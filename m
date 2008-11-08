From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 2/7] DCB: Add interface to query for the DCB
	capabilities of an device.
Date: Fri, 07 Nov 2008 16:51:55 -0800
Message-ID: <20081108005134.17939.27522.stgit@gitlost.lost>
References: <20081108005042.17939.47091.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:49258 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752430AbYKHAwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 19:52:16 -0500
In-Reply-To: <20081108005042.17939.47091.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Adds to the netlink interface for Data Center Bridging (DCB), allowing the DCB capabilities supported by a device to be queried.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   42 +++++++++++++++++++
 include/linux/dcbnl.h            |   37 +++++++++++++++++
 include/net/dcbnl.h              |    1 
 net/dcb/dcbnl.c                  |   82 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 161 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 5915ad3..1e4f56f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -333,6 +333,45 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	return ret;
 }
 
+static u8 ixgbe_dcbnl_getcap(struct net_device *netdev, int capid, u8 *cap)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u8 rval = 0;
+
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		switch (capid) {
+		case DCB_CAP_ATTR_PG:
+			*cap = true;
+			break;
+		case DCB_CAP_ATTR_PFC:
+			*cap = true;
+			break;
+		case DCB_CAP_ATTR_UP2TC:
+			*cap = false;
+			break;
+		case DCB_CAP_ATTR_PG_TCS:
+			*cap = 0x80;
+			break;
+		case DCB_CAP_ATTR_PFC_TCS:
+			*cap = 0x80;
+			break;
+		case DCB_CAP_ATTR_GSP:
+			*cap = true;
+			break;
+		case DCB_CAP_ATTR_BCN:
+			*cap = false;
+			break;
+		default:
+			rval = -EINVAL;
+			break;
+		}
+	} else {
+		rval = -EINVAL;
+	}
+
+	return rval;
+}
+
 struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
@@ -347,6 +386,7 @@ struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getpgbwgcfgrx	= ixgbe_dcbnl_get_pg_bwg_cfg_rx,
 	.setpfccfg	= ixgbe_dcbnl_set_pfc_cfg,
 	.getpfccfg	= ixgbe_dcbnl_get_pfc_cfg,
