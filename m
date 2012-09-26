From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 11/11] infiniband: pass rdma_cm module to netlink_dump_start
Date: Wed, 26 Sep 2012 12:52:20 +0800
Message-ID: <1348635140-20225-11-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, steffen.klassert@secunet.com,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com, Gao feng <gaofeng@cn.fujitsu.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53474 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751855Ab2IZEwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 00:52:54 -0400
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use proper netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/cma.c     |    3 ++-
 drivers/infiniband/core/netlink.c |    2 ++
 include/rdma/rdma_netlink.h       |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 7172559..d1febf0 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3495,7 +3495,8 @@ out:
 }
 
 static const struct ibnl_client_cbs cma_cb_table[] = {
-	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats },
+	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats,
+				       .module = THIS_MODULE },
 };
 
 static int __init cma_init(void)
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 3ae2bfd..1468827 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -154,6 +154,8 @@ static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			{
 				struct netlink_dump_control c = {
 					.dump = client->cb_table[op].dump,
+					.done = netlink_dump_done,
+					.module = client->cb_table[op].module,
 				};
 				return netlink_dump_start(nls, skb, nlh, &c);
 			}
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 3c5363a..bd3d8b2 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -39,6 +39,7 @@ struct rdma_cm_id_stats {
 
 struct ibnl_client_cbs {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
+	struct module *module;
 };
 
 int ibnl_init(void);
-- 
1.7.7.6
