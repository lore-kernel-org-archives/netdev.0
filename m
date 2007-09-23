From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Sun, 23 Sep 2007 13:56:45 -0400
Message-ID: <1190570205.4256.56.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-QuLyNAMcKWffAYzhwpPp"
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
In-Reply-To: <1190569987.4256.52.camel@localhost>
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


--=-QuLyNAMcKWffAYzhwpPp
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I have submitted this before; but here it is again.
Against net-2.6.24 from yesterday for this and all following patches. 


cheers,
jamal


--=-QuLyNAMcKWffAYzhwpPp
Content-Disposition: attachment; filename=patch10f4
Content-Type: text/plain; name=patch10f4; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED] explict hold dev tx lock

For N cpus, with full throttle traffic on all N CPUs, funneling traffic
to the same ethernet device, the devices queue lock is contended by all
N CPUs constantly. The TX lock is only contended by a max of 2 CPUS.
In the current mode of qdisc operation, when all N CPUs contend for
the dequeue region and one of them (after all the work) entering
dequeue region, we may endup aborting the path if we are unable to get
the tx lock and go back to contend for the queue lock. As N goes up,
this gets worse.

The changes in this patch result in a small increase in performance
with a 4CPU (2xdual-core) with no irq binding. My tests are UDP
based and keep all 4CPUs busy all the time for the period of the test.
Both e1000 and tg3 showed similar behavior.
I expect higher gains with more CPUs. Summary below with different
UDP packets and the resulting pps seen. Note at around 200Bytes,
the two dont seem that much different and we are approaching wire
speed (with plenty of CPU available; eg at 512B, the app is sitting
at 80% idle on both cases).

        +------------+--------------+-------------+------------+--------+
pktsize |       64B  |  128B        | 256B        | 512B       |1024B   |
        +------------+--------------+-------------+------------+--------+
Original| 467482     | 463061       | 388267      | 216308     | 114704 |
        |            |              |             |            |        |
txlock  | 468922     | 464060       | 388298      | 216316     | 114709 |
        -----------------------------------------------------------------

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit b0e36991c5850dfe930f80ee508b08fdcabc18d1
tree b1787bba26f80a325298f89d1ec882cc5ab524ae
parent 42765047105fdd496976bc1784d22eec1cd9b9aa
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 23 Sep 2007 09:09:17 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 23 Sep 2007 09:09:17 -0400

 net/sched/sch_generic.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e970e8e..95ae119 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,34 +134,19 @@ static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	unsigned lockless;
 	int ret;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
 		return 0;
 
-	/*
-	 * When the driver has LLTX set, it does its own locking in
-	 * start_xmit. These checks are worth it because even uncongested
-	 * locks can be quite expensive. The driver can do a trylock, as
-	 * is being done here; in case of lock contention it should return
-	 * NETDEV_TX_LOCKED and the packet will be requeued.
-	 */
-	lockless = (dev->features & NETIF_F_LLTX);
-
-	if (!lockless && !netif_tx_trylock(dev)) {
-		/* Another CPU grabbed the driver tx lock */
-		return handle_dev_cpu_collision(skb, dev, q);
-	}
 
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
+	HARD_TX_LOCK(dev, smp_processor_id());
 	ret = dev_hard_start_xmit(skb, dev);
-
-	if (!lockless)
-		netif_tx_unlock(dev);
+	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
 	q = dev->qdisc;

--=-QuLyNAMcKWffAYzhwpPp
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-QuLyNAMcKWffAYzhwpPp--
