From: Daniel Drake <dsd@gentoo.org>
Subject: Driver for Rsltek 8139D / Silan SC92031
Date: Fri, 02 Jun 2006 21:16:53 +0100
Message-ID: <44809CB5.50501@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070701060400090506070007"
Cc: cantao@thorus-scisoft.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:13718 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932553AbWFBUQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 16:16:54 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070701060400090506070007
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Here's a strange one. Cantao (on CC) bought what he thought was a cheap 
realtek PCI NIC, it actually turns out it is a Rsltek (yes, Rsltek) 
8139D card.

It includes an old (2.4/2.5) driver which claims to be for Silan SC92031 
(attached).

The driver has some very obvious similarities with 8139too, however the 
register layout and usage is quite different.

Has anyone got any idea whats going on here? It seems like something 
based on a realtek chip, but not...

Daniel


--------------070701060400090506070007
Content-Type: text/x-csrc;
 name="sc92031.c"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
 filename="sc92031.c"

/***************************************************************************
                          sl.c  - 8139D  Fast Ethernet driver
                             -------------------
    begin                : Ò»  8ÔÂ  6 15:05:44 CST 2002
    copyright            : (C) 2002 by gaoyonghong
    email                : gyh1@localhost.localdomain
 ***************************************************************************/

#define DRV_NAME      "Rsltek 8139"
#define DRV_VERSION   "1.0.0"

#define SILAN_DRIVER_NAME  DRV_NAME"Rsltek 8139D PCI Fast Ethernet driver  v"DRV_VERSION

#ifndef __KERNEL__
#define __KERNEL__
#endif

#include <linux/config.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/compiler.h>
#include <linux/pci.h>
#include <linux/init.h>
#include <linux/ioport.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/skbuff.h>
#include <linux/rtnetlink.h>
#include <linux/ethtool.h>
#include <linux/crc32.h>
#include <linux/delay.h>
#include <asm/io.h>
#include <asm/delay.h>
#include <asm/errno.h>
#include <asm/uaccess.h>

#define USE_IO_OPS

#ifdef SILAN_DEBUG
// note: prints function name for you
#define PDEBUG(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
#else
#define PDEBUG(fmt, args...)
#endif


#ifdef SILAN_NDEBUG
#define assert(expr)   do { } while (0)
#else
#define assert(expr) \
        if(!(expr)) {					\
        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
        #expr,__FILE__,__FUNCTION__,__LINE__);		\
        }
#endif


/* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).*/
static int multicast_filter_limit = 64;

/* Size of the in-memory receive ring. */
#define RX_BUF_LEN_IDX  3 /* 0==8K, 1==16K, 2==32K, 3==64K ,4==128K*/
#define RX_BUF_LEN	(8192 << RX_BUF_LEN_IDX)

/* Number of Tx descriptor registers. */
#define  NUM_TX_DESC	   4

/* max supported ethernet frame size -- must be at least (dev->mtu+14+4).*/
#define MAX_ETH_FRAME_SIZE	  1536

/* Size of the Tx bounce buffers -- must be at least (dev->mtu+14+4). */
#define TX_BUF_SIZE    MAX_ETH_FRAME_SIZE
#define TX_BUF_TOT_LEN    (TX_BUF_SIZE * NUM_TX_DESC)

/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6==1024, 7==end of packet. */
#define RX_FIFO_THRESH   7 /* Rx buffer level before first PCI xfer.  */

/* Time in jiffies before concluding the transmitter is hung. */
#define TX_TIMEOUT   (4*HZ)

#define SILAN_STATE_NUM    2  /* number of ETHTOOL_GSTATS */

enum  work_mode {
   Autoselect = 0x00,
   M10_Half   = 0x01,
   M10_Full   = 0x02,
   M100_Half  = 0x04,
   M100_Full  = 0x08,
} work_mode;


struct tx_info {
  struct sk_buff *skb;
  dma_addr_t  mapping;
};

struct Mii_ioctl_data {
  u32  phy_id;
  u32  reg_num;
  u32  val_in;
  u32  val_out;
};


#if LINUX_VERSION_CODE > KERNEL_VERSION(2,4,18)
static struct{ 
     const char  string[ETH_GSTRING_LEN];
} ethtool_stats_keys[] = {
     {"tx_timeout"},
     {"rx_loss"},
};
#endif


struct pci_device_id silan_pci_tbl[ ] __devinitdata = {
   { 0x1904, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0 ,0 , 0},
   {0,}
};

MODULE_DEVICE_TABLE(pci, silan_pci_tbl);


 /* Symbolic offsets to registers. */
enum SILAN_registers {
   Config0    = 0x00,         // Config0 
   Config1    = 0x04,         // Config1
   RxBufWPtr  = 0x08,         // Rx buffer writer poiter
   IntrStatus = 0x0C,         // Interrupt status
   IntrMask   = 0x10,         // Interrupt mask
   RxbufAddr  = 0x14,         // Rx buffer start address
   RxBufRPtr  = 0x18,         // Rx buffer read pointer
   Txstatusall = 0x1C,        // Transmit status of all descriptors
   TxStatus0  = 0x20,	      // Transmit status (Four 32bit registers).
   TxAddr0    = 0x30,         // Tx descriptors (also four 32bit).
   RxConfig   = 0x40,         // Rx configuration
   MAC0	      = 0x44,	      // Ethernet hardware address.
   MAR0	      = 0x4C,	      // Multicast filter.
   RxStatus0  = 0x54,         // Rx status
   TxConfig   = 0x5C,         // Tx configuration
   PhyCtrl    = 0x60,         // physical control
   FlowCtrlConfig = 0x64,     // flow control
   Miicmd0    = 0x68,         // Mii command0 register
   Miicmd1    = 0x6C,         // Mii command1 register
   Miistatus  = 0x70,         // Mii status register
   Timercnt   = 0x74,         // Timer counter register
   TimerIntr  = 0x78,         // Timer interrupt register
   PMConfig   = 0x7C,         // Power Manager configuration
   CRC0       = 0x80,         // Power Manager CRC ( Two 32bit regisers)
   Wakeup0    = 0x88,         // power Manager wakeup( Eight 64bit regiser)
   LSBCRC0    = 0xC8,         // power Manager LSBCRC(Two 32bit regiser)
   TestD0     = 0xD0,
   TestD4     = 0xD4,
   TestD8     = 0xD8,
};

#define MII_BMCR            0        // Basic mode control register
#define MII_BMSR            1        // Basic mode status register
#define Mii_JAB             16
#define Mii_OutputStatus    24

#define BMCR_FULLDPLX       0x0100    // Full duplex               
#define BMCR_ANRESTART      0x0200    // Auto negotiation restart   
#define BMCR_ANENABLE       0x1000    // Enable auto negotiation    
#define BMCR_SPEED100       0x2000    // Select 100Mbps             
#define BMSR_LSTATUS        0x0004    // Link status 
#define PHY_16_JAB_ENB      0x1000  
#define PHY_16_PORT_ENB     0x1               

                             
enum IntrStatusBits {
   LinkFail       = 0x80000000,
   LinkOK         = 0x40000000,
   TimeOut        = 0x20000000,
   RxOverflow     = 0x0040,
   RxOK           = 0x0020,
   TxOK           = 0x0001,
   IntrBits = LinkFail|LinkOK|TimeOut|RxOverflow|RxOK|TxOK,
};

enum TxStatusBits {
   TxCarrierLost = 0x20000000,
   TxAborted     = 0x10000000,
   TxOutOfWindow = 0x08000000,
   TxNccShift    = 22,
   EarlyTxThresShift = 16,
   TxStatOK      = 0x8000,
   TxUnderrun    = 0x4000,
   TxOwn         = 0x2000,
};

enum RxStatusBits {
   RxStatesOK   = 0x80000,
   RxBadAlign   = 0x40000,
   RxHugeFrame  = 0x20000,
   RxSmallFrame = 0x10000,
   RxCRCOK      = 0x8000,
   RxCrlFrame   = 0x4000,
   Rx_Broadcast = 0x2000,
   Rx_Multicast = 0x1000,
   RxAddrMatch  = 0x0800,
   MiiErr       = 0x0400,
};

enum RxConfigBits {
   RxFullDx    = 0x80000000,
   RxEnb       = 0x40000000,
   RxSmall     = 0x20000000,
   RxHuge      = 0x10000000,
   RxErr       = 0x08000000,
   RxAllphys   = 0x04000000,
   RxMulticast = 0x02000000,
   RxBroadcast = 0x01000000,
   RxLoopBack  = (1 << 23) | (1 << 22),
   LowThresholdShift  = 12,
   HighThresholdShift = 2,
};

enum TxConfigBits {
   TxFullDx       = 0x80000000,
   TxEnb          = 0x40000000,
   TxEnbPad       = 0x20000000,
   TxEnbHuge      = 0x10000000,
   TxEnbFCS       = 0x08000000,
   TxNoBackOff    = 0x04000000,
   TxEnbPrem      = 0x02000000,
   TxCareLostCrs  = 0x1000000,
   TxExdCollNum   = 0xf00000,
   TxDataRate     = 0x80000,
};

