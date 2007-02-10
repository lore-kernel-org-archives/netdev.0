From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC][PATCH][IPSEC][2/3] IPv6 over IPv4 IPsec tunnel
Date: Sat, 10 Feb 2007 12:25:33 +0900
Message-ID: <200702101225.33939.nakam@linux-ipv6.org>
References: <20061229144712.e154b021.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_tsTzFYWf2l7sUYo"
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:43966 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752939AbXBJD3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 22:29:18 -0500
In-Reply-To: <20061229144712.e154b021.kazunori@miyazawa.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_tsTzFYWf2l7sUYo
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

Kazunori MIYAZAWA wrote:
> This is the patch to support IPv6 over IPv4 IPsec
> 
> Signed-off-by: Miika Komu <miika@iki.fi>
> Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
> Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>


This seems to break Mobile IPv6 route optimization (RO).
(This patch is commited as c82f963efe823d3cacaf1f1b7f1a35cc9628b188
 to David's tree.)

Please find my comment below.


> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index 8dffd4d..a1ac537 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -131,13 +131,11 @@ __xfrm6_bundle_create(struct xfrm_policy
>  	struct dst_entry *dst, *dst_prev;
>  	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
>  	struct rt6_info *rt  = rt0;
> -	struct in6_addr *remote = &fl->fl6_dst;
> -	struct in6_addr *local  = &fl->fl6_src;
>  	struct flowi fl_tunnel = {
>  		.nl_u = {
>  			.ip6_u = {
> -				.saddr = *local,
> -				.daddr = *remote
> +				.saddr = fl->fl6_src,
> +				.daddr = fl->fl6_dst,
>  			}
>  		}
>  	};
> @@ -153,7 +151,6 @@ __xfrm6_bundle_create(struct xfrm_policy
>  	for (i = 0; i < nx; i++) {
>  		struct dst_entry *dst1 = dst_alloc(&xfrm6_dst_ops);
>  		struct xfrm_dst *xdst;
> -		int tunnel = 0;
>  
>  		if (unlikely(dst1 == NULL)) {
>  			err = -ENOBUFS;
> @@ -177,19 +174,27 @@ __xfrm6_bundle_create(struct xfrm_policy
>  
>  		dst1->next = dst_prev;
>  		dst_prev = dst1;
> -		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
> -			remote = __xfrm6_bundle_addr_remote(xfrm[i], remote);
> -			local  = __xfrm6_bundle_addr_local(xfrm[i], local);
> -			tunnel = 1;
> -		}
> +
>  		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
>  		trailer_len += xfrm[i]->props.trailer_len;
>  
> -		if (tunnel) {
> -			ipv6_addr_copy(&fl_tunnel.fl6_dst, remote);
> -			ipv6_addr_copy(&fl_tunnel.fl6_src, local);
> -			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
> -					      &fl_tunnel, AF_INET6);
> +		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
> +			unsigned short encap_family = xfrm[i]->props.family;
> +			switch(encap_family) {
> +			case AF_INET:
> +				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
> +				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
> +				break;
> +			case AF_INET6:
> +				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr*)&xfrm[i]->id.daddr.a6);
> +				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr*)&xfrm[i]->props.saddr.a6);
> +				break;
> +			default:
> +				BUG_ON(1);
> +			}
> +
> + 			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
> +					      &fl_tunnel, encap_family);
>  			if (err)
>  				goto error;
>  		} else


You missed RO mode path when you changed semantics to check the mode
from "xfrm[i]->props.mode != XFRM_MODE_TRANSPORT"
to "xfrm[i]->props.mode == XFRM_MODE_TUNNEL" before
changing address. Your patch also makes two incline functions
__xfrm6_bundle_addr_{remote,local} are used by nobody.

I suggest a fix to add "|| xfrm[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION" there
to make it clearer for other developers about RO-is-there than restoring the code.

# FYI, we don't have to fix another side of inter-family IPsec tunneling (xfrm4_policy.c)
# where you have similar patch (IPv4 over IPv6 IPsec tunnel) because the RO
# is used only for the case of "IPv6 flow and IPv6 extension headers".

Please give me comments for the attached patch.
I hope it will be applied (or replaced the original patch with including mine).


Regards,

-- 
Masahide NAKAMURA


--Boundary-00=_tsTzFYWf2l7sUYo
Content-Type: text/plain;
  charset="iso-2022-jp";
  name="0001-PATCH-XFRM-IPV6-Fix-outbound-RO-transformation-which-is-broken-by-IPsec-tunnel-patch.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-PATCH-XFRM-IPV6-Fix-outbound-RO-transformation-which-is-broken-by-IPsec-tunnel-patch.txt"

=46rom ce9f1ac8c8df22b462a15d4609d05ec939930208 Mon Sep 17 00:00:00 2001
=46rom: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 10 Feb 2007 11:48:49 +0900
Subject: [PATCH][XFRM] IPV6: Fix outbound RO transformation which is broken=
 by IPsec tunnel patch.

It seems to miss RO mode path by IPv6 over IPv4 IPsec tunnel patch
when it changed semantics to check the mode from
"xfrm[i]->props.mode !=3D XFRM_MODE_TRANSPORT" to
"xfrm[i]->props.mode =3D=3D XFRM_MODE_TUNNEL" before changing address.
It also makes two incline functions __xfrm6_bundle_addr_{remote,local}
are used by nobody.

This patch fixes it.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
=2D--
 net/ipv6/xfrm6_policy.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 59480e9..54e2fd0 100644
=2D-- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -178,7 +178,8 @@ __xfrm6_bundle_create(struct xfrm_policy
 		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
 		trailer_len +=3D xfrm[i]->props.trailer_len;
=20
=2D		if (xfrm[i]->props.mode =3D=3D XFRM_MODE_TUNNEL) {
+		if (xfrm[i]->props.mode =3D=3D XFRM_MODE_TUNNEL ||
+		    xfrm[i]->props.mode =3D=3D XFRM_MODE_ROUTEOPTIMIZATION) {
 			unsigned short encap_family =3D xfrm[i]->props.family;
 			switch(encap_family) {
 			case AF_INET:
@@ -186,8 +187,9 @@ __xfrm6_bundle_create(struct xfrm_policy
 				fl_tunnel.fl4_src =3D xfrm[i]->props.saddr.a4;
 				break;
 			case AF_INET6:
=2D				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr*)&xfrm[i]->id.da=
ddr.a6);
=2D				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr*)&xfrm[i]->props=
=2Esaddr.a6);
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i],=
 &fl->fl6_dst));
+
+				ipv6_addr_copy(&fl_tunnel.fl6_src, __xfrm6_bundle_addr_remote(xfrm[i],=
 &fl->fl6_src));
 				break;
 			default:
 				BUG_ON(1);
=2D-=20
1.4.2


--Boundary-00=_tsTzFYWf2l7sUYo--
