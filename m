From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Fix device name compares
Date: Mon, 23 Nov 2009 16:22:49 +0100
Message-ID: <4B0AA8C9.8060206@gmail.com>
References: <4B0A75A5.8000106@gmail.com> <19210.40927.13011.176740@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Robert Olsson <robert.olsson@its.uu.se>
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55236 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbZKWPW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 10:22:56 -0500
In-Reply-To: <19210.40927.13011.176740@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

robert@herjulf.net a =E9crit :

>  Ok. So the duplicate test got wrong when the multiqueue stuff was=20
>  added.=20
>=20
>  Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
>=20
>  Cheers

Thanks Robert

Here is an updated version because the netdev unregister event also nee=
ded some changes.



[PATCH] pktgen: Fix device name compares

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
[  673.186383] Modules linked in: pktgen ixgbe ehci_hcd psmouse mdio mo=
usedev evdev [last unloaded: pktgen]
[  673.186406] Pid: 6219, comm: bash Tainted: G        W  2.6.32-rc7-03=
302-g41cec6f-dirty #16
[  673.186410] Call Trace:
[  673.186417]  [<ffffffff8104a29b>] warn_slowpath_common+0x7b/0xc0
[  673.186422]  [<ffffffff8104a341>] warn_slowpath_fmt+0x41/0x50
[  673.186426]  [<ffffffff8114e789>] proc_register+0x109/0x210
[  673.186433]  [<ffffffff8100bf2e>] ? apic_timer_interrupt+0xe/0x20
[  673.186438]  [<ffffffff8114e905>] proc_create_data+0x75/0xd0
[  673.186444]  [<ffffffffa006ad38>] pktgen_thread_write+0x568/0x640 [p=
ktgen]
[  673.186449]  [<ffffffffa006a7d0>] ? pktgen_thread_write+0x0/0x640 [p=
ktgen]
[  673.186453]  [<ffffffff81149144>] proc_reg_write+0x84/0xc0
[  673.186458]  [<ffffffff810f5a58>] vfs_write+0xb8/0x180
[  673.186463]  [<ffffffff810f5c11>] sys_write+0x51/0x90
[  673.186468]  [<ffffffff8100b51b>] system_call_fastpath+0x16/0x1b
[  673.186470] ---[ end trace ccbb991b0a8d994d ]---

Solution to this problem is to use a odevname field (includes @ tag and=
 suffix),
instead of using netdevice name.

This also permits clean unloading of NIC drivers.=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |   30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d38470a..e23f494 100644
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
@@ -427,7 +428,7 @@ static const char version[] =3D
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen=
_dev *i);
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifna=
me);
 static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
-					  const char *ifname);
+					  const char *ifname, bool exact);
 static int pktgen_device_event(struct notifier_block *, unsigned long,=
 void *);
 static void pktgen_run_all_threads(void);
 static void pktgen_reset_all_threads(void);
@@ -529,7 +530,7 @@ static int pktgen_if_show(struct seq_file *seq, voi=
d *v)
 	seq_printf(seq,
 		   "     frags: %d  delay: %llu  clone_skb: %d  ifname: %s\n",
 		   pkt_dev->nfrags, (unsigned long long) pkt_dev->delay,
-		   pkt_dev->clone_skb, pkt_dev->odev->name);
+		   pkt_dev->clone_skb, pkt_dev->odevname);
=20
 	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
 		   pkt_dev->lflow);
@@ -1689,13 +1690,13 @@ static int pktgen_thread_show(struct seq_file *=
seq, void *v)
 	if_lock(t);
 	list_for_each_entry(pkt_dev, &t->if_list, list)
 		if (pkt_dev->running)
-			seq_printf(seq, "%s ", pkt_dev->odev->name);
+			seq_printf(seq, "%s ", pkt_dev->odevname);
=20
 	seq_printf(seq, "\nStopped: ");
=20
 	list_for_each_entry(pkt_dev, &t->if_list, list)
 		if (!pkt_dev->running)
