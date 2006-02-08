From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] get rid of circular list of adev's
Date: Wed, 8 Feb 2006 14:23:26 +0200
Message-ID: <200602081423.26245.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_+Ke6D1hxcQf5DwQ"
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--Boundary-00=_+Ke6D1hxcQf5DwQ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi folks,

If someone has cardbus acx, please test this one.

Basically, in acxpci_e_remove() we will check the presence
of the card by reading a register and if it is not all ones,
we will command device to shut down.

Previously it was done in acxpci_e_cleanup_module().

+INLINE_IO int
+adev_present(acx_device_t *adev)
+{
+       /* fast version (accesses the first register, IO_ACX_SOFT_RESET,
+        * which should be safe): */
+       return readl(adev->iobase) != 0xffffffff;
+}


@@ -1785,6 +1725,43 @@ acxpci_e_remove(struct pci_dev *pdev)

        adev = ndev2adev(ndev);

+       /* If device wasn't hot unplugged... */
+       if (adev_present(adev)) {
+
+               acx_sem_lock(adev);
+
+               /* disable both Tx and Rx to shut radio down properly */
+               acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_TX, NULL, 0);
+               acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_RX, NULL, 0);
...

--
vda

--Boundary-00=_+Ke6D1hxcQf5DwQ
Content-Type: text/x-diff;
  charset="us-ascii";
  name="1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="1.patch"

diff -urpN current.0/acx_struct.h current.1/acx_struct.h
--- current.0/acx_struct.h	Sat Feb  4 13:11:55 2006
+++ current.1/acx_struct.h	Wed Feb  8 12:48:33 2006
@@ -1220,14 +1220,9 @@ struct acx_device {
 	unsigned long		lock_time;
 #endif
 
-	/*** Device chain ***/
-	struct acx_device	*next;		/* link for list of devices */
-
 	/*** Linux network device ***/
 	struct net_device	*ndev;		/* pointer to linux netdevice */
-	struct net_device	*prev_nd;	/* FIXME: We should not chain via our
-						 * private struct acx_device _and_
-						 * the struct net_device */
+
 	/*** Device statistics ***/
 	struct net_device_stats	stats;		/* net device statistics */
 #ifdef WIRELESS_EXT
diff -urpN current.0/pci.c current.1/pci.c
--- current.0/pci.c	Sat Feb  4 14:49:33 2006
+++ current.1/pci.c	Wed Feb  8 13:34:42 2006
@@ -174,11 +174,13 @@ write_flush(acx_device_t *adev)
 	readb(adev->iobase);
 }
 
-
-/***********************************************************************
-*/
-static struct net_device *root_adev_newest = NULL;
-DECLARE_MUTEX(root_adev_sem);
+INLINE_IO int
+adev_present(acx_device_t *adev)
+{
+	/* fast version (accesses the first register, IO_ACX_SOFT_RESET,
+	 * which should be safe): */
+	return readl(adev->iobase) != 0xffffffff;
+}
 
 
 /***********************************************************************
@@ -1273,62 +1275,6 @@ acx_show_card_eeprom_id(acx_device_t *ad
 
 
 /***********************************************************************
-*/
-static void
-acxpci_s_device_chain_add(struct net_device *ndev)
-{
-	acx_device_t *adev = ndev2adev(ndev);
-
-	down(&root_adev_sem);
-	adev->prev_nd = root_adev_newest;
-	root_adev_newest = ndev;
-	adev->ndev = ndev;
-	up(&root_adev_sem);
-}
-
-static void
-acxpci_s_device_chain_remove(struct net_device *ndev)
-{
-	struct net_device *querydev;
-	struct net_device *olderdev;
-	struct net_device *newerdev;
-
-	down(&root_adev_sem);
-	querydev = root_adev_newest;
-	newerdev = NULL;
-	while (querydev) {
-		olderdev = ndev2adev(querydev)->prev_nd;
-		if (0 == strcmp(querydev->name, ndev->name)) {
-			if (!newerdev) {
-				/* if we were at the beginning of the
-				 * list, then it's the list head that
-				 * we need to update to point at the
-				 * next older device */
-				root_adev_newest = olderdev;
-			} else {
-				/* it's the device that is newer than us
-				 * that we need to update to point at
-				 * the device older than us */
-				ndev2adev(newerdev)->prev_nd = olderdev;
-			}
-			break;
-		}
-		/* "newerdev" is actually the device of the old iteration,
-		 * but since the list starts (root_adev_newest)
-		 * with the newest devices,
-		 * it's newer than the ones following.
-		 * Oh the joys of iterating from newest to oldest :-\ */
-		newerdev = querydev;
-
-		/* keep checking old devices for matches until we hit the end
-		 * of the list */
-		querydev = olderdev;
-	}
-	up(&root_adev_sem);
-}
-
-
-/***********************************************************************
 ** acxpci_free_desc_queues
 **
 ** Releases the queues that have been allocated, the
@@ -1643,9 +1589,6 @@ acxpci_e_probe(struct pci_dev *pdev, con
 #endif
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	/* register new dev in linked list */
-	acxpci_s_device_chain_add(ndev);
-
 	log(L_IRQ|L_INIT, "using IRQ %d\n", pdev->irq);
 
 	/* need to be able to restore PCI state after a suspend */
