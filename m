From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] xfrm: Simplify SA looking up when using wildcard source address
Date: Mon, 23 Sep 2013 17:18:37 +0800
Message-ID: <1379927917-17365-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64760 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab3IWJSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 05:18:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not quite sure I get this "wildcard source address" right,
IMHO if a host needs to protect every traffic for a given remote host,
then the source address is wildcard address, i.e. all ZEROs.
(Please correct me if I'm bloodly wrong=E3=80=82=E3=80=82=E3=80=82)

Here is the argument if above statement stands true:
__xfrm4/6_state_addr_check is a four steps check, all we need to do
is checking whether the destination address match. Passing saddr from
flow is worst option, as the checking needs to reach the fourth step.

So, simply this process by only checking destination address only when
using wildcard source address for looking up SAs.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h    |   31 +++++++++++++++++++++++++++++++
 net/xfrm/xfrm_state.c |    2 +-
 2 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e253bf0..fdb9343 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1282,6 +1282,37 @@ xfrm_state_addr_check(const struct xfrm_state *x=
,
 }
=20
 static __inline__ int
+__xfrm4_state_daddr_check(const struct xfrm_state *x,
+                                const xfrm_address_t *daddr)
+{
+        return ((daddr->a4 =3D=3D x->id.daddr.a4) ? 1 : 0);
+}
+
+static __inline__ int
+__xfrm6_state_daddr_check(const struct xfrm_state *x,
+                         const xfrm_address_t *daddr)
+{
+        if (ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr=
 *)&x->id.daddr))
+                return 1;
+        else=20
+                return 0;
+}
+
+static __inline__ int
+xfrm_state_daddr_check(const struct xfrm_state *x,
+                      const xfrm_address_t *daddr,
+                      unsigned short family)
+{
+        switch (family) {
+        case AF_INET:
+                return __xfrm4_state_daddr_check(x, daddr);
+        case AF_INET6:
+                return __xfrm6_state_daddr_check(x, daddr);
+        }   =20
+        return 0;
+}
+
+static __inline__ int
 xfrm_state_addr_flow_check(const struct xfrm_state *x, const struct fl=
owi *fl,
 			   unsigned short family)
 {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e1373d5..87c99da 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -824,7 +824,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const =
xfrm_address_t *saddr,
 		    x->props.reqid =3D=3D tmpl->reqid &&
 		    (mark & x->mark.m) =3D=3D x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
-		    xfrm_state_addr_check(x, daddr, saddr, encap_family) &&
+		    xfrm_state_daddr_check(x, daddr, encap_family) &&
 		    tmpl->mode =3D=3D x->props.mode &&
 		    tmpl->id.proto =3D=3D x->id.proto &&
 		    (tmpl->id.spi =3D=3D x->id.spi || !tmpl->id.spi))
--=20
1.7.9.5
