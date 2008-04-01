From: frank.blaschka@de.ibm.com
Subject: [patch 1/8] qeth: improve ip_list administration after deregister failures
Date: Tue, 01 Apr 2008 10:26:53 +0200
Message-ID: <20080401082740.781438000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:8041 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbYDAI1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:43 -0400
Content-Disposition: inline; filename=01-qeth_ip_list.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

1. ip_list handling after deregister failure of multicast address:
   If error code "MC Address not found" is returned do not re-add
   multicast address to ip_list.
   For other error codes readd multicast address at the end of
   function qeth_delete_all_mc.
2. ip_list handling after deregister failure or normal ip address:
   If error code "IP Address not found" is returned do not re-add
   multicast address to ip list.
   This is especially important in IP address takeover scenarios,
   to enable re-takeover of a taken over IP address.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_mpc.c |    2 +-
 drivers/s390/net/qeth_core_mpc.h |    2 +-
 drivers/s390/net/qeth_l3_main.c  |   14 +++++++++-----
 3 files changed, 11 insertions(+), 7 deletions(-)

Index: git_davem-2.6.26/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_l3_main.c	2008-03-26 09:21:08.000000000 +0100
+++ git_davem-2.6.26/drivers/s390/net/qeth_l3_main.c	2008-03-31 11:15:50.000000000 +0200
@@ -401,8 +401,11 @@
 static void __qeth_l3_delete_all_mc(struct qeth_card *card,
 					unsigned long *flags)
 {
+	struct list_head fail_list;
 	struct qeth_ipaddr *addr, *tmp;
 	int rc;
+
+	INIT_LIST_HEAD(&fail_list);
 again:
 	list_for_each_entry_safe(addr, tmp, &card->ip_list, entry) {
 		if (addr->is_multicast) {
@@ -410,13 +413,14 @@
 			spin_unlock_irqrestore(&card->ip_lock, *flags);
 			rc = qeth_l3_deregister_addr_entry(card, addr);
 			spin_lock_irqsave(&card->ip_lock, *flags);
-			if (!rc) {
+			if (!rc || (rc == IPA_RC_MC_ADDR_NOT_FOUND))
 				kfree(addr);
-				goto again;
-			} else
-				list_add(&addr->entry, &card->ip_list);
+			else
+				list_add_tail(&addr->entry, &fail_list);
+			goto again;
 		}
 	}
+	list_splice(&fail_list, &card->ip_list);
 }
 
 static void qeth_l3_set_ip_addr_list(struct qeth_card *card)
@@ -467,7 +471,7 @@
 			spin_unlock_irqrestore(&card->ip_lock, flags);
 			rc = qeth_l3_deregister_addr_entry(card, addr);
 			spin_lock_irqsave(&card->ip_lock, flags);
-			if (!rc)
+			if (!rc || (rc == IPA_RC_PRIMARY_ALREADY_DEFINED))
 				kfree(addr);
 			else
 				list_add_tail(&addr->entry, &card->ip_list);
Index: git_davem-2.6.26/drivers/s390/net/qeth_core_mpc.h
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_mpc.h	2008-03-26 09:21:08.000000000 +0100
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_mpc.h	2008-03-31 11:15:50.000000000 +0200
@@ -182,7 +182,7 @@
 	IPA_RC_SETIP_NO_STARTLAN	= 0xe008,
 	IPA_RC_SETIP_ALREADY_RECEIVED	= 0xe009,
 	IPA_RC_IP_ADDR_ALREADY_USED	= 0xe00a,
-	IPA_RC_MULTICAST_FULL		= 0xe00b,
+	IPA_RC_MC_ADDR_NOT_FOUND	= 0xe00b,
 	IPA_RC_SETIP_INVALID_VERSION	= 0xe00d,
 	IPA_RC_UNSUPPORTED_SUBCMD	= 0xe00e,
 	IPA_RC_ARP_ASSIST_NO_ENABLE	= 0xe00f,
Index: git_davem-2.6.26/drivers/s390/net/qeth_core_mpc.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_mpc.c	2008-03-26 09:21:08.000000000 +0100
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_mpc.c	2008-03-31 11:15:50.000000000 +0200
@@ -195,7 +195,7 @@
 	{IPA_RC_SETIP_NO_STARTLAN,	"Setip no startlan received"},
 	{IPA_RC_SETIP_ALREADY_RECEIVED,	"Setip already received"},
 	{IPA_RC_IP_ADDR_ALREADY_USED,	"IP address already in use on LAN"},
-	{IPA_RC_MULTICAST_FULL,		"No task available, multicast full"},
+	{IPA_RC_MC_ADDR_NOT_FOUND,	"Multicast address not found"},
 	{IPA_RC_SETIP_INVALID_VERSION,	"SETIP invalid IP version"},
 	{IPA_RC_UNSUPPORTED_SUBCMD,	"Unsupported assist subcommand"},
 	{IPA_RC_ARP_ASSIST_NO_ENABLE,	"Only partial success, no enable"},

-- 
