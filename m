From: Brian Haley <brian.haley@hp.com>
Subject: [IPv6] Add v4mapped address inline
Date: Thu, 23 Aug 2007 12:40:54 -0400
Message-ID: <46CDB896.8040408@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020609040004090001020108"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:51015 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947AbXHWQl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 12:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020609040004090001020108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Add v4mapped address inline to avoid calls to ipv6_addr_type().

--------------020609040004090001020108
Content-Type: text/x-patch;
 name="v4mapped.inline.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="v4mapped.inline.patch"

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9059e0e..c2b6c11 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -418,6 +418,12 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
+static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 && 
+		 a->s6_addr32[2] == htonl(0x0000ffff)); 
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 761a910..92d8119 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -249,7 +249,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			}
 
 			if (ipv6_only_sock(sk) ||
-			    !(ipv6_addr_type(&np->daddr) & IPV6_ADDR_MAPPED)) {
+			    !ipv6_addr_v4mapped(&np->daddr)) {
 				retv = -EADDRNOTAVAIL;
 				break;
 			}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0f7defb..d5c0175 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -697,7 +697,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 	if (!cmd.tcpm_keylen) {
 		if (!tcp_sk(sk)->md5sig_info)
 			return -ENOENT;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED)
+		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 			return tcp_v4_md5_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
 		return tcp_v6_md5_do_del(sk, &sin6->sin6_addr);
 	}
@@ -720,7 +720,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 	if (!newkey)
 		return -ENOMEM;
-	if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED) {
+	if (ipv6_addr_v4mapped(&sin6->sin6_addr)) {
 		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
 					 newkey, cmd.tcpm_keylen);
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4210951..3e0ca15 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -610,7 +610,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		daddr = NULL;
 
 	if (daddr) {
-		if (ipv6_addr_type(daddr) == IPV6_ADDR_MAPPED) {
+		if (ipv6_addr_v4mapped(daddr)) {
 			struct sockaddr_in sin;
 			sin.sin_family = AF_INET;
 			sin.sin_port = sin6 ? sin6->sin6_port : inet->dport;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index f8aa23d..cd57a51 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -481,7 +481,7 @@ static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
 	if (addr1->sa.sa_family != addr2->sa.sa_family) {
 		if (addr1->sa.sa_family == AF_INET &&
 		    addr2->sa.sa_family == AF_INET6 &&
-		    IPV6_ADDR_MAPPED == ipv6_addr_type(&addr2->v6.sin6_addr)) {
+		    ipv6_addr_v4mapped(&addr2->v6.sin6_addr)) {
 			if (addr2->v6.sin6_port == addr1->v4.sin_port &&
 			    addr2->v6.sin6_addr.s6_addr32[3] ==
 			    addr1->v4.sin_addr.s_addr)
@@ -489,7 +489,7 @@ static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
 		}
 		if (addr2->sa.sa_family == AF_INET &&
 		    addr1->sa.sa_family == AF_INET6 &&
-		    IPV6_ADDR_MAPPED == ipv6_addr_type(&addr1->v6.sin6_addr)) {
+		    ipv6_addr_v4mapped(&addr1->v6.sin6_addr)) {
 			if (addr1->v6.sin6_port == addr2->v4.sin_port &&
 			    addr1->v6.sin6_addr.s6_addr32[3] ==
 			    addr2->v4.sin_addr.s_addr)

--------------020609040004090001020108--
