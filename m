From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v3 2/4] mac802154: use new
	header ops in wpan devices
Date: Mon,  3 Mar 2014 23:07:53 +0100
Message-ID: <1393884475-20927-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1393884475-20927-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393884475-20927-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace the old header creation/parsing with the new header operations.
This reduces code duplication that existed between
mac802154_parse_frame_start and mac802154_header_parse. This also fixes
a bug that caused 802.15.4 frames with link layer security enabled to be
misparsed, leading to parts of the header being passed to upper layers
as data.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Tested-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ieee802154_netdev.h |   6 -
 net/mac802154/wpan.c            | 318 ++++++++++------------------------------
 2 files changed, 80 insertions(+), 244 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index c18a4f0..b24d3cb 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -100,7 +100,6 @@ static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
 
 #define MAC_CB_FLAG_ACKREQ		(1 << 3)
 #define MAC_CB_FLAG_SECEN		(1 << 4)
-#define MAC_CB_FLAG_INTRAPAN		(1 << 5)
 
 static inline int mac_cb_is_ackreq(struct sk_buff *skb)
 {
@@ -112,11 +111,6 @@ static inline int mac_cb_is_secen(struct sk_buff *skb)
 	return mac_cb(skb)->flags & MAC_CB_FLAG_SECEN;
 }
 
