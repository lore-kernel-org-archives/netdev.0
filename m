From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v2 6/8] ieee802154: use
	ieee802154_addr instead of *_sa variants
Date: Fri, 14 Mar 2014 21:24:02 +0100
Message-ID: <1394828644-19898-7-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394828644-19898-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Change all internal uses of ieee802154_addr_sa to ieee802154_addr,
except for those instances that communicate directly with userspace.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 drivers/net/ieee802154/fakehard.c |   8 +--
 include/net/ieee802154_netdev.h   |  12 ++--
 include/net/nl802154.h            |   6 +-
 net/ieee802154/6lowpan_rtnl.c     |  38 +++++++++----
 net/ieee802154/dgram.c            |   2 +-
 net/ieee802154/nl-mac.c           | 114 ++++++++++++++++++++++----------------
 net/ieee802154/reassembly.c       |  17 ++++--
 net/ieee802154/reassembly.h       |  42 +++-----------
 net/mac802154/mac_cmd.c           |   8 +--
 net/mac802154/wpan.c              |  35 ++++++------
 10 files changed, 146 insertions(+), 136 deletions(-)

diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 3c98030..78f18be 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -119,7 +119,7 @@ static u8 fake_get_dsn(const struct net_device *dev)
  *       802.15.4-2006 document.
  */
 static int fake_assoc_req(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u8 channel, u8 page, u8 cap)
