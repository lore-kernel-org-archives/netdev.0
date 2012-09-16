From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/6] llc2: Collapse the station event receive path
Date: Sun, 16 Sep 2012 04:11:25 +0100
Message-ID: <1347765085.13258.211.camel@deadeye.wl.decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-P0ewiqgg6sbEjL84CqVc"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53022 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751133Ab2IPDLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:11:30 -0400
In-Reply-To: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-P0ewiqgg6sbEjL84CqVc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We only ever put one skb on the event queue, and then immediately
process it.  Remove the queue and fold together the related functions,
removing several blatantly false comments.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_station.c |   87 ++++-----------------------------------------=
----
 1 file changed, 6 insertions(+), 81 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 917d700..3bdb888 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -32,14 +32,9 @@
  *
  * @mac_sa: MAC source address
  * @sap_list: list of related SAPs
- * @ev_q: events entering state mach.
  * @mac_pdu_q: PDUs ready to send to MAC
  */
 struct llc_station {
-	struct {
-		struct sk_buff_head list;
-		spinlock_t	    lock;
-	} ev_q;
 	struct sk_buff_head	    mac_pdu_q;
 };
=20
@@ -216,79 +211,6 @@ static struct llc_station_state_trans *
 }
=20
 /**
- *	llc_station_free_ev - frees an event
- *	@skb: Address of the event
- *
- *	Frees an event.
- */
-static void llc_station_free_ev(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-}
-
-/**
- *	llc_station_next_state - processes event and goes to the next state
- *	@skb: Address of the event
- *
- *	Processes an event, executes any transitions related to that event and
- *	updates the state of the station.
- */
-static u16 llc_station_next_state(struct sk_buff *skb)
-{
-	u16 rc =3D 1;
-	struct llc_station_state_trans *trans;
-
-	trans =3D llc_find_station_trans(skb);
-	if (trans)
-		/* got the state to which we next transition; perform the
-		 * actions associated with this transition before actually
-		 * transitioning to the next state
-		 */
-		rc =3D llc_exec_station_trans_actions(trans, skb);
-	else
-		/* event not recognized in current state; re-queue it for
-		 * processing again at a later time; return failure
-		 */
-		rc =3D 0;
-	llc_station_free_ev(skb);
-	return rc;
-}
-
-/**
- *	llc_station_service_events - service events in the queue
- *
- *	Get an event from the station event queue (if any); attempt to service
- *	the event; if event serviced, get the next event (if any) on the event
- *	queue; if event not service, re-queue the event on the event queue and
- *	attempt to service the next event; when serviced all events in queue,
- *	finished; if don't transition to different state, just service all
- *	events once; if transition to new state, service all events again.
- *	Caller must hold llc_main_station.ev_q.lock.
- */
-static void llc_station_service_events(void)
-{
-	struct sk_buff *skb;
-
-	while ((skb =3D skb_dequeue(&llc_main_station.ev_q.list)) !=3D NULL)
-		llc_station_next_state(skb);
-}
-
-/**
- *	llc_station_state_process - queue event and try to process queue.
- *	@skb: Address of the event
- *
- *	Queues an event (on the station event queue) for handling by the
- *	station state machine and attempts to process any queued-up events.
- */
-static void llc_station_state_process(struct sk_buff *skb)
-{
-	spin_lock_bh(&llc_main_station.ev_q.lock);
-	skb_queue_tail(&llc_main_station.ev_q.list, skb);
-	llc_station_service_events();
-	spin_unlock_bh(&llc_main_station.ev_q.lock);
-}
-
-/**
  *	llc_station_rcv - send received pdu to the station state machine
  *	@skb: received frame.
  *
@@ -296,14 +218,17 @@ static void llc_station_state_process(struct sk_buff =
*skb)
  */
 static void llc_station_rcv(struct sk_buff *skb)
 {
-	llc_station_state_process(skb);
+	struct llc_station_state_trans *trans;
+
+	trans =3D llc_find_station_trans(skb);
+	if (trans)
+		llc_exec_station_trans_actions(trans, skb);
+	kfree_skb(skb);
 }
=20
 void __init llc_station_init(void)
 {
 	skb_queue_head_init(&llc_main_station.mac_pdu_q);
-	skb_queue_head_init(&llc_main_station.ev_q.list);
-	spin_lock_init(&llc_main_station.ev_q.lock);
 	llc_set_station_handler(llc_station_rcv);
 }
=20



--=-P0ewiqgg6sbEjL84CqVc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVDXee/yOyVhhEJAQpREA/+MWyGQ6sC/RcUdK54QA64JKtLDG0F93Tx
CpfXmNtWVmNyGRPUDMy/VmJ4XOHZNGgaT9Hf8jFOJSY/JNnNxhQKNvqBycuBHesu
jReWdbFjcK91ERAAROeKvGy+W1963CSllFlMrcY3seZO8XfXF9Wq02xsBfItANz+
gOadyMQZNnOE9e0J+bSZIq0oYXzez33wGWeojBCcSaX3kDgMqPHTtd/AGN6tYykM
ZwkX8W/oaq8+x4rMYO7U3bhfG3NFo2mBFbWoWLyOqRYGVuhQ+CHjB+aPo1i9GSyF
MydJICB7YfCsu1pBak/b39PvqdY9nXXaewKg6W41r94/2L7Yds/6vA+v++/Lfz7u
4F3DhPmBof20GvtJoharnJsJdRbfR1TVvRx1eEwZ94i/XOTicquhSWEZm+fsGnic
x5RRzWFOJJB9WXGBFSfwqnYiDIP2d9yellIDuiqDA08NmgE34AXQTc1aGlV/BUY3
ax38jOqapzGJBjKy8ok963hdtNS8fBahGW8JK52LZn5urguAJt2qytq3cZlWvO/I
D+c7au6/GaHqVP+mdqChMsYiftA+DwQDWGrNR5Cx49cHzrAueUhjA40wHtxxdsNY
APCT317VWJXicjNk0/CvW5fiM8b7M92CcGv0OTuivbA94ECug3pJalIErAplweZH
jZgDmeq3Rdw=
=jrWw
-----END PGP SIGNATURE-----

--=-P0ewiqgg6sbEjL84CqVc--
