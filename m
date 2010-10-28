From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ixgbe: delay rx_ring freeing
Date: Thu, 28 Oct 2010 14:02:34 +0200
Message-ID: <1288267354.2649.369.camel@edumazet-laptop>
References: <1286799439.2737.21.camel@edumazet-laptop>
	 <EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
	 <1288239858.2658.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brattain, Ross B" <ross.b.brattain@intel.com>,
	netdev <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63703 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab0J1MCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 08:02:39 -0400
Received: by wwe15 with SMTP id 15so1959627wwe.1
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 05:02:38 -0700 (PDT)
In-Reply-To: <1288239858.2658.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 octobre 2010 =C3=A0 06:24 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mercredi 27 octobre 2010 =C3=A0 16:35 -0600, Tantilov, Emil S a =C3=
=A9crit :

> > Eric,
> >=20
> > We are seeing intermittent hangs on ia32 arch which seem to point t=
o this patch:
> >=20
> > BUG: unable to handle kernel NULL pointer dereference at 00000040
> >  IP: [<f7f6b537>] ixgbe_get_stats64+0x47/0x120 [ixgbe]
> >  *pdpt =3D 000000002dc83001 *pde =3D 000000032d7e5067
> >  Oops: 0000 [#2] SMP
> >  last sysfs file: /sys/devices/system/cpu/cpu23/cache/index2/shared=
_cpu_map
> >  Modules linked in: act_skbedit cls_u32 sch_multiq ixgbe mdio netco=
nsole configfs autofs4 8021q garp stp llc sunrpc ipv6 e
> > xt3 jbd dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath=
 power_meter hwmon sg ses enclosure dcdbas pcspkr serio_raw iTCO_wdt iT=
CO_vendor_support io
> > atdma dca i7core_edac edac_core bnx2 ext4 mbcache jbd2 sr_mod cdrom=
 sd_mod crc_t10dif pata_acpi ata_generic ata_piix megaraid_sas dm_mod [=
last unloaded: mperf
> > ]
> >=20
> >  Pid: 1939, comm: irqbalance Tainted: G      D W   2.6.36-rc7-upstr=
eam-net-next-2.6-ixgbe-queue-i386-g55e1a84 #1 09CGW2/Po
> > werEdge T610
> >  EIP: 0060:[<f7f6b537>] EFLAGS: 00010206 CPU: 0
> >  EIP is at ixgbe_get_stats64+0x47/0x120 [ixgbe]
> >  EAX: 00000000 EBX: ecc45e4c ECX: ebea0400 EDX: 00000000
> >  ESI: ebea0000 EDI: 00000018 EBP: f7f846a0 ESP: ecc45d88
> >  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> >  Process irqbalance (pid: 1939, ti=3Decc44000 task=3Defc63a50 task.=
ti=3Decc44000)
> >  Stack:
> >  ecc45e4c 00000000 ebea0400 ebea0000 ecc45e4c ebea0000 ecc45f04 f7f=
846a0
> >  <0> c0750593 ebea0000 edfec340 ebea0000 000002b5 c075063a edfec340=
 c0993eec
> >  <0> ebe78000 0000021c 00000000 00000009 00000000 00000000 00000000=
 00000000
> >  Call Trace:
> >  [<c0750593>] ? dev_get_stats+0x33/0xc0
> >  [<c075063a>] ? dev_seq_printf_stats+0x1a/0x180
> >  [<c07507aa>] ? dev_seq_show+0xa/0x20
> >  [<c052398f>] ? seq_read+0x22f/0x3d0
> >  [<c0523760>] ? seq_read+0x0/0x3d0
> >  [<c054fdde>] ? proc_reg_read+0x5e/0x90
> >  [<c054fd80>] ? proc_reg_read+0x0/0x90
> >  [<c050a1dd>] ? vfs_read+0x9d/0x160
> >  [<c049d4ef>] ? audit_syscall_entry+0x20f/0x230
> >  [<c050a971>] ? sys_read+0x41/0x70
> >  [<c0409cdf>] ? sysenter_do_call+0x12/0x28
> >  Code: 60 4f 7e c8 8b 44 24 08 8b b8 20 06 00 00 85 ff 7e 63 c7 44 =
24 04 00 00 00 00 66 90 8b 54 24 04 8b 4c 24 08 8b 84 9
> > 1 00 05 00 00 <8b> 50 40 eb 06 8d 74 26 00 89 ca f6 c2 01 0f 85 ae =
00 00 00 8b
> >  EIP: [<f7f6b537>] ixgbe_get_stats64+0x47/0x120 [ixgbe] SS:ESP 0068=
:ecc45d88
> >  CR2: 0000000000000040
> >  ---[ end trace 51ea89f4e57f54f1 ]---
> >=20
> > Emil

I believe I now understand the problem, please try following patch.

Thanks



[PATCH] ixgbe: delay rx_ring freeing

"cat /proc/net/dev" uses RCU protection only.

Its quite possible we call a driver get_stats() method while device is
dismantling and freeing its data structures.

So get_stats() methods must be very careful not accessing driver privat=
e
data without appropriate locking.

In ixgbe case, we access rx_ring pointers. These pointers are freed in
ixgbe_clear_interrupt_scheme() and set to NULL, this can trigger NULL
dereference in ixgbe_get_stats64()

A possible fix is to use RCU locking in ixgbe_get_stats64() and defer
rx_ring freeing after a grace period in ixgbe_clear_interrupt_scheme()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Tantilov, Emil S <emil.s.tantilov@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    1=20
 drivers/net/ixgbe/ixgbe_main.c |   34 +++++++++++++++++++++----------
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ed8703c..018e143 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -192,6 +192,7 @@ struct ixgbe_ring {
=20
 	unsigned int size;		/* length in bytes */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
+	struct rcu_head rcu;
 } ____cacheline_internodealigned_in_smp;
=20
 enum ixgbe_ring_f_enum {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index f856312..1b16292 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4742,6 +4742,11 @@ err_set_interrupt:
 	return err;
 }
=20
+static void ring_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ixgbe_ring, rcu));
+}
+
 /**
  * ixgbe_clear_interrupt_scheme - Clear the current interrupt scheme s=
ettings
  * @adapter: board private structure to clear interrupt scheme on
@@ -4758,7 +4763,12 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_a=
dapter *adapter)
 		adapter->tx_ring[i] =3D NULL;
 	}
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
-		kfree(adapter->rx_ring[i]);
+		struct ixgbe_ring *ring =3D adapter->rx_ring[i];
+	=09
+		/* ixgbe_get_stats64() might access this ring, we must wait
+		 * a grace period before freeing it.
+		 */
+		call_rcu(&ring->rcu, ring_free_rcu);
 		adapter->rx_ring[i] =3D NULL;
 	}
