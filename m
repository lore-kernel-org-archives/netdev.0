From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next-2.6 1/2] dcbnl: add support for retrieving peer
 configuration - ieee
Date: Thu, 24 Feb 2011 23:03:30 +0200
Message-ID: <1298581410.8877.21.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John Fastabend" <john.r.fastabend@intel.com>,
	"Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4487 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477Ab1BXTD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 14:03:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These 2 patches add the support for retrieving the remote or peer DCBX
configuration via dcbnl for embedded DCBX stacks. The peer configuration
is part of the DCBX MIB and is useful for debugging and diagnostics of
the overall DCB configuration. The first patch add this support for IEEE
802.1Qaz standard the second patch add the same support for the older
CEE standard. 

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 include/linux/dcbnl.h |   38 ++++++++++++++++++++++++++
 include/net/dcbnl.h   |    5 +++
 net/dcb/dcbnl.c       |   71 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 4c5b26e..3102185 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -110,6 +110,22 @@ struct dcb_app {
 	__u16	protocol;
 };
 
+/* This structure contains the APP feature information sent by the peer.
+ * It is used for both the IEEE 802.1Qaz and the CEE flavors.
+ *
+ * @willing: willing bit in the peer APP tlv
+ * @error: error bit in the peer APP tlv
+ * @app_count: The number of objects in the peer APP table.
+ *
+ * In addition to this information the full peer APP tlv also contains
+ * a table of 'app_count' APP objects defined above.
+ */
+struct dcb_peer_app_info {
+	__u8	willing;
+	__u8	error;
+	__u16	app_count;
+};
+
 struct dcbmsg {
 	__u8               dcb_family;
 	__u8               cmd;
@@ -235,11 +251,25 @@ enum dcbnl_attrs {
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
 };
 
+/**
+ * enum ieee_attrs - IEEE 802.1Qaz get/set attributes
+ *
+ * @DCB_ATTR_IEEE_UNSPEC: unspecified
+ * @DCB_ATTR_IEEE_ETS: negotiated ETS configuration
+ * @DCB_ATTR_IEEE_PFC: negotiated PFC configuration
+ * @DCB_ATTR_IEEE_APP_TABLE: negotiated APP configuration
+ * @DCB_ATTR_IEEE_PEER_ETS: peer ETS configuration - get only
+ * @DCB_ATTR_IEEE_PEER_PFC: peer PFC configuration - get only
+ * @DCB_ATTR_IEEE_PEER_APP: peer APP tlv - get only
+ */
 enum ieee_attrs {
 	DCB_ATTR_IEEE_UNSPEC,
 	DCB_ATTR_IEEE_ETS,
 	DCB_ATTR_IEEE_PFC,
 	DCB_ATTR_IEEE_APP_TABLE,
+	DCB_ATTR_IEEE_PEER_ETS,
+	DCB_ATTR_IEEE_PEER_PFC,
+	DCB_ATTR_IEEE_PEER_APP,
 	__DCB_ATTR_IEEE_MAX
 };
 #define DCB_ATTR_IEEE_MAX (__DCB_ATTR_IEEE_MAX - 1)
@@ -251,6 +281,14 @@ enum ieee_attrs_app {
 };
 #define DCB_ATTR_IEEE_APP_MAX (__DCB_ATTR_IEEE_APP_MAX - 1)
 
+enum peer_app_attr {
+	DCB_ATTR_PEER_APP_UNSPEC,
+	DCB_ATTR_PEER_APP_INFO,
+	DCB_ATTR_PEER_APP,
+	__DCB_ATTR_PEER_APP_MAX
+};
+#define DCB_ATTR_PEER_APP_MAX (__DCB_ATTR_PEER_APP_MAX - 1)
+
 /**
  * enum dcbnl_pfc_attrs - DCB Priority Flow Control user priority nested attrs
  *
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index a8e7852..739feb4 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -43,6 +43,8 @@ struct dcbnl_rtnl_ops {
 	int (*ieee_setpfc) (struct net_device *, struct ieee_pfc *);
 	int (*ieee_getapp) (struct net_device *, struct dcb_app *);
 	int (*ieee_setapp) (struct net_device *, struct dcb_app *);
+	int (*ieee_peer_getets) (struct net_device *, struct ieee_ets *);
+	int (*ieee_peer_getpfc) (struct net_device *, struct ieee_pfc *);
 
 	/* CEE std */
 	u8   (*getstate)(struct net_device *);
@@ -77,6 +79,9 @@ struct dcbnl_rtnl_ops {
 	u8   (*getdcbx)(struct net_device *);
 	u8   (*setdcbx)(struct net_device *, u8);
 
+	/* peer apps */
+	int (*peer_getappinfo)(struct net_device *, struct dcb_peer_app_info *);
+	int (*peer_getapptable)(struct net_device *, struct dcb_app *);
 
 };
 
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index d5074a5..0eb7461 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1224,6 +1224,56 @@ err:
 	return err;
 }
 
+static int dcbnl_build_peer_app(struct net_device *netdev, struct sk_buff* skb,
+				int attrtype)
+{
+	struct dcb_peer_app_info info;
+	struct dcb_app *table = NULL;
+	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
+	int err;
+
+	/**
+	 * retrieve the peer app configuration form the driver. If the driver
+	 * handlers fail exit without doing anything
+	 */
+	err = ops->peer_getappinfo(netdev, &info);
+	if (!err && info.app_count) {
+		table = kmalloc(sizeof(struct dcb_app) * info.app_count,
+				GFP_KERNEL);
+		if (!table)
+			return -ENOMEM;
+
+		err = ops->peer_getapptable(netdev, table);
+	}
+
+	if (!err) {
+		u16 i;
+		struct nlattr *app;
+
+		/**
+		 * build the message, from here on the only possible failure
+		 * is due to the skb size
+		 */
+		err = -EMSGSIZE;
+
+		app = nla_nest_start(skb, attrtype);
+		if (!app)
+			goto nla_put_failure;
+
+		NLA_PUT(skb, DCB_ATTR_PEER_APP_INFO, sizeof(info), &info);
+
+		for (i = 0; i < info.app_count; i++)
+			NLA_PUT(skb, DCB_ATTR_PEER_APP, sizeof(struct dcb_app),
+				&table[i]);
+
+		nla_nest_end(skb, app);
+	}
+	err = 0;
+
+nla_put_failure:
+	kfree(table);
+	return err;
+}
 
 /* Handle IEEE 802.1Qaz GET commands. */
 static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
@@ -1288,6 +1338,27 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 	spin_unlock(&dcb_lock);
 	nla_nest_end(skb, app);
 
+	/* get peer info if available */
+	if (ops->ieee_peer_getets) {
+		struct ieee_ets ets;
+		err = ops->ieee_peer_getets(netdev, &ets);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_IEEE_PEER_ETS, sizeof(ets), &ets);
+	}
+
+	if (ops->ieee_peer_getpfc) {
+		struct ieee_pfc pfc;
+		err = ops->ieee_peer_getpfc(netdev, &pfc);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_IEEE_PEER_PFC, sizeof(pfc), &pfc);
+	}
+
+	if (ops->peer_getappinfo && ops->peer_getapptable) {
+		err = dcbnl_build_peer_app(netdev, skb, DCB_ATTR_IEEE_PEER_APP);
+		if (err)
+			goto nla_put_failure;
+	}
+
 	nla_nest_end(skb, ieee);
 	nlmsg_end(skb, nlh);
 
-- 
1.7.3.5




