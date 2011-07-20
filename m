From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Wed, 20 Jul 2011 12:27:28 +0200
Message-ID: <1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E24BE94.7010301@gont.com.ar>
	 <1311082696.2375.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311089463.2375.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311108423.3113.24.camel@edumazet-laptop>
	 <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: security@kernel.org, Eugene Teo <eugeneteo@kernel.sg>,
	netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>
To: Fernando Gont <fernando@gont.com.ar>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58888 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab1GTK1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 06:27:38 -0400
Received: by wyg8 with SMTP id 8so58391wyg.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 03:27:36 -0700 (PDT)
In-Reply-To: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 10:25 +0200, Eric Dumazet a =C3=A9cr=
it :

> Please hold on, I'll make a different patch series to ease stable tea=
ms
> job. It appears inetpeer & ipv6 are really not an option for old
> kernels.
>=20
> Common patch for all kernels :
> 1) Fix the problem without inetpeer help
> ---=20
> Patches for next kernels
> 2) random split as suggested by Matt Mackal
> 3) Use inetpeer cache to scale identification generation
>=20

Here is the first patch, applicable on net-2.6 / linux-2.6 and stable
kernels.

Thanks

[PATCH v2] ipv6: make fragment identifications less predictable

=46ernando Gont reported current IPv6 fragment identification generatio=
n
was not secure, because using a very predictable system-wide generator,
allowing various attacks.

IPv4 uses inetpeer cache to address this problem and to get good
performance. We'll use this mechanism when IPv6 inetpeer is stable
enough in linux-3.1

=46or the time being, we use jhash on destination address to provide le=
ss
predictable identifications. Also remove a spinlock and use cmpxchg() t=
o
get better SMP performance.

Reported-by: Fernando Gont <fernando@gont.com.ar>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Matt Mackall <mpm@selenic.com>
CC: Eugene Teo <eugeneteo@kernel.sg>
---
 include/net/ipv6.h    |   12 -----------
 net/ipv6/ip6_output.c |   43 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/udp.c        |    2 -
 3 files changed, 40 insertions(+), 17 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c033ed0..3b5ac1f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -463,17 +463,7 @@ static inline int ipv6_addr_diff(const struct in6_=
addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
=20
-static __inline__ void ipv6_select_ident(struct frag_hdr *fhdr)
-{
-	static u32 ipv6_fragmentation_id =3D 1;
-	static DEFINE_SPINLOCK(ip6_id_lock);
-
-	spin_lock_bh(&ip6_id_lock);
-	fhdr->identification =3D htonl(ipv6_fragmentation_id);
-	if (++ipv6_fragmentation_id =3D=3D 0)
-		ipv6_fragmentation_id =3D 1;
-	spin_unlock_bh(&ip6_id_lock);
-}
+extern void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *=
rt);
=20
 /*
  *	Prototypes exported by ipv6
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9d4b165..8a444c8 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -596,6 +596,38 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **=
nexthdr)
 	return offset;
 }
=20
+static u32 hashidentrnd __read_mostly;
+#define FID_HASH_SZ 16
+static u32 ipv6_fragmentation_id[FID_HASH_SZ];
+
+static int __init initialize_hashidentrnd(void)
+{
+	get_random_bytes(&hashidentrnd, sizeof(hashidentrnd));
+	return 0;
+}
+
+late_initcall_sync(initialize_hashidentrnd);
+
+static u32 __ipv6_select_ident(const struct in6_addr *addr)
+{
+	u32 newid, oldid, hash =3D jhash2((u32 *)addr, 4, hashidentrnd);
+	u32 *pid =3D &ipv6_fragmentation_id[hash % FID_HASH_SZ];
+
+	do {
+		oldid =3D *pid;
+		newid =3D oldid + 1;
+		if (!(hash + newid))
+			newid++;
+	} while (cmpxchg(pid, oldid, newid) !=3D oldid);
+
+	return hash + newid;
+}
+
+void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
+{
+	fhdr->identification =3D htonl(__ipv6_select_ident(&rt->rt6i_dst.addr=
));
+}
+
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
@@ -680,7 +712,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)=
(struct sk_buff *))
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
=20
-		ipv6_select_ident(fh);
+		ipv6_select_ident(fh, rt);
 		fh->nexthdr =3D nexthdr;
 		fh->reserved =3D 0;
 		fh->frag_off =3D htons(IP6_MF);
@@ -826,7 +858,7 @@ slow_path:
 		fh->nexthdr =3D nexthdr;
 		fh->reserved =3D 0;
 		if (!frag_id) {
-			ipv6_select_ident(fh);
+			ipv6_select_ident(fh, rt);
 			frag_id =3D fh->identification;
 		} else
 			fh->identification =3D frag_id;
@@ -1072,7 +1104,8 @@ static inline int ip6_ufo_append_data(struct sock=
 *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int mtu,unsigned int flags)
+			int transhdrlen, int mtu,unsigned int flags,
+			struct rt6_info *rt)
=20
 {
 	struct sk_buff *skb;
@@ -1116,7 +1149,7 @@ static inline int ip6_ufo_append_data(struct sock=
 *sk,
 		skb_shinfo(skb)->gso_size =3D (mtu - fragheaderlen -
 					     sizeof(struct frag_hdr)) & ~7;
 		skb_shinfo(skb)->gso_type =3D SKB_GSO_UDP;
-		ipv6_select_ident(&fhdr);
+		ipv6_select_ident(&fhdr, rt);
 		skb_shinfo(skb)->ip6_frag_id =3D fhdr.identification;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
=20
@@ -1282,7 +1315,7 @@ int ip6_append_data(struct sock *sk, int getfrag(=
void *from, char *to,
=20
 			err =3D ip6_ufo_append_data(sk, getfrag, from, length,
 						  hh_len, fragheaderlen,
-						  transhdrlen, mtu, flags);
+						  transhdrlen, mtu, flags, rt);
 			if (err)
 				goto error;
 			return 0;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 328985c..29213b5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1359,7 +1359,7 @@ static struct sk_buff *udp6_ufo_fragment(struct s=
k_buff *skb, u32 features)
 	fptr =3D (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen=
);
 	fptr->nexthdr =3D nexthdr;
 	fptr->reserved =3D 0;
-	ipv6_select_ident(fptr);
+	ipv6_select_ident(fptr, (struct rt6_info *)skb_dst(skb));
=20
 	/* Fragment the skb. ipv6 header and the remaining fields of the
 	 * fragment header are updated in ipv6_gso_segment()


