From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][INET] move inet_sock into inet_opt and rename it to inet_sock
Date: Sat, 25 Dec 2004 23:53:15 -0200
Message-ID: <41CE198B.7040005@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060000020103000505000009"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060000020103000505000009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Now that 2.6.10 is out, please take a look if this is acceptable,
the following patches will deal with udp_sock, tcp_sock, etc.

	This is the start of the series of patches that will introduce
struct connection_sock, reducing the memory used by non connected protocols,
such as UDP.

	It is available at:

bk://kernel.bkbits.net/acme/connection_sock-2.6

Best Regards,

- Arnaldo

--------------060000020103000505000009
Content-Type: text/plain;
 name="inet_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inet_sock.patch"

===================================================================


ChangeSet@1.2221, 2004-12-23 22:46:12-02:00, acme@conectiva.com.br
  [INET] move inet_sock into inet_opt and rename it to inet_sock
  
  With this we can remove all the cut'n'pasted layouts in all inet_sock
  derived classes, such as tcp_sock, udp_sock, sctp_sock, etc.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/ip.h                     |   24 ++++++++++--------------
 include/linux/ipv6.h                   |   14 ++++----------
 include/linux/tcp.h                    |    6 +-----
 include/linux/udp.h                    |    6 +-----
 include/net/icmp.h                     |    8 +-------
 include/net/sctp/sctp.h                |   12 +++---------
 include/net/tcp.h                      |    2 +-
 net/ipv4/af_inet.c                     |   10 +++++-----
 net/ipv4/datagram.c                    |    2 +-
 net/ipv4/icmp.c                        |    4 ++--
 net/ipv4/igmp.c                        |   16 ++++++++--------
 net/ipv4/ip_output.c                   |   16 ++++++++--------
 net/ipv4/ip_sockglue.c                 |   12 ++++++------
 net/ipv4/ipvs/ip_vs_sync.c             |    6 +++---
 net/ipv4/netfilter/ip_conntrack_core.c |    2 +-
 net/ipv4/raw.c                         |   14 +++++++-------
 net/ipv4/tcp.c                         |    4 ++--
 net/ipv4/tcp_diag.c                    |   14 +++++++-------
 net/ipv4/tcp_input.c                   |    2 +-
 net/ipv4/tcp_ipv4.c                    |   30 +++++++++++++++---------------
 net/ipv4/tcp_minisocks.c               |    2 +-
 net/ipv4/tcp_output.c                  |    2 +-
 net/ipv4/tcp_timer.c                   |    2 +-
 net/ipv4/udp.c                         |   20 ++++++++++----------
 net/ipv6/af_inet6.c                    |   10 ++++------
 net/ipv6/datagram.c                    |    4 ++--
 net/ipv6/ip6_output.c                  |    6 +++---
 net/ipv6/raw.c                         |   10 +++++-----
 net/ipv6/tcp_ipv6.c                    |   20 ++++++++++----------
 net/ipv6/udp.c                         |   12 ++++++------
 net/sctp/input.c                       |    2 +-
 net/sctp/ipv6.c                        |    6 +++---
 net/sctp/protocol.c                    |    4 ++--
 security/selinux/avc.c                 |    4 ++--
 34 files changed, 138 insertions(+), 170 deletions(-)


diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	2004-12-25 23:46:53 -02:00
+++ b/include/linux/ip.h	2004-12-25 23:46:53 -02:00
@@ -107,7 +107,14 @@
 
 #define optlength(opt) (sizeof(struct ip_options) + opt->optlen)
 
-struct inet_opt {
+struct ipv6_pinfo;
+
+struct inet_sock {
+	/* sk and pinet6 has to be the first two members of inet_sock */
+	struct sock		sk;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct ipv6_pinfo	*pinet6;
+#endif
 	/* Socket demultiplex comparisons on incoming packets. */
 	__u32			daddr;		/* Foreign IPv4 addr */
 	__u32			rcv_saddr;	/* Bound local IPv4 addr */
@@ -146,20 +153,9 @@
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
 
-struct ipv6_pinfo;
-
-/* WARNING: don't change the layout of the members in inet_sock! */
-struct inet_sock {
-	struct sock	  sk;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
-#endif
-	struct inet_opt   inet;
-};
-
-static inline struct inet_opt * inet_sk(const struct sock *__sk)
+static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
-	return &((struct inet_sock *)__sk)->inet;
+	return (struct inet_sock *)sk;
 }
 
 #endif
diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	2004-12-25 23:46:53 -02:00
+++ b/include/linux/ipv6.h	2004-12-25 23:46:53 -02:00
@@ -256,32 +256,26 @@
 
 /* WARNING: don't change the layout of the members in {raw,udp,tcp}6_sock! */
 struct raw6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt   inet;
+	struct inet_sock  inet;
 	struct raw6_opt   raw6;
 	struct ipv6_pinfo inet6;
 };
 
 struct udp6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt   inet;
+	struct inet_sock  inet;
 	struct udp_opt	  udp;
 	struct ipv6_pinfo inet6;
 };
 
 struct tcp6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt   inet;
