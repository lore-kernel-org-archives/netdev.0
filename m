From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 6/7] sfc: Fix search for flush completion events
Date: Wed, 04 Mar 2009 20:01:15 +0000
Message-ID: <1236196875.3140.32.camel@achroite>
References: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:54071 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754904AbZCDUBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 15:01:19 -0500
In-Reply-To: <1236196272.3140.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFWhen flushing queues we disable normal interrupt and event han=
dling and
poll event queue 0 looking for flush completions.  Unfortunately the
flush event polling loop fails to move past any other type of event.
This problem has not been observed in production hardware but appears t=
o
be a possibility.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index efd121c..82c10f4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1187,31 +1187,29 @@ static void falcon_poll_flush_events(struct efx=
_nic *efx)
 	struct efx_channel *channel =3D &efx->channel[0];
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	unsigned int read_ptr, i;
+	unsigned int read_ptr =3D channel->eventq_read_ptr;
+	unsigned int end_ptr =3D (read_ptr - 1) & FALCON_EVQ_MASK;
=20
-	read_ptr =3D channel->eventq_read_ptr;
-	for (i =3D 0; i < FALCON_EVQ_SIZE; ++i) {
+	do {
 		efx_qword_t *event =3D falcon_event(channel, read_ptr);
 		int ev_code, ev_sub_code, ev_queue;
 		bool ev_failed;
+
 		if (!falcon_event_present(event))
 			break;
=20
 		ev_code =3D EFX_QWORD_FIELD(*event, EV_CODE);
-		if (ev_code !=3D DRIVER_EV_DECODE)
-			continue;
-
 		ev_sub_code =3D EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-		switch (ev_sub_code) {
-		case TX_DESCQ_FLS_DONE_EV_DECODE:
+		if (ev_code =3D=3D DRIVER_EV_DECODE &&
+		    ev_sub_code =3D=3D TX_DESCQ_FLS_DONE_EV_DECODE) {
 			ev_queue =3D EFX_QWORD_FIELD(*event,
 						   DRIVER_EV_TX_DESCQ_ID);
 			if (ev_queue < EFX_TX_QUEUE_COUNT) {
 				tx_queue =3D efx->tx_queue + ev_queue;
 				tx_queue->flushed =3D true;
 			}
-			break;
-		case RX_DESCQ_FLS_DONE_EV_DECODE:
+		} else if (ev_code =3D=3D DRIVER_EV_DECODE &&
+			   ev_sub_code =3D=3D RX_DESCQ_FLS_DONE_EV_DECODE) {
 			ev_queue =3D EFX_QWORD_FIELD(*event,
 						   DRIVER_EV_RX_DESCQ_ID);
 			ev_failed =3D EFX_QWORD_FIELD(*event,
@@ -1225,11 +1223,10 @@ static void falcon_poll_flush_events(struct efx=
_nic *efx)
 				else
 					rx_queue->flushed =3D true;
 			}
-			break;
 		}
=20
 		read_ptr =3D (read_ptr + 1) & FALCON_EVQ_MASK;
-	}
+	} while (read_ptr !=3D end_ptr);
 }
=20
 /* Handle tx and rx flushes at the same time, since they run in

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

