From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 3/8] ieee802154: enforce
	consistent endianness in the 802.15.4 stack
Date: Fri, 14 Mar 2014 16:23:28 +0100
Message-ID: <1394810613-5657-4-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394810613-5657-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Enable sparse warnings about endianness, replace the remaining fields
regarding network operations without explicit endianness annotations
with such that are annotated, and propagate this through the entire
stack.

Uses of ieee802154_addr_sa are not changed yet, this patch is only
concerned with all other fields (such as address filters, operation
parameters and the likes).

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c |   25 +++++++++++----------
 drivers/net/ieee802154/fakehard.c  |   14 ++++++------
 drivers/net/ieee802154/mrf24j40.c  |   17 +++++++-------
 include/net/ieee802154_netdev.h    |    6 ++---
 include/net/mac802154.h            |    5 ++---
 include/net/nl802154.h             |    6 ++---
 net/ieee802154/6lowpan_rtnl.c      |    8 +++----
 net/ieee802154/Makefile            |    2 ++
 net/ieee802154/af_ieee802154.c     |   10 ++++-----
 net/ieee802154/dgram.c             |    4 ++--
 net/ieee802154/nl-mac.c            |   32 +++++++++++++++------------
 net/mac802154/Makefile             |    2 ++
 net/mac802154/ieee802154_dev.c     |    5 ++++-
 net/mac802154/mac802154.h          |    9 ++++----
 net/mac802154/mac_cmd.c            |    4 ++--
 net/mac802154/mib.c                |   24 +++++++++++---------
 net/mac802154/wpan.c               |   43 ++++++++++++++++++++++--------------
 17 files changed, 121 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index b8e7321..934a12c 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -745,30 +745,31 @@ at86rf230_set_hw_addr_filt(struct ieee802154_dev *dev,
 	struct at86rf230_local *lp = dev->priv;
 
 	if (changed & IEEE802515_AFILT_SADDR_CHANGED) {
+		u16 addr = le16_to_cpu(filt->short_addr);
+
 		dev_vdbg(&lp->spi->dev,
 			"at86rf230_set_hw_addr_filt called for saddr\n");
-		__at86rf230_write(lp, RG_SHORT_ADDR_0, filt->short_addr);
-		__at86rf230_write(lp, RG_SHORT_ADDR_1, filt->short_addr >> 8);
+		__at86rf230_write(lp, RG_SHORT_ADDR_0, addr);
+		__at86rf230_write(lp, RG_SHORT_ADDR_1, addr >> 8);
 	}
 
 	if (changed & IEEE802515_AFILT_PANID_CHANGED) {
+		u16 pan = le16_to_cpu(filt->pan_id);
+
 		dev_vdbg(&lp->spi->dev,
 			"at86rf230_set_hw_addr_filt called for pan id\n");
-		__at86rf230_write(lp, RG_PAN_ID_0, filt->pan_id);
-		__at86rf230_write(lp, RG_PAN_ID_1, filt->pan_id >> 8);
+		__at86rf230_write(lp, RG_PAN_ID_0, pan);
+		__at86rf230_write(lp, RG_PAN_ID_1, pan >> 8);
 	}
 
 	if (changed & IEEE802515_AFILT_IEEEADDR_CHANGED) {
+		u8 i, addr[8];
+
+		memcpy(addr, &filt->ieee_addr, 8);
 		dev_vdbg(&lp->spi->dev,
 			"at86rf230_set_hw_addr_filt called for IEEE addr\n");
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_0, filt->ieee_addr[7]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_1, filt->ieee_addr[6]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_2, filt->ieee_addr[5]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_3, filt->ieee_addr[4]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_4, filt->ieee_addr[3]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_5, filt->ieee_addr[2]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_6, filt->ieee_addr[1]);
-		at86rf230_write_subreg(lp, SR_IEEE_ADDR_7, filt->ieee_addr[0]);
+		for (i = 0; i < 8; i++)
+			__at86rf230_write(lp, RG_IEEE_ADDR_0 + i, addr[i]);
 	}
 
 	if (changed & IEEE802515_AFILT_PANC_CHANGED) {
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 06a400f..3c98030 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -63,11 +63,11 @@ static struct wpan_phy *fake_get_phy(const struct net_device *dev)
  *
  * Return the ID of the PAN from the PIB.
  */
-static u16 fake_get_pan_id(const struct net_device *dev)
+static __le16 fake_get_pan_id(const struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
-	return 0xeba1;
+	return cpu_to_le16(0xeba1);
 }
 
 /**
@@ -78,11 +78,11 @@ static u16 fake_get_pan_id(const struct net_device *dev)
  * device. If the device has not yet had a short address assigned
  * then this should return 0xFFFF to indicate a lack of association.
  */
-static u16 fake_get_short_addr(const struct net_device *dev)
+static __le16 fake_get_short_addr(const struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
-	return 0x1;
+	return cpu_to_le16(0x1);
 }
 
 /**
@@ -149,7 +149,7 @@ static int fake_assoc_req(struct net_device *dev,
  *       802.15.4-2006 document.
  */
 static int fake_assoc_resp(struct net_device *dev,
-		struct ieee802154_addr_sa *addr, u16 short_addr, u8 status)
+		struct ieee802154_addr_sa *addr, __le16 short_addr, u8 status)
 {
 	return 0;
 }
