From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 26 Feb 2005 11:32:29 -0600
Message-ID: <200502261132.29261.jdmason@us.ibm.com>
References: <42208D83.80803@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <42208D83.80803@phekda.gotadsl.co.uk>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 26 February 2005 08:53 am, Richard Dawe wrote:
> Hi Francois and Jon!
> 
> Please find attached a patch that adds the hardware statistics ethtool 
> operations to the r8169 driver. It's against 2.6.11-rc5.

Good Work!  I'll give it a try here in a little bit.

[...]
> If I then bring the interface up ("ifconfig eth0 up"), I get valid stats.
> 
> Any suggestions on how to fix this? I tried a couple of things:
> 
> * Return in get_ethtool_stats if !netif_running(). Made no difference.
> 
> * Zero the stats after creating the DMA mapping with 
> pci_alloc_consistent(). Made no difference.

Can you confirm that the registers are outputting these bogus values?

See comments below. 

<paste from attachment>

--- linux-2.6.11-rc5/drivers/net/r8169.c.orig   2005-02-24 16:40:30.000000000 +0000
+++ linux-2.6.11-rc5/drivers/net/r8169.c        2005-02-26 14:28:37.000000000 +0000
@@ -128,6 +128,7 @@ static int multicast_filter_limit = 32;
 #define RX_BUF_SIZE    1536    /* Rx Buffer size */
 #define R8169_TX_RING_BYTES    (NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES    (NUM_RX_DESC * sizeof(struct RxDesc))
+#define R8169_STATS_BYTES      64
 
 #define RTL8169_TX_TIMEOUT     (6*HZ)
 #define RTL8169_PHY_TIMEOUT    (10*HZ)
