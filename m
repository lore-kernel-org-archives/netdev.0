From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 9/9] nfp: prevent theoretical buffer overrun in nfp_eth_read_ports
Date: Wed,  8 Mar 2017 08:57:08 -0800
Message-ID: <20170308165708.96087-10-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34479 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753790AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pf0-f171.google.com with SMTP id v190so16984130pfb.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:16 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>

Prevent theoretical buffer overrun by returning an error if
the number of entries returned by the firmware does not match those
present.

Also use a common handling error path.

Found by inspection.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Tested-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 34 +++++++++++++---------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 10a0c8392d2b..38bd80077e33 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -191,8 +191,7 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 {
 	struct eth_table_entry *entries;
 	struct nfp_eth_table *table;
-	unsigned int cnt;
-	int i, j, ret;
+	int i, j, ret, cnt = 0;
 
 	entries = kzalloc(NSP_ETH_TABLE_SIZE, GFP_KERNEL);
 	if (!entries)
@@ -201,24 +200,27 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 	ret = nfp_nsp_read_eth_table(nsp, entries, NSP_ETH_TABLE_SIZE);
 	if (ret < 0) {
 		nfp_err(cpp, "reading port table failed %d\n", ret);
-		kfree(entries);
-		return NULL;
+		goto err;
 	}
 
-	/* Some versions of flash will give us 0 instead of port count */
-	cnt = ret;
-	if (!cnt) {
-		for (i = 0; i < NSP_ETH_MAX_COUNT; i++)
-			if (entries[i].port & NSP_ETH_PORT_LANES_MASK)
-				cnt++;
+	for (i = 0; i < NSP_ETH_MAX_COUNT; i++)
+		if (entries[i].port & NSP_ETH_PORT_LANES_MASK)
+			cnt++;
+
+	/* Some versions of flash will give us 0 instead of port count.
+	 * For those that give a port count, verify it against the value
+	 * calculated above.
+	 */
+	if (ret && ret != cnt) {
+		nfp_err(cpp, "table entry count reported (%d) does not match entries present (%d)\n",
+			ret, cnt);
+		goto err;
 	}
 
 	table = kzalloc(sizeof(*table) +
 			sizeof(struct nfp_eth_table_port) * cnt, GFP_KERNEL);
-	if (!table) {
-		kfree(entries);
-		return NULL;
-	}
+	if (!table)
+		goto err;
 
 	table->count = cnt;
 	for (i = 0, j = 0; i < NSP_ETH_MAX_COUNT; i++)
@@ -231,6 +233,10 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 	kfree(entries);
 
 	return table;
+
+err:
+	kfree(entries);
+	return NULL;
 }
 
 /**
-- 
2.11.0
