From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 06/13] tcp: Add tcp_inq to get available receive bytes on socket
Date: Mon, 7 Mar 2016 14:11:05 -0800
Message-ID: <1457388672-2600559-7-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47155 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753707AbcCGWMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:12:05 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27MA80Q003222
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:12:04 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hgcygj8y-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:12:04 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 9eec85e4e4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:12:03 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a common kernel function to get the number of bytes available
on a TCP socket. This is based on code in INQ getsockopt and we now call
the function for that getsockopt.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/tcp.h | 24 ++++++++++++++++++++++++
 net/ipv4/tcp.c    | 15 +--------------
 2 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e90db85..0302636 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1816,4 +1816,28 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
 	skb->truesize = 2;
 }
 
+static inline int tcp_inq(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int answ;
+
+	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
+		answ = 0;
+	} else if (sock_flag(sk, SOCK_URGINLINE) ||
+		   !tp->urg_data ||
+		   before(tp->urg_seq, tp->copied_seq) ||
+		   !before(tp->urg_seq, tp->rcv_nxt)) {
+
+		answ = tp->rcv_nxt - tp->copied_seq;
+
+		/* Subtract 1, if FIN was received */
+		if (answ && sock_flag(sk, SOCK_DONE))
+			answ--;
+	} else {
+		answ = tp->urg_seq - tp->copied_seq;
+	}
+
+	return answ;
+}
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f9faadb..a265f00 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -556,20 +556,7 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			return -EINVAL;
 
 		slow = lock_sock_fast(sk);
-		if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))
-			answ = 0;
-		else if (sock_flag(sk, SOCK_URGINLINE) ||
-			 !tp->urg_data ||
-			 before(tp->urg_seq, tp->copied_seq) ||
-			 !before(tp->urg_seq, tp->rcv_nxt)) {
-
-			answ = tp->rcv_nxt - tp->copied_seq;
-
-			/* Subtract 1, if FIN was received */
-			if (answ && sock_flag(sk, SOCK_DONE))
-				answ--;
-		} else
-			answ = tp->urg_seq - tp->copied_seq;
+		answ = tcp_inq(sk);
 		unlock_sock_fast(sk, slow);
 		break;
 	case SIOCATMARK:
-- 
2.6.5
