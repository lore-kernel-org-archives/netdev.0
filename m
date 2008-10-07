From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 3/6] DCB: Add interface to query # of TCs supported
	by device
Date: Mon, 06 Oct 2008 20:06:35 -0700
Message-ID: <20081007030626.782.94017.stgit@gitlost.lost>
References: <20081007030540.782.28987.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:57665 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753450AbYJGDGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 23:06:55 -0400
In-Reply-To: <20081007030540.782.28987.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Adds interface for DCB to query (and set if supported) the number
of traffic classes currently supported by the device for the two features:
priority groups and priority flow control.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   33 +++++++++
 include/linux/dcbnl.h            |   27 ++++++++
 include/net/dcbnl.h              |    2 +
 net/dcb/dcbnl.c                  |  136 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 197 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 1e4f56f..61e7527 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -372,6 +372,35 @@ static u8 ixgbe_dcbnl_getcap(struct net_device *netdev, int capid, u8 *cap)
 	return rval;
 }
 
+static u8 ixgbe_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u8 rval = 0;
+
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		switch (tcid) {
+		case DCB_NUMTCS_ATTR_PG:
+			*num = MAX_TRAFFIC_CLASS;
+			break;
+		case DCB_NUMTCS_ATTR_PFC:
+			*num = MAX_TRAFFIC_CLASS;
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
+static u8 ixgbe_dcbnl_setnumtcs(struct net_device *netdev, int tcid, u8 num)
+{
+	return -EINVAL;
+}
+
 struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
@@ -387,6 +416,8 @@ struct dcbnl_rtnl_ops dcbnl_ops = {
 	.setpfccfg	= ixgbe_dcbnl_set_pfc_cfg,
 	.getpfccfg	= ixgbe_dcbnl_get_pfc_cfg,
 	.setall		= ixgbe_dcbnl_set_all,
-	.getcap		= ixgbe_dcbnl_getcap
+	.getcap		= ixgbe_dcbnl_getcap,
+	.getnumtcs	= ixgbe_dcbnl_getnumtcs,
+	.setnumtcs	= ixgbe_dcbnl_setnumtcs
 };
 
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 13f0c63..1077fba 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -44,6 +44,8 @@ struct dcbmsg {
  * @DCB_CMD_GPERM_HWADDR: get the permanent MAC address of the underlying
  *                        device.  Only useful when using bonding.
  * @DCB_CMD_GCAP: request the DCB capabilities of the device
+ * @DCB_CMD_GNUMTCS: get the number of traffic classes currently supported
+ * @DCB_CMD_SNUMTCS: set the number of traffic classes
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -62,6 +64,8 @@ enum dcbnl_commands {
 	DCB_CMD_SET_ALL,
 	DCB_CMD_GPERM_HWADDR,
 	DCB_CMD_GCAP,
+	DCB_CMD_GNUMTCS,
+	DCB_CMD_SNUMTCS,
 
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
@@ -81,6 +85,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_SET_ALL: bool to commit changes to hardware or not (NLA_U8)
  * @DCB_ATTR_PERM_HWADDR: MAC address of the physical device (NLA_NESTED)
  * @DCB_ATTR_CAP: DCB capabilities of the device (NLA_NESTED)
+ * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -94,6 +99,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_SET_ALL,
 	DCB_ATTR_PERM_HWADDR,
 	DCB_ATTR_CAP,
+	DCB_ATTR_NUMTCS,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -253,6 +259,27 @@ enum dcbnl_cap_attrs {
 	__DCB_CAP_ATTR_ENUM_MAX,
 	DCB_CAP_ATTR_MAX = __DCB_CAP_ATTR_ENUM_MAX - 1,
 };
+
+/**
+ * enum dcbnl_numtcs_attrs - number of traffic classes
+ *
+ * @DCB_NUMTCS_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @DCB_NUMTCS_ATTR_ALL: (NLA_FLAG) all traffic class attributes
+ * @DCB_NUMTCS_ATTR_PG: (NLA_U8) number of traffic classes used for
+ *                               priority groups
+ * @DCB_NUMTCS_ATTR_PFC: (NLA_U8) number of traffic classes which can
+ *                                support priority flow control
+ */
+enum dcbnl_numtcs_attrs {
+	DCB_NUMTCS_ATTR_UNDEFINED,
+	DCB_NUMTCS_ATTR_ALL,
+	DCB_NUMTCS_ATTR_PG,
+	DCB_NUMTCS_ATTR_PFC,
+
+	__DCB_NUMTCS_ATTR_ENUM_MAX,
+	DCB_NUMTCS_ATTR_MAX = __DCB_NUMTCS_ATTR_ENUM_MAX - 1,
+};
+
 /**
  * enum dcb_general_attr_values - general DCB attribute values
  *
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 183ed04..f0a6528 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -40,6 +40,8 @@ struct dcbnl_rtnl_ops {
 	void (*getpfccfg)(struct net_device *, int, u8 *);
 	u8   (*setall)(struct net_device *);
 	u8   (*getcap)(struct net_device *, int, u8 *);
+	u8   (*getnumtcs)(struct net_device *, int, u8 *);
+	u8   (*setnumtcs)(struct net_device *, int, u8);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 23278b7..7410296 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -98,6 +98,13 @@ static struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
 	[DCB_CAP_ATTR_BCN]     = {.type = NLA_U8},
 };
 
+/* DCB capabilities nested attributes. */
+static struct nla_policy dcbnl_numtcs_nest[DCB_NUMTCS_ATTR_MAX + 1] = {
+	[DCB_NUMTCS_ATTR_ALL]     = {.type = NLA_FLAG},
+	[DCB_NUMTCS_ATTR_PG]      = {.type = NLA_U8},
+	[DCB_NUMTCS_ATTR_PFC]     = {.type = NLA_U8},
+};
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)
@@ -325,6 +332,127 @@ err_out:
 	return -EINVAL;
 }
 
+static int dcbnl_getnumtcs(struct net_device *netdev, struct nlattr **tb,
+                           u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *dcbnl_skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1], *nest;
+	u8 value;
+	int ret = -EINVAL;
+	int i;
+	int getall = 0;
+
+	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->getnumtcs)
+		return ret;
+
+	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
+	                       dcbnl_numtcs_nest);
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
+	dcb->cmd = DCB_CMD_GNUMTCS;
+
+	nest = nla_nest_start(dcbnl_skb, DCB_ATTR_NUMTCS);
+	if (!nest) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	if (data[DCB_NUMTCS_ATTR_ALL])
+		getall = 1;
+
+	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
+		if (!getall && !data[i])
+			continue;
+
+		ret = netdev->dcbnl_ops->getnumtcs(netdev, i, &value);
+		if (!ret) {
+			ret = nla_put_u8(dcbnl_skb, i, value);
+
+			if (ret) {
+				nla_nest_cancel(dcbnl_skb, nest);
+				ret = -EINVAL;
+				goto err;
+			}
+		} else {
+			goto err;
+		}
+	}
+	nla_nest_end(dcbnl_skb, nest);
+
+	nlmsg_end(dcbnl_skb, nlh);
+
+	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
+	if (ret) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	return 0;
+nlmsg_failure:
+err:
+	kfree(dcbnl_skb);
+err_out:
+	return ret;
+}
+
+static int dcbnl_setnumtcs(struct net_device *netdev, struct nlattr **tb,
+                           u32 pid, u32 seq, u16 flags)
+{
+	struct nlattr *data[DCB_NUMTCS_ATTR_MAX + 1];
+	int ret = -EINVAL;
+	u8 value;
+	u8 status;
+	int i;
+
+	if (!tb[DCB_ATTR_NUMTCS] || !netdev->dcbnl_ops->setstate)
+		return ret;
+
+	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
+	                       dcbnl_numtcs_nest);
+
+	if (ret) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
+		if (data[i] == NULL)
+			continue;
+
+		value = nla_get_u8(data[i]);
+
+		ret = netdev->dcbnl_ops->setnumtcs(netdev, i, value);
+
+		if (ret)
+			goto err;
+	}
+
+	value = nla_get_u8(tb[DCB_ATTR_STATE]);
+
+	status = netdev->dcbnl_ops->setnumtcs(netdev, i, value);
+
+	ret = dcbnl_reply(!!status, RTM_SETDCB, DCB_CMD_SNUMTCS,
+	                  DCB_ATTR_NUMTCS, pid, seq, flags);
+
+err:
+	return ret;
+}
+
 static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
                              u32 pid, u32 seq, u16 flags, int dir)
 {
@@ -735,6 +863,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_getcap(netdev, tb, pid, nlh->nlmsg_seq,
 		                   nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_GNUMTCS:
+		ret = dcbnl_getnumtcs(netdev, tb, pid, nlh->nlmsg_seq,
+		                      nlh->nlmsg_flags);
+		goto out;
+	case DCB_CMD_SNUMTCS:
+		ret = dcbnl_setnumtcs(netdev, tb, pid, nlh->nlmsg_seq,
+		                      nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}

