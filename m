From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have a TCP_TIMEWAIT sk
Date: Wed, 1 Jul 2015 13:13:09 -0700
Message-ID: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>, <edumazet@google.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35783 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752069AbbGAUNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 16:13:15 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t61KBdGN018520
	for <netdev@vger.kernel.org>; Wed, 1 Jul 2015 13:13:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1vcmhpraaw-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 13:13:15 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 9a8c23f4202d11e5a0dd0002c9931860-9bbf32b0 for <netdev@vger.kernel.org>;	Wed,
 01 Jul 2015 13:13:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we early-demux bind a TCP_TIMEWAIT socket to an skb and then orphan it
(as we need to do in the ipvs forwarding case), sock_wfree and sock_rfree
are going to reach into the inet_timewait_sock and mess with fields that
don't exist.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/core/sock.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 1e1fe9a..b37328f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1620,6 +1620,9 @@ void sock_wfree(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 	unsigned int len = skb->truesize;
 
+	if (sk->sk_state == TCP_TIME_WAIT)
+		return;
+
 	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
 		/*
 		 * Keep a reference on sk_wmem_alloc, this will be released
@@ -1665,6 +1668,9 @@ void sock_rfree(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 	unsigned int len = skb->truesize;
 
+	if (sk->sk_state == TCP_TIME_WAIT)
+		return;
+
 	atomic_sub(len, &sk->sk_rmem_alloc);
 	sk_mem_uncharge(sk, len);
 }
-- 
Alex Gartrell <agartrell@fb.com>
