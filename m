From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/6][SCTP]: Reject sctp packets with broadcast addresses.
Date: Thu, 15 Jun 2006 15:46:19 -0700
Message-ID: <1150411579.6028.32.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:39104 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750711AbWFOWrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 18:47:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5FMl776019984
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:08 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5FMl65Q265632
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5FMl51M010177
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:06 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Reject sctp packets with broadcast addresses.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 include/net/sctp/structs.h |    3 ++-
 net/sctp/input.c           |    3 ++-
 net/sctp/ipv6.c            |    6 ++++--
 net/sctp/protocol.c        |    8 +++++++-
 net/sctp/socket.c          |    2 +-
 5 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -555,7 +555,8 @@ struct sctp_af {
 	int		(*to_addr_param) (const union sctp_addr *,
 					  union sctp_addr_param *); 
 	int		(*addr_valid)	(union sctp_addr *,
-					 struct sctp_sock *);
+					 struct sctp_sock *,
+					 const struct sk_buff *);
 	sctp_scope_t	(*scope) (union sctp_addr *);
 	void		(*inaddr_any)	(union sctp_addr *, unsigned short);
 	int		(*is_any)	(const union sctp_addr *);
diff --git a/net/sctp/input.c b/net/sctp/input.c
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -170,7 +170,8 @@ int sctp_rcv(struct sk_buff *skb)
 	 * IP broadcast addresses cannot be used in an SCTP transport
 	 * address."
 	 */
-	if (!af->addr_valid(&src, NULL) || !af->addr_valid(&dest, NULL))
+	if (!af->addr_valid(&src, NULL, skb) ||
+	    !af->addr_valid(&dest, NULL, skb))
 		goto discard_it;
 
 	asoc = __sctp_rcv_lookup(skb, &src, &dest, &transport);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -523,7 +523,9 @@ static int sctp_v6_available(union sctp_
  * Return 0 - If the address is a non-unicast or an illegal address.
  * Return 1 - If the address is a unicast.
  */
-static int sctp_v6_addr_valid(union sctp_addr *addr, struct sctp_sock *sp)
+static int sctp_v6_addr_valid(union sctp_addr *addr,
+			      struct sctp_sock *sp,
+			      const struct sk_buff *skb)
 {
 	int ret = ipv6_addr_type(&addr->v6.sin6_addr);
 
@@ -537,7 +539,7 @@ static int sctp_v6_addr_valid(union sctp
 		if (sp && ipv6_only_sock(sctp_opt2sk(sp)))
 			return 0;
 		sctp_v6_map_v4(addr);
-		return sctp_get_af_specific(AF_INET)->addr_valid(addr, sp);
+		return sctp_get_af_specific(AF_INET)->addr_valid(addr, sp, skb);
 	}
 
 	/* Is this a non-unicast address */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -365,12 +365,18 @@ static int sctp_v4_is_any(const union sc
  * Return 0 - If the address is a non-unicast or an illegal address.
  * Return 1 - If the address is a unicast.
  */
-static int sctp_v4_addr_valid(union sctp_addr *addr, struct sctp_sock *sp)
+static int sctp_v4_addr_valid(union sctp_addr *addr,
+			      struct sctp_sock *sp,
+			      const struct sk_buff *skb)
 {
 	/* Is this a non-unicast address or a unusable SCTP address? */
 	if (IS_IPV4_UNUSABLE_ADDRESS(&addr->v4.sin_addr.s_addr))
 		return 0;
 
+ 	/* Is this a broadcast address? */
+ 	if (skb && ((struct rtable *)skb->dst)->rt_flags & RTCF_BROADCAST)
+ 		return 0;
+
 	return 1;
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -172,7 +172,7 @@ static inline int sctp_verify_addr(struc
 		return -EINVAL;
 
 	/* Is this a valid SCTP address?  */
-	if (!af->addr_valid(addr, sctp_sk(sk)))
+	if (!af->addr_valid(addr, sctp_sk(sk), NULL))
 		return -EINVAL;
 
 	if (!sctp_sk(sk)->pf->send_verify(sctp_sk(sk), (addr)))


