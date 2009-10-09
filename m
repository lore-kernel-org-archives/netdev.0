From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: fix Cisco HDLC handshaking.
Date: Fri, 09 Oct 2009 18:16:10 +0200
Message-ID: <m3iqeoh7at.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42092 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760909AbZJIQQt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 12:16:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WAN: fix Cisco HDLC handshaking.

Cisco HDLC uses keepalive packets and sequence numbers to determine lin=
k
state. In rare cases both ends could transmit keepalive packets at the =
same
time, causing the received sequence numbers to be treated as incorrect.
Now we accept our current sequence number as well as the previous one.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.=
c
index cf5fd17..f1bff98 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -58,8 +58,7 @@ struct cisco_state {
 	spinlock_t lock;
 	unsigned long last_poll;
 	int up;
-	int request_sent;
-	u32 txseq; /* TX sequence number */
+	u32 txseq; /* TX sequence number, 0 =3D none */
 	u32 rxseq; /* RX sequence number */
 };
=20
@@ -163,6 +162,7 @@ static int cisco_rx(struct sk_buff *skb)
 	struct cisco_packet *cisco_data;
 	struct in_device *in_dev;
 	__be32 addr, mask;
+	u32 ack;
=20
 	if (skb->len < sizeof(struct hdlc_header))
 		goto rx_error;
@@ -223,8 +223,10 @@ static int cisco_rx(struct sk_buff *skb)
 		case CISCO_KEEPALIVE_REQ:
 			spin_lock(&st->lock);
 			st->rxseq =3D ntohl(cisco_data->par1);
-			if (st->request_sent &&
-			    ntohl(cisco_data->par2) =3D=3D st->txseq) {
+			ack =3D ntohl(cisco_data->par2);
+			if (ack && (ack =3D=3D st->txseq ||
+				    /* our current REQ may be in transit */
+				    ack =3D=3D st->txseq - 1)) {
 				st->last_poll =3D jiffies;
 				if (!st->up) {
 					u32 sec, min, hrs, days;
@@ -275,7 +277,6 @@ static void cisco_timer(unsigned long arg)
=20
 	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ, htonl(++st->txseq),
 			     htonl(st->rxseq));
-	st->request_sent =3D 1;
 	spin_unlock(&st->lock);
=20
 	st->timer.expires =3D jiffies + st->settings.interval * HZ;
@@ -293,9 +294,7 @@ static void cisco_start(struct net_device *dev)
 	unsigned long flags;
=20
 	spin_lock_irqsave(&st->lock, flags);
-	st->up =3D 0;
-	st->request_sent =3D 0;
-	st->txseq =3D st->rxseq =3D 0;
+	st->up =3D st->txseq =3D st->rxseq =3D 0;
 	spin_unlock_irqrestore(&st->lock, flags);
=20
 	init_timer(&st->timer);
@@ -317,8 +316,7 @@ static void cisco_stop(struct net_device *dev)
=20
 	spin_lock_irqsave(&st->lock, flags);
 	netif_dormant_on(dev);
-	st->up =3D 0;
-	st->request_sent =3D 0;
+	st->up =3D st->txseq =3D 0;
 	spin_unlock_irqrestore(&st->lock, flags);
 }
=20

--=20
Krzysztof Halasa