@@ -187,6 +188,8 @@ static int use_dac;
 enum RTL8169_registers {
        MAC0 = 0,               /* Ethernet hardware address. */
        MAR0 = 8,               /* Multicast filter. */
+       StatsAddrLow = 0x10,
+       StatsAddrHigh = 0x14,
        TxDescStartAddrLow = 0x20,
        TxDescStartAddrHigh = 0x24,
        TxHDescStartAddrLow = 0x28,
@@ -255,6 +258,9 @@ enum RTL8169_register_content {
        Cfg9346_Lock = 0x00,
        Cfg9346_Unlock = 0xC0,
 
+       /* StatsAddr register */
+       DumpStats = (1 << 3),
+

Wouldn't this be better as "0x08"?  Also, RTL8169_register_content could do with a bit of tidying (values are expressed in decimal and hex, some are aligned and others not, etc).  I'll try and come-up with a patch here in a bit.



        /* rx_mode_bits */
        AcceptErr = 0x20,
        AcceptRunt = 0x10,
@@ -380,6 +386,22 @@ struct ring_info {
        u8              __pad[sizeof(void *) - sizeof(u32)];
 };
 
+struct rtl8169_stats {
+       u64 tx_ok;
+       u64 rx_ok;
+       u64 tx_err;
+       u32 rx_err;
+       u16 rx_fifo;
+       u16 frame_align;
+       u32 tx_ok_1col;
+       u32 tx_ok_mcol;
+       u64 rx_ok_phys;
+       u64 rx_ok_bcast;
+       u32 rx_ok_mcast;
+       u16 tx_abort;
+       u16 tx_underrun;
+} __attribute__((packed));
+


These could all be u64's.  It would take-up more memory (and a bit more code in the register dump), but the values would be more accurate.  Just an idea.



 struct rtl8169_private {
        void __iomem *mmio_addr;        /* memory map physical address */
        struct pci_dev *pci_dev;        /* Index of PCI device */
@@ -404,6 +426,8 @@ struct rtl8169_private {
        u16 intr_mask;
        int phy_auto_nego_reg;
        int phy_1000_ctrl_reg;
+       struct rtl8169_stats *nic_stats;
+       dma_addr_t nic_stats_addr;
 #ifdef CONFIG_R8169_VLAN
        struct vlan_group *vlgrp;
 #endif
@@ -871,6 +895,68 @@ static void rtl8169_get_regs(struct net_
         spin_unlock_irqrestore(&tp->lock, flags);
 }
 
+static const char rtl8169_gstrings_stats[][ETH_GSTRING_LEN] = {
+       "tx_ok", "rx_ok", "tx_err", "rx_err",
+       "rx_fifo", "frame_align", "tx_ok_1col", "tx_ok_mcol",
+       "rx_ok_phys", "rx_ok_bcast", "rx_ok_mcast", "tx_abort",
+       "tx_underrun",
+};
+#define RTL8169_STATS_LEN sizeof(rtl8169_gstrings_stats) / ETH_GSTRING_LEN
+
+static int rtl8169_get_stats_count(struct net_device *dev)
+{
+       return RTL8169_STATS_LEN;
+}
+
+static void rtl8169_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+       switch(stringset) {
+       case ETH_SS_STATS:
+               memcpy(data, *rtl8169_gstrings_stats, sizeof(rtl8169_gstrings_stats));
+               break;
+       }
+}
+
+static void rtl8169_get_ethtool_stats(struct net_device *netdev,
+       struct ethtool_stats *stats, u64 *data)
+{
+       struct rtl8169_private *tp = netdev_priv(netdev);
+       void __iomem *ioaddr = tp->mmio_addr;
+       int work = 100;
+       int i;
+
+       /* begin NIC statistics dump */
+       RTL_W32(StatsAddrHigh, tp->nic_stats_addr >> 32);
+       RTL_W32(StatsAddrLow, (tp->nic_stats_addr & 0xffffffff) | DumpStats);
+       RTL_R32(StatsAddrLow);
+
+       while (work-- > 0) {
+               if ((RTL_R32(StatsAddrLow) & DumpStats) == 0)
+                       break;
+               cpu_relax();
+       }
+
+       if (RTL_R32(StatsAddrLow) & DumpStats)
+               return; /* no stats - took too long */
+
+       i = 0;
+       data[i++] = le64_to_cpu(tp->nic_stats->tx_ok);
+       data[i++] = le64_to_cpu(tp->nic_stats->rx_ok);
+       data[i++] = le64_to_cpu(tp->nic_stats->tx_err);
+       data[i++] = le32_to_cpu(tp->nic_stats->rx_err);
+       data[i++] = le16_to_cpu(tp->nic_stats->rx_fifo);
+       data[i++] = le16_to_cpu(tp->nic_stats->frame_align);
+       data[i++] = le32_to_cpu(tp->nic_stats->tx_ok_1col);
+       data[i++] = le32_to_cpu(tp->nic_stats->tx_ok_mcol);
+       data[i++] = le64_to_cpu(tp->nic_stats->rx_ok_phys);
+       data[i++] = le64_to_cpu(tp->nic_stats->rx_ok_bcast);
+       data[i++] = le32_to_cpu(tp->nic_stats->rx_ok_mcast);
+       data[i++] = le16_to_cpu(tp->nic_stats->tx_abort);
+       data[i++] = le16_to_cpu(tp->nic_stats->tx_underrun);
+       if (i != RTL8169_STATS_LEN)
+               BUG();
+}
+

It seems to me that 'i' could be re-used, instead of having both 'i' and 'work'.  Also,  'u32' or 'unsigned int' is prefered to int  (see http://www.kroah.com/linux/talks/portable_kernel_code_talk_2001_10_02/mgp00022.html).  Also, changes will need to be made if it is decided to use u64 (see above)



 static struct ethtool_ops rtl8169_ethtool_ops = {
        .get_drvinfo            = rtl8169_get_drvinfo,
        .get_regs_len           = rtl8169_get_regs_len,
@@ -886,6 +972,9 @@ static struct ethtool_ops rtl8169_ethtoo
        .get_tso                = ethtool_op_get_tso,
        .set_tso                = ethtool_op_set_tso,
        .get_regs               = rtl8169_get_regs,
+       .get_strings            = rtl8169_get_strings,
+       .get_stats_count        = rtl8169_get_stats_count,
+       .get_ethtool_stats      = rtl8169_get_ethtool_stats,
 };
 
 static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum,
@@ -1531,6 +1620,11 @@ static int rtl8169_open(struct net_devic
        if (retval < 0)
                goto err_free_rx;
 
+       tp->nic_stats = pci_alloc_consistent(pdev, R8169_STATS_BYTES,
+                                            &tp->nic_stats_addr);
+       if (!tp->nic_stats)
+               goto err_free_nic_stats;
+
        INIT_WORK(&tp->task, NULL, dev);
 
        rtl8169_hw_start(dev);
@@ -1541,6 +1635,10 @@ static int rtl8169_open(struct net_devic
 out:
        return retval;
 
+err_free_nic_stats:
+       pci_free_consistent(pdev, R8169_STATS_BYTES, tp->nic_stats,
+                           tp->nic_stats_addr);
+
 err_free_rx:
        pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
                            tp->RxPhyAddr);
