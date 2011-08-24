From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Wed, 24 Aug 2011 15:04:37 +0800
Message-ID: <CAAM7YAmht5FFTTFHrDUXAXHD5h5gzn1GrtEbHkQfbaoCwccG0w@mail.gmail.com>
References: <4E5367CA.3090005@sfc.wide.ad.jp>
	<1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E539DA8.1070504@sfc.wide.ad.jp>
	<1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E53B360.8090107@sfc.wide.ad.jp>
	<4E53E237.1060401@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Linus_L=FCssing?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:34380 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab1HXHEh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 03:04:37 -0400
Received: by pzk37 with SMTP id 37so355640pzk.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 00:04:37 -0700 (PDT)
In-Reply-To: <4E53E237.1060401@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 1:24 AM, Ang Way Chuang <wcang@sfc.wide.ad.jp> =
wrote:
> This is what I found so far from debugging.
>
> The packet is not forwarded due to the failed checksum at
> br_multicast.c:1533
>
> =A0 =A0 =A0 =A0case CHECKSUM_NONE:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb2->csum =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb_checksum_complete(skb2))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
> Contrary to description of commit ff9a57a6, when the patch of commit
> ff9a57a6 is applied,
> pskb_trim_rcsum is never called at all on my testbed. When commit ff9=
a57a6
> is reverted,
> pskb_trim_rcsum will be called. The difference is:
>
> with commit ff9a57a6,
> =A0 pskb_trim_rcsum is never called, br_multicast_ipv6_rcv returns -E=
INVAL
> which causes
> =A0 br_handle_frame_finish to drop the packet
>
> without commit ff9a57a6,
> =A0 pskb_trim_rcsum is called overwriting err with 0. br_multicast_ip=
v6_rcv
> still fails on the
> =A0 same line (skb_checksum_complete). But the difference is err is s=
et to 0
> this time. Thereby,
> =A0 allowing the packet to be forwarded.
>
> Anyway, I don't think the behaviour is correct with or without commit
> ff9a57a6
>
>

Looks like a checksum calculation bug. Please try below patch, Thanks.

---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d85ca7..22d2d1a 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1520,16 +1520,23 @@ static int br_multicast_ipv6_rcv(struct net_bri=
dge *br,
 		err =3D pskb_trim_rcsum(skb2, len);
 		if (err)
 			goto out;
+		err =3D -EINVAL;
 	}

+	ip6h =3D ipv6_hdr(skb2);
+
 	switch (skb2->ip_summed) {
 	case CHECKSUM_COMPLETE:
-		if (!csum_fold(skb2->csum))
+		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, skb2->len,
+					IPPROTO_ICMPV6, skb2->csum))
 			break;
 		/*FALLTHROUGH*/
 	case CHECKSUM_NONE:
-		skb2->csum =3D 0;
-		if (skb_checksum_complete(skb2))
+		skb2->csum =3D ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
+							&ip6h->daddr,
+							skb2->len,
+							IPPROTO_ICMPV6, 0));
+		if (__skb_checksum_complete(skb2))
 			goto out;
 	}

---
