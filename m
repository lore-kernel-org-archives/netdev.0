From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: Re: [PATCH net v2 0/3] Tunneling fixes
Date: Tue, 18 Oct 2016 18:03:28 +0200
Message-ID: <2320b0ab-b48c-292a-52d0-8e2db3ccf521@hpe.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lUcBAcbRphpWalkuEw3DnqGr4QLAlSMBr"
Cc: netdev@vger.kernel.org, Juerg Haefliger <juerg.haefliger@hpe.com>
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:55144 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936072AbcJRQDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 12:03:39 -0400
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com [15.233.44.25])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 961EB1C72
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 16:03:32 +0000 (UTC)
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lUcBAcbRphpWalkuEw3DnqGr4QLAlSMBr
Content-Type: multipart/mixed; boundary="GCScLJxnu6UFuqsBcQFmONXW6T1wdOJTc";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: jesse@kernel.org
Cc: netdev@vger.kernel.org, Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <2320b0ab-b48c-292a-52d0-8e2db3ccf521@hpe.com>
Subject: Re: [PATCH net v2 0/3] Tunneling fixes

--GCScLJxnu6UFuqsBcQFmONXW6T1wdOJTc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> This series fixes a problem that was reported where encapsulated packet=
s
> do not have their encapsulation offload markers stripped off when being=

> decapsulated. This causes a significant performance drop if the packets=

> are later retransmitted.
>
> Fixing this revealed two other bugs which are also addressed as prerequ=
isites:
>  * GRO can aggregate packets for multiple layers of encapsulation which=
 the
>    stack cannot properly handle.
>  * IPIP packets which are combined by GRO are not marked properly with =
their
>    GSO type.
>
> Note that this is based off the net-next tree as the current target for=

> bug fixes.

I need to backport this series to the 4.4 kernel to fix a performance iss=
ue we're seeing. The series
applies but commit a09a4c8dd1ec (tunnels: Remove encapsulation offloads o=
n decap) breaks compilation
when CONFIG_IPV6_SIT is enabled. This is because the patch uses iptunnel_=
pull_header() whose usage
changed with commit 7f290c94352e (iptunnel: scrub packet in iptunnel_pull=
_header) which is not in 4.4.

7f290c94352e seems to be a cleanup patch which also requires c9e78efb6f66=
 (vxlan: move vxlan device
lookup before iptunnel_pull_header) and potentially others. Rather than p=
ulling in a slew of cleanup
patches, I was wondering if the following from commit a09a4c8dd1ec can be=
 rewritten without using
the 'new' iptunnel_pull_header() function:

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index f45b8ffc2840..83384308d032 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -681,14 +681,16 @@ static int ipip6_rcv(struct sk_buff *skb)
                skb->mac_header =3D skb->network_header;
                skb_reset_network_header(skb);
                IPCB(skb)->flags =3D 0;
-               skb->protocol =3D htons(ETH_P_IPV6);
+               skb->dev =3D tunnel->dev;

                if (packet_is_spoofed(skb, iph, tunnel)) {
                        tunnel->dev->stats.rx_errors++;
                        goto out;
                }

-               __skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
+               if (iptunnel_pull_header(skb, 0, htons(ETH_P_IPV6),
+                   !net_eq(tunnel->net, dev_net(tunnel->dev))))
+                       goto out;


Thanks
=2E..Juerg


> v2: No code changes, just additional information in commit messages and=

>     a new cover letter.
>
> Jesse Gross (3):
>   ipip: Properly mark ipip GRO packets as encapsulated.
>   tunnels: Don't apply GRO to multiple layers of encapsulation.
>   tunnels: Remove encapsulation offloads on decap.
>
>  include/linux/netdevice.h |  4 ++--
>  include/net/ip_tunnels.h  | 16 ++++++++++++++++
>  net/core/dev.c            |  2 +-
>  net/ipv4/af_inet.c        | 24 ++++++++++++++++++++++--
>  net/ipv4/fou.c            | 13 +++++++++++--
>  net/ipv4/gre_offload.c    |  5 +++++
>  net/ipv4/ip_tunnel_core.c |  3 ++-
>  net/ipv4/udp_offload.c    |  6 +++---
>  net/ipv6/ip6_offload.c    | 15 ++++++++++++++-
>  net/ipv6/sit.c            |  6 ++++--
>  10 files changed, 80 insertions(+), 14 deletions(-)


--GCScLJxnu6UFuqsBcQFmONXW6T1wdOJTc--

--lUcBAcbRphpWalkuEw3DnqGr4QLAlSMBr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYBkfQAAoJEHVMOpb5+LSMHL0P/3w2M+F/N+5UGQM8nEwlqwPY
EuLzAcu4m3Vr9lUzCOZWrP8X1HM+DeQqvf+2TR69rFa82cSE1pNEaUclqFYMxd62
guDwzlR4ETrt2QqexxNE1SDL2r4poCR+yK7ptbnkEfrWMeVjJlPaswnilnsuoWNK
IgpughZMLp4KrFnvNl29rekvk6WdiEuKe+pLfe0vO0VxsHUt+LIvgMEC2ARp8iHP
LqKflxfSodHeqad3PGcoIQAIT1LwpnI1Z4tWXIYJjlrT9OLpguWcrgKpIUj1Lw++
N7rOFzasjjd2UZwDigSRLV73J6vn1tJHigBcvPvw0js/DhJIjA32CYOe0XzaW7Tr
Ov5JlES7J/jQywYHZ5ZCGgYItQgWrhur4/vTDbJ0K/Xl9LgeR+ZaZu2EWH22Jeqy
YnVXYHHaFJB7gmumYbpH/YD0F/74uOy+HLC06saKmz5Up+UTwXWZPH8/MD7xqK0f
2S7VfqHnFE29YtvYcRzeIXe/d52J+AWUQHX9EBFmafMKLGR9R+dn7x0jwH3hAQy4
ukzaLS42l742DQEsziaZJ6KO2mDYqORXQc+sVzSs1eVi31DFsVhv+pihFD1M28sn
OR7k6a2ltYMjx9jX6AyZEhmtY83vWRwgaU9xt6LpT4fx9fE7IQQQ6WfxSt10tCDD
hHPLuvSnOiBtJ1kHL5nQ
=zof3
-----END PGP SIGNATURE-----

--lUcBAcbRphpWalkuEw3DnqGr4QLAlSMBr--