enum PhyCtrlconfigbits {
   PhyCtrlAne         = 0x80000000,
   PhyCtrlSpd100      = 0x40000000,
   PhyCtrlSpd10       = 0x20000000,
   PhyCtrlPhyBaseAddr = 0x1f000000,
   PhyCtrlDux         = 0x800000,
   PhyCtrlReset       = 0x400000,
};      

enum FlowCtrlConfigBits {
   FlowCtrlFullDX = 0x80000000,
   FlowCtrlEnb    = 0x40000000,
};

enum Config0Bits {
   Cfg0_Reset  = 0x80000000,
   Cfg0_Anaoff = 0x40000000,
   Cfg0_LDPS   = 0x20000000,
};

enum Config1Bits {
   Cfg1_EarlyRx = 1 << 31,
   Cfg1_EarlyTx = 1 << 30,

   //rx buffer size
   Cfg1_Rcv8K   = 0x0,
   Cfg1_Rcv16K  = 0x1,
   Cfg1_Rcv32K  = 0x3,
   Cfg1_Rcv64K  = 0x7,
   Cfg1_Rcv128K = 0xf,
};

enum MiiCmd0Bits {
   Mii_Divider = 0x20000000,
   Mii_WRITE   = 0x400000,
   Mii_READ    = 0x200000,
   Mii_SCAN    = 0x100000,
   Mii_Tamod   = 0x80000,
   Mii_Drvmod  = 0x40000,
   Mii_mdc     = 0x20000,
   Mii_mdoen   = 0x10000,
   Mii_mdo     = 0x8000,
   Mii_mdi     = 0x4000,
};

enum MiiStatusBits {
    Mii_StatusBusy = 0x80000000,
};

enum PMConfigBits {
   PM_Enable  = 1 << 31,
   PM_LongWF  = 1 << 30,
   PM_Magic   = 1 << 29,
   PM_LANWake = 1 << 28,
   PM_LWPTN   = (1 << 27 | 1<< 26),
   PM_LinkUp  = 1 << 25,
   PM_WakeUp  = 1 << 24,
};

struct silan_private {
     void            *mmio_addr;
     struct pci_dev  *pdev;
     struct net_device_stats  net_stats;
     unsigned char   *rx_ring;
     unsigned long    dirty_rx;	                   // Index into the Rx buffer of next Rx pkt
     unsigned long    cur_tx;
     unsigned long    dirty_tx;
     struct tx_info   tx_info[NUM_TX_DESC];
     unsigned char   *tx_buf[NUM_TX_DESC];	   // Tx bounce buffers
     unsigned char   *tx_bufs;	                   // Tx bounce buffer region.
     dma_addr_t       rx_ring_dma;
     dma_addr_t       tx_bufs_dma;
     enum  work_mode  mediaopt;
     unsigned int     intr_status;
     unsigned int     media_link_speed;
     unsigned int     media_duplex;
     unsigned int     tx_early_ctrl;
     unsigned int     rx_early_ctrl;
     spinlock_t       lock;
     uint32_t         rx_config;
     uint32_t         tx_config;
     unsigned long    tx_timeouts;
     unsigned long    rx_loss;
     long             rx_value;
     int              packet_filter;
     uint32_t         txenablepad;
};

#ifdef USE_IO_OPS

#define SILAN_R8(reg)           inb(((unsigned long)ioaddr) + (reg))
#define SILAN_R16(reg)          inw(((unsigned long)ioaddr) + (reg))
#define SILAN_R32(reg)          ((unsigned long)inl(((unsigned long)ioaddr) + (reg)))
#define SILAN_W8(reg, val8)     outb ((val8), ((unsigned long)ioaddr) + (reg))
#define SILAN_W16(reg, val16)   outw ((val16), ((unsigned long)ioaddr) + (reg))
#define SILAN_W32(reg, val32)   outl ((val32), ((unsigned long)ioaddr) + (reg))
#undef readb
#undef readw
#undef readl
#undef writeb
#undef writew
#undef writel
#define readb(addr)       inb((unsigned long)(addr))
#define readw(addr)       inw((unsigned long)(addr))
#define readl(addr)       inl((unsigned long)(addr))
#define writeb(val,addr)  outb((val),(unsigned long)(addr))
#define writew(val,addr)  outw((val),(unsigned long)(addr))
#define writel(val,addr)  outl((val),(unsigned long)(addr))

#else
// read/write MMIO register
#define SILAN_R8(reg)           readb (ioaddr + (reg))
#define SILAN_R16(reg)          readw (ioaddr + (reg))
#define SILAN_R32(reg)          (unsigned long)readl (ioaddr + (reg))
#define SILAN_W8(reg, val8)     writeb ((val8), ioaddr + (reg))
#define SILAN_W16(reg, val16)   writew ((val16), ioaddr + (reg))
#define SILAN_W32(reg, val32)   writel ((val32), ioaddr + (reg))

#endif /* USE_IO_OPS */

MODULE_AUTHOR ("gaoyonghong");
MODULE_DESCRIPTION ("Rsltek 8139D PCI Fast Ethernet Adapter driver");
MODULE_LICENSE("GPL");

MODULE_PARM (multicast_filter_limit, "i");
MODULE_PARM (work_mode, "i");

MODULE_PARM_DESC (multicast_filter_limit, "Rsltek 8139D  maximum number of filtered multicast addresses");
MODULE_PARM_DESC (work_mode,"Rsltek 8139D netcard media method");


/* Index to Function */
static int  silan_probe(struct pci_dev *pdev,const struct pci_device_id *id);
static void silan_hw_init(struct net_device *dev);
static int  silan_open(struct net_device *dev);
static int  silan_start_xmit(struct sk_buff *skb, struct net_device *dev);
static void silan_rx(struct net_device *dev);
static int  silan_close(struct net_device *dev);
static void silan_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
static int  netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);

static void silan_config_media(struct net_device *dev);
static void mii_cmd_select(void *ioaddr, unsigned long cmd, unsigned long *phys);
static void silan_init_ring(struct net_device *dev);
static void silan_tx_clear(struct silan_private *adapter);
static void silan_tx_timeout(struct net_device *device);
static void silan_tx_interrupt(struct net_device *dev);
static void silan_rx_err(uint32_t rx_status, struct net_device *dev, 
                         struct silan_private *adapter, uint32_t rx_size);
static void silan_mlink_intr(struct net_device *dev);
static void silan_remove(struct pci_dev *pdev);
static void Mii_ethtool_gset(void *ioaddr, struct ethtool_cmd *ecmd);
static int  Mii_ethtool_sset(void *ioaddr, struct ethtool_cmd *ecmd);
static int  Mii_link_ok(struct net_device *dev, void *ioaddr);
static int  Mii_restart(void *ioaddr);

static int  netdev_ethtool_ioctl(struct net_device *dev, void *useraddr);
static struct net_device_stats *silan_get_stats(struct net_device *dev);
static  uint32_t  silan_ether_crc32(unsigned long length, unsigned char *data);
static void silan_set_multi_list(struct net_device *dev);
static void silan_rx_mode(struct net_device *dev);

#ifdef CONFIG_PM
static int  silan_suspend(struct pci_dev *pdev, uint32_t state);
static int  silan_resume(struct pci_dev *pdev);
#endif


