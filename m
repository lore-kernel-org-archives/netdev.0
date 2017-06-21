From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next 09/19] RDMA/netlink: Add and implement doit netlink callback
Date: Wed, 21 Jun 2017 09:05:18 +0300
Message-ID: <20170621060528.3752-10-leon@kernel.org>
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

The .doit callback is used by netlink core to differentiate
between get and set operations. Common convention is to use
that call for command operations like (SET, ADD, e.t.c.) and/or
access without NLF_M_DUMP flag.

This commit adds proper declaration and implementation
to RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/netlink.c | 19 ++++++++++++++-----
 include/rdma/rdma_netlink.h       |  2 ++
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 14b64e4d1e06..34f529cc9776 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -75,9 +75,13 @@ static bool is_nl_msg_valid(unsigned int type, unsigned int op)
 
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
@@ -152,6 +156,7 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	unsigned int op = RDMA_NL_GET_OP(type);
 	struct netlink_callback cb = {};
 	struct netlink_dump_control c = {};
+	int ret;
 
 	if (!is_nl_valid(index, op))
 		return -EINVAL;
@@ -170,10 +175,14 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
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
index 8feeb899e2b2..d6a481880f41 100644
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
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
