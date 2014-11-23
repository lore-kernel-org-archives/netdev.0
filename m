From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] enic: use netdev_rss_key_fill() helper
Date: Sun, 23 Nov 2014 12:27:41 -0800
Message-ID: <1416774461.17888.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Benvenuti <benve@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	netdev <netdev@vger.kernel.org>,
	Sujith Sankar <ssujith@cisco.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:49765 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbaKWU1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 15:27:43 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so7780631ier.41
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 12:27:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use of well known RSS key might increase attack surface.

Switch to a random one, using generic helper so that all
ports share a common key.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>
Cc: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   24 +++++++++---------
 drivers/net/ethernet/cisco/enic/vnic_rss.h  |    9 +++++-
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 46647407d585b54dba0baa5ef357401f17b7c167..86ee350e57f0e03bd79908ade0782d9af99646b4 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1890,23 +1890,23 @@ static int enic_dev_hang_reset(struct enic *enic)
 
 static int enic_set_rsskey(struct enic *enic)
 {
+	union vnic_rss_key *rss_key_buf_va;
 	dma_addr_t rss_key_buf_pa;
-	union vnic_rss_key *rss_key_buf_va = NULL;
-	union vnic_rss_key rss_key = {
-		.key[0].b = {85, 67, 83, 97, 119, 101, 115, 111, 109, 101},
-		.key[1].b = {80, 65, 76, 79, 117, 110, 105, 113, 117, 101},
-		.key[2].b = {76, 73, 78, 85, 88, 114, 111, 99, 107, 115},
-		.key[3].b = {69, 78, 73, 67, 105, 115, 99, 111, 111, 108},
-	};
-	int err;
+	u8 rss_key[ENIC_RSS_LEN];
+	int i, kidx, bidx, err;
 
-	rss_key_buf_va = pci_alloc_consistent(enic->pdev,
-		sizeof(union vnic_rss_key), &rss_key_buf_pa);
+	rss_key_buf_va = pci_zalloc_consistent(enic->pdev,
+					       sizeof(union vnic_rss_key),
+					       &rss_key_buf_pa);
 	if (!rss_key_buf_va)
 		return -ENOMEM;
 
-	memcpy(rss_key_buf_va, &rss_key, sizeof(union vnic_rss_key));
-
+	netdev_rss_key_fill(rss_key, ENIC_RSS_LEN);
+	for (i = 0; i < ENIC_RSS_LEN; i++) {
+		kidx = i / ENIC_RSS_BYTES_PER_KEY;
+		bidx = i % ENIC_RSS_BYTES_PER_KEY;
+		rss_key_buf_va->key[kidx].b[bidx] = rss_key[i];
+	}
 	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_set_rss_key(enic,
 		rss_key_buf_pa,
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rss.h b/drivers/net/ethernet/cisco/enic/vnic_rss.h
index fa421baf45b87eadbf5857843869f1bbcabcdb08..881fa18542b382bc52e222dc4ff47114d052fb00 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rss.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_rss.h
@@ -20,11 +20,16 @@
 #define _VNIC_RSS_H_
 
 /* RSS key array */
+
+#define ENIC_RSS_BYTES_PER_KEY	10
+#define ENIC_RSS_KEYS		4
+#define ENIC_RSS_LEN		(ENIC_RSS_BYTES_PER_KEY * ENIC_RSS_KEYS)
+
 union vnic_rss_key {
 	struct {
-		u8 b[10];
+		u8 b[ENIC_RSS_BYTES_PER_KEY];
 		u8 b_pad[6];
-	} key[4];
+	} key[ENIC_RSS_KEYS];
 	u64 raw[8];
 };
 