-static inline int mac_cb_is_intrapan(struct sk_buff *skb)
-{
-	return mac_cb(skb)->flags & MAC_CB_FLAG_INTRAPAN;
-}
-
 static inline int mac_cb_type(struct sk_buff *skb)
 {
 	return mac_cb(skb)->flags & MAC_CB_FLAG_TYPEMASK;
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 372d8a2..ffadb2c 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -35,35 +35,6 @@
 
 #include "mac802154.h"
 
-static inline int mac802154_fetch_skb_u8(struct sk_buff *skb, u8 *val)
-{
-	if (unlikely(!pskb_may_pull(skb, 1)))
-		return -EINVAL;
-
-	*val = skb->data[0];
-	skb_pull(skb, 1);
-
-	return 0;
-}
-
-static inline int mac802154_fetch_skb_u16(struct sk_buff *skb, u16 *val)
-{
-	if (unlikely(!pskb_may_pull(skb, 2)))
-		return -EINVAL;
-
-	*val = skb->data[0] | (skb->data[1] << 8);
-	skb_pull(skb, 2);
-
-	return 0;
-}
-
-static inline void mac802154_haddr_copy_swap(u8 *dest, const u8 *src)
-{
-	int i;
-	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
-		dest[IEEE802154_ADDR_LEN - i - 1] = src[i];
-}
-
 static int
 mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -128,25 +99,23 @@ static int mac802154_wpan_mac_addr(struct net_device *dev, void *p)
 static int mac802154_header_create(struct sk_buff *skb,
 				   struct net_device *dev,
 				   unsigned short type,
-				   const void *_daddr,
-				   const void *_saddr,
+				   const void *daddr,
+				   const void *saddr,
 				   unsigned len)
 {
-	const struct ieee802154_addr *saddr = _saddr;
-	const struct ieee802154_addr *daddr = _daddr;
-	struct ieee802154_addr dev_addr;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-	int pos = 2;
-	u8 head[MAC802154_FRAME_HARD_HEADER_LEN];
-	u16 fc;
+	struct ieee802154_hdr hdr;
+	int hlen;
 
 	if (!daddr)
 		return -EINVAL;
 
-	head[pos++] = mac_cb(skb)->seq; /* DSN/BSN */
-	fc = mac_cb_type(skb);
+	hdr.fc = mac_cb_type(skb);
+	hdr.seq = mac_cb(skb)->seq;
 	if (mac_cb_is_ackreq(skb))
-		fc |= IEEE802154_FC_ACK_REQ;
+		hdr.fc |= IEEE802154_FC_ACK_REQ;
+	if (mac_cb_is_secen(skb))
+		hdr.fc |= IEEE802154_FC_SECEN;
 
 	if (!saddr) {
 		spin_lock_bh(&priv->mib_lock);
@@ -154,161 +123,46 @@ static int mac802154_header_create(struct sk_buff *skb,
 		if (priv->short_addr == IEEE802154_ADDR_BROADCAST ||
 		    priv->short_addr == IEEE802154_ADDR_UNDEF ||
 		    priv->pan_id == IEEE802154_PANID_BROADCAST) {
-			dev_addr.addr_type = IEEE802154_ADDR_LONG;
-			memcpy(dev_addr.hwaddr, dev->dev_addr,
+			hdr.source.addr_type = IEEE802154_ADDR_LONG;
+			memcpy(hdr.source.hwaddr, dev->dev_addr,
 			       IEEE802154_ADDR_LEN);
 		} else {
-			dev_addr.addr_type = IEEE802154_ADDR_SHORT;
-			dev_addr.short_addr = priv->short_addr;
+			hdr.source.addr_type = IEEE802154_ADDR_SHORT;
+			hdr.source.short_addr = priv->short_addr;
 		}
 
-		dev_addr.pan_id = priv->pan_id;
-		saddr = &dev_addr;
+		hdr.source.pan_id = priv->pan_id;
 
 		spin_unlock_bh(&priv->mib_lock);
+	} else {
+		hdr.source = *(const struct ieee802154_addr *) saddr;
 	}
 
-	if (daddr->addr_type != IEEE802154_ADDR_NONE) {
-		fc |= (daddr->addr_type << IEEE802154_FC_DAMODE_SHIFT);
-
-		head[pos++] = daddr->pan_id & 0xff;
-		head[pos++] = daddr->pan_id >> 8;
-
-		if (daddr->addr_type == IEEE802154_ADDR_SHORT) {
-			head[pos++] = daddr->short_addr & 0xff;
-			head[pos++] = daddr->short_addr >> 8;
-		} else {
-			mac802154_haddr_copy_swap(head + pos, daddr->hwaddr);
-			pos += IEEE802154_ADDR_LEN;
-		}
-	}
-
-	if (saddr->addr_type != IEEE802154_ADDR_NONE) {
-		fc |= (saddr->addr_type << IEEE802154_FC_SAMODE_SHIFT);
-
-		if ((saddr->pan_id == daddr->pan_id) &&
-		    (saddr->pan_id != IEEE802154_PANID_BROADCAST)) {
-			/* PANID compression/intra PAN */
-			fc |= IEEE802154_FC_INTRA_PAN;
-		} else {
-			head[pos++] = saddr->pan_id & 0xff;
-			head[pos++] = saddr->pan_id >> 8;
-		}
+	hdr.dest = *(const struct ieee802154_addr *) daddr;
 
-		if (saddr->addr_type == IEEE802154_ADDR_SHORT) {
-			head[pos++] = saddr->short_addr & 0xff;
-			head[pos++] = saddr->short_addr >> 8;
-		} else {
-			mac802154_haddr_copy_swap(head + pos, saddr->hwaddr);
-			pos += IEEE802154_ADDR_LEN;
-		}
-	}
-
-	head[0] = fc;
-	head[1] = fc >> 8;
+	hlen = ieee802154_hdr_push(skb, &hdr);
+	if (hlen < 0)
+		return -EINVAL;
 
-	memcpy(skb_push(skb, pos), head, pos);
 	skb_reset_mac_header(skb);
-	skb->mac_len = pos;
+	skb->mac_len = hlen;
 
-	return pos;
+	return hlen;
 }
 
 static int
 mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
-	const u8 *hdr = skb_mac_header(skb);
-	const u8 *tail = skb_tail_pointer(skb);
+	struct ieee802154_hdr hdr;
 	struct ieee802154_addr *addr = (struct ieee802154_addr *)haddr;
-	u16 fc;
-	int da_type;
-
-	if (hdr + 3 > tail)
-		goto malformed;
-
-	fc = hdr[0] | (hdr[1] << 8);
-
-	hdr += 3;
-
-	da_type = IEEE802154_FC_DAMODE(fc);
-	addr->addr_type = IEEE802154_FC_SAMODE(fc);
-
-	switch (da_type) {
-	case IEEE802154_ADDR_NONE:
-		if (fc & IEEE802154_FC_INTRA_PAN)
-			goto malformed;
-		break;
-	case IEEE802154_ADDR_LONG:
-		if (fc & IEEE802154_FC_INTRA_PAN) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + IEEE802154_ADDR_LEN > tail)
-			goto malformed;
-
-		hdr += IEEE802154_ADDR_LEN;
-		break;
-	case IEEE802154_ADDR_SHORT:
-		if (fc & IEEE802154_FC_INTRA_PAN) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + 2 > tail)
-			goto malformed;
-
-		hdr += 2;
-		break;
-	default:
-		goto malformed;
-
-	}
-
-	switch (addr->addr_type) {
-	case IEEE802154_ADDR_NONE:
-		break;
-	case IEEE802154_ADDR_LONG:
-		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + IEEE802154_ADDR_LEN > tail)
-			goto malformed;
-
-		mac802154_haddr_copy_swap(addr->hwaddr, hdr);
-		hdr += IEEE802154_ADDR_LEN;
-		break;
-	case IEEE802154_ADDR_SHORT:
-		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
 
-		if (hdr + 2 > tail)
-			goto malformed;
-
-		addr->short_addr = hdr[0] | (hdr[1] << 8);
-		hdr += 2;
-		break;
-	default:
-		goto malformed;
+	if (ieee802154_hdr_peek_addrs(skb, &hdr) < 0) {
+		pr_debug("malformed packet\n");
+		return 0;
 	}
 
-	return sizeof(struct ieee802154_addr);
-
-malformed:
-	pr_debug("malformed packet\n");
-	return 0;
+	*addr = hdr.source;
+	return sizeof(*addr);
 }
 
 static netdev_tx_t
