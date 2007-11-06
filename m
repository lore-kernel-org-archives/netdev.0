From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Tue, 6 Nov 2007 15:07:00 -0500
Message-ID: <20071106200700.GF4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2207 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625AbXKFUH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 15:07:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Here are a few fixes for 2.6.24.  The iwlwifi "is_power_of_2" patch is
a little questionable as a fix.  But it does bring the buildtime check
in iwl_tx_queue_init in-line with the runtime check in iwl_queue_init,
and it is 2x a one-liner -- so I think it is worthwhile.

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub//linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit 2655e2cee2d77459fcb7e10228259e4ee0328697:
  Alan Cox (1):
        ata_piix: Add additional PCI identifier for 40 wire short cable

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Holger Schurig (1):
      libertas: fixes for slow hardware

Ivo van Doorn (1):
      rt2x00: Block adhoc & master mode

John W. Linville (1):
      hermes: clarify Intel reference in Kconfig help

Marcelo Tosatti (1):
      libertas: properly account for queue commands

Michael Buesch (1):
      b43: pcmcia-host initialization bugfixes

Pierre Ossman (1):
      libertas: make if_sdio align packets

Randy Dunlap (1):
      hostap: fix section mismatch warning

Robert P. J. Day (1):
      iwlwifi: Use more obvious "is_power_of_2" macro.

Roel Kluin (1):
      ipw2100: fix postfix decrement errors

 drivers/net/wireless/Kconfig                |    2 +-
 drivers/net/wireless/b43/pcmcia.c           |   44 +++++++++++++++-----------
 drivers/net/wireless/hostap/hostap_pci.c    |    6 ++--
 drivers/net/wireless/ipw2100.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    3 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    3 +-
 drivers/net/wireless/libertas/cmd.c         |   10 ++++--
 drivers/net/wireless/libertas/if_cs.c       |    7 +++-
 drivers/net/wireless/libertas/if_sdio.c     |    4 ++-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |    8 +++++
 10 files changed, 58 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index dae5c8d..2b733c5 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -325,7 +325,7 @@ config HERMES
 	  Cabletron/EnteraSys Roamabout, ELSA AirLancer, MELCO Buffalo, Avaya,
 	  IBM High Rate Wireless, Farralon Syyline, Samsung MagicLAN, Netgear
 	  MA401, LinkSys WPC-11, D-Link DWL-650, 3Com AirConnect, Intel
-	  PRO/Wireless, and Symbol Spectrum24 High Rate amongst others.
+	  IPW2011, and Symbol Spectrum24 High Rate amongst others.
 
 	  This option includes the guts of the driver, but in order to
 	  actually use a card you will also need to enable support for PCMCIA
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index b242a9a..4b6648f 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -65,12 +65,12 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	tuple_t tuple;
 	cisparse_t parse;
 	int err = -ENOMEM;
-	int res;
+	int res = 0;
 	unsigned char buf[64];
 
 	ssb = kzalloc(sizeof(*ssb), GFP_KERNEL);
 	if (!ssb)
-		goto out;
+		goto out_error;
 
 	err = -ENODEV;
 	tuple.DesiredTuple = CISTPL_CONFIG;
@@ -96,10 +96,12 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->io.NumPorts2 = 0;
 	dev->io.Attributes2 = 0;
 
-	win.Attributes = WIN_MEMORY_TYPE_CM | WIN_ENABLE | WIN_USE_WAIT;
+	win.Attributes = WIN_ADDR_SPACE_MEM | WIN_MEMORY_TYPE_CM |
+			 WIN_ENABLE | WIN_DATA_WIDTH_16 |
+			 WIN_USE_WAIT;
 	win.Base = 0;
 	win.Size = SSB_CORE_SIZE;
-	win.AccessSpeed = 1000;
+	win.AccessSpeed = 250;
 	res = pcmcia_request_window(&dev, &win, &dev->win);
 	if (res != CS_SUCCESS)
 		goto err_kfree_ssb;
@@ -108,21 +110,26 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	mem.Page = 0;
 	res = pcmcia_map_mem_page(dev->win, &mem);
 	if (res != CS_SUCCESS)
-		goto err_kfree_ssb;
+		goto err_disable;
 
 	res = pcmcia_request_configuration(dev, &dev->conf);
 	if (res != CS_SUCCESS)
 		goto err_disable;
 
 	err = ssb_bus_pcmciabus_register(ssb, dev, win.Base);
