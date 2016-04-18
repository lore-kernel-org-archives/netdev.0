From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 5/7] tcp: Make use of MSG_EOR in tcp_sendpage
Date: Mon, 18 Apr 2016 15:46:07 -0700
Message-ID: <1461019569-3037369-6-git-send-email-kafai@fb.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56251 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbcDRWqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:30 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3IMg8EI024738
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22d1mut8wc-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:29 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 63504a1205b711e6b3640002c991e86a-ad3f7c50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:28 -0700
In-Reply-To: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It reuses the tcp_sendmsg_noappend() to decide if a new_segment
is needed before entering the loop.  More checks could be added
later for the tcp_sendpage case to decide if a new_segment is
needed immediately.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2918f42..6bb33b8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -913,6 +913,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
 
+	if (tcp_sendmsg_noappend(sk, sk->sk_tsflags))
+		goto new_segment;
+
 	while (size > 0) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		int copy, i;
@@ -969,7 +972,7 @@ new_segment:
 		offset += copy;
 		size -= copy;
 		if (!size) {
-			tcp_tx_timestamp(sk, sk->sk_tsflags, skb, 0);
+			tcp_tx_timestamp(sk, sk->sk_tsflags, skb, flags);
 			goto out;
 		}
 
-- 
2.5.1
