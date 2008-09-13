From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sat, 13 Sep 2008 16:35:48 -0400
Message-ID: <20080913203548.GA2989@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52756 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752891AbYIMUfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 16:35:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Includes several fixes from my slice of the akpm patch pie.

Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 MAINTAINERS                    |    4 +++-
 drivers/net/8139too.c          |    3 ++-
 drivers/net/atl1e/atl1e_main.c |    2 --
 drivers/net/au1000_eth.c       |    3 ++-
 drivers/net/bonding/bond_alb.c |   24 ++++++++++++++++++++++++
 drivers/net/cs89x0.c           |    2 --
 drivers/net/ehea/ehea_phyp.c   |    2 +-
 drivers/net/ehea/ehea_qmr.c    |    3 ++-
 drivers/net/forcedeth.c        |   16 +++++++++++++---
 drivers/net/mlx4/alloc.c       |    1 +
 drivers/net/ne.c               |    9 ++++++++-
 drivers/net/r8169.c            |   25 ++++++++++++++-----------
 drivers/net/s2io.c             |   18 ++++++++++--------
 drivers/net/s2io.h             |    1 +
 drivers/net/skfp/pmf.c         |   29 +++++++++++------------------
 drivers/net/smc91x.c           |    3 ++-
 drivers/net/smc91x.h           |    2 ++
 drivers/net/tulip/de2104x.c    |    1 -
 drivers/net/usb/hso.c          |    9 +++++----
 drivers/net/wan/hdlc_x25.c     |    8 +++++---
 20 files changed, 106 insertions(+), 59 deletions(-)

Adrian Bunk (1):
      [netdrvr/usb] hso_create_bulk_serial_device(): fix a double free

Andrew Morton (1):
      drivers/net/mlx4/alloc.c needs mm.h

Breno Leitao (1):
      s2io: Fix enabling VLAN tag stripping at driver initialization

Chris Snook (1):
      MAINTAINERS: add Atheros maintainer for atlx

David Fries (1):
      [netdrvr] ne: Fix suspend and resume for ISA PnP cards.

Francois Romieu (1):
      r8169: fix RxMissed register access

Hannes Hering (1):
      ehea: Fix DLPAR memory handling

Krzysztof Halasa (1):
      wan/hdlc_x25.c: fix a NULL dereference

Magnus Damm (2):
      smc91x: fix nowait printout
      smc91x: SMC_IO_SHIFT platform data support for default case

Martin Gebert (1):
      [netdrvr] au1000_eth: Spinlock initialisation fix

Mats Erik Andersson (1):
      8139too: [cosmetic] fix incorrect register for flash-rom

Matthew Wilcox (1):
      [netdrvr] atl1e: Don't take the mdio_lock in atl1e_probe

Sebastien Dugue (1):
      ehea: fix phyp debugging typo

Takashi Iwai (1):
      drivers/net/skfp/pmf.c: Use offsetof() macro

Thomas Bogendoerfer (1):
      tulip: Fix dead 21041 ethernet after ifconfig down

Vlad Yasevich (1):
      bonding: Do not tx-balance some IPv6 packets on ALB/TLB bonds

Yinghai Lu (1):
      forcedeth: call restore mac addr in nv_shutdown path

Yoichi Yuasa (1):
      cs89x0: fix warning release_irq label

diff --git a/MAINTAINERS b/MAINTAINERS
index b3e92fb..186be3b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -750,11 +750,13 @@ P:	Ville Syrjala
 M:	syrjala@sci.fi
 S:	Maintained
 
-ATL1 ETHERNET DRIVER
+ATLX ETHERNET DRIVERS
 P:	Jay Cliburn
 M:	jcliburn@gmail.com
 P:	Chris Snook
 M:	csnook@redhat.com
