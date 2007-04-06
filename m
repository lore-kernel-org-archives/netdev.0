From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 3/4] Add mapped address type inline
Date: Thu, 05 Apr 2007 23:21:25 -0400
Message-ID: <4615BCB5.2020609@hp.com>
References: <11758281863002-git-send-email-brian.haley@hp.com> <117582818660-git-send-email-brian.haley@hp.com> <11758281864173-git-send-email-brian.haley@hp.com>,	<151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:34155 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767520AbXDFDmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 23:42:20 -0400
In-Reply-To: <151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add mapped address type inline to avoid calls to ipv6_addr_type().

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
  include/net/ipv6.h       |    6 ++++++
  net/ipv6/ip6_flowlabel.c |    6 ++----
  net/ipv6/ipv6_sockglue.c |    2 +-
  net/ipv6/tcp_ipv6.c      |   13 +++++--------
  net/ipv6/udp.c           |    2 +-
  net/sctp/ipv6.c          |    4 ++--
  6 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a888b0e..f3e13db 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -444,6 +444,12 @@ static inline int ipv6_addr_type_multicast(const struct in6_addr *a)
  	return ((a->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000));
  }

+static inline int ipv6_addr_type_mapped(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 &&
+		 a->s6_addr32[2] == htonl(0x0000ffff));
+}
+
  /*
   *	Prototypes exported by ipv6
   */
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index c206a15..b1bd088 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -282,7 +282,6 @@ fl_create(struct in6_flowlabel_req *freq, char __user *optval, int optlen, int *
  {
  	struct ip6_flowlabel *fl;
  	int olen;
-	int addr_type;
  	int err;

  	err = -ENOMEM;
@@ -328,9 +327,8 @@ fl_create(struct in6_flowlabel_req *freq, char __user *optval, int optlen, int *
  	if (err)
  		goto done;
  	fl->share = freq->flr_share;
-	addr_type = ipv6_addr_type(&freq->flr_dst);
-	if ((addr_type&IPV6_ADDR_MAPPED)
-	    || addr_type == IPV6_ADDR_ANY) {
+	if (ipv6_addr_type_mapped(&freq->flr_dst) ||
+	    ipv6_addr_any(&freq->flr_dst)) {
  		err = -EINVAL;
  		goto done;
  	}
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index aa3d07c..d83e982 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -249,7 +249,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
  			}

  			if (ipv6_only_sock(sk) ||
-			    !(ipv6_addr_type(&np->daddr) & IPV6_ADDR_MAPPED)) {
+			    !ipv6_addr_type_mapped(&np->daddr)) {
  				retv = -EADDRNOTAVAIL;
  				break;
  			}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 537978c..a47d23d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -132,7 +132,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
  	struct in6_addr *saddr = NULL, *final_p = NULL, final;
  	struct flowi fl;
  	struct dst_entry *dst;
-	int addr_type;
  	int err;

  	if (addr_len < SIN6_LEN_RFC2133)
@@ -163,12 +162,10 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
  	if(ipv6_addr_any(&usin->sin6_addr))
  		usin->sin6_addr.s6_addr[15] = 0x1;

-	addr_type = ipv6_addr_type(&usin->sin6_addr);
-
-	if(addr_type & IPV6_ADDR_MULTICAST)
+	if (ipv6_addr_type_multicast(&usin->sin6_addr))
  		return -ENETUNREACH;

-	if (addr_type&IPV6_ADDR_LINKLOCAL) {
+	if (ipv6_addr_scope_linklocal(&usin->sin6_addr)) {
  		if (addr_len >= sizeof(struct sockaddr_in6) &&
  		    usin->sin6_scope_id) {
  			/* If interface is set while binding, indices
@@ -200,7 +197,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
  	 *	TCP over IPv4
  	 */

-	if (addr_type == IPV6_ADDR_MAPPED) {
+	if (ipv6_addr_type_mapped(&usin->sin6_addr)) {
  		u32 exthdrlen = icsk->icsk_ext_hdr_len;
  		struct sockaddr_in sin;

@@ -703,7 +703,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
  	if (!cmd.tcpm_keylen) {
  		if (!tcp_sk(sk)->md5sig_info)
  			return -ENOENT;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED)
+		if (ipv6_addr_type_mapped(&sin6->sin6_addr))
  			return tcp_v4_md5_do_del(sk, sin6->sin6_addr.s6_addr32[3]);
  		return tcp_v6_md5_do_del(sk, &sin6->sin6_addr);
  	}
@@ -725,7 +725,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
  	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
  	if (!newkey)
  		return -ENOMEM;
-	if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED) {
+	if (ipv6_addr_type_mapped(&sin6->sin6_addr)) {
  		return tcp_v4_md5_do_add(sk, sin6->sin6_addr.s6_addr32[3],
  					 newkey, cmd.tcpm_keylen);
  	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c0b5fe3..6636431 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -610,7 +610,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
  		daddr = NULL;

  	if (daddr) {
-		if (ipv6_addr_type(daddr) == IPV6_ADDR_MAPPED) {
+		if (ipv6_addr_type_mapped(daddr)) {
  			struct sockaddr_in sin;
  			sin.sin_family = AF_INET;
  			sin.sin_port = sin6 ? sin6->sin6_port : inet->dport;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index c1f4a8f..af06d4b 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -481,7 +481,7 @@ static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
  	if (addr1->sa.sa_family != addr2->sa.sa_family) {
  		if (addr1->sa.sa_family == AF_INET &&
  		    addr2->sa.sa_family == AF_INET6 &&
-		    IPV6_ADDR_MAPPED == ipv6_addr_type(&addr2->v6.sin6_addr)) {
+		    ipv6_addr_type_mapped(&addr2->v6.sin6_addr)) {
  			if (addr2->v6.sin6_port == addr1->v4.sin_port &&
  			    addr2->v6.sin6_addr.s6_addr32[3] ==
  			    addr1->v4.sin_addr.s_addr)
@@ -489,7 +489,7 @@ static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
  		}
  		if (addr2->sa.sa_family == AF_INET &&
  		    addr1->sa.sa_family == AF_INET6 &&
-		    IPV6_ADDR_MAPPED == ipv6_addr_type(&addr1->v6.sin6_addr)) {
+		    ipv6_addr_type_mapped(&addr1->v6.sin6_addr)) {
  			if (addr1->v6.sin6_port == addr2->v4.sin_port &&
  			    addr1->v6.sin6_addr.s6_addr32[3] ==
  			    addr2->v4.sin_addr.s_addr)
-- 
1.5.0.3

