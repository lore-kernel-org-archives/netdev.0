From: gfree.wind@foxmail.com
Subject: [PATCH net-next 1/1] net: tcp: Define the TCP_MAX_WSCALE instead of literal number 14
Date: Sat,  1 Apr 2017 12:14:10 +0800
Message-ID: <1491020050-118525-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:47390 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750726AbdDAEO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 00:14:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Define one new macro TCP_MAX_WSCALE instead of literal number '14',
and use U16_MAX instead of 65535 as the max value of TCP window.
There is another minor change, use rounddown(space, mss) instead of
(space / mss) * mss;

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 include/net/tcp.h     | 3 +++
 net/ipv4/tcp.c        | 2 +-
 net/ipv4/tcp_input.c  | 4 ++--
 net/ipv4/tcp_output.c | 8 ++++----
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e614ad4..2a89881 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -78,6 +78,9 @@
 /* Maximal number of ACKs sent quickly to accelerate slow-start. */
 #define TCP_MAX_QUICKACKS	16U
 
+/* Maximal number of window scale according to RFC1323 */
+#define TCP_MAX_WSCALE		14U
+
 /* urg_data states */
 #define TCP_URG_VALID	0x0100
 #define TCP_URG_NOTYET	0x0200
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf45555..95be443 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2393,7 +2393,7 @@ static int tcp_repair_options_est(struct tcp_sock *tp,
 				u16 snd_wscale = opt.opt_val & 0xFFFF;
 				u16 rcv_wscale = opt.opt_val >> 16;
 
-				if (snd_wscale > 14 || rcv_wscale > 14)
+				if (snd_wscale > TCP_MAX_WSCALE || rcv_wscale > TCP_MAX_WSCALE)
 					return -EFBIG;
 
 				tp->rx_opt.snd_wscale = snd_wscale;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bb09c70..e277901 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3759,11 +3759,11 @@ void tcp_parse_options(const struct sk_buff *skb,
 				    !estab && sysctl_tcp_window_scaling) {
 					__u8 snd_wscale = *(__u8 *)ptr;
 					opt_rx->wscale_ok = 1;
-					if (snd_wscale > 14) {
+					if (snd_wscale > TCP_MAX_WSCALE) {
 						net_info_ratelimited("%s: Illegal window scaling value %d >14 received\n",
 								     __func__,
 								     snd_wscale);
-						snd_wscale = 14;
+						snd_wscale = TCP_MAX_WSCALE;
 					}
 					opt_rx->snd_wscale = snd_wscale;
 				}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 22548b5..d8f12d7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -212,12 +212,12 @@ void tcp_select_initial_window(int __space, __u32 mss,
 
 	/* If no clamp set the clamp to the max possible scaled window */
 	if (*window_clamp == 0)
-		(*window_clamp) = (65535 << 14);
+		(*window_clamp) = (U16_MAX << TCP_MAX_WSCALE);
 	space = min(*window_clamp, space);
 
 	/* Quantize space offering to a multiple of mss if possible. */
 	if (space > mss)
-		space = (space / mss) * mss;
+		space = rounddown(space, mss);
 
 	/* NOTE: offering an initial window larger than 32767
 	 * will break some buggy TCP stacks. If the admin tells us
@@ -240,7 +240,7 @@ void tcp_select_initial_window(int __space, __u32 mss,
 		space = max_t(u32, space, sysctl_tcp_rmem[2]);
 		space = max_t(u32, space, sysctl_rmem_max);
 		space = min_t(u32, space, *window_clamp);
-		while (space > 65535 && (*rcv_wscale) < 14) {
+		while (space > U16_MAX && (*rcv_wscale) < TCP_MAX_WSCALE) {
 			space >>= 1;
 			(*rcv_wscale)++;
 		}
@@ -253,7 +253,7 @@ void tcp_select_initial_window(int __space, __u32 mss,
 	}
 
 	/* Set the clamp no higher than max representable value */
-	(*window_clamp) = min(65535U << (*rcv_wscale), *window_clamp);
+	(*window_clamp) = min_t(__u32, U16_MAX << (*rcv_wscale), *window_clamp);
 }
 EXPORT_SYMBOL(tcp_select_initial_window);
 
-- 
1.9.1
