From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 15 Jan 2010 11:01:17 +0530
Message-ID: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:34592 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab0AOFbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 00:31:25 -0500
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0F5VL0m018751
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:31:21 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0F5Qmou1101946
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:26:50 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0F5VKaP028604
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:31:20 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A developer had complained of getting lots of warnings:

"eth16 selects TX queue 98, but real number of TX queues is 64"

http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg02200.html

As there was no follow up on that bug, I am submitting this
patch assuming that the other return points will not return
invalid txq's, and also that this fixes the bug (not tested).

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -ruNp org/drivers/net/ixgbe/ixgbe_main.c new/drivers/net/ixgbe/ixgbe_main.c
--- org/drivers/net/ixgbe/ixgbe_main.c	2010-01-12 11:50:24.000000000 +0530
+++ new/drivers/net/ixgbe/ixgbe_main.c	2010-01-12 11:50:44.000000000 +0530
@@ -5514,8 +5514,11 @@ static u16 ixgbe_select_queue(struct net
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int txq = smp_processor_id();
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+		while (unlikely(txq >= dev->real_num_tx_queues))
+			txq -= dev->real_num_tx_queues;
 		return txq;
+	}
 
 #ifdef IXGBE_FCOE
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
