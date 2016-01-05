From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] soreuseport: pass skb to secondary UDP socket lookup
Date: Tue,  5 Jan 2016 15:08:07 -0500
Message-ID: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36242 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbcAEUIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 15:08:11 -0500
Received: by mail-qk0-f179.google.com with SMTP id q19so89637221qke.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 12:08:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This socket-lookup path did not pass along the skb in question
in my original BPF-based socket selection patch.  The skb in the
udpN_lib_lookup2 path can be used for BPF-based socket selection just
like it is in the 'traditional' udpN_lib_lookup path.

udpN_lib_lookup2 kicks in when there are greater than 10 sockets in
the same hlist slot.  Coincidentally, I chose 10 sockets per
reuseport group in my functional test, so the lookup2 path was not
excersised. This adds an additional set of tests with 20 sockets.

Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
Fixes: 3ca8e4029969 ("soreuseport: BPF selection functional test")
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/ipv4/udp.c                              | 10 +++---
 net/ipv6/udp.c                              | 10 +++---
 tools/testing/selftests/net/reuseport_bpf.c | 47 +++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 835378365f25..3a66731e3af6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -493,7 +493,8 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct udp_hslot *hslot2, unsigned int slot2,
+		struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -514,7 +515,8 @@ begin:
 				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
+				sk2 = reuseport_select_sock(sk, hash, skb,
+							    sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -573,7 +575,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 		result = udp4_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  hslot2, slot2, skb);
 		if (!result) {
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
 			slot2 = hash2 & udptable->mask;
@@ -583,7 +585,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 			result = udp4_lib_lookup2(net, saddr, sport,
 						  htonl(INADDR_ANY), hnum, dif,
-						  hslot2, slot2);
+						  hslot2, slot2, skb);
 		}
 		rcu_read_unlock();
 		return result;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 56fcb55fda31..5d2c2afffe7b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -251,7 +251,8 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct udp_hslot *hslot2, unsigned int slot2,
+		struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -272,7 +273,8 @@ begin:
 				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
+				sk2 = reuseport_select_sock(sk, hash, skb,
+							    sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -331,7 +333,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 		result = udp6_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  hslot2, slot2, skb);
 		if (!result) {
 			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
 			slot2 = hash2 & udptable->mask;
@@ -341,7 +343,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 			result = udp6_lib_lookup2(net, saddr, sport,
 						  &in6addr_any, hnum, dif,
-						  hslot2, slot2);
+						  hslot2, slot2, skb);
 		}
 		rcu_read_unlock();
 		return result;
diff --git a/tools/testing/selftests/net/reuseport_bpf.c b/tools/testing/selftests/net/reuseport_bpf.c
index 74ff09988958..bec1b5dd2530 100644
--- a/tools/testing/selftests/net/reuseport_bpf.c
+++ b/tools/testing/selftests/net/reuseport_bpf.c
@@ -123,6 +123,8 @@ static void attach_ebpf(int fd, uint16_t mod)
 	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_REUSEPORT_EBPF, &bpf_fd,
 			sizeof(bpf_fd)))
 		error(1, errno, "failed to set SO_ATTACH_REUSEPORT_EBPF");
+
+	close(bpf_fd);
 }
 
 static void attach_cbpf(int fd, uint16_t mod)
@@ -396,6 +398,9 @@ static void test_filter_without_bind(void)
 int main(void)
 {
 	fprintf(stderr, "---- IPv4 UDP ----\n");
+	/* NOTE: UDP socket lookups traverse a different code path when there
+	 * are > 10 sockets in a group.  Run the bpf test through both paths.
+	 */
 	test_reuseport_ebpf((struct test_params) {
 		.recv_family = AF_INET,
 		.send_family = AF_INET,
@@ -403,6 +408,13 @@ int main(void)
 		.recv_socks = 10,
 		.recv_port = 8000,
 		.send_port_min = 9000});
+	test_reuseport_ebpf((struct test_params) {
+		.recv_family = AF_INET,
+		.send_family = AF_INET,
+		.protocol = SOCK_DGRAM,
+		.recv_socks = 20,
+		.recv_port = 8000,
+		.send_port_min = 9000});
 	test_reuseport_cbpf((struct test_params) {
 		.recv_family = AF_INET,
 		.send_family = AF_INET,
@@ -410,6 +422,13 @@ int main(void)
 		.recv_socks = 10,
 		.recv_port = 8001,
 		.send_port_min = 9020});
+	test_reuseport_cbpf((struct test_params) {
+		.recv_family = AF_INET,
+		.send_family = AF_INET,
+		.protocol = SOCK_DGRAM,
+		.recv_socks = 20,
+		.recv_port = 8001,
+		.send_port_min = 9020});
 	test_extra_filter((struct test_params) {
 		.recv_family = AF_INET,
 		.protocol = SOCK_DGRAM,
@@ -427,6 +446,13 @@ int main(void)
 		.recv_socks = 10,
 		.recv_port = 8003,
 		.send_port_min = 9040});
+	test_reuseport_ebpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET6,
+		.protocol = SOCK_DGRAM,
+		.recv_socks = 20,
+		.recv_port = 8003,
+		.send_port_min = 9040});
 	test_reuseport_cbpf((struct test_params) {
 		.recv_family = AF_INET6,
 		.send_family = AF_INET6,
@@ -434,6 +460,13 @@ int main(void)
 		.recv_socks = 10,
 		.recv_port = 8004,
 		.send_port_min = 9060});
+	test_reuseport_cbpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET6,
+		.protocol = SOCK_DGRAM,
+		.recv_socks = 20,
+		.recv_port = 8004,
+		.send_port_min = 9060});
 	test_extra_filter((struct test_params) {
 		.recv_family = AF_INET6,
 		.protocol = SOCK_DGRAM,
@@ -448,6 +481,13 @@ int main(void)
 		.recv_family = AF_INET6,
 		.send_family = AF_INET,
 		.protocol = SOCK_DGRAM,
+		.recv_socks = 20,
+		.recv_port = 8006,
+		.send_port_min = 9080});
+	test_reuseport_ebpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET,
+		.protocol = SOCK_DGRAM,
 		.recv_socks = 10,
 		.recv_port = 8006,
 		.send_port_min = 9080});
@@ -458,6 +498,13 @@ int main(void)
 		.recv_socks = 10,
 		.recv_port = 8007,
 		.send_port_min = 9100});
+	test_reuseport_cbpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET,
+		.protocol = SOCK_DGRAM,
+		.recv_socks = 20,
+		.recv_port = 8007,
+		.send_port_min = 9100});
 
 
 	test_filter_without_bind();
-- 
2.6.0.rc2.230.g3dd15c0
