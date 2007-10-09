From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 1/3] [NET_BATCH] Introduce batching interface
	Rev2.5
Date: Tue, 09 Oct 2007 18:10:47 -0400
Message-ID: <1191967847.5324.31.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lFjLhOTK04XVIGkh1uLA"
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


--=-lFjLhOTK04XVIGkh1uLA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch introduces the netdevice interface for batching.

cheers,
jamal

--=-lFjLhOTK04XVIGkh1uLA
Content-Disposition: attachment; filename=01-introduce-batching-interface.patch
Content-Type: text/x-patch; name=01-introduce-batching-interface.patch;
	charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_BATCH] Introduce batching interface

This patch introduces the netdevice interface for batching.

BACKGROUND
---------

A driver dev->hard_start_xmit() has 4 typical parts:
a) packet formating (example vlan, mss, descriptor counting etc)
b) chip specific formatting
c) enqueueing the packet on a DMA ring
d) IO operations to complete packet transmit, tell DMA engine to chew on,
tx completion interupts, set last tx time, etc

[For code cleanliness/readability sake, regardless of this work,
one should break the dev->hard_start_xmit() into those 4 functions
anyways].

INTRODUCING API
---------------

With the api introduced in this patch, a driver which has all
4 parts and needing to support batching is advised to split its
dev->hard_start_xmit() in the following manner:
1)Remove #d from dev->hard_start_xmit() and put it in
dev->hard_end_xmit() method.
2)#b and #c can stay in ->hard_start_xmit() (or whichever way you want
to do this)
3) #a is deffered to future work to reduce confusion (since it holds
on its own).

Note: There are drivers which may need not support any of the two
approaches (example the tun driver i patched) so the methods are
optional.

xmit_win variable is set by the driver to tell the core how much space
it has to take on new skbs. It is introduced to ensure that when we pass
the driver a list of packets it will swallow all of them - which is
useful because we dont requeue to the qdisc (and avoids burning
unnecessary cpu cycles or introducing any strange re-ordering). The driver
tells us when it invokes netif_wake_queue how much space it has for
descriptors by setting this variable.

Refer to the driver howto for more details.

THEORY OF OPERATION
-------------------

1. Core dequeues from qdiscs upto dev->xmit_win packets. Fragmented
and GSO packets are accounted for as well.
2. Core grabs TX_LOCK
3. Core loop for all skbs:
                    invokes driver dev->hard_start_xmit()
4. Core invokes driver dev->hard_end_xmit()

ACKNOWLEDGEMENT AND SOME HISTORY
--------------------------------

There's a lot of history and reasoning of "why batching" in a document
i am writting which i may submit as a patch.
Thomas Graf (who doesnt know this probably) gave me the impetus to
start looking at this back in 2004 when he invited me to the linux
conference he was organizing. Parts of what i presented in SUCON in
2004 talk about batching. Herbert Xu forced me to take a second look around
2.6.18 - refer to my netconf 2006 presentation. Krishna Kumar provided
me with more motivation in May 2007 when he posted on netdev and engaged
me.
Sridhar Samudrala, Krishna Kumar, Matt Carlson, Michael Chan,
Jeremy Ethridge, Evgeniy Polyakov, Sivakumar Subramani, David Miller,
and Patrick McHardy, Jeff Garzik and Bill Fink have contributed in one or
more of {bug fixes, enhancements, testing, lively discussion}. The
Broadcom and neterion folks have been outstanding in their help.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 98d39e2222a7922fa2719a80eecd02cae359f3d7
tree 63822bf3040ea41846399c589c912c2be654f008
parent 7b4cd20628fe5c4e145c383fcd8d954d38f7be61
author Jamal Hadi Salim <hadi@cyberus.ca> Tue, 09 Oct 2007 11:06:28 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Tue, 09 Oct 2007 11:06:28 -0400

 include/linux/netdevice.h |    9 +++++-
 net/core/dev.c            |   67 ++++++++++++++++++++++++++++++++++++++++++---
 net/sched/sch_generic.c   |    4 +--
 3 files changed, 73 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91cd3f3..b0e71c9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -86,6 +86,7 @@ struct wireless_dev;
 /* Driver transmit return codes */
 #define NETDEV_TX_OK 0		/* driver took care of packet */
 #define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