@@ -281,8 +281,8 @@ static int ieee802154_fake_ioctl(struct net_device *dev, struct ifreq *ifr,
 	switch (cmd) {
 	case SIOCGIFADDR:
 		/* FIXME: fixed here, get from device IRL */
-		pan_id = fake_get_pan_id(dev);
-		short_addr = fake_get_short_addr(dev);
+		pan_id = le16_to_cpu(fake_get_pan_id(dev));
+		short_addr = le16_to_cpu(fake_get_short_addr(dev));
 		if (pan_id == IEEE802154_PANID_BROADCAST ||
 		    short_addr == IEEE802154_ADDR_BROADCAST)
 			return -EADDRNOTAVAIL;
diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 246befa..78a6552 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -465,8 +465,8 @@ static int mrf24j40_filter(struct ieee802154_dev *dev,
 	if (changed & IEEE802515_AFILT_SADDR_CHANGED) {
 		/* Short Addr */
 		u8 addrh, addrl;
-		addrh = filt->short_addr >> 8 & 0xff;
-		addrl = filt->short_addr & 0xff;
+		addrh = le16_to_cpu(filt->short_addr) >> 8 & 0xff;
+		addrl = le16_to_cpu(filt->short_addr) & 0xff;
 
 		write_short_reg(devrec, REG_SADRH, addrh);
 		write_short_reg(devrec, REG_SADRL, addrl);
@@ -476,15 +476,16 @@ static int mrf24j40_filter(struct ieee802154_dev *dev,
 
 	if (changed & IEEE802515_AFILT_IEEEADDR_CHANGED) {
 		/* Device Address */
-		int i;
+		u8 i, addr[8];
+
+		memcpy(addr, &filt->ieee_addr, 8);
 		for (i = 0; i < 8; i++)
-			write_short_reg(devrec, REG_EADR0+i,
-					filt->ieee_addr[7-i]);
+			write_short_reg(devrec, REG_EADR0 + i, addr[i]);
 
 #ifdef DEBUG
 		printk(KERN_DEBUG "Set long addr to: ");
 		for (i = 0; i < 8; i++)
-			printk("%02hhx ", filt->ieee_addr[i]);
+			printk("%02hhx ", addr[7 - i]);
 		printk(KERN_DEBUG "\n");
 #endif
 	}
@@ -492,8 +493,8 @@ static int mrf24j40_filter(struct ieee802154_dev *dev,
 	if (changed & IEEE802515_AFILT_PANID_CHANGED) {
 		/* PAN ID */
 		u8 panidl, panidh;
-		panidh = filt->pan_id >> 8 & 0xff;
-		panidl = filt->pan_id & 0xff;
+		panidh = le16_to_cpu(filt->pan_id) >> 8 & 0xff;
+		panidl = le16_to_cpu(filt->pan_id) & 0xff;
 		write_short_reg(devrec, REG_PANIDH, panidh);
 		write_short_reg(devrec, REG_PANIDL, panidl);
 
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 86d5d50..e4810d5 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -171,7 +171,7 @@ struct ieee802154_mlme_ops {
 			u8 channel, u8 page, u8 cap);
 	int (*assoc_resp)(struct net_device *dev,
 			struct ieee802154_addr_sa *addr,
-			u16 short_addr, u8 status);
+			__le16 short_addr, u8 status);
 	int (*disassoc_req)(struct net_device *dev,
 			struct ieee802154_addr_sa *addr,
 			u8 reason);
@@ -190,8 +190,8 @@ struct ieee802154_mlme_ops {
 	 * FIXME: these should become the part of PIB/MIB interface.
 	 * However we still don't have IB interface of any kind
 	 */
-	u16 (*get_pan_id)(const struct net_device *dev);
-	u16 (*get_short_addr)(const struct net_device *dev);
+	__le16 (*get_pan_id)(const struct net_device *dev);
+	__le16 (*get_short_addr)(const struct net_device *dev);
 	u8 (*get_dsn)(const struct net_device *dev);
 };
 
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 8ca3d04..f74b2a8 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -50,7 +50,7 @@ struct ieee802154_hw_addr_filt {
 				 * devices across independent networks.
 				 */
 	__le16	short_addr;
-	u8	ieee_addr[IEEE802154_ADDR_LEN];
+	__le64	ieee_addr;
 	u8	pan_coord;
 };
 
@@ -153,8 +153,7 @@ struct ieee802154_ops {
 	int		(*set_hw_addr_filt)(struct ieee802154_dev *dev,
 					  struct ieee802154_hw_addr_filt *filt,
 					    unsigned long changed);
-	int		(*ieee_addr)(struct ieee802154_dev *dev,
-				     u8 addr[IEEE802154_ADDR_LEN]);
+	int		(*ieee_addr)(struct ieee802154_dev *dev, __le64 addr);
 	int		(*set_txpower)(struct ieee802154_dev *dev, int db);
 	int		(*set_lbt)(struct ieee802154_dev *dev, bool on);
 	int		(*set_cca_mode)(struct ieee802154_dev *dev, u8 mode);
diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index 06ead97..3121ed0 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -52,7 +52,7 @@ int ieee802154_nl_assoc_indic(struct net_device *dev,
  * Note: This is in section 7.3.2 of the IEEE 802.15.4 document.
  */
 int ieee802154_nl_assoc_confirm(struct net_device *dev,
-		u16 short_addr, u8 status);
+		__le16 short_addr, u8 status);
 
 /**
  * ieee802154_nl_disassoc_indic - Notify userland of disassociation.
@@ -111,8 +111,8 @@ int ieee802154_nl_scan_confirm(struct net_device *dev,
  * Note: This API cannot indicate a beacon frame for a coordinator
  *       operating in long addressing mode.
  */
-int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid,
-		u16 coord_addr);
+int ieee802154_nl_beacon_indic(struct net_device *dev, __le16 panid,
+		__le16 coord_addr);
 
 /**
  * ieee802154_nl_start_confirm - Notify userland of completion of start.
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 331180e..c23349d 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -120,11 +120,11 @@ static int lowpan_header_create(struct sk_buff *skb,
 
 	/* prepare wpan address data */
 	sa.addr_type = IEEE802154_ADDR_LONG;
-	sa.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	sa.pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
 
 	memcpy(&(sa.hwaddr), saddr, 8);
 	/* intra-PAN communications */
-	da.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	da.pan_id = sa.pan_id;
 
 	/* if the destination address is the broadcast address, use the
 	 * corresponding short address
@@ -352,13 +352,13 @@ static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)
 	return ieee802154_mlme_ops(real_dev)->get_phy(real_dev);
 }
 
-static u16 lowpan_get_pan_id(const struct net_device *dev)
+static __le16 lowpan_get_pan_id(const struct net_device *dev)
 {
 	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
 	return ieee802154_mlme_ops(real_dev)->get_pan_id(real_dev);
 }
 
-static u16 lowpan_get_short_addr(const struct net_device *dev)
+static __le16 lowpan_get_short_addr(const struct net_device *dev)
 {
 	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
 	return ieee802154_mlme_ops(real_dev)->get_short_addr(real_dev);
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index b113fc4..78b1fa2 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -5,3 +5,5 @@ obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
 6lowpan-y := 6lowpan_rtnl.o reassembly.o
 ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
+
+ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index a8db341..973cb11 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -48,7 +48,7 @@ struct net_device *ieee802154_get_dev(struct net *net,
 {
 	struct net_device *dev = NULL;
 	struct net_device *tmp;
-	u16 pan_id, short_addr;
+	__le16 pan_id, short_addr;
 
 	switch (addr->addr_type) {
 	case IEEE802154_ADDR_LONG:
@@ -59,9 +59,9 @@ struct net_device *ieee802154_get_dev(struct net *net,
 		rcu_read_unlock();
 		break;
 	case IEEE802154_ADDR_SHORT:
-		if (addr->pan_id == 0xffff ||
+		if (addr->pan_id == IEEE802154_PANID_BROADCAST ||
 		    addr->short_addr == IEEE802154_ADDR_UNDEF ||
-		    addr->short_addr == 0xffff)
+		    addr->short_addr == IEEE802154_ADDR_UNDEF)
 			break;
 
 		rtnl_lock();
@@ -74,8 +74,8 @@ struct net_device *ieee802154_get_dev(struct net *net,
 			short_addr =
 				ieee802154_mlme_ops(tmp)->get_short_addr(tmp);
 
-			if (pan_id == addr->pan_id &&
-			    short_addr == addr->short_addr) {
+			if (le16_to_cpu(pan_id) == addr->pan_id &&
+			    le16_to_cpu(short_addr) == addr->short_addr) {
 				dev = tmp;
 				dev_hold(dev);
 				break;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 405fdf9..9df3a1d94 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -363,8 +363,8 @@ int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 	/* Data frame processing */
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
-	pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
-	short_addr = ieee802154_mlme_ops(dev)->get_short_addr(dev);
+	pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	short_addr = le16_to_cpu(ieee802154_mlme_ops(dev)->get_short_addr(dev));
 
 	read_lock(&dgram_lock);
 	sk_for_each(sk, &dgram_head) {
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 7ae93e1..58fa523 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -72,7 +72,7 @@ nla_put_failure:
 }
 EXPORT_SYMBOL(ieee802154_nl_assoc_indic);
 
-int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr,
+int ieee802154_nl_assoc_confirm(struct net_device *dev, __le16 short_addr,
 		u8 status)
 {
 	struct sk_buff *msg;
@@ -87,7 +87,8 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr,
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR,
+			le16_to_cpu(short_addr)) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_STATUS, status))
 		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
@@ -157,8 +158,8 @@ nla_put_failure:
 }
 EXPORT_SYMBOL(ieee802154_nl_disassoc_confirm);
 
-int ieee802154_nl_beacon_indic(struct net_device *dev,
-		u16 panid, u16 coord_addr)
+int ieee802154_nl_beacon_indic(struct net_device *dev, __le16 panid,
+			       __le16 coord_addr)
 {
 	struct sk_buff *msg;
 
@@ -172,8 +173,10 @@ int ieee802154_nl_beacon_indic(struct net_device *dev,
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid))
+	    nla_put_u16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR,
+			le16_to_cpu(coord_addr)) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_COORD_PAN_ID,
+			le16_to_cpu(panid)))
 		goto nla_put_failure;
 	return ieee802154_nl_mcast(msg, IEEE802154_COORD_MCGRP);
 