+	if (err)
+		goto err_disable;
 	dev->priv = ssb;
 
-      out:
-	return err;
-      err_disable:
+	return 0;
+
+err_disable:
 	pcmcia_disable_device(dev);
-      err_kfree_ssb:
+err_kfree_ssb:
 	kfree(ssb);
+out_error:
+	printk(KERN_ERR "b43-pcmcia: Initialization failed (%d, %d)\n",
+	       res, err);
 	return err;
 }
 
@@ -131,22 +138,21 @@ static void __devexit b43_pcmcia_remove(struct pcmcia_device *dev)
 	struct ssb_bus *ssb = dev->priv;
 
 	ssb_bus_unregister(ssb);
-	pcmcia_release_window(dev->win);
 	pcmcia_disable_device(dev);
 	kfree(ssb);
 	dev->priv = NULL;
 }
 
 static struct pcmcia_driver b43_pcmcia_driver = {
-	.owner = THIS_MODULE,
-	.drv = {
-		.name = "b43-pcmcia",
-		},
-	.id_table = b43_pcmcia_tbl,
-	.probe = b43_pcmcia_probe,
-	.remove = b43_pcmcia_remove,
-	.suspend = b43_pcmcia_suspend,
-	.resume = b43_pcmcia_resume,
+	.owner		= THIS_MODULE,
+	.drv		= {
+				.name = "b43-pcmcia",
+			},
+	.id_table	= b43_pcmcia_tbl,
+	.probe		= b43_pcmcia_probe,
+	.remove		= __devexit_p(b43_pcmcia_remove),
+	.suspend	= b43_pcmcia_suspend,
+	.resume		= b43_pcmcia_resume,
 };
 
 int b43_pcmcia_init(void)
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 7da3664..fc876ba 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -444,7 +444,7 @@ static int prism2_pci_resume(struct pci_dev *pdev)
 
 MODULE_DEVICE_TABLE(pci, prism2_pci_id_table);
 
-static struct pci_driver prism2_pci_drv_id = {
+static struct pci_driver prism2_pci_driver = {
 	.name		= "hostap_pci",
 	.id_table	= prism2_pci_id_table,
 	.probe		= prism2_pci_probe,
@@ -458,13 +458,13 @@ static struct pci_driver prism2_pci_drv_id = {
 
 static int __init init_prism2_pci(void)
 {
-	return pci_register_driver(&prism2_pci_drv_id);
+	return pci_register_driver(&prism2_pci_driver);
 }
 
 
 static void __exit exit_prism2_pci(void)
 {
-	pci_unregister_driver(&prism2_pci_drv_id);
+	pci_unregister_driver(&prism2_pci_driver);
 }
 
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 8d53d08..fc6cdd8 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1267,7 +1267,7 @@ static int ipw2100_start_adapter(struct ipw2100_priv *priv)
 				       IPW2100_INTA_FATAL_ERROR |
 				       IPW2100_INTA_PARITY_ERROR);
 		}
-	} while (i--);
+	} while (--i);
 
 	/* Clear out any pending INTAs since we aren't supposed to have
 	 * interrupts enabled at this point... */
@@ -1339,7 +1339,7 @@ static int ipw2100_power_cycle_adapter(struct ipw2100_priv *priv)
 
 		if (reg & IPW_AUX_HOST_RESET_REG_MASTER_DISABLED)
 			break;
-	} while (i--);
+	} while (--i);
 
 	priv->status &= ~STATUS_RESET_PENDING;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4f22a71..53b4b4e 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -50,6 +50,7 @@
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
+#include <linux/log2.h>
 
 #include <net/ieee80211_radiotap.h>
 #include <net/mac80211.h>
