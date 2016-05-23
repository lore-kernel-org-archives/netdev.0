From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 4/7] tcp: Support for TOU
Date: Mon, 23 May 2016 15:48:23 -0700
Message-ID: <1464043706-2843932-5-git-send-email-tom@herbertland.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50126 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752066AbcEWWsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:48:52 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4NMkx64024132
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2341q73793-6
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:51 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7edbb7b6213811e697a70002c9931860-31cbd6d0 for <netdev@vger.kernel.org>;	Mon,
 23 May 2016 15:48:41 -0700
In-Reply-To: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to adjust MSS to account for encapsulation overhead. This is done
by add encpasulation header length into icsk_ext_hdr_len.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/tcp_ipv4.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3708de2..c344f667 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -74,6 +74,7 @@
 #include <net/xfrm.h>
 #include <net/secure_seq.h>
 #include <net/busy_poll.h>
+#include <net/tou.h>
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
@@ -205,9 +206,9 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_dport = usin->sin_port;
 	sk_daddr_set(sk, daddr);
 
-	inet_csk(sk)->icsk_ext_hdr_len = 0;
+	inet_csk(sk)->icsk_ext_hdr_len = tou_hdr_len(sk);
 	if (inet_opt)
-		inet_csk(sk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
+		inet_csk(sk)->icsk_ext_hdr_len += inet_opt->opt.optlen;
 
 	tp->rx_opt.mss_clamp = TCP_MSS_DEFAULT;
 
@@ -1296,9 +1297,9 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 	newinet->mc_index     = inet_iif(skb);
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	newinet->rcv_tos      = ip_hdr(skb)->tos;
-	inet_csk(newsk)->icsk_ext_hdr_len = 0;
+	inet_csk(sk)->icsk_ext_hdr_len = tou_hdr_len(sk);
 	if (inet_opt)
-		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
+		inet_csk(newsk)->icsk_ext_hdr_len += inet_opt->opt.optlen;
 	newinet->inet_id = newtp->write_seq ^ jiffies;
 
 	if (!dst) {
-- 
2.8.0.rc2
