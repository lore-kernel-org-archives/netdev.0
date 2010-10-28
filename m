From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] ixgbe: fix stats handling
Date: Thu, 28 Oct 2010 06:24:18 +0200
Message-ID: <1288239858.2658.72.camel@edumazet-laptop>
References: <1286799439.2737.21.camel@edumazet-laptop>
	 <EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
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
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51399 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062Ab0J1EY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 00:24:28 -0400
Received: by wwe15 with SMTP id 15so1581762wwe.1
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 21:24:26 -0700 (PDT)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 16:35 -0600, Tantilov, Emil S a =C3=A9=
crit :
> >-----Original Message-----
> >From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >Sent: Monday, October 11, 2010 5:17 AM
> >To: David Miller; Waskiewicz Jr, Peter P; Tantilov, Emil S; Kirsher,
> >Jeffrey T
> >Cc: netdev
> >Subject: [PATCH net-next] ixgbe: fix stats handling
> >
> >Hi
> >
> >I am sending this patch for Intel people review/test and acknowledge=
=2E
> >
> >Thanks !
> >
> >[PATCH net-next] ixgbe: fix stats handling
> >
> >Current ixgbe stats have following problems :
> >
> >- Not 64 bit safe (on 32bit arches)
> >
> >- Not safe in ixgbe_clean_rx_irq() :
> >   All cpus dirty a common location (netdev->stats.rx_bytes &
> >netdev->stats.rx_packets) without proper synchronization.
> >   This slow down a bit multiqueue operations, and possibly miss som=
e
> >updates.
> >
> >Fixes :
> >
> >Implement ndo_get_stats64() method to provide accurate 64bit rx|tx
> >bytes/packets counters, using 64bit safe infrastructure.
> >
> >ixgbe_get_ethtool_stats() also use this infrastructure to provide 64=
bit
> >safe counters.
> >
> >Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >CC: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> >CC: Emil Tantilov <emil.s.tantilov@intel.com>
> >CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >---
> > drivers/net/ixgbe/ixgbe.h         |    3 +-
> > drivers/net/ixgbe/ixgbe_ethtool.c |   29 +++++++++++---------
> > drivers/net/ixgbe/ixgbe_main.c    |   40 +++++++++++++++++++++++++-=
--
> > 3 files changed, 56 insertions(+), 16 deletions(-)
> >
> >diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> >index a8c47b0..944d9e2 100644
> >--- a/drivers/net/ixgbe/ixgbe.h
> >+++ b/drivers/net/ixgbe/ixgbe.h
> >@@ -180,8 +180,9 @@ struct ixgbe_ring {
> > 					 */
> >
> > 	struct ixgbe_queue_stats stats;
> >-	unsigned long reinit_state;
> >+	struct u64_stats_sync syncp;
> > 	int numa_node;
> >+	unsigned long reinit_state;
> > 	u64 rsc_count;			/* stat for coalesced packets */
> > 	u64 rsc_flush;			/* stats for flushed packets */
> > 	u32 restart_queue;		/* track tx queue restarts */
> >diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c
> >b/drivers/net/ixgbe/ixgbe_ethtool.c
> >index d4ac943..3c7f15d 100644
> >--- a/drivers/net/ixgbe/ixgbe_ethtool.c
> >+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> >@@ -999,12 +999,11 @@ static void ixgbe_get_ethtool_stats(struct net=
_device
> >*netdev,
> >                                     struct ethtool_stats *stats, u6=
4
> >*data)
> > {
> > 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
> >-	u64 *queue_stat;
> >-	int stat_count =3D sizeof(struct ixgbe_queue_stats) / sizeof(u64);
> > 	struct rtnl_link_stats64 temp;
> > 	const struct rtnl_link_stats64 *net_stats;
> >-	int j, k;
> >-	int i;
> >+	unsigned int start;
> >+	struct ixgbe_ring *ring;
> >+	int i, j;
> > 	char *p =3D NULL;
> >
> > 	ixgbe_update_stats(adapter);
> >@@ -1025,16 +1024,22 @@ static void ixgbe_get_ethtool_stats(struct
> >net_device *netdev,
> > 		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
> > 	}
> > 	for (j =3D 0; j < adapter->num_tx_queues; j++) {
> >-		queue_stat =3D (u64 *)&adapter->tx_ring[j]->stats;
> >-		for (k =3D 0; k < stat_count; k++)
> >-			data[i + k] =3D queue_stat[k];
> >-		i +=3D k;
> >+		ring =3D adapter->tx_ring[j];
> >+		do {
> >+			start =3D u64_stats_fetch_begin_bh(&ring->syncp);
> >+			data[i]   =3D ring->stats.packets;
> >+			data[i+1] =3D ring->stats.bytes;
> >+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
> >+		i +=3D 2;
> > 	}
> > 	for (j =3D 0; j < adapter->num_rx_queues; j++) {
> >-		queue_stat =3D (u64 *)&adapter->rx_ring[j]->stats;
> >-		for (k =3D 0; k < stat_count; k++)
> >-			data[i + k] =3D queue_stat[k];
> >-		i +=3D k;
> >+		ring =3D adapter->rx_ring[j];
> >+		do {
> >+			start =3D u64_stats_fetch_begin_bh(&ring->syncp);
> >+			data[i]   =3D ring->stats.packets;
> >+			data[i+1] =3D ring->stats.bytes;
> >+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
> >+		i +=3D 2;
> > 	}
> > 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
> > 		for (j =3D 0; j < MAX_TX_PACKET_BUFFERS; j++) {
> >diff --git a/drivers/net/ixgbe/ixgbe_main.c
> >b/drivers/net/ixgbe/ixgbe_main.c
> >index 95dbf60..1efbcde 100644
> >--- a/drivers/net/ixgbe/ixgbe_main.c
> >+++ b/drivers/net/ixgbe/ixgbe_main.c
> >@@ -824,8 +824,10 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_v=
ector
> >*q_vector,
> >
> > 	tx_ring->total_bytes +=3D total_bytes;
> > 	tx_ring->total_packets +=3D total_packets;
> >+	u64_stats_update_begin(&tx_ring->syncp);
> > 	tx_ring->stats.packets +=3D total_packets;
> > 	tx_ring->stats.bytes +=3D total_bytes;
> >+	u64_stats_update_end(&tx_ring->syncp);
> > 	return count < tx_ring->work_limit;
> > }
> >
> >@@ -1172,7 +1174,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_=
vector
> >*q_vector,
> > 			       int *work_done, int work_to_do)
> > {
> > 	struct ixgbe_adapter *adapter =3D q_vector->adapter;
> >-	struct net_device *netdev =3D adapter->netdev;
> > 	struct pci_dev *pdev =3D adapter->pdev;
> > 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
> > 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
> >@@ -1298,8 +1299,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q=
_vector
> >*q_vector,
> > 					rx_ring->rsc_count++;
> > 				rx_ring->rsc_flush++;
> > 			}
> >+			u64_stats_update_begin(&rx_ring->syncp);
> > 			rx_ring->stats.packets++;
> > 			rx_ring->stats.bytes +=3D skb->len;
> >+			u64_stats_update_end(&rx_ring->syncp);
> > 		} else {
> > 			if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
> > 				rx_buffer_info->skb =3D next_buffer->skb;
> >@@ -1375,8 +1378,6 @@ next_desc:
> >
> > 	rx_ring->total_packets +=3D total_rx_packets;
> > 	rx_ring->total_bytes +=3D total_rx_bytes;
> >-	netdev->stats.rx_bytes +=3D total_rx_bytes;
> >-	netdev->stats.rx_packets +=3D total_rx_packets;
> >
> > 	return cleaned;
> > }
> >@@ -6559,6 +6560,38 @@ static void ixgbe_netpoll(struct net_device *=
netdev)
> > }
> > #endif
> >
> >+static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_devic=
e
> >*netdev,
> >+						   struct rtnl_link_stats64 *stats)
> >+{
> >+	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
> >+	int i;
> >+
> >+	/* accurate rx/tx bytes/packets stats */
> >+	dev_txq_stats_fold(netdev, stats);
> >+	for (i =3D 0; i < adapter->num_rx_queues; i++) {
> >+		struct ixgbe_ring *ring =3D adapter->rx_ring[i];
> >+		u64 bytes, packets;
> >+		unsigned int start;
> >+
> >+		do {
> >+			start =3D u64_stats_fetch_begin_bh(&ring->syncp);
> >+			packets =3D ring->stats.packets;
> >+			bytes   =3D ring->stats.bytes;
> >+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
> >+		stats->rx_packets +=3D packets;
> >+		stats->rx_bytes   +=3D bytes;
> >+	}
> >+
> >+	/* following stats updated by ixgbe_watchdog_task() */
> >+	stats->multicast	=3D netdev->stats.multicast;
> >+	stats->rx_errors	=3D netdev->stats.rx_errors;
> >+	stats->rx_length_errors	=3D netdev->stats.rx_length_errors;
> >+	stats->rx_crc_errors	=3D netdev->stats.rx_crc_errors;
> >+	stats->rx_missed_errors	=3D netdev->stats.rx_missed_errors;
> >+	return stats;
> >+}
> >+
> >+
> > static const struct net_device_ops ixgbe_netdev_ops =3D {
> > 	.ndo_open		=3D ixgbe_open,
> > 	.ndo_stop		=3D ixgbe_close,
> >@@ -6578,6 +6611,7 @@ static const struct net_device_ops ixgbe_netde=
v_ops =3D
> >{
> > 	.ndo_set_vf_vlan	=3D ixgbe_ndo_set_vf_vlan,
> > 	.ndo_set_vf_tx_rate	=3D ixgbe_ndo_set_vf_bw,
> > 	.ndo_get_vf_config	=3D ixgbe_ndo_get_vf_config,
> >+	.ndo_get_stats64	=3D ixgbe_get_stats64,
> > #ifdef CONFIG_NET_POLL_CONTROLLER
> > 	.ndo_poll_controller	=3D ixgbe_netpoll,
> > #endif
> >
>=20
> Eric,
>=20
> We are seeing intermittent hangs on ia32 arch which seem to point to =
this patch:
>=20
> BUG: unable to handle kernel NULL pointer dereference at 00000040
>  IP: [<f7f6b537>] ixgbe_get_stats64+0x47/0x120 [ixgbe]
>  *pdpt =3D 000000002dc83001 *pde =3D 000000032d7e5067
>  Oops: 0000 [#2] SMP
>  last sysfs file: /sys/devices/system/cpu/cpu23/cache/index2/shared_c=
pu_map
>  Modules linked in: act_skbedit cls_u32 sch_multiq ixgbe mdio netcons=
ole configfs autofs4 8021q garp stp llc sunrpc ipv6 e
> xt3 jbd dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath p=
ower_meter hwmon sg ses enclosure dcdbas pcspkr serio_raw iTCO_wdt iTCO=
_vendor_support io
> atdma dca i7core_edac edac_core bnx2 ext4 mbcache jbd2 sr_mod cdrom s=
d_mod crc_t10dif pata_acpi ata_generic ata_piix megaraid_sas dm_mod [la=
st unloaded: mperf
> ]
>=20
>  Pid: 1939, comm: irqbalance Tainted: G      D W   2.6.36-rc7-upstrea=
m-net-next-2.6-ixgbe-queue-i386-g55e1a84 #1 09CGW2/Po
> werEdge T610
>  EIP: 0060:[<f7f6b537>] EFLAGS: 00010206 CPU: 0
>  EIP is at ixgbe_get_stats64+0x47/0x120 [ixgbe]
>  EAX: 00000000 EBX: ecc45e4c ECX: ebea0400 EDX: 00000000
>  ESI: ebea0000 EDI: 00000018 EBP: f7f846a0 ESP: ecc45d88
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>  Process irqbalance (pid: 1939, ti=3Decc44000 task=3Defc63a50 task.ti=
=3Decc44000)
>  Stack:
>  ecc45e4c 00000000 ebea0400 ebea0000 ecc45e4c ebea0000 ecc45f04 f7f84=
6a0
>  <0> c0750593 ebea0000 edfec340 ebea0000 000002b5 c075063a edfec340 c=
0993eec
>  <0> ebe78000 0000021c 00000000 00000009 00000000 00000000 00000000 0=
0000000
>  Call Trace:
>  [<c0750593>] ? dev_get_stats+0x33/0xc0
>  [<c075063a>] ? dev_seq_printf_stats+0x1a/0x180
>  [<c07507aa>] ? dev_seq_show+0xa/0x20
>  [<c052398f>] ? seq_read+0x22f/0x3d0
>  [<c0523760>] ? seq_read+0x0/0x3d0
>  [<c054fdde>] ? proc_reg_read+0x5e/0x90
>  [<c054fd80>] ? proc_reg_read+0x0/0x90
>  [<c050a1dd>] ? vfs_read+0x9d/0x160
>  [<c049d4ef>] ? audit_syscall_entry+0x20f/0x230
>  [<c050a971>] ? sys_read+0x41/0x70
>  [<c0409cdf>] ? sysenter_do_call+0x12/0x28
>  Code: 60 4f 7e c8 8b 44 24 08 8b b8 20 06 00 00 85 ff 7e 63 c7 44 24=
 04 00 00 00 00 66 90 8b 54 24 04 8b 4c 24 08 8b 84 9
> 1 00 05 00 00 <8b> 50 40 eb 06 8d 74 26 00 89 ca f6 c2 01 0f 85 ae 00=
 00 00 8b
>  EIP: [<f7f6b537>] ixgbe_get_stats64+0x47/0x120 [ixgbe] SS:ESP 0068:e=
cc45d88
>  CR2: 0000000000000040
>  ---[ end trace 51ea89f4e57f54f1 ]---
>=20
> Emil

Code disassembly makes no sense to me : this doesnt match C code at all

60 4f 7e c8=20
8b 44 24 08             mov    0x08(%esp),%eax=20
8b b8 20 06 00 00       mov    0x620(%eax),%edi
85 ff                   test   %edi,%edi
7e 63                   jle    +0x63
c7 44 24 04 00 00 00 00 movl   $0,0x4(%esp)
66 90                   xchg   %ax,%ax
8b 54 24 04             mov    0x04(%esp),%edx   (0 in your report)
8b 4c 24 08             mov    0x08(%esp),%ecx   (ebea0400 in your rep)
8b 84 91 00 05 00 00    mov    0x500(,),eax

<8b> 50 40              mov    0x40(%eax),%edx    NULL pointer deref

eb 06                   jmp    +6
8d 74 26 00             lea    0x0(%esi,%eiz,1),%esi
89 ca                   mov    %ecx,%edx
f6 c2 01                test   $0x1,%dl=20
0f 85 ae 00 00 00       jne=20
8b

Could you disassemble your ixgbe_get_stats64() function ?

Thanks

Mine is :

00000e29 <ixgbe_get_stats64>:
     e29:       55                      push   %ebp
     e2a:       89 e5                   mov    %esp,%ebp
     e2c:       57                      push   %edi
     e2d:       56                      push   %esi
     e2e:       89 c6                   mov    %eax,%esi
     e30:       53                      push   %ebx
     e31:       89 d3                   mov    %edx,%ebx
     e33:       83 ec 18                sub    $0x18,%esp
     e36:       8d b8 40 03 00 00       lea    0x340(%eax),%edi
     e3c:       e8 fc ff ff ff          call   dev_txq_stats_fold
     e41:       31 c0                   xor    %eax,%eax
     e43:       eb 54                   jmp    e99 <ixgbe_get_stats64+0=
x70>
     e45:       8b 94 87 40 0d 00 00    mov    0xd40(%edi,%eax,4),%edx
     e4c:       89 75 e0                mov    %esi,-0x20(%ebp)
     e4f:       89 5d dc                mov    %ebx,-0x24(%ebp)
     e52:       8b 4a 34                mov    0x34(%edx),%ecx
     e55:       f6 c1 01                test   $0x1,%cl
     e58:       74 04                   je     e5e <ixgbe_get_stats64+0=
x35>
     e5a:       f3 90                   pause
     e5c:       eb f4                   jmp    e52 <ixgbe_get_stats64+0=
x29>
     e5e:       8b 5a 24                mov    0x24(%edx),%ebx
     e61:       8b 72 28                mov    0x28(%edx),%esi
     e64:       89 5d ec                mov    %ebx,-0x14(%ebp)
     e67:       8b 5a 2c                mov    0x2c(%edx),%ebx
     e6a:       89 75 f0                mov    %esi,-0x10(%ebp)
     e6d:       8b 72 30                mov    0x30(%edx),%esi
     e70:       89 5d e4                mov    %ebx,-0x1c(%ebp)
     e73:       89 75 e8                mov    %esi,-0x18(%ebp)
     e76:       39 4a 34                cmp    %ecx,0x34(%edx)
     e79:       75 d7                   jne    e52 <ixgbe_get_stats64+0=
x29>
     e7b:       8b 5d dc                mov    -0x24(%ebp),%ebx
     e7e:       8b 55 ec                mov    -0x14(%ebp),%edx
     e81:       8b 75 e0                mov    -0x20(%ebp),%esi
     e84:       8b 4d f0                mov    -0x10(%ebp),%ecx
     e87:       01 13                   add    %edx,(%ebx)
     e89:       8b 55 e4                mov    -0x1c(%ebp),%edx
     e8c:       11 4b 04                adc    %ecx,0x4(%ebx)
     e8f:       01 53 10                add    %edx,0x10(%ebx)
     e92:       8b 4d e8                mov    -0x18(%ebp),%ecx
     e95:       11 4b 14                adc    %ecx,0x14(%ebx)
     e98:       40                      inc    %eax
     e99:       3b 87 40 0e 00 00       cmp    0xe40(%edi),%eax
     e9f:       7c a4                   jl     e45 <ixgbe_get_stats64+0=
x1c>
     ea1:       8b 8e 90 00 00 00       mov    0x90(%esi),%ecx
     ea7:       c7 43 44 00 00 00 00    movl   $0x0,0x44(%ebx)
     eae:       89 4b 40                mov    %ecx,0x40(%ebx)
     eb1:       8b 86 80 00 00 00       mov    0x80(%esi),%eax
     eb7:       c7 43 24 00 00 00 00    movl   $0x0,0x24(%ebx)
     ebe:       89 43 20                mov    %eax,0x20(%ebx)
     ec1:       8b 96 98 00 00 00       mov    0x98(%esi),%edx
     ec7:       c7 43 54 00 00 00 00    movl   $0x0,0x54(%ebx)
     ece:       89 53 50                mov    %edx,0x50(%ebx)
     ed1:       8b 8e a0 00 00 00       mov    0xa0(%esi),%ecx
     ed7:       c7 43 64 00 00 00 00    movl   $0x0,0x64(%ebx)
     ede:       89 4b 60                mov    %ecx,0x60(%ebx)
     ee1:       8b 86 ac 00 00 00       mov    0xac(%esi),%eax
     ee7:       c7 43 7c 00 00 00 00    movl   $0x0,0x7c(%ebx)
     eee:       89 43 78                mov    %eax,0x78(%ebx)
     ef1:       83 c4 18                add    $0x18,%esp
     ef4:       89 d8                   mov    %ebx,%eax
     ef6:       5b                      pop    %ebx
     ef7:       5e                      pop    %esi
     ef8:       5f                      pop    %edi
     ef9:       5d                      pop    %ebp
     efa:       c3                      ret

No 0x40(ptr) deref for me

Could adapter->rx_ring[i] becomes NULL sometime in your driver ?

If yes, a lock/protection is needed (same for ethtool stats I guess)


