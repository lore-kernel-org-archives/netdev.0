From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [net-next-2.6 PATCH v2 1/4] dcbnl: adding DCBX engine
 capability
Date: Thu, 30 Dec 2010 18:26:48 +0200
Message-ID: <1293726408.29378.92.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"John Fastabend" <john.r.fastabend@intel.com>, lucy.liu@intel.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3117 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601Ab0L3Q1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 11:27:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding an optional DCBX capability and a pair for get-set routines for
setting the device DCBX mode. The DCBX capability is a bit field of
supported attributes. The user is expected to set the DCBX mode with a
subset of the advertised attributes.

This patch is dependent on the following patches:
[net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
[net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
[net-next-2.6 PATCH 3/3] net_dcb: add application notifiers

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 include/linux/dcbnl.h |   43 +++++++++++++++++++++++++++++++++++++++++++
 include/net/dcbnl.h   |    5 +++++
 net/dcb/dcbnl.c       |   43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 9071e1c..dd5c84e 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -124,6 +124,8 @@ struct dcbmsg {
  * @DCB_CMD_SAPP: set application protocol configuration
  * @DCB_CMD_IEEE_SET: set IEEE 802.1Qaz configuration
  * @DCB_CMD_IEEE_GET: get IEEE 802.1Qaz configuration
+ * @DCB_CMD_GDCBX: get DCBX engine configuration
+ * @DCB_CMD_SDCBX: set DCBX engine configuration
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -160,6 +162,9 @@ enum dcbnl_commands {
 	DCB_CMD_IEEE_SET,
 	DCB_CMD_IEEE_GET,
 
+	DCB_CMD_GDCBX,
+	DCB_CMD_SDCBX,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -180,6 +185,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
  * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
  * @DCB_ATTR_IEEE: IEEE 802.1Qaz supported attributes (NLA_NESTED)
+ * @DCB_ATTR_DCBX: DCBX engine configuration in the device (NLA_U8)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -200,6 +206,8 @@ enum dcbnl_attrs {
 	/* IEEE std attributes */
 	DCB_ATTR_IEEE,
 
+	DCB_ATTR_DCBX,
+
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
 };
@@ -359,6 +367,8 @@ enum dcbnl_tc_attrs {
  * @DCB_CAP_ATTR_GSP: (NLA_U8) device supports group strict priority
  * @DCB_CAP_ATTR_BCN: (NLA_U8) device supports Backwards Congestion
  *                             Notification
+ * @DCB_CAP_ATTR_DCBX: (NLA_U8) device supports DCBX engine
+ *
  */
 enum dcbnl_cap_attrs {
 	DCB_CAP_ATTR_UNDEFINED,
@@ -370,12 +380,45 @@ enum dcbnl_cap_attrs {
 	DCB_CAP_ATTR_PFC_TCS,
 	DCB_CAP_ATTR_GSP,
 	DCB_CAP_ATTR_BCN,
+	DCB_CAP_ATTR_DCBX,
 
 	__DCB_CAP_ATTR_ENUM_MAX,
 	DCB_CAP_ATTR_MAX = __DCB_CAP_ATTR_ENUM_MAX - 1,
 };
 
 /**
+ * DCBX capability flags
+ *
+ * @DCB_CAP_DCBX_HOST: DCBX negotiation is performed by the host LLDP agent.
+ *                     'set' routines are used to configure the device with
+ *                     the negotiated parameters
+ *
+ * @DCB_CAP_DCBX_LLD_MANAGED: DCBX negotiation is not performed in the host but
+ *                            by another entity
+ *                            'get' routines are used to retrieve the
+ *                            negotiated parameters
+ *                            'set' routines can be used to set the initial
+ *                            negotiation configuration
+ *
+ * @DCB_CAP_DCBX_VER_CEE: for a non-host DCBX engine, indicates the engine
+ *                        supports the CEE protocol flavor
+ *
+ * @DCB_CAP_DCBX_VER_IEEE: for a non-host DCBX engine, indicates the engine
+ *                         supports the IEEE protocol flavor
+ *
+ * @DCB_CAP_DCBX_STATIC: for a non-host DCBX engine, indicates the engine
+ *                       supports static configuration (i.e no actual
+ *                       negotiation is performed negotiated parameters equal
+ *                       the initial configuration)
+ *
+ */
+#define DCB_CAP_DCBX_HOST		0x01
+#define DCB_CAP_DCBX_LLD_MANAGED	0x02
+#define DCB_CAP_DCBX_VER_CEE		0x04
+#define DCB_CAP_DCBX_VER_IEEE		0x08
+#define DCB_CAP_DCBX_STATIC		0x10
+
+/**
  * enum dcbnl_numtcs_attrs - number of traffic classes
  *
  * @DCB_NUMTCS_ATTR_UNDEFINED: unspecified attribute to catch errors
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index ab7d623..c65347b 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -70,6 +70,11 @@ struct dcbnl_rtnl_ops {
 	void (*setbcnrp)(struct net_device *, int, u8);
 	u8   (*setapp)(struct net_device *, u8, u16, u8);
 	u8   (*getapp)(struct net_device *, u8, u16);
+
+	/* DCBX configuration */
+	u8   (*getdcbx)(struct net_device *);
+	u8   (*setdcbx)(struct net_device *, u8);
+
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5f1d0ee..4603691 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -68,6 +68,7 @@ static const struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_BCN]         = {.type = NLA_NESTED},
 	[DCB_ATTR_APP]         = {.type = NLA_NESTED},
 	[DCB_ATTR_IEEE]	       = {.type = NLA_NESTED},
+	[DCB_ATTR_DCBX]        = {.type = NLA_U8},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -124,6 +125,7 @@ static const struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
 	[DCB_CAP_ATTR_PFC_TCS] = {.type = NLA_U8},
 	[DCB_CAP_ATTR_GSP]     = {.type = NLA_U8},
 	[DCB_CAP_ATTR_BCN]     = {.type = NLA_U8},
+	[DCB_CAP_ATTR_DCBX]    = {.type = NLA_U8},
 };
 
 /* DCB capabilities nested attributes. */
@@ -1271,6 +1273,39 @@ nlmsg_failure:
 	return -1;
 }
 
+/* DCBX configuration */
+static int dcbnl_getdcbx(struct net_device *netdev, struct nlattr **tb,
+			 u32 pid, u32 seq, u16 flags)
+{
+	int ret = -EINVAL;
+
+	if (!netdev->dcbnl_ops->getdcbx)
+		return ret;
+
+	ret = dcbnl_reply(netdev->dcbnl_ops->getdcbx(netdev), RTM_GETDCB,
+			  DCB_CMD_GDCBX, DCB_ATTR_DCBX, pid, seq, flags);
+
+	return ret;
+}
+
+static int dcbnl_setdcbx(struct net_device *netdev, struct nlattr **tb,
+			 u32 pid, u32 seq, u16 flags)
+{
+	int ret = -EINVAL;
+	u8 value;
+
+	if (!tb[DCB_ATTR_DCBX] || !netdev->dcbnl_ops->setdcbx)
+		return ret;
+
+	value = nla_get_u8(tb[DCB_ATTR_DCBX]);
+
+	ret = dcbnl_reply(netdev->dcbnl_ops->setdcbx(netdev, value),
+			  RTM_SETDCB, DCB_CMD_SDCBX, DCB_ATTR_DCBX,
+			  pid, seq, flags);
+
+	return ret;
+}
+
 static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1384,6 +1419,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_ieee_get(netdev, tb, pid, nlh->nlmsg_seq,
 				 nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_GDCBX:
+		ret = dcbnl_getdcbx(netdev, tb, pid, nlh->nlmsg_seq,
+				    nlh->nlmsg_flags);
+		goto out;
+	case DCB_CMD_SDCBX:
+		ret = dcbnl_setdcbx(netdev, tb, pid, nlh->nlmsg_seq,
+				    nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}
-- 
1.7.1




