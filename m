From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net 2/3] macsec: fix error codes when a SA is created
Date: Fri, 22 Jul 2016 15:07:57 +0200
Message-ID: <70c7fb50a9be7146cf18d9b469b74608c37200a6.1469191850.git.dcaratti@redhat.com>
References: <cover.1469191850.git.dcaratti@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444AbcGVNJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 09:09:13 -0400
In-Reply-To: <cover.1469191850.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

preserve the return value of AEAD functions that are called when a SA is
created, to avoid inappropriate display of "RTNETLINK answers: Cannot
allocate memory" message.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 drivers/net/macsec.c | 58 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 36 insertions(+), 22 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 7c0e732..6d45ba6 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1263,22 +1263,22 @@ static struct crypto_aead *macsec_alloc_tfm(char *key, int key_len, int icv_len)
 	int ret;
 
 	tfm = crypto_alloc_aead("gcm(aes)", 0, 0);
-	if (!tfm || IS_ERR(tfm))
-		return NULL;
+
+	if (IS_ERR(tfm))
+		return tfm;
 
 	ret = crypto_aead_setkey(tfm, key, key_len);
-	if (ret < 0) {
-		crypto_free_aead(tfm);
-		return NULL;
-	}
+	if (ret < 0)
+		goto fail;
 
 	ret = crypto_aead_setauthsize(tfm, icv_len);
-	if (ret < 0) {
-		crypto_free_aead(tfm);
-		return NULL;
-	}
+	if (ret < 0)
+		goto fail;
 
 	return tfm;
+fail:
+	crypto_free_aead(tfm);
+	return ERR_PTR(ret);
 }
 
 static int init_rx_sa(struct macsec_rx_sa *rx_sa, char *sak, int key_len,
@@ -1286,12 +1286,12 @@ static int init_rx_sa(struct macsec_rx_sa *rx_sa, char *sak, int key_len,
 {
 	rx_sa->stats = alloc_percpu(struct macsec_rx_sa_stats);
 	if (!rx_sa->stats)
-		return -1;
+		return -ENOMEM;
 
 	rx_sa->key.tfm = macsec_alloc_tfm(sak, key_len, icv_len);
-	if (!rx_sa->key.tfm) {
+	if (IS_ERR(rx_sa->key.tfm)) {
 		free_percpu(rx_sa->stats);
-		return -1;
+		return PTR_ERR(rx_sa->key.tfm);
 	}
 
 	rx_sa->active = false;
@@ -1384,12 +1384,12 @@ static int init_tx_sa(struct macsec_tx_sa *tx_sa, char *sak, int key_len,
 {
 	tx_sa->stats = alloc_percpu(struct macsec_tx_sa_stats);
 	if (!tx_sa->stats)
-		return -1;
+		return -ENOMEM;
 
 	tx_sa->key.tfm = macsec_alloc_tfm(sak, key_len, icv_len);
-	if (!tx_sa->key.tfm) {
+	if (IS_ERR(tx_sa->key.tfm)) {
 		free_percpu(tx_sa->stats);
-		return -1;
+		return PTR_ERR(tx_sa->key.tfm);
 	}
 
 	tx_sa->active = false;
@@ -1622,6 +1622,7 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 	unsigned char assoc_num;
 	struct nlattr *tb_rxsc[MACSEC_RXSC_ATTR_MAX + 1];
 	struct nlattr *tb_sa[MACSEC_SA_ATTR_MAX + 1];
+	int err;
 
 	if (!attrs[MACSEC_ATTR_IFINDEX])
 		return -EINVAL;
@@ -1658,13 +1659,19 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	rx_sa = kmalloc(sizeof(*rx_sa), GFP_KERNEL);
-	if (!rx_sa || init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
-				 secy->key_len, secy->icv_len)) {
-		kfree(rx_sa);
+	if (!rx_sa) {
 		rtnl_unlock();
 		return -ENOMEM;
 	}
 
+	err = init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
+			 secy->key_len, secy->icv_len);
+	if (err < 0) {
+		kfree(rx_sa);
+		rtnl_unlock();
+		return err;
+	}
+
 	if (tb_sa[MACSEC_SA_ATTR_PN]) {
 		spin_lock_bh(&rx_sa->lock);
 		rx_sa->next_pn = nla_get_u32(tb_sa[MACSEC_SA_ATTR_PN]);
@@ -1770,6 +1777,7 @@ static int macsec_add_txsa(struct sk_buff *skb, struct genl_info *info)
 	struct macsec_tx_sa *tx_sa;
 	unsigned char assoc_num;
 	struct nlattr *tb_sa[MACSEC_SA_ATTR_MAX + 1];
+	int err;
 
 	if (!attrs[MACSEC_ATTR_IFINDEX])
 		return -EINVAL;
@@ -1806,13 +1814,19 @@ static int macsec_add_txsa(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	tx_sa = kmalloc(sizeof(*tx_sa), GFP_KERNEL);
-	if (!tx_sa || init_tx_sa(tx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
-				 secy->key_len, secy->icv_len)) {
-		kfree(tx_sa);
+	if (!tx_sa) {
 		rtnl_unlock();
 		return -ENOMEM;
 	}
 
+	err = init_tx_sa(tx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
+			 secy->key_len, secy->icv_len);
+	if (err < 0) {
+		kfree(tx_sa);
+		rtnl_unlock();
+		return err;
+	}
+
 	nla_memcpy(tx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEYID], MACSEC_KEYID_LEN);
 
 	spin_lock_bh(&tx_sa->lock);
-- 
2.5.5
