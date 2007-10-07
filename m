From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 1/3] [NET_BATCH] Introduce batching interface
Date: Sun, 07 Oct 2007 14:36:23 -0400
Message-ID: <1191782183.4394.62.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-MrbphkMP0vBXylQZV1rs"
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
In-Reply-To: <1190570317.4256.59.camel@localhost>
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


--=-MrbphkMP0vBXylQZV1rs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch introduces the netdevice interface for batching.

cheers,
jamal



--=-MrbphkMP0vBXylQZV1rs
Content-Disposition: attachment; filename=oct07-p1of3
Content-Type: text/plain; name=oct07-p1of3; charset=us-ascii
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
commit 0a0762e2c615a980af284e86d9729d233e1bf7f4
tree c27fec824a9e75ffbb791647bdb595c082a54990
parent 190674ff1fe0b7bddf038c2bfddf45b9c6418e2a
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 07 Oct 2007 08:51:10 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 07 Oct 2007 08:51:10 -0400

 include/linux/netdevice.h |   11 ++++++
 net/core/dev.c            |   83 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91cd3f3..b31df5c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -467,6 +467,7 @@ struct net_device
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
+#define NETIF_F_BTX		65536	/* Capable of batch tx */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -595,6 +596,9 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	void			(*hard_end_xmit) (struct net_device *dev);
+	int			xmit_win;
+
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -609,6 +613,7 @@ struct net_device
 
 	/* delayed register/unregister */
 	struct list_head	todo_list;
+	struct sk_buff_head     blist;
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
 
@@ -1044,6 +1049,12 @@ extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern int		dev_batch_xmit(struct net_device *dev);
+extern int		prepare_gso_skb(struct sk_buff *skb,
+					struct net_device *dev,
+					struct sk_buff_head *skbs);
+extern int		xmit_prepare_skb(struct sk_buff *skb,
+					 struct net_device *dev);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index d998646..04df3fb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1517,6 +1517,87 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
 
+int prepare_gso_skb(struct sk_buff *skb, struct net_device *dev,
+		    struct sk_buff_head *skbs)
+{
+	int tdq = 0;
+	do {
+		struct sk_buff *nskb = skb->next;
+
+		skb->next = nskb->next;
+		nskb->next = NULL;
+
+		/* Driver likes this packet .. */
+		tdq++;
+		__skb_queue_tail(skbs, nskb);
+	} while (skb->next);
+	skb->destructor = DEV_GSO_CB(skb)->destructor;
+	kfree_skb(skb);
+
+	return tdq;
+}
+
+int xmit_prepare_skb(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff_head *skbs = &dev->blist;
+
+	if (netif_needs_gso(dev, skb)) {
+		if (unlikely(dev_gso_segment(skb))) {
+			kfree_skb(skb);
+			return 0;
+		}
+		if (skb->next)
+			return prepare_gso_skb(skb, dev, skbs);
+	}
+
+	__skb_queue_tail(skbs, skb);
+	return 1;
+}
+
+int dev_batch_xmit(struct net_device *dev)
+{
+	struct sk_buff_head *skbs = &dev->blist;
+	int rc = NETDEV_TX_OK;
+	struct sk_buff *skb;
+	int orig_w = dev->xmit_win;
+	int orig_pkts = skb_queue_len(skbs);
+
+	while ((skb = __skb_dequeue(skbs)) != NULL) {
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(skb, dev);
+		rc = dev->hard_start_xmit(skb, dev);
+		if (unlikely(rc))
+			break;
+		/* * XXX: multiqueue may need closer srutiny.. */
+		if (unlikely(netif_queue_stopped(dev) ||
+		     netif_subqueue_stopped(dev, skb->queue_mapping))) {
+			rc = NETDEV_TX_BUSY;
+			break;
+		}
+	}
+
+	/* driver is likely buggy and lied to us on how much
+	 * space it had. Damn you driver ..
+	*/
+	if (unlikely(skb_queue_len(skbs))) {
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
+	if (orig_pkts > skb_queue_len(skbs))
+		if (dev->hard_end_xmit)
+			dev->hard_end_xmit(dev);
+
+	return rc;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(!skb->next)) {
@@ -3553,6 +3634,8 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
+	dev->xmit_win = 1;
+	skb_queue_head_init(&dev->blist);
 	ret = netdev_register_kobject(dev);
 	if (ret)
 		goto err_uninit;

--=-MrbphkMP0vBXylQZV1rs
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-MrbphkMP0vBXylQZV1rs--
