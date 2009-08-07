From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 09/10] nl802154: support START-CONFIRM
	primitive
Date: Fri,  7 Aug 2009 16:58:44 +0400
Message-ID: <1249649925-11996-10-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-4-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-5-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-6-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-7-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-8-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-9-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249649925-11996-9-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/nl802154.h   |    9 +++++++++
 net/ieee802154/netlink.c |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index 6096096..e554ecd 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -114,4 +114,13 @@ int ieee802154_nl_scan_confirm(struct net_device *dev,
 int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid,
 		u16 coord_addr);
 
+/**
+ * ieee802154_nl_start_confirm - Notify userland of completion of start.
+ * @dev: The device which was instructed to scan.
+ * @status: The status of the scan operation.
+ *
+ * Note: This is in section 7.1.14 of the IEEE 802.15.4 document.
+ */
+int ieee802154_nl_start_confirm(struct net_device *dev, u8 status);
+
 #endif
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 6fc6d6f..70a067e 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -31,6 +31,7 @@
 #include <linux/nl802154.h>
 #include <net/af_ieee802154.h>
 #include <net/nl802154.h>
+#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
 static unsigned int ieee802154_seq_num;
@@ -262,6 +263,31 @@ nla_put_failure:
 }
 EXPORT_SYMBOL(ieee802154_nl_scan_confirm);
 
+int ieee802154_nl_start_confirm(struct net_device *dev, u8 status)
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	msg = ieee802154_nl_create(0, IEEE802154_START_CONF);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+			dev->dev_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	nlmsg_free(msg);
+	return -ENOBUFS;
+}
+EXPORT_SYMBOL(ieee802154_nl_start_confirm);
+
 static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 	u32 seq, int flags, struct net_device *dev)
 {
@@ -462,6 +488,12 @@ static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 	blx = nla_get_u8(info->attrs[IEEE802154_ATTR_BAT_EXT]);
 	coord_realign = nla_get_u8(info->attrs[IEEE802154_ATTR_COORD_REALIGN]);
 
+	if (addr.short_addr == IEEE802154_ADDR_BROADCAST) {
+		ieee802154_nl_start_confirm(dev, IEEE802154_NO_SHORT_ADDRESS);
+		dev_put(dev);
+		return -EINVAL;
+	}
+
 	ret = ieee802154_mlme_ops(dev)->start_req(dev, &addr, channel,
 		bcn_ord, sf_ord, pan_coord, blx, coord_realign);
 
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
