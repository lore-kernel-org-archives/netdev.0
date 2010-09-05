From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Sun, 05 Sep 2010 19:43:55 +0200
Message-ID: <1283708635.3402.100.camel@edumazet-laptop>
References: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55993 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0IERoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 13:44:03 -0400
Received: by fxm13 with SMTP id 13so2160298fxm.19
        for <netdev@vger.kernel.org>; Sun, 05 Sep 2010 10:44:01 -0700 (PDT)
In-Reply-To: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 septembre 2010 =C3=A0 01:18 +0800, Changli Gao a =C3=A9crit=
 :
> af_packet uses tpacket_destruct_skb() to notify its user a frame is
> sent out through NIC, and the memory for that frame is available for
> the others. If the driver calls skb_orphan() before the frame is sent
> out successfully, and the user may fill other data into the space for
> this frame, this frame will be corrupted. It became more likely after
> skb_try_orphan() was added into dev_hard_start_xmit().
>=20
> Am I correct?
>=20

Yes good catch. We might add a :

SKBTX_NO_EARLY_ORPHAN =3D 1 << 4,

so that skb_orphan_try() do not early orphan this kind of skb


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f900ffc..9c1a480 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -176,6 +176,9 @@ enum {
=20
 	/* ensure the originating sk reference is available on driver level *=
/
 	SKBTX_DRV_NEEDS_SK_REF =3D 1 << 3,
+
+	/* dont early orphan this skb in skb_orphan_try() */
+	SKBTX_NO_EARLY_ORPHAN =3D 1 << 4,
 };
=20
 /* This data is invariant across clones and lives at
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3616f27..306795d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1029,6 +1029,7 @@ static int tpacket_snd(struct packet_sock *po, st=
ruct msghdr *msg)
 		}
=20
 		skb->destructor =3D tpacket_destruct_skb;
+		skb_shinfo(skb)->tx_flags |=3D SKBTX_NO_EARLY_ORPHAN;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		atomic_inc(&po->tx_ring.pending);
=20


