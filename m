From: Carlos Martin <carlos@cmartin.tk>
Subject: [PATCH 6/7] acxsm: Assign chip-specific ops in the probe functions
Date: Tue, 28 Feb 2006 17:30:14 +0100
Message-ID: <11411442141984-git-send-email-carlos@cmartin.tk>
References: <1141144213577-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@infradead.org>,
	Carlos Martin <carlos@kiopa. (none)>,
	Carlos Martin <carlos@cmartin.tk>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: <1141144213577-git-send-email-carlos@cmartin.tk>
To: netdev@vger.kernel.org
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

Assign the chip-specific ops in the probe functions. Add extern and
dummy functions where needed.

Signed-off-by: Carlos Martin <carlos@cmartin.tk>

---

 acx_func.h |    1 +
 pci.c      |   24 ++++++++++++++++++++++++
 usb.c      |   19 +++++++++++++++++++
 3 files changed, 44 insertions(+), 0 deletions(-)

1a6bb060d33906c12c6ef161b851cc1fab91d3a9
diff --git a/acx_func.h b/acx_func.h
index 0823aec..238c633 100644
--- a/acx_func.h
+++ b/acx_func.h
@@ -534,6 +534,7 @@ acx_l_alloc_tx(acx_device_t *adev)
 }
=20
 void acxusb_l_dealloc_tx(tx_t *tx_opaque);
+void acxpci_l_dealloc_tx(tx_t *tx_opaque);
 static inline void
 acx_l_dealloc_tx(acx_device_t *adev, tx_t *tx_opaque)
 {
diff --git a/pci.c b/pci.c
index 24224b9..23abb96 100644
--- a/pci.c
+++ b/pci.c
@@ -105,6 +105,9 @@ static int acxpci_e_close(struct net_dev
 static void acxpci_s_up(struct net_device *ndev);
 static void acxpci_s_down(struct net_device *ndev);
=20
+extern int acx100_s_create_dma_regions(acx_device_t *);
+extern int acx111_s_create_dma_regions(acx_device_t *);
+
 #ifdef MODULE_LICENSE
 MODULE_LICENSE("Dual MPL/GPL");
 #endif
@@ -1599,6 +1602,22 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	adev->ieee->sec.enabled =3D 0;
 	adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
=20
+#if ACX_DEBUG
+       adev->ops.issue_cmd =3D acxpci_s_issue_cmd_timeo_debug;
+#else
+       adev->ops.issue_cmd  =3D acxpci_s_issue_cmd_timeo;
+#endif /* ACX_DEBUG */
+       adev->ops.alloc_tx =3D acxpci_l_alloc_tx;
+       adev->ops.dealloc_tx =3D acxpci_l_dealloc_tx;
+       adev->ops.delete_dma_regions =3D acxpci_s_delete_dma_regions;
+       adev->ops.write_phy_reg =3D acxpci_s_write_phy_reg;
+       adev->ops.read_phy_reg =3D acxpci_s_read_phy_reg;
+
+       if (IS_ACX100(adev)) {
+	       adev->ops.create_dma_regions =3D acx100_s_create_dma_regions;
+       } else {
+	       adev->ops.create_dma_regions =3D acx111_s_create_dma_regions;
+       }
 #ifdef NONESSENTIAL_FEATURES
 	acx_show_card_eeprom_id(adev);
 #endif /* NONESSENTIAL_FEATURES */
@@ -3058,6 +3077,11 @@ end:
 	return (tx_t*)txdesc;
 }
=20
+/* Dummy function. */
+static void
+acxpci_l_dealloc_tx(tx_t *tx_opaque)
+{
+}
=20
 /***********************************************************************
 */
diff --git a/usb.c b/usb.c
index 6b0b578..5833d04 100644
--- a/usb.c
+++ b/usb.c
@@ -123,6 +123,8 @@ static void acxusb_l_poll_rx(acx_device_
=20
 static void acxusb_i_tx_timeout(struct net_device *);
=20
+extern int acx100_s_create_dma_regions(acx_device_t *);
+
 /* static void dump_device(struct usb_device *); */
 /* static void dump_device_descriptor(struct usb_device_descriptor *); *=
/
 /* static void dump_config_descriptor(struct usb_config_descriptor *); *=
/
@@ -763,6 +765,11 @@ acxusb_s_fill_configoption(acx_device_t=20
 	return OK;
 }
=20
+/* Dummy function. */
+static void
+acxusb_s_delete_dma_regions(acx_device_t *adev)
+{
+}
=20
 /***********************************************************************
 ** acxusb_e_probe()
@@ -891,6 +898,18 @@ acxusb_e_probe(struct usb_interface *int
 	adev->ieee->sec.encrypt =3D 0;
 	adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
=20
+#if ACX_DEBUG
+	adev->ops.issue_cmd =3D acxusb_s_issue_cmd_timeo_debug;
+#else
+       adev->ops.issue_cmd  =3D acxusb_s_issue_cmd_timeo;
+#endif /* ACX_DEBUG */
+       adev->ops.alloc_tx =3D acxusb_l_alloc_tx;
+       adev->ops.dealloc_tx =3D acxusb_l_dealloc_tx;
+       adev->ops.delete_dma_regions =3D acxusb_s_delete_dma_regions;
+       adev->ops.write_phy_reg =3D acxusb_s_write_phy_reg;
+       adev->ops.read_phy_reg =3D acxusb_s_read_phy_reg;
+       adev->ops.create_dma_regions =3D acx100_s_create_dma_regions;
+
 	/* Check that this is really the hardware we know about.
 	** If not sure, at least notify the user that he
 	** may be in trouble...
--=20
1.2.1.g62a4




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
