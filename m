From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 16:08:25 +0200
Message-ID: <1319033305.8416.29.camel@edumazet-laptop>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)  <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
	 <1319030740.8416.14.camel@edumazet-laptop>
	 (sfid-20111019_152616_037809_8B36A3CC) <1319031348.1286.4.camel@jlt3.sipsolutions.net>
	 <1319031856.8416.19.camel@edumazet-laptop>
	 (sfid-20111019_154501_303541_A1FD5289) <1319032638.1286.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50410 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803Ab1JSOIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 10:08:32 -0400
Received: by bkbzt19 with SMTP id zt19so2163185bkb.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 07:08:31 -0700 (PDT)
In-Reply-To: <1319032638.1286.7.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 15:57 +0200, Johannes Berg a =C3=A9c=
rit :
> On Wed, 2011-10-19 at 15:44 +0200, Eric Dumazet wrote:
> > Le mercredi 19 octobre 2011 =C3=A0 15:35 +0200, Johannes Berg a =C3=
=A9crit :
> >=20
> > > Even with that fixed I'm not really convinced of it all -- need t=
o
> > > really really really make sure that no skb->sk that was owned by =
a TX
> > > skb is ever passed to sock_hold(). Can we really guarantee that?
> >=20
> > Either we can guarantee that, or kernel is a piece of crap, all bet=
s are
> > off.
>=20
> Fair enough :-)
>=20
> > Yes, we need to make an audit, since we assumed sock_hold() was the
> > right thing to do in all contexts.
>=20
> Ok.
>=20
> Anyway, I guess you agree that the patches as-is aren't actually the
> right solution since we can't sock_hold() a TX skb socket reference?

Yes, the sock_hold() could be changed by an atomic_inc_not_zero()

What about doing this ?

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 54fc413..79f337c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -420,7 +420,7 @@ struct phy_driver {
=20
 	/*
 	 * Requests a Tx timestamp for 'skb'. The phy driver promises
-	 * to deliver it to the socket's error queue as soon as a
+	 * to deliver it using skb_complete_tx_timestamp() as soon as a
 	 * timestamp becomes available. One of the PTP_CLASS_ values
 	 * is passed in 'type'.
 	 */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8bd383c..0f96646 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2020,8 +2020,13 @@ static inline bool skb_defer_rx_timestamp(struct=
 sk_buff *skb)
 /**
  * skb_complete_tx_timestamp() - deliver cloned skb with tx timestamps
  *
+ * PHY drivers may accept clones of transmitted packets for
+ * timestamping via their phy_driver.txtstamp method. These drivers
+ * must call this function to return the skb back to the stack, with
+ * or without a timestamp.
+ *
  * @skb: clone of the the original outgoing packet
- * @hwtstamps: hardware time stamps
+ * @hwtstamps: hardware time stamps, may be NULL if not available
  *
  */
 void skb_complete_tx_timestamp(struct sk_buff *skb,
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 98a5264..82fb288 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -57,9 +57,13 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 	case PTP_CLASS_V2_VLAN:
 		phydev =3D skb->dev->phydev;
 		if (likely(phydev->drv->txtstamp)) {
+			if (!atomic_inc_not_zero(&sk->sk_refcnt))
+				return;
 			clone =3D skb_clone(skb, GFP_ATOMIC);
-			if (!clone)
+			if (!clone) {
+				sock_put(sk);
 				return;
+			}
 			clone->sk =3D sk;
 			phydev->drv->txtstamp(phydev, clone, type);
 		}
@@ -77,8 +81,11 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	struct sock_exterr_skb *serr;
 	int err;
=20
-	if (!hwtstamps)
+	if (!hwtstamps) {
+		sock_put(sk);
+		kfree_skb(skb);
 		return;
+	}
=20
 	*skb_hwtstamps(skb) =3D *hwtstamps;
 	serr =3D SKB_EXT_ERR(skb);
@@ -87,6 +94,7 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	serr->ee.ee_origin =3D SO_EE_ORIGIN_TIMESTAMPING;
 	skb->sk =3D NULL;
 	err =3D sock_queue_err_skb(sk, skb);
+	sock_put(sk);
 	if (err)
 		kfree_skb(skb);
 }
