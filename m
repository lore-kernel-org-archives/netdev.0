From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next 1/3] dcbnl: adding DCBX engine capability
Date: Tue, 21 Dec 2010 21:32:43 +0200
Message-ID: <1292959963.7142.130.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, lucy.liu@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4636 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab0LUTdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:33:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding an optional DCBX capability and a pair for get-set routines for
setting the device DCBX mode. The DCBX capability is a bit field of
supported attributes. The user is expected to set the DCBX mode with a
subset of the advertised attributes.


Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 include/linux/dcbnl.h |   17 +++++++++++++++++
 include/net/dcbnl.h   |    2 ++
 net/dcb/dcbnl.c       |   42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 8723491..974fd1e 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -50,6 +50,8 @@ struct dcbmsg {
  * @DCB_CMD_SBCN: get backward congestion notification configration.
  * @DCB_CMD_GAPP: get application protocol configuration
  * @DCB_CMD_SAPP: set application protocol configuration
+ * @DCB_CMD_GDCBX: get DCBX engine configuration
+ * @DCB_CMD_SDCBX: set DCBX engine configuration
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -83,6 +85,9 @@ enum dcbnl_commands {
 	DCB_CMD_GAPP,
 	DCB_CMD_SAPP,
 
+	DCB_CMD_GDCBX,
+	DCB_CMD_SDCBX,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -102,6 +107,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_CAP: DCB capabilities of the device (NLA_NESTED)
  * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
  * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
+ * @DCB_ATTR_DCBX: DCBX engine configuration in the device (NLA_U8)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -118,6 +124,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_NUMTCS,
 	DCB_ATTR_BCN,
 	DCB_ATTR_APP,
+	DCB_ATTR_DCBX,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -262,6 +269,8 @@ enum dcbnl_tc_attrs {
  * @DCB_CAP_ATTR_GSP: (NLA_U8) device supports group strict priority
  * @DCB_CAP_ATTR_BCN: (NLA_U8) device supports Backwards Congestion
  *                             Notification
+ * @DCB_CAP_ATTR_DCBX: (NLA_U8) device supports DCBX engine
+ *
  */
 enum dcbnl_cap_attrs {
 	DCB_CAP_ATTR_UNDEFINED,
@@ -273,11 +282,19 @@ enum dcbnl_cap_attrs {
 	DCB_CAP_ATTR_PFC_TCS,
 	DCB_CAP_ATTR_GSP,
 	DCB_CAP_ATTR_BCN,
+	DCB_CAP_ATTR_DCBX,
 
 	__DCB_CAP_ATTR_ENUM_MAX,
 	DCB_CAP_ATTR_MAX = __DCB_CAP_ATTR_ENUM_MAX - 1,
 };
 
+/* DCBX capabilities */
+#define DCB_CAP_DCBX_HOST	0x01 /* host based DCBX engine support */
+#define DCB_CAP_DCBX_HW		0x02 /* HW DCBX engine support */
+#define DCB_CAP_DCBX_VER_CEE	0x04 /* HW DCBX supports CEE protocol */
+#define DCB_CAP_DCBX_VER_IEEE	0x08 /* HW DCBX supports IEEE protocol */
+#define DCB_CAP_DCBX_STATIC	0x10 /* HW DCBX supports static config */
+
 /**
  * enum dcbnl_numtcs_attrs - number of traffic classes
  *
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index b36ac7e..f03079f 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -50,6 +50,8 @@ struct dcbnl_rtnl_ops {
 	void (*setbcnrp)(struct net_device *, int, u8);
 	u8   (*setapp)(struct net_device *, u8, u16, u8);
 	u8   (*getapp)(struct net_device *, u8, u16);
+	u8   (*getdcbx)(struct net_device *);
+	u8   (*setdcbx)(struct net_device *, u8);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 19ac2b9..44e4237 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -66,6 +66,7 @@ static const struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_PFC_STATE]   = {.type = NLA_U8},
 	[DCB_ATTR_BCN]         = {.type = NLA_NESTED},
 	[DCB_ATTR_APP]         = {.type = NLA_NESTED},
+	[DCB_ATTR_DCBX]        = {.type = NLA_U8},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -122,6 +123,7 @@ static const struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
 	[DCB_CAP_ATTR_PFC_TCS] = {.type = NLA_U8},
 	[DCB_CAP_ATTR_GSP]     = {.type = NLA_U8},
 	[DCB_CAP_ATTR_BCN]     = {.type = NLA_U8},
+	[DCB_CAP_ATTR_DCBX]    = {.type = NLA_U8},
 };
 
 /* DCB capabilities nested attributes. */
@@ -1118,6 +1120,38 @@ err:
 	return ret;
 }
 
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
@@ -1223,6 +1257,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_setapp(netdev, tb, pid, nlh->nlmsg_seq,
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