+	struct inet_sock  inet;
 	struct tcp_opt	  tcp;
 	struct ipv6_pinfo inet6;
 };
 
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
-	return ((struct raw6_sock *)__sk)->pinet6;
+	return inet_sk(__sk)->pinet6;
 }
 
 static inline struct raw6_opt * raw6_sk(const struct sock *__sk)
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-12-25 23:46:53 -02:00
+++ b/include/linux/tcp.h	2004-12-25 23:46:53 -02:00
@@ -440,11 +440,7 @@
 
 /* WARNING: don't change the layout of the members in tcp_sock! */
 struct tcp_sock {
-	struct sock	  sk;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
-#endif
-	struct inet_opt	  inet;
+	struct inet_sock  inet;
 	struct tcp_opt	  tcp;
 };
 
diff -Nru a/include/linux/udp.h b/include/linux/udp.h
--- a/include/linux/udp.h	2004-12-25 23:46:53 -02:00
+++ b/include/linux/udp.h	2004-12-25 23:46:53 -02:00
@@ -53,11 +53,7 @@
 
 /* WARNING: don't change the layout of the members in udp_sock! */
 struct udp_sock {
-	struct sock	  sk;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
-#endif
-	struct inet_opt	  inet;
+	struct inet_sock  inet;
 	struct udp_opt	  udp;
 };
 
diff -Nru a/include/net/icmp.h b/include/net/icmp.h
--- a/include/net/icmp.h	2004-12-25 23:46:53 -02:00
+++ b/include/net/icmp.h	2004-12-25 23:46:53 -02:00
@@ -50,15 +50,9 @@
 	struct icmp_filter filter;
 };
 