=20
@@ -6551,20 +6561,23 @@ static struct rtnl_link_stats64 *ixgbe_get_stat=
s64(struct net_device *netdev,
=20
 	/* accurate rx/tx bytes/packets stats */
 	dev_txq_stats_fold(netdev, stats);
+	rcu_read_lock();
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbe_ring *ring =3D adapter->rx_ring[i];
+		struct ixgbe_ring *ring =3D ACCESS_ONCE(adapter->rx_ring[i]);
 		u64 bytes, packets;
 		unsigned int start;
=20
-		do {
-			start =3D u64_stats_fetch_begin_bh(&ring->syncp);
-			packets =3D ring->stats.packets;
-			bytes   =3D ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
-		stats->rx_packets +=3D packets;
-		stats->rx_bytes   +=3D bytes;
+		if (ring) {
+			do {
+				start =3D u64_stats_fetch_begin_bh(&ring->syncp);
+				packets =3D ring->stats.packets;
+				bytes   =3D ring->stats.bytes;
+			} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+			stats->rx_packets +=3D packets;
+			stats->rx_bytes   +=3D bytes;
+		}
 	}
-
+	rcu_read_unlock();
 	/* following stats updated by ixgbe_watchdog_task() */
 	stats->multicast	=3D netdev->stats.multicast;
 	stats->rx_errors	=3D netdev->stats.rx_errors;
@@ -7270,6 +7283,7 @@ static void __exit ixgbe_exit_module(void)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
=20
 #ifdef CONFIG_IXGBE_DCA


