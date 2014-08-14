From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-08-14
Date: Thu, 14 Aug 2014 14:32:53 -0400
Message-ID: <20140814183253.GF4953@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qcHopEYAB45HaUaB"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53551 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbaHNSpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 14:45:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.17 stream...

Arend van Spriel brings two brcmfmac fixes, one which fixes a memory
leak and one which corrects some merge damage.

Emmanuel Grumbach fixes Linus's iwlwifi firmware-related log spam.

Rickard Strandqvist does some proper NULL termination after a call
to strncpy.

Ronald Wahl corrects a carl9170 problem with sending URBs with the
wrong endpoint type (resulting in log spam).

Please let me know if there are problems!

---

The following changes since commit 33caee39925b887a99a2400dc5c980097c3573f9:

  Merge branch 'akpm' (patchbomb from Andrew Morton) (2014-08-06 21:14:42 -=
0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-08-14

for you to fetch changes up to 77b2f2865956b7573f9b040db7a9f808b434acd1:

  iwlwifi: mvm: disable scheduled scan to prevent firmware crash (2014-08-1=
4 19:47:41 +0300)

----------------------------------------------------------------
Arend van Spriel (2):
      brcmfmac: fix curly brace mistake in brcmf_pcie_handle_mb_data()
      brcmfmac: fix memory leakage in msgbuf

Emmanuel Grumbach (1):
      iwlwifi: mvm: disable scheduled scan to prevent firmware crash

Rickard Strandqvist (1):
      net: wireless: ipw2x00: ipw2200.c: Cleaning up missing null-terminate=
 after strncpy call

Ronald Wahl (1):
      carl9170: fix sending URBs with wrong type when using full-speed

 drivers/net/wireless/ath/carl9170/carl9170.h     |  1 +
 drivers/net/wireless/ath/carl9170/usb.c          | 31 ++++++++++++++++++++=
+---
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c |  4 +++
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c   |  3 ++-
 drivers/net/wireless/ipw2x00/ipw2200.c           |  1 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c      |  3 ++-
 6 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/carl9170.h b/drivers/net/wir=
eless/ath/carl9170/carl9170.h
index 8596aba34f96..237d0cda1bcb 100644
--- a/drivers/net/wireless/ath/carl9170/carl9170.h
+++ b/drivers/net/wireless/ath/carl9170/carl9170.h
@@ -256,6 +256,7 @@ struct ar9170 {
 	atomic_t rx_work_urbs;
 	atomic_t rx_pool_urbs;
 	kernel_ulong_t features;
+	bool usb_ep_cmd_is_bulk;
=20
 	/* firmware settings */
 	struct completion fw_load_wait;
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless=
/ath/carl9170/usb.c
index f35c7f30f9a6..c9f93310c0d6 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -621,9 +621,16 @@ int __carl9170_exec_cmd(struct ar9170 *ar, struct carl=
9170_cmd *cmd,
 		goto err_free;
 	}
=20
-	usb_fill_int_urb(urb, ar->udev, usb_sndintpipe(ar->udev,
-		AR9170_USB_EP_CMD), cmd, cmd->hdr.len + 4,
-		carl9170_usb_cmd_complete, ar, 1);
+	if (ar->usb_ep_cmd_is_bulk)
+		usb_fill_bulk_urb(urb, ar->udev,
+				  usb_sndbulkpipe(ar->udev, AR9170_USB_EP_CMD),
+				  cmd, cmd->hdr.len + 4,
+				  carl9170_usb_cmd_complete, ar);
+	else
+		usb_fill_int_urb(urb, ar->udev,
+				 usb_sndintpipe(ar->udev, AR9170_USB_EP_CMD),
+				 cmd, cmd->hdr.len + 4,
+				 carl9170_usb_cmd_complete, ar, 1);
=20
 	if (free_buf)
 		urb->transfer_flags |=3D URB_FREE_BUFFER;
@@ -1032,9 +1039,10 @@ static void carl9170_usb_firmware_step2(const struct=
 firmware *fw,
 static int carl9170_usb_probe(struct usb_interface *intf,
 			      const struct usb_device_id *id)
 {
+	struct usb_endpoint_descriptor *ep;
 	struct ar9170 *ar;
 	struct usb_device *udev;
-	int err;
+	int i, err;
=20
 	err =3D usb_reset_device(interface_to_usbdev(intf));
 	if (err)
@@ -1050,6 +1058,21 @@ static int carl9170_usb_probe(struct usb_interface *=
intf,
 	ar->intf =3D intf;
 	ar->features =3D id->driver_info;
=20
+	/* We need to remember the type of endpoint 4 because it differs
+	 * between high- and full-speed configuration. The high-speed
+	 * configuration specifies it as interrupt and the full-speed
+	 * configuration as bulk endpoint. This information is required
+	 * later when sending urbs to that endpoint.
+	 */
+	for (i =3D 0; i < intf->cur_altsetting->desc.bNumEndpoints; ++i) {
+		ep =3D &intf->cur_altsetting->endpoint[i].desc;
+
+		if (usb_endpoint_num(ep) =3D=3D AR9170_USB_EP_CMD &&
+		    usb_endpoint_dir_out(ep) &&
+		    usb_endpoint_type(ep) =3D=3D USB_ENDPOINT_XFER_BULK)
+			ar->usb_ep_cmd_is_bulk =3D true;
+	}
+
 	usb_set_intfdata(intf, ar);
 	SET_IEEE80211_DEV(ar->hw, &intf->dev);
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c b/drivers/net=
/wireless/brcm80211/brcmfmac/msgbuf.c
index 535c7eb01b3a..8f8b9373de95 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
@@ -1318,6 +1318,8 @@ int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr)
 	msgbuf->nrof_flowrings =3D if_msgbuf->nrof_flowrings;
 	msgbuf->flowring_dma_handle =3D kzalloc(msgbuf->nrof_flowrings *
 		sizeof(*msgbuf->flowring_dma_handle), GFP_ATOMIC);
+	if (!msgbuf->flowring_dma_handle)
+		goto fail;
=20
 	msgbuf->rx_dataoffset =3D if_msgbuf->rx_dataoffset;
 	msgbuf->max_rxbufpost =3D if_msgbuf->max_rxbufpost;
@@ -1362,6 +1364,7 @@ fail:
 		kfree(msgbuf->flow_map);
 		kfree(msgbuf->txstatus_done_map);
 		brcmf_msgbuf_release_pktids(msgbuf);
+		kfree(msgbuf->flowring_dma_handle);
 		if (msgbuf->ioctbuf)
 			dma_free_coherent(drvr->bus_if->dev,
 					  BRCMF_TX_IOCTL_MAX_MSG_SIZE,
@@ -1391,6 +1394,7 @@ void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr)
 				  BRCMF_TX_IOCTL_MAX_MSG_SIZE,
 				  msgbuf->ioctbuf, msgbuf->ioctbuf_handle);
 		brcmf_msgbuf_release_pktids(msgbuf);
+		kfree(msgbuf->flowring_dma_handle);
 		kfree(msgbuf);
 		drvr->proto->pd =3D NULL;
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c b/drivers/net/w=
ireless/brcm80211/brcmfmac/pcie.c
index bc972c0ba5f8..e5101b287e4e 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
@@ -591,12 +591,13 @@ static void brcmf_pcie_handle_mb_data(struct brcmf_pc=
iedev_info *devinfo)
 	}
 	if (dtoh_mb_data & BRCMF_D2H_DEV_DS_EXIT_NOTE)
 		brcmf_dbg(PCIE, "D2H_MB_DATA: DEEP SLEEP EXIT\n");
-	if (dtoh_mb_data & BRCMF_D2H_DEV_D3_ACK)
+	if (dtoh_mb_data & BRCMF_D2H_DEV_D3_ACK) {
 		brcmf_dbg(PCIE, "D2H_MB_DATA: D3 ACK\n");
 		if (waitqueue_active(&devinfo->mbdata_resp_wait)) {
 			devinfo->mbdata_completed =3D true;
 			wake_up(&devinfo->mbdata_resp_wait);
 		}
+	}
 }
=20
=20
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/=
ipw2x00/ipw2200.c
index c5aa404069f3..389656bd1a74 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -9853,6 +9853,7 @@ static int ipw_wx_get_wireless_mode(struct net_device=
 *dev,
 		strncpy(extra, "unknown", MAX_WX_STRING);
 		break;
 	}
+	extra[MAX_WX_STRING - 1] =3D '\0';
=20
 	IPW_DEBUG_WX("PRIV GET MODE: %s\n", extra);
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 0d6a8b768a68..7c8796584c25 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -396,7 +396,8 @@ int iwl_mvm_mac_setup_register(struct iwl_mvm *mvm)
 	else
 		hw->wiphy->flags &=3D ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
=20
-	hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_SCHED_SCAN;
+	/* TODO: enable that only for firmwares that don't crash */
+	/* hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_SCHED_SCAN; */
 	hw->wiphy->max_sched_scan_ssids =3D PROBE_OPTION_MAX;
 	hw->wiphy->max_match_sets =3D IWL_SCAN_MAX_PROFILES;
 	/* we create the 802.11 header and zero length SSID IE. */
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--qcHopEYAB45HaUaB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJT7QDVAAoJEJctW/TcYTgGIoAP/1204RTNsbWg7lX7N18Pn/wQ
Eslx/w8aNhuxd/91fkkR50LDe80ZVQfKgCQyxqVF6pGlmhr1OHHkZrUMeCmipJRn
YkoknNl7gH/OwuNMgXPjAMJ3yUmAtc7F8pCO/sCHAAgTjmPDfUtIvmIyIJNlChbp
MwcXomSzaSLBRU9LSd2FD8s/g02GX+yc6i6j3HX/DA+giVPRcvBxQjKekNPOITuv
WZEXG0mWBQTgtNpplSMhOtqEhaSXTz3/9JcYWXkEeyBgF3+ORf+5B4IRytWVd0eA
nE1N+c77fQoWXF+rhMN1I+pqcdxPCc7wgCI3k1GbN9X5Od5HRk0ZNpbBkAoUsYpd
iFumVO20KfvfuNklgCdaJJvT+NntYdu/KZAcZyYk/sNpumVZflkRKogbGfaMXpeq
K95tcW/M+8tn9mtuFXhFRyx1DsTXocKqQzGgDABa3aJeBWY95OlY2azSRuic+McG
APTraT1Q2BWm0Gn0xvP/jmcBvcIP2fGj0CK/tWmxErv5sBjPHt1Ceb0/KKORB3oj
O/ElSDJlw9UWOAmyh/M8P/1ftE4xeCDGy52Uo7B6Ce+m7zw8I56297qBUvt665E6
8mgl3DjuU8QW6LZafgOpmHa23k09/QFuVDzWYDdP60lfC/8xC/p7ycojPIEd29Q8
TC6zmBOQMw/psE0B1dA3
=Rc9M
-----END PGP SIGNATURE-----

--qcHopEYAB45HaUaB--
