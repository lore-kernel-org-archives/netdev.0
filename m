From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 02/19] RDMA/netlink: Simplify the put_msg and put_attr
Date: Wed, 21 Jun 2017 09:05:11 +0300
Message-ID: <20170621060528.3752-3-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.99]:57628 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751071AbdFUGFi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:05:38 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Reuse standard macros to cancel the netlink message
in case of error.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/netlink.c | 31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index f0d482009c69..96057e722123 100644
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
2.13.1
