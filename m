From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [net-next-2.6 PATCH v2 2/4] dcbnl: adding DCBX feature flags
 get-set
Date: Thu, 30 Dec 2010 18:26:55 +0200
Message-ID: <1293726415.29378.93.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"John Fastabend" <john.r.fastabend@intel.com>, lucy.liu@intel.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1988 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0L3Q1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 11:27:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a pair of set-get routines to dcbnl for setting the negotiation
flags of the various DCB features. Conforms to the CEE flavor of DCBX
The user sets these flags (enable, advertise, willing) for each feature
to be used by the DCBX engine. The 'get' routine returns which of the
features is enabled after the negotiation.

This patch is dependent on the following patches:
[net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
[net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
[net-next-2.6 PATCH 3/3] net_dcb: add application notifiers

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
---
 include/linux/dcbnl.h |   33 ++++++++++++
 include/net/dcbnl.h   |    3 +
 net/dcb/dcbnl.c       |  133 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 169 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index dd5c84e..18cab06 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -126,6 +126,8 @@ struct dcbmsg {
  * @DCB_CMD_IEEE_GET: get IEEE 802.1Qaz configuration
  * @DCB_CMD_GDCBX: get DCBX engine configuration
  * @DCB_CMD_SDCBX: set DCBX engine configuration
+ * @DCB_CMD_GFEATCFG: get DCBX features flags
+ * @DCB_CMD_SFEATCFG: set DCBX features negotiation flags
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -165,6 +167,9 @@ enum dcbnl_commands {
 	DCB_CMD_GDCBX,
 	DCB_CMD_SDCBX,
 
+	DCB_CMD_GFEATCFG,
+	DCB_CMD_SFEATCFG,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -186,6 +191,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
  * @DCB_ATTR_IEEE: IEEE 802.1Qaz supported attributes (NLA_NESTED)
  * @DCB_ATTR_DCBX: DCBX engine configuration in the device (NLA_U8)
+ * @DCB_ATTR_FEATCFG: DCBX features flags (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -207,6 +213,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_IEEE,
 
 	DCB_ATTR_DCBX,
+	DCB_ATTR_FEATCFG,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -495,4 +502,30 @@ enum dcbnl_app_attrs {
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
+#define DCB_FEATCFG_ERROR	0x01	/* error in feature resolution */
+#define DCB_FEATCFG_ENABLE	0x02	/* enable feature */
+#define DCB_FEATCFG_WILLING	0x04	/* feature is willing */
+#define DCB_FEATCFG_ADVERTISE	0x08	/* advertise feature */
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
index c65347b..a8e7852 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -70,11 +70,14 @@ struct dcbnl_rtnl_ops {
 	void (*setbcnrp)(struct net_device *, int, u8);
 	u8   (*setapp)(struct net_device *, u8, u16, u8);
 	u8   (*getapp)(struct net_device *, u8, u16);
+	u8   (*getfeatcfg)(struct net_device *, int, u8 *);
+	u8   (*setfeatcfg)(struct net_device *, int, u8);
 
 	/* DCBX configuration */
 	u8   (*getdcbx)(struct net_device *);
 	u8   (*setdcbx)(struct net_device *, u8);
 
+
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 4603691..b387816 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -69,6 +69,7 @@ static const struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_APP]         = {.type = NLA_NESTED},
 	[DCB_ATTR_IEEE]	       = {.type = NLA_NESTED},
 	[DCB_ATTR_DCBX]        = {.type = NLA_U8},
+	[DCB_ATTR_FEATCFG]     = {.type = NLA_NESTED},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -182,6 +183,14 @@ static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
 	[DCB_ATTR_IEEE_APP]	    = {.len = sizeof(struct dcb_app)},
 };
 
+/* DCB number of traffic classes nested attributes. */
+static const struct nla_policy dcbnl_featcfg_nest[DCB_FEATCFG_ATTR_MAX + 1] = {
+	[DCB_FEATCFG_ATTR_ALL]      = {.type = NLA_FLAG},
+	[DCB_FEATCFG_ATTR_PG]       = {.type = NLA_U8},
+	[DCB_FEATCFG_ATTR_PFC]      = {.type = NLA_U8},
+	[DCB_FEATCFG_ATTR_APP]      = {.type = NLA_U8},
+};
+
 static LIST_HEAD(dcb_app_list);
 static DEFINE_SPINLOCK(dcb_lock);
 
@@ -1306,6 +1315,122 @@ static int dcbnl_setdcbx(struct net_device *netdev, struct nlattr **tb,
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
@@ -1427,6 +1552,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
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




