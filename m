From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Tue, 27 Jan 2015 12:58:15 +0100
Message-ID: <20150127115814.GL13046@secunet.com>
References: <5487DD65.60800@gtsys.com.hk>
 <549AC2B4.8070203@gtsys.com.hk>
 <1420560073.32369.60.camel@redhat.com>
 <20150126083512.GI13046@secunet.com>
 <54C71AFB.40300@gtsys.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58336 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbbA0L6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 06:58:25 -0500
Content-Disposition: inline
In-Reply-To: <54C71AFB.40300@gtsys.com.hk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 12:58:35PM +0800, Chris Ruehl wrote:
>=20
>    Steffen,
>=20
>    your patch can't apply to the vanilla v3.14.29 can you cross check=
 please.

Sorry, this patch was based on the net tree.

>    I'm sorry but we running a productive system and I can't make to m=
uch
>    noise here!
>    Your patch is partly in the 3.14.29 and
>    skb->protocol =3D htons(ETH_P_IP)
>    from the xfrm4/6_output_finish() no removed. I do then
>=20
>    --- linux-3.14.x/net/ipv4/xfrm4_output.c.orig=A0=A0=A0 2015-01-27
>    12:50:01.830651344 +0800
>    +++ linux-3.14.x/net/ipv4/xfrm4_output.c=A0=A0=A0 2015-01-27 12:51=
:13.280386355
>    +0800
>    @@ -82,7 +82,6 @@
>    =A0=A0=A0=A0 IPCB(skb)->flags |=3D IPSKB_XFRM_TRANSFORMED;
>    =A0#endif
>    =A0
>    -=A0=A0=A0 skb->protocol =3D htons(ETH_P_IP);
>    =A0=A0=A0=A0 return xfrm_output(skb);
>    =A0}
>    =A0
>    --- linux-3.14.x/net/ipv6/xfrm6_output.c.orig=A0=A0=A0 2015-01-27
>    12:49:39.260735321 +0800
>    +++ linux-3.14.x/net/ipv6/xfrm6_output.c=A0=A0=A0 2015-01-27 12:50=
:47.280482636
>    +0800
>    @@ -132,7 +132,6 @@
>    =A0=A0=A0=A0 IP6CB(skb)->flags |=3D IP6SKB_XFRM_TRANSFORMED;
>    =A0#endif
>    =A0
>    -=A0=A0=A0 skb->protocol =3D htons(ETH_P_IPV6);
>    =A0=A0=A0=A0 return xfrm_output(skb);
>    =A0}

Yes, that should be ok. Here is the complete patch for v3.14.29:

Subject: [PATCH RFC v3.14.29] xfrm: Fix local error reporting crash wit=
h interfamily tunnels

We set the outer mode protocol too early. As a result, the
local error handler might dispatch to the wrong address family
and report the error to a wrong socket type. We fix this by
seting the outer protocol to the skb only after we accessed the
inner mode for the last time, right before we do the atcual
encapsulation where we switch finally to the outer mode.
The settings in xfrm{4,6}_output_finish() are removed.

Reported-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_output.c |    1 -
 net/ipv6/xfrm6_output.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index baa0f63..0cb9606 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -82,7 +82,6 @@ int xfrm4_output_finish(struct sk_buff *skb)
 	IPCB(skb)->flags |=3D IPSKB_XFRM_TRANSFORMED;
 #endif
=20
-	skb->protocol =3D htons(ETH_P_IP);
 	return xfrm_output(skb);
 }
=20
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6cd625e..98396cf 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -132,7 +132,6 @@ int xfrm6_output_finish(struct sk_buff *skb)
 	IP6CB(skb)->flags |=3D IP6SKB_XFRM_TRANSFORMED;
 #endif
=20
-	skb->protocol =3D htons(ETH_P_IPV6);
 	return xfrm_output(skb);
 }
=20
--=20
1.7.2.5
