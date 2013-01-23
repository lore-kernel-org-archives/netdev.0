From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/2] tuntap: limit the number of flow caches
Date: Wed, 23 Jan 2013 21:59:13 +0800
Message-ID: <1358949553-30309-2-git-send-email-jasowang@redhat.com>
References: <1358949553-30309-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358949553-30309-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We create new flow caches when a new flow is identified by tuntap, This may lead
some issues:

- userspace may produce a huge amount of short live flows to exhaust host memory
- the unlimited number of flow caches may produce a long list which increase the
  time in the linear searching

Solve this by introducing a limit of total number of flow caches.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8939d21..cc09b67 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -113,6 +113,7 @@ struct tap_filter {
  * the netdevice to be fit in one page. So we can make sure the success of
  * memory allocation. TODO: increase the limit. */
 #define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
+#define MAX_TAP_FLOWS  4096
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
 
@@ -185,6 +186,7 @@ struct tun_struct {
 	unsigned int numdisabled;
 	struct list_head disabled;
 	void *security;
+	u32 flow_count;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -218,6 +220,7 @@ static struct tun_flow_entry *tun_flow_create(struct tun_struct *tun,
 		e->queue_index = queue_index;
 		e->tun = tun;
 		hlist_add_head_rcu(&e->hash_link, head);
+		++tun->flow_count;
 	}
 	return e;
 }
@@ -228,6 +231,7 @@ static void tun_flow_delete(struct tun_struct *tun, struct tun_flow_entry *e)
 		  e->rxhash, e->queue_index);
 	hlist_del_rcu(&e->hash_link);
 	kfree_rcu(e, rcu);
+	--tun->flow_count;
 }
 
 static void tun_flow_flush(struct tun_struct *tun)
@@ -317,7 +321,8 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
 		e->updated = jiffies;
 	} else {
 		spin_lock_bh(&tun->lock);
-		if (!tun_flow_find(head, rxhash))
+		if (!tun_flow_find(head, rxhash) &&
+		    tun->flow_count < MAX_TAP_FLOWS)
 			tun_flow_create(tun, head, rxhash, queue_index);
 
 		if (!timer_pending(&tun->flow_gc_timer))
-- 
1.7.1
