From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 7/7] net: ipmr: add mfc newroute/delroute netlink support
Date: Thu, 26 Nov 2015 15:23:50 +0100
Message-ID: <1448547830-21716-8-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34645 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbKZOYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:08 -0500
Received: by wmvv187 with SMTP id v187so33748423wmv.1
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:07 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch adds support to add and remove MFC entries. It uses the
same attributes like the already present dump support in order to be
consistent. There's one new entry - RTA_PREFSRC, it's used to denote an
MFC_PROXY entry (see MRT_ADD_MFC vs MRT_ADD_MFC_PROXY).
The already existing infrastructure is used to create and delete the
entries, the netlink message gets converted internally to a struct mfcctl
which is used with ipmr_mfc_add/delete.
The other used attributes are:
RTA_IIF - used for mfcc_parent (when adding it's required to be valid)
RTA_SRC - used for mfcc_origin
RTA_DST - used for mfcc_mcastgrp
RTA_TABLE - the MRT table id
RTA_MULTIPATH - the "oifs" ttl array

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 129 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 129 insertions(+)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6c24a16299c7..1fa1024e23d0 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -66,6 +66,7 @@
 #include <net/netlink.h>
 #include <net/fib_rules.h>
 #include <linux/netconf.h>
+#include <net/nexthop.h>
 
 struct ipmr_rule {
 	struct fib_rule		common;
@@ -2339,6 +2340,130 @@ done:
 	return skb->len;
 }
 
+static const struct nla_policy rtm_ipmr_policy[RTA_MAX + 1] = {
+	[RTA_SRC]	= { .type = NLA_U32 },
+	[RTA_DST]	= { .type = NLA_U32 },
+	[RTA_IIF]	= { .type = NLA_U32 },
+	[RTA_TABLE]	= { .type = NLA_U32 },
+	[RTA_MULTIPATH]	= { .len = sizeof(struct rtnexthop) },
+};
+
+static bool ipmr_rtm_validate_proto(unsigned char rtm_protocol)
+{
+	switch (rtm_protocol) {
+	case RTPROT_STATIC:
+	case RTPROT_MROUTED:
+		return true;
+	}
+	return false;
+}
+
+static int ipmr_nla_get_ttls(const struct nlattr *nla, struct mfcctl *mfcc)
+{
+	struct rtnexthop *rtnh = nla_data(nla);
+	int remaining = nla_len(nla), vifi = 0;
+
+	while (rtnh_ok(rtnh, remaining)) {
+		mfcc->mfcc_ttls[vifi] = rtnh->rtnh_hops;
+		if (++vifi == MAXVIFS)
+			break;
+		rtnh = rtnh_next(rtnh, &remaining);
+	}
+
+	return remaining > 0 ? -EINVAL : vifi;
+}
+
+/* returns < 0 on error, 0 for ADD_MFC and 1 for ADD_MFC_PROXY */
+static int rtm_to_ipmr_mfcc(struct net *net, struct nlmsghdr *nlh,
+			    struct mfcctl *mfcc, int *mrtsock,
+			    struct mr_table **mrtret)
+{
+	struct net_device *dev = NULL;
+	u32 tblid = RT_TABLE_DEFAULT;
+	struct mr_table *mrt;
+	struct nlattr *attr;
+	struct rtmsg *rtm;
+	int ret, rem;
+
+	ret = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipmr_policy);
+	if (ret < 0)
+		goto out;
+	rtm = nlmsg_data(nlh);
+
+	ret = -EINVAL;
+	if (rtm->rtm_family != RTNL_FAMILY_IPMR || rtm->rtm_dst_len != 32 ||
+	    rtm->rtm_type != RTN_MULTICAST ||
+	    rtm->rtm_scope != RT_SCOPE_UNIVERSE ||
+	    !ipmr_rtm_validate_proto(rtm->rtm_protocol))
+		goto out;
+
+	memset(mfcc, 0, sizeof(*mfcc));
+	mfcc->mfcc_parent = -1;
+	ret = 0;
+	nlmsg_for_each_attr(attr, nlh, sizeof(struct rtmsg), rem) {
+		switch (nla_type(attr)) {
+		case RTA_SRC:
+			mfcc->mfcc_origin.s_addr = nla_get_be32(attr);
+			break;
+		case RTA_DST:
+			mfcc->mfcc_mcastgrp.s_addr = nla_get_be32(attr);
+			break;
+		case RTA_IIF:
+			dev = __dev_get_by_index(net, nla_get_u32(attr));
+			if (!dev) {
+				ret = -ENODEV;
+				goto out;
+			}
+			break;
+		case RTA_MULTIPATH:
+			if (ipmr_nla_get_ttls(attr, mfcc) < 0) {
+				ret = -EINVAL;
+				goto out;
+			}
+			break;
+		case RTA_PREFSRC:
+			ret = 1;
+			break;
+		case RTA_TABLE:
+			tblid = nla_get_u32(attr);
+			break;
+		}
+	}
+	mrt = ipmr_get_table(net, tblid);
+	if (!mrt) {
+		ret = -ENOENT;
+		goto out;
+	}
+	*mrtret = mrt;
+	*mrtsock = rtm->rtm_protocol == RTPROT_MROUTED ? 1 : 0;
+	if (dev)
+		mfcc->mfcc_parent = ipmr_find_vif(mrt, dev);
+
+out:
+	return ret;
+}
+
+/* takes care of both newroute and delroute */
+static int ipmr_rtm_route(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	int ret, mrtsock, parent;
+	struct mr_table *tbl;
+	struct mfcctl mfcc;
+
+	mrtsock = 0;
+	tbl = NULL;
+	ret = rtm_to_ipmr_mfcc(net, nlh, &mfcc, &mrtsock, &tbl);
+	if (ret < 0)
+		return ret;
+
+	parent = ret ? mfcc.mfcc_parent : -1;
+	if (nlh->nlmsg_type == RTM_NEWROUTE)
+		return ipmr_mfc_add(net, tbl, &mfcc, mrtsock, parent);
+	else
+		return ipmr_mfc_delete(tbl, &mfcc, parent);
+}
+
 #ifdef CONFIG_PROC_FS
 /* The /proc interfaces to multicast routing :
  * /proc/net/ip_mr_cache & /proc/net/ip_mr_vif
@@ -2692,6 +2817,10 @@ int __init ip_mr_init(void)
 #endif
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETROUTE,
 		      NULL, ipmr_rtm_dumproute, NULL);
+	rtnl_register(RTNL_FAMILY_IPMR, RTM_NEWROUTE,
+		      ipmr_rtm_route, NULL, NULL);
+	rtnl_register(RTNL_FAMILY_IPMR, RTM_DELROUTE,
+		      ipmr_rtm_route, NULL, NULL);
 	return 0;
 
 #ifdef CONFIG_IP_PIMSM_V2
-- 
2.4.3