-struct ipv6_pinfo;
-
 /* WARNING: don't change the layout of the members in raw_sock! */
 struct raw_sock {
-	struct sock	  sk;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
-#endif
-	struct inet_opt	  inet;
+	struct inet_sock  inet;
 	struct raw_opt	  raw4;
 };
 
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	2004-12-25 23:46:53 -02:00
+++ b/include/net/sctp/sctp.h	2004-12-25 23:46:53 -02:00
@@ -584,26 +584,20 @@
 
 /* WARNING: Do not change the layout of the members in sctp_sock! */
 struct sctp_sock {
-	struct sock	  sk;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct ipv6_pinfo *pinet6;
-#endif /* CONFIG_IPV6 */
-	struct inet_opt	  inet;
+	struct inet_sock  inet;
 	struct sctp_opt	  sctp;
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 struct sctp6_sock {
-	struct sock	  sk;
-	struct ipv6_pinfo *pinet6;
-	struct inet_opt	  inet;
+	struct inet_sock  inet;
 	struct sctp_opt	  sctp;
 	struct ipv6_pinfo inet6;
 };
 #endif /* CONFIG_IPV6 */
 
 #define sctp_sk(__sk) (&((struct sctp_sock *)__sk)->sctp)
-#define sctp_opt2sk(__sp) &container_of(__sp, struct sctp_sock, sctp)->sk
+#define sctp_opt2sk(__sp) &container_of(__sp, struct sctp_sock, sctp)->inet.sk
 
 /* Is a socket of this style? */
 #define sctp_style(sk, style) __sctp_style((sk), (SCTP_SOCKET_##style))
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-12-25 23:46:53 -02:00
+++ b/include/net/tcp.h	2004-12-25 23:46:53 -02:00
@@ -196,7 +196,7 @@
 	unsigned char		tw_rcv_wscale;
 	__u16			tw_sport;
 	/* Socket demultiplex comparisons on incoming packets. */
-	/* these five are in inet_opt */
+	/* these five are in inet_sock */
 	__u32			tw_daddr
 		__attribute__((aligned(TCP_ADDRCMP_ALIGN_BYTES)));
 	__u32			tw_rcv_saddr;
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/af_inet.c	2004-12-25 23:46:53 -02:00
@@ -131,7 +131,7 @@
 
 void inet_sock_destruct(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	__skb_queue_purge(&sk->sk_receive_queue);
 	__skb_queue_purge(&sk->sk_error_queue);
@@ -173,7 +173,7 @@
 
 static int inet_autobind(struct sock *sk)
 {
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	/* We may need to bind the socket. */
 	lock_sock(sk);
 	inet = inet_sk(sk);
@@ -232,7 +232,7 @@
 	struct sock *sk;
 	struct list_head *p;
 	struct inet_protosw *answer;
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	struct proto *answer_prot;
 	unsigned char answer_flags;
 	char answer_no_check;
@@ -389,7 +389,7 @@
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
 	struct sock *sk = sock->sk;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	unsigned short snum;
 	int chk_addr_ret;
 	int err;
@@ -623,7 +623,7 @@
 			int *uaddr_len, int peer)
 {
 	struct sock *sk		= sock->sk;
-	struct inet_opt *inet	= inet_sk(sk);
+	struct inet_sock *inet	= inet_sk(sk);
 	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;
 
 	sin->sin_family = AF_INET;
diff -Nru a/net/ipv4/datagram.c b/net/ipv4/datagram.c
--- a/net/ipv4/datagram.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/datagram.c	2004-12-25 23:46:53 -02:00
@@ -22,7 +22,7 @@
 
 int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *) uaddr;
 	struct rtable *rt;
 	u32 saddr;
diff -Nru a/net/ipv4/icmp.c b/net/ipv4/icmp.c
--- a/net/ipv4/icmp.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/icmp.c	2004-12-25 23:46:53 -02:00
@@ -377,7 +377,7 @@
 static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
 	struct sock *sk = icmp_socket->sk;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
 	struct rtable *rt = (struct rtable *)skb->dst;
 	u32 daddr;
@@ -1097,7 +1097,7 @@
 
 void __init icmp_init(struct net_proto_family *ops)
 {
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++) {
diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/igmp.c	2004-12-25 23:46:53 -02:00
@@ -1617,7 +1617,7 @@
 	u32 addr = imr->imr_multiaddr.s_addr;
 	struct ip_mc_socklist *iml, *i;
 	struct in_device *in_dev;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int count = 0;
 
 	if (!MULTICAST(addr))
@@ -1691,7 +1691,7 @@
 
 int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml, **imlp;
 
 	rtnl_lock();
@@ -1734,7 +1734,7 @@
 	u32 addr = mreqs->imr_multiaddr;
 	struct ip_mc_socklist *pmc;
 	struct in_device *in_dev = NULL;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
 	int i, j, rv;
 
@@ -1852,7 +1852,7 @@
 	u32 addr = msf->imsf_multiaddr;
 	struct ip_mc_socklist *pmc;
 	struct in_device *in_dev;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *newpsl, *psl;
 
 	if (!MULTICAST(addr))
@@ -1922,7 +1922,7 @@
 	u32 addr = msf->imsf_multiaddr;
 	struct ip_mc_socklist *pmc;
 	struct in_device *in_dev;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
 
 	if (!MULTICAST(addr))
@@ -1980,7 +1980,7 @@
 	struct sockaddr_in *psin;
 	u32 addr;
 	struct ip_mc_socklist *pmc;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
 
 	psin = (struct sockaddr_in *)&gsf->gf_group;
@@ -2033,7 +2033,7 @@
  */
 int ip_mc_sf_allow(struct sock *sk, u32 loc_addr, u32 rmt_addr, int dif)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *pmc;
 	struct ip_sf_socklist *psl;
 	int i;
@@ -2069,7 +2069,7 @@
 
 void ip_mc_drop_socket(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml;
 
 	if (inet->mc_list == NULL)
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/ip_output.c	2004-12-25 23:46:53 -02:00
@@ -115,7 +115,7 @@
 	return 0;
 }
 
-static inline int ip_select_ttl(struct inet_opt *inet, struct dst_entry *dst)
+static inline int ip_select_ttl(struct inet_sock *inet, struct dst_entry *dst)
 {
 	int ttl = inet->uc_ttl;
 
@@ -131,7 +131,7 @@
 int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 			  u32 saddr, u32 daddr, struct ip_options *opt)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct rtable *rt = (struct rtable *)skb->dst;
 	struct iphdr *iph;
 
@@ -297,7 +297,7 @@
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk = skb->sk;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options *opt = inet->opt;
 	struct rtable *rt;
 	struct iphdr *iph;
@@ -712,7 +712,7 @@
 		   struct ipcm_cookie *ipc, struct rtable *rt,
 		   unsigned int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 
 	struct ip_options *opt = NULL;
@@ -973,7 +973,7 @@
 ssize_t	ip_append_page(struct sock *sk, struct page *page,
 		       int offset, size_t size, int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	struct rtable *rt;
 	struct ip_options *opt = NULL;
@@ -1112,7 +1112,7 @@
 {
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options *opt = NULL;
 	struct rtable *rt = inet->cork.rt;
 	struct iphdr *iph;
@@ -1217,7 +1217,7 @@
  */
 void ip_flush_pending_frames(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
@@ -1260,7 +1260,7 @@
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
 		   unsigned int len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct {
 		struct ip_options	opt;
 		char			data[40];
diff -Nru a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
--- a/net/ipv4/ip_sockglue.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/ip_sockglue.c	2004-12-25 23:46:53 -02:00
@@ -112,7 +112,7 @@
 
 void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 {
-	struct inet_opt *inet = inet_sk(skb->sk);
+	struct inet_sock *inet = inet_sk(skb->sk);
 	unsigned flags = inet->cmsg_flags;
 
 	/* Ordered by supposed usage frequency */
@@ -234,7 +234,7 @@
 void ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err, 
 		   u16 port, u32 info, u8 *payload)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sock_exterr_skb *serr;
 
 	if (!inet->recverr)
@@ -263,7 +263,7 @@
 
 void ip_local_error(struct sock *sk, int err, u32 daddr, u16 port, u32 info)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sock_exterr_skb *serr;
 	struct iphdr *iph;
 	struct sk_buff *skb;
@@ -342,7 +342,7 @@
 	sin = &errhdr.offender;
 	sin->sin_family = AF_UNSPEC;
 	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = skb->nh.iph->saddr;
@@ -383,7 +383,7 @@
 
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval, int optlen)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int val=0,err;
 
 	if (level != SOL_IP)
@@ -875,7 +875,7 @@
 
 int ip_getsockopt(struct sock *sk, int level, int optname, char __user *optval, int __user *optlen)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int val;
 	int len;
 	
diff -Nru a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
--- a/net/ipv4/ipvs/ip_vs_sync.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/ipvs/ip_vs_sync.c	2004-12-25 23:46:53 -02:00
@@ -343,7 +343,7 @@
  */
 static void set_mcast_loop(struct sock *sk, u_char loop)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	/* setsockopt(sock, SOL_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)); */
 	lock_sock(sk);
@@ -356,7 +356,7 @@
  */
 static void set_mcast_ttl(struct sock *sk, u_char ttl)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	/* setsockopt(sock, SOL_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl)); */
 	lock_sock(sk);
@@ -370,7 +370,7 @@
 static int set_mcast_if(struct sock *sk, char *ifname)
 {
 	struct net_device *dev;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	if ((dev = __dev_get_by_name(ifname)) == NULL)
 		return -ENODEV;
diff -Nru a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/netfilter/ip_conntrack_core.c	2004-12-25 23:46:53 -02:00
@@ -1229,7 +1229,7 @@
 static int
 getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ip_conntrack_tuple_hash *h;
 	struct ip_conntrack_tuple tuple;
 	
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/raw.c	2004-12-25 23:46:53 -02:00
@@ -109,7 +109,7 @@
 	struct hlist_node *node;
 
 	sk_for_each_from(sk, node) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 
 		if (inet->num == num 					&&
 		    !(inet->daddr && inet->daddr != raddr) 		&&
@@ -181,7 +181,7 @@
 
 void raw_err (struct sock *sk, struct sk_buff *skb, u32 info)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int type = skb->h.icmph->type;
 	int code = skb->h.icmph->code;
 	int err = 0;
@@ -263,7 +263,7 @@
 			struct rtable *rt, 
 			unsigned int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int hh_len;
 	struct iphdr *iph;
 	struct sk_buff *skb;
@@ -374,7 +374,7 @@
 static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
 	int free = 0;
@@ -537,7 +537,7 @@
 /* This gets rid of all the nasties in af_inet. -DaveM */
 static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *addr = (struct sockaddr_in *) uaddr;
 	int ret = -EINVAL;
 	int chk_addr_ret;
@@ -565,7 +565,7 @@
 int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len, int noblock, int flags, int *addr_len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
@@ -802,7 +802,7 @@
 
 static __inline__ char *get_raw_sock(struct sock *sp, char *tmpbuf, int i)
 {
-	struct inet_opt *inet = inet_sk(sp);
+	struct inet_sock *inet = inet_sk(sp);
 	unsigned int dest = inet->daddr,
 		     src = inet->rcv_saddr;
 	__u16 destp = 0,
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp.c	2004-12-25 23:46:53 -02:00
@@ -460,7 +460,7 @@
 
 int tcp_listen_start(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt;
 
@@ -1772,7 +1772,7 @@
 
 int tcp_disconnect(struct sock *sk, int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	int err = 0;
 	int old_state = sk->sk_state;
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp_diag.c	2004-12-25 23:46:53 -02:00
@@ -55,7 +55,7 @@
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
 			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcpdiagmsg *r;
 	struct nlmsghdr  *nlh;
@@ -427,7 +427,7 @@
 	if (cb->nlh->nlmsg_len > 4 + NLMSG_SPACE(sizeof(*r))) {
 		struct tcpdiag_entry entry;
 		struct rtattr *bc = (struct rtattr *)(r + 1);
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 
 		entry.family = sk->sk_family;
 #ifdef CONFIG_IP_TCPDIAG_IPV6
@@ -458,7 +458,7 @@
 			    struct open_request *req,
 			    u32 pid, u32 seq)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	unsigned char *b = skb->tail;
 	struct tcpdiagmsg *r;
 	struct nlmsghdr *nlh;
@@ -515,7 +515,7 @@
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt;
 	struct rtattr *bc = NULL;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int j, s_j;
 	int reqnum, s_reqnum;
 	int err = 0;
@@ -609,7 +609,7 @@
 
 			num = 0;
 			sk_for_each(sk, node, &tcp_listening_hash[i]) {
-				struct inet_opt *inet = inet_sk(sk);
+				struct inet_sock *inet = inet_sk(sk);
 
 				if (num < s_num) {
 					num++;
@@ -670,7 +670,7 @@
 
 		num = 0;
 		sk_for_each(sk, node, &head->chain) {
-			struct inet_opt *inet = inet_sk(sk);
+			struct inet_sock *inet = inet_sk(sk);
 
 			if (num < s_num)
 				goto next_normal;
@@ -692,7 +692,7 @@
 		if (r->tcpdiag_states&TCPF_TIME_WAIT) {
 			sk_for_each(sk, node,
 				    &tcp_ehash[i + tcp_ehash_size].chain) {
-				struct inet_opt *inet = inet_sk(sk);
+				struct inet_sock *inet = inet_sk(sk);
 
 				if (num < s_num)
 					goto next_dying;
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp_input.c	2004-12-25 23:46:53 -02:00
@@ -1647,7 +1647,7 @@
 #if FASTRETRANS_DEBUG > 1
 static void DBGUNDO(struct sock *sk, struct tcp_opt *tp, const char *msg)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	printk(KERN_DEBUG "Undo %s %u.%u.%u.%u/%u c%u l%u ss%u/%u p%u\n",
 	       msg,
 	       NIPQUAD(inet->daddr), ntohs(inet->dport),
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp_ipv4.c	2004-12-25 23:46:53 -02:00
@@ -115,7 +115,7 @@
 
 static __inline__ int tcp_sk_hashfn(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	__u32 laddr = inet->rcv_saddr;
 	__u16 lport = inet->num;
 	__u32 faddr = inet->daddr;
@@ -300,7 +300,7 @@
  */
 static void __tcp_put_port(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_bind_hashbucket *head = &tcp_bhash[tcp_bhashfn(inet->num)];
 	struct tcp_bind_bucket *tb;
 
@@ -420,7 +420,7 @@
 
 	hiscore=-1;
 	sk_for_each(sk, node, head) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 
 		if (inet->num == hnum && !ipv6_only_sock(sk)) {
 			__u32 rcv_saddr = inet->rcv_saddr;
@@ -457,7 +457,7 @@
 	read_lock(&tcp_lhash_lock);
 	head = &tcp_listening_hash[tcp_lhashfn(hnum)];
 	if (!hlist_empty(head)) {
-		struct inet_opt *inet = inet_sk((sk = __sk_head(head)));
+		struct inet_sock *inet = inet_sk((sk = __sk_head(head)));
 
 		if (inet->num == hnum && !sk->sk_node.next &&
 		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
@@ -549,7 +549,7 @@
 static int __tcp_v4_check_established(struct sock *sk, __u16 lport,
 				      struct tcp_tw_bucket **twp)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	u32 daddr = inet->rcv_saddr;
 	u32 saddr = inet->daddr;
 	int dif = sk->sk_bound_dev_if;
@@ -755,7 +755,7 @@
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	struct rtable *rt;
@@ -929,7 +929,7 @@
 				     u32 mtu)
 {
 	struct dst_entry *dst;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 
 	/* We are not interested in TCP_LISTEN and open_requests (SYN-ACKs
@@ -992,7 +992,7 @@
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
 	struct tcp_opt *tp;
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	int type = skb->h.icmph->type;
 	int code = skb->h.icmph->code;
 	struct sock *sk;
@@ -1139,7 +1139,7 @@
 void tcp_v4_send_check(struct sock *sk, struct tcphdr *th, int len,
 		       struct sk_buff *skb)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	if (skb->ip_summed == CHECKSUM_HW) {
 		th->check = ~tcp_v4_check(th, len, inet->saddr, inet->daddr, 0);
@@ -1561,7 +1561,7 @@
 				  struct open_request *req,
 				  struct dst_entry *dst)
 {
-	struct inet_opt *newinet;
+	struct inet_sock *newinet;
 	struct tcp_opt *newtp;
 	struct sock *newsk;
 
@@ -1868,7 +1868,7 @@
 
 static int tcp_v4_reselect_saddr(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int err;
 	struct rtable *rt;
 	__u32 old_saddr = inet->saddr;
@@ -1919,7 +1919,7 @@
 
 int tcp_v4_rebuild_header(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct rtable *rt = (struct rtable *)__sk_dst_check(sk, 0);
 	u32 daddr;
 	int err;
@@ -1968,7 +1968,7 @@
 static void v4_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 {
 	struct sockaddr_in *sin = (struct sockaddr_in *) uaddr;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	sin->sin_family		= AF_INET;
 	sin->sin_addr.s_addr	= inet->daddr;
@@ -1983,7 +1983,7 @@
 
 int tcp_v4_remember_stamp(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct rtable *rt = (struct rtable *)__sk_dst_get(sk);
 	struct inet_peer *peer = NULL;
@@ -2486,7 +2486,7 @@
 	int timer_active;
 	unsigned long timer_expires;
 	struct tcp_opt *tp = tcp_sk(sp);
-	struct inet_opt *inet = inet_sk(sp);
+	struct inet_sock *inet = inet_sk(sp);
 	unsigned int dest = inet->daddr;
 	unsigned int src = inet->rcv_saddr;
 	__u16 destp = ntohs(inet->dport);
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp_minisocks.c	2004-12-25 23:46:53 -02:00
@@ -337,7 +337,7 @@
 		tw = kmem_cache_alloc(tcp_timewait_cachep, SLAB_ATOMIC);
 
 	if(tw != NULL) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 		int rto = (tp->rto<<2) - (tp->rto>>1);
 
 		/* Give us an identity. */
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp_output.c	2004-12-25 23:46:53 -02:00
@@ -266,7 +266,7 @@
 static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	if (skb != NULL) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 		struct tcp_opt *tp = tcp_sk(sk);
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 		int tcp_header_size = tp->tcp_header_len;
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/tcp_timer.c	2004-12-25 23:46:53 -02:00
@@ -332,7 +332,7 @@
 		 */
 #ifdef TCP_DEBUG
 		if (net_ratelimit()) {
-			struct inet_opt *inet = inet_sk(sk);
+			struct inet_sock *inet = inet_sk(sk);
 			printk(KERN_DEBUG "TCP: Treason uncloaked! Peer %u.%u.%u.%u:%u/%u shrinks window %u:%u. Repaired.\n",
 			       NIPQUAD(inet->daddr), htons(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv4/udp.c	2004-12-25 23:46:53 -02:00
@@ -124,7 +124,7 @@
 {
 	struct hlist_node *node;
 	struct sock *sk2;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 
 	write_lock_bh(&udp_hash_lock);
 	if (snum == 0) {
@@ -171,7 +171,7 @@
 	} else {
 		sk_for_each(sk2, node,
 			    &udp_hash[snum & (UDP_HTABLE_SIZE - 1)]) {
-			struct inet_opt *inet2 = inet_sk(sk2);
+			struct inet_sock *inet2 = inet_sk(sk2);
 
 			if (inet2->num == snum &&
 			    sk2 != sk &&
@@ -227,7 +227,7 @@
 	int badness = -1;
 
 	sk_for_each(sk, node, &udp_hash[hnum & (UDP_HTABLE_SIZE - 1)]) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 
 		if (inet->num == hnum && !ipv6_only_sock(sk)) {
 			int score = (sk->sk_family == PF_INET ? 1 : 0);
@@ -285,7 +285,7 @@
 	unsigned short hnum = ntohs(loc_port);
 
 	sk_for_each_from(s, node) {
-		struct inet_opt *inet = inet_sk(s);
+		struct inet_sock *inet = inet_sk(s);
 
 		if (inet->num != hnum					||
 		    (inet->daddr && inet->daddr != rmt_addr)		||
@@ -316,7 +316,7 @@
 
 void udp_err(struct sk_buff *skb, u32 info)
 {
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	struct iphdr *iph = (struct iphdr*)skb->data;
 	struct udphdr *uh = (struct udphdr*)(skb->data+(iph->ihl<<2));
 	int type = skb->h.icmph->type;
@@ -398,7 +398,7 @@
  */
 static int udp_push_pending_frames(struct sock *sk, struct udp_opt *up)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	struct sk_buff *skb;
 	struct udphdr *uh;
@@ -480,7 +480,7 @@
 int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct udp_opt *up = udp_sk(sk);
 	int ulen = len;
 	struct ipcm_cookie ipc;
@@ -773,7 +773,7 @@
 int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len, int noblock, int flags, int *addr_len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
   	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
   	struct sk_buff *skb;
   	int copied, err;
@@ -864,7 +864,7 @@
 
 int udp_disconnect(struct sock *sk, int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	/*
 	 *	1003.1g - break association.
 	 */
@@ -1503,7 +1503,7 @@
 /* ------------------------------------------------------------------------ */
 static void udp4_format_sock(struct sock *sp, char *tmpbuf, int bucket)
 {
-	struct inet_opt *inet = inet_sk(sp);
+	struct inet_sock *inet = inet_sk(sp);
 	unsigned int dest = inet->daddr;
 	unsigned int src  = inet->rcv_saddr;
 	__u16 destp	  = ntohs(inet->dport);
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv6/af_inet6.c	2004-12-25 23:46:53 -02:00
@@ -114,10 +114,9 @@
 
 static int inet6_create(struct socket *sock, int protocol)
 {
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	struct ipv6_pinfo *np;
 	struct sock *sk;
-	struct tcp6_sock* tcp6sk;
 	struct list_head *p;
 	struct inet_protosw *answer;
 	struct proto *answer_prot;
@@ -196,8 +195,7 @@
 
 	sk->sk_backlog_rcv	= answer->prot->backlog_rcv;
 
-	tcp6sk		= (struct tcp6_sock *)sk;
-	tcp6sk->pinet6 = np = inet6_sk_generic(sk);
+	inet_sk(sk)->pinet6 = np = inet6_sk_generic(sk);
 	np->hop_limit	= -1;
 	np->mcast_hops	= -1;
 	np->mc_loop	= 1;
@@ -252,7 +250,7 @@
 {
 	struct sockaddr_in6 *addr=(struct sockaddr_in6 *)uaddr;
 	struct sock *sk = sock->sk;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	__u32 v4addr = 0;
 	unsigned short snum;
@@ -410,7 +408,7 @@
 {
 	struct sockaddr_in6 *sin=(struct sockaddr_in6 *)uaddr;
 	struct sock *sk = sock->sk;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
   
 	sin->sin6_family = AF_INET6;
diff -Nru a/net/ipv6/datagram.c b/net/ipv6/datagram.c
--- a/net/ipv6/datagram.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv6/datagram.c	2004-12-25 23:46:53 -02:00
@@ -36,7 +36,7 @@
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
-	struct inet_opt      	*inet = inet_sk(sk);
+	struct inet_sock      	*inet = inet_sk(sk);
 	struct ipv6_pinfo      	*np = inet6_sk(sk);
 	struct in6_addr		*daddr, *final_p = NULL, final;
 	struct dst_entry	*dst;
@@ -335,7 +335,7 @@
 			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
-			struct inet_opt *inet = inet_sk(sk);
+			struct inet_sock *inet = inet_sk(sk);
 
 			ipv6_addr_set(&sin->sin6_addr, 0, 0,
 				      htonl(0xffff),
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv6/ip6_output.c	2004-12-25 23:46:53 -02:00
@@ -809,7 +809,7 @@
 		    int hlimit, struct ipv6_txoptions *opt, struct flowi *fl, struct rt6_info *rt,
 		    unsigned int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
 	unsigned int maxfraglen, fragheaderlen;
@@ -1087,7 +1087,7 @@
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
 	struct in6_addr final_dst_buf, *final_dst = &final_dst_buf;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
@@ -1165,7 +1165,7 @@
 
 void ip6_flush_pending_frames(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
 
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv6/raw.c	2004-12-25 23:46:53 -02:00
@@ -178,7 +178,7 @@
 /* This cleans up af_inet6 a bit. -DaveM */
 static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *addr = (struct sockaddr_in6 *) uaddr;
 	__u32 v4addr = 0;
@@ -253,7 +253,7 @@
 	       struct inet6_skb_parm *opt,
 	       int type, int code, int offset, u32 info)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	int err;
 	int harderr;
@@ -314,7 +314,7 @@
  */
 int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct raw6_opt *raw_opt = raw6_sk(sk);
 
         if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb)) {
@@ -505,7 +505,7 @@
 			struct flowi *fl, struct rt6_info *rt, 
 			unsigned int flags)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 	unsigned int hh_len;
@@ -607,7 +607,7 @@
 	struct ipv6_txoptions opt_space;
 	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
 	struct in6_addr *daddr, *final_p = NULL, final;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct raw6_opt *raw_opt = raw6_sk(sk);
 	struct ipv6_txoptions *opt = NULL;
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv6/tcp_ipv6.c	2004-12-25 23:46:53 -02:00
@@ -89,7 +89,7 @@
 
 static __inline__ int tcp_v6_sk_hashfn(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *laddr = &np->rcv_saddr;
 	struct in6_addr *faddr = &np->daddr;
@@ -443,7 +443,7 @@
 
 static int tcp_v6_check_established(struct sock *sk)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *daddr = &np->rcv_saddr;
 	struct in6_addr *saddr = &np->daddr;
@@ -549,7 +549,7 @@
 			  int addr_len)
 {
 	struct sockaddr_in6 *usin = (struct sockaddr_in6 *) uaddr;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p = NULL, final;
@@ -785,7 +785,7 @@
 		dst = __sk_dst_check(sk, np->dst_cookie);
 
 		if (dst == NULL) {
-			struct inet_opt *inet = inet_sk(sk);
+			struct inet_sock *inet = inet_sk(sk);
 			struct flowi fl;
 
 			/* BUGGG_FUTURE: Again, it is not clear how
@@ -1281,7 +1281,7 @@
 {
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct tcp6_sock *newtcp6sk;
-	struct inet_opt *newinet;
+	struct inet_sock *newinet;
 	struct tcp_opt *newtp;
 	struct sock *newsk;
 	struct ipv6_txoptions *opt;
@@ -1297,7 +1297,7 @@
 			return NULL;
 
 		newtcp6sk = (struct tcp6_sock *)newsk;
-		newtcp6sk->pinet6 = &newtcp6sk->inet6;
+		newtcp6sk->inet.pinet6 = &newtcp6sk->inet6;
 
 		newinet = inet_sk(newsk);
 		newnp = inet6_sk(newsk);
@@ -1390,7 +1390,7 @@
 		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
-	newtcp6sk->pinet6 = &newtcp6sk->inet6;
+	newtcp6sk->inet.pinet6 = &newtcp6sk->inet6;
 
 	newtp = tcp_sk(newsk);
 	newinet = inet_sk(newsk);
@@ -1754,7 +1754,7 @@
 	dst = __sk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 		struct in6_addr *final_p = NULL, final;
 		struct flowi fl;
 
@@ -1800,7 +1800,7 @@
 static int tcp_v6_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk = skb->sk;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi fl;
 	struct dst_entry *dst;
@@ -2006,7 +2006,7 @@
 	__u16 destp, srcp;
 	int timer_active;
 	unsigned long timer_expires;
-	struct inet_opt *inet = inet_sk(sp);
+	struct inet_sock *inet = inet_sk(sp);
 	struct tcp_opt *tp = tcp_sk(sp);
 	struct ipv6_pinfo *np = inet6_sk(sp);
 
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2004-12-25 23:46:53 -02:00
+++ b/net/ipv6/udp.c	2004-12-25 23:46:53 -02:00
@@ -160,7 +160,7 @@
 
  	read_lock(&udp_hash_lock);
 	sk_for_each(sk, node, &udp_hash[hnum & (UDP_HTABLE_SIZE - 1)]) {
-		struct inet_opt *inet = inet_sk(sk);
+		struct inet_sock *inet = inet_sk(sk);
 
 		if (inet->num == hnum && sk->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
@@ -269,7 +269,7 @@
 		sin6->sin6_scope_id = 0;
 
 		if (skb->protocol == htons(ETH_P_IP)) {
-			struct inet_opt *inet = inet_sk(sk);
+			struct inet_sock *inet = inet_sk(sk);
 
 			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
 				      htonl(0xffff), skb->nh.iph->saddr);
@@ -386,7 +386,7 @@
 	unsigned short num = ntohs(loc_port);
 
 	sk_for_each_from(s, node) {
-		struct inet_opt *inet = inet_sk(s);
+		struct inet_sock *inet = inet_sk(s);
 
 		if (inet->num == num && s->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(s);
@@ -566,7 +566,7 @@
 {
 	struct sk_buff *skb;
 	struct udphdr *uh;
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
 
@@ -624,7 +624,7 @@
 {
 	struct ipv6_txoptions opt_space;
 	struct udp_opt *up = udp_sk(sk);
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
 	struct in6_addr *daddr, *final_p = NULL, final;
@@ -970,7 +970,7 @@
 
 static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket)
 {
-	struct inet_opt *inet = inet_sk(sp);
+	struct inet_sock *inet = inet_sk(sp);
 	struct ipv6_pinfo *np = inet6_sk(sp);
 	struct in6_addr *dest, *src;
 	__u16 destp, srcp;
diff -Nru a/net/sctp/input.c b/net/sctp/input.c
--- a/net/sctp/input.c	2004-12-25 23:46:53 -02:00
+++ b/net/sctp/input.c	2004-12-25 23:46:53 -02:00
@@ -393,7 +393,7 @@
 	struct sctp_endpoint *ep;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
-	struct inet_opt *inet;
+	struct inet_sock *inet;
 	char *saveip, *savesctp;
 	int err;
 
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2004-12-25 23:46:53 -02:00
+++ b/net/sctp/ipv6.c	2004-12-25 23:46:53 -02:00
@@ -580,9 +580,9 @@
 struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 				      struct sctp_association *asoc)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	struct sock *newsk;
-	struct inet_opt *newinet;
+	struct inet_sock *newinet;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 
@@ -608,7 +608,7 @@
 	newsk->sk_shutdown = sk->sk_shutdown;
 
 	newsctp6sk = (struct sctp6_sock *)newsk;
-	newsctp6sk->pinet6 = &newsctp6sk->inet6;
+	newsctp6sk->inet.pinet6 = &newsctp6sk->inet6;
 
 	newinet = inet_sk(newsk);
 	newnp = inet6_sk(newsk);
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2004-12-25 23:46:53 -02:00
+++ b/net/sctp/protocol.c	2004-12-25 23:46:53 -02:00
@@ -551,8 +551,8 @@
 				      struct sctp_association *asoc)
 {
 	struct sock *newsk;
-	struct inet_opt *inet = inet_sk(sk);
-	struct inet_opt *newinet;
+	struct inet_sock *inet = inet_sk(sk);
+	struct inet_sock *newinet;
 
 	newsk = sk_alloc(PF_INET, GFP_KERNEL, sk->sk_prot->slab_obj_size,
 			 sk->sk_prot->slab);
diff -Nru a/security/selinux/avc.c b/security/selinux/avc.c
--- a/security/selinux/avc.c	2004-12-25 23:46:53 -02:00
+++ b/security/selinux/avc.c	2004-12-25 23:46:53 -02:00
@@ -566,7 +566,7 @@
 
 				switch (sk->sk_family) {
 				case AF_INET: {
-					struct inet_opt *inet = inet_sk(sk);
+					struct inet_sock *inet = inet_sk(sk);
 
 					avc_print_ipv4_addr(ab, inet->rcv_saddr,
 							    inet->sport,
@@ -577,7 +577,7 @@
 					break;
 				}
 				case AF_INET6: {
-					struct inet_opt *inet = inet_sk(sk);
+					struct inet_sock *inet = inet_sk(sk);
 					struct ipv6_pinfo *inet6 = inet6_sk(sk);
 
 					avc_print_ipv6_addr(ab, &inet6->rcv_saddr,


--------------060000020103000505000009--