+		struct ieee802154_addr *addr, u8 channel, u8 page, u8 cap)
 {
 	struct wpan_phy *phy = fake_to_phy(dev);
 
@@ -149,7 +149,7 @@ static int fake_assoc_req(struct net_device *dev,
  *       802.15.4-2006 document.
  */
 static int fake_assoc_resp(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, __le16 short_addr, u8 status)
+		struct ieee802154_addr *addr, __le16 short_addr, u8 status)
 {
 	return 0;
 }
@@ -167,7 +167,7 @@ static int fake_assoc_resp(struct net_device *dev,
  *       document, with the reason described in 7.3.3.2.
  */
 static int fake_disassoc_req(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u8 reason)
+		struct ieee802154_addr *addr, u8 reason)
 {
 	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
 }
@@ -192,7 +192,7 @@ static int fake_disassoc_req(struct net_device *dev,
  * document, with 7.3.8 describing coordinator realignment.
  */
 static int fake_start_req(struct net_device *dev,
-			  struct ieee802154_addr_sa *addr, u8 channel, u8 page,
+			  struct ieee802154_addr *addr, u8 channel, u8 page,
 			  u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
 			  u8 coord_realign)
 {
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 8e7f690..827e3e3 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -200,11 +200,11 @@ struct ieee802154_frag_info {
  */
 struct ieee802154_mac_cb {
 	u8 lqi;
-	struct ieee802154_addr_sa sa;
-	struct ieee802154_addr_sa da;
 	u8 flags;
 	u8 seq;
 	struct ieee802154_frag_info frag_info;
+	struct ieee802154_addr source;
+	struct ieee802154_addr dest;
 };
 
 static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
@@ -248,16 +248,16 @@ struct ieee802154_mlme_ops {
 	/* The following fields are optional (can be NULL). */
 
 	int (*assoc_req)(struct net_device *dev,
-			struct ieee802154_addr_sa *addr,
+			struct ieee802154_addr *addr,
 			u8 channel, u8 page, u8 cap);
 	int (*assoc_resp)(struct net_device *dev,
-			struct ieee802154_addr_sa *addr,
+			struct ieee802154_addr *addr,
 			__le16 short_addr, u8 status);
 	int (*disassoc_req)(struct net_device *dev,
-			struct ieee802154_addr_sa *addr,
+			struct ieee802154_addr *addr,
 			u8 reason);
 	int (*start_req)(struct net_device *dev,
-			struct ieee802154_addr_sa *addr,
+			struct ieee802154_addr *addr,
 			u8 channel, u8 page, u8 bcn_ord, u8 sf_ord,
 			u8 pan_coord, u8 blx, u8 coord_realign);
 	int (*scan_req)(struct net_device *dev,
diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index 3121ed0..b23548e 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -22,7 +22,7 @@
 #define IEEE802154_NL_H
 
 struct net_device;
-struct ieee802154_addr_sa;
+struct ieee802154_addr;
 
 /**
  * ieee802154_nl_assoc_indic - Notify userland of an association request.
@@ -37,7 +37,7 @@ struct ieee802154_addr_sa;
  * Note: This is in section 7.3.1 of the IEEE 802.15.4-2006 document.
  */
 int ieee802154_nl_assoc_indic(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u8 cap);
+		struct ieee802154_addr *addr, u8 cap);
 
 /**
  * ieee802154_nl_assoc_confirm - Notify userland of association.
@@ -65,7 +65,7 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev,
  * Note: This is in section 7.3.3 of the IEEE 802.15.4 document.
  */
 int ieee802154_nl_disassoc_indic(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u8 reason);
+		struct ieee802154_addr *addr, u8 reason);
 
 /**
  * ieee802154_nl_disassoc_confirm - Notify userland of disassociation
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 678564c..d4edd20 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -168,10 +168,11 @@ static int lowpan_give_skb_to_devices(struct sk_buff *skb,
 	return stat;
 }
 
-static int process_data(struct sk_buff *skb)
+static int process_data(struct sk_buff *skb, const struct ieee802154_hdr *hdr)
 {
 	u8 iphc0, iphc1;
-	const struct ieee802154_addr_sa *_saddr, *_daddr;
+	struct ieee802154_addr_sa sa, da;
+	void *sap, *dap;
 
 	raw_dump_table(__func__, "raw skb data dump", skb->data, skb->len);
 	/* at least two bytes will be used for the encoding */
@@ -184,14 +185,23 @@ static int process_data(struct sk_buff *skb)
 	if (lowpan_fetch_skb_u8(skb, &iphc1))
 		goto drop;
 
-	_saddr = &mac_cb(skb)->sa;
-	_daddr = &mac_cb(skb)->da;
+	ieee802154_addr_to_sa(&sa, &hdr->source);
+	ieee802154_addr_to_sa(&da, &hdr->dest);
 
-	return lowpan_process_data(skb, skb->dev, (u8 *)_saddr->hwaddr,
-				_saddr->addr_type, IEEE802154_ADDR_LEN,
-				(u8 *)_daddr->hwaddr, _daddr->addr_type,
-				IEEE802154_ADDR_LEN, iphc0, iphc1,
-				lowpan_give_skb_to_devices);
+	if (sa.addr_type == IEEE802154_ADDR_SHORT)
+		sap = &sa.short_addr;
+	else
+		sap = &sa.hwaddr;
+
+	if (da.addr_type == IEEE802154_ADDR_SHORT)
+		dap = &da.short_addr;
+	else
+		dap = &da.hwaddr;
+
+	return lowpan_process_data(skb, skb->dev, sap, sa.addr_type,
+				   IEEE802154_ADDR_LEN, dap, da.addr_type,
+				   IEEE802154_ADDR_LEN, iphc0, iphc1,
+				   lowpan_give_skb_to_devices);
 
 drop:
 	kfree_skb(skb);
@@ -438,6 +448,7 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct sk_buff *local_skb;
+	struct ieee802154_hdr hdr;
 	int ret;
 
 	if (!netif_running(dev))
@@ -446,6 +457,9 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (dev->type != ARPHRD_IEEE802154)
 		goto drop_skb;
 
+	if (ieee802154_hdr_peek_addrs(skb, &hdr) < 0)
+		goto drop_skb;
+
 	local_skb = skb_clone(skb, GFP_ATOMIC);
 	if (!local_skb)
 		goto drop_skb;
@@ -466,14 +480,14 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		switch (skb->data[0] & 0xe0) {
 		case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
-			ret = process_data(local_skb);
+			ret = process_data(local_skb, &hdr);
 			if (ret == NET_RX_DROP)
 				goto drop;
 			break;
 		case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
 			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAG1);
 			if (ret == 1) {
-				ret = process_data(local_skb);
+				ret = process_data(local_skb, &hdr);
 				if (ret == NET_RX_DROP)
 					goto drop;
 			}
@@ -481,7 +495,7 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 		case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
 			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAGN);
 			if (ret == 1) {
-				ret = process_data(local_skb);
+				ret = process_data(local_skb, &hdr);
 				if (ret == NET_RX_DROP)
 					goto drop;
 			}
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 0a926c6..55f2dc4 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -313,7 +313,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 	if (saddr) {
 		saddr->family = AF_IEEE802154;
-		saddr->addr = mac_cb(skb)->sa;
+		ieee802154_addr_to_sa(&saddr->addr, &mac_cb(skb)->source);
 		*addr_len = sizeof(*saddr);
 	}
 
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 58fa523..bda8dba 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -39,14 +39,34 @@
 
 #include "ieee802154.h"
 
+static int nla_put_hwaddr(struct sk_buff *msg, int type, __le64 hwaddr)
+{
+	return nla_put_u64(msg, type, swab64((__force u64)hwaddr));
+}
+
+static __le64 nla_get_hwaddr(const struct nlattr *nla)
+{
+	return ieee802154_devaddr_from_raw(nla_data(nla));
+}
+
+static int nla_put_shortaddr(struct sk_buff *msg, int type, __le16 addr)
+{
+	return nla_put_u16(msg, type, le16_to_cpu(addr));
+}
+
+static __le16 nla_get_shortaddr(const struct nlattr *nla)
+{
+	return cpu_to_le16(nla_get_u16(nla));
+}
+
 int ieee802154_nl_assoc_indic(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u8 cap)
+		struct ieee802154_addr *addr, u8 cap)
 {
 	struct sk_buff *msg;
 
 	pr_debug("%s\n", __func__);
 
-	if (addr->addr_type != IEEE802154_ADDR_LONG) {
+	if (addr->mode != IEEE802154_ADDR_LONG) {
 		pr_err("%s: received non-long source address!\n", __func__);
 		return -EINVAL;
 	}
@@ -59,8 +79,8 @@ int ieee802154_nl_assoc_indic(struct net_device *dev,
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
-		    addr->hwaddr) ||
+	    nla_put_hwaddr(msg, IEEE802154_ATTR_SRC_HW_ADDR,
+			   addr->extended_addr) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_CAPABILITY, cap))
 		goto nla_put_failure;
 
@@ -87,8 +107,7 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev, __le16 short_addr,
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR,
-			le16_to_cpu(short_addr)) ||
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
 		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
@@ -100,7 +119,7 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_assoc_confirm);
 
 int ieee802154_nl_disassoc_indic(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u8 reason)
