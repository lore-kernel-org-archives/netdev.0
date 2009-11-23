From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: Fix device name compares
Date: Mon, 23 Nov 2009 12:44:37 +0100
Message-ID: <4B0A75A5.8000106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Robert Olsson <robert.olsson@its.uu.se>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58775 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756959AbZKWLoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 06:44:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e6fce5b916cd7f7f7 (pktgen: multiqueue etc.) tried to relax
the pktgen restriction of one device per kernel thread, adding a '@'
tag to device names.

Problem is we dont perform check on full pktgen device name.
This allows adding many time same 'device' to pktgen thread

 pgset "add_device eth0@0"

one session later :

 pgset "add_device eth0@0"

(This doesnt find previous device)

This consumes ~1.5 MBytes of vmalloc memory per round and also triggers
this warning :

[  673.186380] proc_dir_entry 'pktgen/eth0@0' already registered
[  673.186383] Modules linked in: pktgen ixgbe ehci_hcd psmouse mdio mousedev evdev [last unloaded: pktgen]
[  673.186406] Pid: 6219, comm: bash Tainted: G        W  2.6.32-rc7-03302-g41cec6f-dirty #16
[  673.186410] Call Trace:
[  673.186417]  [<ffffffff8104a29b>] warn_slowpath_common+0x7b/0xc0
[  673.186422]  [<ffffffff8104a341>] warn_slowpath_fmt+0x41/0x50
[  673.186426]  [<ffffffff8114e789>] proc_register+0x109/0x210
[  673.186433]  [<ffffffff8100bf2e>] ? apic_timer_interrupt+0xe/0x20
[  673.186438]  [<ffffffff8114e905>] proc_create_data+0x75/0xd0
[  673.186444]  [<ffffffffa006ad38>] pktgen_thread_write+0x568/0x640 [pktgen]
[  673.186449]  [<ffffffffa006a7d0>] ? pktgen_thread_write+0x0/0x640 [pktgen]
[  673.186453]  [<ffffffff81149144>] proc_reg_write+0x84/0xc0
[  673.186458]  [<ffffffff810f5a58>] vfs_write+0xb8/0x180
[  673.186463]  [<ffffffff810f5c11>] sys_write+0x51/0x90
[  673.186468]  [<ffffffff8100b51b>] system_call_fastpath+0x16/0x1b
[  673.186470] ---[ end trace ccbb991b0a8d994d ]---

Solution to this problem is to use a odevname field (includes @ tag and suffix),
instead of using netdevice name.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d38470a..1813f08 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -364,6 +364,7 @@ struct pktgen_dev {
 				  * device name (not when the inject is
 				  * started as it used to do.)
 				  */
+	char odevname[32];
 	struct flow_state *flows;
 	unsigned cflows;	/* Concurrent flows (config) */
 	unsigned lflow;		/* Flow length  (config) */
@@ -529,7 +530,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "     frags: %d  delay: %llu  clone_skb: %d  ifname: %s\n",
 		   pkt_dev->nfrags, (unsigned long long) pkt_dev->delay,
-		   pkt_dev->clone_skb, pkt_dev->odev->name);
+		   pkt_dev->clone_skb, pkt_dev->odevname);
 
 	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
 		   pkt_dev->lflow);
@@ -1689,13 +1690,13 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
 	if_lock(t);
 	list_for_each_entry(pkt_dev, &t->if_list, list)
 		if (pkt_dev->running)
-			seq_printf(seq, "%s ", pkt_dev->odev->name);
+			seq_printf(seq, "%s ", pkt_dev->odevname);
 
 	seq_printf(seq, "\nStopped: ");
 
 	list_for_each_entry(pkt_dev, &t->if_list, list)
 		if (!pkt_dev->running)
-			seq_printf(seq, "%s ", pkt_dev->odev->name);
+			seq_printf(seq, "%s ", pkt_dev->odevname);
 
 	if (t->result[0])
 		seq_printf(seq, "\nResult: %s\n", t->result);
@@ -1995,7 +1996,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 		       "queue_map_min (zero-based) (%d) exceeds valid range "
 		       "[0 - %d] for (%d) queues on %s, resetting\n",
 		       pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
-		       pkt_dev->odev->name);
+		       pkt_dev->odevname);
 		pkt_dev->queue_map_min = ntxq - 1;
 	}
 	if (pkt_dev->queue_map_max >= ntxq) {
@@ -2003,7 +2004,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 		       "queue_map_max (zero-based) (%d) exceeds valid range "
 		       "[0 - %d] for (%d) queues on %s, resetting\n",
 		       pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
-		       pkt_dev->odev->name);
+		       pkt_dev->odevname);
 		pkt_dev->queue_map_max = ntxq - 1;
 	}
 
@@ -3263,7 +3264,7 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 
 	if (!pkt_dev->running) {
 		printk(KERN_WARNING "pktgen: interface: %s is already "
-		       "stopped\n", pkt_dev->odev->name);
+		       "stopped\n", pkt_dev->odevname);
 		return -EINVAL;
 	}
 
@@ -3467,7 +3468,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	default: /* Drivers are not supposed to return other values! */
 		if (net_ratelimit())
 			pr_info("pktgen: %s xmit error: %d\n",
-				odev->name, ret);
+				pkt_dev->odevname, ret);
 		pkt_dev->errors++;
 		/* fallthru */
 	case NETDEV_TX_LOCKED:
@@ -3576,7 +3577,7 @@ static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
 	if_lock(t);
 
 	list_for_each_entry(p, &t->if_list, list)
-		if (strncmp(p->odev->name, ifname, IFNAMSIZ) == 0) {
+		if (strncmp(p->odevname, ifname, IFNAMSIZ) == 0) {
 			pkt_dev = p;
 			break;
 		}
@@ -3632,6 +3633,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	if (!pkt_dev)
 		return -ENOMEM;
 
+	strcpy(pkt_dev->odevname, ifname);
 	pkt_dev->flows = vmalloc(MAX_CFLOWS * sizeof(struct flow_state));
 	if (pkt_dev->flows == NULL) {
 		kfree(pkt_dev);
