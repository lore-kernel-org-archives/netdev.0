From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH RFC] Allow to turn off TCP window scale opt per route
Date: Tue, 20 Oct 2009 17:22:39 +0200
Message-ID: <1256052161-14156-7-git-send-email-gilad@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <1256052161-14156-2-git-send-email-gilad@codefidence.com>
 <1256052161-14156-3-git-send-email-gilad@codefidence.com>
 <1256052161-14156-4-git-send-email-gilad@codefidence.com>
 <1256052161-14156-5-git-send-email-gilad@codefidence.com>
 <1256052161-14156-6-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37486 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbZJTPWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 11:22:50 -0400
In-Reply-To: <1256052161-14156-6-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add and use no window scale bit in the features field.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Sigend-off-by: Ori Finkelman <ori@comsleep.com>
Sigend-off-by: Yony Amit <yony@comsleep.com>
---
 include/linux/rtnetlink.h |    1 +
 net/ipv4/tcp_input.c      |    3 ++-
 net/ipv4/tcp_output.c     |    6 ++++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2ab8c75..6784b34 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -380,6 +380,7 @@ enum
 #define RTAX_FEATURE_NO_SACK	0x00000002
 #define RTAX_FEATURE_NO_TSTAMP	0x00000004
 #define RTAX_FEATURE_ALLFRAG	0x00000008
+#define RTAX_FEATURE_NO_WSCALE	0x00000010
 
 struct rta_session
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d2f9742..4f5e914 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3739,7 +3739,8 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				break;
 			case TCPOPT_WINDOW:
 				if (opsize == TCPOLEN_WINDOW && th->syn &&
-				    !estab && sysctl_tcp_window_scaling) {
+				    !estab && sysctl_tcp_window_scaling &&
+				    !dst_feature(dst, RTAX_FEATURE_NO_WSCALE)) {
 					__u8 snd_wscale = *(__u8 *)ptr;
 					opt_rx->wscale_ok = 1;
 					if (snd_wscale > 14) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8f30c18..ff60a21 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -496,7 +496,8 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		opts->tsecr = tp->rx_opt.ts_recent;
 		size += TCPOLEN_TSTAMP_ALIGNED;
 	}
-	if (likely(sysctl_tcp_window_scaling)) {
+	if (likely(sysctl_tcp_window_scaling &&
+		   !dst_feature(dst, RTAX_FEATURE_NO_WSCALE))) {
 		opts->ws = tp->rx_opt.rcv_wscale;
 		opts->options |= OPTION_WSCALE;
 		size += TCPOLEN_WSCALE_ALIGNED;
@@ -2347,7 +2348,8 @@ static void tcp_connect_init(struct sock *sk)
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
-				  sysctl_tcp_window_scaling,
+				  (sysctl_tcp_window_scaling &&
+				   !dst_feature(dst, RTAX_FEATURE_NO_WSCALE)),
 				  &rcv_wscale);
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
-- 
1.5.6.3

