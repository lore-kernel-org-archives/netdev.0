From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][NET] Calculate ipv6_pinfo offset from struct proto->slab_obj_size
Date: Sun, 19 Sep 2004 18:06:40 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919210639.GA11844@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.6

Best Regards,

                        - Arnaldo

===================================================================

ChangeSet@1.1937, 2004-09-19 15:26:01-03:00, acme@conectiva.com.br
  [NET] Calculate ipv6_pinfo offset from struct proto->slab_obj_size
  
  With a new rule for the struct sock hierarchy descendants layout,
  that states that the struct ipv6_pinfo member should be last one
  in the struct layout (see tcp6_sock, udp6_sock, sctp6_sock, etc),
  we can calculate the ipv6_pinfo member offset by using
  struct proto->slab_obj_size.
  
  So ditch struct ipv6_sk_offset and struct proto->af_specific.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 include/linux/ipv6.h |   15 +++++++++------
 include/net/sock.h   |    1 -
 net/ipv6/af_inet6.c  |    4 ++--
 net/ipv6/raw.c       |    5 -----
 net/ipv6/tcp_ipv6.c  |    5 -----
 net/ipv6/udp.c       |    5 -----
 net/sctp/socket.c    |    5 -----
 7 files changed, 11 insertions(+), 29 deletions(-)


diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	Sun Sep 19 17:53:25 2004
+++ b/include/linux/ipv6.h	Sun Sep 19 17:53:25 2004
@@ -182,8 +182,7 @@
    as offsets from skb->nh.
  */
 
-struct inet6_skb_parm
-{
+struct inet6_skb_parm {
 	int			iif;
 	__u16			ra;
 	__u16			hop;
@@ -194,6 +193,14 @@
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
 
+/**
+ * struct ipv6_pinfo - ipv6 private area
+ *
+ * In the struct sock hierarchy (tcp6_sock, upd6_sock, etc)
+ * this _must_ be the last member, so that inet6_sk_generic
+ * is able to calculate its offset from the base struct sock
+ * by using the struct proto->slab_obj_size member. -acme
+ */
 struct ipv6_pinfo {
 	struct in6_addr 	saddr;
 	struct in6_addr 	rcv_saddr;
@@ -281,10 +288,6 @@
 {
 	return &((struct raw6_sock *)__sk)->raw6;
 }
-
-struct ipv6_sk_offset {
-	int	offset;
-};
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Sun Sep 19 17:53:25 2004
+++ b/include/net/sock.h	Sun Sep 19 17:53:25 2004
@@ -557,7 +557,6 @@
 
 	kmem_cache_t		*slab;
 	int			slab_obj_size;
-	void			*af_specific;
 
 	char			name[32];
 
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	Sun Sep 19 17:53:25 2004
+++ b/net/ipv6/af_inet6.c	Sun Sep 19 17:53:25 2004
@@ -107,9 +107,9 @@
 
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
-	const struct ipv6_sk_offset *offset = sk->sk_prot->af_specific;
+	const int offset = sk->sk_prot->slab_obj_size - sizeof(struct ipv6_pinfo);
 
-	return (struct ipv6_pinfo *)(((u8 *)sk) + offset->offset);
+	return (struct ipv6_pinfo *)(((u8 *)sk) + offset);
 }
 
 static int inet6_create(struct socket *sock, int protocol)
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Sun Sep 19 17:53:25 2004
+++ b/net/ipv6/raw.c	Sun Sep 19 17:53:25 2004
@@ -973,10 +973,6 @@
 	return(0);
 }
 
-struct ipv6_sk_offset raw_sock_offset = {
-	.offset = offsetof(struct raw6_sock, inet6),
-};
-
 struct proto rawv6_prot = {
 	.name =		"RAW",
 	.close =	rawv6_close,
@@ -994,7 +990,6 @@
 	.hash =		raw_v6_hash,
 	.unhash =	raw_v6_unhash,
 	.slab_obj_size = sizeof(struct raw6_sock),
-	.af_specific =	&raw_sock_offset,
 };
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Sun Sep 19 17:53:25 2004
+++ b/net/ipv6/tcp_ipv6.c	Sun Sep 19 17:53:25 2004
@@ -2120,10 +2120,6 @@
 }
 #endif
 
-struct ipv6_sk_offset tcp_sock_offset = {
-	.offset = offsetof(struct tcp6_sock, inet6),
-};
-
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.close			= tcp_close,
@@ -2151,7 +2147,6 @@
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
 	.slab_obj_size		= sizeof(struct tcp6_sock),
-	.af_specific		= &tcp_sock_offset,
 };
 
 static struct inet6_protocol tcpv6_protocol = {
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	Sun Sep 19 17:53:25 2004
+++ b/net/ipv6/udp.c	Sun Sep 19 17:53:25 2004
@@ -1031,10 +1031,6 @@
 
 /* ------------------------------------------------------------------------ */
 
-struct ipv6_sk_offset udp_sock_offset = {
-	.offset = offsetof(struct udp6_sock, inet6),
-};
-
 struct proto udpv6_prot = {
 	.name =		"UDP",
 	.close =	udpv6_close,
@@ -1051,7 +1047,6 @@
 	.unhash =	udp_v6_unhash,
 	.get_port =	udp_v6_get_port,
 	.slab_obj_size = sizeof(struct udp6_sock),
-	.af_specific =	&udp_sock_offset,
 };
 
 extern struct proto_ops inet6_dgram_ops;
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	Sun Sep 19 17:53:25 2004
+++ b/net/sctp/socket.c	Sun Sep 19 17:53:25 2004
@@ -4626,10 +4626,6 @@
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-struct ipv6_sk_offset sctp_sock_offset = {
-	.offset = offsetof(struct sctp6_sock, inet6),
-};
-
 struct proto sctpv6_prot = {
 	.name		= "SCTPv6",
 	.close		= sctp_close,
@@ -4650,6 +4646,5 @@
 	.unhash		= sctp_unhash,
 	.get_port	= sctp_get_port,
 	.slab_obj_size	= sizeof(struct sctp6_sock),
-	.af_specific	= &sctp_sock_offset,
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
