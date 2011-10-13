From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 19:28:54 +0200
Message-ID: <1318526934.2393.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318521901.2745.18.camel@bwh-desktop>
	 <1318523090.2393.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318523564.2745.32.camel@bwh-desktop>
	 <1318525877.2393.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318525990.2745.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63192 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756433Ab1JMR2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:28:39 -0400
Received: by mail-ey0-f174.google.com with SMTP id 27so259093eye.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 10:28:38 -0700 (PDT)
In-Reply-To: <1318525990.2745.33.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 18:13 +0100, Ben Hutchings a =C3=A9crit=
 :
> On Thu, 2011-10-13 at 19:11 +0200, Eric Dumazet wrote:
> > Le jeudi 13 octobre 2011 =C3=A0 17:32 +0100, Ben Hutchings a =C3=A9=
crit :
> >=20
> > > Fair enough, but please add a comment explaining this.
> > >=20
> >=20
> >=20
> > What about :
> >=20
> > 	/* We do our best to align skb_shared_info on a separate cache
> > 	 * line. It usually works because kmalloc(X > CACHE_BYTES) gives
> > 	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
> > 	 */
> > 	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>=20
> Yes, that seems like a good explanation.

Thanks !

Here is the second version of the patch, including this comment.

[PATCH V2 net-next] net: more accurate skb truesize

skb truesize currently accounts for sk_buff struct and part of skb head=
=2E
kmalloc() roundings are also ignored.

Considering that skb_shared_info is larger than sk_buff, its time to
take it into account for better memory accounting.

This patch introduces SKB_TRUESIZE(X) macro to centralize various
assumptions into a single place.

At skb alloc phase, we put skb_shared_info struct at the exact end of
skb head, to allow a better use of memory (lowering number of
reallocations), since kmalloc() gives us power-of-two memory blocks.

Unless SLUB/SLUB debug is active, both skb->head and skb_shared_info ar=
e
aligned to cache lines, as before.

Note: This patch might trigger performance regressions because of
misconfigured protocol stacks, hitting per socket or global memory
limits that were previously not reached. But its a necessary step for a
more accurate memory accounting.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andi Kleen <ak@linux.intel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/skbuff.h |    5 +++++
 net/core/skbuff.c      |   18 ++++++++++++++----
 net/core/sock.c        |    2 +-
 net/ipv4/icmp.c        |    5 ++---
 net/ipv4/tcp_input.c   |   14 +++++++-------
 net/ipv6/icmp.c        |    3 +--
 net/iucv/af_iucv.c     |    2 +-
 net/sctp/protocol.c    |    2 +-
 8 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac6b05a..64f8695 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -46,6 +46,11 @@
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
 #define SKB_MAX_ALLOC		(SKB_MAX_ORDER(0, 2))
=20
+/* return minimum truesize of one skb containing X bytes of data */
+#define SKB_TRUESIZE(X) ((X) +						\
+			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
+			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+
 /* A. Checksumming of received packets by device.
  *
  *	NONE: device failed to checksum this packet.
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b2c5f1..a7f855d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -184,11 +184,20 @@ struct sk_buff *__alloc_skb(unsigned int size, gf=
p_t gfp_mask,
 		goto out;
 	prefetchw(skb);
=20
-	size =3D SKB_DATA_ALIGN(size);
-	data =3D kmalloc_node_track_caller(size + sizeof(struct skb_shared_in=
fo),
-			gfp_mask, node);
+	/* We do our best to align skb_shared_info on a separate cache
+	 * line. It usually works because kmalloc(X > SMP_CACHE_BYTES) gives
+	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
+	 * Both skb->head and skb_shared_info are cache line aligned.
+	 */
+	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	data =3D kmalloc_node_track_caller(size, gfp_mask, node);
 	if (!data)
 		goto nodata;
+	/* kmalloc(size) might give us more room than requested.
+	 * Put skb_shared_info exactly at the end of allocated zone,
+	 * to allow max possible filling before reallocation.
+	 */
+	size =3D SKB_WITH_OVERHEAD(ksize(data));
 	prefetchw(data + size);
=20
 	/*
@@ -197,7 +206,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_=
t gfp_mask,
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->truesize =3D size + sizeof(struct sk_buff);
+	/* Account for allocated memory : skb + skb->head */
+	skb->truesize =3D SKB_TRUESIZE(size);
 	atomic_set(&skb->users, 1);
 	skb->head =3D data;
 	skb->data =3D data;
