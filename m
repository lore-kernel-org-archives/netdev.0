From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 3/3][NET_SCHED] kill dev->gso_skb
Date: Sun, 30 Sep 2007 14:53:50 -0400
Message-ID: <1191178430.6165.31.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
	<1190570409.4256.62.camel@localhost>
	<1190570521.4256.65.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-AAmzzJuH/vzRS0exXbYD"
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
In-Reply-To: <1190570521.4256.65.camel@localhost>
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


--=-AAmzzJuH/vzRS0exXbYD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This patch removes dev->gso_skb as it is no longer necessary with
batching code.

cheers,
jamal



--=-AAmzzJuH/vzRS0exXbYD
Content-Disposition: attachment; filename=sep30-p3of3
Content-Type: text/plain; name=sep30-p3of3; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED] kill dev->gso_skb
The batching code does what gso used to batch at the drivers.
There is no more need for gso_skb. If for whatever reason the
requeueing is a bad idea we are going to leave packets in dev->blist
(and still not need dev->gso_skb)

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit c2916c550d228472ddcdd676c2689fa6c8ecfcc0
tree 5beaf197fd08a038d83501f405017f48712d0318
parent 9b4a8fb190278d388c0a622fb5529d184ac8c7dc
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Sep 2007 14:38:58 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Sep 2007 14:38:58 -0400

 include/linux/netdevice.h |    3 ---
 net/sched/sch_generic.c   |   12 ------------
 2 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index df1fb61..cea400a 100644
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
index 86a3f9d..b4e1607 100644
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
@@ -654,7 +647,6 @@ void dev_activate(struct net_device *dev)
 void dev_deactivate(struct net_device *dev)
 {
 	struct Qdisc *qdisc;
-	struct sk_buff *skb;
 
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
@@ -662,15 +654,11 @@ void dev_deactivate(struct net_device *dev)
 
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

--=-AAmzzJuH/vzRS0exXbYD
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-AAmzzJuH/vzRS0exXbYD--