-	.setall		= ixgbe_dcbnl_set_all
+	.setall		= ixgbe_dcbnl_set_all,
+	.getcap		= ixgbe_dcbnl_getcap
 };
 
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 32d32c1..13f0c63 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -43,6 +43,7 @@ struct dcbmsg {
  * @DCB_CMD_SET_ALL: apply all changes to the underlying device
  * @DCB_CMD_GPERM_HWADDR: get the permanent MAC address of the underlying
  *                        device.  Only useful when using bonding.
+ * @DCB_CMD_GCAP: request the DCB capabilities of the device
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -60,6 +61,7 @@ enum dcbnl_commands {
 
 	DCB_CMD_SET_ALL,
 	DCB_CMD_GPERM_HWADDR,
+	DCB_CMD_GCAP,
 
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
@@ -78,6 +80,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_PG_CFG: priority group configuration (NLA_NESTED)
  * @DCB_ATTR_SET_ALL: bool to commit changes to hardware or not (NLA_U8)
  * @DCB_ATTR_PERM_HWADDR: MAC address of the physical device (NLA_NESTED)
+ * @DCB_ATTR_CAP: DCB capabilities of the device (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -90,6 +93,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_PG_CFG,
 	DCB_ATTR_SET_ALL,
 	DCB_ATTR_PERM_HWADDR,
+	DCB_ATTR_CAP,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -217,6 +221,39 @@ enum dcbnl_tc_attrs {
 };
 
 /**
+ * enum dcbnl_cap_attrs - DCB Capability attributes
+ *
+ * @DCB_CAP_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_CAP_ATTR_ALL: (NLA_FLAG) all capability parameters
+ * @DCB_CAP_ATTR_PG: (NLA_U8) device supports Priority Groups
+ * @DCB_CAP_ATTR_PFC: (NLA_U8) device supports Priority Flow Control
+ * @DCB_CAP_ATTR_UP2TC: (NLA_U8) device supports user priority to
+ *                               traffic class mapping
+ * @DCB_CAP_ATTR_PG_TCS: (NLA_U8) bitmap where each bit represents a
+ *                                number of traffic classes the device
+ *                                can be configured to use for Priority Groups
+ * @DCB_CAP_ATTR_PFC_TCS: (NLA_U8) bitmap where each bit represents a
+ *                                 number of traffic classes the device can be
+ *                                 configured to use for Priority Flow Control
+ * @DCB_CAP_ATTR_GSP: (NLA_U8) device supports group strict priority
+ * @DCB_CAP_ATTR_BCN: (NLA_U8) device supports Backwards Congestion
+ *                             Notification
+ */
+enum dcbnl_cap_attrs {
+	DCB_CAP_ATTR_UNDEFINED,
+	DCB_CAP_ATTR_ALL,
+	DCB_CAP_ATTR_PG,
+	DCB_CAP_ATTR_PFC,
+	DCB_CAP_ATTR_UP2TC,
+	DCB_CAP_ATTR_PG_TCS,
+	DCB_CAP_ATTR_PFC_TCS,
+	DCB_CAP_ATTR_GSP,
+	DCB_CAP_ATTR_BCN,
+
+	__DCB_CAP_ATTR_ENUM_MAX,
+	DCB_CAP_ATTR_MAX = __DCB_CAP_ATTR_ENUM_MAX - 1,
+};
+/**
  * enum dcb_general_attr_values - general DCB attribute values
  *
  * @DCB_ATTR_UNDEFINED: value used to indicate an attribute is not supported
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 0ef0c5a..183ed04 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -39,6 +39,7 @@ struct dcbnl_rtnl_ops {
 	void (*setpfccfg)(struct net_device *, int, u8);
 	void (*getpfccfg)(struct net_device *, int, u8 *);
 	u8   (*setall)(struct net_device *);
+	u8   (*getcap)(struct net_device *, int, u8 *);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 516e8be..de61d64 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -61,6 +61,7 @@ static struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_PG_CFG]    = {.type = NLA_NESTED},
 	[DCB_ATTR_SET_ALL]   = {.type = NLA_U8},
 	[DCB_ATTR_PERM_HWADDR] = {.type = NLA_FLAG},
+	[DCB_ATTR_CAP]       = {.type = NLA_NESTED},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -107,6 +108,17 @@ static struct nla_policy dcbnl_tc_param_nest[DCB_TC_ATTR_PARAM_MAX + 1] = {
 	[DCB_TC_ATTR_PARAM_ALL]             = {.type = NLA_FLAG},
 };
 
+/* DCB capabilities nested attributes. */
+static struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
+	[DCB_CAP_ATTR_ALL]     = {.type = NLA_FLAG},
+	[DCB_CAP_ATTR_PG]      = {.type = NLA_U8},
+	[DCB_CAP_ATTR_PFC]     = {.type = NLA_U8},
+	[DCB_CAP_ATTR_UP2TC]   = {.type = NLA_U8},
+	[DCB_CAP_ATTR_PG_TCS]  = {.type = NLA_U8},
+	[DCB_CAP_ATTR_PFC_TCS] = {.type = NLA_U8},
+	[DCB_CAP_ATTR_GSP]     = {.type = NLA_U8},
+	[DCB_CAP_ATTR_BCN]     = {.type = NLA_U8},
+};
 
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
@@ -269,6 +281,72 @@ err_out:
 	return -EINVAL;
 }
 
+static int dcbnl_getcap(struct net_device *netdev, struct nlattr **tb,
+                        u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *dcbnl_skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *data[DCB_CAP_ATTR_MAX + 1], *nest;
+	u8 value;
+	int ret = -EINVAL;
+	int i;
+	int getall = 0;
+
+	if (!tb[DCB_ATTR_CAP] || !netdev->dcbnl_ops->getcap)
+		return ret;
+
+	ret = nla_parse_nested(data, DCB_CAP_ATTR_MAX, tb[DCB_ATTR_CAP],
+	                       dcbnl_cap_nest);
+	if (ret)
+		goto err_out;
+
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		goto err_out;
+
+	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
+
+	dcb = NLMSG_DATA(nlh);
+	dcb->dcb_family = AF_UNSPEC;
+	dcb->cmd = DCB_CMD_GCAP;
+
+	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_CAP);
+	if (!nest)
+		goto err;
+
+	if (data[DCB_CAP_ATTR_ALL])
+		getall = 1;
+
+	for (i = DCB_CAP_ATTR_ALL+1; i <= DCB_CAP_ATTR_MAX; i++) {
+		if (!getall && !data[i])
+			continue;
+
+		if (!netdev->dcbnl_ops->getcap(netdev, i, &value)) {
+			ret = nla_put_u8(dcbnl_skb, i, value);
+
+			if (ret) {
+				nla_nest_cancel(dcbnl_skb, nest);
+				goto err;
+			}
+		}
+	}
+	nla_nest_end(dcbnl_skb, nest);
+
+	nlmsg_end(dcbnl_skb, nlh);
+
+	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
+	if (ret)
+		goto err;
+
+	return 0;
+nlmsg_failure:
+err:
+	kfree(dcbnl_skb);
+err_out:
+	return -EINVAL;
+}
+
 static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
                              u32 pid, u32 seq, u16 flags, int dir)
 {
@@ -675,6 +753,10 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_pgrx_setcfg(netdev, tb, pid, nlh->nlmsg_seq,
 		                        nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_GCAP:
+		ret = dcbnl_getcap(netdev, tb, pid, nlh->nlmsg_seq,
+		                   nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}

