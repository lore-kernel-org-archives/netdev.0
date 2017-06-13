From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next 2/3] ipmr: add netlink notifications on igmpmsg cache reports
Date: Tue, 13 Jun 2017 10:08:21 -0700
Message-ID: <20170613170822.16310-3-julien@arista.com>
References: <20170613170822.16310-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nikolay@cumulusnetworks.com, Julien Gomes <julien@arista.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613170822.16310-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Netlink notifications on cache reports in ipmr, in addition to the
existing igmpmsg sent to mroute_sk.
Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV4_MROUTE.

MSGTYPE, VIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
same data as their equivalent fields in the igmpmsg header.
PKT attribute is the packet sent to mroute_sk, without the added igmpmsg
header.

Suggested-by: Ryan Halbrook <halbrook@arista.com>
Signed-off-by: Julien Gomes <julien@arista.com>
---
 include/uapi/linux/mroute.h | 11 ++++++++
 net/ipv4/ipmr.c             | 63 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
index f904367c0cee..f6f9e01ee734 100644
--- a/include/uapi/linux/mroute.h
+++ b/include/uapi/linux/mroute.h
@@ -152,6 +152,17 @@ enum {
 };
 #define IPMRA_VIFA_MAX (__IPMRA_VIFA_MAX - 1)
 
+/* ipmr netlink cache report attributes */
+enum {
+	IPMRA_CACHEREPORTA_MSGTYPE,
+	IPMRA_CACHEREPORTA_VIF_ID,
+	IPMRA_CACHEREPORTA_SRC_ADDR,
+	IPMRA_CACHEREPORTA_DST_ADDR,
+	IPMRA_CACHEREPORTA_PKT,
+	__IPMRA_CACHEREPORTA_MAX
+};
+#define IPMRA_CACHEREPORTA_MAX (__IPMRA_CACHEREPORTA_MAX - 1)
+
 /* That's all usermode folks */
 
 #define MFC_ASSERT_THRESH (3*HZ)		/* Maximal freq. of asserts */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9374b99c7c17..6d1f4fae3749 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -109,6 +109,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm);
 static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
 				 int cmd);
+static void igmpmsg_netlink_event(struct mr_table *mrt, struct sk_buff *pkt);
 static void mroute_clean_tables(struct mr_table *mrt, bool all);
 static void ipmr_expire_process(unsigned long arg);
 
@@ -993,8 +994,7 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 	}
 }
 
-/* Bounce a cache query up to mrouted. We could use netlink for this but mrouted
- * expects the following bizarre scheme.
+/* Bounce a cache query up to mrouted and netlink.
  *
  * Called under mrt_lock.
  */
@@ -1060,6 +1060,8 @@ static int ipmr_cache_report(struct mr_table *mrt,
 		return -EINVAL;
 	}
 
+	igmpmsg_netlink_event(mrt, skb);
+
 	/* Deliver to mrouted */
 	ret = sock_queue_rcv_skb(mroute_sk, skb);
 	rcu_read_unlock();
@@ -2341,6 +2343,63 @@ static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
 		rtnl_set_sk_err(net, RTNLGRP_IPV4_MROUTE, err);
 }
 
+static void igmpmsg_netlink_event(struct mr_table *mrt, struct sk_buff *pkt)
+{
+	struct net *net = read_pnet(&mrt->net);
+	struct nlmsghdr *nlh;
+	struct rtgenmsg *rtgenm;
+	struct igmpmsg *msg;
+	struct sk_buff *skb;
+	int payloadlen;
+	int msgsize;
+
+	payloadlen = pkt->len - sizeof(struct igmpmsg);
+	msg = (struct igmpmsg *)skb_network_header(pkt);
+	msgsize = NLMSG_ALIGN(sizeof(struct rtgenmsg))
+			+ nla_total_size(1)
+					/* IPMRA_CACHEREPORTA_MSGTYPE */
+			+ nla_total_size(1)
+					/* IPMRA_CACHEREPORTA_VIF_ID */
+			+ nla_total_size(4)
+					/* IPMRA_CACHEREPORTA_SRC_ADDR */
+			+ nla_total_size(4)
+					/* IPMRA_CACHEREPORTA_DST_ADDR */
+			+ nla_total_size(payloadlen)
+					/* IPMRA_CACHEREPORTA_PKT */
+			;
+
+	skb = nlmsg_new(msgsize, GFP_ATOMIC);
+	if (!skb)
+		goto errout;
+
+	nlh = nlmsg_put(skb, 0, 0, RTM_NEWCACHEREPORT,
+			sizeof(struct rtgenmsg), 0);
+	if (!nlh)
+		goto errout;
+	rtgenm = nlmsg_data(nlh);
+	rtgenm->rtgen_family = RTNL_FAMILY_IPMR;
+	if (nla_put_u8(skb, IPMRA_CACHEREPORTA_MSGTYPE, msg->im_msgtype) ||
+	    nla_put_u8(skb, IPMRA_CACHEREPORTA_VIF_ID, msg->im_vif) ||
+	    nla_put_in_addr(skb, IPMRA_CACHEREPORTA_SRC_ADDR,
+			    msg->im_src.s_addr) ||
+	    nla_put_in_addr(skb, IPMRA_CACHEREPORTA_DST_ADDR,
+			    msg->im_dst.s_addr) ||
+	    nla_put(skb, IPMRA_CACHEREPORTA_PKT, payloadlen,
+		    pkt->data + sizeof(struct igmpmsg)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV4_MROUTE, NULL, GFP_ATOMIC);
+	return;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+errout:
+	kfree_skb(skb);
+	rtnl_set_sk_err(net, RTNLGRP_IPV4_MROUTE, -ENOBUFS);
+}
+
 static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-- 
2.13.1
