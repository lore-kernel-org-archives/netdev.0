From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: protect Cisco HDLC state changes with a spinlock.
Date: Mon, 19 May 2008 19:11:08 +0200
Message-ID: <m3od72gqxf.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761206AbYESRLY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WAN: protect Cisco HDLC state changes with a spinlock.
   =20
Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -55,6 +55,7 @@ struct cisco_state {
 	cisco_proto settings;
=20
 	struct timer_list timer;
+	spinlock_t lock;
 	unsigned long last_poll;
 	int up;
 	int request_sent;
@@ -157,6 +158,7 @@ static int cisco_rx(struct sk_buff *skb)
 {
 	struct net_device *dev =3D skb->dev;
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
+	struct cisco_state *st =3D state(hdlc);
 	struct hdlc_header *data =3D (struct hdlc_header*)skb->data;
 	struct cisco_packet *cisco_data;
 	struct in_device *in_dev;
@@ -219,11 +221,12 @@ static int cisco_rx(struct sk_buff *skb)
 			goto rx_error;
=20
 		case CISCO_KEEPALIVE_REQ:
-			state(hdlc)->rxseq =3D ntohl(cisco_data->par1);
-			if (state(hdlc)->request_sent &&
-			    ntohl(cisco_data->par2) =3D=3D state(hdlc)->txseq) {
-				state(hdlc)->last_poll =3D jiffies;
-				if (!state(hdlc)->up) {
+			spin_lock(&st->lock);
+			st->rxseq =3D ntohl(cisco_data->par1);
+			if (st->request_sent &&
+			    ntohl(cisco_data->par2) =3D=3D st->txseq) {
+				st->last_poll =3D jiffies;
+				if (!st->up) {
 					u32 sec, min, hrs, days;
 					sec =3D ntohl(cisco_data->time) / 1000;
 					min =3D sec / 60; sec -=3D min * 60;
@@ -231,12 +234,12 @@ static int cisco_rx(struct sk_buff *skb)
 					days =3D hrs / 24; hrs -=3D days * 24;
 					printk(KERN_INFO "%s: Link up (peer "
 					       "uptime %ud%uh%um%us)\n",
-					       dev->name, days, hrs,
-					       min, sec);
+					       dev->name, days, hrs, min, sec);
 					netif_dormant_off(dev);
-					state(hdlc)->up =3D 1;
+					st->up =3D 1;
 				}
 			}
+			spin_unlock(&st->lock);
=20
 			dev_kfree_skb_any(skb);
 			return NET_RX_SUCCESS;
@@ -260,24 +263,25 @@ static void cisco_timer(unsigned long arg)
 {
 	struct net_device *dev =3D (struct net_device *)arg;
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
+	struct cisco_state *st =3D state(hdlc);
=20
-	if (state(hdlc)->up &&
-	    time_after(jiffies, state(hdlc)->last_poll +
-		       state(hdlc)->settings.timeout * HZ)) {
-		state(hdlc)->up =3D 0;
+	spin_lock(&st->lock);
+	if (st->up &&
+	    time_after(jiffies, st->last_poll + st->settings.timeout * HZ)) {
+		st->up =3D 0;
 		printk(KERN_INFO "%s: Link down\n", dev->name);
 		netif_dormant_on(dev);
 	}
=20
-	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ,
-			     htonl(++state(hdlc)->txseq),
-			     htonl(state(hdlc)->rxseq));
-	state(hdlc)->request_sent =3D 1;
-	state(hdlc)->timer.expires =3D jiffies +
-		state(hdlc)->settings.interval * HZ;
-	state(hdlc)->timer.function =3D cisco_timer;
-	state(hdlc)->timer.data =3D arg;
-	add_timer(&state(hdlc)->timer);
+	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ, htonl(++st->txseq),
+			     htonl(st->rxseq));
+	st->request_sent =3D 1;
+	spin_unlock(&st->lock);
+
+	st->timer.expires =3D jiffies + st->settings.interval * HZ;
+	st->timer.function =3D cisco_timer;
+	st->timer.data =3D arg;
+	add_timer(&st->timer);
 }
=20
=20
@@ -285,15 +289,20 @@ static void cisco_timer(unsigned long arg)
 static void cisco_start(struct net_device *dev)
 {
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
-	state(hdlc)->up =3D 0;
-	state(hdlc)->request_sent =3D 0;
-	state(hdlc)->txseq =3D state(hdlc)->rxseq =3D 0;
-
-	init_timer(&state(hdlc)->timer);
-	state(hdlc)->timer.expires =3D jiffies + HZ; /*First poll after 1s*/
-	state(hdlc)->timer.function =3D cisco_timer;
-	state(hdlc)->timer.data =3D (unsigned long)dev;
-	add_timer(&state(hdlc)->timer);
+	struct cisco_state *st =3D state(hdlc);
+	unsigned long flags;
+
+	spin_lock_irqsave(&st->lock, flags);
+	st->up =3D 0;
+	st->request_sent =3D 0;
+	st->txseq =3D st->rxseq =3D 0;
+	spin_unlock_irqrestore(&st->lock, flags);
+
+	init_timer(&st->timer);
+	st->timer.expires =3D jiffies + HZ; /* First poll after 1 s */
+	st->timer.function =3D cisco_timer;
+	st->timer.data =3D (unsigned long)dev;
+	add_timer(&st->timer);
 }
=20
=20
@@ -301,10 +310,16 @@ static void cisco_start(struct net_device *dev)
 static void cisco_stop(struct net_device *dev)
 {
 	hdlc_device *hdlc =3D dev_to_hdlc(dev);
-	del_timer_sync(&state(hdlc)->timer);
+	struct cisco_state *st =3D state(hdlc);
+	unsigned long flags;
+
+	del_timer_sync(&st->timer);
+
+	spin_lock_irqsave(&st->lock, flags);
 	netif_dormant_on(dev);
-	state(hdlc)->up =3D 0;
-	state(hdlc)->request_sent =3D 0;
+	st->up =3D 0;
+	st->request_sent =3D 0;
+	spin_unlock_irqrestore(&st->lock, flags);
 }
=20
=20
@@ -366,6 +381,7 @@ static int cisco_ioctl(struct net_device *dev, stru=
ct ifreq *ifr)
 			return result;
=20
 		memcpy(&state(hdlc)->settings, &new_settings, size);
+		spin_lock_init(&state(hdlc)->lock);
 		dev->hard_start_xmit =3D hdlc->xmit;
 		dev->header_ops =3D &cisco_header_ops;
 		dev->type =3D ARPHRD_CISCO;
