From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 02:41:23 +0200
Message-ID: <20080731004123.GB22826@xi.wantstofly.org>
References: <20080730235004.GC21999@xi.wantstofly.org> <20080730.165621.211366535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57372 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbYGaAlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:41:25 -0400
Content-Disposition: inline
In-Reply-To: <20080730.165621.211366535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 04:56:21PM -0700, David Miller wrote:

> Thanks for all the great data and testing.

Thanks for taking the time to look at this and replying so quickly!


> > Given this, I'm wondering about the following:
> > 
> > 1. Considering the drop in CPU utilisation, are there reasons not
> >    to use software GSO on non-hardware-GSO-capable netdevices (apart
> >    from GSO possibly confusing tcpdump/iptables/qdiscs/etc)?
> 
> We should probably enable software GSO whenever the device can
> do scatter-gather and checksum offload.

OK.


> > 3. Why does dev_hard_start_xmit() get sent 64 KiB segments when the
> >    link is in 100 Mb/s mode but gso_segs never grows beyond 3 when
> >    the link is in 1000 Mb/s mode?
> 
> Because the link can empty the socket send buffer fast enough such
> that there is often not enough data to coalesce into larger GSO frames.
> At least that's my guess.

Hmmmm.

The hacky patch below (on top of 2.6.27-rc1 + stubbing out the
sk_can_gso() check) reduces the 1 GiB 1000 Mb/s sendfile test from:

	real	0m16.319s	sys	0m13.930s
	real	0m15.680s	sys	0m14.900s
	real	0m15.538s	sys	0m10.410s
	real	0m15.325s	sys	0m8.440s
	real	0m16.147s	sys	0m12.680s
	real	0m15.549s	sys	0m12.840s
	real	0m15.667s	sys	0m13.860s
	real	0m15.509s	sys	0m14.980s
	real	0m15.237s	sys	0m10.850s

to:

	real	0m14.643s	sys	0m3.260s
	real    0m14.547s	sys     0m3.100s
	real    0m14.932s	sys     0m3.290s
	real    0m14.557s	sys     0m3.160s
	real    0m14.712s	sys     0m3.260s
	real    0m14.827s	sys     0m3.360s
	real    0m14.495s	sys     0m3.200s
	real    0m14.575s	sys     0m3.220s
	real    0m14.552s	sys     0m3.420s

(I'm sure there's a better way to enforce larger GSO frames, I don't
know the TCP stack too well.)

I.e. dramatic CPU time improvements, and some overall speedup as well.

I wonder if something like this can be done in a less hacky fashion --
the hard part I guess is deciding when to keep coalescing (to reduce
CPU overhead) vs. when to push out what has been coalesced so far (in
order to keep the pipe filled), and I'm not sure I have good ideas
about how to make that decision.



Index: linux-2.6.27-rc1/net/ipv4/tcp_output.c
===================================================================
--- linux-2.6.27-rc1.orig/net/ipv4/tcp_output.c
+++ linux-2.6.27-rc1/net/ipv4/tcp_output.c
@@ -1544,7 +1544,7 @@ static int tcp_write_xmit(struct sock *s
 			break;
 
 		if (tso_segs == 1) {
-			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
+			if (unlikely(!tcp_nagle_test(tp, skb, 5 * mss_now,
 						     (tcp_skb_is_last(sk, skb) ?
 						      nonagle : TCP_NAGLE_PUSH))))
 				break;
