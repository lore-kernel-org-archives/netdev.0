From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6 1/2] Revert "rndis_host: Poll status channel before
 control channel"
Date: Fri, 02 Jul 2010 23:39:21 +0100
Message-ID: <1278110361.4878.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Lu=EDs?= Picciochi Oliveira <pitxyoki@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58229 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752807Ab0GBWj1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jul 2010 18:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit c17b274dc2aa538b68c1f02b01a3c4e124b435ba.

That change was reported to break rndis_wlan support for the WUSB54GS.

Reported-by: Lu=C3=ADs Picciochi Oliveira <pitxyoki@gmail.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/rndis_host.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.=
c
index 28d3ee1..dd8a4ad 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -104,10 +104,8 @@ static void rndis_msg_indicate(struct usbnet *dev,=
 struct rndis_indicate *msg,
 int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int b=
uflen)
 {
 	struct cdc_state	*info =3D (void *) &dev->data;
-	struct usb_cdc_notification notification;
 	int			master_ifnum;
 	int			retval;
-	int			partial;
 	unsigned		count;
 	__le32			rsp;
 	u32			xid =3D 0, msg_len, request_id;
@@ -135,17 +133,13 @@ int rndis_command(struct usbnet *dev, struct rndi=
s_msg_hdr *buf, int buflen)
 	if (unlikely(retval < 0 || xid =3D=3D 0))
 		return retval;
=20
-	/* Some devices don't respond on the control channel until
-	 * polled on the status channel, so do that first. */
-	retval =3D usb_interrupt_msg(
-		dev->udev,
-		usb_rcvintpipe(dev->udev, dev->status->desc.bEndpointAddress),
-		&notification, sizeof(notification), &partial,
-		RNDIS_CONTROL_TIMEOUT_MS);
-	if (unlikely(retval < 0))
-		return retval;
+	// FIXME Seems like some devices discard responses when
+	// we time out and cancel our "get response" requests...
+	// so, this is fragile.  Probably need to poll for status.
=20
-	/* Poll the control channel; the request probably completed immediate=
ly */
+	/* ignore status endpoint, just poll the control channel;
+	 * the request probably completed immediately
+	 */
 	rsp =3D buf->msg_type | RNDIS_MSG_COMPLETION;
 	for (count =3D 0; count < 10; count++) {
 		memset(buf, 0, CONTROL_BUFFER_SIZE);
--=20
1.7.1



