From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/2][UDP]: Make full use of proto.h.udp_hash innovation.
Date: Tue, 18 Mar 2008 14:53:36 +0300
Message-ID: <47DFAD40.1000609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52119 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbYCRLyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 07:54:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this we have only udp_lib_get_port to get the port and two 
stubs for ipv4 and ipv6. No difference in udp and udplite except
for initialized h.udp_hash member.

I tried to find a graceful way to drop the only difference between
udp_v4_get_port and udp_v6_get_port (i.e. the rcv_saddr comparison 
routine), but adding one more callback on the struct proto didn't 
appear such :( Maybe later.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 include/net/udp.h   |    2 ++
 net/ipv4/udp.c      |   22 ++++++++--------------
 net/ipv4/udp_impl.h |    6 +-----
 net/ipv4/udplite.c  |   15 ++-------------
 net/ipv6/udp.c      |    5 +++--
 net/ipv6/udp_impl.h |    2 ++
 net/ipv6/udplite.c  |    8 ++------
 7 files changed, 20 insertions(+), 40 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index c6669c0..c3c7963 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -125,6 +125,8 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
+extern int	udp_lib_get_port(struct sock *sk, unsigned short snum,
+		int (*)(const struct sock*,const struct sock*));
 
 /* net/ipv4/udp.c */
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7ea1b67..ef72fe8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -143,18 +143,17 @@ static inline int __udp_lib_lport_inuse(struct net *net, __u16 num,
 }
 
 /**
- *  __udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
+ *  udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
  *
  *  @sk:          socket struct in question
  *  @snum:        port number to look up
- *  @udptable:    hash list table, must be of UDP_HTABLE_SIZE
  *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
  */
-int __udp_lib_get_port(struct sock *sk, unsigned short snum,
-		       struct hlist_head udptable[],
+int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       int (*saddr_comp)(const struct sock *sk1,
 					 const struct sock *sk2 )    )
 {
+	struct hlist_head *udptable = sk->sk_prot->h.udp_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct sock *sk2;
@@ -240,13 +239,7 @@ fail:
 	return error;
 }
 
-int udp_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *))
-{
-	return  __udp_lib_get_port(sk, snum, udp_hash, scmp);
-}
-
-int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
@@ -255,9 +248,9 @@ int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 		   inet1->rcv_saddr == inet2->rcv_saddr      ));
 }
 
-static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
+int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
 
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
@@ -1498,6 +1491,7 @@ struct proto udp_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp_sock),
+	.h.udp_hash	   = udp_hash,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
@@ -1717,12 +1711,12 @@ EXPORT_SYMBOL(udp_disconnect);
 EXPORT_SYMBOL(udp_hash);
 EXPORT_SYMBOL(udp_hash_lock);
 EXPORT_SYMBOL(udp_ioctl);
-EXPORT_SYMBOL(udp_get_port);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
 EXPORT_SYMBOL(udp_lib_getsockopt);
 EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
+EXPORT_SYMBOL(udp_lib_get_port);
 
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 6c55828..7288bf7 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -8,11 +8,7 @@
 extern int  	__udp4_lib_rcv(struct sk_buff *, struct hlist_head [], int );
 extern void 	__udp4_lib_err(struct sk_buff *, u32, struct hlist_head []);
 
-extern int	__udp_lib_get_port(struct sock *sk, unsigned short snum,
-				   struct hlist_head udptable[],
-				   int (*)(const struct sock*,const struct sock*));
-extern int	ipv4_rcv_saddr_equal(const struct sock *, const struct sock *);
-
+extern int	udp_v4_get_port(struct sock *sk, unsigned short snum);
 
 extern int	udp_setsockopt(struct sock *sk, int level, int optname,
 			       char __user *optval, int optlen);
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index d49c6d6..f9f0dd2 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -17,17 +17,6 @@ DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics)	__read_mostly;
 
 struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
 
-int udplite_get_port(struct sock *sk, unsigned short p,
-		     int (*c)(const struct sock *, const struct sock *))
-{
-	return  __udp_lib_get_port(sk, p, udplite_hash, c);
-}
-
-static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
-{
-	return udplite_get_port(sk, snum, ipv4_rcv_saddr_equal);
-}
-
 static int udplite_rcv(struct sk_buff *skb)
 {
 	return __udp4_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
@@ -63,8 +52,9 @@ struct proto 	udplite_prot = {
 	.backlog_rcv	   = udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
-	.get_port	   = udplite_v4_get_port,
+	.get_port	   = udp_v4_get_port,
 	.obj_size	   = sizeof(struct udp_sock),
+	.h.udp_hash	   = udplite_hash,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
@@ -118,4 +108,3 @@ out_register_err:
 
 EXPORT_SYMBOL(udplite_hash);
 EXPORT_SYMBOL(udplite_prot);
-EXPORT_SYMBOL(udplite_get_port);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d6e311f..c3c938a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -51,9 +51,9 @@
 #include <linux/seq_file.h>
 #include "udp_impl.h"
 
-static inline int udp_v6_get_port(struct sock *sk, unsigned short snum)
+int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);
+	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
 
 static struct sock *__udp6_lib_lookup(struct net *net,
@@ -1024,6 +1024,7 @@ struct proto udpv6_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp6_sock),
+	.h.udp_hash	   = udp_hash,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 21be3a8..321b81a 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -11,6 +11,8 @@ extern int  	__udp6_lib_rcv(struct sk_buff *, struct hlist_head [], int );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
 			       int , int , int , __be32 , struct hlist_head []);
 
+extern int	udp_v6_get_port(struct sock *sk, unsigned short snum);
+
 extern int	udpv6_getsockopt(struct sock *sk, int level, int optname,
 				 char __user *optval, int __user *optlen);
 extern int	udpv6_setsockopt(struct sock *sk, int level, int optname,
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 87d4202..af296da 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -35,11 +35,6 @@ static struct inet6_protocol udplitev6_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-static int udplite_v6_get_port(struct sock *sk, unsigned short snum)
-{
-	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
-}
-
 DEFINE_PROTO_INUSE(udplitev6)
 
 struct proto udplitev6_prot = {
@@ -58,8 +53,9 @@ struct proto udplitev6_prot = {
 	.backlog_rcv	   = udpv6_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
-	.get_port	   = udplite_v6_get_port,
+	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
+	.h.udp_hash	   = udplite_hash,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
