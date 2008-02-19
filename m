From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: "protocol 0300 is buggy" spam in dmesg when
	injecting&capturing on same interface
Date: Tue, 19 Feb 2008 15:39:25 +0200
Message-ID: <20080219133925.GA21492@ee.oulu.fi>
References: <20080218153903.GA30253@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:34415 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbYBSNj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 08:39:28 -0500
Received: from tk-cn0002.oulu.fi (tk-cn0002 [130.231.63.2])
	by ee.oulu.fi (8.14.2/8.14.2) with ESMTP id m1JDdPjp007396
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:39:26 +0200 (EET)
Received: (from pp@localhost)
	by tk-cn0002.oulu.fi (8.14.2/8.14.2/Submit) id m1JDdP3j021646
	for netdev@vger.kernel.org; Tue, 19 Feb 2008 15:39:25 +0200
Content-Disposition: inline
In-Reply-To: <20080218153903.GA30253@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2008 at 05:39:03PM +0200, Pekka Pietikainen wrote:
> When playing with some L2 level fuzzing I started getting lots of
> "protocol 0300 is buggy, dev eth3" spew in dmesg. That interface is also
> capturing the traffic that's being sent, that's probably why the
> dev_queue_xmit_nit codepath is getting called in the first place.
> 
> Any ideas? Add a "If it came from AF_PACKET, don't print out anything" to
> that if-statement?
I'm probably just plastering over a bug in af_packet.c with this one,
but the following patch should make it shut up. The printk definately
needs a ntohs for skb2->protocol, took me a while to figure out where
the 0300 even came from :-) 

Signed-off-by: Pekka Pietikainen <pp@ee.oulu.fi>

diff -up linux-2.6.24.i686/net/core/dev.c.orig linux-2.6.24.i686/net/core/dev.c
--- linux-2.6.24.i686/net/core/dev.c.orig	2008-02-19 15:22:12.000000000 +0200
+++ linux-2.6.24.i686/net/core/dev.c	2008-02-19 15:29:37.000000000 +0200
@@ -1262,10 +1262,11 @@ static void dev_queue_xmit_nit(struct sk
 
 			if (skb_network_header(skb2) < skb2->data ||
 			    skb2->network_header > skb2->tail) {
-				if (net_ratelimit())
-					printk(KERN_CRIT "protocol %04x is "
-					       "buggy, dev %s\n",
-					       skb2->protocol, dev->name);
+				if (skb2->protocol != htons(ETH_P_ALL) &&
+				    net_ratelimit())
+					pr_crit("protocol %04x is buggy, dev %s\n",
+						ntohs(skb2->protocol),
+						dev->name);
 				skb_reset_network_header(skb2);
 			}
 


-- 
Pekka Pietikainen
