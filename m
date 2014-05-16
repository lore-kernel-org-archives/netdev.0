From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 06/11] mac802154: integrate llsec with wpan devices
Date: Fri, 16 May 2014 17:46:40 +0200
Message-ID: <1400255205-9031-7-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39851 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833AbaEPPrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:47:11 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4GFl1W3031667
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 17:47:01 +0200
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/net/ieee802154_netdev.h |    3 +
 net/mac802154/mac802154.h       |   10 ++++
 net/mac802154/wpan.c            |  118 +++++++++++++++++++++++++++++----------
 3 files changed, 103 insertions(+), 28 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 6f8f9c2..000c855 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -225,6 +225,9 @@ struct ieee802154_mac_cb {
 	u8 type;
 	bool ackreq;
 	bool secen;
+	bool secen_override;
+	u8 seclevel;
+	bool seclevel_override;
 	struct ieee802154_addr source;
 	struct ieee802154_addr dest;
 };
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index e05f66e..a8d7cbc 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -23,9 +23,12 @@
 #ifndef MAC802154_H
 #define MAC802154_H
 
+#include <linux/mutex.h>
 #include <net/mac802154.h>
 #include <net/ieee802154_netdev.h>
 
+#include "llsec.h"
+
 /* mac802154 device private data */
 struct mac802154_priv {
 	struct ieee802154_dev hw;
@@ -91,6 +94,13 @@ struct mac802154_sub_if_data {
 	u8 bsn;
 	/* MAC DSN field */
 	u8 dsn;
+
+	/* protects sec from concurrent access by netlink. access by
+	 * encrypt/decrypt/header_create safe without additional protection.
+	 */
+	struct mutex sec_mtx;
+
+	struct mac802154_llsec sec;
 };
 
 #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index ed10577..00729ca 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -183,6 +183,38 @@ out:
 	return rc;
 }
 
