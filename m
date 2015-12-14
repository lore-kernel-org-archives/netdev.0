From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 6/8] tcp: Fix conditions to determine checksum offload
Date: Mon, 14 Dec 2015 11:19:45 -0800
Message-ID: <1450120787-1773171-7-git-send-email-tom@herbertland.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:9605 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932194AbbLNTVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:21:07 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBEJI5v6032115
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:21:06 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ys1c86qr7-10
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:21:06 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 cd4bcfc8a29711e593540002c99293a0-b11f8210 for <netdev@vger.kernel.org>;	Mon,
 14 Dec 2015 11:20:58 -0800
In-Reply-To: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcp_send_sendpage and tcp_sendmsg we check the route capabilities to
determine if checksum offload can be performed. This check currently
does not take the IP protocol into account for devices that advertise
only one of NETIF_F_IPV6_CSUM or NETIF_F_IP_CSUM. This patch adds a
function to check capabilities for checksum offload with a socket
called sk_check_csum_caps. This function checks for specific IPv4 or
IPv6 offload support based on the family of the socket.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/sock.h | 9 +++++++++
 net/ipv4/tcp.c     | 4 ++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0ca22b0..ab0269f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1791,6 +1791,15 @@ static inline void sk_nocaps_add(struct sock *sk, netdev_features_t flags)
 	sk->sk_route_caps &= ~flags;
 }
 
+static inline bool sk_check_csum_caps(struct sock *sk)
+{
+	return (sk->sk_route_caps & NETIF_F_HW_CSUM) ||
+	       (sk->sk_family == PF_INET &&
+		(sk->sk_route_caps & NETIF_F_IP_CSUM)) ||
+	       (sk->sk_family == PF_INET6 &&
+		(sk->sk_route_caps & NETIF_F_IPV6_CSUM));
+}
+
 static inline int skb_do_copy_data_nocache(struct sock *sk, struct sk_buff *skb,
 					   struct iov_iter *from, char *to,
 					   int copy, int offset)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf7ef7b..92b3e61 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1018,7 +1018,7 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 	ssize_t res;
 
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
-	    !(sk->sk_route_caps & NETIF_F_CSUM_MASK))
+	    !sk_check_csum_caps(sk))
 		return sock_no_sendpage(sk->sk_socket, page, offset, size,
 					flags);
 
@@ -1175,7 +1175,7 @@ new_segment:
 			/*
 			 * Check whether we can use HW checksum.
 			 */
-			if (sk->sk_route_caps & NETIF_F_CSUM_MASK)
+			if (sk_check_csum_caps(sk))
 				skb->ip_summed = CHECKSUM_PARTIAL;
 
 			skb_entail(sk, skb);
-- 
2.4.6
