From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Fri, 01 Oct 2010 17:27:41 +0200
Message-ID: <1285946861.21547.24.camel@edumazet-laptop>
References: <20100930062419.GD86786@beaver.vrungel.ru>
	 <1285828432.5211.812.camel@edumazet-laptop>
	 <20100930122321.GA1575@beaver.vrungel.ru>
	 <1285850669.2615.426.camel@edumazet-laptop>
	 <20100930173732.GB4094@beaver.vrungel.ru>
	 <1285869782.2615.920.camel@edumazet-laptop>
	 <20100930181556.GC4094@beaver.vrungel.ru>
	 <1285872765.2615.1008.camel@edumazet-laptop>
	 <20101001101650.GD4094@beaver.vrungel.ru>
	 <1285937966.2641.117.camel@edumazet-laptop>
	 <20101001141858.GE4094@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Alexey Vlasov <renton@renton.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101001141858.GE4094@beaver.vrungel.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 01 octobre 2010 =C3=A0 18:18 +0400, Alexey Vlasov a =C3=A9c=
rit :

> NIC statistics:
>      rx_packets: 2973717440
>      tx_packets: 3032670910
>      rx_bytes: 1892633650741
>      tx_bytes: 2536130682695
>      rx_broadcast: 118773199
>      tx_broadcast: 68013
>      rx_multicast: 95257
>      tx_multicast: 0
>      rx_errors: 0
>      tx_errors: 0
>      tx_dropped: 0
>      multicast: 95257
>      collisions: 0
>      rx_length_errors: 0
>      rx_over_errors: 0
>      rx_crc_errors: 0
>      rx_frame_errors: 0
>      rx_no_buffer_count: 7939
>      rx_queue_drop_packet_count: 1324025520
>      rx_missed_errors: 146631
>      tx_aborted_errors: 0
>      tx_carrier_errors: 0
>      tx_fifo_errors: 0
>      tx_heartbeat_errors: 0
>      tx_window_errors: 0
>      tx_abort_late_coll: 0
>      tx_deferred_ok: 0
>      tx_single_coll_ok: 0
>      tx_multi_coll_ok: 0
>      tx_timeout_count: 0
>      tx_restart_queue: 50715
>      rx_long_length_errors: 0
>      rx_short_length_errors: 0
>      rx_align_errors: 0
>      tx_tcp_seg_good: 344724062
>      tx_tcp_seg_failed: 0
>      rx_flow_control_xon: 0
>      rx_flow_control_xoff: 0
>      tx_flow_control_xon: 0
>      tx_flow_control_xoff: 0
>      rx_long_byte_count: 1892633650741
>      rx_csum_offload_good: 2973697420
>      rx_csum_offload_errors: 6235
>      tx_dma_out_of_sync: 0
>      alloc_rx_buff_failed: 0
>      tx_smbus: 9327
>      rx_smbus: 118531661
>      dropped_smbus: 0
>      tx_queue_0_packets: 797617475
>      tx_queue_0_bytes: 630191908685
>      tx_queue_1_packets: 719681297
>      tx_queue_1_bytes: 625907304846
>      tx_queue_2_packets: 718841556
>      tx_queue_2_bytes: 620522418855
>      tx_queue_3_packets: 796521255
>      tx_queue_3_bytes: 646196024585
>      rx_queue_0_packets: 788885797
>      rx_queue_0_bytes: 458936338699
>      rx_queue_0_drops: 0
>      rx_queue_1_packets: 701354604
>      rx_queue_1_bytes: 457490536453
>      rx_queue_1_drops: 0
>      rx_queue_2_packets: 791887663
>      rx_queue_2_bytes: 534425333616
>      rx_queue_2_drops: 0
>      rx_queue_3_packets: 691579028
>      rx_queue_3_bytes: 429887244557
>      rx_queue_3_drops: 0
> 11.111.80: R 1983626201:1983626201(0) win 0
> > >=20

OK

IGB stats are wrong... for rx_queue_drop_packet_count field at least

Here is a patch against 2.6.32.23, to get the idea...

Dont trust it unless you patch your kernel ;)

Thanks

Note: current linux-2.6 tree doesnt have this bug.

[PATCH] igb: rx_fifo_errors counter fix

Alexey Vlasov reported insane rx_queue_drop_packet_count
(rx_fifo_errors) values.=20

IGB drivers is doing an accumulation for 82575, instead using a zero
value for rqdpc_total.

Reported-by: Alexey Vlasov <renton@renton.name>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 linux-2.6.32.23/net/igb/igb_main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- linux-2.6.32.23/drivers/net/igb/igb_main.c.orig
+++ linux-2.6.32.23/drivers/net/igb/igb_main.c
@@ -3552,6 +3552,7 @@
 	struct e1000_hw *hw =3D &adapter->hw;
 	struct pci_dev *pdev =3D adapter->pdev;
 	u16 phy_tmp;
+	unsigned long rqdpc_total =3D 0;
=20
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
=20
@@ -3645,7 +3646,6 @@
=20
 	if (hw->mac.type !=3D e1000_82575) {
 		u32 rqdpc_tmp;
-		u64 rqdpc_total =3D 0;
 		int i;
 		/* Read out drops stats per RX queue.  Notice RQDPC (Receive
 		 * Queue Drop Packet Count) stats only gets incremented, if
@@ -3660,7 +3660,6 @@
 			adapter->rx_ring[i].rx_stats.drops +=3D rqdpc_tmp;
 			rqdpc_total +=3D adapter->rx_ring[i].rx_stats.drops;
 		}
-		adapter->net_stats.rx_fifo_errors =3D rqdpc_total;
 	}
=20
 	/* Note RNBC (Receive No Buffers Count) is an not an exact
@@ -3668,7 +3667,7 @@
 	 * one of the reason for saving it in rx_fifo_errors, as its
 	 * potentially not a true drop.
 	 */
-	adapter->net_stats.rx_fifo_errors +=3D adapter->stats.rnbc;
+	adapter->net_stats.rx_fifo_errors =3D rqdpc_total + adapter->stats.rn=
bc;
=20
 	/* RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC */
