From: "David H. Lynch Jr." <dhlii@dlasys.net>
Subject: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000 Ethernet
 NIC
Date: Sun, 17 Aug 2008 00:59:08 -0400
Message-ID: <48A7B01C.2070403@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: linuxppc-embedded <linuxppc-embedded@ozlabs.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-146.bluehost.com ([67.222.38.36]:43170 "HELO
	outbound-mail-146.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751050AbYHQFGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 01:06:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please bear with me. This is my first patch submission.
Grant Likely of Secret Labs has kindly done a prelimary view.
Hopefully I have correct the issues he raised.


Ethernet driver for Xilinx LL TEMAC

Original Author Yoshio Kashiwagi
Updated and Maintained by David Lynch


Signed-off-by: David H. Lynch Jr <dhlii@dlasys.net>

---

 drivers/net/Kconfig            |    5
 drivers/net/Makefile           |    1
 drivers/net/xps_lltemac.c      | 1283
++++++++++++++++++++++++++++++++++++++++
 include/linux/xilinx_devices.h |    2
 4 files changed, 1290 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fd0dd80..71a3eee 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2332,6 +2332,11 @@ config MV643XX_ETH
 	  Some boards that use the Discovery chipset are the Momenco
 	  Ocelot C and Jaguar ATX and Pegasos II.

+config XPS_LLTEMAC
+	tristate "Xilinx LLTEMAC 10/100/1000 Ethernet MAC driver"
+	help
+	  This driver supports the Xilinx 10/100/1000 LLTEMAC found in Virtex
4 FPGAs
+
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 1f09934..9196bab 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -126,6 +126,7 @@ obj-$(CONFIG_AX88796) += ax88796.o
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_PICO_TEMAC) += pico_temac.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
+obj-$(CONFIG_XPS_LLTEMAC) += xps_lltemac.o
 obj-$(CONFIG_QLA3XXX) += qla3xxx.o

 obj-$(CONFIG_PPP) += ppp_generic.o
