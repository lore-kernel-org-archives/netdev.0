From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: Large Send enablement
Date: Tue, 2 Nov 2004 20:11:03 +0100
Message-ID: <20041102191103.GA24860@electric-eye.fr.zoreil.com>
References: <200411021203.22003.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411021203.22003.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> @@ -1578,6 +1580,24 @@ rtl8169_hw_start(struct net_device *dev)
>         netif_start_queue(dev);
>  }
> 
> +static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +       struct rtl8169_private *tp = netdev_priv(dev);
> +
> +       if (new_mtu < ETH_ZLEN || new_mtu > 7400)
> +               return -EINVAL;
> +
> +       if (netif_running(dev))
> +               rtl8169_close(dev);
> +
> +       dev->mtu = new_mtu;
> +       tp->rx_buf_sz = new_mtu + ETH_HLEN + 8;
> +
> +       rtl8169_open(dev);
> +
> +       return 0;
> +}
> +

Ok. Powow:
- rtl8169_close() is not protected as if it was issued during dev->close.
  It races with the irq handler.
- I see no reason why the state of the device should change if the device
  was not up. Use the tool of your choice to correct me if I am wrong.
- If rtl8169_open() fails [*] when the device was previously up, the driver
  could/should try to recover.

Untested example below to clarify.

[*] page allocation failure, bigger mtu/rx buffers -> I feel moderately
    confortable.


diff -puN drivers/net/r8169.c~r8169-240 drivers/net/r8169.c
--- linux-2.6.9/drivers/net/r8169.c~r8169-240	2004-10-21 21:55:45.000000000 +0200
+++ linux-2.6.9-fr/drivers/net/r8169.c	2004-11-01 23:10:25.000000000 +0100
@@ -120,6 +120,8 @@ static int multicast_filter_limit = 32;
 #define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
+#define R8169_MIN_MTU		8
+#define R8169_MAX_MTU		((2 << 14) - 1)
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
@@ -412,6 +414,7 @@ MODULE_PARM_DESC(use_dac, "Enable PCI DA
 MODULE_LICENSE("GPL");
 
 static int rtl8169_open(struct net_device *dev);
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance,
 			      struct pt_regs *regs);
@@ -1314,6 +1317,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
+	dev->change_mtu = rtl8169_change_mtu;
 	dev->set_multicast_list = rtl8169_set_rx_mode;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
@@ -1533,7 +1537,7 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1738,6 +1742,26 @@ static void rtl8169_schedule_work(struct
 	schedule_delayed_work(&tp->task, 4);
 }
 
+static void __rtl8169_kick(struct net_device *dev)
+{
+	rtl8169_hw_start(dev);
+	netif_poll_enable(dev);
+	netif_wake_queue(dev);
+	set_bit(__LINK_STATE_START, &dev->state);
+}
+
+static void rtl8169_refill_task(void *_data)
+{
+	struct net_device *dev = _data;
+	int err;
+
+	err = rtl8169_init_ring(dev);
+	if (err < 0)
+		rtl8169_schedule_work(dev, rtl8169_refill_task);
+	else if (netif_queue_stopped(dev)) 
+		__rtl8169_kick(dev);
+}
+
 static void rtl8169_wait_for_quiescence(struct net_device *dev)
 {
 	synchronize_irq(dev->irq);
@@ -2223,6 +2247,72 @@ out:
 	return IRQ_RETVAL(handled);
 }
 
+static int rtl8169_set_rxbufsize(struct rtl8169_private *tp, int mtu)
+{
+	if (mtu < R8169_MIN_MTU || mtu > R8169_MAX_MTU)
+		return -EINVAL;
+
+	tp->rx_buf_sz = mtu;
+	if (mtu > ETH_DATA_LEN) {
+		/* MTU + ethernet header + FCS + optional VLAN tag */
+		tp->rx_buf_sz += ETH_HLEN + 8;
+	}
+	return 0;
+}
+
+
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct TxDesc *txd = tp->TxDescArray;
+	void *ioaddr = tp->mmio_addr;
+	int ret, i;
+
+	ret = rtl8169_set_rxbufsize(tp, new_mtu);
+	if (ret < 0)
+		goto out;
+
+	if (!netif_running(dev))
+		goto out;
+
+	printk(KERN_DEBUG "%s: Tx/Rx activity going down!\n", dev->name);
+	RTL_W8(ChipCmd, 0x00);
+	RTL_R8(ChipCmd);
+
+	flush_scheduled_work();
+
+	netif_poll_disable(dev);
+
+	RTL_W16(IntrMask, 0x0000);
+	RTL_R16(IntrMask);
+
+	/* A bit incestuous */
+	clear_bit(__LINK_STATE_START, &dev->state);
+
+	synchronize_irq(dev->irq);
+
+	netif_stop_queue(dev);
+
+	/*
+	 * At this point we do not bother with the irq/napi handlers
+	 * any more. Tx thread may lurk.
+	 */
+	for (i = 0; i < NUM_TX_DESC; i++, txd++)
+		txd->opts1 = le32_to_cpu(DescOwn);
+
+	/* Give a racing hard_start_xmit a few cycles to complete. */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(1);
+		
+	rtl8169_rx_clear(tp);
+	rtl8169_tx_clear(tp);
+
+	rtl8169_refill_task(dev);
+
+out:
+	return ret;
+}
+
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget)
 {

_
