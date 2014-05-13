From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 3/5] ieee802154: change _cb
	handling slightly
Date: Tue, 13 May 2014 19:24:04 +0200
Message-ID: <1400001846-5349-4-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400001846-5349-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The current mac_cb handling of ieee802154 is rather awkward and limited.
Decompose the single flags fields into multiple fields with the meanings
of each subfield of the flags field to make future extensions (for
example, link-layer security) easier. Also don't set the frame sequence
number in upper layers, since that's a thing the MAC is supposed to set
on frame transmit.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/ieee802154_netdev.h |   25 +++++++------------------
 net/ieee802154/6lowpan_rtnl.c   |    9 ++++-----
 net/ieee802154/dgram.c          |   10 ++++------
 net/mac802154/rx.c              |    2 --
 net/mac802154/wpan.c            |   26 +++++++++++++-------------
 5 files changed, 28 insertions(+), 44 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 6e4d3e1..ee5e9a1 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -222,8 +222,9 @@ static inline void ieee802154_addr_to_sa(struct ieee802154_addr_sa *sa,
  */
 struct ieee802154_mac_cb {
 	u8 lqi;
-	u8 flags;
-	u8 seq;
+	u8 type;
+	bool ackreq;
+	bool secen;
 	struct ieee802154_addr source;
 	struct ieee802154_addr dest;
 };
@@ -233,24 +234,12 @@ static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
 	return (struct ieee802154_mac_cb *)skb->cb;
 }
 
-#define MAC_CB_FLAG_TYPEMASK		((1 << 3) - 1)
-
-#define MAC_CB_FLAG_ACKREQ		(1 << 3)
-#define MAC_CB_FLAG_SECEN		(1 << 4)
-
-static inline bool mac_cb_is_ackreq(struct sk_buff *skb)
-{
-	return mac_cb(skb)->flags & MAC_CB_FLAG_ACKREQ;
-}
-
-static inline bool mac_cb_is_secen(struct sk_buff *skb)
+static inline struct ieee802154_mac_cb *mac_cb_alloc(struct sk_buff *skb)
 {
-	return mac_cb(skb)->flags & MAC_CB_FLAG_SECEN;
-}
+	BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
 
-static inline int mac_cb_type(struct sk_buff *skb)
-{
-	return mac_cb(skb)->flags & MAC_CB_FLAG_TYPEMASK;
+	memset(skb->cb, 0, sizeof(struct ieee802154_mac_cb));
+	return mac_cb(skb);
 }
 
 #define IEEE802154_MAC_SCAN_ED		0
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 3e11b46..a830b2e 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -92,6 +92,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 	const u8 *saddr = _saddr;
 	const u8 *daddr = _daddr;
 	struct ieee802154_addr sa, da;
+	struct ieee802154_mac_cb *cb = mac_cb_alloc(skb);
 
 	/* TODO:
 	 * if this package isn't ipv6 one, where should it be routed?
@@ -115,8 +116,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 	 * from MAC subif of the 'dev' and 'real_dev' network devices, but
 	 * this isn't implemented in mainline yet, so currently we assign 0xff
 	 */
-	mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
-	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
+	cb->type = IEEE802154_FC_TYPE_DATA;
 
 	/* prepare wpan address data */
 	sa.mode = IEEE802154_ADDR_LONG;
@@ -135,11 +135,10 @@ static int lowpan_header_create(struct sk_buff *skb,
 	} else {
 		da.mode = IEEE802154_ADDR_LONG;
 		da.extended_addr = ieee802154_devaddr_from_raw(daddr);
-
-		/* request acknowledgment */
-		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
 	}
 
+	cb->ackreq = !lowpan_is_addr_broadcast(daddr);
+
 	return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
 			type, (void *)&da, (void *)&sa, 0);
 }
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 786437b..2fefe12 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -209,6 +209,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct net_device *dev;
 	unsigned int mtu;
 	struct sk_buff *skb;
+	struct ieee802154_mac_cb *cb;
 	struct dgram_sock *ro = dgram_sk(sk);
 	int hlen, tlen;
 	int err;
@@ -249,18 +250,15 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	skb_reset_network_header(skb);
 
-	mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
-	if (ro->want_ack)
-		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+	cb = mac_cb_alloc(skb);
+	cb->type = IEEE802154_FC_TYPE_DATA;
+	cb->ackreq = ro->want_ack;
 
-	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr,
 			ro->bound ? &ro->src_addr : NULL, size);
 	if (err < 0)
 		goto out_skb;
 
-	skb_reset_mac_header(skb);
-
 	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 	if (err < 0)
 		goto out_skb;
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index 03855b0..0597b96 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -59,8 +59,6 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
 	skb->protocol = htons(ETH_P_IEEE802154);
 	skb_reset_mac_header(skb);
 
-	BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
-
 	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
 		u16 crc;
 
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 1df7a6a..1477ee9 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -192,15 +192,17 @@ static int mac802154_header_create(struct sk_buff *skb,
 {
 	struct ieee802154_hdr hdr;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct ieee802154_mac_cb *cb = mac_cb(skb);
 	int hlen;
 
 	if (!daddr)
 		return -EINVAL;
 
 	memset(&hdr.fc, 0, sizeof(hdr.fc));
-	hdr.fc.type = mac_cb_type(skb);
-	hdr.fc.security_enabled = mac_cb_is_secen(skb);
-	hdr.fc.ack_request = mac_cb_is_ackreq(skb);
+	hdr.fc.type = cb->type;
+	hdr.fc.security_enabled = cb->secen;
+	hdr.fc.ack_request = cb->ackreq;
+	hdr.seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 
 	if (!saddr) {
 		spin_lock_bh(&priv->mib_lock);
@@ -391,12 +393,12 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 	sdata->dev->stats.rx_packets++;
 	sdata->dev->stats.rx_bytes += skb->len;
 
-	switch (mac_cb_type(skb)) {
+	switch (mac_cb(skb)->type) {
 	case IEEE802154_FC_TYPE_DATA:
 		return mac802154_process_data(sdata->dev, skb);
 	default:
 		pr_warn("ieee802154: bad frame received (type = %d)\n",
-			mac_cb_type(skb));
+			mac_cb(skb)->type);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
@@ -423,6 +425,7 @@ static int mac802154_parse_frame_start(struct sk_buff *skb)
 {
 	int hlen;
 	struct ieee802154_hdr hdr;
+	struct ieee802154_mac_cb *cb = mac_cb_alloc(skb);
 
 	hlen = ieee802154_hdr_pull(skb, &hdr);
 	if (hlen < 0)
@@ -433,18 +436,15 @@ static int mac802154_parse_frame_start(struct sk_buff *skb)
 	pr_debug("fc: %04x dsn: %02x\n", le16_to_cpup((__le16 *)&hdr.fc),
 		 hdr.seq);
 
-	mac_cb(skb)->flags = hdr.fc.type;
-
-	if (hdr.fc.ack_request)
-		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
-	if (hdr.fc.security_enabled)
-		mac_cb(skb)->flags |= MAC_CB_FLAG_SECEN;
+	cb->type = hdr.fc.type;
+	cb->ackreq = hdr.fc.ack_request;
+	cb->secen = hdr.fc.security_enabled;
 
 	mac802154_print_addr("destination", &hdr.dest);
 	mac802154_print_addr("source", &hdr.source);
 
-	mac_cb(skb)->source = hdr.source;
-	mac_cb(skb)->dest = hdr.dest;
+	cb->source = hdr.source;
+	cb->dest = hdr.dest;
 
 	if (hdr.fc.security_enabled) {
 		u64 key;
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
