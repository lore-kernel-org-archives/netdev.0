From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 11/27] RDMA/netlink: Convert LS to doit callback
Date: Mon,  3 Jul 2017 09:28:14 +0300
Message-ID: <20170703062830.30361-12-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59456 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752704AbdGCG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:27 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

RDMA_NL_LS protocol is actually does not dump anything,
but sets data and it should be handled by doit callback.

This patch actually converts RDMA_NL_LS to doit callback, while
preserving IWCM and RDMA_CM flows through netlink_dump_start().

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/addr.c      |  5 ++---
 drivers/infiniband/core/core_priv.h |  9 ++++++---
 drivers/infiniband/core/device.c    |  6 +++---
 drivers/infiniband/core/netlink.c   | 28 ++++++++++------------------
 drivers/infiniband/core/sa_query.c  |  8 ++++----
 5 files changed, 25 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 2cc23a26ce4f..0b283029bc61 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -129,10 +129,9 @@ static void ib_nl_process_good_ip_rsep(const struct nlmsghdr *nlh)
 }
 
 int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
-			     struct netlink_callback *cb)
+			     struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
-	const struct nlmsghdr *nlh = (struct nlmsghdr *)cb->nlh;
-
 	if ((nlh->nlmsg_flags & NLM_F_REQUEST) ||
 	    !(NETLINK_CB(skb).sk))
 		return -EPERM;
diff --git a/drivers/infiniband/core/core_priv.h b/drivers/infiniband/core/core_priv.h
index 8733c26258b2..03e39ccaae2a 100644
--- a/drivers/infiniband/core/core_priv.h
+++ b/drivers/infiniband/core/core_priv.h
@@ -188,11 +188,14 @@ void rdma_nl_exit(void);
 int ibnl_chk_listeners(unsigned int group);
 
 int ib_nl_handle_resolve_resp(struct sk_buff *skb,
-			      struct netlink_callback *cb);
+			      struct nlmsghdr *nlh,
+			      struct netlink_ext_ack *extack);
 int ib_nl_handle_set_timeout(struct sk_buff *skb,
-			     struct netlink_callback *cb);
+			     struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack);
 int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
-			     struct netlink_callback *cb);
+			     struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack);
 
 struct ib_device *__ib_device_get_by_index(u32 ifindex);
 /* RDMA device netlink */
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 7ff65d766d86..4aaf51db528a 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -1070,15 +1070,15 @@ EXPORT_SYMBOL(ib_get_net_dev_by_params);
 
 static const struct rdma_nl_cbs ibnl_ls_cb_table[] = {
 	[RDMA_NL_LS_OP_RESOLVE] = {
-		.dump = ib_nl_handle_resolve_resp,
+		.doit = ib_nl_handle_resolve_resp,
 		.flags = RDMA_NL_ADMIN_PERM,
 	},
 	[RDMA_NL_LS_OP_SET_TIMEOUT] = {
-		.dump = ib_nl_handle_set_timeout,
+		.doit = ib_nl_handle_set_timeout,
 		.flags = RDMA_NL_ADMIN_PERM,
 	},
 	[RDMA_NL_LS_OP_IP_RESOLVE] = {
-		.dump = ib_nl_handle_ip_res_resp,
+		.doit = ib_nl_handle_ip_res_resp,
 		.flags = RDMA_NL_ADMIN_PERM,
 	},
 };
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 6c3bb2693afa..3efa161bf4a6 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -155,38 +155,30 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int type = nlh->nlmsg_type;
 	unsigned int index = RDMA_NL_GET_CLIENT(type);
 	unsigned int op = RDMA_NL_GET_OP(type);
-	struct netlink_callback cb = {};
-	struct netlink_dump_control c = {};
 	const struct rdma_nl_cbs *cb_table;
-	int ret;
 
 	if (!is_nl_valid(index, op))
 		return -EINVAL;
 
-	cb_table = rdma_nl_types[type].cb_table;
+	cb_table = rdma_nl_types[index].cb_table;
 
 	if ((cb_table[op].flags & RDMA_NL_ADMIN_PERM) &&
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	/*
-	 * For response or local service set_timeout request,
-	 * there is no need to use netlink_dump_start.
-	 */
-	if (!(nlh->nlmsg_flags & NLM_F_REQUEST) ||
-	    (index == RDMA_NL_LS && op == RDMA_NL_LS_OP_SET_TIMEOUT)) {
-		cb.skb = skb;
-		cb.nlh = nlh;
-		cb.dump = cb_table[op].dump;
-		return cb.dump(skb, &cb);
-	} else {
-		c.dump = cb_table[op].dump;
+	/* FIXME: Convert IWCM to properly handle doit callbacks */
+	if ((nlh->nlmsg_flags & NLM_F_DUMP) || index == RDMA_NL_RDMA_CM ||
+	    index == RDMA_NL_IWCM) {
+		struct netlink_dump_control c = {
+			.dump = cb_table[op].dump,
+		};
 		return netlink_dump_start(nls, skb, nlh, &c);
 	}
+
 	if (cb_table[op].doit)
-		ret = cb_table[op].doit(skb, nlh, extack);
-	return ret;
+		return cb_table[op].doit(skb, nlh, extack);
 
+	return 0;
 }
 
 /*
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 27535970a2b7..88f06f91741f 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -1022,9 +1022,9 @@ static void ib_nl_request_timeout(struct work_struct *work)
 }
 
 int ib_nl_handle_set_timeout(struct sk_buff *skb,
-			     struct netlink_callback *cb)
+			     struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
-	const struct nlmsghdr *nlh = (struct nlmsghdr *)cb->nlh;
 	int timeout, delta, abs_delta;
 	const struct nlattr *attr;
 	unsigned long flags;
@@ -1098,9 +1098,9 @@ static inline int ib_nl_is_good_resolve_resp(const struct nlmsghdr *nlh)
 }
 
 int ib_nl_handle_resolve_resp(struct sk_buff *skb,
-			      struct netlink_callback *cb)
+			      struct nlmsghdr *nlh,
+			      struct netlink_ext_ack *extack)
 {
-	const struct nlmsghdr *nlh = (struct nlmsghdr *)cb->nlh;
 	unsigned long flags;
 	struct ib_sa_query *query;
 	struct ib_mad_send_buf *send_buf;
-- 
2.13.2
