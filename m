From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: take care of misalignments
Date: Sun, 04 Dec 2011 19:51:08 +0100
Message-ID: <1323024668.2762.163.camel@edumazet-laptop>
References: <20111202.163024.1294014889349291295.davem@davemloft.net>
	 <1322924992.2762.117.camel@edumazet-laptop>
	 <1322984393.2762.134.camel@edumazet-laptop>
	 <20111204.132126.654109006321344175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35173 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab1LDSvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:51:14 -0500
Received: by eaak14 with SMTP id k14so3665754eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 10:51:12 -0800 (PST)
In-Reply-To: <20111204.132126.654109006321344175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 d=C3=A9cembre 2011 =C3=A0 13:21 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 04 Dec 2011 08:39:53 +0100
>=20
> > [PATCH] tcp: take care of misalignments
> >=20
> > We discovered that TCP stack could retransmit misaligned skbs if a
> > malicious peer acknowledged sub MSS frame. This currently can happe=
n
> > only if output interface is non SG enabled : If SG is enabled, tcp
> > builds headless skbs (all payload is included in fragments), so the=
 tcp
> > trimming process only removes parts of skb fragments, header stay
> > aligned.
> >=20
> > Some arches cant handle misalignments, so force a head reallocation=
 and
> > shrink headroom to MAX_TCP_HEADER.
> >=20
> > Dont care about misaligments on x86 and PPC (or other arches settin=
g
> > NET_IP_ALIGN to 0)
> >=20
> > This patch introduces __pskb_copy() which can specify the headroom =
of
> > new head, and pskb_copy() becomes a wrapper on top of __pskb_copy()
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Looks good, applied.

Thanks !

Here a respin of previous patch then ?

[PATCH net-next] tcp: fix tcp_trim_head()

commit f07d960df3 (tcp: avoid frag allocation for small frames)
breaked assumption in tcp stack that skb is either linear (skb->data_le=
n
=3D=3D 0), or fully fragged (skb->data_len =3D=3D skb->len)

tcp_trim_head() made this assumption, we must fix it.

Thanks to Vijay for providing a very detailed explanation.

Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 50788d6..cf30680 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1093,6 +1093,13 @@ static void __pskb_trim_head(struct sk_buff *skb=
, int len)
 {
 	int i, k, eat;
=20
+	eat =3D min_t(int, len, skb_headlen(skb));
+	if (eat) {
+		__skb_pull(skb, eat);
+		len -=3D eat;
+		if (!len)
+			return;
+	}
 	eat =3D len;
 	k =3D 0;
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
@@ -1124,11 +1131,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buf=
f *skb, u32 len)
 	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
=20
-	/* If len =3D=3D headlen, we avoid __skb_pull to preserve alignment. =
*/
-	if (unlikely(len < skb_headlen(skb)))
-		__skb_pull(skb, len);
-	else
-		__pskb_trim_head(skb, len - skb_headlen(skb));
+	__pskb_trim_head(skb, len);
=20
 	TCP_SKB_CB(skb)->seq +=3D len;
 	skb->ip_summed =3D CHECKSUM_PARTIAL;
