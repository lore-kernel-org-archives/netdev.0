From: Harald Welte <laforge@netfilter.org>
Subject: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 10:14:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux NICS <linux.nics@intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I'm currently trying to help Robert Olsson improving the performance of
the Linux in-kernel packet generator (pktgen.c).  At the moment, we seem
to be unable to get more than 760kpps from a single port of a 82546,
(or any other PCI-X MAC supported by e1000) - that's a bit more than 51%
wirespeed at 64byte packet sizes.

I tried to find out whether this is a software (i.e. linux network
stack, pktgen) problem, or if it is a hardware or driver problem.

To do this, I hardwired some code into the e1000 driver, that
automatically refills the Tx Queue with the same packet over and over
again (see ugly hack attached to this email).  When running in this
hardwired mode, I do not get any E1000_ICR_TXQE events - so apparently
the TX Queue never gets empty, and the 82546 is transferring packets as
fast as possible from host memory.

However, I still don't get more than 760kpps from a single port.

Do you have any further recommendations comments?

Is this 760kpps really a hardware limitation?  Is it limited by the
82546, the PCI-X latency/bandwidth or memory latency/bandwith?

Did Intel ever achieve higher tx pps rates with the 82546 MAC? If yes,
on which hardware and OS ?

Thanks for your help.


Hardware:

MSI K8D Master-F, Dual Opteron 1.4GHz, 1GB RAM, PC-2700 (DDR-333), all on C=
PU1

0000:02:03.0 Ethernet controller: Intel Corp. 82546GB Gigabit Ethernet Cont=
roller (rev 03)
        Subsystem: Intel Corp. PRO/1000 MT Dual Port Network Connection
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 24
        Memory at fc9c0000 (64-bit, non-prefetchable) [size=3D128K]
        Memory at fc900000 (64-bit, non-prefetchable) [size=3D256K]
        I/O ports at a880 [size=3D64]
        Expansion ROM at fc8c0000 [disabled] [size=3D256K]
        Capabilities: [dc] Power Management version 2
        Capabilities: [e4]      Capabilities: [f0] Message Signalled Interr=
upts: 64bit+ Queue=3D0/0 Enable-


Software

linux-2.6.8.1
- modified e1000 to keep re-filling 2048 tx descriptors with same skb
- board does not generate any 'tx queue empty' interrupts
	- thus, TX is running at full PC/HT/memory speed

TxDescriptors=3D2048,2048 FlowControl=3D0,0 Speed=3D1000,1000 TxIntDelay=3D=
0,0 TxAbsIntDelay=3D0,0 InterruptThottleRate=3D0,0

No more than 763kpps possible :(

tried (no improvement):
	- IntDelay, AbsIntDelay, dynamic ThrottleRate
	- enabling NAPI (disables TX interrupt)
		-> tx queue runs empty
	- smp_affinity to other cpu (not sure which has local ram)
		-> only 714kpps
	- increase skb to 128byte
		- 746kpps

---

diff -Nru linux-2.6.8.1/drivers/net/e1000/e1000.h linux-2.6.8.1-test/driver=
s/net/e1000/e1000.h
--- linux-2.6.8.1/drivers/net/e1000/e1000.h	2004-08-14 10:54:47.000000000 +=
0000
+++ linux-2.6.8.1-test/drivers/net/e1000/e1000.h	2004-09-13 16:37:12.000000=
000 +0000
@@ -202,6 +202,7 @@
 	spinlock_t stats_lock;
 	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
+	struct work_struct tx_pktgen_task;
     	uint8_t fc_autoneg;
=20
 	struct timer_list blink_timer;
diff -Nru linux-2.6.8.1/drivers/net/e1000/e1000_main.c linux-2.6.8.1-test/d=
rivers/net/e1000/e1000_main.c
--- linux-2.6.8.1/drivers/net/e1000/e1000_main.c	2004-08-14 10:55:10.000000=
000 +0000
+++ linux-2.6.8.1-test/drivers/net/e1000/e1000_main.c	2004-09-13 21:19:13.9=
96635320 +0000
@@ -111,6 +111,9 @@
 void e1000_update_stats(struct e1000_adapter *adapter);
=20
 /* Local Function Prototypes */
+static struct sk_buff *test_dummy_skb(unsigned int size);
+static void test_refill_tx_queue(struct e1000_adapter *adapter);
+static void test_tx_pktgen_task(struct net_device *netdev);
=20
 static int e1000_init_module(void);
 static void e1000_exit_module(void);
@@ -273,6 +276,9 @@
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	e1000_irq_enable(adapter);
=20
+	test_dummy_skb(60);
+	test_refill_tx_queue(adapter);
+
 	return 0;
 }