static int __devinit silan_probe(struct pci_dev *pdev,const struct pci_device_id *id)
{
    struct net_device *dev = NULL;
    struct silan_private *adapter;
    uint32_t pio_start, pio_end, pio_flags, pio_len;
    unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
    void *ioaddr;
    int  rc;
    int  i;
    uint8_t pci_rev;
    uint16_t pci_command;

    assert (pdev != NULL);
    assert (id != NULL);

    pci_read_config_byte(pdev, PCI_REVISION_ID, &pci_rev);

    if ((pdev->vendor == 0x1904) && (pdev->device == 0x8139)) {
         printk(KERN_INFO "pci dev %s (id %04x:%04x rev %02x) \n",
             pdev->slot_name, pdev->vendor, pdev->device, pci_rev);
    } else {
    	 printk( KERN_INFO " unkown chip \n");
    	 return -ENODEV;
    }
    	
    // configure pci command
    pci_read_config_word(pdev, PCI_COMMAND, &pci_command);

    if ((pci_command & (PCI_COMMAND_MASTER | PCI_COMMAND_MEMORY |PCI_COMMAND_IO)) != 0x7) {
         pci_command |= PCI_COMMAND_MASTER | PCI_COMMAND_MEMORY |PCI_COMMAND_IO;
         pci_write_config_word(pdev, PCI_COMMAND, pci_command);
    }

    dev = alloc_etherdev(sizeof(*adapter));
    if (dev == NULL) {
        printk (KERN_ERR "%s: Unable to alloc new net device\n", pdev->slot_name);
        return -ENOMEM;
    }

    SET_MODULE_OWNER(dev);
    adapter = dev->priv;
    memset(adapter,0 ,sizeof(*adapter));
    adapter->pdev = pdev;

    /* enable device (incl. PCI PM wakeup and hotplug setup) */
    rc = pci_enable_device(pdev);
    if (rc){
       goto err_out;
    }
    
    pio_start = pci_resource_start(pdev, 1);
    pio_end = pci_resource_end(pdev, 1);
    pio_flags = pci_resource_flags(pdev, 1);
    pio_len = pci_resource_len(pdev, 1);

    mmio_start = pci_resource_start(pdev, 0);
    mmio_end = pci_resource_end(pdev, 0);
    mmio_flags = pci_resource_flags(pdev, 0);
    mmio_len = pci_resource_len(pdev, 0);

    PDEBUG("PIO region size == 0x%02x\n", pio_len);
    PDEBUG("MMIO region size == 0x%02lx\n", mmio_len);

#ifdef USE_IO_OPS
    /* make sure PCI base addr 0 is PIO */
    if (!(pio_flags & IORESOURCE_IO)) {
          printk(KERN_ERR "%s: region #0 not a PIO resource, aborting\n",

                  pdev->slot_name);
          rc = -ENODEV;
          goto err_out;
    }
    /* check for PCI region reporting */
    if (pio_len < 0x80) {
          printk(KERN_ERR "%s: Invalid PCI I/O region size(s), aborting\n",
                  pdev->slot_name);
          rc = -ENODEV;
          goto err_out;
    }
#else
    // make sure PCI base addr 1 is MMIO
    if (!(mmio_flags & IORESOURCE_MEM)) {
         printk(KERN_ERR "%s: region #1 not an MMIO resource, aborting\n",
               pdev->slot_name);
         rc = -ENODEV;
         goto err_out;
    }
    
    if (mmio_len < 0x80) {
         printk(KERN_ERR "%s: Invalid PCI mem region size(s), aborting\n",
                pdev->slot_name);
         rc = -ENODEV;
         goto err_out;
    }
#endif

    rc = pci_request_regions(pdev, (char *)DRV_NAME);
    if (rc)
       goto err_out;

    /* enable PCI bus-mastering */
    pci_set_master (pdev);

#ifdef USE_IO_OPS
    ioaddr = (void *)pio_start;
    dev->base_addr = pio_start;
    adapter->mmio_addr = ioaddr;
#else
    // ioremap MMIO region
    ioaddr = ioremap(mmio_start, mmio_len);
    if (ioaddr == NULL) {
       printk (KERN_ERR "%s: cannot remap MMIO, aborting\n", pdev->slot_name);
       rc = -EIO;
       goto err_out;
    }
    dev->base_addr = (unsigned long)ioaddr;
    adapter->mmio_addr = ioaddr;
#endif /* USE_IO_OPS */

    printk(KERN_INFO "PCI PM Wakeup\n");
    SILAN_W32(PMConfig, ((~PM_LongWF & ~PM_LWPTN ) | PM_Enable));

    assert (ioaddr != NULL);
    assert (dev != NULL);
    assert (adapter != NULL);

    ((uint32_t *)(dev->dev_addr))[0] = be32_to_cpu(SILAN_R32(MAC0));
    ((uint16_t *)(dev->dev_addr))[2] = be16_to_cpu(SILAN_R32(MAC0+4));	
  	      	
    /* The SILAN-specific entries in the device structure. */
    dev->open = silan_open;
    dev->hard_start_xmit = silan_start_xmit;
    dev->stop = silan_close;
    dev->get_stats = silan_get_stats;
    dev->set_multicast_list = silan_set_multi_list;
    dev->do_ioctl = netdev_ioctl;
    dev->tx_timeout = silan_tx_timeout;
    dev->watchdog_timeo = TX_TIMEOUT;

    dev->irq = pdev->irq;
    
    /* dev is fully set up and ready to use now */
    PDEBUG("register device named %s (%p)\n", dev->name, dev);
    i = register_netdev(dev);
    if (i)
       goto err_out;

    pci_set_drvdata(pdev, dev);
    spin_lock_init(&adapter->lock);
    adapter->packet_filter = dev->flags & (IFF_PROMISC|IFF_ALLMULTI|IFF_MULTICAST|IFF_BROADCAST);

    printk(KERN_INFO "%s: at 0x%lx, %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x,IRQ %d\n",
             dev->name, dev->base_addr,
             dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
             dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5],
             dev->irq);

    return 0;

err_out:
#ifndef USE_IO_OPS
    if (adapter->mmio_addr)
        iounmap(adapter->mmio_addr);
#endif /* !USE_IO_OPS */

    pci_release_regions(pdev);

#ifndef SILAN_NDEBUG
    memset(dev, 0, sizeof(struct net_device) + sizeof(struct silan_private));
#endif

    kfree(dev);
    dev = NULL;
    pci_set_drvdata(pdev, NULL);
    return rc;
}




static void mii_cmd_select(void *ioaddr, unsigned long cmd, unsigned long *phys)
{
   unsigned long mii_status;

   assert (ioaddr != NULL);
   
   SILAN_W32(Miicmd0, Mii_Divider);

   do {
       mii_status = 0;
       udelay(10);
       mii_status = SILAN_R32(Miistatus);

   } while (mii_status & Mii_StatusBusy);

   switch (cmd){
     case Mii_SCAN:
         SILAN_W32(Miicmd1, 0x1 << 6);
         SILAN_W32(Miicmd0, Mii_Divider | Mii_SCAN);
         break;

     case Mii_READ:
         SILAN_W32(Miicmd1, phys[0] << 6);
         SILAN_W32(Miicmd0, Mii_Divider | Mii_READ);
         break;

     default:  /* WRITE*/
         SILAN_W32(Miicmd1, phys[0] << 6 | phys[1] << 11);
         SILAN_W32(Miicmd0, Mii_Divider | Mii_WRITE);
         break ;
   }

   do {
         udelay(10);
         mii_status = SILAN_R32(Miistatus);
   } while (mii_status & Mii_StatusBusy);

   if (Mii_READ == cmd) {
        phys[1] = (mii_status >> 13) & 0xffff;
   }
}


static void silan_config_media(struct net_device *dev)
{
   struct silan_private *adapter = dev->priv;
   void  *ioaddr = adapter->mmio_addr;
   unsigned long   phys[2];
   unsigned long   temp;

   assert (dev != NULL);
   assert (adapter != NULL);
   assert (ioaddr != NULL);
   
   adapter->mediaopt = work_mode;
   
   temp = SILAN_R32(PhyCtrl);
   temp &=~(PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10);
   temp |= (PhyCtrlAne | PhyCtrlReset);
   
   switch (adapter->mediaopt) {
      case Autoselect:
           printk(KERN_INFO "autoselect supported\n");
           temp |= (PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10);
           break;
           
      case M10_Half:
           printk(KERN_INFO "10M half_duplex supported\n");
           temp |= PhyCtrlSpd10;
           break;
       
      case M10_Full:
           printk(KERN_INFO "10M Full_duplex supported\n");
           temp |= (PhyCtrlDux |PhyCtrlSpd10);
           break;
           
      case M100_Half:
           printk(KERN_INFO "100M half_duplex supported\n");
           temp |= PhyCtrlSpd100;
           break;
           
      case M100_Full:
           printk(KERN_INFO "100M full_duplex supported\n");
           temp |= (PhyCtrlDux |PhyCtrlSpd100);
           break;
      
      default:
           break;
   }

   SILAN_W32(PhyCtrl,temp);

   mdelay(10);
   temp &=~PhyCtrlReset;
   SILAN_W32(PhyCtrl,temp);
   
   mdelay(1);
   phys[0] = Mii_JAB;
   phys[1] = PHY_16_JAB_ENB |PHY_16_PORT_ENB;
   mii_cmd_select(ioaddr, Mii_WRITE, phys);

   netif_carrier_off(dev);
   netif_stop_queue(dev);
   mii_cmd_select(ioaddr, Mii_SCAN, phys);

   return;
}


static unsigned char shade_map[ ] = { 0x0, 0x8, 0x4, 0xc, 0x2, 0xa, 0x6, 0xe,
                                      0x1, 0x9, 0x5, 0xd, 0x3, 0xb, 0x7, 0xf };

static uint32_t silan_ether_crc32(unsigned long length, unsigned char *data)
{
    uint32_t crc = 0xffffffff;
    uint32_t crcr = 0;
    int  current_octet = 0;
    int  bit = 0;

    for (; length>0; length--) {
        current_octet = *data++;
        
        for (bit = 0; bit < 8; bit++){
            if (((current_octet& 0x1)^(crc & 0x1)) != 0) {
                crc >>= 1;
                crc ^= 0xEDB88320;
            } else {
                crc >>= 1;
            }
            current_octet >>= 1;
        }
    }
   
    crcr = shade_map[crc >> 28];
    crcr |= (shade_map[(crc >> 24) & 0xf] << 4);
    crcr |= (shade_map[(crc >> 20) & 0xf] << 8);
    crcr |= (shade_map[(crc >> 16) & 0xf] << 12);
    crcr |= (shade_map[(crc >> 12) & 0xf] << 16);
    crcr |= (shade_map[(crc >> 8) & 0xf] << 20);
    crcr |= (shade_map[(crc >> 4) & 0xf] << 24);
    crcr |= (shade_map[crc & 0xf] << 28);

    return crcr;
}