+		struct ieee802154_addr *addr, u8 reason)
 {
 	struct sk_buff *msg;
 
@@ -115,13 +134,13 @@ int ieee802154_nl_disassoc_indic(struct net_device *dev,
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr))
 		goto nla_put_failure;
-	if (addr->addr_type == IEEE802154_ADDR_LONG) {
-		if (nla_put(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
-			    addr->hwaddr))
+	if (addr->mode == IEEE802154_ADDR_LONG) {
+		if (nla_put_hwaddr(msg, IEEE802154_ATTR_SRC_HW_ADDR,
+				   addr->extended_addr))
 			goto nla_put_failure;
 	} else {
-		if (nla_put_u16(msg, IEEE802154_ATTR_SRC_SHORT_ADDR,
-				addr->short_addr))
+		if (nla_put_shortaddr(msg, IEEE802154_ATTR_SRC_SHORT_ADDR,
+				      addr->short_addr))
 			goto nla_put_failure;
 	}
 	if (nla_put_u8(msg, IEEE802154_ATTR_REASON, reason))
@@ -173,10 +192,9 @@ int ieee802154_nl_beacon_indic(struct net_device *dev, __le16 panid,
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR,
-			le16_to_cpu(coord_addr)) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_COORD_PAN_ID,
-			le16_to_cpu(panid)))
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_COORD_SHORT_ADDR,
+			      coord_addr) ||
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_COORD_PAN_ID, panid))
 		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