diff --git a/net/core/sock.c b/net/core/sock.c
index 83c462d..5a08762 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -207,7 +207,7 @@ static struct lock_class_key af_callback_keys[AF_MA=
X];
  * not depend upon such differences.
  */
 #define _SK_MEM_PACKETS		256
-#define _SK_MEM_OVERHEAD	(sizeof(struct sk_buff) + 256)
+#define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
 #define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
 #define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
=20
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 23ef31b..ab188ae 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1152,10 +1152,9 @@ static int __net_init icmp_sk_init(struct net *n=
et)
 		net->ipv4.icmp_sk[i] =3D sk;
=20
 		/* Enough space for 2 64K ICMP packets, including
-		 * sk_buff struct overhead.
+		 * sk_buff/skb_shared_info struct overhead.
 		 */
-		sk->sk_sndbuf =3D
-			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
+		sk->sk_sndbuf =3D	2 * SKB_TRUESIZE(64 * 1024);
=20
 		/*
 		 * Speedup sock_wfree()
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 81cae64..c1653fe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -265,8 +265,7 @@ static inline int TCP_ECN_rcv_ecn_echo(struct tcp_s=
ock *tp, struct tcphdr *th)
=20
 static void tcp_fixup_sndbuf(struct sock *sk)
 {
-	int sndmem =3D tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HEADER + 16 +
-		     sizeof(struct sk_buff);
+	int sndmem =3D SKB_TRUESIZE(tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HE=
ADER);
=20
 	if (sk->sk_sndbuf < 3 * sndmem) {
 		sk->sk_sndbuf =3D 3 * sndmem;
@@ -349,7 +348,7 @@ static void tcp_grow_window(struct sock *sk, struct=
 sk_buff *skb)
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	int rcvmem =3D tp->advmss + MAX_TCP_HEADER + 16 + sizeof(struct sk_bu=
ff);
+	int rcvmem =3D SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
=20
 	/* Try to select rcvbuf so that 4 mss-sized segments
 	 * will fit to window and corresponding skbs will fit to our rcvbuf.
@@ -540,8 +539,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 			space /=3D tp->advmss;
 			if (!space)
 				space =3D 1;
-			rcvmem =3D (tp->advmss + MAX_TCP_HEADER +
-				  16 + sizeof(struct sk_buff));
+			rcvmem =3D SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
 			while (tcp_win_from_space(rcvmem) < tp->advmss)
 				rcvmem +=3D 128;
 			space *=3D rcvmem;
@@ -4950,8 +4948,10 @@ static void tcp_new_space(struct sock *sk)
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	if (tcp_should_expand_sndbuf(sk)) {
-		int sndmem =3D max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
-			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff);
+		int sndmem =3D SKB_TRUESIZE(max_t(u32,
+						tp->rx_opt.mss_clamp,
+						tp->mss_cache) +
+					  MAX_TCP_HEADER);
 		int demanded =3D max_t(unsigned int, tp->snd_cwnd,
 				     tp->reordering + 1);
 		sndmem *=3D 2 * demanded;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 2b59154..90868fb 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -835,8 +835,7 @@ static int __net_init icmpv6_sk_init(struct net *ne=
t)
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
 		 */
-		sk->sk_sndbuf =3D
-			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
+		sk->sk_sndbuf =3D 2 * SKB_TRUESIZE(64 * 1024);
 	}
 	return 0;
=20
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index c39f3a4..274d150 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1819,7 +1819,7 @@ static void iucv_callback_rx(struct iucv_path *pa=
th, struct iucv_message *msg)
 		goto save_message;
=20
 	len =3D atomic_read(&sk->sk_rmem_alloc);
-	len +=3D iucv_msg_length(msg) + sizeof(struct sk_buff);
+	len +=3D SKB_TRUESIZE(iucv_msg_length(msg));
 	if (len > sk->sk_rcvbuf)
 		goto save_message;
=20
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 91784f4..61b9fca 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1299,7 +1299,7 @@ SCTP_STATIC __init int sctp_init(void)
 	max_share =3D min(4UL*1024*1024, limit);
=20
 	sysctl_sctp_rmem[0] =3D SK_MEM_QUANTUM; /* give each asoc 1 page min =
*/
-	sysctl_sctp_rmem[1] =3D (1500 *(sizeof(struct sk_buff) + 1));
+	sysctl_sctp_rmem[1] =3D 1500 * SKB_TRUESIZE(1);
 	sysctl_sctp_rmem[2] =3D max(sysctl_sctp_rmem[1], max_share);
=20
 	sysctl_sctp_wmem[0] =3D SK_MEM_QUANTUM;
