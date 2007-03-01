From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/3] bonding: fix double dev_add_pack
Date: Wed, 28 Feb 2007 17:03:20 -0800
Message-ID: <200703010103.l2113K22030733@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:60141 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932868AbXCABDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 20:03:24 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2113Ntw028262
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:03:23 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l2113Neo539104
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 18:03:23 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2113MlB010913
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 18:03:22 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Bonding can erroneously register the same packet_type to receive
ARPs (for use by ARP validation): once at device open time, and once via
sysfs.  Since sysfs can change the validate setting (and thus register
or unregister) at any time, a flag is needed to synchronize with device
open in order to avoid double registrations, and the simplest place is
within the packet_type structure itself.  Double unregister is not an
issue.

	Bug reported by Ulrich Oelmann <ulrich.oelmann@web.de>.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a7c8f98..1f263ac 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3423,6 +3423,9 @@ void bond_register_arp(struct bonding *b
 {
 	struct packet_type *pt = &bond->arp_mon_pt;
 
+	if (pt->type)
+		return;
+
 	pt->type = htons(ETH_P_ARP);
 	pt->dev = NULL; /*bond->dev;XXX*/
 	pt->func = bond_arp_rcv;
@@ -3431,7 +3434,10 @@ void bond_register_arp(struct bonding *b
 
 void bond_unregister_arp(struct bonding *bond)
 {
-	dev_remove_pack(&bond->arp_mon_pt);
+	struct packet_type *pt = &bond->arp_mon_pt;
+
+	dev_remove_pack(pt);
+	pt->type = 0;
 }
 
 /*---------------------------- Hashing Policies -----------------------------*/
