From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/14] be2net:use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:10 -0800
Message-ID: <1416147798-16561-7-git-send-email-edumazet@google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:40595 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086AbaKPOX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:23:58 -0500
Received: by mail-qa0-f73.google.com with SMTP id j7so189235qaq.2
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:23:57 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_rss_key_fill() helper, as it provides better support for some
bonding setups.
Rename rss_hkey local variable to rss_key to have consistent name among
drivers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9a18e7930b31..54160cc62656 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2853,10 +2853,10 @@ static int be_close(struct net_device *netdev)
 
 static int be_rx_qs_create(struct be_adapter *adapter)
 {
+	struct rss_info *rss = &adapter->rss_info;
+	u8 rss_key[RSS_HASH_KEY_LEN];
 	struct be_rx_obj *rxo;
 	int rc, i, j;
-	u8 rss_hkey[RSS_HASH_KEY_LEN];
-	struct rss_info *rss = &adapter->rss_info;
 
 	for_all_rx_queues(adapter, rxo, i) {
 		rc = be_queue_alloc(adapter, &rxo->q, RX_Q_LEN,
@@ -2901,15 +2901,15 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 		rss->rss_flags = RSS_ENABLE_NONE;
 	}
 
-	get_random_bytes(rss_hkey, RSS_HASH_KEY_LEN);
+	netdev_rss_key_fill(rss_key, RSS_HASH_KEY_LEN);
 	rc = be_cmd_rss_config(adapter, rss->rsstable, rss->rss_flags,
-			       128, rss_hkey);
+			       128, rss_key);
 	if (rc) {
 		rss->rss_flags = RSS_ENABLE_NONE;
 		return rc;
 	}
 
-	memcpy(rss->rss_hkey, rss_hkey, RSS_HASH_KEY_LEN);
+	memcpy(rss->rss_hkey, rss_key, RSS_HASH_KEY_LEN);
 
 	/* First time posting */
 	for_all_rx_queues(adapter, rxo, i)
-- 
2.1.0.rc2.206.gedb03e5
