From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 09/27] RDMA/netlink: Add and implement doit netlink callback
Date: Mon,  3 Jul 2017 09:28:12 +0300
Message-ID: <20170703062830.30361-10-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59416 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752674AbdGCG3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:16 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

The .doit callback is used by netlink core to differentiate
between get and set operations. Common convention is to use
that call for command operations like (SET, ADD, e.t.c.) and/or
access without NLF_M_DUMP flag.

This commit adds proper declaration and implementation
to RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/netlink.c | 19 ++++++++++++++-----
 include/rdma/rdma_netlink.h       |  2 ++
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 4d8c8b5583c6..f98f9fe86d0a 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -76,9 +76,13 @@ static bool is_nl_msg_valid(unsigned int type, unsigned int op)
 
 static bool is_nl_valid(unsigned int type, unsigned int op)
 {
-	if (!is_nl_msg_valid(type, op) ||
-	    !rdma_nl_types[type].cb_table ||
-	    !rdma_nl_types[type].cb_table[op].dump)
+	const struct rdma_nl_cbs *cb_table;
+
+	if (!is_nl_msg_valid(type, op))
+		return false;
+
+	cb_table = rdma_nl_types[type].cb_table;
+	if (!cb_table || (!cb_table[op].dump && !cb_table[op].doit))
 		return false;
 	return true;
 }
@@ -153,6 +157,7 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	unsigned int op = RDMA_NL_GET_OP(type);
 	struct netlink_callback cb = {};
 	struct netlink_dump_control c = {};
+	int ret;
 
 	if (!is_nl_valid(index, op))
 		return -EINVAL;
@@ -171,10 +176,14 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		cb.nlh = nlh;
 		cb.dump = rdma_nl_types[index].cb_table[op].dump;
 		return cb.dump(skb, &cb);
+	} else {
+		c.dump = rdma_nl_types[index].cb_table[op].dump;
+		return netlink_dump_start(nls, skb, nlh, &c);
 	}
+	if (rdma_nl_types[index].cb_table[op].doit)
+		ret = rdma_nl_types[index].cb_table[op].doit(skb, nlh, extack);
+	return ret;
 
-	c.dump = rdma_nl_types[index].cb_table[op].dump;
-	return netlink_dump_start(nls, skb, nlh, &c);
 }
 
 /*
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 17565a2765c4..b8b3528ebc08 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -6,6 +6,8 @@
 #include <uapi/rdma/rdma_netlink.h>
 
 struct rdma_nl_cbs {
+	int (*doit)(struct sk_buff *skb, struct nlmsghdr *nlh,
+		    struct netlink_ext_ack *extack);
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
 	u8 flags;
 };
-- 
2.13.2
