From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 14:05:24 +0200
Message-ID: <1209643524.3904.5.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mSGq/OzWjJoamPSStMpE"
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:54779 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbYEAMGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 08:06:11 -0400
In-Reply-To: <20080501.034950.261408566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mSGq/OzWjJoamPSStMpE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


> That makes more sense, good catch Herbert.
>=20
> I guess it's the pskb_expand_head() calls done by net/mac80211/tx.c
> I suspect we'll need to orphan early in order to accomodate these
> adjustments, otherwise socket memory buffer allocations will
> be corrupted.
>=20
> Once that is cured, I think we can detect this better, by adding a
> carefully constructed assertion to pskb_expand_head().  Basically, the
> idea is, if "nhead" or "ntail" are non-zero, and there is a socket
> still attached to the SKB, print a warning message.

I'm confused now. I added this patch:

--- everything.orig/net/core/skbuff.c	2008-05-01 13:21:52.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-01 13:29:57.000000000 +0200
@@ -683,6 +683,14 @@ int pskb_expand_head(struct sk_buff *skb
 	if (!data)
 		goto nodata;
=20
+	if (unlikely((nhead || ntail) && skb->sk)) {
+		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
+				"with socket attached\n",
+		       nhead, ntail);
+                dump_stack();
+	} else
+		skb->truesize =3D size + sizeof(struct sk_buff);
+
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void. */
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
--- everything.orig/net/mac80211/tx.c	2008-05-01 13:01:09.000000000 +0200
+++ everything/net/mac80211/tx.c	2008-05-01 13:16:50.000000000 +0200
@@ -1279,6 +1279,8 @@ int ieee80211_master_start_xmit(struct s
 	int headroom;
 	int ret;
=20
+	skb_orphan(skb);
+
 	if (info->flags & IEEE80211_TX_CTL_READY_FOR_TX) {
 		/*
 		 * We set the IEEE80211_TX_CTL_READY_FOR_TX bit in all skbs
@@ -1581,6 +1583,7 @@ int ieee80211_subif_start_xmit(struct sk
 	 * us broadcast frames. */
=20
 	if (head_need > 0 || skb_cloned(skb)) {
+		skb_orphan(skb);
 #if 0
 		printk(KERN_DEBUG "%s: need to reallocate buffer for %d bytes "
 		       "of headroom\n", dev->name, head_need);


and the assertion never triggers, however I get a number of bugs like this:

=EF=BB=BFSKB BUG: Invalid truesize (4294963740) len=3D44, sizeof(sk_buff)=
=3D176, skb=3D0xeecb6620

and definitely cannot explain that number (-3556).

johannes

--=-mSGq/OzWjJoamPSStMpE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmyA6Vg1VMiehFYAQKLKQ/5ARGbyNzzj/ahajOCL67uiiCv9ppV2OV+
ZKgPZyouqXI1nYhFFE/IM1xzD24yxLYP0i/YySIx29RWDRPNnQGUy1/Shx9um9T5
5wriQoku4gFgUenS20lJfc8Sxhfb275pFMfvcdAzCJgPAk1qy8324kFOLs92Oc55
AH1y3CH/p1y/LlyyckJlme9pdveC8EN5QU1i/fOUhfCRJh7S8h6MafhTa+TX18JD
hBv5lbNHQbxbCqepwQ1uZwI1FtUMbiuVbuW+3+sNGwsmmU+NYLKxaJRMbDIoQiI4
WzWaq2tRG+M680wFkBPAFB0HBYseFMW1S4mVEu44G2pDJbIb9RdyeW3tmPmK917T
X769tSCitMGCie6sYTo5SCt30EVR7c8K8V3ohH1L22ZpwDuhnQFvJhm+S9blK65C
JkDQZ6byqskQLoz+8uSGtzZlvLQhRd4LOnLs0Yivl10K9A8Xxe147iNbDdyr4nz2
eyhc3DPARRcyWs+6SP1iX/XJPwxrLJniPy/xAT2YCmnlgntx8AIqcfUdGXzeXQf8
Mbt55xCD792MZ2O29rRHXi2T7bXDAvfbtCzH40bxpdRwPNQteKOS5Bo5Ml2QJ/19
53lhVRhzSZLoLRvjD0vqEfFMjXMivA55V/nnpf7bx4P1ouErlBDFJLNGNa9vS9S5
bcY9JdpNsKA=
=BBDZ
-----END PGP SIGNATURE-----

--=-mSGq/OzWjJoamPSStMpE--

