From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] net: Handle NETREG_UNINITIALIZED devices correctly
Date: Wed, 09 Dec 2009 13:56:02 +0530
Message-ID: <20091209082602.19053.97297.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:55854 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbZLII0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 03:26:00 -0500
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB98MnES014466
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 19:22:49 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB98Q5vG1089650
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 19:26:05 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB98Q4N9027367
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 19:26:05 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Fix two problems:

1. If unregister_netdevice_many() is called with both registered
   and unregistered devices, rollback_registered_many() bails out
   when it reaches the first unregistered device. The processing
   of the prior registered devices is unfinished, and the
   remaining devices are skipped, and possible registered netdev's
   are leaked/unregistered.

2. System hangs or panics depending on how the devices are passed,
   since when netdev_run_todo() runs, some devices were not fully
   processed.

Tested by passing intermingled unregistered and registered vlan
devices to unregister_netdevice_many() as follows:
	1. dev, fake_dev1, fake_dev2: hangs in run_todo
	   ("unregister_netdevice: waiting for eth1.100 to become
	    free. Usage count = 1")
	2. fake_dev1, dev, fake_dev2: failure during de-registration
	   and next registration, followed by a vlan driver Oops
	   during subsequent registration.

Confirmed that the patch fixes both cases.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/core/dev.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c	2009-12-04 18:46:13.000000000 +0530
+++ new/net/core/dev.c	2009-12-05 10:23:25.000000000 +0530
@@ -4771,21 +4771,23 @@ static void net_set_todo(struct net_devi
 
 static void rollback_registered_many(struct list_head *head)
 {
-	struct net_device *dev;
+	struct net_device *dev, *tmp;
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
 
-	list_for_each_entry(dev, head, unreg_list) {
+	list_for_each_entry_safe(dev, tmp, head, unreg_list) {
 		/* Some devices call without registering
-		 * for initialization unwind.
+		 * for initialization unwind. Remove those
+		 * devices and proceed with the remaining.
 		 */
 		if (dev->reg_state == NETREG_UNINITIALIZED) {
 			pr_debug("unregister_netdevice: device %s/%p never "
 				 "was registered\n", dev->name, dev);
 
 			WARN_ON(1);
-			return;
+			list_del(&dev->unreg_list);
+			continue;
 		}
 
 		BUG_ON(dev->reg_state != NETREG_REGISTERED);
