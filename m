From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Mon, 14 Mar 2016 20:16:44 +0200
Message-ID: <CALzJLG9rB4iBnOC0f+8NopjdS407-WJ9b7KFUPO9hjbwFCyP-A@mail.gmail.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	<1457703594-9482-9-git-send-email-saeedm@mellanox.com>
	<1457706771.2663.37.camel@edumazet-ThinkPad-T530>
	<CALzJLG_XU-KMp8dMqcNOpu1OxZRnJro4LFQohK=FLX+5uJKXpQ@mail.gmail.com>
	<1457726319.2663.50.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33158 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789AbcCNSQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:16:45 -0400
Received: by mail-yw0-f195.google.com with SMTP id g6so12428787ywb.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 11:16:44 -0700 (PDT)
In-Reply-To: <1457726319.2663.50.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 9:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

>> I totally agree with this, we should have reported  skb->truesize +=
>> (consumed strides)*(stride size).
>> but again this is not as critical as you think, in the worst case
>> skb->truesize will be off by 127B at most.
>
> Ouch. really you are completely wrong.

It it is just a matter of perspective, quoting:
http://vger.kernel.org/~davem/skb_sk.html
"This is the total of how large a data buffer we allocated for the
packet, plus the size of 'struct sk_buff' itself."

as explained more than once, a page used in ConnectX4 MPWQE approach
can be used for more than one packet, according to the above
documentation and many other examples in the kernel, each packet will
report as much data buffer as it used from that page, and we allocated
for that packet: #strides * stridesize from that page, (common sense).

it is really uncalled-for to report for each SKB, skb->truesize +=
PAGE_SIZE for the same shared reuseable page, as we did in here and as
other drivers already do.

It is just ridiculous to report PAGE_SIZE for SKB that used only 128B
and the others parts of that page are being either reused by HW or
reported back to the stack and we already did the truesize accounting
on their parts.

It seems to me that reporting PAGE_SIZE* (#SKBs pointing to that page)
for all of those SKBs is just a big lie and it is just an abuse to the
skb->truesize to protect against special/rare cases like OOO issue
that I can suggest a handful of solutions (out of this thread scope)
for them without the need of lying in device drivers of the actual
truesize.
Think about it, if SKBs share the same page then SUM(SKBs->truesize) =
PAGE_SIZE.

and suppose you are right, why just not  remove the truesize param
from skb_add_rx_frag, and just explicitly do skb->true_szie +=
PAGE_SIZE, hardcoded inside that function? or rename the truesize
param to pageorder ?

>
> If one skb has a fragment of a page, and sits in a queue for a long
> time, it really uses a full page, because the remaining part of the page
> is not reusable. Only kmalloc(128) can deal with that idea of allowing
> other parts of the page being 'freed and reusable'
This concern was also true before this series for other drivers in the
kernel, who use pages for fragmented SKBs and non of them report
PAGE_SIZE as SKB->truesize, as their pages are reuseable.

>
> It is trivial for an attacker to make sure the host will consume one
> page + sk_buff + skb->head = 4096 + 256 + 512, by specially sending out
> of order packets on TCP flows.
we can do special accounting for ooo like issues in the stack (maybe
count page references and sum up page sizes as you suggest), device
drivers shouldn't have special handling/accounting to protect against
such cases.
