From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 09/10] can: use __dev_get_by_index instead of dev_get_by_index to find interface
Date: Tue, 14 Jan 2014 15:41:08 +0800
Message-ID: <1389685269-18600-10-git-send-email-ying.xue@windriver.com>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As cgw_create_job() is always under rtnl_lock protection,
__dev_get_by_index() instead of dev_get_by_index() should be used to
find interface handler in it having us avoid to change interface
reference counter.

Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/can/gw.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/can/gw.c b/net/can/gw.c
index 88c8a39..ac31891 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -839,21 +839,21 @@ static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh)
 	if (!gwj->ccgw.src_idx || !gwj->ccgw.dst_idx)
 		goto out;
 
-	gwj->src.dev = dev_get_by_index(&init_net, gwj->ccgw.src_idx);
+	gwj->src.dev = __dev_get_by_index(&init_net, gwj->ccgw.src_idx);
 
 	if (!gwj->src.dev)
 		goto out;
 
 	if (gwj->src.dev->type != ARPHRD_CAN)
-		goto put_src_out;
+		goto out;
 
-	gwj->dst.dev = dev_get_by_index(&init_net, gwj->ccgw.dst_idx);
+	gwj->dst.dev = __dev_get_by_index(&init_net, gwj->ccgw.dst_idx);
 
 	if (!gwj->dst.dev)
-		goto put_src_out;
+		goto out;
 
 	if (gwj->dst.dev->type != ARPHRD_CAN)
-		goto put_src_dst_out;
+		goto out;
 
 	gwj->limit_hops = limhops;
 
@@ -862,11 +862,6 @@ static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh)
 	err = cgw_register_filter(gwj);
 	if (!err)
 		hlist_add_head_rcu(&gwj->list, &cgw_list);
-
-put_src_dst_out:
-	dev_put(gwj->dst.dev);
-put_src_out:
-	dev_put(gwj->src.dev);
 out:
 	if (err)
 		kmem_cache_free(cgw_cache, gwj);
-- 
1.7.9.5
