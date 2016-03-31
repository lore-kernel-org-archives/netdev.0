From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 6/4] tcp: fix __sk_dst_get usage in tcp_current_mss
Date: Fri,  1 Apr 2016 01:56:07 +0200
Message-ID: <1459468567-3927-1-git-send-email-hannes@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45873 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755198AbcCaX4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:56:12 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 68A5B20C4A
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:56:11 -0400 (EDT)
In-Reply-To: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/tcp_output.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ba3621834e7bfa..3f70582578ada0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1426,21 +1426,21 @@ EXPORT_SYMBOL(tcp_sync_mss);
 unsigned int tcp_current_mss(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst;
 	u32 mss_now;
 	unsigned int header_len;
 	struct tcp_out_options opts;
 	struct tcp_md5sig_key *md5;
 
+	rcu_read_lock();
 	mss_now = tp->mss_cache;
-
+	dst = __sk_dst_get(sk);
 	if (dst) {
 		u32 mtu = dst_mtu(dst);
 		if (mtu != inet_csk(sk)->icsk_pmtu_cookie)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
-	rcu_read_lock();
 	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
 		     sizeof(struct tcphdr);
 	rcu_read_unlock();
-- 
2.5.5