+P:	Jie Yang
+M:	jie.yang@atheros.com
 L:	atl1-devel@lists.sourceforge.net
 W:	http://sourceforge.net/projects/atl1
 W:	http://atl1.sourceforge.net
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 8a5b0d2..9070bad 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -309,7 +309,7 @@ enum RTL8139_registers {
 	Cfg9346		= 0x50,
 	Config0		= 0x51,
 	Config1		= 0x52,
-	FlashReg	= 0x54,
+	TimerInt	= 0x54,
 	MediaStatus	= 0x58,
 	Config3		= 0x59,
 	Config4		= 0x5A,	 /* absent on RTL-8139A */
@@ -325,6 +325,7 @@ enum RTL8139_registers {
 	FIFOTMS		= 0x70,	 /* FIFO Control and test. */
 	CSCR		= 0x74,	 /* Chip Status and Configuration Register. */
 	PARA78		= 0x78,
+	FlashReg	= 0xD4,	/* Communication with Flash ROM, four bytes. */
 	PARA7c		= 0x7c,	 /* Magic transceiver parameter register. */
 	Config5		= 0xD8,	 /* absent on RTL-8139A */
 };
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 7685b99..9b60352 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2390,9 +2390,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 	}
 
 	/* Init GPHY as early as possible due to power saving issue  */
-	spin_lock(&adapter->mdio_lock);
 	atl1e_phy_init(&adapter->hw);
-	spin_unlock(&adapter->mdio_lock);
 	/* reset the controller to
 	 * put the device in a known good starting state */
 	err = atl1e_reset_hw(&adapter->hw);
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 5ee1b05..92c16c3 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -653,6 +653,8 @@ static struct net_device * au1000_probe(int port_num)
 
 	aup = dev->priv;
 
+	spin_lock_init(&aup->lock);
+
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
 	aup->vaddr = (u32)dma_alloc_noncoherent(NULL, MAX_BUF_SIZE *
@@ -753,7 +755,6 @@ static struct net_device * au1000_probe(int port_num)
 		aup->tx_db_inuse[i] = pDB;
 	}
 
-	spin_lock_init(&aup->lock);
 	dev->base_addr = base;
 	dev->irq = irq;
 	dev->open = au1000_open;
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b211486..c219262 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -38,6 +38,7 @@
 #include <linux/in.h>
 #include <net/ipx.h>
 #include <net/arp.h>
+#include <net/ipv6.h>
 #include <asm/byteorder.h>
 #include "bonding.h"
 #include "bond_alb.h"
@@ -81,6 +82,7 @@
 #define RLB_PROMISC_TIMEOUT	10*ALB_TIMER_TICKS_PER_SEC
 
 static const u8 mac_bcast[ETH_ALEN] = {0xff,0xff,0xff,0xff,0xff,0xff};
+static const u8 mac_v6_allmcast[ETH_ALEN] = {0x33,0x33,0x00,0x00,0x00,0x01};
 static const int alb_delta_in_ticks = HZ / ALB_TIMER_TICKS_PER_SEC;
 
 #pragma pack(1)
@@ -1290,6 +1292,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	u32 hash_index = 0;
 	const u8 *hash_start = NULL;
 	int res = 1;
+	struct ipv6hdr *ip6hdr;
 
 	skb_reset_mac_header(skb);
 	eth_data = eth_hdr(skb);
@@ -1319,11 +1322,32 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	}
 		break;
 	case ETH_P_IPV6:
+		/* IPv6 doesn't really use broadcast mac address, but leave
+		 * that here just in case.
+		 */
 		if (memcmp(eth_data->h_dest, mac_bcast, ETH_ALEN) == 0) {
 			do_tx_balance = 0;
 			break;
 		}
 
+		/* IPv6 uses all-nodes multicast as an equivalent to
+		 * broadcasts in IPv4.
+		 */
+		if (memcmp(eth_data->h_dest, mac_v6_allmcast, ETH_ALEN) == 0) {
+			do_tx_balance = 0;
+			break;
+		}
+
+		/* Additianally, DAD probes should not be tx-balanced as that
+		 * will lead to false positives for duplicate addresses and
+		 * prevent address configuration from working.
+		 */
+		ip6hdr = ipv6_hdr(skb);
+		if (ipv6_addr_any(&ip6hdr->saddr)) {
+			do_tx_balance = 0;
+			break;
+		}
+
 		hash_start = (char *)&(ipv6_hdr(skb)->daddr);
 		hash_size = sizeof(ipv6_hdr(skb)->daddr);
 		break;
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index ea6144a..b0b6676 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1397,9 +1397,7 @@ net_open(struct net_device *dev)
 release_dma:
 #if ALLOW_DMA
 		free_dma(dev->dma);
