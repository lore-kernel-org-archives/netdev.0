From: John Lumby <johnlumby@hotmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Wed, 20 Apr 2011 23:52:25 -0400
Message-ID: <4DAFA9F9.5080909@hotmail.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from toip5.srvr.bell.ca ([209.226.175.88]:38726 "EHLO
	toip5.srvr.bell.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab1DUDwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 23:52:18 -0400
In-Reply-To: <20110420191316.GA18805@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/11 15:13, Francois Romieu wrote:
>
> Why don't you send the patch through the mailing list ?
>
> (hint, hint)
>

based on 2.6.39-rc2.

also has changes for ethtool  -
    .    get and set ring parms (suggested by Ben)
    .    get and set rx_copybreak   -    not sure if this is a good idea 
or not,
           as it's a driver parm,  not NIC setting,
           but there are 22 net drivers that have the parm so I thought
           maybe useful.

-------------------------------------------------------------------------------------
--- linux-2.6.39-rc2FCrtl/drivers/net/r8169.c.orig    2011-04-05 
21:30:43.000000000 -0400
+++ linux-2.6.39-rc2FCrtl/drivers/net/r8169.c    2011-04-20 
21:34:42.000000000 -0400
@@ -56,7 +56,7 @@
      (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)

  #define TX_BUFFS_AVAIL(tp) \
-    (tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
+    (tp->dirty_tx + tp->num_tx_allocd - tp->cur_tx - 1)

  /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
     The RTL chips use a 64 element hash table based on the Ethernet CRC. */
@@ -74,11 +74,19 @@ static const int multicast_filter_limit

  #define R8169_REGS_SIZE        256
  #define R8169_NAPI_WEIGHT    64
-#define NUM_TX_DESC    64    /* Number of Tx descriptor registers */
-#define NUM_RX_DESC    256    /* Number of Rx descriptor registers */
-#define RX_BUF_SIZE    1536    /* Rx Buffer size */
-#define R8169_TX_RING_BYTES    (NUM_TX_DESC * sizeof(struct TxDesc))
-#define R8169_RX_RING_BYTES    (NUM_RX_DESC * sizeof(struct RxDesc))
+/*  #define NUM_TX_DESC    64    Number of Tx descriptor registers is 
now based on variable num_tx_allocd */
+/*  #define NUM_RX_DESC    256    Number of in-use Rx descriptor 
registers is now based on variable num_rx_allocd :
+                                see comments attached to definition of 
that variable */
+#define MIN_NUM_RX_DESC 16    /*   minimum number of Rx descriptor 
registers with which the chip can operate ? */
+#define MAX_NUM_RX_DESC 256    /*   maximum number of Rx descriptor 
registers with which the chip can operate ? */
+#define MIN_NUM_TX_DESC 16    /*   minimum number of Tx descriptor 
registers with which the chip can operate ? */
+#define MAX_NUM_TX_DESC 64    /*   maximum number of Tx descriptor 
registers with which the chip can operate ? */
+
+                /*  number of in-use Rx descriptors is based on 
variable num_rx_allocd
+                 **  and num_rx_allocd is always <= num_rx_requested value
+                 */
+#define R8169_RX_RING_BYTES    (tp->num_rx_requested * sizeof(struct 
RxDesc))
+#define R8169_TX_RING_BYTES    (tp->num_tx_requested * sizeof(struct 
TxDesc))

  #define RTL8169_TX_TIMEOUT    (6*HZ)
  #define RTL8169_PHY_TIMEOUT    (10*HZ)
@@ -198,12 +206,23 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_p

  MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);

-static int rx_buf_sz = 16383;
+static const int rx_buf_sz = 16383;
+/*
+ *  we set our default copybreak very high to eliminate
+ *  the possibility of running out of receive buffers.
+ *  HOWEVER lowering it will reduce memcpying
+ *  and may improve performance significantly.
+ */
+static int rx_copybreak = 16383;
  static int use_dac;
  static struct {
      u32 msg_enable;
-} debug = { -1 };
+} debug = {
+-1};

