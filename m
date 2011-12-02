From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 16:44:23 +0100
Message-ID: <1322840663.2762.26.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	 <1322713032.2577.7.camel@edumazet-laptop>
	 <CAGK4HS8fLWwdPsrag6+Mz93_ZNg2B5JRjx2s=Re8_Qiv4V=T=w@mail.gmail.com>
	 <1322778621.2750.48.camel@edumazet-laptop>
	 <CAGK4HS84vepB-cOnjOASqXy2gLWGwx=RHnQ3PbbMPezxJ5m3QQ@mail.gmail.com>
	 <1322827188.2607.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48392 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756785Ab1LBPo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 10:44:28 -0500
Received: by vbbfc26 with SMTP id fc26so2379378vbb.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 07:44:27 -0800 (PST)
In-Reply-To: <1322827188.2607.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 12:59 +0100, Eric Dumazet a =C3=
=A9crit :

> Thanks for this detailed explanation !
>=20
> And yes, you're probably right.
>=20
> Are you willing to submit a patch to fix this ?
>=20
> (If not, I can do it myself of course)
>=20

[PATCH net-next] tcp: fix tcp_trim_head()

commit f07d960df3 (tcp: avoid frag allocation for small frames)
breaked assumption in tcp stack that skb is either linear (data_len =3D=
=3D
0), either fully fragged (data_len =3D=3D len)

Thanks to Vijay for providing a very detailed explanation.

Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 58f69ac..4a0f54a 100644
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