-#endif
 release_irq:
-#if ALLOW_DMA
 		release_dma_buff(lp);
 #endif
                 writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) & ~(SERIAL_TX_ON | SERIAL_RX_ON));
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 156eb63..2a33a61 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -535,7 +535,7 @@ u64 ehea_h_query_ehea(const u64 adapter_handle, void *cb_addr)
 				       cb_logaddr,		/* R5 */
 				       0, 0, 0, 0, 0);		/* R6-R10 */
 #ifdef DEBUG
-	ehea_dmp(cb_addr, sizeof(struct hcp_query_ehea), "hcp_query_ehea");
+	ehea_dump(cb_addr, sizeof(struct hcp_query_ehea), "hcp_query_ehea");
 #endif
 	return hret;
 }
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 140f05b..db8a925 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -595,7 +595,8 @@ static int ehea_create_busmap_callback(unsigned long pfn,
 	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
 	mr_len = *(unsigned long *)arg;
 
-	ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
+	if (!ehea_bmap)
+		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 	if (!ehea_bmap)
 		return -ENOMEM;
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0b6ecef..eeb55ed 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5643,6 +5643,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev->dev_addr[4] = (np->orig_mac[0] >>  8) & 0xff;
 		dev->dev_addr[5] = (np->orig_mac[0] >>  0) & 0xff;
 		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
+		printk(KERN_DEBUG "nv_probe: set workaround bit for reversed mac addr\n");
 	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
@@ -5890,14 +5891,12 @@ static void nv_restore_phy(struct net_device *dev)
 	}
 }
 
-static void __devexit nv_remove(struct pci_dev *pci_dev)
+static void nv_restore_mac_addr(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	unregister_netdev(dev);
-
 	/* special op: write back the misordered MAC address - otherwise
 	 * the next nv_probe would see a wrong address.
 	 */
@@ -5905,6 +5904,15 @@ static void __devexit nv_remove(struct pci_dev *pci_dev)
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
 	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR_REV,
 	       base + NvRegTransmitPoll);
+}
+
+static void __devexit nv_remove(struct pci_dev *pci_dev)
+{
+	struct net_device *dev = pci_get_drvdata(pci_dev);
+
+	unregister_netdev(dev);
+
+	nv_restore_mac_addr(pci_dev);
 
 	/* restore any phy related changes */
 	nv_restore_phy(dev);
@@ -5975,6 +5983,8 @@ static void nv_shutdown(struct pci_dev *pdev)
 	if (netif_running(dev))
 		nv_close(dev);
 
+	nv_restore_mac_addr(pdev);
+
 	pci_disable_device(pdev);
 	if (system_state == SYSTEM_POWER_OFF) {
 		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index 096bca5..b411b79 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -33,6 +33,7 @@
 
 #include <linux/errno.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/bitmap.h>
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index fa3ceca..7959990 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -844,8 +844,12 @@ static int ne_drv_suspend(struct platform_device *pdev, pm_message_t state)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
 		netif_device_detach(dev);
+		if (idev)
+			pnp_stop_dev(idev);
+	}
 	return 0;
 }
 
@@ -854,6 +858,9 @@ static int ne_drv_resume(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+		if (idev)
+			pnp_start_dev(idev);
 		ne_reset_8390(dev);
 		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0f6f974..4190ee7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2099,8 +2099,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2143,8 +2141,6 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	RTL_W32(RxMissed, 0);
-
 	rtl_set_rx_mode(dev);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2922,6 +2918,17 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+static void rtl8169_rx_missed(struct net_device *dev, void __iomem *ioaddr)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06)
