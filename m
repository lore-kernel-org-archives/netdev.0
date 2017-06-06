From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipmr: add getlink support
Date: Tue,  6 Jun 2017 19:41:32 +0300
Message-ID: <1496767292-7976-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        sharpd@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:35473 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdFFQqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 12:46:16 -0400
Received: by mail-wr0-f176.google.com with SMTP id q97so56673498wrb.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 09:46:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there's no way to dump the VIF table for an ipmr table other
than the default (via proc). This is a major issue when debugging ipmr
issues and in general it is good to know which interfaces are
configured. This patch adds support for RTM_GETLINK for the ipmr family
so we can dump the VIF table and the ipmr table's current config for
each table. We're protected by rtnl so no need to acquire RCU or
mrt_lock.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
The plan is to add full netlink control to ipmr via new/set/dellink later.
Also this would allow us to dump any number of VIFs in the future when we
remove the VIF device limit.

 include/uapi/linux/mroute.h |  38 +++++++++++++++
 net/ipv4/ipmr.c             | 114 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 152 insertions(+)

diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
index 1fe4c1e7d66e..7860be2d2c25 100644
--- a/include/uapi/linux/mroute.h
+++ b/include/uapi/linux/mroute.h
@@ -110,6 +110,44 @@ struct igmpmsg {
 	struct in_addr im_src,im_dst;
 };
 
+/* netlink table attribute format */
+enum {
+	IPMR_NL_TABLE_UNSPEC,
+	IPMR_NL_TABLE,
+	IPMR_NL_TABLE_VIFS,
+	__IPMR_NL_TABLE_MAX
+};
+#define IPMR_NL_TABLE_MAX (__IPMR_NL_TABLE_MAX - 1)
+
+struct ipmr_nl_tbl {
+	__u32 id;
+	__u32 cache_resolve_queue_len;
+	int mroute_reg_vif_num;
+	__u32 unused;
+};
+
+/* netlink vif attribute format */
+enum {
+	IPMR_NL_VIF_UNSPEC,
+	IPMR_NL_VIF_ENTRY,
+	__IPMR_NL_VIF_MAX
+};
+#define IPMR_NL_VIF_MAX (__IPMR_NL_VIF_MAX - 1)
+
+struct ipmr_nl_vif {
+	unsigned long bytes_in;
+	unsigned long bytes_out;
+	unsigned long packets_in;
+	unsigned long packets_out;
+	unsigned long rate_limit;
+	__u32 ifindex;
+	__u16 vif_id;
+	__u16 flags;
+	__be32 local;
+	__be32 remote;
+	__u8 threshold;
+};
+
 /* That's all usermode folks */
 
 #define MFC_ASSERT_THRESH (3*HZ)		/* Maximal freq. of asserts */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 551de4d023a8..8ec88e50f7ad 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2528,6 +2528,117 @@ static int ipmr_rtm_route(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return ipmr_mfc_delete(tbl, &mfcc, parent);
 }
 
+static int ipmr_fill_vif(struct mr_table *mrt, int vifid, struct sk_buff *skb)
+{
+	struct vif_device *vif = &mrt->vif_table[vifid];
+	struct ipmr_nl_vif nlvif;
+
+	/* previous existence check should've confirmed it but in case it's
+	 * missing warn and do not signal error so the caller can move on
+	 */
+	if (WARN_ON(!vif->dev))
+		return 0;
+
+	memset(&nlvif, 0, sizeof(nlvif));
+	nlvif.ifindex = vif->dev->ifindex;
+	nlvif.vif_id = vifid;
+	nlvif.flags = vif->flags;
+	nlvif.threshold = vif->threshold;
+	nlvif.local = vif->local;
+	nlvif.remote = vif->remote;
+	nlvif.bytes_in = vif->bytes_in;
+	nlvif.bytes_out = vif->bytes_out;
+	nlvif.packets_in = vif->pkt_in;
+	nlvif.packets_out = vif->pkt_out;
+	nlvif.rate_limit = vif->rate_limit;
+
+	return nla_put(skb, IPMR_NL_VIF_ENTRY, sizeof(nlvif), &nlvif);
+}
+
+static int ipmr_rtm_dumplink(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nlmsghdr *nlh = NULL;
+	unsigned int t = 0, s_t;
+	unsigned int e = 0, s_e;
+	struct mr_table *mrt;
+
+	s_t = cb->args[0];
+	s_e = cb->args[1];
+
+	ipmr_for_each_table(mrt, net) {
+		struct nlattr *vifs, *af;
+		struct ipmr_nl_tbl tbl;
+		struct ifinfomsg *hdr;
+		u32 queue_len;
+		int i;
+
+		if (t < s_t)
+			goto skip_table;
+		nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+				cb->nlh->nlmsg_seq, RTM_GETLINK,
+				sizeof(*hdr), NLM_F_MULTI);
+		if (!nlh)
+			break;
+
+		hdr = nlmsg_data(nlh);
+		memset(hdr, 0, sizeof(*hdr));
+		hdr->ifi_family = RTNL_FAMILY_IPMR;
+
+		af = nla_nest_start(skb, IFLA_AF_SPEC);
+		if (!af) {
+			nlmsg_cancel(skb, nlh);
+			goto out;
+		}
+
+		if (!s_e) {
+			memset(&tbl, 0, sizeof(tbl));
+			tbl.id = mrt->id;
+			queue_len = atomic_read(&mrt->cache_resolve_queue_len);
+			tbl.cache_resolve_queue_len = queue_len;
+			tbl.mroute_reg_vif_num = mrt->mroute_reg_vif_num;
+			if (nla_put(skb, IPMR_NL_TABLE, sizeof(tbl), &tbl)) {
+				nlmsg_cancel(skb, nlh);
+				goto out;
+			}
+		}
+
+		vifs = nla_nest_start(skb, IPMR_NL_TABLE_VIFS);
+		if (!vifs) {
+			nla_nest_end(skb, af);
+			nlmsg_end(skb, nlh);
+			goto out;
+		}
+		for (i = 0; i < mrt->maxvif; i++) {
+			if (!VIF_EXISTS(mrt, i))
+				continue;
+			if (e < s_e)
+				goto skip_entry;
+			if (ipmr_fill_vif(mrt, i, skb)) {
+				nla_nest_end(skb, vifs);
+				nla_nest_end(skb, af);
+				nlmsg_end(skb, nlh);
+				goto out;
+			}
+skip_entry:
+			e++;
+		}
+		s_e = 0;
+		e = 0;
+		nla_nest_end(skb, vifs);
+		nla_nest_end(skb, af);
+		nlmsg_end(skb, nlh);
+skip_table:
+		t++;
+	}
+
+out:
+	cb->args[1] = e;
+	cb->args[0] = t;
+
+	return skb->len;
+}
+
 #ifdef CONFIG_PROC_FS
 /* The /proc interfaces to multicast routing :
  * /proc/net/ip_mr_cache & /proc/net/ip_mr_vif
@@ -2870,6 +2981,9 @@ int __init ip_mr_init(void)
 		      ipmr_rtm_route, NULL, NULL);
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_DELROUTE,
 		      ipmr_rtm_route, NULL, NULL);
+
+	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETLINK,
+		      NULL, ipmr_rtm_dumplink, NULL);
 	return 0;
 
 #ifdef CONFIG_IP_PIMSM_V2
-- 
2.1.4