@@ -1725,7 +1668,6 @@ fail_init_mac:
 fail_read_eeprom_version:
 fail_reset:
 
-	acxpci_s_device_chain_remove(ndev);
 	free_netdev(ndev);
 fail_alloc_netdev:
 fail_irq:
@@ -1759,11 +1701,8 @@ done:
 /***********************************************************************
 ** acxpci_e_remove
 **
-** Deallocate PCI resources for the acx chip.
-**
-** This should NOT execute any other hardware operations on the card,
-** since the card might already be ejected. Instead, that should be done
-** in cleanup_module, since the card is most likely still available there.
+** Shut device down (if not hot unplugged)
+** and deallocate PCI resources for the acx chip.
 **
 ** pdev - ptr to PCI device structure containing info about pci configuration
 */
@@ -1773,6 +1712,7 @@ acxpci_e_remove(struct pci_dev *pdev)
 	struct net_device *ndev;
 	acx_device_t *adev;
 	unsigned long mem_region1, mem_region2;
+	unsigned long flags;
 
 	FN_ENTER;
 
@@ -1785,6 +1725,43 @@ acxpci_e_remove(struct pci_dev *pdev)
 
 	adev = ndev2adev(ndev);
 
+	/* If device wasn't hot unplugged... */
+	if (adev_present(adev)) {
+
+		acx_sem_lock(adev);
+
+		/* disable both Tx and Rx to shut radio down properly */
+		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_TX, NULL, 0);
+		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_RX, NULL, 0);
+
+#ifdef REDUNDANT
+		/* put the eCPU to sleep to save power
+		 * Halting is not possible currently,
+		 * since not supported by all firmware versions */
+		acx_s_issue_cmd(adev, ACX100_CMD_SLEEP, NULL, 0);
+#endif
+		acx_lock(adev, flags);
+		/* disable power LED to save power :-) */
+		log(L_INIT, "switching off power LED to save power\n");
+		acxpci_l_power_led(adev, 0);
+		/* stop our eCPU */
+		if (IS_ACX111(adev)) {
+			/* FIXME: does this actually keep halting the eCPU?
+			 * I don't think so...
+			 */
+			acxpci_l_reset_mac(adev);
+		} else {
+			u16 temp;
+			/* halt eCPU */
+			temp = read_reg16(adev, IO_ACX_ECPU_CTRL) | 0x1;
+			write_reg16(adev, IO_ACX_ECPU_CTRL, temp);
+			write_flush(adev);
+		}
+		acx_unlock(adev, flags);
+
+		acx_sem_unlock(adev);
+	}
+
 	/* unregister the device to not let the kernel
 	 * (e.g. ioctls) access a half-deconfigured device
 	 * NB: this will cause acxpci_e_close() to be called,
@@ -1796,6 +1773,13 @@ acxpci_e_remove(struct pci_dev *pdev)
 	 * For paranoid reasons we continue to follow the rules */
 	acx_sem_lock(adev);
 
+	if (adev->dev_state_mask & ACX_STATE_IFACE_UP) {
+		acxpci_s_down(ndev);
+		CLEAR_BIT(adev->dev_state_mask, ACX_STATE_IFACE_UP);
+	}
+
+	acx_proc_unregister_entries(ndev);
+
 	if (IS_ACX100(adev)) {
 		mem_region1 = PCI_ACX100_REGION1;
 		mem_region2 = PCI_ACX100_REGION2;
@@ -1804,33 +1788,21 @@ acxpci_e_remove(struct pci_dev *pdev)
 		mem_region2 = PCI_ACX111_REGION2;
 	}
 
