From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 06/15] tcp: Fix conditions to determine checksum offload
Date: Thu, 19 Nov 2015 11:55:52 -0800
Message-ID: <1447962961-2106059-7-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:13719 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759278AbbKST4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:16 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJrBQu032543
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:16 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt6nby-7
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:16 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 978a69488ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:15 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
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
index 7f89e4b..8ba056e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1794,6 +1794,15 @@ static inline void sk_nocaps_add(struct sock *sk, netdev_features_t flags)
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
index 47f2741..1ab2949 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1019,7 +1019,7 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 	ssize_t res;
 
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
-	    !(sk->sk_route_caps & NETIF_F_CSUM_MASK))
+	    !sk_check_csum_caps(sk))
 		return sock_no_sendpage(sk->sk_socket, page, offset, size,
 					flags);
 
@@ -1176,7 +1176,7 @@ new_segment:
 			/*
 			 * Check whether we can use HW checksum.
 			 */
-			if (sk->sk_route_caps & NETIF_F_CSUM_MASK)
+			if (sk_check_csum_caps(sk))
 				skb->ip_summed = CHECKSUM_PARTIAL;
 
 			skb_entail(sk, skb);
-- 
2.4.6
