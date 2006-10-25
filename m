From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 25 Oct 2006 15:04:06 -0700
Message-ID: <20061025220406.GA5413@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:18883 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751698AbWJYWEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 18:04:11 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="remove_d80211_fifo_qdisc.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wme.c needs a generic fifo qdisc for each hardware queue.  Switch 
wme.c to use the generic fifo qdisc in net/sched/sch_fifo.c.  This allows
removal of net/d80211/fifo_qdisc.c which isn't particularily tied to
IEEE 802.11 in any way.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/Makefile
===================================================================
--- wireless-dev.orig/net/d80211/Makefile
+++ wireless-dev/net/d80211/Makefile
@@ -21,6 +21,3 @@ obj-$(CONFIG_D80211) += 80211.o rc80211_
 	wme.o \
 	$(80211-objs-y)
 
-ifeq ($(CONFIG_NET_SCHED),)
-  80211-objs += fifo_qdisc.o
-endif
Index: wireless-dev/net/d80211/wme.c
===================================================================
--- wireless-dev.orig/net/d80211/wme.c
+++ wireless-dev/net/d80211/wme.c
@@ -18,8 +18,6 @@
 #include "ieee80211_i.h"
 #include "wme.h"
 
-#define CHILD_QDISC_OPS pfifo_qdisc_ops
-
 static inline int WLAN_FC_IS_QOS_DATA(u16 fc)
 {
 	return (fc & 0x8C) == 0x88;
@@ -433,7 +431,7 @@ static int wme_qdiscop_init(struct Qdisc
 	/* create child queues */
 	for (i = 0; i < queues; i++) {
 		skb_queue_head_init(&q->requeued[i]);
-		q->queues[i] = qdisc_create_dflt(qd->dev, &CHILD_QDISC_OPS);
+		q->queues[i] = qdisc_create_dflt(qd->dev, &pfifo_qdisc_ops);
 		if (q->queues[i] == 0) {
 			q->queues[i] = &noop_qdisc;
 			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
Index: wireless-dev/net/d80211/fifo_qdisc.c
===================================================================
--- wireless-dev.orig/net/d80211/fifo_qdisc.c
+++ /dev/null
@@ -1,102 +0,0 @@
-/*
- * Copyright 2005, Devicescape Software, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * If building without CONFIG_NET_SCHED we need a simple
- * fifo qdisc to install by default as the sub-qdisc.
- * This is a simple replacement for sch_fifo.
- */
-
-#include <linux/skbuff.h>
-#include <net/pkt_sched.h>
-#include <net/d80211.h>
-#include "ieee80211_i.h"
-#include "wme.h"
-
-static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* qd)
-{
-	struct sk_buff_head *q = qdisc_priv(qd);
-
-	if (skb_queue_len(q) > qd->dev->tx_queue_len) {
-		qd->qstats.drops++;
-		kfree_skb(skb);
-		return NET_XMIT_DROP;
-	}
-
-	skb_queue_tail(q, skb);
-	qd->q.qlen++;
-	qd->bstats.bytes += skb->len;
-	qd->bstats.packets++;
-
-	return NET_XMIT_SUCCESS;
-}
-
-
-static int pfifo_requeue(struct sk_buff *skb, struct Qdisc* qd)
-{
-	struct sk_buff_head *q = qdisc_priv(qd);
-
-	skb_queue_head(q, skb);
-	qd->q.qlen++;
-	qd->bstats.bytes += skb->len;
-	qd->bstats.packets++;
-
-	return NET_XMIT_SUCCESS;
-}
-
-
-static struct sk_buff *pfifo_dequeue(struct Qdisc* qd)
-{
-	struct sk_buff_head *q = qdisc_priv(qd);
-
-	return skb_dequeue(q);
-}
-
-
-static int pfifo_init(struct Qdisc* qd, struct rtattr *opt)
-{
-	struct sk_buff_head *q = qdisc_priv(qd);
-
-	skb_queue_head_init(q);
-	return 0;
-}
-
-
-static void pfifo_reset(struct Qdisc* qd)
-{
-	struct sk_buff_head *q = qdisc_priv(qd);
-
-	skb_queue_purge(q);
-	qd->q.qlen = 0;
-}
-
-
-static int pfifo_dump(struct Qdisc *qd, struct sk_buff *skb)
-{
-	return skb->len;
-}
-
-
-struct Qdisc_ops pfifo_qdisc_ops =
-{
-	.next = NULL,
-	.cl_ops = NULL,
-	.id = "ieee80211_pfifo",
-	.priv_size = sizeof(struct sk_buff_head),
-
-	.enqueue = pfifo_enqueue,
-	.dequeue = pfifo_dequeue,
-	.requeue = pfifo_requeue,
-	.drop = NULL,
-
-	.init = pfifo_init,
-	.reset = pfifo_reset,
-	.destroy = NULL,
-	.change = NULL,
-
-	.dump = pfifo_dump,
-};
-
Index: wireless-dev/net/d80211/Kconfig
===================================================================
--- wireless-dev.orig/net/d80211/Kconfig
+++ wireless-dev/net/d80211/Kconfig
@@ -3,6 +3,7 @@ config D80211
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select NET_SCHED
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.

--
