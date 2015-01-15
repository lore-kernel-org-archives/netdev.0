From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] ip: zero sockaddr returned on error queue
Date: Thu, 15 Jan 2015 13:18:40 -0500
Message-ID: <1421345920-13994-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:62099 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbbAOSSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:18:54 -0500
Received: by mail-yh0-f50.google.com with SMTP id b6so8004835yha.9
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 10:18:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The sockaddr is returned in IP(V6)_RECVERR as part of errhdr. That
structure is defined and allocated on the stack as

    struct {
            struct sock_extended_err ee;
            struct sockaddr_in(6)    offender;
    } errhdr;

The second part is only initialized for certain SO_EE_ORIGIN values.
Always initialize it completely.

An MTU exceeded error on a SOCK_RAW/IPPROTO_RAW is one example that
would return uninitialized bytes.

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

Also verified that there is no padding between errhdr.ee and
errhdr.offender that could leak additional kernel data.
---
 net/ipv4/ip_sockglue.c |  8 ++------
 net/ipv6/datagram.c    | 10 +++-------
 2 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8a89c73..6b85adb 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -461,17 +461,13 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
 	sin = &errhdr.offender;
-	sin->sin_family = AF_UNSPEC;
+	memset(sin, 0, sizeof(*sin));
 
 	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
 	    ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin)) {
-		struct inet_sock *inet = inet_sk(sk);
-
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
-		sin->sin_port = 0;
-		memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
-		if (inet->cmsg_flags)
+		if (inet_sk(sk)->cmsg_flags)
 			ip_cmsg_recv(msg, skb);
 	}
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 100c589..49f5e73 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -393,11 +393,10 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
 	sin = &errhdr.offender;
-	sin->sin6_family = AF_UNSPEC;
+	memset(sin, 0, sizeof(*sin));
+
 	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
 		sin->sin6_family = AF_INET6;
-		sin->sin6_flowinfo = 0;
-		sin->sin6_port = 0;
 		if (np->rxopt.all) {
 			if (serr->ee.ee_origin != SO_EE_ORIGIN_ICMP &&
 			    serr->ee.ee_origin != SO_EE_ORIGIN_ICMP6)
@@ -412,12 +411,9 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 				ipv6_iface_scope_id(&sin->sin6_addr,
 						    IP6CB(skb)->iif);
 		} else {
-			struct inet_sock *inet = inet_sk(sk);
-
 			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
 					       &sin->sin6_addr);
-			sin->sin6_scope_id = 0;
-			if (inet->cmsg_flags)
+			if (inet_sk(sk)->cmsg_flags)
 				ip_cmsg_recv(msg, skb);
 		}
 	}
-- 
2.2.0.rc0.207.ga3a616c
