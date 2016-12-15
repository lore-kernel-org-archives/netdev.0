From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] inet: Don't go into port scan when looking for specific bind port
Date: Wed, 14 Dec 2016 16:54:15 -0800
Message-ID: <20161215005416.1561632-2-tom@herbertland.com>
References: <20161215005416.1561632-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <jbacik@fb.com>, <eric.dumazet@gmail.com>,
        <raigatgoog@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34996 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932559AbcLOAym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:54:42 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBF0saSR027825
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 16:54:36 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27bdmqhxkv-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 16:54:36 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 0b65e8f4c26111e6902d0002c992ebde-a1dfca50 for <netdev@vger.kernel.org>;        Wed,
 14 Dec 2016 16:54:34 -0800
In-Reply-To: <20161215005416.1561632-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_csk_get_port is called with port number (snum argument) that may be
zero or nonzero. If it is zero, then the intent is to find an available
ephemeral port number to bind to. If snum is non-zero then the caller
is asking to allocate a specific port number. In the latter case we
never want to perform the scan in ephemeral port range. It is
conceivable that this can happen if the "goto again" in "tb_found:"
is done. This patch adds a check that snum is zero before doing
the "goto again".

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/inet_connection_sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d5d3ead..f59838a6 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -212,7 +212,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 			      sk->sk_reuseport &&
 			      !rcu_access_pointer(sk->sk_reuseport_cb) &&
 			      uid_eq(tb->fastuid, uid))) &&
-			    smallest_size != -1 && --attempts >= 0) {
+			    !snum && smallest_size != -1 && --attempts >= 0) {
 				spin_unlock_bh(&head->lock);
 				goto again;
 			}
-- 
2.9.3