@@ -243,6 +246,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 {
 	void *hdr;
 	struct wpan_phy *phy;
+	u16 short_addr, pan_id;
 
 	pr_debug("%s\n", __func__);
 
@@ -254,15 +258,16 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
 	BUG_ON(!phy);
 
+	short_addr = le16_to_cpu(ieee802154_mlme_ops(dev)->get_short_addr(dev));
+	pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
+
 	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
 	    nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
 	    nla_put(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
 		    dev->dev_addr) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR,
-			ieee802154_mlme_ops(dev)->get_short_addr(dev)) ||
-	    nla_put_u16(msg, IEEE802154_ATTR_PAN_ID,
-			ieee802154_mlme_ops(dev)->get_pan_id(dev)))
+	    nla_put_u16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr) ||
+	    nla_put_u16(msg, IEEE802154_ATTR_PAN_ID, pan_id))
 		goto nla_put_failure;
 	wpan_phy_put(phy);
 	return genlmsg_end(msg, hdr);
@@ -368,11 +373,10 @@ int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info)
 	addr.addr_type = IEEE802154_ADDR_LONG;
 	nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_DEST_HW_ADDR],
 			IEEE802154_ADDR_LEN);
-	addr.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
-
+	addr.pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
 
 	ret = ieee802154_mlme_ops(dev)->assoc_resp(dev, &addr,
-		nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]),
+		cpu_to_le16(nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR])),
 		nla_get_u8(info->attrs[IEEE802154_ATTR_STATUS]));
 
 out:
