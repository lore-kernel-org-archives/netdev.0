From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] IrDA: Oops fix for ksdazzle
Date: Mon, 1 Oct 2007 02:21:38 +0300
Message-ID: <20070930232138.GA5669@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	Alex =?iso-8859-1?Q?Villac=EDs?= Lasso
	<a_villacis@palosanto.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.31]:61999 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbXI3XVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Sep 2007 19:21:43 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2023.orange.fr (SMTP Server) with ESMTP id 7686B1C000AD
	for <netdev@vger.kernel.org>; Mon,  1 Oct 2007 01:21:40 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is the last remaining patch for IrDA, against net-2.6.24.

It fixes a kernel oops triggered by the ksdazzle SIR driver.
We need more space for input frames, and 2048 should be plenty of it.

Signed-off-by: Alex Villac=EDs Lasso <a_villacis@palosanto.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/ksdazzle-sir.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

Index: net-2.6.24-quilt/drivers/net/irda/ksdazzle-sir.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-2.6.24-quilt.orig/drivers/net/irda/ksdazzle-sir.c	2007-10-01 01=
:53:56.000000000 +0300
+++ net-2.6.24-quilt/drivers/net/irda/ksdazzle-sir.c	2007-10-01 01:53:5=
8.000000000 +0300
@@ -1,7 +1,7 @@
 /*********************************************************************=
********
 *
 * Filename:      ksdazzle.c
-* Version:       0.1.1
+* Version:       0.1.2
 * Description:   Irda KingSun Dazzle USB Dongle
 * Status:        Experimental
 * Author:        Alex Villac=EDs Lasso <a_villacis@palosanto.com>
@@ -113,6 +113,7 @@
 #define KINGSUN_REQ_SEND 0x09
=20
 #define KINGSUN_SND_FIFO_SIZE    2048	/* Max packet we can send */
+#define KINGSUN_RCV_MAX 2048	/* Max transfer we can receive */
=20
 struct ksdazzle_speedparams {
 	__le32 baudrate;	/* baud rate, little endian */
@@ -150,7 +151,7 @@
 	__u8 tx_payload[8];
=20
 	struct urb *rx_urb;
-	__u8 rx_payload[8];
+	__u8 *rx_buf;
 	iobuff_t rx_unwrap_buff;
=20
 	struct usb_ctrlrequest *speed_setuprequest;
@@ -440,7 +441,8 @@
 	/* Start reception. */
 	usb_fill_int_urb(kingsun->rx_urb, kingsun->usbdev,
 			 usb_rcvintpipe(kingsun->usbdev, kingsun->ep_in),
-			 kingsun->rx_payload, 8, ksdazzle_rcv_irq, kingsun, 1);
+			 kingsun->rx_buf, KINGSUN_RCV_MAX, ksdazzle_rcv_irq,
+			 kingsun, 1);
 	kingsun->rx_urb->status =3D 0;
 	err =3D usb_submit_urb(kingsun->rx_urb, GFP_KERNEL);
 	if (err) {
@@ -641,6 +643,7 @@
 	kingsun->tx_buf_clear_sent =3D 0;
=20
 	kingsun->rx_urb =3D NULL;
+	kingsun->rx_buf =3D NULL;
 	kingsun->rx_unwrap_buff.in_frame =3D FALSE;
 	kingsun->rx_unwrap_buff.state =3D OUTSIDE_FRAME;
 	kingsun->rx_unwrap_buff.skb =3D NULL;
@@ -651,6 +654,11 @@
 	kingsun->speed_urb =3D NULL;
 	kingsun->speedparams.baudrate =3D 0;
=20
+	/* Allocate input buffer */
+	kingsun->rx_buf =3D kmalloc(KINGSUN_RCV_MAX, GFP_KERNEL);
+	if (!kingsun->rx_buf)
+		goto free_mem;
+
 	/* Allocate output buffer */
 	kingsun->tx_buf_clear =3D kmalloc(KINGSUN_SND_FIFO_SIZE, GFP_KERNEL);
 	if (!kingsun->tx_buf_clear)
@@ -714,6 +722,7 @@
       free_mem:
 	kfree(kingsun->speed_setuprequest);
 	kfree(kingsun->tx_buf_clear);
+	kfree(kingsun->rx_buf);
 	free_netdev(net);
       err_out1:
 	return ret;
@@ -746,6 +755,7 @@
=20
 	kfree(kingsun->speed_setuprequest);
 	kfree(kingsun->tx_buf_clear);
+	kfree(kingsun->rx_buf);
 	free_netdev(kingsun->netdev);
=20
 	usb_set_intfdata(intf, NULL);

