From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 15:36:26 +0100
Message-ID: <1330007786.15610.26.camel@edumazet-laptop>
References: <bug-42809-100@https.bugzilla.kernel.org/>
	   <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
	   <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it>
	  <1329961083.15610.2.camel@edumazet-laptop>
	  <4F459E37.9010507@linuxsystems.it>
	 <1329962785.15610.8.camel@edumazet-laptop>
	 <4F46430D.3060802@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: =?ISO-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57016 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab2BWOge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 09:36:34 -0500
Received: by werb13 with SMTP id b13so789898wer.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 06:36:33 -0800 (PST)
In-Reply-To: <4F46430D.3060802@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Your patch does solve the problem, thanks!
>=20

Thanks for testing.

Here is the official patch I submit for review then.

[PATCH] ipsec: be careful of non existing mac headers

Nicollo Belli reported ipsec crashes in case we handle a frame without
mac header (atm in his case)

Before copying mac header, better make sure it is present.

Bugzilla reference:  https://bugzilla.kernel.org/show_bug.cgi?id=3D4280=
9

Reported-by: Niccol=C3=B2 Belli <darkbasic@linuxsystems.it>
Tested-by: Niccol=C3=B2 Belli <darkbasic@linuxsystems.it>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/xfrm4_mode_beet.c   |    9 +++++----
 net/ipv4/xfrm4_mode_tunnel.c |   10 ++++++----
 net/ipv6/xfrm6_mode_beet.c   |    9 +++++----
 net/ipv6/xfrm6_mode_tunnel.c |   10 ++++++----
 4 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 6341818..d3451f6 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -111,10 +111,11 @@ static int xfrm4_beet_input(struct xfrm_state *x,=
 struct sk_buff *skb)
 	skb_push(skb, sizeof(*iph));
 	skb_reset_network_header(skb);
=20
-	memmove(skb->data - skb->mac_len, skb_mac_header(skb),
-		skb->mac_len);
-	skb_set_mac_header(skb, -skb->mac_len);
-
+	if (skb_mac_header_was_set(skb)) {
+		memmove(skb->data - skb->mac_len, skb_mac_header(skb),
+			skb->mac_len);
+		skb_set_mac_header(skb, -skb->mac_len);
+	}
 	xfrm4_beet_make_header(skb);
=20
 	iph =3D ip_hdr(skb);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.=
c
index 534972e..a646f30 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -66,7 +66,6 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state=
 *x, struct sk_buff *skb)
=20
 static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buf=
f *skb)
 {
-	const unsigned char *old_mac;
 	int err =3D -EINVAL;
=20
 	if (XFRM_MODE_SKB_CB(skb)->protocol !=3D IPPROTO_IPIP)
@@ -84,9 +83,12 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state=
 *x, struct sk_buff *skb)
 	if (!(x->props.flags & XFRM_STATE_NOECN))
 		ipip_ecn_decapsulate(skb);
=20
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	if (skb_mac_header_was_set(skb)) {
+		const unsigned char *old_mac =3D skb_mac_header(skb);
+
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 	skb_reset_network_header(skb);
 	err =3D 0;
=20
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index a81ce94..74c4b92 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -80,7 +80,6 @@ static int xfrm6_beet_output(struct xfrm_state *x, st=
ruct sk_buff *skb)
 static int xfrm6_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *ip6h;
-	const unsigned char *old_mac;
 	int size =3D sizeof(struct ipv6hdr);
 	int err;
=20
@@ -91,10 +90,12 @@ static int xfrm6_beet_input(struct xfrm_state *x, s=
truct sk_buff *skb)
 	__skb_push(skb, size);
 	skb_reset_network_header(skb);
=20
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	if (skb_mac_header_was_set(skb)) {
+		const unsigned char *old_mac =3D skb_mac_header(skb);
=20
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 	xfrm6_beet_make_header(skb);
=20
 	ip6h =3D ipv6_hdr(skb);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.=
c
index 261e6e6..edb7091 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -63,7 +63,6 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state=
 *x, struct sk_buff *skb)
 static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buf=
f *skb)
 {
 	int err =3D -EINVAL;
-	const unsigned char *old_mac;
=20
 	if (XFRM_MODE_SKB_CB(skb)->protocol !=3D IPPROTO_IPV6)
 		goto out;
@@ -80,9 +79,12 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state=
 *x, struct sk_buff *skb)
 	if (!(x->props.flags & XFRM_STATE_NOECN))
 		ipip6_ecn_decapsulate(skb);
=20
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	if (skb_mac_header_was_set(skb)) {
+		const unsigned char *old_mac =3D skb_mac_header(skb);
+
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 	skb_reset_network_header(skb);
 	err =3D 0;
=20
