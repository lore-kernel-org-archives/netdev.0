From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 02/27] RDMA/netlink: Simplify the put_msg and put_attr
Date: Mon,  3 Jul 2017 09:28:05 +0300
Message-ID: <20170703062830.30361-3-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59226 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751902AbdGCG2l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:28:41 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Reuse standard macros to cancel the netlink message
in case of error.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/netlink.c | 31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index a0e25689d3e7..19476a584de3 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -126,36 +126,23 @@ EXPORT_SYMBOL(rdma_nl_unregister);
 void *ibnl_put_msg(struct sk_buff *skb, struct nlmsghdr **nlh, int seq,
 		   int len, int client, int op, int flags)
 {
-	unsigned char *prev_tail;
-
-	prev_tail = skb_tail_pointer(skb);
-	*nlh = nlmsg_put(skb, 0, seq, RDMA_NL_GET_TYPE(client, op),
-			 len, flags);
-	if (!*nlh)
-		goto out_nlmsg_trim;
-	(*nlh)->nlmsg_len = skb_tail_pointer(skb) - prev_tail;
+	*nlh = nlmsg_put(skb, 0, seq, RDMA_NL_GET_TYPE(client, op), len, flags);
+	if (!*nlh) {
+		nlmsg_cancel(skb, *nlh);
+		return NULL;
+	}
 	return nlmsg_data(*nlh);
-
-out_nlmsg_trim:
-	nlmsg_trim(skb, prev_tail);
-	return NULL;
 }
 EXPORT_SYMBOL(ibnl_put_msg);
 
 int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
 		  int len, void *data, int type)
 {
-	unsigned char *prev_tail;
-
-	prev_tail = skb_tail_pointer(skb);
-	if (nla_put(skb, type, len, data))
-		goto nla_put_failure;
-	nlh->nlmsg_len += skb_tail_pointer(skb) - prev_tail;
+	if (nla_put(skb, type, len, data)) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
 	return 0;
-
-nla_put_failure:
-	nlmsg_trim(skb, prev_tail - nlh->nlmsg_len);
-	return -EMSGSIZE;
 }
 EXPORT_SYMBOL(ibnl_put_attr);
 
-- 
2.13.2
