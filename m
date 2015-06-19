From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH v2 net-next] macvtap: Increase limit of macvtap queues
Date: Fri, 19 Jun 2015 19:47:53 +0530
Message-ID: <1434723473-18224-1-git-send-email-pagupta@redhat.com>
Cc: kaber@trash.net, mst@redhat.com, davem@davemloft.net,
	jasowang@redhat.com, vyasevic@redhat.com,
	bhutchings@solarflare.com, therbert@google.com,
	viro@zeniv.linux.org.uk, pagupta@redhat.com,
	herbert@gondor.apana.org.au, justin@myriabit.com,
	sergei.shtylyov@cogentembedded.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macvtap should be compatible with tuntap for 
maximum number of queues. 

commit 'baf71c5c1f80d82e92924050a60b5baaf97e3094 (tuntap: 
Increase the number of queues in tun.)' removes
the limitations and increases number of queues in tuntap.
Now, Its safe to increase number of queues in Macvtap as well.

This patch also modifies 'macvtap_del_queues' function
to avoid extra memory allocation in stack.

Changes from v1->v2 :
Michael S. Tsirkin, Jason Wang  : 
                  Better way to use linked list to 
avoid use of extra memory in stack.
Sergei Shtylyov : Specify dependent commit's summary.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 drivers/net/macvtap.c      | 10 ++--------
 include/linux/if_macvlan.h |  2 +-
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 483afb1..6a64197f 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -263,27 +263,21 @@ out:
 static void macvtap_del_queues(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvtap_queue *q, *tmp, *qlist[MAX_MACVTAP_QUEUES];
-	int i, j = 0;
+	struct macvtap_queue *q, *tmp;
 
 	ASSERT_RTNL();
 	list_for_each_entry_safe(q, tmp, &vlan->queue_list, next) {
 		list_del_init(&q->next);
-		qlist[j++] = q;
 		RCU_INIT_POINTER(q->vlan, NULL);
 		if (q->enabled)
 			vlan->numvtaps--;
 		vlan->numqueues--;
+		sock_put(&q->sk);
 	}
-	for (i = 0; i < vlan->numvtaps; i++)
-		RCU_INIT_POINTER(vlan->taps[i], NULL);
 	BUG_ON(vlan->numvtaps);
 	BUG_ON(vlan->numqueues);
 	/* guarantee that any future macvtap_set_queue will fail */
 	vlan->numvtaps = MAX_MACVTAP_QUEUES;
-
-	for (--j; j >= 0; j--)
-		sock_put(&qlist[j]->sk);
 }
 
 static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 6f6929e..a4ccc31 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -29,7 +29,7 @@ struct macvtap_queue;
  * Maximum times a macvtap device can be opened. This can be used to
  * configure the number of receive queue, e.g. for multiqueue virtio.
  */
-#define MAX_MACVTAP_QUEUES	16
+#define MAX_MACVTAP_QUEUES	256
 
 #define MACVLAN_MC_FILTER_BITS	8
 #define MACVLAN_MC_FILTER_SZ	(1 << MACVLAN_MC_FILTER_BITS)
-- 
1.9.3
