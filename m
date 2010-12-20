From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
Date: Mon, 20 Dec 2010 12:50:13 -0800
Message-ID: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21946 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933077Ab0LTUxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 15:53:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IEEE8021Qaz is the IEEE standard version of CEE. The
standard has had enough significant changes from the CEE
version that many of the CEE attributes have no meaning
in the new spec or do not easily map to IEEE standards.

Rather then attempt to create a complicated mapping
between CEE and IEEE standards this patch adds a nested
IEEE attribute to the list of DCB attributes. The policy
is,

	[DCB_ATTR_IFNAME]
	[DCB_ATTR_STATE]
	...
	[DCB_ATTR_IEEE]
		[DCB_ATTR_IEEE_ETS]
		[DCB_ATTR_IEEE_PFC]
		[DCB_ATTR_IEEE_APP_TABLE]
			[DCB_ATTR_IEEE_APP]
			...

The following dcbnl_rtnl_ops routines were added to handle
the IEEE standard,

	int (*ieee_getets) (struct net_device *, struct ieee_ets *);
	int (*ieee_setets) (struct net_device *, struct ieee_ets *);
	int (*ieee_getpfc) (struct net_device *, struct ieee_pfc *);
	int (*ieee_setpfc) (struct net_device *, struct ieee_pfc *);
	int (*ieee_getapp) (struct net_device *, struct dcb_app *);
	int (*ieee_setapp) (struct net_device *, struct dcb_app *);

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/dcbnl.h |   95 ++++++++++++++++++++++++++++++++++++
 include/net/dcbnl.h   |   11 ++++
 net/dcb/dcbnl.c       |  131 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 237 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 8723491..3706a13 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -22,6 +22,76 @@
 
 #include <linux/types.h>
 