@@ -343,7 +344,7 @@ int iwl_tx_queue_init(struct iwl_priv *priv,
 
 	/* TFD_QUEUE_SIZE_MAX must be power-of-two size, otherwise
 	 * iwl_queue_inc_wrap and iwl_queue_dec_wrap are broken. */
-	BUILD_BUG_ON(TFD_QUEUE_SIZE_MAX & (TFD_QUEUE_SIZE_MAX - 1));
+	BUILD_BUG_ON(!is_power_of_2(TFD_QUEUE_SIZE_MAX));
 	iwl_queue_init(priv, &txq->q, TFD_QUEUE_SIZE_MAX, slots_num, txq_id);
 
 	iwl_hw_tx_queue_init(priv, txq);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index d60adcb..5f3bcb3 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -50,6 +50,7 @@
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
+#include <linux/log2.h>
 
 #include <net/ieee80211_radiotap.h>
 #include <net/mac80211.h>
@@ -342,7 +343,7 @@ int iwl_tx_queue_init(struct iwl_priv *priv,
 
 	/* TFD_QUEUE_SIZE_MAX must be power-of-two size, otherwise
 	 * iwl_queue_inc_wrap and iwl_queue_dec_wrap are broken. */
-	BUILD_BUG_ON(TFD_QUEUE_SIZE_MAX & (TFD_QUEUE_SIZE_MAX - 1));
+	BUILD_BUG_ON(!is_power_of_2(TFD_QUEUE_SIZE_MAX));
 	iwl_queue_init(priv, &txq->q, TFD_QUEUE_SIZE_MAX, slots_num, txq_id);
 
 	iwl_hw_tx_queue_init(priv, txq);
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 1cbbd96..be5cfd8 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -912,6 +912,10 @@ static int wlan_cmd_set_boot2_ver(wlan_private * priv,
 	return 0;
 }
 
+/*
+ * Note: NEVER use libertas_queue_cmd() with addtail==0 other than for
+ * the command timer, because it does not account for queued commands.
+ */
 void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u8 addtail)
 {
 	unsigned long flags;
@@ -941,10 +945,11 @@ void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u
 
 	spin_lock_irqsave(&adapter->driver_lock, flags);
 
-	if (addtail)
+	if (addtail) {
 		list_add_tail((struct list_head *)cmdnode,
 			      &adapter->cmdpendingq);
-	else
+		adapter->nr_cmd_pending++;
+	} else
 		list_add((struct list_head *)cmdnode, &adapter->cmdpendingq);
 
 	spin_unlock_irqrestore(&adapter->driver_lock, flags);
@@ -1412,7 +1417,6 @@ int libertas_prepare_and_send_command(wlan_private * priv,
 	cmdnode->cmdwaitqwoken = 0;
 
 	libertas_queue_cmd(adapter, cmdnode, 1);
-	adapter->nr_cmd_pending++;
 	wake_up_interruptible(&priv->waitq);
 
 	if (wait_option & CMD_OPTION_WAITFORRSP) {
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 0360cad..ec89dab 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -148,11 +148,11 @@ static int if_cs_poll_while_fw_download(struct if_cs_card *card, uint addr, u8 r
 {
 	int i;
 
-	for (i = 0; i < 500; i++) {
+	for (i = 0; i < 1000; i++) {
 		u8 val = if_cs_read8(card, addr);
 		if (val == reg)
 			return i;
-		udelay(100);
+		udelay(500);
 	}
 	return -ETIME;
 }
@@ -878,6 +878,9 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 		goto out3;
 	}
 
+	/* Clear any interrupt cause that happend while sending
+	 * firmware/initializing card */
+	if_cs_write16(card, IF_CS_C_INT_CAUSE, IF_CS_C_IC_MASK);
 	if_cs_enable_ints(card);
 
 	/* And finally bring the card up */
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index a8e1707..b24425f 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -182,12 +182,14 @@ static int if_sdio_handle_data(struct if_sdio_card *card,
 		goto out;
 	}
 
-	skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
+	skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		ret = -ENOMEM;
 		goto out;
 	}
 
+	skb_reserve(skb, NET_IP_ALIGN);
+
 	data = skb_put(skb, size);
 
 	memcpy(data, buffer, size);
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index 4a6a0bd..85ea8a8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -196,6 +196,14 @@ int rt2x00mac_add_interface(struct ieee80211_hw *hw,
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct interface *intf = &rt2x00dev->interface;
 
+	/* FIXME: Beaconing is broken in rt2x00. */
+	if (conf->type == IEEE80211_IF_TYPE_IBSS ||
+	    conf->type == IEEE80211_IF_TYPE_AP) {
+		ERROR(rt2x00dev,
+		      "rt2x00 does not support Adhoc or Master mode");
+		return -EOPNOTSUPP;
+	}
+
 	/*
 	 * Don't allow interfaces to be added while
 	 * either the device has disappeared or when
-- 
John W. Linville
linville@tuxdriver.com