+		return;
+
+	dev->stats.rx_missed_errors += (RTL_R32(RxMissed) & 0xffffff);
+	RTL_W32(RxMissed, 0);
+}
+
 static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2939,9 +2946,7 @@ core_down:
 
 	rtl8169_asic_down(ioaddr);
 
-	/* Update the error counts. */
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
@@ -3063,8 +3068,7 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-		RTL_W32(RxMissed, 0);
+		rtl8169_rx_missed(dev, ioaddr);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
@@ -3089,8 +3093,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	rtl8169_asic_down(ioaddr);
 
-	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
-	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..1386d76 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -371,9 +371,6 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 				flags[i]);
 }
 
-/* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
-static int vlan_strip_flag;
-
 /* Unregister the vlan */
 static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
 {
@@ -2303,7 +2300,7 @@ static int start_nic(struct s2io_nic *nic)
 		val64 = readq(&bar0->rx_pa_cfg);
 		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
 		writeq(val64, &bar0->rx_pa_cfg);
-		vlan_strip_flag = 0;
+		nic->vlan_strip_flag = 0;
 	}
 
 	/*
@@ -5010,7 +5007,7 @@ static void s2io_set_multicast(struct net_device *dev)
 			val64 = readq(&bar0->rx_pa_cfg);
 			val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
 			writeq(val64, &bar0->rx_pa_cfg);
-			vlan_strip_flag = 0;
+			sp->vlan_strip_flag = 0;
 		}
 
 		val64 = readq(&bar0->mac_cfg);
@@ -5032,7 +5029,7 @@ static void s2io_set_multicast(struct net_device *dev)
 			val64 = readq(&bar0->rx_pa_cfg);
 			val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
 			writeq(val64, &bar0->rx_pa_cfg);
-			vlan_strip_flag = 1;
+			sp->vlan_strip_flag = 1;
 		}
 
 		val64 = readq(&bar0->mac_cfg);
@@ -8206,6 +8203,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	/* Initialize device name */
 	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
+	if (vlan_tag_strip)
+		sp->vlan_strip_flag = 1;
+	else
+		sp->vlan_strip_flag = 0;
+
 	/*
 	 * Make Link state as off at this point, when the Link change
 	 * interrupt comes the state will be automatically changed to
@@ -8311,7 +8313,7 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 		 * If vlan stripping is disabled and the frame is VLAN tagged,
 		 * shift the offset by the VLAN header size bytes.
 		 */
