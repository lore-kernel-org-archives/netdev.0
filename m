From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH 1/3] net: ipv6: Unify {raw,udp}6_sock_seq_show.
Date: Tue, 28 May 2013 23:45:13 +0900
Message-ID: <1369752315-11167-1-git-send-email-lorenzo@google.com>
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:52548 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934359Ab3E1OpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 10:45:25 -0400
Received: by mail-yh0-f73.google.com with SMTP id a41so475492yho.0
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 07:45:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp6_sock_seq_show and raw6_sock_seq_show are identical, except
the UDP version displays ports and the raw version displays the
protocol. Refactor most of the code in these two functions into
a new common ip6_dgram_sock_seq_show function, in preparation
for using it to display ICMPv6 sockets as well.

Also reduce the indentation in parts of include/net/transp_v6.h
to improve readability.

Compiles and displays reasonable results with CONFIG_IPV6={n,m,y}

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/transp_v6.h | 73 +++++++++++++++++++++++++++++--------------------
 net/ipv6/datagram.c     | 27 ++++++++++++++++++
 net/ipv6/raw.c          | 45 ++++++------------------------
 net/ipv6/udp.c          | 49 ++++++---------------------------
 4 files changed, 87 insertions(+), 107 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index eb40e71..841c33e 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -16,38 +16,51 @@ extern struct proto pingv6_prot;
 struct flowi6;
 
 /* extension headers */
-extern int				ipv6_exthdrs_init(void);
-extern void				ipv6_exthdrs_exit(void);
-extern int				ipv6_frag_init(void);
-extern void				ipv6_frag_exit(void);
+extern int		ipv6_exthdrs_init(void);
+extern void		ipv6_exthdrs_exit(void);
+extern int		ipv6_frag_init(void);
+extern void		ipv6_frag_exit(void);
 
 /* transport protocols */
-extern int				pingv6_init(void);
-extern void				pingv6_exit(void);
-extern int				rawv6_init(void);
-extern void				rawv6_exit(void);
-extern int				udpv6_init(void);
-extern void				udpv6_exit(void);
-extern int 				udplitev6_init(void);
-extern void 				udplitev6_exit(void);
-extern int				tcpv6_init(void);
-extern void				tcpv6_exit(void);
-
-extern int				udpv6_connect(struct sock *sk,
-						      struct sockaddr *uaddr,
-						      int addr_len);
-
-extern int			ip6_datagram_recv_ctl(struct sock *sk,
-						      struct msghdr *msg,
-						      struct sk_buff *skb);
-
-extern int			ip6_datagram_send_ctl(struct net *net,
-						      struct sock *sk,
-						      struct msghdr *msg,
-						      struct flowi6 *fl6,
-						      struct ipv6_txoptions *opt,
-						      int *hlimit, int *tclass,
-						      int *dontfrag);
+extern int		pingv6_init(void);
+extern void		pingv6_exit(void);
+extern int		rawv6_init(void);
+extern void		rawv6_exit(void);
+extern int		udpv6_init(void);
+extern void		udpv6_exit(void);
+extern int		udplitev6_init(void);
+extern void		udplitev6_exit(void);
+extern int		tcpv6_init(void);
+extern void		tcpv6_exit(void);
+
+extern int		udpv6_connect(struct sock *sk,
+				      struct sockaddr *uaddr,
+				      int addr_len);
+
+extern int		ip6_datagram_recv_ctl(struct sock *sk,
+					      struct msghdr *msg,
+					      struct sk_buff *skb);
+
+extern int		ip6_datagram_send_ctl(struct net *net,
+					      struct sock *sk,
+					      struct msghdr *msg,
+					      struct flowi6 *fl6,
+					      struct ipv6_txoptions *opt,
+					      int *hlimit, int *tclass,
+					      int *dontfrag);
+
+#define IPV6_SEQ_DGRAM_HEADER \
+			   "  sl  "					\
+			   "local_address                         "	\
+			   "remote_address                        "	\
+			   "st tx_queue rx_queue tr tm->when retrnsmt"	\
+			   "   uid  timeout inode ref pointer drops\n"
+
+extern void		ip6_dgram_sock_seq_show(struct seq_file *seq,
+						struct sock *sp,
+						__u16 srcp,
+						__u16 destp,
+						int bucket);
 
 #define		LOOPBACK4_IPV6		cpu_to_be32(0x7f000006)
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4b56cbb..197e6f4 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -879,3 +879,30 @@ exit_f:
 	return err;
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
+
+void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
+			     __u16 srcp, __u16 destp, int bucket)
+{
+	struct ipv6_pinfo *np = inet6_sk(sp);
+	const struct in6_addr *dest, *src;
+
+	dest  = &np->daddr;
+	src   = &np->rcv_saddr;
+	seq_printf(seq,
+		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
+		   bucket,
+		   src->s6_addr32[0], src->s6_addr32[1],
+		   src->s6_addr32[2], src->s6_addr32[3], srcp,
+		   dest->s6_addr32[0], dest->s6_addr32[1],
+		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
+		   sp->sk_state,
+		   sk_wmem_alloc_get(sp),
+		   sk_rmem_alloc_get(sp),
+		   0, 0L, 0,
+		   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sp)),
+		   0,
+		   sock_i_ino(sp),
+		   atomic_read(&sp->sk_refcnt), sp,
+		   atomic_read(&sp->sk_drops));
+}
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index eedff8c..83bef86 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1226,45 +1226,16 @@ struct proto rawv6_prot = {
 };
 
 #ifdef CONFIG_PROC_FS
