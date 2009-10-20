From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH RFC] Add the no SACK route option feature
Date: Tue, 20 Oct 2009 17:22:37 +0200
Message-ID: <1256052161-14156-5-git-send-email-gilad@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <1256052161-14156-2-git-send-email-gilad@codefidence.com>
 <1256052161-14156-3-git-send-email-gilad@codefidence.com>
 <1256052161-14156-4-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37470 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZJTPWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 11:22:45 -0400
In-Reply-To: <1256052161-14156-4-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement querying and acting upon the no sack bit in the features
field.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Sigend-off-by: Ori Finkelman <ori@comsleep.com>
Sigend-off-by: Yony Amit <yony@comsleep.com>

---
 include/linux/rtnetlink.h |    2 +-
 net/ipv4/tcp_input.c      |    3 ++-
 net/ipv4/tcp_output.c     |    4 +++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index adf2068..9c802a6 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -377,7 +377,7 @@ enum
 #define RTAX_MAX (__RTAX_MAX - 1)
 
 #define RTAX_FEATURE_ECN	0x00000001
-#define RTAX_FEATURE_SACK	0x00000002
+#define RTAX_FEATURE_NO_SACK	0x00000002
 #define RTAX_FEATURE_TIMESTAMP	0x00000004
 #define RTAX_FEATURE_ALLFRAG	0x00000008
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d502f49..b14f780 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3763,7 +3763,8 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				break;
 			case TCPOPT_SACK_PERM:
 				if (opsize == TCPOLEN_SACK_PERM && th->syn &&
-				    !estab && sysctl_tcp_sack) {
+				    !estab && sysctl_tcp_sack &&
+				    !dst_feature(dst, RTAX_FEATURE_NO_SACK)) {
 					opt_rx->sack_ok = 1;
 					tcp_sack_reset(opt_rx);
 				}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..64db8dd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -464,6 +464,7 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned size = 0;
+	struct dst_entry *dst = __sk_dst_get(sk);
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
@@ -498,7 +499,8 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		opts->options |= OPTION_WSCALE;
 		size += TCPOLEN_WSCALE_ALIGNED;
 	}
-	if (likely(sysctl_tcp_sack)) {
+	if (likely(sysctl_tcp_sack &&
+		   !dst_feature(dst, RTAX_FEATURE_NO_SACK))) {
 		opts->options |= OPTION_SACK_ADVERTISE;
 		if (unlikely(!(OPTION_TS & opts->options)))
 			size += TCPOLEN_SACKPERM_ALIGNED;
-- 
1.5.6.3