@@ -407,7 +411,7 @@ int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
 		addr.short_addr = nla_get_u16(
 				info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]);
 	}
-	addr.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	addr.pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
 
 	ret = ieee802154_mlme_ops(dev)->disassoc_req(dev, &addr,
 			nla_get_u8(info->attrs[IEEE802154_ATTR_REASON]));
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index 57cf5d1..15d62df5 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
 mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o mib.o monitor.o wpan.o
+
+ccflags-y += -D__CHECK_ENDIAN__
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index b75bb01..10cdb09 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -27,6 +27,7 @@
 #include <net/netlink.h>
 #include <linux/nl802154.h>
 #include <net/mac802154.h>
+#include <net/ieee802154_netdev.h>
 #include <net/route.h>
 #include <net/wpan-phy.h>
 
@@ -46,7 +47,9 @@ int mac802154_slave_open(struct net_device *dev)
 	}
 
 	if (ipriv->ops->ieee_addr) {
-		res = ipriv->ops->ieee_addr(&ipriv->hw, dev->dev_addr);
+		__le64 addr = ieee802154_devaddr_from_raw(dev->dev_addr);
+
+		res = ipriv->ops->ieee_addr(&ipriv->hw, addr);
 		WARN_ON(res);
 		if (res)
 			goto err;
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index d48422e..4619486 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -76,6 +76,7 @@ struct mac802154_sub_if_data {
 
 	__le16 pan_id;
 	__le16 short_addr;
+	__le64 extended_addr;
 
 	u8 chan;
 	u8 page;
@@ -106,11 +107,11 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
 /* MIB callbacks */
-void mac802154_dev_set_short_addr(struct net_device *dev, u16 val);
-u16 mac802154_dev_get_short_addr(const struct net_device *dev);
+void mac802154_dev_set_short_addr(struct net_device *dev, __le16 val);
+__le16 mac802154_dev_get_short_addr(const struct net_device *dev);
 void mac802154_dev_set_ieee_addr(struct net_device *dev);
-u16 mac802154_dev_get_pan_id(const struct net_device *dev);
-void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
+__le16 mac802154_dev_get_pan_id(const struct net_device *dev);
+void mac802154_dev_set_pan_id(struct net_device *dev, __le16 val);
 void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan);
 u8 mac802154_dev_get_dsn(const struct net_device *dev);
 
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index e079c57..f551ef2 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -42,8 +42,8 @@ static int mac802154_mlme_start_req(struct net_device *dev,
 {
 	BUG_ON(addr->addr_type != IEEE802154_ADDR_SHORT);
 
-	mac802154_dev_set_pan_id(dev, addr->pan_id);
-	mac802154_dev_set_short_addr(dev, addr->short_addr);
+	mac802154_dev_set_pan_id(dev, cpu_to_le16(addr->pan_id));
+	mac802154_dev_set_short_addr(dev, cpu_to_le16(addr->short_addr));
 	mac802154_dev_set_ieee_addr(dev);
 	mac802154_dev_set_page_channel(dev, page, channel);
 
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index f48f40c..ba5abdc 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -24,6 +24,7 @@
 #include <linux/if_arp.h>
 
 #include <net/mac802154.h>
+#include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
 
 #include "mac802154.h"
@@ -79,7 +80,7 @@ static void set_hw_addr_filt(struct net_device *dev, unsigned long changed)
 	queue_work(priv->hw->dev_workqueue, &work->work);
 }
 
-void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
+void mac802154_dev_set_short_addr(struct net_device *dev, __le16 val)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 
@@ -96,10 +97,10 @@ void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
 	}
 }
 