-static void raw6_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
-{
-	struct ipv6_pinfo *np = inet6_sk(sp);
-	const struct in6_addr *dest, *src;
-	__u16 destp, srcp;
-
-	dest  = &np->daddr;
-	src   = &np->rcv_saddr;
-	destp = 0;
-	srcp  = inet_sk(sp)->inet_num;
-	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
-		   sp->sk_state,
-		   sk_wmem_alloc_get(sp),
-		   sk_rmem_alloc_get(sp),
-		   0, 0L, 0,
-		   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sp)),
-		   0,
-		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
-}
-
 static int raw6_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == SEQ_START_TOKEN)
-		seq_printf(seq,
-			   "  sl  "
-			   "local_address                         "
-			   "remote_address                        "
-			   "st tx_queue rx_queue tr tm->when retrnsmt"
-			   "   uid  timeout inode ref pointer drops\n");
-	else
-		raw6_sock_seq_show(seq, v, raw_seq_private(seq)->bucket);
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, IPV6_SEQ_DGRAM_HEADER);
+	} else {
+		struct sock *sp = v;
+		__u16 srcp  = inet_sk(sp)->inet_num;
+		ip6_dgram_sock_seq_show(seq, v, srcp, 0,
+					raw_seq_private(seq)->bucket);
+	}
 	return 0;
 }
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 42923b1..b580853 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1359,48 +1359,17 @@ static const struct inet6_protocol udpv6_protocol = {
 
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
-
-static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket)
-{
-	struct inet_sock *inet = inet_sk(sp);
-	struct ipv6_pinfo *np = inet6_sk(sp);
-	const struct in6_addr *dest, *src;
-	__u16 destp, srcp;
-
-	dest  = &np->daddr;
-	src   = &np->rcv_saddr;
-	destp = ntohs(inet->inet_dport);
-	srcp  = ntohs(inet->inet_sport);
-	seq_printf(seq,
-		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
-		   bucket,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
-		   sp->sk_state,
-		   sk_wmem_alloc_get(sp),
-		   sk_rmem_alloc_get(sp),
-		   0, 0L, 0,
-		   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sp)),
-		   0,
-		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp,
-		   atomic_read(&sp->sk_drops));
-}
-
 int udp6_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == SEQ_START_TOKEN)
-		seq_printf(seq,
-			   "  sl  "
-			   "local_address                         "
-			   "remote_address                        "
-			   "st tx_queue rx_queue tr tm->when retrnsmt"
-			   "   uid  timeout inode ref pointer drops\n");
-	else
-		udp6_sock_seq_show(seq, v, ((struct udp_iter_state *)seq->private)->bucket);
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, IPV6_SEQ_DGRAM_HEADER);
+	} else {
+		int bucket = ((struct udp_iter_state *)seq->private)->bucket;
+		struct inet_sock *inet = inet_sk(v);
+		__u16 srcp = ntohs(inet->inet_sport);
+		__u16 destp = ntohs(inet->inet_dport);
+		ip6_dgram_sock_seq_show(seq, v, srcp, destp, bucket);
+	}
 	return 0;
 }
 
-- 
1.8.2.1
