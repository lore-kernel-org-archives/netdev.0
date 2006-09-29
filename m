From: David Miller <davem@davemloft.net>
Subject: Re: rewriting skb->truesize... good or bad idea
Date: Fri, 29 Sep 2006 14:31:39 -0700 (PDT)
Message-ID: <20060929.143139.74560775.davem@davemloft.net>
References: <451D6319.1040506@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1254
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964836AbWI2Vbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:31:38 -0400
To: vladislav.yasevich@hp.com
In-Reply-To: <451D6319.1040506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 29 Sep 2006 14:16:57 -0400

> I've attached the patch, in case people want to look at the code.
> 
> However, we question if this is a good idea or if this is going to break
> things...

Modification of skb->truesize is very dangerous and is only legal
in a very limited set of circumstances.

The core problem is that if any other reference exists to the skb
you could corrupt existing socket accounting by changing skb->truesize.

Let's say that the packet went into a network tap like tcpdump and
the packet has been charged to an AF_PACKET socket via skb->truesize.
If you modify skb->truesize then when the AF_PACKET socket releases
it's reference it will subtract the wrong amount of skb->truesize
from the socket receive buffer.

If, on the other hand, you know you have exclusive access to the
skb and there are no other references, setting skb->truesize can
be OK.  However setting it to sizeof(struct sk_buff) doesn't make
sense since there is at least:

	sizeof(struct sk_buff) + sizeof(struct skb_shared_info)

memory assosciated with any SKB whatsoever in the kernel.  That is,
even for a "zero length" skb->data buffer, we still always allocate
the skb_shared_info area which must be accounted for.

BTW, I think the whole chunking mechanism in the SCTP code is the
largest source of problems and maintainability issues in that stack.
Any time I want to make major modifications to SKBs to make them
smaller or whatever, the most difficult piece of code to adjust is
this code.