-	acx_proc_unregister_entries(ndev);
-
-	/* find our PCI device in the global acx list and remove it */
-	acxpci_s_device_chain_remove(ndev);
-
-	if (adev->dev_state_mask & ACX_STATE_IFACE_UP)
-		acxpci_s_down(ndev);
-
-	CLEAR_BIT(adev->dev_state_mask, ACX_STATE_IFACE_UP);
-
-	acxpci_s_delete_dma_regions(adev);
-
 	/* finally, clean up PCI bus state */
+	acxpci_s_delete_dma_regions(adev);
 	if (adev->iobase) iounmap(adev->iobase);
 	if (adev->iobase2) iounmap(adev->iobase2);
-
 	release_mem_region(pci_resource_start(pdev, mem_region1),
 			   pci_resource_len(pdev, mem_region1));
-
 	release_mem_region(pci_resource_start(pdev, mem_region2),
 			   pci_resource_len(pdev, mem_region2));
-
 	pci_disable_device(pdev);
 
 	/* remove dev registration */
 	pci_set_drvdata(pdev, NULL);
 
+	acx_sem_unlock(adev);
+
 	/* Free netdev (quite late,
 	 * since otherwise we might get caught off-guard
 	 * by a netdev timeout handler execution
@@ -2002,10 +1974,10 @@ acxpci_s_up(struct net_device *ndev)
 /***********************************************************************
 ** acxpci_s_down
 **
-** This disables the netdevice
+** NB: device may be already hot unplugged if called from acxpci_e_remove()
 **
-** Side effects:
-** - disables on-card interrupt request
+** Disables on-card interrupt request, stops softirq and timer, stops queue,
+** sets status == STOPPED
 */
 
 static void
@@ -4207,69 +4179,8 @@ acxpci_e_init_module(void)
 void __exit
 acxpci_e_cleanup_module(void)
 {
-	struct net_device *ndev;
-	unsigned long flags;
-
 	FN_ENTER;
 
-	/* Since the whole module is about to be unloaded,
-	 * we recursively shutdown all cards we handled instead
-	 * of doing it in acxpci_e_remove() (which will be activated by us
-	 * via pci_unregister_driver at the end).
-	 * acxpci_e_remove() might just get called after a card eject,
-	 * that's why hardware operations have to be done here instead
-	 * when the hardware is available. */
-
-	down(&root_adev_sem);
-
-	ndev = root_adev_newest;
-	while (ndev) {
-		acx_device_t *adev = ndev2adev(ndev);
-
-		acx_sem_lock(adev);
-
-		/* disable both Tx and Rx to shut radio down properly */
-		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_TX, NULL, 0);
-		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_RX, NULL, 0);
-
-#ifdef REDUNDANT
-		/* put the eCPU to sleep to save power
-		 * Halting is not possible currently,
-		 * since not supported by all firmware versions */
-		acx_s_issue_cmd(adev, ACX100_CMD_SLEEP, NULL, 0);
-#endif
-		acx_lock(adev, flags);
-
-		/* disable power LED to save power :-) */
-		log(L_INIT, "switching off power LED to save power\n");
-		acxpci_l_power_led(adev, 0);
-
-		/* stop our eCPU */
-		if (IS_ACX111(adev)) {
-			/* FIXME: does this actually keep halting the eCPU?
-			 * I don't think so...
-			 */
-			acxpci_l_reset_mac(adev);
-		} else {
-			u16 temp;
-
-			/* halt eCPU */
-			temp = read_reg16(adev, IO_ACX_ECPU_CTRL) | 0x1;
-			write_reg16(adev, IO_ACX_ECPU_CTRL, temp);
-			write_flush(adev);
-		}
-
-		acx_unlock(adev, flags);
-
-		acx_sem_unlock(adev);
-
-		ndev = adev->prev_nd;
-	}
-
-	up(&root_adev_sem);
-
-	/* now let the PCI layer recursively remove
-	 * all PCI related things (acxpci_e_remove()) */
 	pci_unregister_driver(&acxpci_drv_id);
 
 	FN_EXIT0;

--Boundary-00=_+Ke6D1hxcQf5DwQ--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
