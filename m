From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH v2 7/8] Allow disabling of DSACK TCP option per route
Date: Wed, 21 Oct 2009 10:57:00 +0200
Message-ID: <1256115421-12714-8-git-send-email-gilad@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:39418 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbZJUI5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:57:08 -0400
In-Reply-To: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add and use no DSCAK bit in the features field.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Sigend-off-by: Ori Finkelman <ori@comsleep.com>
Sigend-off-by: Yony Amit <yony@comsleep.com>

---
 include/linux/rtnetlink.h |    1 +
 net/ipv4/tcp_input.c      |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6784b34..e78b60c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -381,6 +381,7 @@ enum
 #define RTAX_FEATURE_NO_TSTAMP	0x00000004
 #define RTAX_FEATURE_ALLFRAG	0x00000008
 #define RTAX_FEATURE_NO_WSCALE	0x00000010
+#define RTAX_FEATURE_NO_DSACK	0x00000020
 
 struct rta_session
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4f5e914..4262da5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4080,8 +4080,10 @@ static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
 static void tcp_dsack_set(struct sock *sk, u32 seq, u32 end_seq)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = __sk_dst_get(sk);
 
-	if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
+	if (tcp_is_sack(tp) && sysctl_tcp_dsack &&
+	    !dst_feature(dst, RTAX_FEATURE_NO_DSACK)) {
 		int mib_idx;
 
 		if (before(seq, tp->rcv_nxt))
@@ -4110,13 +4112,15 @@ static void tcp_dsack_extend(struct sock *sk, u32 seq, u32 end_seq)
 static void tcp_send_dupack(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 	    before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
 		tcp_enter_quickack_mode(sk);
 
-		if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
+		if (tcp_is_sack(tp) && sysctl_tcp_dsack &&
+		    !dst_feature(dst, RTAX_FEATURE_NO_DSACK)) {
 			u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
 			if (after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))
-- 
1.5.6.3

