From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: flush tx_queue in hdlc_ppp to prevent panic on rmmod hw_driver.
Date: Thu, 15 Apr 2010 02:09:52 +0200
Message-ID: <m3mxx5mv8v.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38194 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504Ab0DOAJy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 20:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx_queue is used as a temporary queue when not allowed to queue skb
directly to the hw device driver (which may sleep). Most paths flush
it before returning, but ppp_start() currently cannot. Make sure we
don't leave skbs pointing to a non-existent device.

Thanks to Michael Barkowski for reporting this problem.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index b9b9d6b..941f053 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -628,9 +628,15 @@ static void ppp_stop(struct net_device *dev)
 	ppp_cp_event(dev, PID_LCP, STOP, 0, 0, 0, NULL);
 }
=20
+static void ppp_close(struct net_device *dev)
+{
+	ppp_tx_flush();
+}
+
 static struct hdlc_proto proto =3D {
 	.start		=3D ppp_start,
 	.stop		=3D ppp_stop,
+	.close		=3D ppp_close,
 	.type_trans	=3D ppp_type_trans,
 	.ioctl		=3D ppp_ioctl,
 	.netif_rx	=3D ppp_rx,