diff --git a/drivers/net/xps_lltemac.c b/drivers/net/xps_lltemac.c
new file mode 100644
index 0000000..1f2c158
--- /dev/null
+++ b/drivers/net/xps_lltemac.c
@@ -0,0 +1,1283 @@
+/*======================================================================
+
+ Driver for Xilinx temac ethernet NIC's
+
+ Author: Yoshio Kashiwagi
+ Copyright (c) 2008 Nissin Systems Co.,Ltd.
+
+ Revisons: David H. Lynch Jr. <dhlii@dlasys.net>
+ Copyright (C) 2005-2008 DLA Systems
+
+======================================================================*/
+
+#define DRV_NAME        "xilinx_lltemac"
+#define DRV_AUTHOR      "Yoshio Kashiwagi"
+#define DRV_EMAIL       ""
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/platform_device.h>
+#include <linux/spinlock.h>
+
+#include <linux/mii.h>
+#include <linux/in.h>
+#include <linux/pci.h>
+
+#include <linux/ip.h>
+#include <linux/tcp.h>      /* just needed for sizeof(tcphdr) */
+#include <linux/udp.h>      /* needed for sizeof(udphdr) */
+#include <asm/delay.h>
+#include <asm/io.h>
+
+/* register access modes */
+typedef enum { REG_DCR = 1, REG_IND, REG_DIR} REG_MODE;
+
+#define MII_ANI                     0x10
+#define PHY_NUM                     0
+#define PHY_TIMEOUT                 10000
+
+#define MII_SSR                     0x11
+#define MII_SSR_LINK                    (1 << 10)
+#define MII_SSR_SPDMASK                 0xC000
+#define MII_SSR_SPD1000                 (1 << 15)
+#define MII_SSR_SPD100                  (1 << 14)
+#define MII_SSR_SPD10                   0
+#define MII_SSR_FD                      (1 << 13)
+
+#define MII_ISR                     0x13
+
+/* packet size info */
+#define XTE_MTU                     1500        /* max MTU size of
Ethernet frame */
+#define XTE_HDR_SIZE                14          /* size of Ethernet
header */
+#define XTE_TRL_SIZE                4           /* size of Ethernet
trailer (FCS) */
+#define XTE_MAX_FRAME_SIZE          (XTE_MTU + XTE_HDR_SIZE + XTE_TRL_SIZE)
+#define XTE_JUMBO_MTU               9000
+#define XTE_MAX_JUMBO_FRAME_SIZE    (XTE_JUMBO_MTU + XTE_HDR_SIZE +
XTE_TRL_SIZE)
+
+/**  Configuration options
+ *
+ * Device configuration options. See the temac_setoptions(),
+ * XTemac_ClearOptions() and XTemac_GetOptions() for information on how
to use
+ * options.
+ *
+ * The default state of the options are noted and are what the device
and driver
+ * will be set to after calling XTemac_Reset() or XTemac_Initialize().
+ *
+ */
+
+#define XTE_OPTION_PROMISC                      (1 << 0)    /**< Accept
all incoming packets. This option defaults to disabled (cleared) */
+#define XTE_OPTION_JUMBO                        (1 << 1)    /**< Jumbo
frame support for Tx & Rx. This option defaults to disabled (cleared) */
+#define XTE_OPTION_VLAN                         (1 << 2)    /**< VLAN
Rx & Tx frame support.  This option defaults to disabled (cleared) */
+#define XTE_OPTION_FLOW_CONTROL                 (1 << 4)    /**< Enable
recognition of flow control frames on Rx This option defaults to enabled
(set) */
+#define XTE_OPTION_FCS_STRIP                    (1 << 5)    /**< Strip
FCS and PAD from incoming frames. Note: PAD from VLAN frames is not
stripped.  This option defaults to disabled (set) */
+#define XTE_OPTION_FCS_INSERT                   (1 << 6)    /**<
Generate FCS field and add PAD automatically for outgoing frames.  This
option defaults to enabled (set) */
+#define XTE_OPTION_LENTYPE_ERR                  (1 << 7)    /**< Enable
Length/Type error checking for incoming frames. When this option is
+
set, the MAC will filter frames that have a mismatched type/length field
+
and if XTE_OPTION_REPORT_RXERR is set, the user is notified when these
+
types of frames are encountered. When this option is cleared, the MAC will
+
allow these types of frames to be received.
+
This option defaults to enabled (set) */
+#define XTE_OPTION_TXEN                         (1 << 11)   /**< Enable
the transmitter.  This option defaults to enabled (set) */
+#define XTE_OPTION_RXEN                         (1 << 12)   /**< Enable
the receiver This option defaults to enabled (set) */
+#define XTE_OPTION_DEFAULTS                     \
+    (XTE_OPTION_TXEN |            \
+     XTE_OPTION_FLOW_CONTROL |                  \
+     XTE_OPTION_RXEN)                /**< Default options set when
device is initialized or reset */
+
+/* XPS_LL_TEMAC SDMA registers definition */
+
+#define TX_NXTDESC_PTR      0x00            /* r */
+#define TX_CURBUF_ADDR      0x04            /* r */
+#define TX_CURBUF_LENGTH    0x08            /* r */
+#define TX_CURDESC_PTR      0x0c            /* rw */
+#define TX_TAILDESC_PTR     0x10            /* rw */
+#define TX_CHNL_CTRL        0x14            /* rw */
+/* 0:7      24:31       IRQTimeout */
+/* 8:15     16:23       IRQCount */
+/* 16:20    11:15       Reserved */
+/* 21       10          0 */
+/* 22       9           UseIntOnEnd */
+/* 23       8           LdIRQCnt */
+/* 24       7           IRQEn */
+/* 25:28    3:6         Reserved */
+/* 29       2           IrqErrEn */
+/* 30       1           IrqDlyEn */
+/* 31       0           IrqCoalEn */
+#define CHNL_CTRL_IRQ_IOE       (1 << 9)
+#define CHNL_CTRL_IRQ_EN        (1 << 7)
+#define CHNL_CTRL_IRQ_ERR_EN    (1 << 2)
+#define CHNL_CTRL_IRQ_DLY_EN    (1 << 1)
+#define CHNL_CTRL_IRQ_COAL_EN   (1 << 0)
+#define TX_IRQ_REG          0x18            /* rw */
+/* 0:7      24:31       DltTmrValue */
+/* 8:15     16:23       ClscCntrValue */
+/* 16:17    14:15       Reserved */
+/* 18:21    10:13       ClscCnt */
+/* 22:23    8:9         DlyCnt */
+/* 24:28    3::7        Reserved */
+/* 29       2           ErrIrq */
+/* 30       1           DlyIrq */
+/* 31       0           CoalIrq */
+#define TX_CHNL_STS         0x1c            /* r */
+/* 0:9      22:31   Reserved */
+/* 10       21      TailPErr */
+/* 11       20      CmpErr */
+/* 12       19      AddrErr */
+/* 13       18      NxtPErr */
+/* 14       17      CurPErr */
+/* 15       16      BsyWr */
+/* 16:23    8:15    Reserved */
+/* 24       7       Error */
+/* 25       6       IOE */
+/* 26       5       SOE */
+/* 27       4       Cmplt */
+/* 28       3       SOP */
+/* 29       2       EOP */
+/* 30       1       EngBusy */
+/* 31       0       Reserved */
+
+#define RX_NXTDESC_PTR      0x20            /* r */
+#define RX_CURBUF_ADDR      0x24            /* r */
+#define RX_CURBUF_LENGTH    0x28            /* r */
+#define RX_CURDESC_PTR      0x2c            /* rw */
+#define RX_TAILDESC_PTR     0x30            /* rw */
+#define RX_CHNL_CTRL        0x34            /* rw */
+/* 0:7      24:31       IRQTimeout */
+/* 8:15     16:23       IRQCount */
+/* 16:20    11:15       Reserved */
+/* 21       10          0 */
+/* 22       9           UseIntOnEnd */
+/* 23       8           LdIRQCnt */
+/* 24       7           IRQEn */
+/* 25:28    3:6         Reserved */
+/* 29       2           IrqErrEn */
+/* 30       1           IrqDlyEn */
+/* 31       0           IrqCoalEn */
+#define RX_IRQ_REG          0x38            /* rw */
+#define IRQ_COAL        (1 << 0)
+#define IRQ_DLY         (1 << 1)
+#define IRQ_ERR         (1 << 2)
+#define IRQ_DMAERR      (1 << 7)            /* this is not documented
??? */
+/* 0:7      24:31       DltTmrValue */
+/* 8:15     16:23       ClscCntrValue */
+/* 16:17    14:15       Reserved */
+/* 18:21    10:13       ClscCnt */
+/* 22:23    8:9         DlyCnt */
+/* 24:28    3::7        Reserved */
+#define RX_CHNL_STS         0x3c        /* r */
+#define CHNL_STS_ENGBUSY    (1 << 1)
+#define CHNL_STS_EOP        (1 << 2)
+#define CHNL_STS_SOP        (1 << 3)
+#define CHNL_STS_CMPLT      (1 << 4)
+#define CHNL_STS_SOE        (1 << 5)
+#define CHNL_STS_IOE        (1 << 6)
+#define CHNL_STS_ERR        (1 << 7)
+
+#define CHNL_STS_BSYWR      (1 << 16)
+#define CHNL_STS_CURPERR    (1 << 17)
+#define CHNL_STS_NXTPERR    (1 << 18)
+#define CHNL_STS_ADDRERR    (1 << 19)
+#define CHNL_STS_CMPERR     (1 << 20)
+#define CHNL_STS_TAILERR    (1 << 21)
+/* 0:9      22:31   Reserved */
+/* 10       21      TailPErr */
+/* 11       20      CmpErr */
+/* 12       19      AddrErr */
+/* 13       18      NxtPErr */
+/* 14       17      CurPErr */
+/* 15       16      BsyWr */
+/* 16:23    8:15    Reserved */
+/* 24       7       Error */
+/* 25       6       IOE */
+/* 26       5       SOE */
+/* 27       4       Cmplt */
+/* 28       3       SOP */
+/* 29       2       EOP */
+/* 30       1       EngBusy */
+/* 31       0       Reserved */
+
+#define DMA_CONTROL_REG             0x40            /* rw */
+#define DMA_CONTROL_RST                 (1 << 0)
+
+/* XPS_LL_TEMAC direct registers definition */
+
+#define XTE_RAF0_OFFSET              0x00
+#define RAF0_RST                        (1 << 0)
+#define RAF0_MCSTREJ                    (1 << 1)
+#define RAF0_BCSTREJ                    (1 << 2)
+#define XTE_TPF0_OFFSET              0x04
+#define XTE_IFGP0_OFFSET             0x08
+#define XTE_ISR0_OFFSET              0x0c
+#define ISR0_HARDACSCMPLT               (1 << 0)
+#define ISR0_AUTONEG                    (1 << 1)
+#define ISR0_RXCMPLT                    (1 << 2)
+#define ISR0_RXREJ                      (1 << 3)
+#define ISR0_RXFIFOOVR                  (1 << 4)
+#define ISR0_TXCMPLT                    (1 << 5)
+#define ISR0_RXDCMLCK                   (1 << 6)
+
+#define XTE_IPR0_OFFSET              0x10
+#define XTE_IER0_OFFSET              0x14
+
+#define XTE_MSW0_OFFSET              0x20
+#define XTE_LSW0_OFFSET              0x24
+#define XTE_CTL0_OFFSET              0x28
+#define XTE_RDY0_OFFSET              0x2c
+
+#define XTE_RSE_MIIM_RR_MASK      0x0002
+#define XTE_RSE_MIIM_WR_MASK      0x0004
+#define XTE_RSE_CFG_RR_MASK       0x0020
+#define XTE_RSE_CFG_WR_MASK       0x0040
+
+/* XPS_LL_TEMAC indirect registers offset definition */
+
+#define XTE_RXC0_OFFSET                 0x00000200              /**< Rx
configuration word 0 */
+#define XTE_RXC1_OFFSET                 0x00000240              /**< Rx
configuration word 1 */
+#define XTE_RXC1_RXRST_MASK                 (1 << 31)           /**<
Receiver reset */
+#define XTE_RXC1_RXJMBO_MASK                (1 << 30)           /**<
Jumbo frame enable */
+#define XTE_RXC1_RXFCS_MASK                 (1 << 29)           /**<
FCS not stripped */
+#define XTE_RXC1_RXEN_MASK                  (1 << 28)           /**<
Receiver enable */
+#define XTE_RXC1_RXVLAN_MASK                (1 << 27)           /**<
VLAN enable */
+#define XTE_RXC1_RXHD_MASK                  (1 << 26)           /**<
Half duplex */
+#define XTE_RXC1_RXLT_MASK                  (1 << 25)           /**<
Length/type check disable */
+
+#define XTE_TXC_OFFSET                  0x00000280              /**< Tx
configuration */
+#define XTE_TXC_TXRST_MASK                  (1 << 31)           /**<
Transmitter reset */
+#define XTE_TXC_TXJMBO_MASK                 (1 << 30)           /**<
Jumbo frame enable */
+#define XTE_TXC_TXFCS_MASK                  (1 << 29)           /**<
Generate FCS */
+#define XTE_TXC_TXEN_MASK                   (1 << 28)           /**<
Transmitter enable */
+#define XTE_TXC_TXVLAN_MASK                 (1 << 27)           /**<
VLAN enable */
+#define XTE_TXC_TXHD_MASK                   (1 << 26)           /**<
Half duplex */
+#define XTE_FCC_OFFSET                  0x000002C0              /**<
Flow control configuration */
+#define XTE_FCC_RXFLO_MASK                  (1 << 29)           /**< Rx
flow control enable */
+#define XTE_FCC_TXFLO_MASK                  (1 << 30)           /**< Tx
flow control enable */
+
+#define XTE_EMCFG_OFFSET                0x00000300              /**<
EMAC configuration */
+#define XTE_EMCFG_LINKSPD_MASK          0xC0000000              /**<
Link speed */
+#define XTE_EMCFG_HOSTEN_MASK               (1 << 26)           /**<
Host interface enable */
+#define XTE_EMCFG_LINKSPD_10            0x00000000              /**<
XTE_EMCFG_LINKSPD_MASK for 10 Mbit */
+#define XTE_EMCFG_LINKSPD_100               (1 << 30)           /**<
XTE_EMCFG_LINKSPD_MASK for 100 Mbit */
+#define XTE_EMCFG_LINKSPD_1000              (1 << 31)           /**<
XTE_EMCFG_LINKSPD_MASK for 1000 Mbit */
+
+#define XTE_GMIC_OFFSET                 0x00000320              /**<
RGMII/SGMII configuration */
+#define XTE_MC_OFFSET                   0x00000340              /**<
Management configuration */
+#define XTE_MC_MDIO_MASK                    (1 << 6)            /**<
MII management enable */
+#define XTE_MDIO_CLOCK_DIV_100MHz       0x28                    /* 100
MHz host clock */
+#define XTE_MDIO_DIV_DFT                29                      /*
Default MDIO clock divisor */
+#define XTE_UAW0_OFFSET                 0x00000380              /**<
Unicast address word 0 */
+#define XTE_UAW1_OFFSET                 0x00000384              /**<
Unicast address word 1 */
+
+#define XTE_MAW0_OFFSET                 0x00000388              /**<
Multicast address word 0 */
+#define XTE_MAW1_OFFSET                 0x0000038C              /**<
Multicast address word 1 */
+#define XTE_AFM_OFFSET                  0x00000390              /**<
Promisciuous mode */
+#define XTE_AFM_EPPRM_MASK                  (1 << 31)           /**<
Promiscuous mode enable */
+
+#define XTE_TIS_OFFSET                  0x000003A0              /*
Interrupt Request status */
+#define TIS_FRIS                            (1 << 0)
+#define TIS_MRIS                            (1 << 1)
+#define TIS_MWIS                            (1 << 2)
+#define TIS_ARIS                            (1 << 3)
+#define TIS_AWIS                            (1 << 4)
+#define TIS_CRIS                            (1 << 5)
+#define TIS_CWIS                            (1 << 6)
+#define XTE_TIE_OFFSET                  0x000003A4              /*
Interrupt Request enable */
+
+    /**  MII Mamagement Control register (MGTCR) */
+#define XTE_MGTDR_OFFSET                0x000003B0              /**<
MII data */
+#define XTE_MIIMAI_OFFSET               0x000003B4              /**<
MII control */
+
+#define CNTLREG_WRITE_ENABLE_MASK   0x8000
+#define CNTLREG_EMAC1SEL_MASK       0x0400
+#define CNTLREG_ADDRESSCODE_MASK    0x03ff
+
+/* CDMAC descriptor status bit definitions */
+
+#define STS_CTRL_APP0_ERR         (1 << 31)
+#define STS_CTRL_APP0_IRQONEND    (1 << 30)
+#define STS_CTRL_APP0_STOPONEND   (1 << 29)           /* undoccumented */
+#define STS_CTRL_APP0_CMPLT       (1 << 28)
+#define STS_CTRL_APP0_SOP         (1 << 27)
+#define STS_CTRL_APP0_EOP         (1 << 26)
+#define STS_CTRL_APP0_ENGBUSY     (1 << 25)
+#define STS_CTRL_APP0_ENGRST      (1 << 24)           /* undocumented */
+
+#define TX_CONTROL_CALC_CSUM_MASK   1
+
+#define ALIGNMENT       32
+#define BUFFER_ALIGN(adr) ((ALIGNMENT - ((u32) adr)) % ALIGNMENT)
+
+#define MULTICAST_CAM_TABLE_NUM 4
+
+#define TX_BD_NUM   64
+#define RX_BD_NUM   128
+
+#define XILINX_GSRD3_NAPI
+
+
+/* TX/RX CURDESC_PTR points to first descriptor */
+/* TX/RX TAILDESC_PTR points to last descriptor in linked list */
+
+struct cdmac_bd {
+    struct cdmac_bd             *next;
+    unsigned char               *phys;
+    u32                    len;
+    u32                    app0;
+    u32                    app1;           /* TX start << 16 | insert */
+    u32                    app2;           /* TX csum */
+    u32                    app3;           /* unused ? */
+    u32                    app4;           /* skb for TX length for RX */
+} ;
+/* APP0 bits */
+/* 0    Error */
+/* 1    IrqOnEnd    generate an interrupt at completion of DMA  op */
+/* 2    reserved */
+/* 3    completed   Current descriptor completed */
+/* 4    SOP         TX - marks first desc/ RX marks first desct */
+/* 5    EOP         TX marks last desc/RX marks last desc */
+/* 6    EngBusy     DMA is processing */
+/* 7    reserved */
+/* 8:31 application specific */
+
+struct temac_local {
+    struct net_device_stats     stats;              /* Statistics for
this device */
+    struct net_device           *dev;
+    unsigned long               sdma_base_addr;
+    int                         tx_irq;
+    int                         rx_irq;
+    unsigned int                mii:1;              /* mii port
available */
+
+    int                         emac_num;
+    u16                         phy_addr;
+    int                         LinkSpeed;          /* Speed of link
10/100/1000 */
+    u32                    options;            /* Current options word */
+    spinlock_t                  lock;
+    spinlock_t                  rx_lock;
+    spinlock_t                  tx_lock;
+    struct cdmac_bd             *tx_bd_v;
+    struct cdmac_bd             *tx_bd_p;
+    struct cdmac_bd             *rx_bd_v;
+    struct cdmac_bd             *rx_bd_p;
+    volatile int                tx_bd_ci;
+    volatile int                tx_bd_next;
+    volatile int                tx_bd_tail;
+    int                         rx_bd_ci;
+    struct sk_buff              **rx_skb;
+};
+
+static u32
+_ior(u32 offset)
+{
+    u32 value;
+    value = (*(volatile u32 *)(offset));
+    __asm__ __volatile__("eieio");
+    return value;
+}
+
+static void
+_iow(u32 offset, u32 value)
+{
+    (*(volatile u32 *)(offset) = value);
+    __asm__ __volatile__("eieio");
+}
+
+static u32
+tior(struct net_device *ndev, int offset)
+{
+    return _ior(ndev->base_addr + offset);
+}
+
+static void
+tiow(struct net_device *ndev, int offset, u32 value)
+{
+    _iow(ndev->base_addr + offset, value);
+}
+
+static u32
+tio_setclr(struct net_device *ndev, u32 reg_num, u32 val, int flg)
+{
+        u32 Reg = tior(ndev, reg_num) & ~val;
+        if (flg)
+            Reg |= val;
+        tiow(ndev, reg_num, Reg);
+        return 0;
+}
+
+static u32
+sd_ior(struct net_device *ndev, int offset)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    return _ior(lp->sdma_base_addr + offset);
+}
+
+static void
+sd_iow(struct net_device *ndev, int offset, u32 value)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    _iow(lp->sdma_base_addr + offset, value);
+
+}
+
+/***************************************************************************
+ * Reads an MII register from the MII PHY attached to the Xilinx Temac.
+ *
+ * Parameters:
+ *   dev      - the temac device.
+ *   phy_addr - the address of the PHY [0..31]
+ *   reg_num  - the number of the register to read. 0-6 are defined by
+ *              the MII spec, but most PHYs have more.
+ *   reg_value - this is set to the specified register's value
+ *
+ * Returns:
+ *   Success or Failure
+ */
+static unsigned int
+mdio_read(struct net_device *ndev, int phy_id, int reg_num)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    u32 timeout = PHY_TIMEOUT;
+    u32 rv = 0;
+    unsigned long flags;
+
+    if (lp->mii) {
+        spin_lock_irqsave(&lp->lock, flags);
+
+        tiow(ndev, XTE_LSW0_OFFSET, ((phy_id << 5) | (reg_num)));
+        tiow(ndev, XTE_CTL0_OFFSET, XTE_MIIMAI_OFFSET | (lp->emac_num
<< 10));
+        while(!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_MIIM_RR_MASK) &&
timeout--);
+        rv = tior(ndev, XTE_LSW0_OFFSET);
+
+        spin_unlock_irqrestore(&lp->lock, flags);
+    }
+    return rv;
+}
+
+/***************************************************************************
+ * Writes an MII register from the MII PHY attached to the Xilinx Temac.
+ *
+ * Parameters:
+ *   dev      - the temac device.
+ *   phy_id - the address of the PHY [0..31]
+ *   reg_num  - the number of the register to read. 0-6 are defined by
+ *              the MII spec, but most PHYs have more.
+ *   reg_value - the value to set
+ *
+ * Returns:
+ *   Success or Failure
+ */
+static void
+mdio_write(struct net_device *ndev, int phy_id, int reg_num, int reg_val)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    u32 timeout = PHY_TIMEOUT, status;
+    unsigned long flags;
+
+    if (lp->mii) {
+        spin_lock_irqsave(&lp->lock, flags);
+
+        tiow(ndev, XTE_LSW0_OFFSET, reg_val);
+        tiow(ndev, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK |
XTE_MGTDR_OFFSET);
+        tiow(ndev, XTE_LSW0_OFFSET, ((phy_id << 5) | (reg_num)));
+        tiow(ndev, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK |
XTE_MIIMAI_OFFSET | (lp->emac_num << 10));
+        while(!(status = tior(ndev, XTE_RDY0_OFFSET) &
XTE_RSE_MIIM_WR_MASK) && timeout--);
+
+        spin_unlock_irqrestore(&lp->lock, flags);
+    }
+}
+
+static u32
+emac_cfg_read(struct net_device *ndev, u16 reg_num)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    u32 timeout = 10000;
+
+    if (lp->mii) {
+        tiow(ndev, XTE_CTL0_OFFSET, (lp->emac_num << 10) | reg_num);
+        while(!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_CFG_RR_MASK) &&
timeout--);
+        return (u32) tior(ndev, XTE_LSW0_OFFSET);
+    }
+
+    return 0;
+}
+
+static void
+emac_cfg_write(struct net_device *ndev, u32 reg_num, u32 val)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    u32 timeout = 10000;
+
+    if (lp->mii) {
+        tiow(ndev, XTE_LSW0_OFFSET, val);
+        tiow(ndev, XTE_CTL0_OFFSET, (CNTLREG_WRITE_ENABLE_MASK |
(lp->emac_num << 10) | reg_num));
+        while(!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_CFG_WR_MASK) &&
timeout--);
+    }
+}
+
+static u32
+emac_cfg_setclr(struct net_device *ndev, u32 reg_num, u32 val, int flg)
+{
+        u32 Reg = emac_cfg_read(ndev, reg_num) & ~val;
+        if (flg)
+            Reg |= val;
+        emac_cfg_write(ndev, reg_num, Reg);
+        return 0;
+}
+
+/*
+Changes the mac address if the controller is not running.
+
+static int (*set_mac_address)(struct net_device *dev, void *addr);
+Function that can be implemented if the interface supports the ability
to change its
+hardware address. Many interfaces don't support this ability at all.
Others use the
+default eth_mac_addr implementation (from drivers/net/net_init.c).
eth_mac_addr
+only copies the new address into dev->dev_addr, and it does so only if
the interface
+is not running. Drivers that use eth_mac_addr should set the hardware MAC
+address from dev->dev_addr in their open method.
+
+*/
+static int
+temac_set_mac_address(struct net_device *ndev, void *address)
+{
+    if (address)
+        memcpy(ndev->dev_addr, address, ETH_ALEN);
+
+    if (!is_valid_ether_addr(ndev->dev_addr)) {
+		random_ether_addr(ndev->dev_addr);
+    }
+    /* set up unicast MAC address filter set its mac address */
+    emac_cfg_write(ndev, XTE_UAW0_OFFSET,
+            ((ndev->dev_addr[0]) |
+            (ndev->dev_addr[1] << 8) |
+            (ndev->dev_addr[2] << 16) |
+            (ndev->dev_addr[3] << 24)));
+    /* There are reserved bits in EUAW1 so don't affect them Set MAC
bits [47:32] in EUAW1 */
+    emac_cfg_write(ndev, XTE_UAW1_OFFSET,
+              (ndev->dev_addr[4] & 0x000000ff) |
+              (ndev->dev_addr[5] << 8));
+
+    return 0;
+}
+
+/*
+OPTIONAL
+static void (*set_multicast_list)(struct net_device *dev);
+Method called when the multicast list for the device changes and when the
+flags change. See the section Multicast for further details and a sample
+implementation.
+*/
+static void
+temac_set_multicast_list(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    u32 multi_addr_msw, multi_addr_lsw;
+    int i;
+
+    spin_lock(&lp->lock);
+
+    if(ndev->flags & IFF_PROMISC) {
+        printk(KERN_NOTICE "%s: Promiscuos mode enabled.\n", ndev->name);
+        emac_cfg_write(ndev, XTE_AFM_OFFSET, 0x80000000);
+    }  else {
+        struct dev_mc_list *mclist;
+        for(i = 0, mclist = ndev->mc_list; mclist && i <
ndev->mc_count; i++, mclist = mclist->next) {
+
+            if(i >= MULTICAST_CAM_TABLE_NUM) break;
+            multi_addr_msw = ((mclist->dmi_addr[3] << 24) |
(mclist->dmi_addr[2] << 16) | (mclist->dmi_addr[1] << 8) |
mclist->dmi_addr[0]);
+            emac_cfg_write(ndev, XTE_MAW0_OFFSET, multi_addr_msw);
+            multi_addr_lsw = ((mclist->dmi_addr[5] << 8) |
mclist->dmi_addr[4]);
+            multi_addr_lsw |= (i << 16);
+            emac_cfg_write(ndev, XTE_MAW1_OFFSET, multi_addr_lsw);
+        }
+    }
+    spin_unlock(&lp->lock);
+}
+
+static void
+temac_phy_init(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    unsigned int ret, Reg;
+    int ii;
+
+    /* Set default MDIO divisor */
+    /* Set up MII management registers to write to PHY  */
+    emac_cfg_write(ndev, XTE_MC_OFFSET, XTE_MC_MDIO_MASK |
XTE_MDIO_DIV_DFT);
+
+    /*
+       Set A-N Advertisement Regs for Full Duplex modes ONLY
+       address 4 = Autonegotiate Advertise Register
+       Disable 1000 Mbps for negotiation if not built for GEth
+     */
+    mdio_write(ndev, PHY_NUM, MII_ADVERTISE, mdio_read(ndev, PHY_NUM,
MII_ADVERTISE) | ADVERTISE_10FULL | ADVERTISE_100FULL | ADVERTISE_CSMA);
+    mdio_write(ndev, PHY_NUM, MII_CTRL1000, ADVERTISE_1000FULL);
+
+    /*
+       Soft reset the PHY
+       address 0 = Basic Mode Control Register
+     */
+    mdio_write(ndev, PHY_NUM, MII_BMCR, mdio_read(ndev, PHY_NUM,
MII_BMCR) | BMCR_RESET | BMCR_ANENABLE | BMCR_ANRESTART);
+
+    /* Wait for a PHY Link (auto-negotiation to complete)...  */
+    ret = mdio_read(ndev, PHY_NUM, MII_BMSR);
+    ii = 64;
+    while (((ret & BMSR_LSTATUS) != BMSR_LSTATUS) && ii--) {
+        mdelay(500);
+        ret = mdio_read(ndev, PHY_NUM, MII_BMSR);
+    }
+    ret = mdio_read(ndev, PHY_NUM, MII_SSR);
+
+    Reg = emac_cfg_read(ndev, XTE_EMCFG_OFFSET) & ~XTE_EMCFG_LINKSPD_MASK;
+    if (ret & MII_SSR_LINK) {
+        switch (ret & MII_SSR_SPDMASK) {
+        case MII_SSR_SPD1000:   /* 1000Base-T */
+            lp->LinkSpeed = 1000;
+            emac_cfg_write(ndev, XTE_EMCFG_OFFSET, Reg | (u32)
XTE_EMCFG_LINKSPD_1000);
+            break;
+        case MII_SSR_SPD100:    /* 100Base-T */
+            lp->LinkSpeed = 100;
+            emac_cfg_write(ndev, XTE_EMCFG_OFFSET, Reg |
XTE_EMCFG_LINKSPD_100);
+            break;
+        case MII_SSR_SPD10: /* 10Base-T */
+            lp->LinkSpeed = 10;
+            break;
+        };
+        if ((ret & MII_SSR_FD) == 0x0) {
+            /* set up Tx/Rx config reg for half duplex */
+            ret = emac_cfg_read(ndev, XTE_TXC_OFFSET);
+            emac_cfg_write(ndev, XTE_TXC_OFFSET, ret | XTE_TXC_TXHD_MASK);
+            ret = emac_cfg_read(ndev, XTE_RXC1_OFFSET);
+            emac_cfg_write(ndev, XTE_RXC1_OFFSET, ret |
XTE_RXC1_RXHD_MASK);
+        }
+    }
+}
+
+/*
-----------------------------------------------------------------------------
+-----------------------------------------------------------------------------
*/
+static int
+temac_bd_init(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    struct sk_buff *skb;
+    unsigned long align;
+    int ii;
+
+    lp->rx_skb = kzalloc(sizeof(struct sk_buff)*RX_BD_NUM, GFP_KERNEL);
+    /* allocate the tx and rx ring buffer descriptors. */
+    /* returns a virtual addres and a physical address. */
+    lp->tx_bd_v = dma_alloc_coherent(NULL, sizeof(struct cdmac_bd) *
TX_BD_NUM, (dma_addr_t *)&lp->tx_bd_p, GFP_KERNEL);
+    lp->rx_bd_v = dma_alloc_coherent(NULL, sizeof(struct cdmac_bd) *
RX_BD_NUM, (dma_addr_t *)&lp->rx_bd_p, GFP_KERNEL);
+
+    for(ii = 0;ii < TX_BD_NUM;ii++) {
+        memset((char *)&lp->tx_bd_v[ii], 0, sizeof(struct cdmac_bd));
+        if(ii == (TX_BD_NUM - 1)) {
+            lp->tx_bd_v[ii].next = &lp->tx_bd_p[0];
+        } else {
+            lp->tx_bd_v[ii].next = &lp->tx_bd_p[ii + 1];
+        }
+    }
+    for(ii = 0;ii < RX_BD_NUM;ii++) {
+        memset((char *)&lp->rx_bd_v[ii], 0, sizeof(struct cdmac_bd));
+        if(ii == (RX_BD_NUM - 1)) {
+            lp->rx_bd_v[ii].next = &lp->rx_bd_p[0];
+        } else {
+            lp->rx_bd_v[ii].next = &lp->rx_bd_p[ii + 1];
+        }
+        skb = alloc_skb(XTE_MAX_JUMBO_FRAME_SIZE + ALIGNMENT, GFP_ATOMIC);
+        if(skb == 0) {
+            printk("alloc_skb error %d\n", ii);
+            return -1;
+        }
+        lp->rx_skb[ii] = skb;
+/* this is how to get skb's aligned !!! */
+        align = BUFFER_ALIGN(skb->data);
+        if(align)
+            skb_reserve(skb, align);
+        /* returns physical address of skb->data */
+        lp->rx_bd_v[ii].phys = (unsigned char *)pci_map_single(NULL,
skb->data, XTE_MAX_JUMBO_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+        lp->rx_bd_v[ii].len = XTE_MAX_JUMBO_FRAME_SIZE;
+        lp->rx_bd_v[ii].app0 = STS_CTRL_APP0_IRQONEND;
+    }
+
+    sd_iow(ndev, TX_CHNL_CTRL, 0x10220400 | CHNL_CTRL_IRQ_EN |
CHNL_CTRL_IRQ_DLY_EN | CHNL_CTRL_IRQ_COAL_EN);
+    /* sd_iow(ndev, TX_CHNL_CTRL, 0x10220483); */
+    /*sd_iow(ndev, TX_CHNL_CTRL, 0x00100483); */
+    sd_iow(ndev, RX_CHNL_CTRL, 0xff010000 | CHNL_CTRL_IRQ_EN |
CHNL_CTRL_IRQ_DLY_EN | CHNL_CTRL_IRQ_COAL_EN | CHNL_CTRL_IRQ_IOE);
+    /* sd_iow(ndev, RX_CHNL_CTRL, 0xff010283); */
+
+    sd_iow(ndev, RX_CURDESC_PTR,  (uintptr_t)&lp->rx_bd_p[0]);
+    sd_iow(ndev, RX_TAILDESC_PTR, (uintptr_t)&lp->rx_bd_p[RX_BD_NUM - 1]);
+
+    return 0;
+}
+
+struct temac_option {
+    int         flg;
+    u32    opt;
+    u32    reg;
+    u32    m_or;
+    u32    m_and;
+
+};
+
+struct temac_option temac_options[] = {
+    { 0,  XTE_OPTION_JUMBO,                 XTE_TXC_OFFSET,
XTE_TXC_TXJMBO_MASK,	0},   /* Turn on jumbo packet support for both Rx
and Tx */
+    { 0,  XTE_OPTION_JUMBO,                 XTE_RXC1_OFFSET,
XTE_RXC1_RXJMBO_MASK,	0},
+    { 0,  XTE_OPTION_VLAN,                  XTE_TXC_OFFSET,
XTE_TXC_TXVLAN_MASK,	0},   /* Turn on VLAN packet support for both Rx
and Tx */
+    { 0,  XTE_OPTION_VLAN,                  XTE_RXC1_OFFSET,
XTE_RXC1_RXVLAN_MASK,	0},
+    { 0,  XTE_OPTION_FCS_STRIP,             XTE_RXC1_OFFSET,
XTE_RXC1_RXFCS_MASK,	0},   /* Turn on FCS stripping on receive packets */
+    { 0,  XTE_OPTION_FCS_INSERT,            XTE_TXC_OFFSET,
XTE_TXC_TXFCS_MASK,	    0},    /* Turn on FCS insertion on transmit
packets */
+    { 0,  XTE_OPTION_LENTYPE_ERR,           XTE_RXC1_OFFSET,
XTE_RXC1_RXLT_MASK,	    0},    /* Turn on length/type field checking on
receive packets */
+    { 0,  XTE_OPTION_FLOW_CONTROL,          XTE_FCC_OFFSET,
XTE_FCC_RXFLO_MASK,	    0},    /* Turn on flow control */
+    { 0,  XTE_OPTION_FLOW_CONTROL,          XTE_FCC_OFFSET,
XTE_FCC_TXFLO_MASK,	    0},    /* Turn on flow control */
+    { 0,  XTE_OPTION_PROMISC,               XTE_AFM_OFFSET,
XTE_AFM_EPPRM_MASK,	    0},     /* Turn on promiscuous frame filtering
(all frames are received ) */
+    { 0,  XTE_OPTION_TXEN,                  XTE_TXC_OFFSET,
XTE_TXC_TXEN_MASK,	    0},     /* Enable transmitter if not already
enabled */
+    { 0,  XTE_OPTION_RXEN,                 XTE_RXC1_OFFSET,
XTE_RXC1_RXEN_MASK,	    0},    /* Enable receiver? */
+    { 0, 0, 0, 0,	0}
+};
+
+/*****************************************************************************/
+/**
+ * Set options for the driver/device. The driver should be stopped with
+ * XTemac_Stop() before changing options.
+ *
+ * @param InstancePtr is a pointer to the instance to be worked on.
+ * @param Options are the options to set. Multiple options can be set
by OR'ing
+ *        XTE_*_OPTIONS constants together. Options not specified are not
+ *        affected.
+ *
+ * @return
+ * - 0 if the options were set successfully
+ * - XST_DEVICE_IS_STARTED if the device has not yet been stopped
+ * - XST_NO_FEATURE if setting an option requires HW support not present
+ *
+ * @note
+ * See xtemac.h for a description of the available options.
+ *
+
******************************************************************************/
+static u32
+temac_setoptions(struct net_device *ndev, u32 Options) {
+	struct temac_local *lp = netdev_priv(ndev);
+    struct temac_option *tp = &temac_options[0];
+
+    while (tp->opt) {
+        if (tp->flg)
+            tio_setclr(ndev, tp->reg, tp->m_or, (Options & tp->opt));
+        else
+            emac_cfg_setclr(ndev, tp->reg, tp->m_or, (Options & tp->opt));
+        tp++;
+    }
+    lp->options |= Options;
+
+    return (0);
+}
+
+/*
+Initilize temac board
+ */
+static void
+temac_device_reset(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+
+    /* Perform a software reset */
+
+    /* 0x300 host enable bit ? */
+    /* reset PHY through control register ?:1 */
+
+    /* Reset the device */
+    emac_cfg_write(ndev, XTE_RXC1_OFFSET, XTE_RXC1_RXRST_MASK);
+    while (emac_cfg_read(ndev, XTE_RXC1_OFFSET) & XTE_RXC1_RXRST_MASK)
; /* Wait for the receiver to finish reset */
+
+    emac_cfg_write(ndev, XTE_TXC_OFFSET, XTE_TXC_TXRST_MASK);
+    while (emac_cfg_read(ndev, XTE_TXC_OFFSET) & XTE_TXC_TXRST_MASK) ;
  /* Wait for the transmitter to finish reset */
+    /* Disable the receiver */
+    emac_cfg_write(ndev, XTE_RXC1_OFFSET, emac_cfg_read(ndev,
XTE_RXC1_OFFSET) & ~XTE_RXC1_RXEN_MASK);
+
+    tiow(ndev, XTE_RAF0_OFFSET, 1);
 /* reset */
+    while(tior(ndev, XTE_RAF0_OFFSET) & 1);
 /* wait for reset */
+    /* ISR0/IER0/IPR0 bits */
+    /* b1                                                  autoneg
complete */
+    /* b2                                                  receive
complete */
+    /* b5                                                  transmit
complete */
+    /* b0       = interrupts from TIS/TIE registers */
+
+
+    sd_iow(ndev, DMA_CONTROL_REG, DMA_CONTROL_RST);             /*
Reset ? */
+    while(sd_ior(ndev, DMA_CONTROL_REG) & DMA_CONTROL_RST);
+
+    printk(KERN_INFO "%s: Xilinx Embedded Tri-Mode Ethernet MAC %s
%s\n", ndev->name, __DATE__, __TIME__);
+    // printk(KERN_INFO "temac %08x[%08x] sdma %08x[%08x]\n", (u32)
ndev->base_addr, LLTEMAC_BASEADDR, lp->sdma_base_addr, SDMACTRL_BASEADDR);
+    printk(KERN_INFO "temac %08x sdma %08x\n", (u32) ndev->base_addr,
lp->sdma_base_addr);
+
+    temac_bd_init(ndev);
+    /* emac_cfg_write(ndev, XTE_AFM_OFFSET, 0x00000000); */
+    emac_cfg_write(ndev, XTE_RXC0_OFFSET, 0);
+    emac_cfg_write(ndev, XTE_RXC1_OFFSET, 0);
+    emac_cfg_write(ndev, XTE_TXC_OFFSET, 0);
+    emac_cfg_write(ndev, XTE_FCC_OFFSET, XTE_FCC_RXFLO_MASK);
+
+    /* Sync default options with HW but leave receiver and transmitter
disabled.  */
+    temac_setoptions(ndev, lp-> options & ~(XTE_OPTION_TXEN |
XTE_OPTION_RXEN));
+    temac_phy_init(ndev);
+    temac_set_mac_address(ndev, 0);
+    /* Set address filter table */
+    temac_set_multicast_list(ndev);
+    if (temac_setoptions(ndev, lp->options))
+        dev_err(ndev, "Error setting TEMAC options\n");
+
+    /* Init Driver variable */
+    ndev->trans_start = 0;
+    spin_lock_init(&lp->lock);
+    spin_lock_init(&lp->tx_lock);
+    spin_lock_init(&lp->rx_lock);
+}
+
+static void
+temac_hard_start_xmit_done(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    struct cdmac_bd *cur_p;
+    unsigned int stat = 0;
+    unsigned long flags;
+
+    spin_lock_irqsave(&lp->tx_lock, flags);
+
+    cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
+    stat = cur_p->app0;
+
+    while(stat & STS_CTRL_APP0_CMPLT) {
+        pci_unmap_single(NULL, (unsigned long)cur_p->phys, cur_p->len,
PCI_DMA_TODEVICE);
+        if (cur_p->app4)
+            dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
+        cur_p->app0 = 0;
+
+        lp->stats.tx_packets++;
+        lp->stats.tx_bytes += cur_p->len;
+
+        lp->tx_bd_ci++;
+        if (lp->tx_bd_ci >= TX_BD_NUM) lp->tx_bd_ci = 0;
+
+        cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
+        stat = cur_p->app0;
+    }
+
+    spin_unlock_irqrestore(&lp->tx_lock, flags);
+
+    if(netif_queue_stopped(ndev)) {
+        netif_wake_queue(ndev);
+    }
+}
+
+static int
+temac_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    struct cdmac_bd *cur_p, *start_p, *tail_p;
+    int i;
+    unsigned long num_frag;
+    skb_frag_t *frag;
+
+    spin_lock(&lp->tx_lock);
+
+    num_frag = skb_shinfo(skb)->nr_frags;
+    frag = &skb_shinfo(skb)->frags[0];
+    start_p = &lp->tx_bd_p[lp->tx_bd_tail];
+    cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
+
+    if(cur_p->app0 & STS_CTRL_APP0_CMPLT) {
+        if(!netif_queue_stopped(ndev)) {
+            netif_stop_queue(ndev);
+            spin_unlock(&lp->tx_lock);
+            return NETDEV_TX_BUSY;
+        }
+        return NETDEV_TX_BUSY;
+    }
+
+    cur_p->app0 = 0;
+    if(skb->ip_summed == CHECKSUM_PARTIAL) {
+        const struct iphdr *ip = ip_hdr(skb);
+        int length=0, start, insert=0, headlen;
+
+        switch(ip->protocol) {
+            case IPPROTO_TCP:
+                start = sizeof(struct iphdr) + ETH_HLEN;
+                insert = sizeof(struct iphdr) + ETH_HLEN + 16;
+                length = ip->tot_len - sizeof(struct iphdr);
+                headlen = ETH_HLEN + sizeof(struct iphdr) +
sizeof(struct tcphdr);
+                break;
+            case IPPROTO_UDP:
+                start = sizeof(struct iphdr) + ETH_HLEN;
+                insert = sizeof(struct iphdr) + ETH_HLEN + 6;
+                length = ip->tot_len - sizeof(struct iphdr);
+                headlen = ETH_HLEN + sizeof(struct iphdr) +
sizeof(struct udphdr);
+                break;
+            default:
+                break;
+        }
+        cur_p->app1 = ((start << 16) | insert);
+        cur_p->app2 = csum_tcpudp_magic(ip->saddr, ip->daddr, length,
ip->protocol, 0);
+        skb->data[insert] = 0;
+        skb->data[insert + 1] = 0;
+    }
+    cur_p->app0 |= STS_CTRL_APP0_SOP;
+    cur_p->len = skb_headlen(skb);
+    cur_p->phys = (unsigned char *)pci_map_single(NULL, skb->data,
skb->len, PCI_DMA_TODEVICE);
+    cur_p->app4 = (unsigned long)skb;
+
+    for(i = 0;i < num_frag;i++) {
+        lp->tx_bd_tail++;
+        if (lp->tx_bd_tail >= TX_BD_NUM) lp->tx_bd_tail = 0;
+
+        cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
+        cur_p->phys = (unsigned char *)pci_map_single(NULL, (void
*)page_address(frag->page) + frag->page_offset, frag-> size,
PCI_DMA_TODEVICE);
+        cur_p->len = frag->size;
+        cur_p->app0 = 0;
+        frag++;
+    }
+    cur_p->app0 |= STS_CTRL_APP0_EOP;
+
+    tail_p = &lp->tx_bd_p[lp->tx_bd_tail];
+    lp->tx_bd_tail++;
+    if (lp->tx_bd_tail >= TX_BD_NUM) lp->tx_bd_tail = 0;
+
+    if(!(sd_ior(ndev, TX_CHNL_STS) & CHNL_STS_ENGBUSY)) {        /*
EngBusy ? */
+        sd_iow(ndev, TX_CURDESC_PTR, (uintptr_t)start_p);
+        sd_iow(ndev, TX_TAILDESC_PTR, (uintptr_t)tail_p);    /* DMA
start */
+    }
+
+    spin_unlock(&lp->tx_lock);
+
+    return 0;
+}
+
+/*
+Stop the interface.
+Stops the interface. The interface is stopped when it is brought down.
+This function should reverse operations performed at open time.
+*/
+static int
+temac_stop(struct net_device *ndev)
+{
+    return 0;
+}
+
+static void
+ll_temac_recv(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+    struct sk_buff *skb, *new_skb;
+    unsigned int bdstat;
+    unsigned long align;
+    struct cdmac_bd *cur_p, *tail_p;
+    int length;
+    unsigned long skb_vaddr;
+    unsigned long flags;
+
+    spin_lock_irqsave(&lp->rx_lock, flags);
+
+    tail_p = &lp->rx_bd_p[lp->rx_bd_ci];
+    cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
+
+    bdstat = cur_p->app0;
+    while((bdstat & STS_CTRL_APP0_CMPLT)) {
+
+        skb = lp->rx_skb[lp->rx_bd_ci];
+        length = cur_p->app4;
+
+        skb_vaddr = virt_to_bus(skb->data);
+        pci_unmap_single(NULL, skb_vaddr, length, PCI_DMA_FROMDEVICE);
+
+        skb_put(skb, length);
+        skb->dev = ndev;
+        skb->protocol = eth_type_trans(skb, ndev);
+        skb->ip_summed = CHECKSUM_NONE;
+
+        netif_rx(skb);
+
+        lp->stats.rx_packets++;
+        lp->stats.rx_bytes += length;
+
+        new_skb = alloc_skb(XTE_MAX_JUMBO_FRAME_SIZE + ALIGNMENT,
GFP_ATOMIC);
+        if(new_skb == 0) {
+            printk("no memory for new sk_buff\n");
+            spin_unlock_irqrestore(&lp->rx_lock, flags);
+            return;
+        }
+
+        align = BUFFER_ALIGN(new_skb->data);
+        if(align) skb_reserve(new_skb, align);
+
+        cur_p->app0 = STS_CTRL_APP0_IRQONEND;
+        cur_p->phys = (unsigned char *)
+                    pci_map_single(NULL, new_skb->data,
+                               XTE_MAX_JUMBO_FRAME_SIZE,
+                               PCI_DMA_FROMDEVICE);
+        cur_p->len    = XTE_MAX_JUMBO_FRAME_SIZE;
+        lp->rx_skb[lp->rx_bd_ci] = new_skb;
+
+        lp->rx_bd_ci++;
+        if(lp->rx_bd_ci >= RX_BD_NUM) lp->rx_bd_ci = 0;
+
+        cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
+        bdstat = cur_p->app0;
+    }
+    sd_iow(ndev, RX_TAILDESC_PTR, (uintptr_t)tail_p);
+
+    spin_unlock_irqrestore(&lp->rx_lock, flags);
+}
+
+static irqreturn_t
+ll_temac_tx_interrupt(int irq, void *dev_id)
+{
+    unsigned int status;
+    struct net_device *ndev = (struct net_device *)dev_id;
+
+    status = sd_ior(ndev, TX_IRQ_REG);
+    sd_iow(ndev, TX_IRQ_REG, status);
+
+    if(status & (IRQ_COAL | IRQ_DLY))
+        temac_hard_start_xmit_done(ndev);
+    if(status & 0x080)
+        dev_err(ndev, "DMA error 0x%x\n", status);
+
+    return IRQ_HANDLED;
+}
+
+static irqreturn_t
+ll_temac_rx_interrupt(int irq, void * dev_id)
+{
+    unsigned int status;
+    struct net_device *ndev = (struct net_device *)dev_id;
+
+    status = sd_ior(ndev, RX_IRQ_REG);
+    sd_iow(ndev, RX_IRQ_REG, status);
+
+    if(status & (IRQ_COAL | IRQ_DLY)) ll_temac_recv(ndev);
+
+    return IRQ_HANDLED;
+}
+
+/*
+Whenever an application needs to get statistics for the interface, this
method is
+called. This happens, for example, when ifconfig or netstat -i is run.
A sample
+implementation for snull is introduced in the section Statistical
Information.
+ */
+static struct net_device_stats *
+temac_get_stats(struct net_device *ndev)
+{
+    return netdev_priv(ndev);
+}
+
+static int
+temac_open(struct net_device *ndev)
+{
+
+    return 0;
+}
+
+/*
+OPTIONAL
+void (*poll_controller)(struct net_device *dev);
+Function that asks the driver to check for events on the interface in
situations
+where interrupts are disabled. It is used for specific in-kernel
networking tasks,
+such as remote consoles and kernel debugging over the network.
+
+*/
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void
+temac_poll_controller(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+
+    disable_irq(lp->tx_irq);
+    disable_irq(lp->rx_irq);
+
+    ll_temac_rx_interrupt(lp->tx_irq, ndev, 0);
+    ll_temac_tx_interrupt(lp->rx_irq, ndev, 0);
+
+    enable_irq(lp->tx_irq);
+    enable_irq(lp->rx_irq);
+}
+#endif
+/*
+OPTIONAL
+
+int (*change_mtu)(struct net_device *dev, int new_mtu);
+Function that takes action if there is a change in the maximum transfer
unit (MTU)
+for the interface. If the driver needs to do anything particular when
the MTU is
+changed by the user, it should declare its own function; otherwise, the
default does
+the right thing. snull has a template for the function if you are
interested.
+*/
+static int
+temac_change_mtu(struct net_device *ndev, int newmtu)
+{
+    dev_info(ndev, "new MTU %d\n", newmtu);
+    ndev->mtu = newmtu; /* change mtu in net_device structure */
+
+    return 0;
+}
+
+
+static int __init
+temac_device_map(struct platform_device *pdev, struct net_device *ndev,
int num, unsigned long *addr)
+{
+	struct resource *res;
+    int erC = 0;
+
+	if((res = platform_get_resource(pdev, IORESOURCE_MEM, num)) == 0) {
+		erC = -ENODEV;
+		goto fail;
+	}
+	if (request_mem_region(res->start, res->end - res->start, pdev->name)
== 0) {
+		printk(KERN_ERR "%s: failed to request registers\n", pdev->name);
+		erC = -ENXIO;
+		goto fail_reserve;
+	}
+
+	*addr = (unsigned long) ioremap_nocache(res->start, res->end -
res->start);
+	if (*addr == 0) {
+		printk(KERN_ERR "%s: failed to remap registers\n", pdev->name);
+		erC = -ENXIO;
+		goto fail_remap;
+	}
+    // dev_info(pdev, "num %d start %p, end %p, addr %p\n", num,
res->start, res->end, *addr);
+    return 0;
+fail_remap:
+	release_region(*addr, res->end-res->start);
+fail_reserve:
+fail:
+    return erC;
+}
+/*
+Search TEMAC board, allocate space and register it
+ */
+static int __init
+temac_device_probe(struct platform_device *pdev)
+{
+    struct net_device *ndev = alloc_etherdev(sizeof(struct temac_local));
+	// struct eth_plat_info *plat = pdev->dev.platform_data;
+    struct temac_local *lp;
+    u8 addr[] = { 0x0, 0x50, 0xc2, 0x44, 0x2f, 0xff };
+    int erC = 0;
+
+    /* Init network device */
+    if (!ndev) {
+        dev_err(pdev, "could not allocate device.\n");
+        return -ENOMEM;
+    }
+	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+    /* setup board info structure */
+    /* Clear memory */
+	lp = netdev_priv(ndev);
+    memset(lp, 0, sizeof(struct temac_local));
+    if ((erC = temac_device_map(pdev, ndev, 0, &ndev->base_addr))) {
+        dev_err("pdev, could not allocate temac regs.\n");
+        return erC;
+    }
+    if ((erC = temac_device_map(pdev, ndev, 1, &lp->sdma_base_addr))) {
+        dev_err(pdev, "could not allocate sdma regs.\n");
+        return erC;
+    }
+	if ((lp->rx_irq = platform_get_irq(pdev, 0)) < 0) {
+        dev_err(pdev, "could not allocate rx irq.\n");
+        return -ENOMEM;
+    }
+    // dev_info(pdev, "rx_irq %d \n", lp->rx_irq);
+	if ((lp->tx_irq = platform_get_irq(pdev, 1)) < 0) {
+        dev_err(pdev, "could not allocate tx irq.\n");
+        return -ENOMEM;
+    }
+    // dev_info(pdev, "tx_irq %d \n", lp->tx_irq);
+
+    dev_info(pdev, "%s", DRV_NAME ".c:v " __DATE__ "  " DRV_AUTHOR " "
DRV_EMAIL "\n");
+
+    lp->dev = ndev;
+    lp->emac_num = 0;
+    lp->options = XTE_OPTION_DEFAULTS;
+    lp->LinkSpeed = 1000;           /* Tell driver that the PHY is
10/100/1000 capable */
+    lp->mii = 1;                    /*  really important can't
read/write anyting until set */
+
+	// memcpy(ndev->dev_addr, plat->hwaddr, ETH_ALEN);
+    temac_set_mac_address(ndev, addr);
+    /* from this point we assume that we have found a TEMAC */
+    /* driver system function */
+    ether_setup(ndev);
+    /* The TEMAC-specific entries in the device structure. */
+    ndev->open = &temac_open;
+    ndev->stop = &temac_stop;
+    ndev->get_stats = &temac_get_stats;
+    ndev->set_mac_address = &temac_set_mac_address;
+    ndev->hard_start_xmit = &temac_hard_start_xmit;
+    ndev->set_multicast_list = &temac_set_multicast_list;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+    ndev->poll_controller = &temac_poll_controller;
+#endif
+    ndev->change_mtu = &temac_change_mtu;
+    ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
+
+    ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
+
+    erC = request_irq(lp->tx_irq, ll_temac_tx_interrupt, 0, ndev->name,
ndev);
+    erC = request_irq(lp->rx_irq, ll_temac_rx_interrupt, 0, ndev->name,
ndev);
+    temac_device_reset(ndev);
+
+    if ((erC = register_netdev(ndev)))
+        goto nodev;
+    return 0;
+
+	release_region(ndev->base_addr, 0x18);
+nodev:
+    free_netdev(ndev);
+    ndev = NULL;
+    return erC;
+}
+
+static int __devexit temac_device_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	// struct temac_local *lp = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	// free_irq(dev->irq, dev);
+	// dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist,
(dma_addr_t)lp->dlist_phys);
+	platform_set_drvdata(pdev, NULL);
+	free_netdev(dev);
+	return 0;
+}
+static struct platform_driver temac_device_driver = {
+	.probe		= temac_device_probe,
+	.remove		= __devexit_p(temac_device_remove),
+	.suspend	= NULL,
+	.resume		= NULL,
+	.driver		= {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init
+temac_init_module(void)
+{
+    printk(KERN_INFO "temac_init_module()");
+	return platform_driver_register(&temac_device_driver);
+}
+
+static void __exit
+temac_cleanup_module(void)
+{
+	platform_driver_unregister(&temac_device_driver);
+}
+
+module_init(temac_init_module);
+module_exit(temac_cleanup_module);
+
+MODULE_DESCRIPTION("Xilinx Tri-Mode Eth MAC driver");
+MODULE_ALIAS("platform:" DRV_NAME);
+MODULE_AUTHOR(DRV_AUTHOR);
+MODULE_LICENSE("GPL");
+// MODULE_ALIAS("platform:" DRV_NAME);
+
+
diff --git a/include/linux/xilinx_devices.h b/include/linux/xilinx_devices.h
index 41ad421..79ca491 100755
--- a/include/linux/xilinx_devices.h
+++ b/include/linux/xilinx_devices.h
@@ -94,7 +94,7 @@ struct xtemac_platform_data {
 #define XTEMAC_DMA_SGDMA	3	/* scatter gather DMA */
 #endif

-#if defined(CONFIG_XILINX_LLTEMAC)
+#if defined(CONFIG_XILINX_LLTEMAC) || defined(CONFIG_XPS_LLTEMAC)
 /* LLTEMAC platform data */
 struct xlltemac_platform_data {
 	u8 tx_csum;

