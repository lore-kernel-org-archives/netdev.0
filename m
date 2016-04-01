From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net 4/4] ipv6: udp: Do a route lookup and update during release_cb
Date: Fri, 1 Apr 2016 15:56:31 -0700
Message-ID: <1459551391-69969-5-git-send-email-kafai@fb.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37467 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753769AbcDAW5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 18:57:32 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u31Muhvl008219
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 15:57:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2220rv8c2c-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 15:57:31 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1d118c8af85d11e5956a0002c9dfb610-107f43f0 for <netdev@vger.kernel.org>;	Fri,
 01 Apr 2016 15:57:30 -0700
In-Reply-To: <1459551391-69969-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a release_cb for UDPv6.  It does a route lookup
and updates sk->sk_dst_cache if it is needed.  It picks up the
left-over job from ip6_sk_update_pmtu() if the sk is owned
by user during the pmtu update.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Wei Wang <weiwan@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Wei Wang <weiwan@google.com>
---
 include/net/ipv6.h  |  1 +
 net/ipv6/datagram.c | 12 ++++++++++++
 net/ipv6/udp.c      |  1 +
 3 files changed, 14 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fd02e90..1be050a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -960,6 +960,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
 				 int addr_len);
 int ip6_datagram_dst_update(struct sock *sk, bool fix_sk_saddr);
+void ip6_datagram_release_cb(struct sock *sk);
 
 int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 0b60f1e..a4f06bd 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -119,6 +119,18 @@ out:
 	return err;
 }
 
+void ip6_datagram_release_cb(struct sock *sk)
+{
+	struct dst_entry *dst;
+
+	dst = __sk_dst_get(sk);
+	if (!dst || dst->ops->check(dst, inet6_sk(sk)->dst_cookie))
+		return;
+
+	ip6_datagram_dst_update(sk, false);
+}
+EXPORT_SYMBOL_GPL(ip6_datagram_release_cb);
+
 static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8125931..6bc5c66 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1539,6 +1539,7 @@ struct proto udpv6_prot = {
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
 	.backlog_rcv	   = __udpv6_queue_rcv_skb,
+	.release_cb	   = ip6_datagram_release_cb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v6_rehash,
-- 
2.5.1
