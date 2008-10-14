From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/6] DCB: Add interface to query the state of PFC feature.
Date: Tue, 14 Oct 2008 12:55:19 -0700
Message-ID: <20081014195519.16879.96733.stgit@gitlost.lost>
References: <20081014195413.16879.25832.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:55714 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754797AbYJNTzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:55:42 -0400
In-Reply-To: <20081014195413.16879.25832.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Adds a netlink interface for Data Center Bridging (DCB) to get and set the enable state of the Priority Flow Control (PFC) feature.  Primarily, this is a way to turn off PFC in the driver while
DCB remains enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   16 +++++++++++++-
 include/linux/dcbnl.h            |    2 ++
 include/net/dcbnl.h              |    2 ++
 net/dcb/dcbnl.c                  |   43 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 62 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 61e7527..b750323 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -401,6 +401,18 @@ static u8 ixgbe_dcbnl_setnumtcs(struct net_device *netdev, int tcid, u8 num)
 	return -EINVAL;
 }
 
+static u8 ixgbe_dcbnl_getpfcstate(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	return !!(adapter->flags & IXGBE_FLAG_DCB_ENABLED);
+}
+
+static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
+{
+	return;
+}
+
 struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
@@ -418,6 +430,8 @@ struct dcbnl_rtnl_ops dcbnl_ops = {
 	.setall		= ixgbe_dcbnl_set_all,
 	.getcap		= ixgbe_dcbnl_getcap,
 	.getnumtcs	= ixgbe_dcbnl_getnumtcs,
-	.setnumtcs	= ixgbe_dcbnl_setnumtcs
+	.setnumtcs	= ixgbe_dcbnl_setnumtcs,
+	.getpfcstate	= ixgbe_dcbnl_getpfcstate,
+	.setpfcstate	= ixgbe_dcbnl_setpfcstate
 };
 
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 1077fba..6cc4560 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -66,6 +66,8 @@ enum dcbnl_commands {
 	DCB_CMD_GCAP,
 	DCB_CMD_GNUMTCS,
 	DCB_CMD_SNUMTCS,
+	DCB_CMD_PFC_GSTATE,
+	DCB_CMD_PFC_SSTATE,
 
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index f0a6528..c7d87ca 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -42,6 +42,8 @@ struct dcbnl_rtnl_ops {
 	u8   (*getcap)(struct net_device *, int, u8 *);
 	u8   (*getnumtcs)(struct net_device *, int, u8 *);
 	u8   (*setnumtcs)(struct net_device *, int, u8);
+	u8   (*getpfcstate)(struct net_device *);
+	void (*setpfcstate)(struct net_device *, u8);
 };
 
 #endif /* __NET_DCBNL_H__ */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 9d592b4..8c21a00 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -62,6 +62,7 @@ static struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_SET_ALL]   = {.type = NLA_U8},
 	[DCB_ATTR_PERM_HWADDR] = {.type = NLA_FLAG},
 	[DCB_ATTR_CAP]       = {.type = NLA_NESTED},
+	[DCB_ATTR_PFC_STATE] = {.type = NLA_U8},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -475,6 +476,40 @@ err:
 	return ret;
 }
 
+static int dcbnl_getpfcstate(struct net_device *netdev, struct nlattr **tb,
+                             u32 pid, u32 seq, u16 flags)
+{
+	int ret = -EINVAL;
+
+	if (!netdev->dcbnl_ops->getpfcstate)
+		return ret;
+
+	ret = dcbnl_reply(netdev->dcbnl_ops->getpfcstate(netdev), RTM_GETDCB,
+	                  DCB_CMD_PFC_GSTATE, DCB_ATTR_PFC_STATE,
+	                  pid, seq, flags);
+
+	return ret;
+}
+
+static int dcbnl_setpfcstate(struct net_device *netdev, struct nlattr **tb,
+                             u32 pid, u32 seq, u16 flags)
+{
+	int ret = -EINVAL;
+	u8 value;
+
+	if (!tb[DCB_ATTR_PFC_STATE] || !netdev->dcbnl_ops->setpfcstate)
+		return ret;
+
+	value = nla_get_u8(tb[DCB_ATTR_STATE]);
+
+	netdev->dcbnl_ops->setstate(netdev, value);
+
+	ret = dcbnl_reply(0, RTM_SETDCB, DCB_CMD_PFC_SSTATE, DCB_ATTR_PFC_STATE,
+	                  pid, seq, flags);
+
+	return ret;
+}
+
 static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
                              u32 pid, u32 seq, u16 flags, int dir)
 {
@@ -893,6 +928,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_setnumtcs(netdev, tb, pid, nlh->nlmsg_seq,
 		                      nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_PFC_GSTATE:
+		ret = dcbnl_getpfcstate(netdev, tb, pid, nlh->nlmsg_seq,
+		                        nlh->nlmsg_flags);
+		goto out;
+	case DCB_CMD_PFC_SSTATE:
+		ret = dcbnl_setpfcstate(netdev, tb, pid, nlh->nlmsg_seq,
+		                        nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}