static void  silan_set_multi_list(struct net_device *dev)
{

    struct silan_private * adapter = dev->priv;
    void * ioaddr = adapter->mmio_addr;
    uint32_t mc_filter[2]={0,0};
    int i, j, mc_max;
    uint32_t  crc;
    struct dev_mc_list   *mclist;

    if(dev->flags & IFF_PROMISC) {
            printk(" %s: promisc mode is enable.\n",dev->name);
            mc_filter[0] = mc_filter[1] = 0xffffffff;
    } else if (dev->flags & IFF_ALLMULTI) {
            printk("%s: allmulti mode is enable.\n",dev->name);
            mc_filter[0] = mc_filter[1] = 0xffffffff;
    }  else if ((dev->flags & IFF_MULTICAST) && (dev->mc_count > 0)) {
                 assert(NULL != dev->mc_list);
                 PDEBUG("multicast mode is enabled.\n");

                 mc_filter[0] = mc_filter[1] = 0;
                 mc_max = dev->mc_count > multicast_filter_limit ? multicast_filter_limit : dev->mc_count;
                 mclist = dev->mc_list;

                for (i=0; (NULL!= mclist) && (i < mc_max); i++, mclist=mclist->next) {
                      j=0;

                      crc = ~silan_ether_crc32(ETH_ALEN, mclist->dmi_addr);
                      crc >>= 24;

                      if (crc & 0x1)      j |= 0x2;
                      if (crc & 0x2)      j |= 0x1;
                      if (crc & 0x10)     j |= 0x20;
                      if (crc & 0x20)     j |= 0x10;
                      if (crc & 0x40)     j |= 0x8;
                      if (crc & 0x80)     j |= 0x4;

                      if (j > 31) {
                          mc_filter[0] |= (0x1 << (j - 32));
                      } else {
                          mc_filter[1] |= (0x1 << j);
                      }
               }
            }

     SILAN_W32 ((MAR0 + 0), mc_filter[0]);
     SILAN_W32 ((MAR0 + 4), mc_filter[1]);
     
     if ((netif_carrier_ok(dev))
         && (adapter->packet_filter != (dev->flags & (IFF_PROMISC|IFF_ALLMULTI|IFF_MULTICAST|IFF_BROADCAST)))) {

            silan_rx_mode(dev);
            adapter->packet_filter = dev->flags & (IFF_PROMISC|IFF_ALLMULTI|IFF_MULTICAST|IFF_BROADCAST);
     }

}



static void silan_rx_mode(struct net_device *dev)
{
    struct silan_private * adapter = dev->priv;
    void * ioaddr = adapter->mmio_addr;
    uint32_t   rx_mode = 0;

    assert (dev != NULL);
    assert (adapter != NULL);
    assert (ioaddr != NULL);

    PDEBUG("adapter->rx_config = 0x%x  dev->flags = 0x%x\n", adapter->rx_config, dev->flags);

    if (adapter->packet_filter & IFF_PROMISC)
          rx_mode = RxEnb|RxSmall|RxHuge|RxErr|RxBroadcast|RxMulticast|RxAllphys;

    if (adapter->packet_filter & (IFF_ALLMULTI | IFF_MULTICAST))
          rx_mode = RxEnb|RxMulticast;

    if (adapter->packet_filter & IFF_BROADCAST)
          rx_mode = RxEnb|RxBroadcast;

    if ((adapter->rx_config | rx_mode) != adapter->rx_config) {
           adapter->rx_config |= rx_mode;
           SILAN_W32(RxConfig, adapter->rx_config);
    }

   PDEBUG("ADAPTER->RX_CONFIG = 0x%x\n", adapter->rx_config);

}


/* Initialize the Rx and Tx rings, along with various 'dev' bits. */
static void silan_init_ring(struct net_device *dev)
{
    struct silan_private *adapter = dev->priv;
    int i;
    
    assert (dev != NULL);

    adapter->cur_tx = 0;
    adapter->dirty_tx = 0;

    for (i = 0; i < NUM_TX_DESC; i++) {
         adapter->tx_buf[i] = &adapter->tx_bufs[i * TX_BUF_SIZE];
         adapter->tx_info[i].skb = NULL;
         adapter->tx_info[i].mapping = 0;
    }

    adapter->dirty_rx = adapter->rx_ring_dma;
    adapter->media_duplex = 0;
    adapter->media_link_speed = 0;
}


static void silan_tx_clear(struct silan_private *adapter)
{
    int       i;

    adapter->cur_tx = 0;
    adapter->dirty_tx = 0;

    /* dump the unsent Tx packets */
    for (i = 0; i < NUM_TX_DESC; i++) {
           if (adapter->tx_info[i].mapping != 0) {
                     pci_unmap_single(adapter->pdev, adapter->tx_info[i].mapping,
                                      adapter->tx_info[i].skb->len, PCI_DMA_TODEVICE);
                     adapter->tx_info[i].mapping = 0;

           }

           if (adapter->tx_info[i].skb ) {
                  dev_kfree_skb(adapter->tx_info[i].skb);
                  adapter->tx_info[i].skb = NULL;
                  adapter->net_stats.tx_dropped++;
           }
     }
}


/* Start the hardware at open or resume.*/
static void  silan_hw_init(struct net_device *dev)
{
    struct silan_private *adapter = dev->priv;
    void *ioaddr = adapter->mmio_addr;
    int i;

    assert (dev != NULL);
    assert (adapter != NULL);
    assert (ioaddr != NULL);
    
    //disable PM
    SILAN_W32(PMConfig,0);

    // soft reset the chip
    SILAN_W32(Config0, Cfg0_Reset);
    mdelay(200);
    SILAN_W32(Config0, 0);
    mdelay(10);
    
    //disable interrupt
    SILAN_W32(IntrMask, 0);
   
    // clear multicast address
    SILAN_W32(MAR0 + 0, 0);
    SILAN_W32(MAR0 + 4, 0);

    // init Rx ring buffer DMA address
    SILAN_W32(RxbufAddr, adapter->rx_ring_dma);

    // init Tx buffer DMA addresses
    for (i = 0; i < NUM_TX_DESC; i++)
          SILAN_W32(TxAddr0 + (i * 4),
                    adapter->tx_bufs_dma + (adapter->tx_buf[i] - adapter->tx_bufs));

    // configure rx buffer size
    if (adapter->tx_early_ctrl && adapter->rx_early_ctrl)
           SILAN_W32(Config1, Cfg1_EarlyRx | Cfg1_EarlyTx | Cfg1_Rcv64K | RX_FIFO_THRESH << 21);
    else if (adapter->tx_early_ctrl)
              SILAN_W32( Config1, Cfg1_EarlyTx | Cfg1_Rcv64K);
         else if (adapter->rx_early_ctrl)
                   SILAN_W32(Config1, Cfg1_EarlyRx | Cfg1_Rcv64K | RX_FIFO_THRESH << 21);
              else
                   SILAN_W32(Config1, Cfg1_Rcv64K);

    // configure media mode
    silan_config_media(dev);

    //enable rx and tx
    if (netif_carrier_ok(dev)) {
       adapter->rx_config |= RxEnb;
       adapter->tx_config |= TxEnb;
    } else {
       adapter->rx_config &= ~RxEnb;
       adapter->tx_config &= ~TxEnb;
    }

    SILAN_W32(RxConfig, adapter->rx_config);
    SILAN_W32(TxConfig, adapter->tx_config);
    
    /* calculate rx fifo overflow */
    adapter->rx_value = 0;
   
    //clear INT register
    adapter->intr_status = SILAN_R32(IntrStatus);

    // Enable all known interrupts by setting the interrupt mask.
    SILAN_W32(IntrMask, IntrBits);
}



static int silan_open(struct net_device *dev)
{
   struct silan_private *adapter = dev->priv;
   int retval;
   unsigned long flags;

   assert (dev != NULL);
   assert (adapter != NULL);

   retval = request_irq(dev->irq, silan_interrupt, SA_SHIRQ, dev->name, dev);
   if (retval) {
      return retval;
   }

   adapter->tx_bufs = pci_alloc_consistent(adapter->pdev, TX_BUF_TOT_LEN,
                                           &adapter->tx_bufs_dma);
   adapter->rx_ring = pci_alloc_consistent(adapter->pdev, RX_BUF_LEN,
                                           &adapter->rx_ring_dma);

   if (adapter->tx_bufs == NULL || adapter->rx_ring == NULL) {
        free_irq(dev->irq, dev);

        if (adapter->tx_bufs)
            pci_free_consistent(adapter->pdev, TX_BUF_TOT_LEN,
                                adapter->tx_bufs, adapter->tx_bufs_dma);
        if (adapter->rx_ring)
            pci_free_consistent(adapter->pdev, RX_BUF_LEN ,
                                adapter->rx_ring, adapter->rx_ring_dma);

        return -ENOMEM;
   }

   spin_lock_irqsave(&adapter->lock, flags);

   silan_init_ring(dev);  // initial tx/rx variable
   silan_hw_init(dev);    //  hardware initialize

   spin_unlock_irqrestore(&adapter->lock, flags);

   PDEBUG("%s: silan_open() ioaddr 0x%lx IRQ %d \n",
             dev->name, pci_resource_start (adapter->pdev, 1), dev->irq);

   return 0;
}


