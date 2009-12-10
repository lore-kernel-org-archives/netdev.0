From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] net: release dst entry while cache-hot for GSO case too
Date: Thu, 10 Dec 2009 12:29:58 +0530
Message-ID: <20091210065958.10261.89370.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:40774 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbZLJG7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 01:59:55 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBA6bHkJ021241
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 12:07:17 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBA700KF311448
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 12:30:00 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBA6xxE3019914
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 17:59:59 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Non-GSO code drops dst entry for performance reasons, but
the same is missing for GSO code. Drop dst while cache-hot
for GSO case too.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2009-12-10 10:20:39.000000000 +0530
+++ new/net/core/dev.c	2009-12-10 10:21:17.000000000 +0530
@@ -1853,6 +1853,14 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
+
+		/*
+		 * If device doesnt need nskb->dst, release it right now while
+		 * its hot in this cpu cache
+		 */
+		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+			skb_dst_drop(nskb);
+
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
