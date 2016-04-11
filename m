From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net 4/4] ipv6: udp: Do a route lookup and update during release_cb
Date: Mon, 11 Apr 2016 15:29:37 -0700
Message-ID: <1460413777-177662-5-git-send-email-kafai@fb.com>
References: <1460413777-177662-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:4521 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691AbcDKW3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:29:53 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3BMTMPr031443
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:29:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 226wda2mmr-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:29:52 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 e6a54d46003411e6a9fa24be0595f910-ef5f63f0 for <netdev@vger.kernel.org>;	Mon,
 11 Apr 2016 15:29:49 -0700
In-Reply-To: <1460413777-177662-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a release_cb for UDPv6.  It does a route lookup
and updates sk->sk_dst_cache if it is needed.  It picks up the
left-over job from ip6_sk_update_pmtu() if the sk was owned
by user during the pmtu update.

It takes a rcu_read_lock to protect the __sk_dst_get() operations
because another thread may do ip6_dst_store() without taking the
sk lock (e.g. sendmsg).

Fixes: 45e4fd26683c ("ipv6: Only create RTF_CACHE routes after encountering pmtu exception")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Wei Wang <weiwan@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Wei Wang <weiwan@google.com>
---
 include/net/ipv6.h  |  1 +
 net/ipv6/datagram.c | 20 ++++++++++++++++++++
 net/ipv6/udp.c      |  1 +
 3 files changed, 22 insertions(+)

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
index 59e01f27..9dd3882 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -119,6 +119,26 @@ out:
 	return err;
 }
 
+void ip6_datagram_release_cb(struct sock *sk)
+{
+	struct dst_entry *dst;
+
+	if (ipv6_addr_v4mapped(&sk->sk_v6_daddr))
+		return;
+
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
+	if (!dst || !dst->obsolete ||
+	    dst->ops->check(dst, inet6_sk(sk)->dst_cookie)) {
+		rcu_read_unlock();
+		return;
+	}
+	rcu_read_unlock();
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
