From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: use ipv6_addr_set_v4mapped()
Date: Wed, 07 Oct 2009 11:47:34 -0400
Message-ID: <4ACCB816.2000902@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: david Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:35701 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318AbZJGPsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 11:48:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Might as well use the ipv6_addr_set_v4mapped() inline we created last
year.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index e48ca5d..a2afb55 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -510,11 +510,9 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set(&newnp->daddr, 0, 0, htonl(0x0000FFFF),
-			      newinet->daddr);
+		ipv6_addr_set_v4mapped(newinet->daddr, &newnp->daddr);
 
-		ipv6_addr_set(&newnp->saddr, 0, 0, htonl(0x0000FFFF),
-			      newinet->saddr);
+		ipv6_addr_set_v4mapped(newinet->saddr, &newnp->saddr);
 
 		ipv6_addr_copy(&newnp->rcv_saddr, &newnp->saddr);
 
@@ -971,10 +969,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			sk->sk_backlog_rcv = dccp_v6_do_rcv;
 			goto failure;
 		} else {
-			ipv6_addr_set(&np->saddr, 0, 0, htonl(0x0000FFFF),
-				      inet->saddr);
-			ipv6_addr_set(&np->rcv_saddr, 0, 0, htonl(0x0000FFFF),
-				      inet->rcv_saddr);
+			ipv6_addr_set_v4mapped(inet->saddr, &np->saddr);
+			ipv6_addr_set_v4mapped(inet->rcv_saddr, &np->rcv_saddr);
 		}
 
 		return err;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e2bdc6d..6ebf0ff 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -98,17 +98,14 @@ ipv4_connected:
 		if (err)
 			goto out;
 
-		ipv6_addr_set(&np->daddr, 0, 0, htonl(0x0000ffff), inet->daddr);
+		ipv6_addr_set_v4mapped(inet->daddr, &np->daddr);
 
-		if (ipv6_addr_any(&np->saddr)) {
-			ipv6_addr_set(&np->saddr, 0, 0, htonl(0x0000ffff),
-				      inet->saddr);
-		}
+		if (ipv6_addr_any(&np->saddr))
+			ipv6_addr_set_v4mapped(inet->saddr, &np->saddr);
+
+		if (ipv6_addr_any(&np->rcv_saddr))
+			ipv6_addr_set_v4mapped(inet->rcv_saddr, &np->rcv_saddr);
 
-		if (ipv6_addr_any(&np->rcv_saddr)) {
-			ipv6_addr_set(&np->rcv_saddr, 0, 0, htonl(0x0000ffff),
-				      inet->rcv_saddr);
-		}
 		goto out;
 	}
 
@@ -329,9 +326,8 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
-			ipv6_addr_set(&sin->sin6_addr, 0, 0,
-				      htonl(0xffff),
-				      *(__be32 *)(nh + serr->addr_offset));
+			ipv6_addr_set_v4mapped(*(__be32 *)(nh + serr->addr_offset),
+					       &sin->sin6_addr);
 		}
 	}
 
@@ -351,8 +347,8 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		} else {
 			struct inet_sock *inet = inet_sk(sk);
 
-			ipv6_addr_set(&sin->sin6_addr, 0, 0,
-				      htonl(0xffff), ip_hdr(skb)->saddr);
+			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
+					       &sin->sin6_addr);
 			if (inet->cmsg_flags)
 				ip_cmsg_recv(msg, skb);
 		}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 21d100b..93dad9a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -226,10 +226,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 #endif
 			goto failure;
 		} else {
-			ipv6_addr_set(&np->saddr, 0, 0, htonl(0x0000FFFF),
-				      inet->saddr);
-			ipv6_addr_set(&np->rcv_saddr, 0, 0, htonl(0x0000FFFF),
-				      inet->rcv_saddr);
+			ipv6_addr_set_v4mapped(inet->saddr, &np->saddr);
+			ipv6_addr_set_v4mapped(inet->rcv_saddr, &np->rcv_saddr);
 		}
 
 		return err;
@@ -1290,11 +1288,9 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set(&newnp->daddr, 0, 0, htonl(0x0000FFFF),
-			      newinet->daddr);
+		ipv6_addr_set_v4mapped(newinet->daddr, &newnp->daddr);
 
-		ipv6_addr_set(&newnp->saddr, 0, 0, htonl(0x0000FFFF),
-			      newinet->saddr);
+		ipv6_addr_set_v4mapped(newinet->saddr, &newnp->saddr);
 
 		ipv6_addr_copy(&newnp->rcv_saddr, &newnp->saddr);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3a60f12..0dae3f7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -265,8 +265,8 @@ try_again:
 		sin6->sin6_scope_id = 0;
 
 		if (is_udp4)
-			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
-				      htonl(0xffff), ip_hdr(skb)->saddr);
+			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
+					       &sin6->sin6_addr);
 		else {
 			ipv6_addr_copy(&sin6->sin6_addr,
 				       &ipv6_hdr(skb)->saddr);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 117f68a..f4c7ff3 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -686,8 +686,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	case AF_INET:
 		sin = svc_addr_in(rqstp);
 		sin6 = &sin6_storage;
-		ipv6_addr_set(&sin6->sin6_addr, 0, 0,
-				htonl(0x0000FFFF), sin->sin_addr.s_addr);
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &sin6->sin6_addr);
 		break;
 	case AF_INET6:
 		sin6 = svc_addr_in6(rqstp);
