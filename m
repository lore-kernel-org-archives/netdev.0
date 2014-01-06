From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/3] be2net: disable RSS when number of RXQs is reduced to 1 via set-channels
Date: Mon, 6 Jan 2014 13:02:23 +0530
Message-ID: <1388993545-25634-2-git-send-email-sathya.perla@emulex.com>
References: <1388993545-25634-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19012 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbaAFH2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 02:28:32 -0500
In-Reply-To: <1388993545-25634-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

When *only* the default RXQ is used, the RSS policy must be disabled so
that all IP and no-IP traffic is placed into the default RXQ. If not,
IP traffic is dropped.

Also, issue the RSS_CONFIG cmd only if FW advertises RSS capability for
the interface.
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
 drivers/net/ethernet/emulex/benet/be_main.c |   15 +++++++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index e0e8bc1..b84902e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2017,6 +2017,9 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 			0x3ea83c02, 0x4a110304};
 	int status;
 
+	if (!(be_if_cap_flags(adapter) & BE_IF_FLAGS_RSS))
+		return 0;
+
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
 		return -1;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0fde69d..6b774a5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2744,13 +2744,16 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 		if (!BEx_chip(adapter))
 			adapter->rss_flags |= RSS_ENABLE_UDP_IPV4 |
 						RSS_ENABLE_UDP_IPV6;
+	} else {
+		/* Disable RSS, if only default RX Q is created */
+		adapter->rss_flags = RSS_ENABLE_NONE;
+	}
 
-		rc = be_cmd_rss_config(adapter, rsstable, adapter->rss_flags,
-				       128);
-		if (rc) {
-			adapter->rss_flags = 0;
-			return rc;
-		}
+	rc = be_cmd_rss_config(adapter, rsstable, adapter->rss_flags,
+			       128);
+	if (rc) {
+		adapter->rss_flags = RSS_ENABLE_NONE;
+		return rc;
 	}
 
 	/* First time posting */
-- 
1.7.1
