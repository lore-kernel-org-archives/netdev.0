From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 6/6] llc2: Collapse remainder of state machine into
 simple if-else if-statement
Date: Sun, 16 Sep 2012 04:11:47 +0100
Message-ID: <1347765107.13258.214.camel@deadeye.wl.decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xAJ6fGcoSNceUqvrjZvY"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53032 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750930Ab2IPDLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:11:52 -0400
In-Reply-To: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xAJ6fGcoSNceUqvrjZvY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_station.c |   91 +++------------------------------------------=
----
 1 file changed, 4 insertions(+), 87 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index fe43158..204a835 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -25,16 +25,6 @@
 #include <net/llc_s_st.h>
 #include <net/llc_pdu.h>
=20
-typedef int (*llc_station_ev_t)(struct sk_buff *skb);
-
-typedef int (*llc_station_action_t)(struct sk_buff *skb);
-
-/* Station component state table structure */
-struct llc_station_state_trans {
-	llc_station_ev_t ev;
-	llc_station_action_t *ev_actions;
-};
-
 static int llc_stat_ev_rx_null_dsap_xid_c(struct sk_buff *skb)
 {
 	struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
@@ -109,78 +99,6 @@ free:
 	goto out;
 }
=20
-/* state transition for LLC_STATION_EV_RX_NULL_DSAP_XID_C event */
-static llc_station_action_t llc_stat_up_state_actions_2[] =3D {
-	llc_station_ac_send_xid_r,
-	NULL,
-};
-
-static struct llc_station_state_trans llc_stat_up_state_trans_2 =3D {
-	.ev	    =3D llc_stat_ev_rx_null_dsap_xid_c,
-	.ev_actions =3D llc_stat_up_state_actions_2,
-};
-
-/* state transition for LLC_STATION_EV_RX_NULL_DSAP_TEST_C event */
-static llc_station_action_t llc_stat_up_state_actions_3[] =3D {
-	llc_station_ac_send_test_r,
-	NULL,
-};
-
-static struct llc_station_state_trans llc_stat_up_state_trans_3 =3D {
-	.ev	    =3D llc_stat_ev_rx_null_dsap_test_c,
-	.ev_actions =3D llc_stat_up_state_actions_3,
-};
-
-/* array of pointers; one to each transition */
-static struct llc_station_state_trans *llc_stat_up_state_trans [] =3D {
-	&llc_stat_up_state_trans_2,
-	&llc_stat_up_state_trans_3,
-	NULL,
-};
-
-/**
- *	llc_exec_station_trans_actions - executes actions for transition
- *	@trans: Address of the transition
- *	@skb: Address of the event that caused the transition
- *
- *	Executes actions of a transition of the station state machine. Returns
- *	0 if all actions complete successfully, nonzero otherwise.
- */
-static u16 llc_exec_station_trans_actions(struct llc_station_state_trans *=
trans,
-					  struct sk_buff *skb)
-{
-	u16 rc =3D 0;
-	llc_station_action_t *next_action =3D trans->ev_actions;
-
-	for (; next_action && *next_action; next_action++)
-		if ((*next_action)(skb))
-			rc =3D 1;
-	return rc;
-}
-
-/**
- *	llc_find_station_trans - finds transition for this event
- *	@skb: Address of the event
- *
- *	Search thru events of the current state of the station until list
- *	exhausted or it's obvious that the event is not valid for the current
- *	state. Returns the address of the transition if cound, %NULL otherwise.
- */
-static struct llc_station_state_trans *
-				llc_find_station_trans(struct sk_buff *skb)
-{
-	int i =3D 0;
-	struct llc_station_state_trans *rc =3D NULL;
-	struct llc_station_state_trans **next_trans;
-
-	for (next_trans =3D llc_stat_up_state_trans; next_trans[i]; i++)
-		if (!next_trans[i]->ev(skb)) {
-			rc =3D next_trans[i];
-			break;
-		}
-	return rc;
-}
-
 /**
  *	llc_station_rcv - send received pdu to the station state machine
  *	@skb: received frame.
@@ -189,11 +107,10 @@ static struct llc_station_state_trans *
  */
 static void llc_station_rcv(struct sk_buff *skb)
 {
-	struct llc_station_state_trans *trans;
-
-	trans =3D llc_find_station_trans(skb);
-	if (trans)
-		llc_exec_station_trans_actions(trans, skb);
+	if (llc_stat_ev_rx_null_dsap_xid_c(skb))
+		llc_station_ac_send_xid_r(skb);
+	else if (llc_stat_ev_rx_null_dsap_test_c(skb))
+		llc_station_ac_send_test_r(skb);
 	kfree_skb(skb);
 }
=20


--=-xAJ6fGcoSNceUqvrjZvY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVDc+e/yOyVhhEJAQqOQRAA1a1YALGfT/NqVx6nvK1oQRZDXqo2S6WW
hmzu5nXBMDSmDui/hOll+DeRQRfPixin2pMlkTlKMjr4+uKEJrd9gjZS1a663lSJ
pB+seeBv/jJdtEW3AvjK+maFw9xXPnMPoHJ/OMw+UkfoDp/CN54hriyIww4dQT67
cmMI/7djQ6d4mi0pnvQJU4BptNq91fIYAfCWq5Y4PNYBcaqc0UB1Rf2UinSeZoDX
rn052H5u+QmzGUY0IvdUmNd0D2govvF5b7er9DJUj+caR3to3n0Fx3oJXWY3X0ay
Rlt55pXIakhYr+NXSbhoFyJWfXxwQ+zVhY2e2l9tAqubyjp3fl1n1FgyQ+ewPzce
oow4ybYtUiTeMCi7bXxV4pMtdGcZtcT1NPK0GtbkkWePev8YRs9jl5IRZjJZ2x1/
7M9tYBS+mH6BBApu3hykPCTSTJj88bequmxYUzIrSSdNCj1fT6CAOWmWSD1M8/B0
pEUS9T62aSm1QXfw9//mAl0hC24Zatyv4n4JFtokfEXxCvarjJ35smQrYuxJa1Hl
GShnG+/ZECWDSxtqsNqKv6dgz4Jh5wVj7fMBTL18V1MhxFehKOF/H5Af/1LwmK07
ACmvTKTeY3ctPDumU+FILHBuBpl2ro/vt0DQ1PbCq3Gr4T0lbqAY1+opUTVrnUT5
1cNfldnT8Is=
=NwJX
-----END PGP SIGNATURE-----

--=-xAJ6fGcoSNceUqvrjZvY--
