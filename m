From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 8/10] hostap: Improved suspend
Date: Sat, 12 Mar 2005 16:34:48 -0800
Message-ID: <20050313003448.GI8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Improved suspend operation: disable firmware (hostap_cs) and
generate disconnect event to trigger wpa_supplicant to reassociate
immediately after resume.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c	2005-03-12 16:10:53.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_cs.c	2005-03-12 16:10:59.000000000 -0800
@@ -870,6 +870,7 @@
 				netif_stop_queue(dev);
 				netif_device_detach(dev);
 			}
+			prism2_suspend(dev);
 			pcmcia_release_configuration(link->handle);
 		}
 		break;
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_hw.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_hw.c	2005-03-12 16:10:58.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_hw.c	2005-03-12 16:10:59.000000000 -0800
@@ -3594,6 +3594,28 @@
 }
 
 
+#ifndef PRISM2_PLX
+static void prism2_suspend(struct net_device *dev)
+{
+	struct hostap_interface *iface;
+	struct local_info *local;
+	union iwreq_data wrqu;
+
+	iface = dev->priv;
+	local = iface->local;
+
+	/* Send disconnect event, e.g., to trigger reassociation after resume
+	 * if wpa_supplicant is used. */
+	memset(&wrqu, 0, sizeof(wrqu));
+	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+	wireless_send_event(local->dev, SIOCGIWAP, &wrqu, NULL);
+
+	/* Disable hardware and firmware */
+	prism2_hw_shutdown(dev, 0);
+}
+#endif /* PRISM2_PLX */
+
+
 /* These might at some point be compiled separately and used as separate
  * kernel modules or linked into one */
 #ifdef PRISM2_DOWNLOAD_SUPPORT
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_pci.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_pci.c	2005-03-12 16:10:50.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_pci.c	2005-03-12 16:10:59.000000000 -0800
@@ -393,7 +393,7 @@
 		netif_stop_queue(dev);
 		netif_device_detach(dev);
 	}
-	prism2_hw_shutdown(dev, 0);
+	prism2_suspend(dev);
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, 3);


-- 
Jouni Malinen                                            PGP id EFC895FA