@@ -246,7 +264,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 {
 	void *hdr;
 	struct wpan_phy *phy;
-	u16 short_addr, pan_id;
+	__le16 short_addr, pan_id;
 
 	pr_debug("%s\n", __func__);
 
@@ -258,16 +276,16 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
 	BUG_ON(!phy);
 
-	short_addr = le16_to_cpu(ieee802154_mlme_ops(dev)->get_short_addr(dev));
-	pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	short_addr = ieee802154_mlme_ops(dev)->get_short_addr(dev);
+	pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
 
 	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
 	    nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_PAN_ID, pan_id))
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
+	    nla_put_shortaddr(msg, IEEE802154_ATTR_PAN_ID, pan_id))
 		goto nla_put_failure;
 	wpan_phy_put(phy);
 	return genlmsg_end(msg, hdr);
@@ -309,7 +327,7 @@ static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr_sa addr;
+	struct ieee802154_addr addr;
 	u8 page;
 	int ret = -EOPNOTSUPP;
 
@@ -327,16 +345,16 @@ int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 
 	if (info->attrs[IEEE802154_ATTR_COORD_HW_ADDR]) {
-		addr.addr_type = IEEE802154_ADDR_LONG;
-		nla_memcpy(addr.hwaddr,
-				info->attrs[IEEE802154_ATTR_COORD_HW_ADDR],
-				IEEE802154_ADDR_LEN);
+		addr.mode = IEEE802154_ADDR_LONG;
+		addr.extended_addr = nla_get_hwaddr(
+				info->attrs[IEEE802154_ATTR_COORD_HW_ADDR]);
 	} else {
-		addr.addr_type = IEEE802154_ADDR_SHORT;
-		addr.short_addr = nla_get_u16(
+		addr.mode = IEEE802154_ADDR_SHORT;
+		addr.short_addr = nla_get_shortaddr(
 				info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]);
 	}
-	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
+	addr.pan_id = nla_get_shortaddr(
+			info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
 
 	if (info->attrs[IEEE802154_ATTR_PAGE])
 		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
@@ -356,7 +374,7 @@ out:
 int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr_sa addr;
+	struct ieee802154_addr addr;
 	int ret = -EOPNOTSUPP;
 
 	if (!info->attrs[IEEE802154_ATTR_STATUS] ||
@@ -370,13 +388,13 @@ int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info)
 	if (!ieee802154_mlme_ops(dev)->assoc_resp)
 		goto out;
 
-	addr.addr_type = IEEE802154_ADDR_LONG;
-	nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_DEST_HW_ADDR],
-			IEEE802154_ADDR_LEN);
-	addr.pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	addr.mode = IEEE802154_ADDR_LONG;
+	addr.extended_addr = nla_get_hwaddr(
+			info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]);
+	addr.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
 
 	ret = ieee802154_mlme_ops(dev)->assoc_resp(dev, &addr,
-		cpu_to_le16(nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR])),
+		nla_get_shortaddr(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]),
 		nla_get_u8(info->attrs[IEEE802154_ATTR_STATUS]));
 
 out:
@@ -387,7 +405,7 @@ out:
 int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr_sa addr;
+	struct ieee802154_addr addr;
 	int ret = -EOPNOTSUPP;
 
 	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] &&
@@ -402,16 +420,15 @@ int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 
 	if (info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]) {
-		addr.addr_type = IEEE802154_ADDR_LONG;
-		nla_memcpy(addr.hwaddr,
-				info->attrs[IEEE802154_ATTR_DEST_HW_ADDR],
-				IEEE802154_ADDR_LEN);
+		addr.mode = IEEE802154_ADDR_LONG;
+		addr.extended_addr = nla_get_hwaddr(
+				info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]);
 	} else {
-		addr.addr_type = IEEE802154_ADDR_SHORT;
-		addr.short_addr = nla_get_u16(
+		addr.mode = IEEE802154_ADDR_SHORT;
+		addr.short_addr = nla_get_shortaddr(
 				info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]);
 	}