+#define NETDEV_TX_DROPPED 2	/* driver tx path dropped packet*/
 #define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
 
 /*
@@ -467,6 +468,7 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
+#define NETIF_F_BTX		65536	/* Capable of batch tx */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -595,6 +597,9 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	void			(*hard_end_xmit) (struct net_device *dev);
+	int			xmit_win;
+
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -609,6 +614,7 @@ struct net_device
 
 	/* delayed register/unregister */
 	struct list_head	todo_list;
+	struct sk_buff_head     blist;
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
 
@@ -1043,7 +1049,8 @@ extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev);
+					    struct net_device *dev, int *cnt);
+extern int		dev_batch_xmit(struct net_device *dev);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index e7e728a..eaa43d6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1517,8 +1517,10 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
 
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev, int *tcnt)
 {
+	int rc =  NETDEV_TX_OK;
+
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
@@ -1530,7 +1532,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto gso;
 		}
 
-		return dev->hard_start_xmit(skb, dev);
+		rc = dev->hard_start_xmit(skb, dev);
+		if (unlikely(rc)) {
+			/*Life goes on if driver dropped packet */
+			if (unlikely(rc == NETDEV_TX_DROPPED))
+				rc = NETDEV_TX_OK;
+		} else {
+			*tcnt += 1;
+		}
+		return rc;
 	}
 
 gso:
@@ -1542,10 +1552,17 @@ gso:
 		nskb->next = NULL;
 		rc = dev->hard_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
+			if (unlikely(rc == NETDEV_TX_DROPPED)) {
+				rc = NETDEV_TX_OK;
+				continue;
+			}
+
 			nskb->next = skb->next;
 			skb->next = nskb;
 			return rc;
-		}
+		} else
+			*tcnt += 1;
+
 		if (unlikely((netif_queue_stopped(dev) ||
 			     netif_subqueue_stopped(dev, skb->queue_mapping)) &&
 			     skb->next))
@@ -1559,6 +1576,45 @@ out_kfree_skb:
 	return 0;
 }
 
+int dev_batch_xmit(struct net_device *dev)
+{
+	struct sk_buff_head *skbs = &dev->blist;
+	int rc = NETDEV_TX_OK;
+	int tqd = 0, xcnt;
+	struct sk_buff *skb;
+	int orig_w = dev->xmit_win;
+	int orig_pkts = skb_queue_len(skbs);
+
+	while ((skb = __skb_dequeue(skbs)) != NULL) {
+		xcnt = 0;
+		rc = dev_hard_start_xmit(skb, dev, &xcnt);
+		tqd += xcnt;
+		if (unlikely(rc))
+			break;
+	}
+
+	/* Batching driver is likely buggy and lied to us on how much
+	 * space it had. Damn you driver ..
+	*/
+	if (unlikely(skb_queue_len(skbs)) && (dev->features & NETIF_F_BTX)) {
+		printk(KERN_WARNING "Likely bug %s %s (%d) "
+				"left %d/%d window now %d, orig %d\n",
+			dev->name, rc?"busy":"locked",
+			netif_queue_stopped(dev),
+			skb_queue_len(skbs),
+			orig_pkts,
+			dev->xmit_win,
+			orig_w);
+			rc = NETDEV_TX_BUSY;
+	}
+
+	if (tqd)
+		if (dev->hard_end_xmit)
+			dev->hard_end_xmit(dev);
+
+	return rc;
+}
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -1687,8 +1743,9 @@ gso:
 
 			if (!netif_queue_stopped(dev) &&
 			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
+				int c = 0;
 				rc = 0;
-				if (!dev_hard_start_xmit(skb, dev)) {
+				if (!dev_hard_start_xmit(skb, dev, &c)) {
 					HARD_TX_UNLOCK(dev);
 					goto out;
 				}
@@ -3581,6 +3638,8 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
+	dev->xmit_win = 1;
+	skb_queue_head_init(&dev->blist);
 	ret = netdev_register_kobject(dev);
 	if (ret)
 		goto err_uninit;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 95ae119..424c08b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,7 +134,7 @@ static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	int ret;
+	int ret, xcnt = 0;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
@@ -145,7 +145,7 @@ static inline int qdisc_restart(struct net_device *dev)
 	spin_unlock(&dev->queue_lock);
 
 	HARD_TX_LOCK(dev, smp_processor_id());
-	ret = dev_hard_start_xmit(skb, dev);
+	ret = dev_hard_start_xmit(skb, dev, &xcnt);
 	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);

--=-lFjLhOTK04XVIGkh1uLA
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-lFjLhOTK04XVIGkh1uLA--
