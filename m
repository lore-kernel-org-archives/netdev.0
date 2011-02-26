From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] be2net: add rxhash support
Date: Sat, 26 Feb 2011 11:30:30 +0100
Message-ID: <1298716230.8726.18.camel@edumazet-laptop>
References: <20110225213542.GA11773@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51909 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab1BZKaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 05:30:39 -0500
Received: by bwz15 with SMTP id 15so2584222bwz.19
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 02:30:38 -0800 (PST)
In-Reply-To: <20110225213542.GA11773@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 15:35 -0600, Ajit Khaparde a =C3=
=A9crit :

> I asked that because, if a switch is part a of the configuration,
> the ASIC can receive packets other than the tcp flow.
>=20
> And if hashing is enabled for IP packets, we can see this behavior.
> The other values indicate that hashing has been enabled for IPv4 pack=
ets.

To make sure RSS (and rxhash) was OK, I added following debugging aid :

diff --git a/include/net/sock.h b/include/net/sock.h
index da0534d..e9b1180 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -688,6 +688,7 @@ static inline void sock_rps_save_rxhash(struct sock=
 *sk, u32 rxhash)
 {
 #ifdef CONFIG_RPS
 	if (unlikely(sk->sk_rxhash !=3D rxhash)) {
+		pr_err("rxhash change from %x to %x\n", sk->sk_rxhash, rxhash);
 		sock_rps_reset_flow(sk);
 		sk->sk_rxhash =3D rxhash;
 	}


And got following traces :

[  201.170297] change rxhash from 0 to be0b5a87
[  232.607474] bonding: bond1: Setting eth3 as active slave.
[  232.607478] bonding: bond1: making interface eth3 the new active one=
=2E
[  232.710848] change rxhash from be0b5a87 to e56a3c1e
[  300.047500] bonding: bond1: Setting eth1 as active slave.
[  300.047504] bonding: bond1: making interface eth1 the new active one=
=2E
[  300.159162] change rxhash from e56a3c1e to be0b5a87

The flip occured when I changed my active slave (bonding mode=3D1).

eth1 is a bnx2 NIC, while eth3 a be2net one, so its OK to change the rx=
hash in this case=20
(different firmware/algo)

So as far as be2net is concerned, everything seems OK : all packets for=
=20
a given flow get an unique RSS hash and can feed skb->rxhash