static void silan_tx_timeout(struct net_device *dev)
{
    struct silan_private *adapter = dev->priv;
    void *ioaddr = adapter->mmio_addr;
    int i;
    unsigned long flags;

    assert (dev != NULL);
    assert (adapter != NULL);
    assert (ioaddr != NULL);

    adapter->tx_timeouts++;
    printk("Tx is time out count:%ld\n", adapter->tx_timeouts);
    /* Disable interrupts by clearing the interrupt mask.*/
    SILAN_W32(IntrMask, 0);

    PDEBUG("%s: Tx queue cur entry %ld  dirty entry %ld  timeout counts %ld\n",
             dev->name, adapter->cur_tx, adapter->dirty_tx, adapter->tx_timeouts);

    for (i = 0; i < NUM_TX_DESC; i++) {
       PDEBUG("%s:  Tx descriptor %d is 0x%8.8lx.%s\n",
               dev->name, i, SILAN_R32(TxStatus0 +(i * 4)),
               i == (int)(adapter->dirty_tx % NUM_TX_DESC) ? " (queue head)" : "");

    }
    /* Stop a shared interrupt */
    spin_lock_irqsave(&adapter->lock, flags);
    silan_tx_clear(adapter);
    spin_unlock_irqrestore(&adapter->lock, flags);
    /* reset everything */
    silan_hw_init(dev);
    silan_set_multi_list(dev);
    netif_wake_queue(dev);
}


static int silan_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
     struct silan_private *adapter = dev->priv;
     void *ioaddr = adapter->mmio_addr;
     int entry;
     int len = skb->len;
    
     if(skb == NULL || len <= 0) {
         printk(KERN_WARNING "%s: driver layer request mode: skbuff==NULL\n", dev->name);
         return 0;
     }

     // Calculate the next Tx descriptor entry.
     entry = adapter->cur_tx % NUM_TX_DESC;

     assert(adapter->tx_info[entry].skb == NULL);
     assert(adapter->tx_info[entry].mapping == 0);

     adapter->tx_info[entry].skb = skb;
     
     /* for skb->len < 60, padding payload with 0x20. */
     if ((len < ETH_ZLEN) && (!adapter->txenablepad)) {
            //adapter->tx_info[entry].mapping = 0;
            memcpy(adapter->tx_buf[entry], skb->data, len);
            memset(adapter->tx_buf[entry] + len, 0x20, (ETH_ZLEN - len) );
            SILAN_W32(TxAddr0 + entry*4, adapter->tx_bufs_dma + (adapter->tx_buf[entry] - adapter->tx_bufs));
            len = ETH_ZLEN;
     } 
     else if ((long)skb->data & 3) {
                  //adapter->tx_info[entry].mapping = 0;
                  memcpy(adapter->tx_buf[entry], skb->data, len);
                  SILAN_W32(TxAddr0 + entry*4, adapter->tx_bufs_dma + (adapter->tx_buf[entry] - adapter->tx_bufs));
           } 
           else {
                  adapter->tx_info[entry].mapping =
                            pci_map_single(adapter->pdev, skb->data, len, PCI_DMA_TODEVICE);
                  SILAN_W32(TxAddr0 + entry*4, adapter->tx_info[entry].mapping);
           }
    
     if (len < 100)
            SILAN_W32(TxStatus0 + entry*4, len);
     else if (len <300)
            SILAN_W32(TxStatus0 + entry*4, 0x30000 | len);
          else
            SILAN_W32(TxStatus0 + entry*4, 0x50000 | len);

     dev->trans_start = jiffies;
     
     spin_lock_irq(&adapter->lock);
     adapter->cur_tx++;
    
     if ((adapter->cur_tx - adapter->dirty_tx) == NUM_TX_DESC)
           netif_stop_queue(dev);
           
     spin_unlock_irq(&adapter->lock);
     PDEBUG("%s: Queued Tx packet size %d to tx-buffer %d.\n",
                  dev->name, len, entry);
                  
     return 0;
}



static void silan_tx_interrupt(struct net_device *dev)
{
     struct silan_private *adapter = dev->priv;
     void *ioaddr = adapter->mmio_addr;
     int entry;
     unsigned long  dirty_tx;
     unsigned long  tx_status;

     assert (dev != NULL);
     assert (adapter != NULL);
     assert (ioaddr != NULL);


     dirty_tx = adapter->dirty_tx;

     while (adapter->cur_tx - dirty_tx > 0) {
          entry = dirty_tx % NUM_TX_DESC;
          tx_status = SILAN_R32(TxStatus0 + (entry * 4));
          PDEBUG("entry = 0x%x, tx_status = 0x%8.8lx \n", entry, tx_status);

          if (!(tx_status & (TxStatOK | TxUnderrun | TxAborted))) {
                //printk("no tx packet will be transmitted .\n" );
                break;
          }

          if (tx_status & TxStatOK) {
               adapter->net_stats.tx_bytes += tx_status & 0x1fff;
               adapter->net_stats.tx_packets++;
               /* Note: TxCarrierLost is always asserted at 100mbps. */
               adapter->net_stats.collisions += (tx_status >> 22) & 0xf;
          }

          if (tx_status & (TxOutOfWindow | TxAborted)) {
                printk (KERN_NOTICE "%s: Transmit error.\n",dev->name);
                adapter->net_stats.tx_errors++;

                if (tx_status & TxAborted)
                   adapter->net_stats.tx_aborted_errors++;

                if (tx_status & TxCarrierLost) {
                    adapter->net_stats.tx_carrier_errors++;
                }

                if (tx_status & TxOutOfWindow)
                     adapter->net_stats.tx_window_errors++;

           }

         if (tx_status & TxUnderrun)
                adapter->net_stats.tx_fifo_errors++;
         
         // free the TX packets
         if (adapter->tx_info[entry].mapping != 0) {
               pci_unmap_single(adapter->pdev, adapter->tx_info[entry].mapping,
                                 adapter->tx_info[entry].skb->len, PCI_DMA_TODEVICE);
               adapter->tx_info[entry].mapping = 0;
         }

         dev_kfree_skb_irq(adapter->tx_info[entry].skb);
         adapter->tx_info[entry].skb = NULL;

         PDEBUG("%s: tx done, slot %ld.\n", dev->name, dirty_tx);
         dirty_tx++;
     }

#ifndef SILAN_NDEBUG
     if (adapter->cur_tx - dirty_tx > NUM_TX_DESC) {
          printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs %ld.\n",
                   dev->name, dirty_tx, adapter->cur_tx);
          dirty_tx += NUM_TX_DESC;

     }
#endif

     if (adapter->dirty_tx != dirty_tx) {
           adapter->dirty_tx = dirty_tx;
           if (netif_queue_stopped (dev))
                netif_wake_queue (dev);
     }
}


static void  silan_rx_err(uint32_t rx_status, struct net_device *dev,
                           struct silan_private *adapter, uint32_t rx_size)
{
    PDEBUG("%s: Ethernet frame had rx error, status %8.8x.\n",
             dev->name, rx_status);
    if((rx_size > (MAX_ETH_FRAME_SIZE + 4)) || (rx_size < 16)) {
    	  PDEBUG(KERN_NOTICE "%s: Ethernet frame lengh too long or short!\n", dev->name);
    	  adapter->net_stats.rx_errors++;
    	  adapter->net_stats.rx_length_errors++;
    }
       
    if (!(rx_status & RxStatesOK)) {
    	adapter->net_stats.rx_errors++;
    	
       if (rx_status & (RxHugeFrame | RxSmallFrame )){
            PDEBUG(KERN_NOTICE "%s: Ethernet frame lengh errors!\n", dev->name);
            adapter->net_stats.rx_length_errors++;
       }

       if (rx_status & RxBadAlign) {
          adapter->net_stats.rx_frame_errors++;
          PDEBUG("rx_frame_error\n");
       }

       if (!(rx_status & RxCRCOK))
          adapter->net_stats.rx_crc_errors++;
    } else {
          adapter->rx_loss++;
    }

}


