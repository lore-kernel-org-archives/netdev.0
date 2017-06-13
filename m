From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next 3/3] ip6mr: add netlink notifications on mrt6msg cache reports
Date: Tue, 13 Jun 2017 10:08:22 -0700
Message-ID: <20170613170822.16310-4-julien@arista.com>
References: <20170613170822.16310-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nikolay@cumulusnetworks.com, Julien Gomes <julien@arista.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613170822.16310-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Netlink notifications on cache reports in ip6mr, in addition to the
existing mrt6msg sent to mroute6_sk.
Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV6_MROUTE.

MSGTYPE, MIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
same data as their equivalent fields in the mrt6msg header.
PKT attribute is the packet sent to mroute6_sk, without the added
mrt6msg header.

Suggested-by: Ryan Halbrook <halbrook@arista.com>
Signed-off-by: Julien Gomes <julien@arista.com>
---
 include/uapi/linux/mroute6.h | 11 ++++++++
 net/ipv6/ip6mr.c             | 63 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/mroute6.h b/include/uapi/linux/mroute6.h
index ed5721148768..8e3c2d2c170e 100644
--- a/include/uapi/linux/mroute6.h
+++ b/include/uapi/linux/mroute6.h
@@ -133,4 +133,15 @@ struct mrt6msg {
 	struct in6_addr	im6_src, im6_dst;
 };
 
+/* ip6mr netlink cache report attributes */
+enum {
+	IP6MRA_CACHEREPORTA_MSGTYPE,
+	IP6MRA_CACHEREPORTA_MIF_ID,
+	IP6MRA_CACHEREPORTA_SRC_ADDR,
+	IP6MRA_CACHEREPORTA_DST_ADDR,
+	IP6MRA_CACHEREPORTA_PKT,
+	__IP6MRA_CACHEREPORTA_MAX
+};
+#define IP6MRA_CACHEREPORTA_MAX (__IP6MRA_CACHEREPORTA_MAX - 1)
+
 #endif /* _UAPI__LINUX_MROUTE6_H */
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 374997d26488..8667256b4343 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -116,6 +116,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 			       struct mfc6_cache *c, struct rtmsg *rtm);
 static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
 			      int cmd);
+static void mrt6msg_netlink_event(struct mr6_table *mrt, struct sk_buff *pkt);
 static int ip6mr_rtm_dumproute(struct sk_buff *skb,
 			       struct netlink_callback *cb);
 static void mroute_clean_tables(struct mr6_table *mrt, bool all);
@@ -1123,8 +1124,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 }
 
 /*
- *	Bounce a cache query up to pim6sd. We could use netlink for this but pim6sd
- *	expects the following bizarre scheme.
+ *	Bounce a cache query up to pim6sd and netlink.
  *
  *	Called under mrt_lock.
  */
@@ -1206,6 +1206,8 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 		return -EINVAL;
 	}
 
+	mrt6msg_netlink_event(mrt, skb);
+
 	/*
 	 *	Deliver to user space multicast routing algorithms
 	 */
@@ -2455,6 +2457,63 @@ static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_MROUTE, err);
 }
 
+static void mrt6msg_netlink_event(struct mr6_table *mrt, struct sk_buff *pkt)
+{
+	struct net *net = read_pnet(&mrt->net);
+	struct nlmsghdr *nlh;
+	struct rtgenmsg *rtgenm;
+	struct mrt6msg *msg;
+	struct sk_buff *skb;
+	int payloadlen;
+	int msgsize;
+
+	payloadlen = pkt->len - sizeof(struct mrt6msg);
+	msg = (struct mrt6msg *)skb_transport_header(pkt);
+	msgsize = NLMSG_ALIGN(sizeof(struct rtgenmsg))
+			+ nla_total_size(1)
+					/* IP6MRA_CACHEREPORTA_MSGTYPE */
+			+ nla_total_size(2)
+					/* IP6MRA_CACHEREPORTA_MIF_ID */
+			+ nla_total_size(sizeof(struct in6_addr))
+					/* IP6MRA_CACHEREPORTA_SRC_ADDR */
+			+ nla_total_size(sizeof(struct in6_addr))
+					/* IP6MRA_CACHEREPORTA_DST_ADDR */
+			+ nla_total_size(payloadlen)
+					/* IP6MRA_CACHEREPORTA_PKT */
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
+	rtgenm->rtgen_family = RTNL_FAMILY_IP6MR;
+	if (nla_put_u8(skb, IP6MRA_CACHEREPORTA_MSGTYPE, msg->im6_msgtype) ||
+	    nla_put_u16(skb, IP6MRA_CACHEREPORTA_MIF_ID, msg->im6_mif) ||
+	    nla_put_in6_addr(skb, IP6MRA_CACHEREPORTA_SRC_ADDR,
+			     &msg->im6_src) ||
+	    nla_put_in6_addr(skb, IP6MRA_CACHEREPORTA_DST_ADDR,
+			     &msg->im6_dst) ||
+	    nla_put(skb, IP6MRA_CACHEREPORTA_PKT, payloadlen,
+		    pkt->data + sizeof(struct mrt6msg)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_MROUTE, NULL, GFP_ATOMIC);
+	return;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+errout:
+	kfree_skb(skb);
+	rtnl_set_sk_err(net, RTNLGRP_IPV6_MROUTE, -ENOBUFS);
+}
+
 static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-- 
2.13.1