-	addr.pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	addr.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
 
 	ret = ieee802154_mlme_ops(dev)->disassoc_req(dev, &addr,
 			nla_get_u8(info->attrs[IEEE802154_ATTR_REASON]));
@@ -429,7 +446,7 @@ out:
 int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr_sa addr;
+	struct ieee802154_addr addr;
 
 	u8 channel, bcn_ord, sf_ord;
 	u8 page;
@@ -453,10 +470,11 @@ int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	if (!ieee802154_mlme_ops(dev)->start_req)
 		goto out;
 
-	addr.addr_type = IEEE802154_ADDR_SHORT;
-	addr.short_addr = nla_get_u16(
+	addr.mode = IEEE802154_ADDR_SHORT;
+	addr.short_addr = nla_get_shortaddr(
 			info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]);
-	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
+	addr.pan_id = nla_get_shortaddr(
+			info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
 
 	channel = nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]);
 	bcn_ord = nla_get_u8(info->attrs[IEEE802154_ATTR_BCN_ORD]);
@@ -471,7 +489,7 @@ int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 		page = 0;
 
 
-	if (addr.short_addr == IEEE802154_ADDR_BROADCAST) {
+	if (addr.short_addr == cpu_to_le16(IEEE802154_ADDR_BROADCAST)) {
 		ieee802154_nl_start_confirm(dev, IEEE802154_NO_SHORT_ADDRESS);
 		dev_put(dev);
 		return -EINVAL;
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index f08b37a..a2b9e4e 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -36,8 +36,8 @@ static int lowpan_frag_reasm(struct lowpan_frag_queue *fq,
 			     struct sk_buff *prev, struct net_device *dev);
 
 static unsigned int lowpan_hash_frag(__be16 tag, u16 d_size,
-				     const struct ieee802154_addr_sa *saddr,
-				     const struct ieee802154_addr_sa *daddr)
+				     const struct ieee802154_addr *saddr,
+				     const struct ieee802154_addr *daddr)
 {
 	u32 c;
 
@@ -65,8 +65,8 @@ static bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
 
 	fq = container_of(q, struct lowpan_frag_queue, q);
 	return	fq->tag == arg->tag && fq->d_size == arg->d_size &&
-		ieee802154_addr_addr_equal(&fq->saddr, arg->src) &&
-		ieee802154_addr_addr_equal(&fq->daddr, arg->dst);
+		ieee802154_addr_equal(&fq->saddr, arg->src) &&
+		ieee802154_addr_equal(&fq->daddr, arg->dst);
 }
 
 static void lowpan_frag_init(struct inet_frag_queue *q, void *a)
@@ -103,7 +103,8 @@ out:
 
 static inline struct lowpan_frag_queue *
 fq_find(struct net *net, const struct ieee802154_frag_info *frag_info,
-	const struct ieee802154_addr_sa *src, const struct ieee802154_addr_sa *dst)
+	const struct ieee802154_addr *src,
+	const struct ieee802154_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct lowpan_create_arg arg;
@@ -346,8 +347,12 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 	struct lowpan_frag_queue *fq;
 	struct net *net = dev_net(skb->dev);
 	struct ieee802154_frag_info *frag_info = &mac_cb(skb)->frag_info;
+	struct ieee802154_addr source, dest;
 	int err;
 
+	source = mac_cb(skb)->source;
+	dest = mac_cb(skb)->dest;
+
 	err = lowpan_get_frag_info(skb, frag_type, frag_info);
 	if (err < 0)
 		goto err;
@@ -357,7 +362,7 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 
 	inet_frag_evictor(&net->ieee802154_lowpan.frags, &lowpan_frags, false);
 
-	fq = fq_find(net, frag_info, &mac_cb(skb)->sa, &mac_cb(skb)->da);
+	fq = fq_find(net, frag_info, &source, &dest);
 	if (fq != NULL) {
 		int ret;
 		spin_lock(&fq->q.lock);
diff --git a/net/ieee802154/reassembly.h b/net/ieee802154/reassembly.h
index 895721a..74e4a7c 100644
--- a/net/ieee802154/reassembly.h
+++ b/net/ieee802154/reassembly.h
@@ -6,8 +6,8 @@
 struct lowpan_create_arg {
 	__be16 tag;
 	u16 d_size;
-	const struct ieee802154_addr_sa *src;
-	const struct ieee802154_addr_sa *dst;
+	const struct ieee802154_addr *src;
+	const struct ieee802154_addr *dst;
 };
 
 /* Equivalent of ipv4 struct ip
@@ -17,16 +17,16 @@ struct lowpan_frag_queue {
 
 	__be16			tag;
 	u16			d_size;
-	struct ieee802154_addr_sa	saddr;
-	struct ieee802154_addr_sa	daddr;
+	struct ieee802154_addr	saddr;
+	struct ieee802154_addr	daddr;
 };
 
-static inline u32 ieee802154_addr_hash(const struct ieee802154_addr_sa *a)
+static inline u32 ieee802154_addr_hash(const struct ieee802154_addr *a)
 {
-	switch (a->addr_type) {
+	switch (a->mode) {
 	case IEEE802154_ADDR_LONG:
-		return (__force u32)((((u32 *)a->hwaddr))[0] ^
-				      ((u32 *)(a->hwaddr))[1]);
+		return (((__force u64)a->extended_addr) >> 32) ^
+			(((__force u64)a->extended_addr) & 0xffffffff);
 	case IEEE802154_ADDR_SHORT:
 		return (__force u32)(a->short_addr);
 	default:
@@ -34,32 +34,6 @@ static inline u32 ieee802154_addr_hash(const struct ieee802154_addr_sa *a)
 	}
 }
 
-static inline bool
-ieee802154_addr_addr_equal(const struct ieee802154_addr_sa *a1,
-			   const struct ieee802154_addr_sa *a2)
-{
-	if (a1->pan_id != a2->pan_id)
-		return false;
-
-	if (a1->addr_type != a2->addr_type)
-		return false;
-
-	switch (a1->addr_type) {
-	case IEEE802154_ADDR_LONG:
-		if (memcmp(a1->hwaddr, a2->hwaddr, IEEE802154_ADDR_LEN))
-			return false;
-		break;
-	case IEEE802154_ADDR_SHORT:
-		if (a1->short_addr != a2->short_addr)
-			return false;
-		break;
-	default:
-		return false;
-	}
-
-	return true;
-}
-
 int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type);
 void lowpan_net_frag_exit(void);
 int lowpan_net_frag_init(void);
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index f551ef2..15bac33 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -34,16 +34,16 @@
 #include "mac802154.h"
 
 static int mac802154_mlme_start_req(struct net_device *dev,
-				    struct ieee802154_addr_sa *addr,
+				    struct ieee802154_addr *addr,
 				    u8 channel, u8 page,
 				    u8 bcn_ord, u8 sf_ord,
 				    u8 pan_coord, u8 blx,
 				    u8 coord_realign)
 {
-	BUG_ON(addr->addr_type != IEEE802154_ADDR_SHORT);
+	BUG_ON(addr->mode != IEEE802154_ADDR_SHORT);
 
-	mac802154_dev_set_pan_id(dev, cpu_to_le16(addr->pan_id));
-	mac802154_dev_set_short_addr(dev, cpu_to_le16(addr->short_addr));
+	mac802154_dev_set_pan_id(dev, addr->pan_id);
+	mac802154_dev_set_short_addr(dev, addr->short_addr);
 	mac802154_dev_set_ieee_addr(dev);
 	mac802154_dev_set_page_channel(dev, page, channel);
 
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 051ed46..b614266 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -251,18 +251,18 @@ static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
 static int
 mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 {
-	u16 span, sshort;
+	__le16 span, sshort;
 
 	pr_debug("getting packet via slave interface %s\n", sdata->dev->name);
 
 	spin_lock_bh(&sdata->mib_lock);
 
-	span = le16_to_cpu(sdata->pan_id);
-	sshort = le16_to_cpu(sdata->short_addr);
+	span = sdata->pan_id;
+	sshort = sdata->short_addr;
 
-	switch (mac_cb(skb)->da.addr_type) {
+	switch (mac_cb(skb)->dest.mode) {
 	case IEEE802154_ADDR_NONE:
-		if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE)
+		if (mac_cb(skb)->dest.mode != IEEE802154_ADDR_NONE)
 			/* FIXME: check if we are PAN coordinator */
 			skb->pkt_type = PACKET_OTHERHOST;
 		else
@@ -270,23 +270,22 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 			skb->pkt_type = PACKET_HOST;
 		break;
 	case IEEE802154_ADDR_LONG:
-		if (mac_cb(skb)->da.pan_id != span &&
-		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+		if (mac_cb(skb)->dest.pan_id != span &&
+		    mac_cb(skb)->dest.pan_id != cpu_to_le16(IEEE802154_PANID_BROADCAST))
 			skb->pkt_type = PACKET_OTHERHOST;
-		else if (!memcmp(mac_cb(skb)->da.hwaddr, sdata->dev->dev_addr,
-				 IEEE802154_ADDR_LEN))
+		else if (mac_cb(skb)->dest.extended_addr == sdata->extended_addr)
 			skb->pkt_type = PACKET_HOST;
 		else
 			skb->pkt_type = PACKET_OTHERHOST;
 		break;
 	case IEEE802154_ADDR_SHORT:
-		if (mac_cb(skb)->da.pan_id != span &&
-		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+		if (mac_cb(skb)->dest.pan_id != span &&
+		    mac_cb(skb)->dest.pan_id != cpu_to_le16(IEEE802154_PANID_BROADCAST))
 			skb->pkt_type = PACKET_OTHERHOST;
-		else if (mac_cb(skb)->da.short_addr == sshort)
+		else if (mac_cb(skb)->dest.short_addr == sshort)
 			skb->pkt_type = PACKET_HOST;
-		else if (mac_cb(skb)->da.short_addr ==
-					IEEE802154_ADDR_BROADCAST)
+		else if (mac_cb(skb)->dest.short_addr ==
+			  cpu_to_le16(IEEE802154_ADDR_BROADCAST))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -332,8 +331,8 @@ static void mac802154_print_addr(const char *name,
 
 static int mac802154_parse_frame_start(struct sk_buff *skb)
 {
-	struct ieee802154_hdr hdr;
 	int hlen;
+	struct ieee802154_hdr hdr;
 
 	hlen = ieee802154_hdr_pull(skb, &hdr);
 	if (hlen < 0)
@@ -346,9 +345,6 @@ static int mac802154_parse_frame_start(struct sk_buff *skb)
 
 	mac_cb(skb)->flags = hdr.fc.type;
 
-	ieee802154_addr_to_sa(&mac_cb(skb)->sa, &hdr.source);
-	ieee802154_addr_to_sa(&mac_cb(skb)->da, &hdr.dest);
-
 	if (hdr.fc.ack_request)
 		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
 	if (hdr.fc.security_enabled)
@@ -357,6 +353,9 @@ static int mac802154_parse_frame_start(struct sk_buff *skb)
 	mac802154_print_addr("destination", &hdr.dest);
 	mac802154_print_addr("source", &hdr.source);
 
+	mac_cb(skb)->source = hdr.source;
+	mac_cb(skb)->dest = hdr.dest;
+
 	if (hdr.fc.security_enabled) {
 		u64 key;
 
-- 
1.9.0


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