static void silan_rx(struct net_device *dev)
{
    struct silan_private *adapter = dev->priv;
    void *ioaddr = adapter->mmio_addr;
    unsigned char  *rx_ring;
    unsigned long   cur_rx;
    unsigned long   ring_offset;
    uint32_t        rx_status;
    unsigned long   rx_size;
    unsigned long   pkt_size;
    unsigned long   semi_len;
    struct sk_buff  *skb;
    long            rx_len;

    assert (dev != NULL);
    assert (adapter != NULL);
    assert (ioaddr!= NULL);

    cur_rx = SILAN_R32(RxBufWPtr);
    /* cur_rx is only 17 bits in the RxBufWPtr register. if cur_rx can be used in physical space,
     * we need to change it to 32 bits physical address 
     */
    cur_rx |= adapter->rx_ring_dma & (~(unsigned long)(RX_BUF_LEN - 1));

    if(cur_rx < adapter->rx_ring_dma)
         cur_rx = cur_rx + RX_BUF_LEN;

    if(cur_rx >= adapter->dirty_rx)
        rx_len = (long)(cur_rx - adapter->dirty_rx);
    else
        rx_len = (long)(RX_BUF_LEN - (adapter->dirty_rx - cur_rx));

    rx_ring = adapter->rx_ring;
    ring_offset = (adapter->dirty_rx - adapter->rx_ring_dma) & (unsigned long)(RX_BUF_LEN - 1);

    PDEBUG("in rx cur_rx %8.8lx ring_dma %8.8x rx_len %ld ring_offset %8.8lx\n",
                   cur_rx, adapter->rx_ring_dma, rx_len, ring_offset);
    
    if (rx_len > RX_BUF_LEN) {
    	   PDEBUG("rx packets length > rx buffer\n");
           return;
    }
    
    if (rx_len == 0)
           return;

    spin_lock(&adapter->lock);

    while (rx_len > 0 ) {
         rx_status = *(uint32_t *)(rx_ring + ring_offset);
         rx_size = rx_status >> 20 ;
         rx_size = (rx_size + 3) & ~3; //for 4 bytes aligned
         pkt_size = rx_size - 4;   // Omit the four octet CRC from the length.

         PDEBUG("%s:rx_status %8.8x, rx_size %ld.\n", dev->name, rx_status, rx_size);

#if (SILAN_DEBUG > 1) 
     {
         PDEBUG ("%s: Frame contents\n ", dev->name);
         int i;
         for (i = 0; i < 30; i++){
             if (i % 10 == 0) printk ("\n");
             printk (" %2.2x", rx_ring[ring_offset + i]);
         }
          printk("\n");
      }
#endif

         if ((rx_status == 0) || (rx_size > (MAX_ETH_FRAME_SIZE + 4)) || (rx_size < 16) || !(rx_status & RxStatesOK)) {

               silan_rx_err (rx_status, dev, adapter,rx_size);
               break;

         }

         rx_len -= (long)(rx_size + 4);

         if (rx_len > RX_BUF_LEN) {
              printk(KERN_ERR "rx_len is too huge, rx_len = %ld\n", rx_len);
              break;
         }

         if (rx_len < 0) {
             printk(KERN_ERR "rx_len is too small\n");
             break;
         }

         // Malloc up new buffer
         skb = dev_alloc_skb(pkt_size + 2);

         if (skb == NULL) {
             printk (KERN_WARNING "%s: Couldn't allocate a skb_buff of size %ld. \n",
                      dev->name, pkt_size);
             adapter->net_stats.rx_dropped++;
         } 
         else {
             skb->dev = dev;
             skb_reserve(skb, 2);  // 16 byte align the IP fields.

             if ((ring_offset + rx_size) > RX_BUF_LEN) {
                   semi_len = (unsigned long)RX_BUF_LEN -(4 + ring_offset);// 4 bytes for receive frame header
                   memcpy(skb_put(skb, semi_len), &rx_ring[ring_offset + 4], semi_len);
                   memcpy(skb_put(skb, pkt_size - semi_len), rx_ring, pkt_size -semi_len);
             } 
             else {
#if HAS_IP_COPYSUM
                   eth_copy_and_sum (skb, &rx_ring[ring_offset + 4], pkt_size, 0);
                   skb_put (skb, pkt_size);
#else
                   memcpy(skb_put(skb,pkt_size),&rx_ring[ring_offset+4], pkt_size);
#endif
             }


             skb->protocol = eth_type_trans(skb, dev);
             dev->last_rx = jiffies;
             netif_rx(skb);
             adapter->net_stats.rx_bytes += pkt_size;
             adapter->net_stats.rx_packets++;

             if (rx_status & Rx_Multicast)
                  adapter->net_stats.multicast++;

             PDEBUG("rx_bytes = %ld,rx_packets = %ld,multicast = %ld.\n",
                       adapter->net_stats.rx_bytes, 
                       adapter->net_stats.rx_packets, adapter->net_stats.multicast);
        }

        ring_offset = (ring_offset + rx_size + 4)&(unsigned long)(RX_BUF_LEN - 1); // 4 bytes for receive frame head	
    }
    spin_unlock(&adapter->lock);

    adapter->dirty_rx = cur_rx;
    SILAN_W32(RxBufRPtr, adapter->dirty_rx);

    PDEBUG("%s: Done siln8139d_rx(), current dirty_rx = %8.8lx \n",
               dev->name, adapter->dirty_rx);
}



/* media link interrupt */
static void silan_mlink_intr(struct net_device *dev)
{
    struct silan_private *adapter = dev->priv;
    void *ioaddr = adapter->mmio_addr;
    unsigned long   phys[2];
    uint32_t        flow_cfg = 0;
   
    assert (dev != NULL);
    assert (adapter != NULL);
    assert (ioaddr != NULL);
   
    phys[0] = MII_BMSR;
    mii_cmd_select(ioaddr, Mii_READ, phys);
    PDEBUG("mii_status = %4.4lx\n", phys[1]);
   
    if ((phys[1] & BMSR_LSTATUS) == 0) {
       printk(KERN_INFO "%s: media is unconnected, link down, or incompatible connection\n",
               dev->name);
       netif_carrier_off(dev);
       netif_stop_queue(dev);
       adapter->net_stats.tx_carrier_errors++;
       mii_cmd_select(ioaddr, Mii_SCAN, phys);
       //disable rx/tx
       adapter->rx_config &= ~RxEnb;
       adapter->tx_config &= ~TxEnb;
       SILAN_W32(RxConfig, adapter->rx_config);
       SILAN_W32(TxConfig, adapter->tx_config);
       return;

    }

    printk(KERN_INFO "%s: media is connected--->", dev->name);
    netif_carrier_on(dev);
      
    phys[0] = Mii_OutputStatus;
    mii_cmd_select(ioaddr, Mii_READ, phys);
    adapter->media_duplex = (phys[1] & 0x4) ? DUPLEX_FULL : DUPLEX_HALF;
    adapter->media_link_speed = (phys[1] & 0x2) ? SPEED_100 :SPEED_10;

    printk(KERN_INFO "speed:%dM, duplex:%s.\n",
           adapter->media_link_speed, 
           (adapter->media_duplex == 0x0001)? "full":"half");
           
    mii_cmd_select(ioaddr, Mii_SCAN, phys);

    // Initial Tx/Rx configuration
    adapter->rx_config = (0x40 << LowThresholdShift) | (0x1c0 << HighThresholdShift);
    adapter->tx_config = 0x48800000 ;

    if (adapter->txenablepad)
         adapter->tx_config |= 0x20000000;
         
    if (adapter->media_link_speed == SPEED_10)
         adapter->tx_config |= 0x80000;

    // configure rx mode
     silan_rx_mode(dev);

    /* configure Rx register */
    silan_set_multi_list(dev);

    if (adapter->media_duplex == DUPLEX_FULL) {
         adapter->rx_config |= RxFullDx;
         adapter->tx_config |= TxFullDx;
         flow_cfg = FlowCtrlFullDX | FlowCtrlEnb;
    } else {
         adapter->rx_config &= ~RxFullDx;
         adapter->tx_config &= ~TxFullDx;
    }

    //enable rx and tx
    adapter->rx_config |= RxEnb;
    adapter->tx_config |= TxEnb;
    SILAN_W32(RxConfig, adapter->rx_config);
    SILAN_W32(TxConfig, adapter->tx_config);
    SILAN_W32(FlowCtrlConfig, flow_cfg);

    netif_start_queue(dev);
}



static void silan_interrupt(int irq, void *dev_instance, struct pt_regs *regs) 
{
    struct net_device *dev = (struct net_device *) dev_instance;
    struct silan_private *adapter = dev->priv;
    void *ioaddr = adapter->mmio_addr;

    SILAN_W32(IntrMask, 0);
    adapter->intr_status = SILAN_R32(IntrStatus) & IntrBits;

    if ((adapter->intr_status == 0xffffffff) || (adapter->intr_status == 0))
            return;

    while (0 != adapter->intr_status) {
          PDEBUG("%s: interrupt status = %#8.8x\n",dev->name, adapter->intr_status);

         /* interrupt after transfering data */
         if (netif_running(dev) && (adapter->intr_status & TxOK )) {
         	spin_lock(&adapter->lock);
                silan_tx_interrupt (dev);
                spin_unlock(&adapter->lock);
         }
         /* receive interrupt */
         if (netif_running(dev) && (adapter->intr_status & RxOK)) {
                silan_rx(dev);
         }

         /* media link interrupt.*/
         if (adapter->intr_status & (LinkFail | LinkOK)) {
                silan_mlink_intr(dev);
         }

         if (netif_running(dev) && adapter->intr_status & RxOverflow) {
             printk(KERN_WARNING  "rx buffer is full!\n");
             adapter->net_stats.rx_errors++;
         }

         if (adapter->intr_status & TimeOut) {
             printk(KERN_WARNING "time is too long \n");
             adapter->net_stats.rx_errors++;
             adapter->net_stats.rx_length_errors++;
         }

         adapter->intr_status = SILAN_R32(IntrStatus) & IntrBits;
  }

     // Enable all known interrupts by setting the interrupt mask.
     SILAN_W32(IntrMask, IntrBits);

     return;
}


