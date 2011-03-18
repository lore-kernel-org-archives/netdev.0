From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN over GRE segfault
Date: Fri, 18 Mar 2011 11:27:27 +0100
Message-ID: <1300444047.2888.18.camel@edumazet-laptop>
References: <4D830AF9.8040007@diddi.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>
To: Diddi Oscarsson <diddi@diddi.se>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63463 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab1CRK1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 06:27:33 -0400
Received: by fxm17 with SMTP id 17so3533317fxm.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 03:27:32 -0700 (PDT)
In-Reply-To: <4D830AF9.8040007@diddi.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mars 2011 =C3=A0 08:34 +0100, Diddi Oscarsson a =C3=A9cr=
it :
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Hello!
>=20
> I was trying to get ethernet over GRE to work when I found an obvious
> way NOT to do it.
> Basically I created a VLAN interface from the GRE interface (even
> though I had my fair doubts it would work) which gave me a nice segfa=
ult.
> The problem with this is that after the segfault, new network
> connections cannot be made (ping, ssh, http, whatever) and a reboot o=
f
> the computer is necessary.
> I think an error message needs to be added when trying an operation
> like this.
>=20
> My system:
> Linux colalapp 2.6.37-2-amd64 #1 SMP Sun Feb 27 10:12:22 UTC 2011
> x86_64 GNU/Linux
> ip utility, iproute2-ss110107
> Debian unstable
>=20
> Steps to reproduce:
> ip tunnel add gre0 mode gre
> ip link add link gre0 name vlan1 type vlan id 1
> ip link set vlan1 address 00:15:14:13:12:11
> ip link set gre0 up
> ip link set vlan1 up
> <CRASH>
> Attached in the mail is an output from dmesg right after the segfault=
=2E
>=20
> Regarding ethernet over gre, I've just found out about gretap which
> I'm testing right now.

Hi Diddi

It might be a 2.6.28 regression, after commit c95b819ad7
(gre: Use needed_headroom)

Thanks

[PATCH] vlan: should take into account needed_headroom

Commit c95b819ad7 (gre: Use needed_headroom)
made gre use needed_headroom instead of hard_header_len

This uncover a bug in vlan code.

We should make sure vlan devices take into account their
real_dev->needed_headroom or we risk a crash in ipgre_header(), because
we dont have enough room to push IP header in skb.

Reported-by: Diddi Oscarsson <diddi@diddi.se>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/8021q/vlan_dev.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ae610f0..e34ea9e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -720,6 +720,7 @@ static int vlan_dev_init(struct net_device *dev)
 	dev->fcoe_ddp_xid =3D real_dev->fcoe_ddp_xid;
 #endif
=20
+	dev->needed_headroom =3D real_dev->needed_headroom;
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      =3D real_dev->header_ops;
 		dev->hard_header_len =3D real_dev->hard_header_len;


