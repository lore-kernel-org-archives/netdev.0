From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Tue, 10 Nov 2009 17:50:38 +0100
Message-ID: <4AF999DE.9060206@trash.net>
References: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39933 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757212AbZKJQui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 11:50:38 -0500
In-Reply-To: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ben@bigfootnetworks.com wrote:
> We have observed significant reassembly errors when combining
> routing/bridging with conntrack + nf_defrag_ipv4 loaded, and
> skb_recycle_check - enabled interfaces.  For our test, we had a single
> linux device with two interfaces (gianfars in this case) with SKB
> recycling enabled.  We sent large, continuous pings across the bridge,
> like this:
> ping -s 64000 -A <dest IP>
> 
> Then, we ran netstat -s --raw, and noticed that IPSTATS_MIB_REASMFAILS
> were happening for about 40% of the received datagrams.  Tracing the
> code in ip_fragment.c, we instrumented each of the
> IPSTATS_MIB_REASMFAILS locations, and found the culprit to be
> ip_evictor.  Nothing looked unusual here, so we placed tracing in
> ip_frag_queue, directly above:
> 	atomic_add(skb->truesize, &qp->q.net->mem);
> 
> We noticed that quite a few of the skb->truesize numbers were in the 67K
> range, which quickly overwhelms the default 192K-ish ipfrag_low_thresh.
> This means that the next time inet_frag_evictor is run:
>  work = atomic_read(&nf->mem) - nf->low_thresh;
> 
> Will surely be positive, and it is likely that our huge-frag-containing
> queue will be one of those evicted. 
> 
> Looking at the source of these huge skbs, it seems that during
> re-fragmentation in br_nf_dev_queue_xmit (which calls ip_fragment with
> CONFIG_NF_CONNTRACK_IPV4 enabled), the huge datagram that was allocated
> to hold a successfully-reassembled skb may be getting reused?  In any
> case, when skb_recycle_check(skb, min_rx_size) is called, the huge
> (skb->truesize huge, not data huge) skb is recycled for use on RX, and
> it eventually gets enqueued for reassembly, causing the
> inet_frag_evictor to have a positive work value.

Interesting problem. I wonder what the linear size of the skb was
and whether we're just not properly adjusting truesize of the head
during refragmentation.

This code in ip_fragment() looks suspicious:

	if (skb_has_frags(skb)) {
	...
		skb_walk_frags(skb, frag) {
			...
			if (skb->sk) {
				frag->sk = skb->sk;
				frag->destructor = sock_wfree;
				truesizes += frag->truesize;
			}

truesizes is later used to adjust truesize of the head skb.
For some reason this is only done when it originated from a
local socket.

> Our solution was to add an upper-bounds check to skb_recycle_check,
> which prevents the large-ish SKBs from being used to create future
> frags, and overwhelming ipfrag_low_thresh.  This seems quite clunky,
> although I would be happy to submit this as a patch...

This seems reasonable to me, there might be large skbs for
different reasons.
