From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/2] net: Recompute sk_txhash on negative routing advice
Date: Tue, 28 Jul 2015 16:02:06 -0700
Message-ID: <1438124526-2129341-3-git-send-email-tom@herbertland.com>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44101 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751077AbbG1XCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 19:02:35 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6SN1WFB024986
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 16:02:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vxjkqr41x-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 16:02:35 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 bab8c038357c11e5a9070002c991e86a-593fc2b0 for <netdev@vger.kernel.org>;	Tue,
 28 Jul 2015 16:02:33 -0700
In-Reply-To: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a connection is failing a transport protocol calls
dst_negative_advice to try to get a better route. This patch includes
changing the sk_txhash in that function. This provides a rudimentary
method to try to find a different path in the network since sk_txhash
affects ECMP on the local host and through the network (via flow labels
or UDP source port in encapsulation).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/sock.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index fe735c4..24aa75c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1695,6 +1695,12 @@ static inline void sk_set_txhash(struct sock *sk)
 		sk->sk_txhash = 1;
 }
 
+static inline void sk_rethink_txhash(struct sock *sk)
+{
+	if (sk->sk_txhash)
+		sk_set_txhash(sk);
+}
+
 static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
 {
@@ -1719,6 +1725,8 @@ static inline void dst_negative_advice(struct sock *sk)
 {
 	struct dst_entry *ndst, *dst = __sk_dst_get(sk);
 
+	sk_rethink_txhash(sk);
+
 	if (dst && dst->ops->negative_advice) {
 		ndst = dst->ops->negative_advice(dst);
 
-- 
1.8.1
