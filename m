From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next 2/3] dcbnl: adding DCBX feature flags get-set
Date: Tue, 21 Dec 2010 21:32:53 +0200
Message-ID: <1292959973.7142.131.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, lucy.liu@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1248 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845Ab0LUTdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:33:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a pair of set-get functions to dcbnl for setting the negotiation
flags of the various DCB features. The user sets these flags (enable,
advertise, willing) for each feature to be used by the device DCBX
engine. The 'get' routine returns which of the features is enabled
after the negotiation.

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 include/linux/dcbnl.h |   33 ++++++++++++
 include/net/dcbnl.h   |    2 +
 net/dcb/dcbnl.c       |  133 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 168 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 974fd1e..681c1f2 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -52,6 +52,8 @@ struct dcbmsg {
  * @DCB_CMD_SAPP: set application protocol configuration
  * @DCB_CMD_GDCBX: get DCBX engine configuration
  * @DCB_CMD_SDCBX: set DCBX engine configuration
+ * @DCB_CMD_GFEATCFG: get DCBX features flags
+ * @DCB_CMD_SFEATCFG: set DCBX features negotiation flags
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -88,6 +90,9 @@ enum dcbnl_commands {
 	DCB_CMD_GDCBX,
 	DCB_CMD_SDCBX,
 
+	DCB_CMD_GFEATCFG,
+	DCB_CMD_SFEATCFG,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -108,6 +113,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
  * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
  * @DCB_ATTR_DCBX: DCBX engine configuration in the device (NLA_U8)
+ * @DCB_ATTR_FEATCFG: DCBX features flags (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -125,6 +131,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_BCN,
 	DCB_ATTR_APP,
 	DCB_ATTR_DCBX,
+	DCB_ATTR_FEATCFG,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -372,4 +379,30 @@ enum dcbnl_app_attrs {
 	DCB_APP_ATTR_MAX = __DCB_APP_ATTR_ENUM_MAX - 1,
 };
 
+/**
+ * enum dcbnl_featcfg_attrs - features conifiguration flags
+ *
+ * @DCB_FEATCFG_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_FEATCFG_ATTR_ALL: (NLA_FLAG) all features configuration attributes
+ * @DCB_FEATCFG_ATTR_PG: (NLA_U8) configuration flags for priority groups
+ * @DCB_FEATCFG_ATTR_PFC: (NLA_U8) configuration flags for priority
+ *                                 flow control
+ * @DCB_FEATCFG_ATTR_APP: (NLA_U8) configuration flags for application TLV
+ *
+ */
+#define DCB_FEATCFG_ENABLE	0x01	/* enable feature */
+#define DCB_FEATCFG_ADVERTISE	0x02	/* advertise feature */
+#define DCB_FEATCFG_WILLING	0x04	/* feature is willing */
+#define DCB_FEATCFG_ERROR	0x08	/* error in feature resolution */
+enum dcbnl_featcfg_attrs {
+	DCB_FEATCFG_ATTR_UNDEFINED,
+	DCB_FEATCFG_ATTR_ALL,
+	DCB_FEATCFG_ATTR_PG,
+	DCB_FEATCFG_ATTR_PFC,
+	DCB_FEATCFG_ATTR_APP,
+
+	__DCB_FEATCFG_ATTR_ENUM_MAX,
+	DCB_FEATCFG_ATTR_MAX = __DCB_FEATCFG_ATTR_ENUM_MAX - 1,
+};
+
 #endif /* __LINUX_DCBNL_H__ */
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index f03079f..92735af 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -52,6 +52,8 @@ struct dcbnl_rtnl_ops {
 	u8   (*getapp)(struct net_device *, u8, u16);
 	u8   (*getdcbx)(struct net_device *);
 	u8   (*setdcbx)(struct net_device *, u8);
+	u8   (*getfeatcfg)(struct net_device *, int, u8 *);
+	u8   (*setfeatcfg)(struct net_device *, int, u8);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 44e4237..d066c62 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -67,6 +67,7 @@ static const struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_BCN]         = {.type = NLA_NESTED},
 	[DCB_ATTR_APP]         = {.type = NLA_NESTED},
 	[DCB_ATTR_DCBX]        = {.type = NLA_U8},
+	[DCB_ATTR_FEATCFG]     = {.type = NLA_NESTED},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -169,6 +170,14 @@ static const struct nla_policy dcbnl_app_nest[DCB_APP_ATTR_MAX + 1] = {
 	[DCB_APP_ATTR_PRIORITY]     = {.type = NLA_U8},
 };
 
+/* DCB number of traffic classes nested attributes. */
+static const struct nla_policy dcbnl_featcfg_nest[DCB_FEATCFG_ATTR_MAX + 1] = {
+	[DCB_FEATCFG_ATTR_ALL]      = {.type = NLA_FLAG},
+	[DCB_FEATCFG_ATTR_PG]       = {.type = NLA_U8},
+	[DCB_FEATCFG_ATTR_PFC]      = {.type = NLA_U8},
+	[DCB_FEATCFG_ATTR_APP]      = {.type = NLA_U8},
+};
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)
@@ -1152,6 +1161,122 @@ static int dcbnl_setdcbx(struct net_device *netdev, struct nlattr **tb,
 	return ret;
 }
 
+static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlattr **tb,
+			    u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *dcbnl_skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1], *nest;
+	u8 value;
+	int ret = -EINVAL;
+	int i;
+	int getall = 0;
+
+	if (!tb[DCB_ATTR_FEATCFG] || !netdev->dcbnl_ops->getfeatcfg)
+		return ret;
+
+	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
+			       dcbnl_featcfg_nest);
+	if (ret) {
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb) {
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
+
+	dcb = NLMSG_DATA(nlh);
+	dcb->dcb_family = AF_UNSPEC;
+	dcb->cmd = DCB_CMD_GFEATCFG;
+
+	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_FEATCFG);
+	if (!nest) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	if (data[DCB_FEATCFG_ATTR_ALL])
+		getall = 1;
+
+	for (i = DCB_FEATCFG_ATTR_ALL+1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
+		if (!getall && !data[i])
+			continue;
+
+		ret = netdev->dcbnl_ops->getfeatcfg(netdev, i, &value);
+		if (!ret) {
+			ret = nla_put_u8(dcbnl_skb, i, value);
+
+			if (ret) {
+				nla_nest_cancel(dcbnl_skb, nest);
+				ret = -EINVAL;
+				goto err;
+			}
+		} else
+			goto err;
+	}
+	nla_nest_end(dcbnl_skb, nest);
+
+	nlmsg_end(dcbnl_skb, nlh);
+
+	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
+	if (ret) {
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	return 0;
+nlmsg_failure:
+err:
+	kfree_skb(dcbnl_skb);
+err_out:
+	return ret;
+}
+
+static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
+			    u32 pid, u32 seq, u16 flags)
+{
+	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1];
+	int ret = -EINVAL;
+	u8 value;
+	int i;
+
+	if (!tb[DCB_ATTR_FEATCFG] || !netdev->dcbnl_ops->setfeatcfg)
+		return ret;
+
+	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
+			       dcbnl_featcfg_nest);
+
+	if (ret) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	for (i = DCB_FEATCFG_ATTR_ALL+1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
+		if (data[i] == NULL)
+			continue;
+
+		value = nla_get_u8(data[i]);
+
+		ret = netdev->dcbnl_ops->setfeatcfg(netdev, i, value);
+
+		if (ret)
+			goto operr;
+	}
+
+operr:
+	ret = dcbnl_reply(!!ret, RTM_SETDCB, DCB_CMD_SFEATCFG,
+			  DCB_ATTR_FEATCFG, pid, seq, flags);
+
+err:
+	return ret;
+}
+
 static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1265,6 +1390,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_setdcbx(netdev, tb, pid, nlh->nlmsg_seq,
 				    nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_GFEATCFG:
+		ret = dcbnl_getfeatcfg(netdev, tb, pid, nlh->nlmsg_seq,
+				       nlh->nlmsg_flags);
+		goto out;
+	case DCB_CMD_SFEATCFG:
+		ret = dcbnl_setfeatcfg(netdev, tb, pid, nlh->nlmsg_seq,
+				       nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}
-- 
1.7.1