@@ -451,88 +305,76 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 	}
 }
 
-static int mac802154_parse_frame_start(struct sk_buff *skb)
+static void mac802154_print_addr(const char *name,
+				 const struct ieee802154_addr *addr)
 {
-	u8 *head = skb->data;
-	u16 fc;
-
-	if (mac802154_fetch_skb_u16(skb, &fc) ||
-	    mac802154_fetch_skb_u8(skb, &(mac_cb(skb)->seq)))
-		goto err;
-
-	pr_debug("fc: %04x dsn: %02x\n", fc, head[2]);
-
-	mac_cb(skb)->flags = IEEE802154_FC_TYPE(fc);
-	mac_cb(skb)->sa.addr_type = IEEE802154_FC_SAMODE(fc);
-	mac_cb(skb)->da.addr_type = IEEE802154_FC_DAMODE(fc);
-
-	if (fc & IEEE802154_FC_INTRA_PAN)
-		mac_cb(skb)->flags |= MAC_CB_FLAG_INTRAPAN;
-
-	if (mac_cb(skb)->da.addr_type != IEEE802154_ADDR_NONE) {
-		if (mac802154_fetch_skb_u16(skb, &(mac_cb(skb)->da.pan_id)))
-			goto err;
-
-		/* source PAN id compression */
-		if (mac_cb_is_intrapan(skb))
-			mac_cb(skb)->sa.pan_id = mac_cb(skb)->da.pan_id;
-
-		pr_debug("dest PAN addr: %04x\n", mac_cb(skb)->da.pan_id);
+	if (addr->addr_type == IEEE802154_ADDR_NONE)
+		pr_debug("%s not present\n", name);
+
+	pr_debug("%s PAN ID: %04x\n", name, addr->pan_id);
+	if (addr->addr_type == IEEE802154_ADDR_SHORT) {
+		pr_debug("%s is short: %04x\n", name, addr->short_addr);
+	} else {
+		pr_debug("%s is hardware: %02x %02x %02x %02x %02x %02x %02x %02x\n",
+			 name, addr->hwaddr[0], addr->hwaddr[1],
+			 addr->hwaddr[2], addr->hwaddr[3], addr->hwaddr[4],
+			 addr->hwaddr[5], addr->hwaddr[6], addr->hwaddr[7]);
+	}
+}
 
-		if (mac_cb(skb)->da.addr_type == IEEE802154_ADDR_SHORT) {
-			u16 *da = &(mac_cb(skb)->da.short_addr);
+static int mac802154_parse_frame_start(struct sk_buff *skb)
+{
+	struct ieee802154_hdr hdr;
+	int hlen;
 
-			if (mac802154_fetch_skb_u16(skb, da))
-				goto err;
+	hlen = ieee802154_hdr_pull(skb, hdr);
+	if (hlen < 0)
+		return -EINVAL;
 
-			pr_debug("destination address is short: %04x\n",
-				 mac_cb(skb)->da.short_addr);
-		} else {
-			if (!pskb_may_pull(skb, IEEE802154_ADDR_LEN))
-				goto err;
+	skb->mac_len = hlen;
 
-			mac802154_haddr_copy_swap(mac_cb(skb)->da.hwaddr,
-						  skb->data);
-			skb_pull(skb, IEEE802154_ADDR_LEN);
+	pr_debug("fc: %04x dsn: %02x\n", hdr->fc, hdr->seq);
 
-			pr_debug("destination address is hardware\n");
-		}
-	}
+	mac_cb(skb)->flags = IEEE802154_FC_TYPE(hdr.fc);
+	mac_cb(skb)->sa = hdr.source;
+	mac_cb(skb)->da = hdr.dest;
 
-	if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE) {
-		/* non PAN-compression, fetch source address id */
-		if (!(mac_cb_is_intrapan(skb))) {
-			u16 *sa_pan = &(mac_cb(skb)->sa.pan_id);
+	if (hdr.fc & IEEE802154_FC_SECEN)
+		mac_cb(skb)->flags |= MAC_CB_FLAG_SECEN;
 
-			if (mac802154_fetch_skb_u16(skb, sa_pan))
-				goto err;
-		}
+	mac802154_print_addr("destination", &hdr.dest);
+	mac802154_print_addr("source", &hdr.source);
 
-		pr_debug("source PAN addr: %04x\n", mac_cb(skb)->da.pan_id);
+	if (hdr.fc & IEEE802154_FC_SECEN) {
+		const u8 *key;
 
-		if (mac_cb(skb)->sa.addr_type == IEEE802154_ADDR_SHORT) {
-			u16 *sa = &(mac_cb(skb)->sa.short_addr);
+		pr_debug("sc %02x\n", hdr.sec.sc);
 
-			if (mac802154_fetch_skb_u16(skb, sa))
-				goto err;
+		switch (IEEE802154_SCF_KEY_ID_MODE(hdr.sec.sc)) {
+		case IEEE802154_SCF_KEY_IMPLICIT:
+			pr_debug("implicit key\n");
+			break;
 
-			pr_debug("source address is short: %04x\n",
-				 mac_cb(skb)->sa.short_addr);
-		} else {
-			if (!pskb_may_pull(skb, IEEE802154_ADDR_LEN))
-				goto err;
+		case IEEE802154_SCF_KEY_INDEX:
+			break;
 
-			mac802154_haddr_copy_swap(mac_cb(skb)->sa.hwaddr,
-						  skb->data);
-			skb_pull(skb, IEEE802154_ADDR_LEN);
+		case IEEE802154_SCF_KEY_SHORT_INDEX:
+			pr_debug("key %04x:%04x %02x\n",
+				 hdr.sec.key_source.pan.pan_id,
+				 hdr.sec.key_source.pan.short_addr,
+				 hdr.sec.key_id);
+			break;
 
-			pr_debug("source address is hardware\n");
+		case IEEE802154_SCF_KEY_HW_INDEX:
+			key = hdr.sec.key_source.hw;
+			pr_debug("key source %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x %02x\n",
+				 key[0], key[1], key[2], key[3], key[4],
+				 key[5], key[6], key[7], hdr.sec.key_id);
+			break;
 		}
 	}
 
 	return 0;
-err:
-	return -EINVAL;
 }
 
 void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
-- 
1.9.0


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
