From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Additional run-tme check [Run-time kfree check for correct cache]
Date: Thu, 1 Mar 2007 19:17:44 +0300
Message-ID: <20070301161744.GB16344@2ka.mipt.ru>
References: <20070227.100052.59655152.davem@davemloft.net> <20070227.102452.102574618.davem@davemloft.net> <20070228090258.GA28336@2ka.mipt.ru> <200702281110.54619.dada1@cosmosbay.com> <20070228141652.GA3033@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, paul.moore@hp.com,
	kaber@trash.net, netdev@vger.kernel.org, acme@ghostprotocols.net,
	Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53940 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965318AbXCAQUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 11:20:19 -0500
Content-Disposition: inline
In-Reply-To: <20070228141652.GA3033@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to slab poisoning after origianl freeing, skb->users will not allow
subsequent freeing to succeed and fire slab debugging, which ends up
with obscure bugs.

Patch based on Eric Sesterhenn's <snakebyte@gmx.de> one, I changed
check to skb>truesize instead of skb->users.counter, since the latter in
theory can be different than simple integer containing structure.

--- linux/net/core/skbuff.c.orig	2007-02-28 11:34:13.865540564 +0100
+++ linux/net/core/skbuff.c	2007-03-01 13:42:05.633136591 +0100
@@ -407,6 +407,11 @@ void kfree_skb(struct sk_buff *skb)
 {
 	if (unlikely(!skb))
 		return;
+#ifdef CONFIG_DEBUG_SLAB
+	/* check for double kfree_skb() */
+	WARN_ON(unlikely((skb->truesize & 0xFFFFFFFF) == 0x6b6b6b6b));
+#endif
+
 	if (likely(atomic_read(&skb->users) == 1))
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))

-- 
	Evgeniy Polyakov
