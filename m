From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH RFC] Allow disabling TCP timestamp options per route
Date: Tue, 20 Oct 2009 17:22:38 +0200
Message-ID: <1256052161-14156-6-git-send-email-gilad@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <1256052161-14156-2-git-send-email-gilad@codefidence.com>
 <1256052161-14156-3-git-send-email-gilad@codefidence.com>
 <1256052161-14156-4-git-send-email-gilad@codefidence.com>
 <1256052161-14156-5-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37479 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbZJTPWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 11:22:47 -0400
In-Reply-To: <1256052161-14156-5-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement querying and acting upon the no timestamp bit in the feature 
field.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Sigend-off-by: Ori Finkelman <ori@comsleep.com>
Sigend-off-by: Yony Amit <yony@comsleep.com>

---
 include/linux/rtnetlink.h |    2 +-
 net/ipv4/tcp_input.c      |    3 ++-
 net/ipv4/tcp_output.c     |    8 ++++++--
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 9c802a6..2ab8c75 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -378,7 +378,7 @@ enum
 
 #define RTAX_FEATURE_ECN	0x00000001
 #define RTAX_FEATURE_NO_SACK	0x00000002
-#define RTAX_FEATURE_TIMESTAMP	0x00000004
+#define RTAX_FEATURE_NO_TSTAMP	0x00000004
 #define RTAX_FEATURE_ALLFRAG	0x00000008
 
 struct rta_session
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b14f780..d2f9742 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3755,7 +3755,8 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 			case TCPOPT_TIMESTAMP:
 				if ((opsize == TCPOLEN_TIMESTAMP) &&
 				    ((estab && opt_rx->tstamp_ok) ||
-				     (!estab && sysctl_tcp_timestamps))) {
+				     (!estab && sysctl_tcp_timestamps &&
+				      !dst_feature(dst, RTAX_FEATURE_NO_TSTAMP)))) {
 					opt_rx->saw_tstamp = 1;
 					opt_rx->rcv_tsval = get_unaligned_be32(ptr);
 					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 64db8dd..8f30c18 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -488,7 +488,9 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	opts->mss = tcp_advertise_mss(sk);
 	size += TCPOLEN_MSS_ALIGNED;
 
-	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
+	if (likely(sysctl_tcp_timestamps &&
+		   !dst_feature(dst, RTAX_FEATURE_NO_TSTAMP) &&
+		   *md5 == NULL)) {
 		opts->options |= OPTION_TS;
 		opts->tsval = TCP_SKB_CB(skb)->when;
 		opts->tsecr = tp->rx_opt.ts_recent;
@@ -2317,7 +2319,9 @@ static void tcp_connect_init(struct sock *sk)
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
 	 */
 	tp->tcp_header_len = sizeof(struct tcphdr) +
-		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
+		(sysctl_tcp_timestamps &&
+		(!dst_feature(dst, RTAX_FEATURE_NO_TSTAMP) ?
+		  TCPOLEN_TSTAMP_ALIGNED : 0));
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (tp->af_specific->md5_lookup(sk, sk) != NULL)
-- 
1.5.6.3