-u16 mac802154_dev_get_short_addr(const struct net_device *dev)
+__le16 mac802154_dev_get_short_addr(const struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-	u16 ret;
+	__le16 ret;
 
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
@@ -114,20 +115,21 @@ void mac802154_dev_set_ieee_addr(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 	struct mac802154_priv *mac = priv->hw;
+	__le64 addr;
 
-	if (mac->ops->set_hw_addr_filt &&
-	    memcmp(mac->hw.hw_filt.ieee_addr,
-		   dev->dev_addr, IEEE802154_ADDR_LEN)) {
-		memcpy(mac->hw.hw_filt.ieee_addr,
-		       dev->dev_addr, IEEE802154_ADDR_LEN);
+	addr = ieee802154_devaddr_from_raw(dev->dev_addr);
+	priv->extended_addr = addr;
+
+	if (mac->ops->set_hw_addr_filt && mac->hw.hw_filt.ieee_addr != addr) {
+		mac->hw.hw_filt.ieee_addr = addr;
 		set_hw_addr_filt(dev, IEEE802515_AFILT_IEEEADDR_CHANGED);
 	}
 }
 
-u16 mac802154_dev_get_pan_id(const struct net_device *dev)
+__le16 mac802154_dev_get_pan_id(const struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-	u16 ret;
+	__le16 ret;
 
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
@@ -138,7 +140,7 @@ u16 mac802154_dev_get_pan_id(const struct net_device *dev)
 	return ret;
 }
 
-void mac802154_dev_set_pan_id(struct net_device *dev, u16 val)
+void mac802154_dev_set_pan_id(struct net_device *dev, __le16 val)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index b2bc3f0..43e886b 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -76,19 +76,25 @@ mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCGIFADDR:
-		if (priv->pan_id == IEEE802154_PANID_BROADCAST ||
-		    priv->short_addr == IEEE802154_ADDR_BROADCAST) {
+	{
+		u16 pan_id, short_addr;
+
+		pan_id = le16_to_cpu(priv->pan_id);
+		short_addr = le16_to_cpu(priv->short_addr);
+		if (pan_id == IEEE802154_PANID_BROADCAST ||
+		    short_addr == IEEE802154_ADDR_BROADCAST) {
 			err = -EADDRNOTAVAIL;
 			break;
 		}
 
 		sa->family = AF_IEEE802154;
 		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
-		sa->addr.pan_id = priv->pan_id;
-		sa->addr.short_addr = priv->short_addr;
+		sa->addr.pan_id = pan_id;
+		sa->addr.short_addr = short_addr;
 
 		err = 0;
 		break;
+	}
 	case SIOCSIFADDR:
 		dev_warn(&dev->dev,
 			 "Using DEBUGing ioctl SIOCSIFADDR isn't recommened!\n");
@@ -101,8 +107,8 @@ mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			break;
 		}
 
-		priv->pan_id = sa->addr.pan_id;
-		priv->short_addr = sa->addr.short_addr;
+		priv->pan_id = cpu_to_le16(sa->addr.pan_id);
+		priv->short_addr = cpu_to_le16(sa->addr.short_addr);
 
 		err = 0;
 		break;
@@ -151,18 +157,18 @@ static int mac802154_header_create(struct sk_buff *skb,
 	if (!saddr) {
 		spin_lock_bh(&priv->mib_lock);
 
-		if (priv->short_addr == IEEE802154_ADDR_BROADCAST ||
-		    priv->short_addr == IEEE802154_ADDR_UNDEF ||
-		    priv->pan_id == IEEE802154_PANID_BROADCAST) {
+		if (priv->short_addr == cpu_to_le16(IEEE802154_ADDR_BROADCAST) ||
+		    priv->short_addr == cpu_to_le16(IEEE802154_ADDR_UNDEF) ||
+		    priv->pan_id == cpu_to_le16(IEEE802154_PANID_BROADCAST)) {
 			dev_addr.addr_type = IEEE802154_ADDR_LONG;
 			memcpy(dev_addr.hwaddr, dev->dev_addr,
 			       IEEE802154_ADDR_LEN);
 		} else {
 			dev_addr.addr_type = IEEE802154_ADDR_SHORT;
-			dev_addr.short_addr = priv->short_addr;
+			dev_addr.short_addr = le16_to_cpu(priv->short_addr);
 		}
 
-		dev_addr.pan_id = priv->pan_id;
+		dev_addr.pan_id = le16_to_cpu(priv->pan_id);
 		saddr = &dev_addr;
 
 		spin_unlock_bh(&priv->mib_lock);
@@ -382,8 +388,8 @@ void mac802154_wpan_setup(struct net_device *dev)
 	get_random_bytes(&priv->bsn, 1);
 	get_random_bytes(&priv->dsn, 1);
 
-	priv->pan_id = IEEE802154_PANID_BROADCAST;
-	priv->short_addr = IEEE802154_ADDR_BROADCAST;
+	priv->pan_id = cpu_to_le16(IEEE802154_PANID_BROADCAST);
+	priv->short_addr = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
 }
 
 static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
@@ -394,10 +400,15 @@ static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
 static int
 mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 {
+	u16 span, sshort;
+
 	pr_debug("getting packet via slave interface %s\n", sdata->dev->name);
 
 	spin_lock_bh(&sdata->mib_lock);
 
+	span = le16_to_cpu(sdata->pan_id);
+	sshort = le16_to_cpu(sdata->short_addr);
+
 	switch (mac_cb(skb)->da.addr_type) {
 	case IEEE802154_ADDR_NONE:
 		if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE)
@@ -408,7 +419,7 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 			skb->pkt_type = PACKET_HOST;
 		break;
 	case IEEE802154_ADDR_LONG:
-		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
+		if (mac_cb(skb)->da.pan_id != span &&
 		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
 			skb->pkt_type = PACKET_OTHERHOST;
 		else if (!memcmp(mac_cb(skb)->da.hwaddr, sdata->dev->dev_addr,
@@ -418,10 +429,10 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 			skb->pkt_type = PACKET_OTHERHOST;
 		break;
 	case IEEE802154_ADDR_SHORT:
-		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
+		if (mac_cb(skb)->da.pan_id != span &&
 		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
 			skb->pkt_type = PACKET_OTHERHOST;
-		else if (mac_cb(skb)->da.short_addr == sdata->short_addr)
+		else if (mac_cb(skb)->da.short_addr == sshort)
 			skb->pkt_type = PACKET_HOST;
 		else if (mac_cb(skb)->da.short_addr ==
 					IEEE802154_ADDR_BROADCAST)
-- 
1.7.9.5


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
