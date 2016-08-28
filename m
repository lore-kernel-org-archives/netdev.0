From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/3] tcp: Set read_sock and peek_len proto_ops
Date: Sun, 28 Aug 2016 14:43:18 -0700
Message-ID: <1472420599-510735-3-git-send-email-tom@herbertland.com>
References: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davejwatson@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51395 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932346AbcH1Vnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 17:43:42 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7SLfxQl017071
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2536p3mvgg-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:42 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 7c1d12146d6811e69e7b0002c9dfb610-cecfcaa0 for <netdev@vger.kernel.org>;        Sun,
 28 Aug 2016 14:43:40 -0700
In-Reply-To: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In inet_stream_ops we set read_sock to tcp_read_sock and peek_len to
tcp_peek_len (which is just a stub function that calls tcp_inq).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/tcp.h   | 2 ++
 net/ipv4/af_inet.c  | 2 ++
 net/ipv4/tcp.c      | 6 ++++++
 net/ipv6/af_inet6.c | 2 ++
 4 files changed, 12 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d56666a..a5af6be 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1848,6 +1848,8 @@ static inline int tcp_inq(struct sock *sk)
 	return answ;
 }
 
+int tcp_peek_len(struct socket *sock);
+
 static inline void tcp_segs_in(struct tcp_sock *tp, const struct sk_buff *skb)
 {
 	u16 segs_in;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 989a362..e94b47b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -916,6 +916,8 @@ const struct proto_ops inet_stream_ops = {
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 	.splice_read	   = tcp_splice_read,
+	.read_sock	   = tcp_read_sock,
+	.peek_len	   = tcp_peek_len,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f1a9a0a..60a4388 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1570,6 +1570,12 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 }
 EXPORT_SYMBOL(tcp_read_sock);
 
+int tcp_peek_len(struct socket *sock)
+{
+	return tcp_inq(sock->sk);
+}
+EXPORT_SYMBOL(tcp_peek_len);
+
 /*
  *	This routine copies from a sock struct into the user buffer.
  *
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b454055..46ad699 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -545,6 +545,8 @@ const struct proto_ops inet6_stream_ops = {
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 	.splice_read	   = tcp_splice_read,
+	.read_sock	   = tcp_read_sock,
+	.peek_len	   = tcp_peek_len,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
-- 
2.8.0.rc2