static int silan_close(struct net_device *dev)
{
     struct silan_private *adapter = dev->priv;
     void *ioaddr = adapter->mmio_addr;
     unsigned long flags;

     assert (dev != NULL);
     assert (adapter != NULL);
     assert (ioaddr != NULL);
     
     netif_stop_queue(dev);

     spin_lock_irqsave(&adapter->lock, flags);
     /* Stop the chip's Tx and Rx DMA processes. */
     adapter->rx_config &= ~RxEnb;
     adapter->tx_config &= ~TxEnb;
     SILAN_W32(RxConfig, adapter->rx_config);
     SILAN_W32(RxConfig, adapter->tx_config);
     /* Disable interrupts by clearing the interrupt mask. */
     SILAN_W32(IntrMask, 0);

     spin_unlock_irqrestore(&adapter->lock, flags);

     synchronize_irq( );
     free_irq(dev->irq, dev);

     silan_tx_clear(adapter);

     adapter->dirty_rx = adapter->rx_ring_dma;
     pci_free_consistent(adapter->pdev, RX_BUF_LEN,
                          adapter->rx_ring, adapter->rx_ring_dma);
     pci_free_consistent(adapter->pdev, TX_BUF_TOT_LEN,
                          adapter->tx_bufs, adapter->tx_bufs_dma);
     adapter->rx_ring = NULL;
     adapter->tx_bufs = NULL;

     return 0;

}


#ifdef CONFIG_PM

static int silan_suspend(struct pci_dev *pdev, u32 state)
{
     struct net_device *dev = pci_get_drvdata (pdev);
     struct silan_private *adapter = dev->priv;
     void *ioaddr = adapter->mmio_addr;
     unsigned long flags;

     if (!netif_running(dev))
        return 0;

     netif_device_detach(dev);
     spin_lock_irqsave(&adapter->lock, flags);
     /* Disable interrupts, stop Tx and Rx. */
     SILAN_W32(IntrMask, 0);

     adapter->rx_config &= ~RxEnb;
     adapter->tx_config &= ~TxEnb;
     SILAN_W32(RxConfig, adapter->rx_config);
     SILAN_W32(RxConfig, adapter->tx_config);

     spin_unlock_irqrestore(&adapter->lock, flags);

     return 0;
}


static int silan_resume(struct pci_dev *pdev)

{
     struct net_device *dev = pci_get_drvdata(pdev);

     if (!netif_running (dev))
        return 0;

     netif_device_attach (dev);
     silan_hw_init(dev);

     return 0;
}
#endif


static void  __devexit silan_remove(struct pci_dev *pdev)
{
    struct net_device *dev = pci_get_drvdata(pdev);
    struct silan_private *adapter;

    assert (dev != NULL);
    adapter = dev->priv;
    assert (adapter != NULL);

    unregister_netdev (dev);

#ifndef USE_IO_OPS
    if (adapter->mmio_addr)
         iounmap(adapter->mmio_addr);
#endif
     pci_release_regions(pdev);

#ifndef SILAN8139D_NDEBUG
     memset(dev, 0, sizeof(struct net_device) + sizeof(struct silan_private));
#endif

     kfree(dev);
     pci_set_drvdata(pdev,NULL);
     return;
}




static struct net_device_stats *silan_get_stats(struct net_device *dev)
{
    struct silan_private *adapter = dev->priv;
    void *ioaddr = adapter->mmio_addr;
    unsigned long flags;
    int    temp = 0;

    if (netif_running(dev)) {
        spin_lock_irqsave(&adapter->lock, flags);
        /* Update the error count. */
        temp = (SILAN_R32(RxStatus0) >> 16) & 0xffff;

        if( temp == 0xffff) {
              adapter->rx_value += temp;
              adapter->net_stats.rx_fifo_errors = adapter->rx_value;
        } else {
              adapter->net_stats.rx_fifo_errors = temp + adapter->rx_value;
        }
        
        spin_unlock_irqrestore(&adapter->lock, flags);
    }

    return &adapter->net_stats;
}




static void Mii_ethtool_gset(void * ioaddr, struct ethtool_cmd *ecmd)
{
    unsigned long   temp, phys[2];

    ecmd->supported =
   	    (M10_Half | M10_Full | M100_Half | M100_Full | Autoselect);

    ecmd->phy_address = SILAN_R32(Miicmd1) >> 27;
    temp = SILAN_R32(PhyCtrl);
   
    if ((temp & (PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10))== 0x60800000)
        ecmd->advertising = Autoselect;
        
    if ((temp & PhyCtrlSpd10)== 0x20000000)
        ecmd->advertising = M10_Half;
        
    if ((temp & (PhyCtrlSpd10 |PhyCtrlDux)) == 0x20800000)
        ecmd->advertising = M10_Full;

    if ((temp & PhyCtrlSpd100) == 0x40000000)
        ecmd->advertising = M100_Half;

    if ((temp & (PhyCtrlSpd100 |PhyCtrlDux)) == 0x40800000)
        ecmd->advertising = M100_Full;

    if (temp & PhyCtrlAne) {
       ecmd->advertising = Autoselect; 
       ecmd->autoneg = AUTONEG_ENABLE;
    } else {
       ecmd->autoneg = AUTONEG_DISABLE;
    }

    phys[0] = Mii_OutputStatus;
    mii_cmd_select(ioaddr, Mii_READ, phys);
    ecmd->speed = phys[1] & 0x2 ? SPEED_100 :SPEED_10;
    ecmd->duplex = phys[1] & 0x4 ? DUPLEX_FULL : DUPLEX_HALF;
    mii_cmd_select (ioaddr, Mii_SCAN, phys);

    return ;
}


