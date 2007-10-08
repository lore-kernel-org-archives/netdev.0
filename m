From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/3] [NET_BATCH] Introduce batching interface
Date: Mon, 08 Oct 2007 14:24:45 -0400
Message-ID: <1191867885.4335.30.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-tB3qcmTfQs1JplUVC0Lt"
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.246]:27916 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbXJHSYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:24:49 -0400
Received: by ag-out-0708.google.com with SMTP id 35so657307aga
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 11:24:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tB3qcmTfQs1JplUVC0Lt
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch introduces the netdevice interface for batching.

cheers,
jamal


--=-tB3qcmTfQs1JplUVC0Lt
Content-Disposition: attachment; filename=01-introduce-batching-interface.patch
Content-Type: text/x-patch; name=01-introduce-batching-interface.patch; charset=us-ascii
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
commit 8b9960cfbb98d48c0ac30b2c00d27c25217adb26
tree d8ab164757cee431f71a6011df4b09e0c382e2da
parent cef811600354e9f41f059570fc877d19a1daed99
author Jamal Hadi Salim <hadi@cyberus.ca> Mon, 08 Oct 2007 09:03:42 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 08 Oct 2007 09:03:42 -0400

 include/linux/netdevice.h |   11 +++++++++++
 net/core/dev.c            |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 0 deletions(-)

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
index 1aa0704..164977f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1559,6 +1559,44 @@ out_kfree_skb:
 	return 0;
 }
 
+int dev_batch_xmit(struct net_device *dev)
+{
+	struct sk_buff_head *skbs = &dev->blist;
+	int rc = NETDEV_TX_OK;
+	int tqd = 0;
+	struct sk_buff *skb;
+	int orig_w = dev->xmit_win;
+	int orig_pkts = skb_queue_len(skbs);
+
+	while ((skb = __skb_dequeue(skbs)) != NULL) {
+		rc = dev_hard_start_xmit(skb, dev);
+		if (unlikely(rc))
+			break;
+		tqd++;
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
@@ -3581,6 +3619,8 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
+	dev->xmit_win = 1;
+	skb_queue_head_init(&dev->blist);
 	ret = netdev_register_kobject(dev);
 	if (ret)
 		goto err_uninit;

--=-tB3qcmTfQs1JplUVC0Lt--

