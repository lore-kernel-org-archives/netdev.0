From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Bug Fix: Dont reset ENIC_SET_APPLIED flag
	on port profile disassociate
Date: Thu, 20 Jan 2011 16:35:54 -0800
Message-ID: <20110121003554.25697.15096.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:27395 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701Ab1AUAfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:35:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

enic_get_vf_port returns port profile operation status only if ENIC_SET_APPLIED
flag is set. A recent rework of enic_set_port_profile added code to reset this
flag on disassociate. As a result of which a client calling enic_get_vf_port
to get the status of port profile disassociate will always get a return value
of ENODATA. This patch renames ENIC_SET_APPLIED to more appropriate
ENIC_PORT_REQUEST_APPLIED and reverts back the recent change so that the
flag is set both at associate and disassociate of a port profile.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    6 +++---
 drivers/net/enic/enic_main.c |   10 ++++++----
 2 files changed, 9 insertions(+), 7 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index a937f49..ca3be4f 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,8 +32,8 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.10"
-#define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
+#define DRV_VERSION		"2.1.1.2"
+#define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
 
@@ -49,7 +49,7 @@ struct enic_msix_entry {
 	void *devid;
 };
 
-#define ENIC_SET_APPLIED		(1 << 0)
+#define ENIC_PORT_REQUEST_APPLIED	(1 << 0)
 #define ENIC_SET_REQUEST		(1 << 1)
 #define ENIC_SET_NAME			(1 << 2)
 #define ENIC_SET_INSTANCE		(1 << 3)
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a0af48c..89664c6 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1318,18 +1318,20 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 		vic_provinfo_free(vp);
 		if (err)
 			return err;
-
-		enic->pp.set |= ENIC_SET_APPLIED;
 		break;
 
 	case PORT_REQUEST_DISASSOCIATE:
-		enic->pp.set &= ~ENIC_SET_APPLIED;
 		break;
 
 	default:
 		return -EINVAL;
 	}
 
+	/* Set flag to indicate that the port assoc/disassoc
+	 * request has been sent out to fw
+	 */
+	enic->pp.set |= ENIC_PORT_REQUEST_APPLIED;
+
 	return 0;
 }
 
@@ -1411,7 +1413,7 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 	int err, error, done;
 	u16 response = PORT_PROFILE_RESPONSE_SUCCESS;
 
-	if (!(enic->pp.set & ENIC_SET_APPLIED))
+	if (!(enic->pp.set & ENIC_PORT_REQUEST_APPLIED))
 		return -ENODATA;
 
 	err = enic_dev_init_done(enic, &done, &error);

