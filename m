From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next-2.6 2/2] dcbnl: add support for retrieving peer
 configuration - cee
Date: Thu, 24 Feb 2011 23:03:34 +0200
Message-ID: <1298581414.8877.22.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John Fastabend" <john.r.fastabend@intel.com>,
	"Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4487 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756107Ab1BXTDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 14:03:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the support for retrieving the remote or peer DCBX
configuration via dcbnl for embedded DCBX stacks supporting the CEE DCBX
standard.

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 include/linux/dcbnl.h |   62 ++++++++++++++++++++++++++++++++++++++++++++++
 include/net/dcbnl.h   |    3 ++
 net/dcb/dcbnl.c       |   66 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 131 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 3102185..f937c75 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -87,6 +87,43 @@ struct ieee_pfc {
 	__u64	indications[IEEE_8021QAZ_MAX_TCS];
 };
 
+/* CEE DCBX std supported values */
+#define CEE_DCBX_MAX_PGS	8
+#define CEE_DCBX_MAX_PRIO	8
+
+/* This structure contains the CEE Prioity-Group managed object
+ *
+ * @willing: willing bit in the PG tlv
+ * @error: error bit in the PG tlv
+ * @pg_en: enable bit of the PG feature
+ * @tcs_supported: number of traffic classes supported
+ * @pg_bw: bandwidth percentage for each priority group
+ * @prio_pg: priority to PG mapping indexed by priority
+ */
+struct cee_pg {
+	__u8	willing;
+	__u8	error;
+	__u8	pg_en;
+	__u8	tcs_supported;
+	__u8	pg_bw[CEE_DCBX_MAX_PGS];
+	__u8	prio_pg[CEE_DCBX_MAX_PGS];
+};
+
+/* This structure contains the PFC managed object
+ *
+ * @willing: willing bit in the PFC tlv
+ * @error: error bit in the PFC tlv
+ * @pfc_en: bitmap indicating pfc enabled traffic classes
+ * @tcs_supported: number of traffic classes supported
+ */
+struct cee_pfc {
+	__u8	willing;
+	__u8	error;
+	__u8	pfc_en;
+	__u8	tcs_supported;
+};
+
+
 /* This structure contains the IEEE 802.1Qaz APP managed object. This
  * object is also used for the CEE std as well. There is no difference
  * between the objects.
@@ -160,6 +197,7 @@ struct dcbmsg {
  * @DCB_CMD_SDCBX: set DCBX engine configuration
  * @DCB_CMD_GFEATCFG: get DCBX features flags
  * @DCB_CMD_SFEATCFG: set DCBX features negotiation flags
+ * @DCB_CMD_CEE_GET: get CEE aggregated configuration
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -202,6 +240,8 @@ enum dcbnl_commands {
 	DCB_CMD_GFEATCFG,
 	DCB_CMD_SFEATCFG,
 
+	DCB_CMD_CEE_GET,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -224,6 +264,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_IEEE: IEEE 802.1Qaz supported attributes (NLA_NESTED)
  * @DCB_ATTR_DCBX: DCBX engine configuration in the device (NLA_U8)
  * @DCB_ATTR_FEATCFG: DCBX features flags (NLA_NESTED)
+ * @DCB_ATTR_CEE: CEE std supported attributes (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -247,6 +288,9 @@ enum dcbnl_attrs {
 	DCB_ATTR_DCBX,
 	DCB_ATTR_FEATCFG,
 
+	/* CEE nested attributes */
+	DCB_ATTR_CEE,
+
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
 };
@@ -281,6 +325,24 @@ enum ieee_attrs_app {
 };
 #define DCB_ATTR_IEEE_APP_MAX (__DCB_ATTR_IEEE_APP_MAX - 1)
 
+
+/**
+ * enum cee_attrs - CEE DCBX get attributes
+ *
+ * @DCB_ATTR_CEE_UNSPEC: unspecified
+ * @DCB_ATTR_CEE_PEER_PG: peer PG configuration - get only
+ * @DCB_ATTR_CEE_PEER_PFC: peer PFC configuration - get only
+ * @DCB_ATTR_CEE_PEER_APP: peer APP tlv - get only
+ */
+enum cee_attrs {
+	DCB_ATTR_CEE_UNSPEC,
+	DCB_ATTR_CEE_PEER_PG,
+	DCB_ATTR_CEE_PEER_PFC,
+	DCB_ATTR_CEE_PEER_APP,
+	__DCB_ATTR_CEE_MAX
+};
+#define DCB_ATTR_CEE_MAX (__DCB_ATTR_CEE_MAX - 1)
+
 enum peer_app_attr {
 	DCB_ATTR_PEER_APP_UNSPEC,
 	DCB_ATTR_PEER_APP_INFO,
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 739feb4..06227e83 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -83,6 +83,9 @@ struct dcbnl_rtnl_ops {
 	int (*peer_getappinfo)(struct net_device *, struct dcb_peer_app_info *);
 	int (*peer_getapptable)(struct net_device *, struct dcb_app *);
 
+	/* CEE peer */
+	int (*cee_peer_getpg) (struct net_device *, struct cee_pg *);
+	int (*cee_peer_getpfc) (struct net_device *, struct cee_pfc *);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 0eb7461..ea39e51 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1512,6 +1512,68 @@ err:
 	return ret;
 }
 
+/* Handle CEE DCBX GET commands. */
+static int dcbnl_cee_get(struct net_device *netdev, struct nlattr **tb,
+			 u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *cee;
+	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
+	int err;
+
+	if (!ops)
+		return -EOPNOTSUPP;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOBUFS;
+
+	nlh = NLMSG_NEW(skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
+
+	dcb = NLMSG_DATA(nlh);
+	dcb->dcb_family = AF_UNSPEC;
+	dcb->cmd = DCB_CMD_CEE_GET;
+
+	NLA_PUT_STRING(skb, DCB_ATTR_IFNAME, netdev->name);
+
+	cee = nla_nest_start(skb, DCB_ATTR_CEE);
+	if (!cee)
+		goto nla_put_failure;
+
+	/* get peer info if available */
+	if (ops->cee_peer_getpg) {
+		struct cee_pg pg;
+		err = ops->cee_peer_getpg(netdev, &pg);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_CEE_PEER_PG, sizeof(pg), &pg);
+	}
+
+	if (ops->cee_peer_getpfc) {
+		struct cee_pfc pfc;
+		err = ops->cee_peer_getpfc(netdev, &pfc);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_CEE_PEER_PFC, sizeof(pfc), &pfc);
+	}
+
+	if (ops->peer_getappinfo && ops->peer_getapptable) {
+		err = dcbnl_build_peer_app(netdev, skb, DCB_ATTR_CEE_PEER_APP);
+		if (err)
+			goto nla_put_failure;
+	}
+
+	nla_nest_end(skb, cee);
+	nlmsg_end(skb, nlh);
+
+	return rtnl_unicast(skb, &init_net, pid);
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+nlmsg_failure:
+	kfree_skb(skb);
+	return -1;
+}
+
 static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1641,6 +1703,10 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_setfeatcfg(netdev, tb, pid, nlh->nlmsg_seq,
 				       nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_CEE_GET:
+		ret = dcbnl_cee_get(netdev, tb, pid, nlh->nlmsg_seq,
+				    nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}
-- 
1.7.3.5