+/* IEEE 802.1Qaz std supported values */
+#define IEEE_8021QAZ_MAX_TCS	8
+
+/* This structure contains the IEEE 802.1Qaz ETS managed object
+ *
+ * @ets_cap: indicates supported capacity of ets feature
+ * @cbs: credit based shaper ets algorithm supported
+ * @tc_tx_bw: tc tx bandwidth indexed by traffic class
+ * @tc_rx_bw: tc rx bandwidth indexed by traffic class
+ * @tc_tsa: TSA Assignment table, indexed by traffic class
+ * @prio_tc: priority assignment table mapping 8021Qp to traffic class
+ *
+ * ----
+ *  TSA Assignment 8 bit identifiers
+ *	0	strict priority
+ *	1	credit-based shaper
+ *	2	enhanced transmission selection
+ *	3-254	reserved
+ *	255	vendor specific
+ */
+struct ieee_ets {
+	__u8	ets_cap;
+	__u8	cbs;
+	__u8	tc_tx_bw[IEEE_8021QAZ_MAX_TCS];
+	__u8	tc_rx_bw[IEEE_8021QAZ_MAX_TCS];
+	__u8	tc_tsa[IEEE_8021QAZ_MAX_TCS];
+	__u8	prio_tc[IEEE_8021QAZ_MAX_TCS];
+};
+
+/* This structure contains the IEEE 802.1Qaz PFC managed object
+ *
+ * @pfc_cap: Indicates the number of traffic classes on the local device
+ *	     that may simultaneously have PFC enabled.
+ * @pfc_en: bitmap indicating pfc enabled traffic classes
+ * @mbc: enable macsec bypass capability
+ * @delay: the allowance made for a round-trip propagation delay of the
+ *	   link in bits.
+ * @requests: count of the sent pfc frames
+ * @indications: count of the received pfc frames
+ */
+struct ieee_pfc {
+	__u8	pfc_cap;
+	__u8	pfc_en;
+	__u8	mbc;
+	__u16	delay;
+	__u64	requests[IEEE_8021QAZ_MAX_TCS];
+	__u64	indications[IEEE_8021QAZ_MAX_TCS];
+};
+
+/* This structure contains the IEEE 802.1Qaz APP managed object
+ *
+ * @selector: protocol identifier type
+ * @protocol: protocol of type indicated
+ * @priority: 3-bit unsigned integer indicating priority
+ *
+ * ----
+ *  Selector field values
+ *	0	Reserved
+ *	1	Ethertype
+ *	2	Well known port number over TCP or SCTP
+ *	3	Well known port number over UDP or DCCP
+ *	4	Well known port number over TCP, SCTP, UDP, or DCCP
+ *	5-7	Reserved
+ */
+struct dcb_app {
+	__u8	selector;
+	__u32	protocol;
+	__u8	priority;
+};
+
 struct dcbmsg {
 	__u8               dcb_family;
 	__u8               cmd;
@@ -50,6 +120,8 @@ struct dcbmsg {
  * @DCB_CMD_SBCN: get backward congestion notification configration.
  * @DCB_CMD_GAPP: get application protocol configuration
  * @DCB_CMD_SAPP: set application protocol configuration
+ * @DCB_CMD_IEEE_SET: set IEEE 802.1Qaz configuration
+ * @DCB_CMD_IEEE_GET: get IEEE 802.1Qaz configuration
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -83,6 +155,9 @@ enum dcbnl_commands {
 	DCB_CMD_GAPP,
 	DCB_CMD_SAPP,
 
+	DCB_CMD_IEEE_SET,
+	DCB_CMD_IEEE_GET,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -102,6 +177,7 @@ enum dcbnl_commands {
  * @DCB_ATTR_CAP: DCB capabilities of the device (NLA_NESTED)
  * @DCB_ATTR_NUMTCS: number of traffic classes supported (NLA_NESTED)
  * @DCB_ATTR_BCN: backward congestion notification configuration (NLA_NESTED)
+ * @DCB_ATTR_IEEE: IEEE 802.1Qaz supported attributes (NLA_NESTED)
  */
 enum dcbnl_attrs {
 	DCB_ATTR_UNDEFINED,
@@ -119,10 +195,29 @@ enum dcbnl_attrs {
 	DCB_ATTR_BCN,
 	DCB_ATTR_APP,
 
+	/* IEEE std attributes */
+	DCB_ATTR_IEEE,
+
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
 };
 
+enum ieee_attrs {
+	DCB_ATTR_IEEE_UNSPEC,
+	DCB_ATTR_IEEE_ETS,
+	DCB_ATTR_IEEE_PFC,
+	DCB_ATTR_IEEE_APP_TABLE,
+	__DCB_ATTR_IEEE_MAX
+};
+#define DCB_ATTR_IEEE_MAX (__DCB_ATTR_IEEE_MAX - 1)
+
+enum ieee_attrs_app {
+	DCB_ATTR_IEEE_APP_UNSPEC,
+	DCB_ATTR_IEEE_APP,
+	__DCB_ATTR_IEEE_APP_MAX
+};
+#define DCB_ATTR_IEEE_APP_MAX (__DCB_ATTR_IEEE_APP_MAX - 1)
+
 /**
  * enum dcbnl_pfc_attrs - DCB Priority Flow Control user priority nested attrs
  *
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index b36ac7e..e2d841e 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -20,11 +20,22 @@
 #ifndef __NET_DCBNL_H__
 #define __NET_DCBNL_H__
 
+#include <linux/dcbnl.h>
+
 /*
  * Ops struct for the netlink callbacks.  Used by DCB-enabled drivers through
  * the netdevice struct.
  */
 struct dcbnl_rtnl_ops {
+	/* IEEE 802.1Qaz std */
+	int (*ieee_getets) (struct net_device *, struct ieee_ets *);
+	int (*ieee_setets) (struct net_device *, struct ieee_ets *);
+	int (*ieee_getpfc) (struct net_device *, struct ieee_pfc *);
+	int (*ieee_setpfc) (struct net_device *, struct ieee_pfc *);
+	int (*ieee_getapp) (struct net_device *, struct dcb_app *);
+	int (*ieee_setapp) (struct net_device *, struct dcb_app *);
+
+	/* CEE std */
 	u8   (*getstate)(struct net_device *);
 	u8   (*setstate)(struct net_device *, u8);
 	void (*getpermhwaddr)(struct net_device *, u8 *);
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 19ac2b9..2ff9084 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -66,6 +66,7 @@ static const struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_PFC_STATE]   = {.type = NLA_U8},
 	[DCB_ATTR_BCN]         = {.type = NLA_NESTED},
 	[DCB_ATTR_APP]         = {.type = NLA_NESTED},
+	[DCB_ATTR_IEEE]	       = {.type = NLA_NESTED},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -167,6 +168,17 @@ static const struct nla_policy dcbnl_app_nest[DCB_APP_ATTR_MAX + 1] = {
 	[DCB_APP_ATTR_PRIORITY]     = {.type = NLA_U8},
 };
 
+/* IEEE 802.1Qaz nested attributes. */
+static const struct nla_policy dcbnl_ieee_policy[DCB_ATTR_IEEE_MAX + 1] = {
+	[DCB_ATTR_IEEE_ETS]	    = {.len = sizeof(struct ieee_ets)},
+	[DCB_ATTR_IEEE_PFC]	    = {.len = sizeof(struct ieee_pfc)},
+	[DCB_ATTR_IEEE_APP_TABLE]   = {.type = NLA_NESTED},
+};
+
+static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
+	[DCB_ATTR_IEEE_APP]	    = {.len = sizeof(struct dcb_app)},
+};
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)
@@ -1118,6 +1130,117 @@ err:
 	return ret;
 }
 
+/* Handle IEEE 802.1Qaz SET commands. If any requested operation can not
+ * be completed the entire msg is aborted and error value is returned.
+ * No attempt is made to reconcile the case where only part of the
+ * cmd can be completed.
+ */
+static int dcbnl_ieee_set(struct net_device *netdev, struct nlattr **tb,
+			  u32 pid, u32 seq, u16 flags)
+{
+	const struct dcbnl_rtnl_ops *ops = netdev->dcbnl_ops;
+	struct nlattr *ieee[DCB_ATTR_IEEE_MAX + 1];
+	int err = -EOPNOTSUPP;
+
+	if (!ops)
+		goto err;
+
+	err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX,
+			       tb[DCB_ATTR_IEEE], dcbnl_ieee_policy);
+	if (err)
+		goto err;
+
+	if (ieee[DCB_ATTR_IEEE_ETS] && ops->ieee_setets) {
+		struct ieee_ets *ets = nla_data(ieee[DCB_ATTR_IEEE_ETS]);
+		err = ops->ieee_setets(netdev, ets);
+		if (err)
+			goto err;
+	}
+
+	if (ieee[DCB_ATTR_IEEE_PFC] && ops->ieee_setets) {
+		struct ieee_pfc *pfc = nla_data(ieee[DCB_ATTR_IEEE_PFC]);
+		err = ops->ieee_setpfc(netdev, pfc);
+		if (err)
+			goto err;
+	}
+
+	if (ieee[DCB_ATTR_IEEE_APP_TABLE] && ops->ieee_setapp) {
+		struct nlattr *attr;
+		int rem;
+
+		nla_for_each_nested(attr, ieee[DCB_ATTR_IEEE_APP_TABLE], rem) {
+			struct dcb_app *app_data;
+			if (nla_type(attr) != DCB_ATTR_IEEE_APP)
+				continue;
+			app_data = nla_data(attr);
+			err = ops->ieee_setapp(netdev, app_data);
+			if (err)
+				goto err;
+		}
+	}
+
+err:
+	dcbnl_reply(err, RTM_SETDCB, DCB_CMD_IEEE_SET, DCB_ATTR_IEEE,
+		    pid, seq, flags);
+	return err;
+}
+
+
+/* Handle IEEE 802.1Qaz GET commands. */
+static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
+			  u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *ieee;
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
+	dcb->cmd = DCB_CMD_IEEE_GET;
+
+	NLA_PUT_STRING(skb, DCB_ATTR_IFNAME, netdev->name);
+
+	ieee = nla_nest_start(skb, DCB_ATTR_IEEE);
+	if (!ieee)
+		goto nla_put_failure;
+
+	if (ops->ieee_getets) {
+		struct ieee_ets ets;
+		err = ops->ieee_getets(netdev, &ets);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_IEEE_ETS, sizeof(ets), &ets);
+	}
+
+	if (ops->ieee_getpfc) {
+		struct ieee_pfc pfc;
+		err = ops->ieee_getpfc(netdev, &pfc);
+		if (!err)
+			NLA_PUT(skb, DCB_ATTR_IEEE_PFC, sizeof(pfc), &pfc);
+	}
+
+	nla_nest_end(skb, ieee);
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
@@ -1223,6 +1346,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_setapp(netdev, tb, pid, nlh->nlmsg_seq,
 		                   nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_IEEE_SET:
+		ret = dcbnl_ieee_set(netdev, tb, pid, nlh->nlmsg_seq,
+				 nlh->nlmsg_flags);
+		goto out;
+	case DCB_CMD_IEEE_GET:
+		ret = dcbnl_ieee_get(netdev, tb, pid, nlh->nlmsg_seq,
+				 nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}