=20
@@ -281,6 +287,8 @@
 {
 	struct net_device *netdev =3D adapter->netdev;
=20
+	printk("%s: entering\n", __FUNCTION__);
+
 	e1000_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
@@ -533,6 +541,9 @@
 	INIT_WORK(&adapter->tx_timeout_task,
 		(void (*)(void *))e1000_tx_timeout_task, netdev);
=20
+	INIT_WORK(&adapter->tx_pktgen_task,
+		(void (*)(void *))test_tx_pktgen_task, netdev);
+
 	/* we're going to reset, so assume we have no link for now */
=20
 	netif_carrier_off(netdev);
@@ -765,6 +776,7 @@
 {
 	struct e1000_adapter *adapter =3D netdev->priv;
=20
+	printk("%s: entering\n", __FUNCTION__);
 	e1000_down(adapter);
=20
 	e1000_free_tx_resources(adapter);
@@ -1070,13 +1082,15 @@
=20
 	for(i =3D 0; i < tx_ring->count; i++) {
 		buffer_info =3D &tx_ring->buffer_info[i];
-		if(buffer_info->skb) {
-
+		if(buffer_info->dma) {
 			pci_unmap_page(pdev,
 			               buffer_info->dma,
 			               buffer_info->length,
 			               PCI_DMA_TODEVICE);
+			buffer_info->dma =3D 0;
+		}
=20
+		if(buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
=20
 			buffer_info->skb =3D NULL;
@@ -1434,6 +1448,7 @@
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context). */
+			printk("%s: scheduling timeout\n", __FUNCTION__);
 			schedule_work(&adapter->tx_timeout_task);
 		}
 	}
@@ -1555,6 +1570,7 @@
 #define E1000_MAX_TXD_PWR	12
 #define E1000_MAX_DATA_PER_TXD	(1<<E1000_MAX_TXD_PWR)
=20
+
 static inline int
 e1000_tx_map(struct e1000_adapter *adapter, struct sk_buff *skb,
 	unsigned int first, unsigned int max_per_txd,
@@ -1754,6 +1770,13 @@
 		return 0;
 	}
=20
+#if 0
+	/* don't send any packets */
+	dev_kfree_skb_any(skb);
+	netdev->trans_start =3D jiffies;
+	return 0;
+#endif
+
 #ifdef NETIF_F_TSO
 	mss =3D skb_shinfo(skb)->tso_size;
 	/* The controller does a simple calculation to=20
@@ -1791,6 +1814,8 @@
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2 ) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+		if (net_ratelimit())
+			printk(KERN_DEBUG "err: no unused descriptors\n");
 		return 1;
 	}
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
@@ -1834,6 +1859,7 @@
 {
 	struct e1000_adapter *adapter =3D netdev->priv;
=20
+	printk("%s: entering\n", __FUNCTION__);
 	/* Do the reset outside of interrupt context */
 	schedule_work(&adapter->tx_timeout_task);
 }
@@ -1843,6 +1869,7 @@
 {
 	struct e1000_adapter *adapter =3D netdev->priv;
=20
+	printk("%s: entering\n", __FUNCTION__);
 	netif_device_detach(netdev);
 	e1000_down(adapter);
 	e1000_up(adapter);
@@ -2078,6 +2105,8 @@
 {
 	if(atomic_dec_and_test(&adapter->irq_sem)) {
 		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+		/* disable RX interrupt generation */
+		//E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK & ~E1000_IMS_RXDMT0=
);
 		E1000_WRITE_FLUSH(&adapter->hw);
 	}
 }
@@ -2103,11 +2132,27 @@
 	if(!icr)
 		return IRQ_NONE;  /* Not our interrupt */
=20
+#if 0
+	printk("e1000_intr: icr=3D0x%08x\n", icr);
+	printk("%s: tdh=3D%d, tdt=3D%d\n", __FUNCTION__,
+		E1000_READ_REG(&adapter->hw, TDH),
+		E1000_READ_REG(&adapter->hw, TDT));
+#endif
+
 	if(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->get_link_status =3D 1;
 		mod_timer(&adapter->watchdog_timer, jiffies);
 	}
=20
+	if (icr & E1000_ICR_TXQE) {
+		printk("TX queue empty: shouldn't happen!\n");
+	}
+
+	if (icr & E1000_ICR_TXDW) {
+		e1000_clean_tx_irq(adapter);
+		schedule_work(&adapter->tx_pktgen_task);
+	}
+
 #ifdef CONFIG_E1000_NAPI
 	if(netif_rx_schedule_prep(netdev)) {
=20
@@ -2116,7 +2161,7 @@
 		*/
=20
 		atomic_inc(&adapter->irq_sem);
-		E1000_WRITE_REG(hw, IMC, ~0);
+//		E1000_WRITE_REG(hw, IMC, ~0);
 		__netif_rx_schedule(netdev);
 	}
 #else
@@ -2142,6 +2187,7 @@
 	int work_to_do =3D min(*budget, netdev->quota);
 	int work_done =3D 0;
 =09
+	//printk("%s entered\n", __FUNCTION__);
 	e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
=20
@@ -2175,6 +2221,7 @@
 	boolean_t cleaned =3D FALSE;
=20
=20
+	//printk("%s entered\n", __FUNCTION__);
 	i =3D tx_ring->next_to_clean;
 	eop =3D tx_ring->buffer_info[i].next_to_watch;
 	eop_desc =3D E1000_TX_DESC(*tx_ring, eop);
@@ -2184,6 +2231,7 @@
 		for(cleaned =3D FALSE; !cleaned; ) {
 			tx_desc =3D E1000_TX_DESC(*tx_ring, i);
 			buffer_info =3D &tx_ring->buffer_info[i];
+			//printk("cleaning tx_desc %d\n", i);
=20
 			if(buffer_info->dma) {
=20
@@ -2802,6 +2850,7 @@
 	uint32_t ctrl, ctrl_ext, rctl, manc, status;
 	uint32_t wufc =3D adapter->wol;
=20
+	printk("%s: entering\n", __FUNCTION__);
 	netif_device_detach(netdev);
=20
 	if(netif_running(netdev))
@@ -2920,4 +2969,169 @@
 }
 #endif
=20
+
+#include <linux/ip.h>
+#include <linux/udp.h>
+static struct sk_buff *test_skb;
+
+static struct sk_buff *
+test_dummy_skb(unsigned int pkt_size)
+{
+	int datalen;
+	struct sk_buff *skb;
+	__u8 *eth;
+	struct iphdr *iph;
+	struct udphdr *udph;
+=09
+	skb =3D alloc_skb(pkt_size + 64 + 16, GFP_ATOMIC);
+
+	if (!skb)
+		return NULL;
+
+	/* increase reference count so noone can free it */
+	skb_get(skb);
+
+	skb_reserve(skb, 16);
+	eth =3D (__u8 *) skb_push(skb, 14);
+	iph =3D (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
+	udph =3D (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
+	memset(eth, 1, 6);	// dst
+	memset(eth+6, 2, 6);	// src
+	memset(eth+12, 0x08, 1);
+	memset(eth+13, 0x00, 1);
+
+	datalen =3D pkt_size - 14 - 20 - 8;
+
+	udph->source =3D htons(9);
+	udph->dest =3D htons(9);
+	udph->len =3D htons(datalen + 8);
+	udph->check =3D 0;
+
+	iph->ihl =3D 5;
+	iph->version =3D 4;
+	iph->ttl =3D 3;
+	iph->tos =3D 0;
+	iph->protocol =3D IPPROTO_UDP;
+	iph->saddr =3D htonl(0x01010101);
+	iph->daddr =3D htonl(0x02020202);
+	iph->frag_off =3D 0;
+	iph->tot_len =3D htons(20+8+datalen);
+	iph->check =3D 0;
+	iph->check =3D ip_fast_csum((void *) iph, iph->ihl);
+	skb->protocol =3D __constant_htons(ETH_P_IP);
+	skb->mac.raw =3D ((u8 *)iph) - 14;
+	skb->pkt_type =3D PACKET_HOST;
+
+	test_skb =3D skb;
+
+	return skb;
+}
+
+static inline void
+test_tx_queue(struct e1000_adapter *adapter, int count, int tx_flags)
+{
+	struct e1000_desc_ring *tx_ring =3D &adapter->tx_ring;
+	struct e1000_tx_desc *tx_desc =3D NULL;
+	struct e1000_buffer *buffer_info;
+	uint32_t txd_upper =3D 0, txd_lower =3D E1000_TXD_CMD_IFCS;
+	unsigned int i;
+
+	if(tx_flags & E1000_TX_FLAGS_TSO) {
+		txd_lower |=3D E1000_TXD_CMD_DEXT | E1000_TXD_DTYP_D |
+		             E1000_TXD_CMD_TSE;
+		txd_upper |=3D (E1000_TXD_POPTS_IXSM | E1000_TXD_POPTS_TXSM) << 8;
+	}
+
+	if(tx_flags & E1000_TX_FLAGS_CSUM) {
+		txd_lower |=3D E1000_TXD_CMD_DEXT | E1000_TXD_DTYP_D;
+		txd_upper |=3D E1000_TXD_POPTS_TXSM << 8;
+	}
+
+	if(tx_flags & E1000_TX_FLAGS_VLAN) {
+		txd_lower |=3D E1000_TXD_CMD_VLE;
+		txd_upper |=3D (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
+	}
+
+	i =3D tx_ring->next_to_use;
+
+	while(count--) {
+		buffer_info =3D &tx_ring->buffer_info[i];
+		tx_desc =3D E1000_TX_DESC(*tx_ring, i);
+		tx_desc->buffer_addr =3D cpu_to_le64(buffer_info->dma);
+		tx_desc->lower.data =3D
+			cpu_to_le32(txd_lower | buffer_info->length);
+		tx_desc->upper.data =3D cpu_to_le32(txd_upper);
+		if(++i =3D=3D tx_ring->count) i =3D 0;
+	}
+
+	tx_desc->lower.data |=3D cpu_to_le32(adapter->txd_cmd);
+
+	/* Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.  (Only
+	 * applicable for weak-ordered memory model archs,
+	 * such as IA-64). */
+	wmb();
+
+	tx_ring->next_to_use =3D i;
+}
+
+static void
+test_refill_tx_queue(struct e1000_adapter *adapter)
+{
+	int i, num;
+	unsigned long flags;
+	int reserve =3D 2 + 10;=20
+=09
+	spin_lock_irqsave(&adapter->tx_lock, flags);
+	num =3D E1000_DESC_UNUSED(&adapter->tx_ring);
+
+	if (num <=3D reserve) {
+		printk("too little unused descriptors to refill\n");
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+		return;
+	}
+
+	//printk("%s: refilling %d descriptors\n", __FUNCTION__, num - reserve);
+
+	i =3D 0;
+	while (1) {
+		int ret, skb_idx;
+		if (i >=3D num-reserve)
+			break;
+
+	//	printk("e1000_tx_map(%d)\n", adapter->tx_ring.next_to_use);
+		ret =3D e1000_tx_map(adapter, test_skb,=20
+					adapter->tx_ring.next_to_use,
+				       E1000_MAX_DATA_PER_TXD,
+				       skb_shinfo(test_skb)->nr_frags,
+				       skb_shinfo(test_skb)->tso_size);
+		skb_idx =3D adapter->tx_ring.buffer_info[adapter->tx_ring.next_to_use].n=
ext_to_watch;
+		adapter->tx_ring.buffer_info[skb_idx].skb =3D NULL;
+		test_tx_queue(adapter, ret, 0);
+		i +=3D ret;
+	}
+
+#if 0
+	printk("%s: tdh=3D%d, tdt=3D%d\n", __FUNCTION__,
+		E1000_READ_REG(&adapter->hw, TDH),
+		E1000_READ_REG(&adapter->hw, TDT));
+#endif
+	E1000_WRITE_REG(&adapter->hw, TDT, adapter->tx_ring.next_to_use);
+#if 0
+	printk("%s: tdh=3D%d, tdt=3D%d\n", __FUNCTION__,
+		E1000_READ_REG(&adapter->hw, TDH),
+		E1000_READ_REG(&adapter->hw, TDT));
+#endif
+
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+}
+
+static void
+test_tx_pktgen_task(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter =3D netdev->priv;
+	test_refill_tx_queue(adapter);
+}
+
+
 /* e1000_main.c */



--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD4DBQFBR/nvXaXGVTD0i/8RAgjbAJ4nVm5MMxyodnDdim9iijF0wZl6HACXYaog
5iztEF+7SEhhKM7PPdNgtA==
=ae8b
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--
