From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC PATCH net-2.6.26 2/3] [NET] NETNS: Omit sock->sk_net without
 CONFIG_NET_NS.
Date: Tue, 25 Mar 2008 14:48:02 -0400
Message-ID: <47E948E2.6020800@hp.com>
References: <20080325.231459.40431402.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020704070505000403050500"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:5884 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859AbYCYSsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 14:48:07 -0400
In-Reply-To: <20080325.231459.40431402.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020704070505000403050500
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

YOSHIFUJI Hideaki / ???? wrote:
> Introduce per-sock inlines: sock_net(), sock_net_set().
> Without CONFIG_NET_NS, no namespace other than &init_net exists.
> Let's explicitly define them to help compiler optimizations.

> diff --git a/include/net/sock.h b/include/net/sock.h
> index b433b1e..7e0d4a0 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -126,7 +126,9 @@ struct sock_common {
>  	atomic_t		skc_refcnt;
>  	unsigned int		skc_hash;
>  	struct proto		*skc_prot;
> +#ifdef CONFIG_NET_NS
>  	struct net	 	*skc_net;
> +#endif
>  };

net/ipv4/inet_timewait_sock.c: In function ‘inet_twsk_alloc’:
net/ipv4/inet_timewait_sock.c:127: error: ‘struct sock_common’ has no 
member named ‘skc_net’

Maybe this was the issue you already found yourself, patch below.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------020704070505000403050500
Content-Type: text/x-patch;
 name="skc_net_ns.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skc_net_ns.patch"

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 296547b..c825c2d 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -115,7 +115,9 @@ struct inet_timewait_sock {
 #define tw_refcnt		__tw_common.skc_refcnt
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
+#ifdef CONFIG_NET_NS
 #define tw_net			__tw_common.skc_net
+#endif
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
 	/* 3 bits hole, try to pack */
@@ -187,6 +189,24 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 	return (struct inet_timewait_sock *)sk;
 }
 
+static inline
+struct net *tw_sock_net(struct inet_timewait_sock *twsk)
+{
+#ifdef CONFIG_NET_NS
+	return twsk->tw_net;
+#else
+	return &init_net;
+#endif
+}
+
+static inline void tw_sock_net_set(struct inet_timewait_sock *twsk,
+				   struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	twsk->tw_net = net;
+#endif
+}
+
 static inline __be32 inet_rcv_saddr(const struct sock *sk)
 {
 	return likely(sk->sk_state != TCP_TIME_WAIT) ?
diff --git a/include/net/sock.h b/include/net/sock.h
index 7e0d4a0..eb1f065 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -211,7 +211,9 @@ struct sock {
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_hash			__sk_common.skc_hash
 #define sk_prot			__sk_common.skc_prot
+#ifdef CONFIG_NET_NS
 #define sk_net			__sk_common.skc_net
+#endif
 	unsigned char		sk_shutdown : 2,
 				sk_no_check : 2,
 				sk_userlocks : 4;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a60db37..3524dcd 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -124,7 +124,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
-		tw->tw_net          = sock_net(sk);
+		tw_sock_net_set(tw, sock_net(sk));
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b92f789..a157027 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2059,7 +2059,7 @@ static void *established_get_first(struct seq_file *seq)
 		inet_twsk_for_each(tw, node,
 				   &tcp_hashinfo.ehash[st->bucket].twchain) {
 			if (tw->tw_family != st->family ||
-			    tw->tw_net != net) {
+			    tw_sock_net(tw) != net) {
 				continue;
 			}
 			rc = tw;
@@ -2086,7 +2086,8 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 		tw = cur;
 		tw = tw_next(tw);
 get_tw:
-		while (tw && (tw->tw_family != st->family || tw->tw_net != net)) {
+		while (tw && (tw->tw_family != st->family ||
+		       tw_sock_net(tw) != net)) {
 			tw = tw_next(tw);
 		}
 		if (tw) {

--------------020704070505000403050500--
