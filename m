From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V4 net-next 01/15] net: introduce keepalive function in struct proto
Date: Mon,  9 Jan 2017 16:55:12 +0100
Message-ID: <20170109155526.10961-2-ubraun@linux.vnet.ibm.com>
References: <20170109155526.10961-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45647 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965905AbdAIPzg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:55:36 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09Frv6r031422
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:55:36 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27vd6rh66t-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:55:36 -0500
Received: from localhost
        by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 9 Jan 2017 15:55:33 -0000
In-Reply-To: <20170109155526.10961-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Direct call of tcp_set_keepalive() function from protocol-agnostic
sock_setsockopt() function in net/core/sock.c violates network
layering. And newly introduced protocol (SMC-R) will need its own
keepalive function. Therefore, add "keepalive" function pointer
to "struct proto", and call it from sock_setsockopt() via this pointer.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Utz Bacher <utz.bacher@de.ibm.com>
---
 include/net/sock.h   | 1 +
 net/core/sock.c      | 7 ++-----
 net/ipv4/tcp_ipv4.c  | 1 +
 net/ipv4/tcp_timer.c | 1 +
 net/ipv6/tcp_ipv6.c  | 1 +
 5 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f0e867f..99deda6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1024,6 +1024,7 @@ struct proto {
 	int			(*getsockopt)(struct sock *sk, int level,
 					int optname, char __user *optval,
 					int __user *option);
+	void			(*keepalive)(struct sock *sk, int valbool);
 #ifdef CONFIG_COMPAT
 	int			(*compat_setsockopt)(struct sock *sk,
 					int level,
diff --git a/net/core/sock.c b/net/core/sock.c
index f560e08..5018703 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -762,11 +762,8 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		goto set_rcvbuf;
 
 	case SO_KEEPALIVE:
-#ifdef CONFIG_INET
-		if (sk->sk_protocol == IPPROTO_TCP &&
-		    sk->sk_type == SOCK_STREAM)
-			tcp_set_keepalive(sk, valbool);
-#endif
+		if (sk->sk_prot->keepalive)
+			sk->sk_prot->keepalive(sk, valbool);
 		sock_valbool_flag(sk, SOCK_KEEPOPEN, valbool);
 		break;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7e4be4f..56d756e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2376,6 +2376,7 @@ struct proto tcp_prot = {
 	.shutdown		= tcp_shutdown,
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
+	.keepalive		= tcp_set_keepalive,
 	.recvmsg		= tcp_recvmsg,
 	.sendmsg		= tcp_sendmsg,
 	.sendpage		= tcp_sendpage,
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 3705075..29a9bd5 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -617,6 +617,7 @@ void tcp_set_keepalive(struct sock *sk, int val)
 	else if (!val)
 		inet_csk_delete_keepalive_timer(sk);
 }
+EXPORT_SYMBOL_GPL(tcp_set_keepalive);
 
 
 static void tcp_keepalive_timer (unsigned long data)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a4cdf6a..228965d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1889,6 +1889,7 @@ struct proto tcpv6_prot = {
 	.shutdown		= tcp_shutdown,
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
+	.keepalive		= tcp_set_keepalive,
 	.recvmsg		= tcp_recvmsg,
 	.sendmsg		= tcp_sendmsg,
 	.sendpage		= tcp_sendpage,
-- 
2.8.4
