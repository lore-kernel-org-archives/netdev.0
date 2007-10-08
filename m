From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 3/3][NET_BATCH] kill dev->gso_skb
Date: Mon, 08 Oct 2007 14:27:44 -0400
Message-ID: <1191868064.4335.35.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Qdl9NnzeK85EDTekYA7w"
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


--=-Qdl9NnzeK85EDTekYA7w
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch removes dev->gso_skb as it is no longer necessary with
batching code.

cheers,
jamal


--=-Qdl9NnzeK85EDTekYA7w
Content-Disposition: attachment; filename=03-kill-dev-gso-skb.patch
Content-Type: text/x-patch; name=03-kill-dev-gso-skb.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_BATCH] kill dev->gso_skb
The batching code does what gso used to batch at the drivers.
There is no more need for gso_skb. If for whatever reason the
requeueing is a bad idea we are going to leave packets in dev->blist
(and still not need dev->gso_skb)

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 3a6202d62adff75b85d6ca0f8fd491abf9d63f4b
tree 80497c538bdb3eab6ab81ff1dec1c3263da79826
parent 63381156b35719a364d0f81fec487e6263fb5467
author Jamal Hadi Salim <hadi@cyberus.ca> Mon, 08 Oct 2007 09:11:02 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 08 Oct 2007 09:11:02 -0400

 include/linux/netdevice.h |    3 ---
 net/sched/sch_generic.c   |   12 ------------
 2 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b31df5c..4ddc6eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -577,9 +577,6 @@ struct net_device
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
-	/* Partially transmitted GSO packet. */
-	struct sk_buff		*gso_skb;
-
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 96bfdcb..9112ea0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -172,13 +172,6 @@ static int xmit_get_pkts(struct net_device *dev,
 	struct sk_buff *skb;
 	int count = dev->xmit_win;
 
-	if (count  && dev->gso_skb) {
-		skb = dev->gso_skb;
-		dev->gso_skb = NULL;
-		count -= xmit_count_skbs(skb);
-		__skb_queue_tail(pktlist, skb);
-	}
-
 	while (count > 0) {
 		skb = q->dequeue(q);
 		if (!skb)
@@ -647,7 +640,6 @@ void dev_activate(struct net_device *dev)
 void dev_deactivate(struct net_device *dev)
 {
 	struct Qdisc *qdisc;
-	struct sk_buff *skb;
 
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
@@ -655,15 +647,11 @@ void dev_deactivate(struct net_device *dev)
 
 	qdisc_reset(qdisc);
 
-	skb = dev->gso_skb;
-	dev->gso_skb = NULL;
 	if (!skb_queue_empty(&dev->blist))
 		skb_queue_purge(&dev->blist);
 	dev->xmit_win = 1;
 	spin_unlock_bh(&dev->queue_lock);
 
-	kfree_skb(skb);
-
 	dev_watchdog_down(dev);
 
 	/* Wait for outstanding dev_queue_xmit calls. */

--=-Qdl9NnzeK85EDTekYA7w
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-Qdl9NnzeK85EDTekYA7w--