+static int mac802154_set_header_security(struct mac802154_sub_if_data *priv,
+					 struct ieee802154_hdr *hdr,
+					 const struct ieee802154_mac_cb *cb)
+{
+	struct ieee802154_llsec_params params;
+	u8 level;
+
+	mac802154_llsec_get_params(&priv->sec, &params);
+
+	if (!params.enabled && cb->secen_override && cb->secen)
+		return -EINVAL;
+	if (!params.enabled ||
+	    (cb->secen_override && !cb->secen) ||
+	    !params.out_level)
+		return 0;
+	if (cb->seclevel_override && !cb->seclevel)
+		return -EINVAL;
+
+	level = cb->seclevel_override ? cb->seclevel : params.out_level;
+
+	hdr->fc.security_enabled = 1;
+	hdr->sec.level = level;
+	hdr->sec.key_id_mode = params.out_key.mode;
+	if (params.out_key.mode == IEEE802154_SCF_KEY_SHORT_INDEX)
+		hdr->sec.short_src = params.out_key.short_source;
+	else if (params.out_key.mode == IEEE802154_SCF_KEY_HW_INDEX)
+		hdr->sec.extended_src = params.out_key.extended_source;
+	hdr->sec.key_id = params.out_key.id;
+
+	return 0;
+}
+
 static int mac802154_header_create(struct sk_buff *skb,
 				   struct net_device *dev,
 				   unsigned short type,
@@ -204,6 +236,9 @@ static int mac802154_header_create(struct sk_buff *skb,
 	hdr.fc.ack_request = cb->ackreq;
 	hdr.seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 
+	if (mac802154_set_header_security(priv, &hdr, cb) < 0)
+		return -EINVAL;
+
 	if (!saddr) {
 		spin_lock_bh(&priv->mib_lock);
 
@@ -259,6 +294,7 @@ mac802154_wpan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv;
 	u8 chan, page;
+	int rc;
 
 	priv = netdev_priv(dev);
 
@@ -274,6 +310,13 @@ mac802154_wpan_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
+	rc = mac802154_llsec_encrypt(&priv->sec, skb);
+	if (rc) {
+		pr_warn("encryption failed: %i\n", rc);
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
 	skb->skb_iif = dev->ifindex;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
@@ -294,6 +337,15 @@ static const struct net_device_ops mac802154_wpan_ops = {
 	.ndo_set_mac_address	= mac802154_wpan_mac_addr,
 };
 
+static void mac802154_wpan_free(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	mac802154_llsec_destroy(&priv->sec);
+
+	free_netdev(dev);
+}
+
 void mac802154_wpan_setup(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv;
@@ -303,14 +355,14 @@ void mac802154_wpan_setup(struct net_device *dev)
 
 	dev->hard_header_len	= MAC802154_FRAME_HARD_HEADER_LEN;
 	dev->header_ops		= &mac802154_header_ops;
-	dev->needed_tailroom	= 2; /* FCS */
+	dev->needed_tailroom	= 2 + 16; /* FCS + MIC */
 	dev->mtu		= IEEE802154_MTU;
 	dev->tx_queue_len	= 300;
 	dev->type		= ARPHRD_IEEE802154;
 	dev->flags		= IFF_NOARP | IFF_BROADCAST;
 	dev->watchdog_timeo	= 0;
 
-	dev->destructor		= free_netdev;
+	dev->destructor		= mac802154_wpan_free;
 	dev->netdev_ops		= &mac802154_wpan_ops;
 	dev->ml_priv		= &mac802154_mlme_wpan;
 
@@ -321,6 +373,7 @@ void mac802154_wpan_setup(struct net_device *dev)
 	priv->page = 0;
 
 	spin_lock_init(&priv->mib_lock);
+	mutex_init(&priv->sec_mtx);
 
 	get_random_bytes(&priv->bsn, 1);
 	get_random_bytes(&priv->dsn, 1);
@@ -333,6 +386,8 @@ void mac802154_wpan_setup(struct net_device *dev)
 
 	priv->pan_id = cpu_to_le16(IEEE802154_PANID_BROADCAST);
 	priv->short_addr = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
+
+	mac802154_llsec_init(&priv->sec);
 }
 
 static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
@@ -341,9 +396,11 @@ static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
 }
 
 static int
-mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
+mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb,
+		      const struct ieee802154_hdr *hdr)
 {
 	__le16 span, sshort;
+	int rc;
 
 	pr_debug("getting packet via slave interface %s\n", sdata->dev->name);
 
@@ -390,6 +447,12 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 
 	skb->dev = sdata->dev;
 
+	rc = mac802154_llsec_decrypt(&sdata->sec, skb);
+	if (rc) {
+		pr_debug("decryption failed: %i\n", rc);
+		return NET_RX_DROP;
+	}
+
 	sdata->dev->stats.rx_packets++;
 	sdata->dev->stats.rx_bytes += skb->len;
 
@@ -421,60 +484,58 @@ static void mac802154_print_addr(const char *name,
 	}
 }
 
-static int mac802154_parse_frame_start(struct sk_buff *skb)
+static int mac802154_parse_frame_start(struct sk_buff *skb,
+				       struct ieee802154_hdr *hdr)
 {
 	int hlen;
-	struct ieee802154_hdr hdr;
 	struct ieee802154_mac_cb *cb = mac_cb_init(skb);
 
-	hlen = ieee802154_hdr_pull(skb, &hdr);
+	hlen = ieee802154_hdr_pull(skb, hdr);
 	if (hlen < 0)
 		return -EINVAL;
 
 	skb->mac_len = hlen;
 
-	pr_debug("fc: %04x dsn: %02x\n", le16_to_cpup((__le16 *)&hdr.fc),
-		 hdr.seq);
+	pr_debug("fc: %04x dsn: %02x\n", le16_to_cpup((__le16 *)&hdr->fc),
+		 hdr->seq);
 
-	cb->type = hdr.fc.type;
-	cb->ackreq = hdr.fc.ack_request;
-	cb->secen = hdr.fc.security_enabled;
+	cb->type = hdr->fc.type;
+	cb->ackreq = hdr->fc.ack_request;
+	cb->secen = hdr->fc.security_enabled;
 
-	mac802154_print_addr("destination", &hdr.dest);
-	mac802154_print_addr("source", &hdr.source);
+	mac802154_print_addr("destination", &hdr->dest);
+	mac802154_print_addr("source", &hdr->source);
 
-	cb->source = hdr.source;
-	cb->dest = hdr.dest;
+	cb->source = hdr->source;
+	cb->dest = hdr->dest;
 
-	if (hdr.fc.security_enabled) {
+	if (hdr->fc.security_enabled) {
 		u64 key;
 
-		pr_debug("seclevel %i\n", hdr.sec.level);
+		pr_debug("seclevel %i\n", hdr->sec.level);
 
-		switch (hdr.sec.key_id_mode) {
+		switch (hdr->sec.key_id_mode) {
 		case IEEE802154_SCF_KEY_IMPLICIT:
 			pr_debug("implicit key\n");
 			break;
 
 		case IEEE802154_SCF_KEY_INDEX:
-			pr_debug("key %02x\n", hdr.sec.key_id);
+			pr_debug("key %02x\n", hdr->sec.key_id);
 			break;
 
 		case IEEE802154_SCF_KEY_SHORT_INDEX:
 			pr_debug("key %04x:%04x %02x\n",
-				 le32_to_cpu(hdr.sec.short_src) >> 16,
-				 le32_to_cpu(hdr.sec.short_src) & 0xffff,
-				 hdr.sec.key_id);
+				 le32_to_cpu(hdr->sec.short_src) >> 16,
+				 le32_to_cpu(hdr->sec.short_src) & 0xffff,
+				 hdr->sec.key_id);
 			break;
 
 		case IEEE802154_SCF_KEY_HW_INDEX:
-			key = swab64((__force u64) hdr.sec.extended_src);
+			key = swab64((__force u64) hdr->sec.extended_src);
 			pr_debug("key source %8phC %02x\n", &key,
-				 hdr.sec.key_id);
+				 hdr->sec.key_id);
 			break;
 		}
-
-		return -EINVAL;
 	}
 
 	return 0;
@@ -485,8 +546,9 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 	int ret;
 	struct sk_buff *sskb;
 	struct mac802154_sub_if_data *sdata;
+	struct ieee802154_hdr hdr;
 
-	ret = mac802154_parse_frame_start(skb);
+	ret = mac802154_parse_frame_start(skb, &hdr);
 	if (ret) {
 		pr_debug("got invalid frame\n");
 		return;
@@ -499,7 +561,7 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 
 		sskb = skb_clone(skb, GFP_ATOMIC);
 		if (sskb)
-			mac802154_subif_frame(sdata, sskb);
+			mac802154_subif_frame(sdata, sskb, &hdr);
 	}
 	rcu_read_unlock();
 }
-- 
1.7.9.5