-		if ((!vlan_strip_flag) &&
+		if ((!sp->vlan_strip_flag) &&
 			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
 			ip_off += HEADER_VLAN_SIZE;
 	} else {
@@ -8592,7 +8594,7 @@ static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 
 	skb->protocol = eth_type_trans(skb, dev);
 	if (sp->vlgrp && vlan_tag
-		&& (vlan_strip_flag)) {
+		&& (sp->vlan_strip_flag)) {
 		/* Queueing the vlan frame to the upper layer */
 		if (sp->config.napi)
 			vlan_hwaccel_receive_skb(skb, sp->vlgrp, vlan_tag);
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 6722a2f..55cb943 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -962,6 +962,7 @@ struct s2io_nic {
 	int task_flag;
 	unsigned long long start_time;
 	struct vlan_group *vlgrp;
+	int vlan_strip_flag;
 #define MSIX_FLG                0xA5
 	int num_entries;
 	struct msix_entry *entries;
diff --git a/drivers/net/skfp/pmf.c b/drivers/net/skfp/pmf.c
index ea85de9..79e665e 100644
--- a/drivers/net/skfp/pmf.c
+++ b/drivers/net/skfp/pmf.c
@@ -44,17 +44,10 @@ static SMbuf *smt_build_pmf_response(struct s_smc *smc, struct smt_header *req,
 				     int set, int local);
 static int port_to_mib(struct s_smc *smc, int p);
 
-#define MOFFSS(e)	((int)&(((struct fddi_mib *)0)->e))
-#define MOFFSA(e)	((int) (((struct fddi_mib *)0)->e))
-
-#define MOFFMS(e)	((int)&(((struct fddi_mib_m *)0)->e))
-#define MOFFMA(e)	((int) (((struct fddi_mib_m *)0)->e))
-
-#define MOFFAS(e)	((int)&(((struct fddi_mib_a *)0)->e))
-#define MOFFAA(e)	((int) (((struct fddi_mib_a *)0)->e))
-
-#define MOFFPS(e)	((int)&(((struct fddi_mib_p *)0)->e))
-#define MOFFPA(e)	((int) (((struct fddi_mib_p *)0)->e))
+#define MOFFSS(e)	offsetof(struct fddi_mib, e)
+#define MOFFMS(e)	offsetof(struct fddi_mib_m, e)
+#define MOFFAS(e)	offsetof(struct fddi_mib_a, e)
+#define MOFFPS(e)	offsetof(struct fddi_mib_p, e)
 
 
 #define AC_G	0x01		/* Get */
@@ -87,8 +80,8 @@ static const struct s_p_tab {
 	{ SMT_P100D,AC_G,	MOFFSS(fddiSMTOpVersionId),	"S"	} ,
 	{ SMT_P100E,AC_G,	MOFFSS(fddiSMTHiVersionId),	"S"	} ,
 	{ SMT_P100F,AC_G,	MOFFSS(fddiSMTLoVersionId),	"S"	} ,
-	{ SMT_P1010,AC_G,	MOFFSA(fddiSMTManufacturerData), "D" } ,
-	{ SMT_P1011,AC_GR,	MOFFSA(fddiSMTUserData),	"D"	} ,
+	{ SMT_P1010,AC_G,	MOFFSS(fddiSMTManufacturerData), "D" } ,
+	{ SMT_P1011,AC_GR,	MOFFSS(fddiSMTUserData),	"D"	} ,
 	{ SMT_P1012,AC_G,	MOFFSS(fddiSMTMIBVersionId),	"S"	} ,
 
 	/* StationConfigGrp */
@@ -103,7 +96,7 @@ static const struct s_p_tab {
 	{ SMT_P101D,AC_GR,	MOFFSS(fddiSMTTT_Notify),	"wS"	} ,
 	{ SMT_P101E,AC_GR,	MOFFSS(fddiSMTStatRptPolicy),	"bB"	} ,
 	{ SMT_P101F,AC_GR,	MOFFSS(fddiSMTTrace_MaxExpiration),"lL"	} ,
-	{ SMT_P1020,AC_G,	MOFFSA(fddiSMTPORTIndexes),	"II"	} ,
+	{ SMT_P1020,AC_G,	MOFFSS(fddiSMTPORTIndexes),	"II"	} ,
 	{ SMT_P1021,AC_G,	MOFFSS(fddiSMTMACIndexes),	"I"	} ,
 	{ SMT_P1022,AC_G,	MOFFSS(fddiSMTBypassPresent),	"F"	} ,
 
@@ -117,8 +110,8 @@ static const struct s_p_tab {
 
 	/* MIBOperationGrp */
 	{ SMT_P1032,AC_GROUP	} ,
-	{ SMT_P1033,AC_G,	MOFFSA(fddiSMTTimeStamp),"P"		} ,
-	{ SMT_P1034,AC_G,	MOFFSA(fddiSMTTransitionTimeStamp),"P"	} ,
+	{ SMT_P1033,AC_G,	MOFFSS(fddiSMTTimeStamp),"P"		} ,
+	{ SMT_P1034,AC_G,	MOFFSS(fddiSMTTransitionTimeStamp),"P"	} ,
 	/* NOTE : SMT_P1035 is already swapped ! SMT_P_SETCOUNT */
 	{ SMT_P1035,AC_G,	MOFFSS(fddiSMTSetCount),"4P"		} ,
 	{ SMT_P1036,AC_G,	MOFFSS(fddiSMTLastSetStationId),"8"	} ,
@@ -129,7 +122,7 @@ static const struct s_p_tab {
 	 * PRIVATE EXTENSIONS
 	 * only accessible locally to get/set passwd
 	 */
-	{ SMT_P10F0,AC_GR,	MOFFSA(fddiPRPMFPasswd),	"8"	} ,
+	{ SMT_P10F0,AC_GR,	MOFFSS(fddiPRPMFPasswd),	"8"	} ,
 	{ SMT_P10F1,AC_GR,	MOFFSS(fddiPRPMFStation),	"8"	} ,
 #ifdef	ESS
 	{ SMT_P10F2,AC_GR,	MOFFSS(fddiESSPayload),		"lL"	} ,
@@ -245,7 +238,7 @@ static const struct s_p_tab {
 	{ SMT_P400E,AC_GR,	MOFFPS(fddiPORTConnectionPolicies),"bB"	} ,
 	{ SMT_P400F,AC_G,	MOFFPS(fddiPORTMacIndicated),	"2"	} ,
 	{ SMT_P4010,AC_G,	MOFFPS(fddiPORTCurrentPath),	"E"	} ,
-	{ SMT_P4011,AC_GR,	MOFFPA(fddiPORTRequestedPaths),	"l4"	} ,
+	{ SMT_P4011,AC_GR,	MOFFPS(fddiPORTRequestedPaths),	"l4"	} ,
 	{ SMT_P4012,AC_G,	MOFFPS(fddiPORTMACPlacement),	"S"	} ,
 	{ SMT_P4013,AC_G,	MOFFPS(fddiPORTAvailablePaths),	"B"	} ,
 	{ SMT_P4016,AC_G,	MOFFPS(fddiPORTPMDClass),	"E"	} ,
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 24768c1..53c2dda 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1961,7 +1961,8 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
 		if (dev->dma != (unsigned char)-1)
 			printk(" DMA %d", dev->dma);
 
-		printk("%s%s\n", nowait ? " [nowait]" : "",
+		printk("%s%s\n",
+			lp->cfg.flags & SMC91X_NOWAIT ? " [nowait]" : "",
 			THROTTLE_TX_PKTS ? " [throttle_tx]" : "");
 
 		if (!is_valid_ether_addr(dev->dev_addr)) {
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 997e7f1..edea073 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -446,6 +446,8 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
 #define SMC_CAN_USE_32BIT	1
 #define SMC_NOWAIT		1
 
+#define SMC_IO_SHIFT		(lp->io_shift)
+
 #define SMC_inb(a, r)		readb((a) + (r))
 #define SMC_inw(a, r)		readw((a) + (r))
 #define SMC_inl(a, r)		readl((a) + (r))
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 9281d06..f54c450 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1418,7 +1418,6 @@ static int de_close (struct net_device *dev)
 
 	de_free_rings(de);
 	de_adapter_sleep(de);
-	pci_disable_device(de->pdev);
 	return 0;
 }
 
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 6e42b5a..8b2b947 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2211,14 +2211,14 @@ static struct hso_device *hso_create_bulk_serial_device(
 				     USB_DIR_IN);
 	if (!serial->in_endp) {
 		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
-		goto exit;
+		goto exit2;
 	}
 
 	if (!
 	    (serial->out_endp =
 	     hso_get_ep(interface, USB_ENDPOINT_XFER_BULK, USB_DIR_OUT))) {
 		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
-		goto exit;
+		goto exit2;
 	}
 
 	serial->write_data = hso_std_serial_write_data;
@@ -2231,9 +2231,10 @@ static struct hso_device *hso_create_bulk_serial_device(
 
 	/* done, return it */
 	return hso_dev;
+
+exit2:
+	hso_serial_common_free(serial);
 exit:
-	if (hso_dev && serial)
-		hso_serial_common_free(serial);
 	kfree(serial);
 	hso_free_device(hso_dev);
 	return NULL;
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index 8b7e5d2..cbcbf6f 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -163,15 +163,17 @@ static void x25_close(struct net_device *dev)
 
 static int x25_rx(struct sk_buff *skb)
 {
+	struct net_device *dev = skb->dev;
+
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		skb->dev->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
-	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
+	if (lapb_data_received(dev, skb) == LAPB_OK)
 		return NET_RX_SUCCESS;
 
-	skb->dev->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
