From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 10/19] RDMA/netlink: Reduce indirection access to cb_table
Date: Wed, 21 Jun 2017 09:05:19 +0300
Message-ID: <20170621060528.3752-11-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57854 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751835AbdFUGGF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:06:05 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Introduce intermediate variable to store access to fields
of cb_table.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/netlink.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 34f529cc9776..73c74d1cd2a3 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -156,12 +156,15 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
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
 
@@ -173,14 +176,14 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
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
2.13.1
