From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 3/3] netlink: use a statically allocated nl_table instead
Date: Sun,  2 Sep 2007 03:45:59 +0800
Message-ID: <11886759772663-git-send-email-crquan@gmail.com>
References: <1188675959178-git-send-email-crquan@gmail.com>
 <11886759682348-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932119AbXIATrP@vger.kernel.org>
In-Reply-To: <11886759682348-git-send-email-crquan@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if the table is always fixed size with MAX_LINKS entries, why not use a statically
allocated table straightforwardly?

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/netlink/af_netlink.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ac3b100..c527f87 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -115,7 +115,7 @@ struct netlink_table {
 	int registered;
 };
 
-static struct netlink_table *nl_table;
+static struct netlink_table nl_table[MAX_LINKS];
 
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 
@@ -1894,10 +1894,6 @@ static int __init netlink_proto_init(void)
 
 	BUILD_BUG_ON(sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb));
 
-	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);
-	if (!nl_table)
-		goto panic;
-
 	if (num_physpages >= (128 * 1024))
 		limit = num_physpages >> (21 - PAGE_SHIFT);
 	else
@@ -1915,8 +1911,7 @@ static int __init netlink_proto_init(void)
 			while (i-- > 0)
 				nl_pid_hash_free(nl_table[i].hash.table,
 						 1 * sizeof(*hash->table));
-			kfree(nl_table);
-			goto panic;
+			goto out;
 		}
 		memset(hash->table, 0, 1 * sizeof(*hash->table));
 		hash->max_shift = order;
@@ -1933,8 +1928,6 @@ static int __init netlink_proto_init(void)
 	rtnetlink_init();
 out:
 	return err;
-panic:
-	panic("netlink_init: Cannot allocate nl_table\n");
 }
 
 core_initcall(netlink_proto_init);
-- 
1.5.3.rc7