static int Mii_ethtool_sset(void *ioaddr, struct ethtool_cmd *ecmd)
{
    uint32_t temp, temp1;

    if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
           return -EINVAL;
           
    if(ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
           return -EINVAL;
           
    if (ecmd->phy_address != 0x1f)
           return -EINVAL;
           
    if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
           return -EINVAL;

    if (ecmd->autoneg == AUTONEG_ENABLE) {
       if ((ecmd->advertising & (Autoselect|M10_Half |M10_Full |M100_Half |M100_Full)) == 0)
           return -EINVAL;	
        
        temp = SILAN_R32(PhyCtrl);
        temp1 = temp;
        temp &=~(PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10);
        temp |= PhyCtrlAne ;
   
        switch (ecmd->advertising) {
         case Autoselect:
           printk(KERN_INFO "autoselect supported\n");
           temp |= (PhyCtrlDux | PhyCtrlSpd100 | PhyCtrlSpd10);
           break;
           
         case M10_Half:
           printk(KERN_INFO "10M half_duplex supported\n");
           temp |= PhyCtrlSpd10;
           break;
       
         case M10_Full:
           printk(KERN_INFO "10M Full_duplex supported\n");
           temp |= (PhyCtrlDux |PhyCtrlSpd10);
           break;
             
         case M100_Half:
           printk(KERN_INFO "100M half_duplex supported\n");
           temp |= PhyCtrlSpd100;
           break;
           
         case M100_Full:
           printk(KERN_INFO "100M full_duplex supported\n");
           temp |= (PhyCtrlDux |PhyCtrlSpd100);
           break;
      
         default:
           break;
       }
        
        if (temp1 != temp) {
             SILAN_W32(PhyCtrl, temp);  	
        }
     }
    return 0;
}


static int Mii_link_ok (struct net_device *dev, void *ioaddr)
{
    unsigned long phys[2];

    printk(" mii_link_ok called .\n");
    phys[0] = MII_BMSR;
    mii_cmd_select(ioaddr, Mii_READ, phys);

    if (!(phys[1] & BMSR_LSTATUS)) {
       netif_carrier_off(dev);
       mii_cmd_select(ioaddr, Mii_SCAN, phys);
       return(netif_carrier_ok(dev));
    }

    netif_carrier_on(dev);
    mii_cmd_select(ioaddr, Mii_SCAN, phys);
    return(netif_carrier_ok(dev));
}


static int Mii_restart(void *ioaddr)
{
     unsigned long phys[2];

     int err = -EINVAL;

     /* if autoneg is off, it's an error */
     phys[0] = MII_BMCR;
     mii_cmd_select(ioaddr, Mii_READ, phys);

     if (phys[1] & BMCR_ANENABLE) {
        phys[1] |= BMCR_ANRESTART;
        mii_cmd_select(ioaddr, Mii_WRITE, phys);
        err = 0;
     }


     mii_cmd_select(ioaddr, Mii_SCAN, phys);
     
     return err;

}


/* W ake-On-Lan options. */
#define SL_WAKE_PHY   (1 << 0)
#define SL_WAKE_MAGIC (1 << 1)
#define SL_WAKE_MATCH (1 << 2)

/*Get the ethtool Wake-on-LAN settings.  Assumes that wol points to
   kernel memory, *wol has been initialized as {ETHTOOL_GWOL}, and
   other  interrupts aren't messing with the 8139d.  */
extern  int  netdev_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
{
    u32 pmconfig = 0;

    wol->supported = SL_WAKE_PHY | SL_WAKE_MAGIC | SL_WAKE_MATCH;
    wol->wolopts = 0;


    if (pmconfig & PM_LinkUp)
        wol->wolopts |= SL_WAKE_PHY;

    if (pmconfig & PM_Magic)
        wol->wolopts |= SL_WAKE_MAGIC;

    if (pmconfig & PM_WakeUp)
        wol->wolopts |= SL_WAKE_MATCH;

    return 0;	
}


/* Set the ethtool Wake-on-LAN settings.  Return 0 or -errno.  Assumes
   that wol points to kernel memory and other  interrupts
   aren't messing with the 8139d. */
extern int netdev_set_wol(struct net_device *dev, const struct ethtool_wolinfo *wol)
{
     struct silan_private *adapter = dev->priv;
     void *ioaddr = adapter->mmio_addr;
     u32 pmconfig = 0;


     pmconfig = SILAN_R32(PMConfig) & (~(PM_LinkUp | PM_Magic | PM_WakeUp));

     if (wol->wolopts & SL_WAKE_PHY)
        pmconfig |= PM_LinkUp;

     if (wol->wolopts & SL_WAKE_MAGIC)
        pmconfig |= PM_Magic;

     if (wol->wolopts & SL_WAKE_MATCH)
        pmconfig |= PM_WakeUp;

     SILAN_W32(PMConfig, pmconfig);


     return 0;
}



static int netdev_ethtool_ioctl(struct net_device *dev, void *useraddr)

{
     struct silan_private *adapter = dev->priv;
     void *ioaddr = adapter->mmio_addr;
     uint32_t ethcmd;
     int r;

     if (get_user(ethcmd, (u32 *)useraddr))
        return -EFAULT;  /* Bad address */

     switch (ethcmd) {
        /* Get driver info */
       case ETHTOOL_GDRVINFO: {
          struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
          strcpy(info.driver, DRV_NAME);
          strcpy(info.version, DRV_VERSION);
          strcpy(info.bus_info, adapter->pdev->slot_name);
          if (copy_to_user (useraddr, &info, sizeof (info)))
              return -EFAULT;
          return 0;
        }
       /* get settings  */
       case ETHTOOL_GSET: {
          struct ethtool_cmd ecmd = { ETHTOOL_GSET };
          spin_lock_irq(&adapter->lock);
          Mii_ethtool_gset(ioaddr, &ecmd);
          spin_unlock_irq(&np->lock);
          if (copy_to_user(useraddr, &ecmd, sizeof(ecmd)))
               return -EFAULT;
          return 0;
       }
       /*set settings */
       case ETHTOOL_SSET: {
          struct ethtool_cmd ecmd = { ETHTOOL_GSET};
          if (copy_from_user(&ecmd, useraddr, sizeof(ecmd)))
              return -EFAULT;
          spin_lock_irq(&adapter->lock);
          r = Mii_ethtool_sset(ioaddr, &ecmd);
          spin_unlock_irq(&adapter->lock);
          return r;
       }
       /* get link status */
       case ETHTOOL_GLINK: {
         struct ethtool_value edata = {ETHTOOL_GLINK};

         edata.data = Mii_link_ok(dev, ioaddr);
         if (copy_to_user(useraddr, &edata, sizeof(edata)))
             return -EFAULT;
         return 0;
       }
       /* restart autonegotiation */
       case ETHTOOL_NWAY_RST: {
          r = Mii_restart(ioaddr);
          return r;
       }
       /*Get wake-on-lan options*/
       case ETHTOOL_GWOL:{
           struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
           spin_lock_irq (&adapter->lock);

                netdev_get_wol(dev , &wol);
           spin_unlock_irq (&adapter->lock);
           if (copy_to_user (useraddr, &wol, sizeof (wol)))
                return -EFAULT;
           return 0;
       }
       /*Set wake-on-lan options */
       case ETHTOOL_SWOL:{
            struct ethtool_wolinfo  wol ={ETHTOOL_SWOL};
            int rc;
            if(copy_from_user (&wol, useraddr, sizeof (wol)))
                return -EFAULT;
            spin_lock_irq (&adapter->lock);
                rc = netdev_set_wol(dev, &wol);
            spin_unlock_irq (&adapter->lock);
            return rc;
       }

#if LINUX_VERSION_CODE > KERNEL_VERSION(2,4,18)
       /* get string list(s) */
       case ETHTOOL_GSTRINGS: {
           struct ethtool_gstrings  estr = { ETHTOOL_GSTRINGS };

           if (copy_from_user(&estr, useraddr, sizeof(estr)))
                return -EFAULT;

           if (estr.string_set != ETH_SS_STATS)
                return -EINVAL;

            estr.len = SILAN_STATE_NUM;

           if (copy_to_user(useraddr, &estr, sizeof(estr)))
                return -EFAULT;

           if (copy_to_user(useraddr + sizeof(estr), &ethtool_stats_keys, sizeof(ethtool_stats_keys)))
                return -EFAULT;

           return 0;
      }

      /* get NIC-specific statistics */
      case ETHTOOL_GSTATS: {
           struct ethtool_stats estats = { ETHTOOL_GSTATS };
           u64 *tmp_state;
           const unsigned int sz = sizeof(u64) * SILAN_STATE_NUM;
           int i;

           estats.n_stats = SILAN_STATE_NUM;

           if (copy_to_user(useraddr, &estats, sizeof(estats)))
                return -EFAULT;

           tmp_state = kmalloc(sz, GFP_KERNEL);

           if (!tmp_state)
               return -ENOMEM;
           memset(tmp_state, 0, sz);

           i = 0;

           tmp_state[i++] = adapter->tx_timeouts;
           tmp_state[i++] = adapter->rx_loss;


           if (i != SILAN_STATE_NUM)
                BUG();

          if(copy_to_user(useraddr + sizeof(estats), tmp_state, sz));
                return -EFAULT;

          kfree(tmp_state);
          return 0;
     }
#endif
     default:
          break;
}
   /* Operation not supported on transport endpoint */
   return -EOPNOTSUPP;
}


static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
{
     struct silan_private *adapter = dev->priv;
     struct Mii_ioctl_data *data = (struct Mii_ioctl_data *)&rq->ifr_data;
     void *ioaddr = adapter->mmio_addr;
     unsigned long phys[2], flags;
     int rc = 0;
    
     spin_lock_irqsave (&adapter->lock, flags);

     if (!netif_running(dev))
         return -EINVAL;    // Invalid argument

     if (cmd == SIOCETHTOOL) {
        return (netdev_ethtool_ioctl(dev, (void *) rq->ifr_data));


     data->reg_num = (SILAN_R32(Miicmd1) >> 6) & 0x001f;
     phys[0] = data->reg_num;
     PDEBUG("reg_num-phys[0] = 0x%lx\n", phys[0]);

     switch (cmd) {
            case SIOCDEVPRIVATE:	
               data->phy_id = (SILAN_R32(Miicmd1) >> 27) & 0x001f;
               break;
               
           case SIOCDEVPRIVATE+1:
               mii_cmd_select(ioaddr, Mii_READ, phys);
               data->val_out = phys[1];


               mii_cmd_select(ioaddr, Mii_SCAN, phys);
               break;

           default:
                rc = -EOPNOTSUPP;
                break;
         }
      }
    
     spin_unlock_irqrestore(&adapter->lock, flags);
     return rc;
}



static struct pci_driver silan_pci_driver = {
    name:   (char*) DRV_NAME,
    id_table: silan_pci_tbl,
    probe:   silan_probe,
    remove: __devexit_p(silan_remove),
#ifdef CONFIG_PM
    suspend:  silan_suspend,
    resume:   silan_resume,
#endif
};


static int __init silan_init_module(void)
{

    unsigned char   *work_mode1 = NULL;

#ifdef MODULE
    printk (KERN_INFO  SILAN_DRIVER_NAME "\n");
#endif

    switch(work_mode){
    case 0x00:
        work_mode1 = "Autoselect";
        break;
    case 0x01:
        work_mode1 = "10M Half_duplex";
        break;

    case 0x02:
        work_mode1 = "10M Full_duplex";
        break;
    case 0x04:
        work_mode1 = "100M Half_duplex";
        break;
    case 0x08:
        work_mode1 = "100M Full_duplex";
        break;
    default:
        break;
    }
   printk(KERN_INFO "work_mode -> %s\n ", work_mode1);

   return pci_module_init(&silan_pci_driver);

}


static void  __exit silan_cleanup_module(void)
{
    pci_unregister_driver(&silan_pci_driver);
}

module_init(silan_init_module);
module_exit(silan_cleanup_module);

--------------070701060400090506070007--
