From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some issues
Date: Mon, 07 Sep 2015 16:54:46 +0200
Message-ID: <55EDA536.10707@iogearbox.net>
References: <20150814085807.GA30443@gmail.com>	<55CDBC84.8020605@iogearbox.net>	<55CDC51D.1060204@iogearbox.net> <20150817.140222.1763422851882964859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, netdev@vger.kernel.org, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39533 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbbIGOyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 10:54:50 -0400
In-Reply-To: <20150817.140222.1763422851882964859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2015 11:02 PM, David Miller wrote:
...
> I would seriously rather see us do an expensive full copy of the SKB
> than to have traffic which is unexpectedly invisible to taps.

I've been looking into this issue a bit further, so the copy for the
tap seems doable, but while further going through the code to find similar
issues elsewhere, and doing some experiments, it looks like we write
shared info also in some edge-cases of upcalls such as nfqueue or ovs
when mmaped netlink is used for rx. I did a test with nfqueue using
the libmnl mmap branch [1].

My test case reduced the hard-coded frame size in libmnl to 4096. I
then crafted via pktgen in receive mode skbs that f.e. have a MTU
of 9000, and which do contain page frags. Redirecting that traffic
into nfqueue with a listener that is rx mmaped, I can see that in case
of nfqnl_build_packet_message(), the kernel is, when invoking skb_zerocopy(),
failing the (len <= skb_tailroom(to)) condition, writing some header
part, and filling the rest with frags[] in the for loop (thus writing/
leaking into the user mmap buffer), so given the right preconditions,
the kernel wouldn't prevent us from doing that.

One way to fix it would be to change netlink_alloc_skb() and all its
call-sites to add another size param, say 'ldiff', that would contain
the size difference that would be needed to copy the non-linear parts
from the network skb into the linear ring buffer slot of the netlink skb.
Thus, that also in case it exceeds the slot size, the kernel will just
fall back to alloc_skb() inside of netlink_alloc_skb() and fill the
slot with status NL_MMAP_STATUS_COPY. With this, no doubt it's not
super pretty to add that additional size param, but the kernel could
still work with mmap receivers.

Other than that, I found an skb_copy() in __netlink_dump_start(), but
that is a left-over from tx mmap in netlink, so not an issue here.

Thanks,
Daniel

   [1] http://git.netfilter.org/libmnl/log/?h=nl-mmap
