From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next 01/19] RDMA/netlink: Add flag to consolidate common handing
Date: Wed, 21 Jun 2017 09:05:10 +0300
Message-ID: <20170621060528.3752-2-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621060528.3752-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add ability to provide flags to control RDMA netlink callbacks
and convert addr.c and sa_query.c to be first users of such
infrastructure. It allows to move their CAP_NET_ADMIN checks
into netlink core.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/addr.c     |  3 +--
 drivers/infiniband/core/device.c   | 12 +++++++++---
 drivers/infiniband/core/netlink.c  |  4 ++++
 drivers/infiniband/core/sa_query.c |  6 ++----
 include/rdma/rdma_netlink.h        |  6 ++++++
 5 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 02971e239a18..134d8394fca5 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -134,8 +134,7 @@ int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
 	const struct nlmsghdr *nlh = (struct nlmsghdr *)cb->nlh;
 
 	if ((nlh->nlmsg_flags & NLM_F_REQUEST) ||
-	    !(NETLINK_CB(skb).sk) ||
-	    !netlink_capable(skb, CAP_NET_ADMIN))
+	    !(NETLINK_CB(skb).sk))
 		return -EPERM;
 
 	if (ib_nl_is_good_ip_resp(nlh))
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 5c70ea49d5ad..2001dabd1444 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -1010,11 +1010,17 @@ EXPORT_SYMBOL(ib_get_net_dev_by_params);
 
 static const struct ibnl_client_cbs ibnl_ls_cb_table[] = {
 	[RDMA_NL_LS_OP_RESOLVE] = {
-		.dump = ib_nl_handle_resolve_resp},
+		.dump = ib_nl_handle_resolve_resp,
+		.flags = RDMA_NL_ADMIN_PERM,
+	},
 	[RDMA_NL_LS_OP_SET_TIMEOUT] = {
-		.dump = ib_nl_handle_set_timeout},
+		.dump = ib_nl_handle_set_timeout,
+		.flags = RDMA_NL_ADMIN_PERM,
+	},
 	[RDMA_NL_LS_OP_IP_RESOLVE] = {
-		.dump = ib_nl_handle_ip_res_resp},
+		.dump = ib_nl_handle_ip_res_resp,
+		.flags = RDMA_NL_ADMIN_PERM,
+	},
 };
 
 static int __init ib_core_init(void)
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 4fa6746a62b1..f0d482009c69 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -171,6 +171,10 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!is_nl_valid(index, op))
 		return -EINVAL;
 
+	if ((rdma_nl_types[index].cb_table[op].flags & RDMA_NL_ADMIN_PERM) &&
+	    !netlink_capable(skb, CAP_NET_ADMIN))
+		return -EPERM;
+
 	/*
 	 * For response or local service set_timeout request,
 	 * there is no need to use netlink_dump_start.
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index e335b09c022e..6e39a763b220 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -1034,8 +1034,7 @@ int ib_nl_handle_set_timeout(struct sk_buff *skb,
 	int ret;
 
 	if (!(nlh->nlmsg_flags & NLM_F_REQUEST) ||
-	    !(NETLINK_CB(skb).sk) ||
-	    !netlink_capable(skb, CAP_NET_ADMIN))
+	    !(NETLINK_CB(skb).sk))
 		return -EPERM;
 
 	ret = nla_parse(tb, LS_NLA_TYPE_MAX - 1, nlmsg_data(nlh),
@@ -1110,8 +1109,7 @@ int ib_nl_handle_resolve_resp(struct sk_buff *skb,
 	int ret;
 
 	if ((nlh->nlmsg_flags & NLM_F_REQUEST) ||
-	    !(NETLINK_CB(skb).sk) ||
-	    !netlink_capable(skb, CAP_NET_ADMIN))
+	    !(NETLINK_CB(skb).sk))
 		return -EPERM;
 
 	spin_lock_irqsave(&ib_nl_request_lock, flags);
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 761517105a36..6932b7acd3a6 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -7,6 +7,12 @@
 
 struct ibnl_client_cbs {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
+	u8 flags;
+};
+
+enum rdma_nl_flags {
+	/* Require CAP_NET_ADMIN */
+	RDMA_NL_ADMIN_PERM	= 1 << 0,
 };
 
 int rdma_nl_init(void);
-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