-			seq_printf(seq, "%s ", pkt_dev->odev->name);
+			seq_printf(seq, "%s ", pkt_dev->odevname);
=20
 	if (t->result[0])
 		seq_printf(seq, "\nResult: %s\n", t->result);
@@ -1818,9 +1819,10 @@ static struct pktgen_dev *__pktgen_NN_threads(co=
nst char *ifname, int remove)
 {
 	struct pktgen_thread *t;
 	struct pktgen_dev *pkt_dev =3D NULL;
+	bool exact =3D (remove =3D=3D FIND);
=20
 	list_for_each_entry(t, &pktgen_threads, th_list) {
-		pkt_dev =3D pktgen_find_dev(t, ifname);
+		pkt_dev =3D pktgen_find_dev(t, ifname, exact);
 		if (pkt_dev) {
 			if (remove) {
 				if_lock(t);
@@ -1995,7 +1997,7 @@ static void pktgen_setup_inject(struct pktgen_dev=
 *pkt_dev)
 		       "queue_map_min (zero-based) (%d) exceeds valid range "
 		       "[0 - %d] for (%d) queues on %s, resetting\n",
 		       pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
-		       pkt_dev->odev->name);
+		       pkt_dev->odevname);
 		pkt_dev->queue_map_min =3D ntxq - 1;
 	}
 	if (pkt_dev->queue_map_max >=3D ntxq) {
@@ -2003,7 +2005,7 @@ static void pktgen_setup_inject(struct pktgen_dev=
 *pkt_dev)
 		       "queue_map_max (zero-based) (%d) exceeds valid range "
 		       "[0 - %d] for (%d) queues on %s, resetting\n",
 		       pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
-		       pkt_dev->odev->name);
+		       pkt_dev->odevname);
 		pkt_dev->queue_map_max =3D ntxq - 1;
 	}
=20
@@ -3263,7 +3265,7 @@ static int pktgen_stop_device(struct pktgen_dev *=
pkt_dev)
=20
 	if (!pkt_dev->running) {
 		printk(KERN_WARNING "pktgen: interface: %s is already "
-		       "stopped\n", pkt_dev->odev->name);
+		       "stopped\n", pkt_dev->odevname);
 		return -EINVAL;
 	}
=20
@@ -3467,7 +3469,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_de=
v)
 	default: /* Drivers are not supposed to return other values! */
 		if (net_ratelimit())
 			pr_info("pktgen: %s xmit error: %d\n",
-				odev->name, ret);
+				pkt_dev->odevname, ret);
 		pkt_dev->errors++;
 		/* fallthru */
 	case NETDEV_TX_LOCKED:
@@ -3570,13 +3572,18 @@ static int pktgen_thread_worker(void *arg)
 }
=20
 static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
-					  const char *ifname)
+					  const char *ifname, bool exact)
 {
 	struct pktgen_dev *p, *pkt_dev =3D NULL;
+	size_t len =3D strlen(ifname);
 	if_lock(t);
=20
 	list_for_each_entry(p, &t->if_list, list)
-		if (strncmp(p->odev->name, ifname, IFNAMSIZ) =3D=3D 0) {
+		if (strncmp(p->odevname, ifname, len) =3D=3D 0) {
+			if (p->odevname[len]) {
+				if (exact || p->odevname[len] !=3D '@')
+					continue;
+			}
 			pkt_dev =3D p;
 			break;
 		}
@@ -3632,6 +3639,7 @@ static int pktgen_add_device(struct pktgen_thread=
 *t, const char *ifname)
 	if (!pkt_dev)
 		return -ENOMEM;
=20
+	strcpy(pkt_dev->odevname, ifname);
 	pkt_dev->flows =3D vmalloc(MAX_CFLOWS * sizeof(struct flow_state));
 	if (pkt_dev->flows =3D=3D NULL) {
 		kfree(pkt_dev);
