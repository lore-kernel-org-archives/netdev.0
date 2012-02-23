From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V2] ipsec: be careful of non existing mac headers
Date: Thu, 23 Feb 2012 21:55:02 +0100
Message-ID: <1330030502.15610.44.camel@edumazet-laptop>
References: <1330007786.15610.26.camel@edumazet-laptop>
	 <20120223.151115.1646872434333284038.davem@davemloft.net>
	 <1330028243.15610.40.camel@edumazet-laptop>
	 <20120223.152314.1111200746248162115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64922 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756998Ab2BWUzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 15:55:11 -0500
Received: by wgbdt10 with SMTP id dt10so1449186wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 12:55:09 -0800 (PST)
In-Reply-To: <20120223.152314.1111200746248162115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Niccolo Belli reported ipsec crashes in case we handle a frame without
mac header (atm in his case)

Before copying mac header, better make sure it is present.

Bugzilla reference:  https://bugzilla.kernel.org/show_bug.cgi?id=3D4280=
9

Reported-by: Niccol=C3=B2 Belli <darkbasic@linuxsystems.it>
Tested-by: Niccol=C3=B2 Belli <darkbasic@linuxsystems.it>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: added skb_mac_header_rebuild() helper as David suggested.

 include/linux/skbuff.h       |   10 ++++++++++
 net/ipv4/xfrm4_mode_beet.c   |    5 +----
 net/ipv4/xfrm4_mode_tunnel.c |    6 ++----
 net/ipv6/xfrm6_mode_beet.c   |    6 +-----
 net/ipv6/xfrm6_mode_tunnel.c |    6 ++----
 5 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 50db9b0..ae86ade 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1465,6 +1465,16 @@ static inline void skb_set_mac_header(struct sk_=
buff *skb, const int offset)
 }
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
=20
+static inline void skb_mac_header_rebuild(struct sk_buff *skb)
+{
+	if (skb_mac_header_was_set(skb)) {
+		const unsigned char *old_mac =3D skb_mac_header(skb);
+
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
+}
+
 static inline int skb_checksum_start_offset(const struct sk_buff *skb)
 {
 	return skb->csum_start - skb_headroom(skb);
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 6341818..e3db3f9 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -110,10 +110,7 @@ static int xfrm4_beet_input(struct xfrm_state *x, =
struct sk_buff *skb)
=20
 	skb_push(skb, sizeof(*iph));
 	skb_reset_network_header(skb);
-
-	memmove(skb->data - skb->mac_len, skb_mac_header(skb),
-		skb->mac_len);
-	skb_set_mac_header(skb, -skb->mac_len);
+	skb_mac_header_rebuild(skb);
=20
 	xfrm4_beet_make_header(skb);
=20
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.=
c
index 534972e..ed4bf11 100644
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
@@ -84,10 +83,9 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state=
 *x, struct sk_buff *skb)
 	if (!(x->props.flags & XFRM_STATE_NOECN))
 		ipip_ecn_decapsulate(skb);
=20
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
 	skb_reset_network_header(skb);
+	skb_mac_header_rebuild(skb);
+
 	err =3D 0;
=20
 out:
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index a81ce94..9949a35 100644
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
@@ -90,10 +89,7 @@ static int xfrm6_beet_input(struct xfrm_state *x, st=
ruct sk_buff *skb)
=20
 	__skb_push(skb, size);
 	skb_reset_network_header(skb);
-
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	skb_mac_header_rebuild(skb);
=20
 	xfrm6_beet_make_header(skb);
=20
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.=
c
index 261e6e6..9f2095b 100644
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
@@ -80,10 +79,9 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state=
 *x, struct sk_buff *skb)
 	if (!(x->props.flags & XFRM_STATE_NOECN))
 		ipip6_ecn_decapsulate(skb);
=20
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
 	skb_reset_network_header(skb);
+	skb_mac_header_rebuild(skb);
+
 	err =3D 0;
=20
 out:
