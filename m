From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] lmc: copy_*_user under spinlock
Date: Wed, 15 Oct 2008 11:50:42 +0100
Message-ID: <20081015105025.6526.68580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:60295 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751438AbYJOKu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 06:50:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@redhat.com>

Not sure anyone uses this driver any more, maybe we should just drop it ?
Code is still foul but at least a fraction less broken.

Signed-off-by: Alan Cox <alan@redhat.com>
---

 drivers/net/wan/lmc/lmc_main.c |   31 ++++++++++++++++++++++++-------
 1 files changed, 24 insertions(+), 7 deletions(-)


diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index f80640f..d7bb63e 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -122,7 +122,6 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
      * Most functions mess with the structure
      * Disable interrupts while we do the polling
      */
-    spin_lock_irqsave(&sc->lmc_lock, flags);
 
     switch (cmd) {
         /*
@@ -152,6 +151,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		break;
 	}
 
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         sc->lmc_media->set_status (sc, &ctl);
 
         if(ctl.crc_length != sc->ictl.crc_length) {
@@ -161,6 +161,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 	    else
 		sc->TxDescriptControlInit &= ~LMC_TDES_ADD_CRC_DISABLE;
         }
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
         ret = 0;
         break;
@@ -187,15 +188,18 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		break;				/* no change */
             }
             
+	    spin_lock_irqsave(&sc->lmc_lock, flags);
             lmc_proto_close(sc);
 
             sc->if_type = new_type;
             lmc_proto_attach(sc);
 	    ret = lmc_proto_open(sc);
+	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 	    break;
 	}
 
     case LMCIOCGETXINFO: /*fold01*/
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         sc->lmc_xinfo.Magic0 = 0xBEEFCAFE;
 
         sc->lmc_xinfo.PciCardType = sc->lmc_cardtype;
@@ -208,6 +212,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         sc->lmc_xinfo.MaxFrameSize = LMC_PKT_BUF_SZ;
         sc->lmc_xinfo.link_status = sc->lmc_media->get_link_status (sc);
         sc->lmc_xinfo.mii_reg16 = lmc_mii_readreg (sc, 0, 16);
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
         sc->lmc_xinfo.Magic1 = 0xDEADBEEF;
 
@@ -220,6 +225,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         break;
 
     case LMCIOCGETLMCSTATS:
+	    spin_lock_irqsave(&sc->lmc_lock, flags);
 	    if (sc->lmc_cardtype == LMC_CARDTYPE_T1) {
 		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
 		    sc->extra_stats.framingBitErrorCount +=
@@ -243,6 +249,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		    sc->extra_stats.severelyErroredFrameCount +=
 			    regVal & T1FRAMER_SEF_MASK;
 	    }
+	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 	    if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
 			     sizeof(sc->lmc_device->stats)) ||
 		copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
@@ -258,12 +265,14 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		    break;
 	    }
 
+	    spin_lock_irqsave(&sc->lmc_lock, flags);
 	    memset(&sc->lmc_device->stats, 0, sizeof(sc->lmc_device->stats));
 	    memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
 	    sc->extra_stats.check = STATCHECK;
 	    sc->extra_stats.version_size = (DRIVER_VERSION << 16) +
 		    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
 	    sc->extra_stats.lmc_cardtype = sc->lmc_cardtype;
+	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 	    ret = 0;
 	    break;
 
@@ -282,8 +291,10 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		ret = -EFAULT;
 		break;
 	}
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
         sc->ictl.circuit_type = ctl.circuit_type;
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
         ret = 0;
 
         break;
@@ -294,12 +305,14 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
             break;
         }
 
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         /* Reset driver and bring back to current state */
         printk (" REG16 before reset +%04x\n", lmc_mii_readreg (sc, 0, 16));
         lmc_running_reset (dev);
         printk (" REG16 after reset +%04x\n", lmc_mii_readreg (sc, 0, 16));
 
         LMC_EVENT_LOG(LMC_EVENT_FORCEDRESET, LMC_CSR_READ (sc, csr_status), lmc_mii_readreg (sc, 0, 16));
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
         ret = 0;
         break;
@@ -338,14 +351,15 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
              */
             netif_stop_queue(dev);
 
-	if (copy_from_user(&xc, ifr->ifr_data, sizeof(struct lmc_xilinx_control))) {
+	    if (copy_from_user(&xc, ifr->ifr_data, sizeof(struct lmc_xilinx_control))) {
 		ret = -EFAULT;
 		break;
-	}
+	    }
             switch(xc.command){
             case lmc_xilinx_reset: /*fold02*/
                 {
                     u16 mii;
+		    spin_lock_irqsave(&sc->lmc_lock, flags);
                     mii = lmc_mii_readreg (sc, 0, 16);
 
                     /*
@@ -404,6 +418,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                             lmc_led_off(sc, LMC_DS3_LED2);
                         }
                     }
+		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
                     
                     
 
@@ -416,6 +431,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                 {
                     u16 mii;
                     int timeout = 500000;
+		    spin_lock_irqsave(&sc->lmc_lock, flags);
                     mii = lmc_mii_readreg (sc, 0, 16);
 
                     /*
@@ -451,13 +467,14 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                      */
                     while( (LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) == 0 &&
                            (timeout-- > 0))
-                        ;
+                        cpu_relax();
 
 
                     /*
                      * stop driving Xilinx-related signals
                      */
                     lmc_gpio_mkinput(sc, 0xff);
+		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
                     ret = 0x0;
                     
@@ -493,6 +510,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
                     printk("%s: Starting load of data Len: %d at 0x%p == 0x%p\n", dev->name, xc.len, xc.data, data);
 
+		    spin_lock_irqsave(&sc->lmc_lock, flags);
                     lmc_gpio_mkinput(sc, 0xff);
 
                     /*
@@ -545,7 +563,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                      */
                     while( (LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) == 0 &&
                            (timeout-- > 0))
-                        ;
+                        cpu_relax();
 
                     printk(KERN_DEBUG "%s: Waited %d for the Xilinx to clear it's memory\n", dev->name, 500000-timeout);
 
@@ -588,6 +606,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
                     sc->lmc_miireg16 &= ~LMC_MII16_FIFO_RESET;
                     lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
                     kfree(data);
                     
@@ -611,8 +630,6 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         break;
     }
 
-    spin_unlock_irqrestore(&sc->lmc_lock, flags); /*fold01*/
-
     lmc_trace(dev, "lmc_ioctl out");
 
     return ret;