+#ifdef RTL8169_DEBUG
+static int simulate_alloc_fail = 0;    /*  set to (P-1) to fail alloc 
on all except every P attempts */
+#endif /* RTL8169_DEBUG */
  enum rtl_registers {
      MAC0        = 0,    /* Ethernet hardware address. */
      MAC4        = 4,
@@ -522,16 +541,50 @@ struct rtl8169_private {
      u32 msg_enable;
      int chipset;
      int mac_version;
-    u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
-    u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
-    u32 dirty_rx;
-    u32 dirty_tx;
+
+    /*   Note - re number of Rx/Tx descriptor buffers allocated :
+     **    we maintain two values per ring  -   requested and allocd.
+     **    requested can be set by ethtool and defaults to the max 
permitted
+     **    allocd is the number actually obtained at open and may be 
less than
+     **    requested,  but provided it is at least the minimum 
required, we'll continue.
+     **    ethtool setting is asynchronous and takes effect at next open.
+     **    The num_xx_allocd count is used as modulus for
+     **    locating active entries in the array using logic like this 
snippet
+     **    in rtl8169_rx_interrupt  :
+     **               entry = cur_rx % num_rx_allocd;
+     **    The size of each array of per-ring-element thingy is always 
the maximum.
+     **
+     **    at present,  with the tx ring info embedded in private,
+     **    it is a bit silly pretending to provide a settable tx_requested,
+     **    but if desired,  at expense of extra ptr deref,
+     **    could change it to an array of pointers
+     */
+    u32 num_tx_requested;    /*   num Tx buffers requested */
+    u32 num_rx_requested;    /*   num Rx buffers requested */
+    u32 num_tx_allocd;    /*   num Tx descriptor buffers allocated */
+    u32 num_rx_allocd;    /*   num Rx descriptor buffers allocated */
+
+    /*    note - the following two counters are monotonically-ascending 
- can be thought of
+     **           as the count of number of buffers which the hardware 
has accessed.
+     */
+    u32 cur_rx;        /* Index of next Rx pkt. */
+    u32 cur_tx;        /* Index of next Tx pkt. */
+
+    u32 totl_rx_replenished;    /*  monotonically-ascending count of 
replenished buffers */
+    u32 replenish_rx_cursor;    /*  Index of next Rx pkt. to replenish 
(modulo,  not monotonic) */
+    /* the following counts pkts copied as opposed to uncopied 
(unhooked)                     */
+    /*  note  -                      count of uncopied packets = cur_rx 
- copied_rx_pkt_count */
+    u32 copied_rx_pkt_count;    /*  total pkts copied to new skb  */
+    u32 totl_rx_alloc_fail;    /*  rx alloc failures */
+    u32 dirty_tx;        /*  monotonic count of transmitted packets (or 
fragments?) */
      struct TxDesc *TxDescArray;    /* 256-aligned Tx descriptor ring */
      struct RxDesc *RxDescArray;    /* 256-aligned Rx descriptor ring */
      dma_addr_t TxPhyAddr;
      dma_addr_t RxPhyAddr;
-    void *Rx_databuff[NUM_RX_DESC];    /* Rx data buffers */
-    struct ring_info tx_skb[NUM_TX_DESC];    /* Tx data buffers */
+    struct sk_buff *Rx_skbuff[MAX_NUM_RX_DESC];    /* Rx data buffers */
+    struct ring_info tx_skb[MAX_NUM_TX_DESC];    /* Tx data buffers */
+
+    unsigned align;
      struct timer_list timer;
      u16 cp_cmd;
      u16 intr_event;
@@ -569,6 +622,14 @@ struct rtl8169_private {

  MODULE_AUTHOR("Realtek and the Linux r8169 crew 
<netdev@vger.kernel.org>");
  MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
+module_param(rx_copybreak, int, 0);
+MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for 
copy-only-tiny-frames");
+#ifdef RTL8169_DEBUG
+module_param(simulate_alloc_fail, int, 0);
+MODULE_PARM_DESC(simulate_alloc_fail,
+         "set to (2**P - 1) eg 15, to fail alloc rx skb on all except 
every 2**P attempts");
+#endif /* RTL8169_DEBUG */
+
  module_param(use_dac, int, 0);
  MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
  module_param_named(debug, debug.msg_enable, int, 0);
@@ -583,7 +644,7 @@ static int rtl8169_open(struct net_devic
  static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
                        struct net_device *dev);
  static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
-static int rtl8169_init_ring(struct net_device *dev);
+static int rtl8169_init_ring(struct rtl8169_private *tp);
  static void rtl_hw_start(struct net_device *dev);
  static int rtl8169_close(struct net_device *dev);
  static void rtl_set_rx_mode(struct net_device *dev);
@@ -1242,6 +1303,15 @@ static int rtl8169_set_settings(struct n
      spin_lock_irqsave(&tp->lock, flags);
      ret = rtl8169_set_speed(dev,
          cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
+
+    /*   check that ethtool has set a copybreak value before accepting 
it */
+    if ( (cmd->supported & (SUPPORTED_cmd_extension |
+                   SUPPORTED_cmd_extension_rx_copybreak))
+ && (cmd->rx_copybreak <= rx_buf_sz) ) {
+        rx_copybreak = cmd->rx_copybreak;
+        netif_info(tp, drv, dev, "set rx_copybreak to %d\n",
+               rx_copybreak);
+    }
      spin_unlock_irqrestore(&tp->lock, flags);

      return ret;
@@ -1254,6 +1324,49 @@ static u32 rtl8169_get_rx_csum(struct ne
      return tp->cp_cmd & RxChkSum;
  }

+static void rtl8169_get_ringparam(struct net_device *netdev,
+                  struct ethtool_ringparam *ring)
+{
+    struct rtl8169_private *tp = netdev_priv(netdev);
+
+    ring->rx_max_pending = MAX_NUM_RX_DESC;
+    ring->tx_max_pending = MAX_NUM_TX_DESC;
+    ring->rx_mini_max_pending = 0;
+    ring->rx_jumbo_max_pending = 0;
+    ring->rx_pending = tp->num_rx_allocd;
+    ring->tx_pending = tp->num_tx_allocd;
+    ring->rx_mini_pending = 0;
+    ring->rx_jumbo_pending = 0;
+}
+
+static int rtl8169_set_ringparam(struct net_device *netdev,
+                 struct ethtool_ringparam *ring)
+{
+    struct rtl8169_private *tp = netdev_priv(netdev);
+
+    if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
+        return -EINVAL;
+
+    /*  I am not sure about closing and opening the NIC here
+     *  so will leave the change pending for next open
+     */
+
+    tp->num_rx_requested = ((ring->rx_pending < MIN_NUM_RX_DESC) ?
+                MIN_NUM_RX_DESC :
+                ((ring->rx_pending > MAX_NUM_RX_DESC) ?
+                 MAX_NUM_RX_DESC : ring->rx_pending));
+    tp->num_tx_requested = ((ring->tx_pending < MIN_NUM_TX_DESC) ?
+                MIN_NUM_TX_DESC :
+                ((ring->tx_pending > MAX_NUM_TX_DESC) ?
+                 MAX_NUM_TX_DESC : ring->tx_pending));
+
+    netif_info(tp, drv, netdev,
+           "Ring sizes to be requested at next open: num rx: %d, num tx 
%d\n",
+           tp->num_rx_requested, tp->num_tx_requested);
+
+    return 0;
+}
+
  static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
  {
      struct rtl8169_private *tp = netdev_priv(dev);
@@ -1351,6 +1464,13 @@ static int rtl8169_get_settings(struct n

      rc = tp->get_settings(dev, cmd);

+    /* inform about returning extended info - rx_copybreak
+     * and initialize so we can detect if set to new val by ethtool
+         */
+    cmd->rx_copybreak = rx_copybreak;
+    cmd->supported |= SUPPORTED_cmd_extension;
+    cmd->supported &= ~SUPPORTED_cmd_extension_rx_copybreak;
+
      spin_unlock_irqrestore(&tp->lock, flags);
      return rc;
  }
@@ -1397,6 +1517,11 @@ static const char rtl8169_gstrings[][ETH
      "multicast",
      "tx_aborted",
      "tx_underrun",
+    /*  extras maintained in driver code */
+    "tot rx intrpts",
+        "tot rx copied",
+        "tot rx replenished",
+    "tot rx alloc_fail"
  };

  static int rtl8169_get_sset_count(struct net_device *dev, int sset)
@@ -1472,9 +1597,15 @@ static void rtl8169_get_ethtool_stats(st
      data[10] = le32_to_cpu(tp->counters.rx_multicast);
      data[11] = le16_to_cpu(tp->counters.tx_aborted);
      data[12] = le16_to_cpu(tp->counters.tx_underun);
+    /*  extras maintained in driver code */
+    data[13] = tp->cur_rx;
+    data[14] = tp->copied_rx_pkt_count;
+    data[15] = tp->totl_rx_replenished;
+    data[16] = tp->totl_rx_alloc_fail;
  }

-static void rtl8169_get_strings(struct net_device *dev, u32 stringset, 
u8 *data)
+static void rtl8169_get_strings(struct net_device *dev, u32 stringset,
+                u8 * data)
  {
      switch(stringset) {
      case ETH_SS_STATS:
@@ -1516,6 +1647,8 @@ static const struct ethtool_ops rtl8169_
      .get_rx_csum        = rtl8169_get_rx_csum,
      .set_rx_csum        = rtl8169_set_rx_csum,
      .set_tx_csum        = ethtool_op_set_tx_csum,
+    .get_ringparam = rtl8169_get_ringparam,
+    .set_ringparam = rtl8169_set_ringparam,
      .set_sg            = ethtool_op_set_sg,
      .set_tso        = ethtool_op_set_tso,
      .get_regs        = rtl8169_get_regs,
@@ -3060,6 +3193,10 @@ rtl8169_init_one(struct pci_dev *pdev, c
      tp->pci_dev = pdev;
      tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);

+    tp->num_rx_allocd = tp->num_tx_allocd = 0;
+    tp->num_rx_requested = MAX_NUM_RX_DESC;
+    tp->num_tx_requested = MAX_NUM_TX_DESC;
+
      mii = &tp->mii;
      mii->dev = dev;
      mii->mdio_read = rtl_mdio_read;
@@ -3229,6 +3366,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
      dev->features |= NETIF_F_HW_VLAN_TX_RX | NETIF_F_GRO;

      tp->intr_mask = 0xffff;
+    tp->align = cfg->align;
      tp->hw_start = cfg->hw_start;
      tp->intr_event = cfg->intr_event;
      tp->napi_event = cfg->napi_event;
@@ -3326,7 +3464,7 @@ static int rtl8169_open(struct net_devic
      if (!tp->RxDescArray)
          goto err_free_tx_0;

-    retval = rtl8169_init_ring(dev);
+    retval = rtl8169_init_ring(tp);
      if (retval < 0)
          goto err_free_rx_1;

@@ -4071,14 +4209,15 @@ static inline void rtl8169_make_unusable
      desc->opts1 &= ~cpu_to_le32(DescOwn | RsvdMask);
  }

-static void rtl8169_free_rx_databuff(struct rtl8169_private *tp,
-                     void **data_buff, struct RxDesc *desc)
+static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
+                struct sk_buff **sk_buff, struct RxDesc *desc)
  {
-    dma_unmap_single(&tp->pci_dev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
-             DMA_FROM_DEVICE);
+    struct pci_dev *pdev = tp->pci_dev;

-    kfree(*data_buff);
-    *data_buff = NULL;
+    dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
+             PCI_DMA_FROMDEVICE);
+    dev_kfree_skb(*sk_buff);    /* also frees the data buffer! */
+    *sk_buff = NULL;
      rtl8169_make_unusable_by_asic(desc);
  }

@@ -4102,28 +4241,25 @@ static inline void *rtl8169_align(void *
      return (void *)ALIGN((long)data, 16);
  }

-static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
-                         struct RxDesc *desc)
+static struct sk_buff *rtl8169_alloc_rx_skb(struct rtl8169_private *tp,
+                        struct RxDesc *desc, gfp_t gfp)
  {
-    void *data;
+    struct sk_buff *skb;
      dma_addr_t mapping;
      struct device *d = &tp->pci_dev->dev;
      struct net_device *dev = tp->dev;
-    int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
+    unsigned int pad;

-    data = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
-    if (!data)
-        return NULL;
+    pad = tp->align ? tp->align : NET_IP_ALIGN;

-    if (rtl8169_align(data) != data) {
-        kfree(data);
-        data = kmalloc_node(rx_buf_sz + 15, GFP_KERNEL, node);
-        if (!data)
-            return NULL;
-    }
+    skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
+    if (!skb)
+        goto err_out;
+
+    skb_reserve(skb,
+            tp->align ? ((pad - 1) & (unsigned long)skb->data) : pad);

-    mapping = dma_map_single(d, rtl8169_align(data), rx_buf_sz,
-                 DMA_FROM_DEVICE);
+    mapping = dma_map_single(d, skb->data, rx_buf_sz, DMA_FROM_DEVICE);
      if (unlikely(dma_mapping_error(d, mapping))) {
          if (net_ratelimit())
              netif_err(tp, drv, tp->dev, "Failed to map RX DMA!\n");
@@ -4131,23 +4267,25 @@ static struct sk_buff *rtl8169_alloc_rx_
      }

      rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
-    return data;
+out:
+    return skb;

  err_out:
-    kfree(data);
-    return NULL;
+    rtl8169_make_unusable_by_asic(desc);
+    goto out;
  }

  static void rtl8169_rx_clear(struct rtl8169_private *tp)
  {
      unsigned int i;

-    for (i = 0; i < NUM_RX_DESC; i++) {
-        if (tp->Rx_databuff[i]) {
-            rtl8169_free_rx_databuff(tp, tp->Rx_databuff + i,
+    for (i = 0; i < tp->num_rx_allocd; i++) {
+        if (tp->Rx_skbuff[i]) {
+            rtl8169_free_rx_skb(tp, tp->Rx_skbuff + i,
                          tp->RxDescArray + i);
          }
      }
+    tp->num_rx_allocd = 0;    /*  no rx descriptors allocated any more ! */
  }

  static inline void rtl8169_mark_as_last_descriptor(struct RxDesc *desc)
@@ -4155,47 +4293,92 @@ static inline void rtl8169_mark_as_last_
      desc->opts1 |= cpu_to_le32(RingEnd);
  }

-static int rtl8169_rx_fill(struct rtl8169_private *tp)
+/*   rtl8169_rx_fill :allocate num_to_alloc rx skb buffers to rx 
descriptors
+ *   starting with descriptor first_desc.
+ *   this function operates in one of two slightly different modes,
+ *   depending on whether the num_replenished parm is zero or not :
+ *      zero     -  traverse a fixed number of buffers specified by 
num_to_alloc,
+ *                  allocating those which are empty;
+ *      non-zero -  traverse as many buffers as needed
+ *                  to replenish num_replenished empty buffers,
+ *                  and update the parm with number actually replenished.
+ *   in each case,  stop if unable to allocate,
+ *   and in each case return number of buffers traversed.
+ */
+static u32 rtl8169_rx_fill(struct rtl8169_private *tp, u32 first_desc,
+               u32 num_to_alloc, u32 * num_replenished, gfp_t gfp)
  {
-    unsigned int i;
+    unsigned int this_desc_index;    /*   loop through on this */
+    u32 count_allocd;    /*   count allocd */
+    u32 num_traversed;    /*   count num traversed */
+
+    for (count_allocd = 0, num_traversed = 0, this_desc_index = first_desc;
+         ((num_replenished && (count_allocd < *num_replenished))
+          || (num_traversed < num_to_alloc)
+         ); num_traversed++) {
+        struct sk_buff *skb;

-    for (i = 0; i < NUM_RX_DESC; i++) {
-        void *data;
+        if (tp->Rx_skbuff[this_desc_index] == (struct sk_buff *)0) {    
/* bypass if allocd */

-        if (tp->Rx_databuff[i])
-            continue;
+            skb =
+                rtl8169_alloc_rx_skb(tp,
+                         tp->RxDescArray +
+                         this_desc_index, gfp);
+            if (!skb)
+                break;

-        data = rtl8169_alloc_rx_data(tp, tp->RxDescArray + i);
-        if (!data) {
-            rtl8169_make_unusable_by_asic(tp->RxDescArray + i);
-            goto err_out;
-        }
-        tp->Rx_databuff[i] = data;
+            tp->Rx_skbuff[this_desc_index] = skb;
+            count_allocd++;
      }

-    rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
-    return 0;
+        /*  increment this_desc_index allowing for modulo num_rx_allocd 
if latter is > 0
+         *  also ensuring we stop after one complete circuit
+         */
+        this_desc_index++;
+        if (this_desc_index == tp->num_rx_allocd) {
+            this_desc_index = 0;
+        }
+        if (this_desc_index == first_desc) {
+            break;
+        }
+    }

-err_out:
-    rtl8169_rx_clear(tp);
-    return -ENOMEM;
+    if (num_replenished)
+        *num_replenished = count_allocd;
+    return num_traversed;
  }

  static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
  {
-    tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
+    tp->dirty_tx = tp->totl_rx_replenished = tp->totl_rx_alloc_fail =
+        tp->cur_tx = tp->cur_rx = tp->replenish_rx_cursor = 0;
  }

-static int rtl8169_init_ring(struct net_device *dev)
+static int rtl8169_init_ring(struct rtl8169_private *tp)
  {
-    struct rtl8169_private *tp = netdev_priv(dev);

      rtl8169_init_ring_indexes(tp);

-    memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
-    memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
+    memset(tp->tx_skb, 0x0, MAX_NUM_TX_DESC * sizeof(struct ring_info));
+    memset(tp->Rx_skbuff, 0x0, MAX_NUM_RX_DESC * sizeof(struct sk_buff *));
+    tp->copied_rx_pkt_count = 0;
+
+    /*  see comment preceding defn of num_tx_requested */
+    tp->num_tx_allocd = tp->num_tx_requested;
+    tp->num_rx_allocd =
+        rtl8169_rx_fill(tp, 0, (u32) tp->num_rx_requested, 0, GFP_KERNEL);
+    printk(KERN_INFO "%s num_rx_requested= %d num_rx_allocd= %d\n",
+           MODULENAME, (u32) tp->num_rx_requested, tp->num_rx_allocd);
+    if (tp->num_rx_allocd < MIN_NUM_RX_DESC)
+        goto err_out;
+
+    rtl8169_mark_as_last_descriptor(tp->RxDescArray + tp->num_rx_allocd 
- 1);

-    return rtl8169_rx_fill(tp);
+    return 0;
+
+err_out:
+    rtl8169_rx_clear(tp);
+    return -ENOMEM;
  }

  static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info 
*tx_skb,
@@ -4217,7 +4400,7 @@ static void rtl8169_tx_clear_range(struc
      unsigned int i;

      for (i = 0; i < n; i++) {
-        unsigned int entry = (start + i) % NUM_TX_DESC;
+        unsigned int entry = (start + i) % tp->num_tx_allocd;
          struct ring_info *tx_skb = tp->tx_skb + entry;
          unsigned int len = tx_skb->len;

@@ -4237,7 +4420,7 @@ static void rtl8169_tx_clear_range(struc

  static void rtl8169_tx_clear(struct rtl8169_private *tp)
  {
-    rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
+    rtl8169_tx_clear_range(tp, tp->dirty_tx, tp->num_tx_allocd);
      tp->cur_tx = tp->dirty_tx = 0;
  }

@@ -4310,7 +4493,7 @@ static void rtl8169_reset_task(struct wo
      rtl8169_rx_interrupt(dev, tp, tp->mmio_addr, ~(u32)0);
      rtl8169_tx_clear(tp);

-    if (tp->dirty_rx == tp->cur_rx) {
+    if (tp->totl_rx_replenished == tp->cur_rx) {
          rtl8169_init_ring_indexes(tp);
          rtl_hw_start(dev);
          netif_wake_queue(dev);
@@ -4350,7 +4533,7 @@ static int rtl8169_xmit_frags(struct rtl
          u32 status, len;
          void *addr;

-        entry = (entry + 1) % NUM_TX_DESC;
+        entry = (entry + 1) % tp->num_tx_allocd;

          txd = tp->TxDescArray + entry;
          len = frag->size;
@@ -4364,7 +4547,9 @@ static int rtl8169_xmit_frags(struct rtl
          }

          /* anti gcc 2.95.3 bugware (sic) */
-        status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
+        status =
+            opts1 | len | (RingEnd *
+                   !((entry + 1) % tp->num_tx_allocd));

          txd->opts1 = cpu_to_le32(status);
          txd->addr = cpu_to_le64(mapping);
@@ -4408,7 +4593,7 @@ static netdev_tx_t rtl8169_start_xmit(st
                        struct net_device *dev)
  {
      struct rtl8169_private *tp = netdev_priv(dev);
-    unsigned int entry = tp->cur_tx % NUM_TX_DESC;
+    unsigned int entry = tp->cur_tx % tp->num_tx_allocd;
      struct TxDesc *txd = tp->TxDescArray + entry;
      void __iomem *ioaddr = tp->mmio_addr;
      struct device *d = &tp->pci_dev->dev;
@@ -4418,7 +4603,8 @@ static netdev_tx_t rtl8169_start_xmit(st
      int frags;

      if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
-        netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
+        netif_err(tp, drv, dev,
+              "BUG! Tx Ring full when queue awake!\n");
          goto err_stop_0;
      }

@@ -4452,7 +4638,7 @@ static netdev_tx_t rtl8169_start_xmit(st
      wmb();

      /* anti gcc 2.95.3 bugware (sic) */
-    status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
+    status = opts1 | len | (RingEnd * !((entry + 1) % tp->num_tx_allocd));
      txd->opts1 = cpu_to_le32(status);

      tp->cur_tx += frags + 1;
@@ -4512,11 +4698,13 @@ static void rtl8169_pcierr_interrupt(str

      pci_write_config_word(pdev, PCI_STATUS,
          pci_status & (PCI_STATUS_DETECTED_PARITY |
-        PCI_STATUS_SIG_SYSTEM_ERROR | PCI_STATUS_REC_MASTER_ABORT |
-        PCI_STATUS_REC_TARGET_ABORT | PCI_STATUS_SIG_TARGET_ABORT));
+                        PCI_STATUS_SIG_SYSTEM_ERROR |
+                        PCI_STATUS_REC_MASTER_ABORT |
+                        PCI_STATUS_REC_TARGET_ABORT |
+                        PCI_STATUS_SIG_TARGET_ABORT));

      /* The infamous DAC f*ckup only happens at boot time */
-    if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
+    if ((tp->cp_cmd & PCIDAC) && !tp->totl_rx_replenished && !tp->cur_rx) {
          void __iomem *ioaddr = tp->mmio_addr;

          netif_info(tp, intr, dev, "disabling PCI DAC\n");
@@ -4541,7 +4729,7 @@ static void rtl8169_tx_interrupt(struct
      tx_left = tp->cur_tx - dirty_tx;

      while (tx_left > 0) {
-        unsigned int entry = dirty_tx % NUM_TX_DESC;
+        unsigned int entry = dirty_tx % tp->num_tx_allocd;
          struct ring_info *tx_skb = tp->tx_skb + entry;
          u32 status;

@@ -4597,29 +4785,110 @@ static inline void rtl8169_rx_csum(struc
          skb_checksum_none_assert(skb);
  }

-static struct sk_buff *rtl8169_try_rx_copy(void *data,
-                       struct rtl8169_private *tp,
-                       int pkt_size,
-                       dma_addr_t addr)
+/*   rtl8169_rx_deliver : delivers one rx skb up to higher netif layer
+ *   and copies or replenishes the skb as needed.
+ *   @tp        -> private cb for this NIC
+ *   @entry     == index of rx descriptor in ring
+ *   @polling   == whether polling or not (see comments for rx_interrupt)
+ *   we guarantee that the received packet will be passed up to the 
higher layer.
+ *   we also try to ensure that a buffer is available for next receive 
on this skb,
+ *   but do not guarantee that.
+ *   This function does not write or read to the asic registers
+ *   and does not return any return code -  work is reported via the 
descriptors.
+ *   "original" skb means the one previously in the ring
+ *   "returned" skb means the one passed up
+ *   these may be the same or different :
+ *       if packet size sufficiently small relative to rx_copybreak mod 
parm,
+ *       then try to copy the entire active skb to a new one,  and,
+ *       if successful,  return the new and leave the original as active.
+ *       otherwise,   return the original and try to replenish the ring.
+ */
+
+void rtl8169_rx_deliver(struct rtl8169_private *tp, unsigned int entry,
+              int polling)
  {
-    struct sk_buff *skb;
-    struct device *d = &tp->pci_dev->dev;
+    struct RxDesc *desc;
+    u32 opts1;
+    struct sk_buff *original_skb;
+    struct sk_buff *returned_skb;
+    dma_addr_t addr;
+    int pkt_size;
+    struct pci_dev *pdev;
+
+    desc = tp->RxDescArray + entry;
+    opts1 = le32_to_cpu(desc->opts1);
+    original_skb = tp->Rx_skbuff[entry];
+    addr = le64_to_cpu(desc->addr);
+    pkt_size = (opts1 & 0x00001FFF) - 4;
+    pdev = tp->pci_dev;
+
+    dprintk
+        ("rtl8169_rx_deliver entry= %d opts1= 0x%X pkt_size= %d 
polling= 0x%X\n",
+         entry, opts1, pkt_size, polling);
+
+    if (pkt_size < rx_copybreak) {
+        returned_skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
+        if (returned_skb) {
+            dma_sync_single_for_cpu(&pdev->dev, addr, pkt_size,
+                        PCI_DMA_FROMDEVICE);
+            prefetch(original_skb->data);
+            memcpy(returned_skb->data, original_skb->data,
+                   pkt_size);
+            dma_sync_single_for_device(&pdev->dev, addr, pkt_size,
+                           PCI_DMA_FROMDEVICE);
+            rtl8169_mark_to_asic(desc, rx_buf_sz);
+            tp->totl_rx_replenished++;
+            tp->copied_rx_pkt_count++;
+        } else {
+            /*  can't replenish (out of storage ) */
+            rtl8169_make_unusable_by_asic(desc);
+            dma_unmap_single(&pdev->dev, addr, rx_buf_sz,
+                     PCI_DMA_FROMDEVICE);
+            tp->Rx_skbuff[entry] = NULL;
+            returned_skb = original_skb;
+            tp->totl_rx_alloc_fail++;
+        }
+    } else {
+        returned_skb = original_skb;
+        dma_unmap_single(&pdev->dev, addr, rx_buf_sz,
+                 PCI_DMA_FROMDEVICE);
+        /*  following may fail in which case it sets the skbuff ptr to 0 */
+#ifdef RTL8169_DEBUG
+        /*  to simulate alloc failure every n attempts  */
+        if (simulate_alloc_fail && ((simulate_alloc_fail & entry) != 0))
+            tp->Rx_skbuff[entry] = 0;
+        else
+#endif /* RTL8169_DEBUG */
+            tp->Rx_skbuff[entry] =
+                rtl8169_alloc_rx_skb(tp, desc, GFP_ATOMIC);
+        if (tp->Rx_skbuff[entry]) {
+            tp->totl_rx_replenished++;
+        } else {
+            rtl8169_make_unusable_by_asic(desc);
+            tp->totl_rx_alloc_fail++;
+        }
+    }

-    data = rtl8169_align(data);
-    dma_sync_single_for_cpu(d, addr, pkt_size, DMA_FROM_DEVICE);
-    prefetch(data);
-    skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
-    if (skb)
-        memcpy(skb->data, data, pkt_size);
-    dma_sync_single_for_device(d, addr, pkt_size, DMA_FROM_DEVICE);
+    rtl8169_rx_csum(returned_skb, opts1);
+    skb_put(returned_skb, pkt_size);
+    returned_skb->protocol = eth_type_trans(returned_skb, tp->dev);
+
+    rtl8169_rx_vlan_tag(desc, returned_skb);
+
+    if (likely(polling)) {
+        napi_gro_receive(&tp->napi, returned_skb);
+        dprintk("rtl8169_rx_deliver explicit napi_gro_receive\n");
+    } else {
+        netif_rx(returned_skb);
+        dprintk("rtl8169_rx_deliver explicit netif_rx\n");
+    }

-    return skb;
  }

  /*
   * Warning : rtl8169_rx_interrupt() might be called :
   * 1) from NAPI (softirq) context
- *    (polling = 1 : we should call netif_receive_skb())
+ *    (polling = 1 : we should call napi_gro_receive())
   * 2) from process context (rtl8169_reset_task())
   *    (polling = 0 : we must call netif_rx() instead)
   */
@@ -4628,71 +4897,55 @@ static int rtl8169_rx_interrupt(struct n
                  void __iomem *ioaddr, u32 budget)
  {
      unsigned int cur_rx, rx_left;
-    unsigned int count;
+
+    unsigned int replenish_rx_cursor_delta;    /*  amount by which to 
advance cursor  */
+    unsigned int count;    /*  number of completed buffers handled in 
this call   */
+    unsigned int number_to_replenish; /* num buffers to replenish after 
delivering */
      int polling = (budget != ~(u32)0) ? 1 : 0;

      cur_rx = tp->cur_rx;
-    rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
+    rx_left = tp->num_rx_allocd + tp->totl_rx_replenished - cur_rx;
      rx_left = min(rx_left, budget);

      for (; rx_left > 0; rx_left--, cur_rx++) {
-        unsigned int entry = cur_rx % NUM_RX_DESC;
+        unsigned int entry = cur_rx % tp->num_rx_allocd;
          struct RxDesc *desc = tp->RxDescArray + entry;
-        u32 status;
+        u32 opts1;

          rmb();
-        status = le32_to_cpu(desc->opts1);
+        opts1 = le32_to_cpu(desc->opts1);

-        if (status & DescOwn)
+        if (opts1 & DescOwn)
              break;
-        if (unlikely(status & RxRES)) {
-            netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
-                   status);
+        if (unlikely(opts1 & RxRES)) {
+            netif_info(tp, rx_err, dev, "Rx ERROR. opts1 = %08x\n",
+                   opts1);
              dev->stats.rx_errors++;
-            if (status & (RxRWT | RxRUNT))
+            if (opts1 & (RxRWT | RxRUNT))
                  dev->stats.rx_length_errors++;
-            if (status & RxCRC)
+            if (opts1 & RxCRC)
                  dev->stats.rx_crc_errors++;
-            if (status & RxFOVF) {
+            if (opts1 & RxFOVF) {
                  rtl8169_schedule_work(dev, rtl8169_reset_task);
                  dev->stats.rx_fifo_errors++;
              }
              rtl8169_mark_to_asic(desc, rx_buf_sz);
          } else {
-            struct sk_buff *skb;
-            dma_addr_t addr = le64_to_cpu(desc->addr);
-            int pkt_size = (status & 0x00001FFF) - 4;
+            int pkt_size = (opts1 & 0x00001FFF) - 4;

              /*
               * The driver does not support incoming fragmented
               * frames. They are seen as a symptom of over-mtu
               * sized frames.
               */
-            if (unlikely(rtl8169_fragmented_frame(status))) {
+            if (unlikely(rtl8169_fragmented_frame(opts1))) {
                  dev->stats.rx_dropped++;
                  dev->stats.rx_length_errors++;
                  rtl8169_mark_to_asic(desc, rx_buf_sz);
                  continue;
              }

-            skb = rtl8169_try_rx_copy(tp->Rx_databuff[entry],
-                          tp, pkt_size, addr);
-            rtl8169_mark_to_asic(desc, rx_buf_sz);
-            if (!skb) {
-                dev->stats.rx_dropped++;
-                continue;
-            }
-
-            rtl8169_rx_csum(skb, status);
-            skb_put(skb, pkt_size);
-            skb->protocol = eth_type_trans(skb, dev);
-
-            rtl8169_rx_vlan_tag(desc, skb);
-
-            if (likely(polling))
-                napi_gro_receive(&tp->napi, skb);
-            else
-                netif_rx(skb);
+            rtl8169_rx_deliver(tp, entry, polling);

              dev->stats.rx_bytes += pkt_size;
              dev->stats.rx_packets++;
@@ -4706,10 +4959,36 @@ static int rtl8169_rx_interrupt(struct n
          }
      }

-    count = cur_rx - tp->cur_rx;
+    replenish_rx_cursor_delta = count = cur_rx - tp->cur_rx;
      tp->cur_rx = cur_rx;

-    tp->dirty_rx += count;
+    /*   try to replenish buffers that any previous rtl8169_rx_deliver
+     *   failed to.   Note that these may not be contiguous  -
+     *   alloc success and fail may be interleaved.
+     *   replenish_rx_cursor marks the earliest unreplenished.
+     */
+
+    number_to_replenish = (tp->cur_rx - tp->totl_rx_replenished);
+
+    if (number_to_replenish > 0) {
+        replenish_rx_cursor_delta =
+            rtl8169_rx_fill(tp, tp->replenish_rx_cursor, 0,
+ &number_to_replenish, GFP_ATOMIC);
+        if (!replenish_rx_cursor_delta)
+            netif_info(tp, intr, dev, "no Rx buffer allocated\n");
+        tp->totl_rx_replenished += number_to_replenish;
+    }
+    tp->replenish_rx_cursor =
+        ((tp->replenish_rx_cursor +
+          replenish_rx_cursor_delta) % tp->num_rx_allocd);
+
+    /*
+     * exhaustion of available buffers may kill the Rx process.
+     * the previous code tries to replenish but may fail. To prevent that,
+     * set or let default rx_copybreak to maximum value to copy every 
buffer.
+     */
+    if ((tp->totl_rx_replenished + tp->num_rx_allocd) == tp->cur_rx)
+        netif_emerg(tp, intr, dev, "Rx buffers exhausted\n");

      return count;
  }

