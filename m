From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: ipmr: add getlink support
Date: Wed,  7 Jun 2017 18:02:32 +0300
Message-ID: <1496847752-6935-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1496767292-7976-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, sharpd@cumulusnetworks.com,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38710 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdFGPHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 11:07:07 -0400
Received: by mail-wm0-f42.google.com with SMTP id n195so13312425wmg.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 08:07:06 -0700 (PDT)
In-Reply-To: <1496767292-7976-1-git-send-email-nikolay@cumulusnetworks.com>
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
v2: use netlink attributes for all mrtable and vif fields, and set message
    type to RTM_NEWLINK

The plan is to add full netlink control to ipmr via new/set/dellink later.
Also this would allow us to dump any number of VIFs in the future when we
remove the VIF device limit.

 include/uapi/linux/mroute.h |  42 +++++++++++++++
 net/ipv4/ipmr.c             | 126 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 168 insertions(+)

diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
index 1fe4c1e7d66e..f904367c0cee 100644
--- a/include/uapi/linux/mroute.h
+++ b/include/uapi/linux/mroute.h
@@ -110,6 +110,48 @@ struct igmpmsg {
 	struct in_addr im_src,im_dst;
 };
 
+/* ipmr netlink table attributes */
+enum {
+	IPMRA_TABLE_UNSPEC,
+	IPMRA_TABLE_ID,
+	IPMRA_TABLE_CACHE_RES_QUEUE_LEN,
+	IPMRA_TABLE_MROUTE_REG_VIF_NUM,
+	IPMRA_TABLE_MROUTE_DO_ASSERT,
+	IPMRA_TABLE_MROUTE_DO_PIM,
+	IPMRA_TABLE_VIFS,
+	__IPMRA_TABLE_MAX
+};
+#define IPMRA_TABLE_MAX (__IPMRA_TABLE_MAX - 1)
+
+/* ipmr netlink vif attribute format
+ * [ IPMRA_TABLE_VIFS ] - nested attribute
+ *   [ IPMRA_VIF ] - nested attribute
+ *     [ IPMRA_VIFA_xxx ]
+ */
+enum {
+	IPMRA_VIF_UNSPEC,
+	IPMRA_VIF,
+	__IPMRA_VIF_MAX
+};
+#define IPMRA_VIF_MAX (__IPMRA_VIF_MAX - 1)
+
+/* vif-specific attributes */
+enum {
+	IPMRA_VIFA_UNSPEC,
+	IPMRA_VIFA_IFINDEX,
+	IPMRA_VIFA_VIF_ID,
+	IPMRA_VIFA_FLAGS,
+	IPMRA_VIFA_BYTES_IN,
+	IPMRA_VIFA_BYTES_OUT,
+	IPMRA_VIFA_PACKETS_IN,
+	IPMRA_VIFA_PACKETS_OUT,
+	IPMRA_VIFA_LOCAL_ADDR,
+	IPMRA_VIFA_REMOTE_ADDR,
+	IPMRA_VIFA_PAD,
+	__IPMRA_VIFA_MAX
+};
+#define IPMRA_VIFA_MAX (__IPMRA_VIFA_MAX - 1)
+
 /* That's all usermode folks */
 
 #define MFC_ASSERT_THRESH (3*HZ)		/* Maximal freq. of asserts */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 551de4d023a8..9374b99c7c17 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2528,6 +2528,129 @@ static int ipmr_rtm_route(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return ipmr_mfc_delete(tbl, &mfcc, parent);
 }
 
+static bool ipmr_fill_table(struct mr_table *mrt, struct sk_buff *skb)
+{
+	u32 queue_len = atomic_read(&mrt->cache_resolve_queue_len);
+
+	if (nla_put_u32(skb, IPMRA_TABLE_ID, mrt->id) ||
+	    nla_put_u32(skb, IPMRA_TABLE_CACHE_RES_QUEUE_LEN, queue_len) ||
+	    nla_put_s32(skb, IPMRA_TABLE_MROUTE_REG_VIF_NUM,
+			mrt->mroute_reg_vif_num) ||
+	    nla_put_u8(skb, IPMRA_TABLE_MROUTE_DO_ASSERT,
+		       mrt->mroute_do_assert) ||
+	    nla_put_u8(skb, IPMRA_TABLE_MROUTE_DO_PIM, mrt->mroute_do_pim))
+		return false;
+
+	return true;
+}
+
+static bool ipmr_fill_vif(struct mr_table *mrt, u32 vifid, struct sk_buff *skb)
+{
+	struct nlattr *vif_nest;
+	struct vif_device *vif;
+
+	/* if the VIF doesn't exist just continue */
+	if (!VIF_EXISTS(mrt, vifid))
+		return true;
+
+	vif = &mrt->vif_table[vifid];
+	vif_nest = nla_nest_start(skb, IPMRA_VIF);
+	if (!vif_nest)
+		return false;
+	if (nla_put_u32(skb, IPMRA_VIFA_IFINDEX, vif->dev->ifindex) ||
+	    nla_put_u32(skb, IPMRA_VIFA_VIF_ID, vifid) ||
+	    nla_put_u16(skb, IPMRA_VIFA_FLAGS, vif->flags) ||
+	    nla_put_u64_64bit(skb, IPMRA_VIFA_BYTES_IN, vif->bytes_in,
+			      IPMRA_VIFA_PAD) ||
+	    nla_put_u64_64bit(skb, IPMRA_VIFA_BYTES_OUT, vif->bytes_out,
+			      IPMRA_VIFA_PAD) ||
+	    nla_put_u64_64bit(skb, IPMRA_VIFA_PACKETS_IN, vif->pkt_in,
+			      IPMRA_VIFA_PAD) ||
+	    nla_put_u64_64bit(skb, IPMRA_VIFA_PACKETS_OUT, vif->pkt_out,
+			      IPMRA_VIFA_PAD) ||
+	    nla_put_be32(skb, IPMRA_VIFA_LOCAL_ADDR, vif->local) ||
+	    nla_put_be32(skb, IPMRA_VIFA_REMOTE_ADDR, vif->remote)) {
+		nla_nest_cancel(skb, vif_nest);
+		return false;
+	}
+	nla_nest_end(skb, vif_nest);
+
+	return true;
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
+		struct ifinfomsg *hdr;
+		u32 i;
+
+		if (t < s_t)
+			goto skip_table;
+		nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+				cb->nlh->nlmsg_seq, RTM_NEWLINK,
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
+		if (!ipmr_fill_table(mrt, skb)) {
+			nlmsg_cancel(skb, nlh);
+			goto out;
+		}
+
+		vifs = nla_nest_start(skb, IPMRA_TABLE_VIFS);
+		if (!vifs) {
+			nla_nest_end(skb, af);
+			nlmsg_end(skb, nlh);
+			goto out;
+		}
+		for (i = 0; i < mrt->maxvif; i++) {
+			if (e < s_e)
+				goto skip_entry;
+			if (!ipmr_fill_vif(mrt, i, skb)) {
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
@@ -2870,6 +2993,9 @@ int __init ip_mr_init(void)
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
