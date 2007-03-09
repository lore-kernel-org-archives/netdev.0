From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/2] [IPV6]: Ensure to truncate result and return full length for sticky options.
Date: Fri, 9 Mar 2007 15:44:35 -0800
Message-ID: <20070309234435.GE7920@sequoia.sous-sol.org>
References: <20070309.101328.78855655.yoshfuji@linux-ipv6.org> <20070308.204845.125566290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, chrisw@sous-sol.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:37905 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767665AbXCIXoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 18:44:01 -0500
Content-Disposition: inline
In-Reply-To: <20070308.204845.125566290.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller (davem@davemloft.net) wrote:
> From: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshf=
uji@linux-ipv6.org>
> Date: Fri, 09 Mar 2007 10:13:28 +0900 (JST)
>=20
> > Bug noticed by Chris Wright <chrisw@sous-sol.org>.
> >=20
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> Applied, thanks a lot.

Crud, I should have noticed this earlier.  This has a problem, min_t(in=
t)
means user supplied < 0 is a large copy_to_user (back to leaking memory
on arch's that don't protect < 0 copy_to_user like i386 does).  Here's
a simple fix ontop of yoshifuji's two changes.  Hope that's it ;-)

thanks,
-chris
--

=46rom: Chris Wright <chrisw@sous-sol.org>
Subject: [IPV6] fix ipv6_getsockopt_sticky copy_to_user leak

User supplied len < 0 can cause leak of kernel memory.
Use unsigned compare instead.

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 net/ipv6/ipv6_sockglue.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a4f06ce..321287b 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -824,7 +824,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, =
struct ipv6_txoptions *opt,
 	if (!hdr)
 		return 0;
=20
-	len =3D min_t(int, len, ipv6_optlen(hdr));
+	len =3D min_t(unsigned, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, len));
 		return -EFAULT;
 	return ipv6_optlen(hdr);
