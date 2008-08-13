From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH] prevent pktgen from using bad tx queue
Date: Wed, 13 Aug 2008 16:34:09 -0400
Message-ID: <48A34541.6000008@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000400010701030308040904"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1871 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752155AbYHMUeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 16:34:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000400010701030308040904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


With the new multi-queue transmit code, it is possible to accidentally
make pktgen pick a non-existing tx queue simply by using a stale
script to drive pktgen.  Access to this non-existing tx queue will
then trigger a bad memory access and kill the machine.

For example, setting "queue_map_max 2" will cause my machine to die
when accessing a garbage spinlock in the non-existing tx queue:

BUG: spinlock bad magic on CPU#0, kpktgend_0/564
  lock: ffff88001ddf6718, .magic: ffffffff, .owner: /-1, .owner_cpu: 0
Pid: 564, comm: kpktgend_0 Not tainted 2.6.27-rc3 #35

Call Trace:
  [<ffffffff803a1228>] spin_bug+0xa4/0xac
  [<ffffffff803a1253>] _raw_spin_lock+0x23/0x123
  [<ffffffff8055b06f>] _spin_lock_bh+0x17/0x1b
  [<ffffffff804cb57d>] pktgen_thread_worker+0xa97/0x1002
  [<ffffffff8022874d>] ? finish_task_switch+0x38/0x97
  [<ffffffff80242077>] ? autoremove_wake_function+0x0/0x36
  [<ffffffff80242077>] ? autoremove_wake_function+0x0/0x36
  [<ffffffff804caae6>] ? pktgen_thread_worker+0x0/0x1002
  [<ffffffff80241a40>] kthread+0x44/0x6d
  [<ffffffff8020c399>] child_rip+0xa/0x11
  [<ffffffff802419fc>] ? kthread+0x0/0x6d
  [<ffffffff8020c38f>] ? child_rip+0x0/0x11

The attached patch adds some sanity checking to prevent
these sorts of configuration errors.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>

--------------000400010701030308040904
Content-Type: text/x-diff;
 name="pktgen.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pktgen.diff"

 net/core/pktgen.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 5262364..a756847 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1961,6 +1961,8 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
  */
 static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 {
+	int ntxq;
+
 	if (!pkt_dev->odev) {
 		printk(KERN_ERR "pktgen: ERROR: pkt_dev->odev == NULL in "
 		       "setup_inject.\n");
@@ -1969,6 +1971,33 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 		return;
 	}
 
+	/* make sure that we don't pick a non-existing transmit queue */
+	ntxq = pkt_dev->odev->real_num_tx_queues;
+	if (ntxq <= num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
+		printk(KERN_WARNING "pktgen: WARNING: QUEUE_MAP_CPU "
+		       "disabled because CPU count (%d) exceeds number ",
+		       num_online_cpus());
+		printk(KERN_WARNING "pktgen: WARNING: of tx queues "
+		       "(%d) on %s \n", ntxq, pkt_dev->odev->name);
+		pkt_dev->flags &= ~F_QUEUE_MAP_CPU;
+	}
+	if (ntxq <= pkt_dev->queue_map_min) {
+		printk(KERN_WARNING "pktgen: WARNING: Requested "
+		       "queue_map_min (%d) exceeds number of tx\n",
+		       pkt_dev->queue_map_min);
+		printk(KERN_WARNING "pktgen: WARNING: queues (%d) on "
+		       "%s, resetting\n", ntxq, pkt_dev->odev->name);
+		pkt_dev->queue_map_min = ntxq - 1;
+	}
+	if (ntxq <= pkt_dev->queue_map_max) {
+		printk(KERN_WARNING "pktgen: WARNING: Requested "
+		       "queue_map_max (%d) exceeds number of tx\n",
+		       pkt_dev->queue_map_max);
+		printk(KERN_WARNING "pktgen: WARNING: queues (%d) on "
+		       "%s, resetting\n", ntxq, pkt_dev->odev->name);
+		pkt_dev->queue_map_max = ntxq - 1;
+	}
+
 	/* Default to the interface's mac if not explicitly set. */
 
 	if (is_zero_ether_addr(pkt_dev->src_mac))

--------------000400010701030308040904--
