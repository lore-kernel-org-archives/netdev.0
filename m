From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 10/27] RDMA/netlink: Reduce indirection access to cb_table
Date: Mon,  3 Jul 2017 09:28:13 +0300
Message-ID: <20170703062830.30361-11-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59436 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751902AbdGCG3T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:19 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Introduce intermediate variable to store access to fields
of cb_table.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/netlink.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index f98f9fe86d0a..6c3bb2693afa 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -157,12 +157,15 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	unsigned int op = RDMA_NL_GET_OP(type);
 	struct netlink_callback cb = {};
 	struct netlink_dump_control c = {};
+	const struct rdma_nl_cbs *cb_table;
 	int ret;
 
 	if (!is_nl_valid(index, op))
 		return -EINVAL;
 
-	if ((rdma_nl_types[index].cb_table[op].flags & RDMA_NL_ADMIN_PERM) &&
+	cb_table = rdma_nl_types[type].cb_table;
+
+	if ((cb_table[op].flags & RDMA_NL_ADMIN_PERM) &&
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
@@ -174,14 +177,14 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	    (index == RDMA_NL_LS && op == RDMA_NL_LS_OP_SET_TIMEOUT)) {
 		cb.skb = skb;
 		cb.nlh = nlh;
-		cb.dump = rdma_nl_types[index].cb_table[op].dump;
+		cb.dump = cb_table[op].dump;
 		return cb.dump(skb, &cb);
 	} else {
-		c.dump = rdma_nl_types[index].cb_table[op].dump;
+		c.dump = cb_table[op].dump;
 		return netlink_dump_start(nls, skb, nlh, &c);
 	}
-	if (rdma_nl_types[index].cb_table[op].doit)
-		ret = rdma_nl_types[index].cb_table[op].doit(skb, nlh, extack);
+	if (cb_table[op].doit)
+		ret = cb_table[op].doit(skb, nlh, extack);
 	return ret;
 
 }
-- 
2.13.2
