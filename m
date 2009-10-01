From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCHv2] IPv4 TCP fails to send window scale option when window
 scale is zero
Date: Thu, 01 Oct 2009 11:39:53 +0200
Message-ID: <4AC478E9.5050605@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ori Finkalman <ori@comsleep.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:45035 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756026AbZJAJjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 05:39:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ori Finkelman <ori@comsleep.com>

Acknowledge TCP window scale support by inserting the proper option in 
SYN/ACK and SYN headers
even if our window scale is zero.

This fixes the following observed behavior:

1. Client sends a SYN with TCP window scaling option and non zero window 
scale value to a Linux box.
2. Linux box notes large receive window from client.
3. Linux decides on a zero value of window scale for its part.
4. Due to compare against requested window scale size option, Linux does 
not to send windows scale TCP option header on SYN/ACK at all.

With the following result:

Client box thinks TCP window scaling is not supported, since SYN/ACK had 
no TCP window scale option,
while Linux thinks that TCP window scaling is supported (and scale might 
be non zero), since SYN had TCP window scale option and we have a 
mismatched idea between the client and server regarding window sizes.

Probably it also fixes up the following bug (not observed in practice):

1. Linux box opens TCP connection to some server.
2. Linux decides on zero value of window scale.
3. Due to compare against computed window scale size option, Linux does 
not to set windows scale TCP option header on SYN.  

With the expected result that the server OS does not use window scale 
option due to not receiving such an option in the SYN headers, leading 
to suboptimal performance.

---

Original bug reported and patch written by Ori Finkelman from Comsleep 
Ltd. I've fixed the SYN header case based on feedback from Eric Dumazet 
and Ilpo Jarvinen, as part of trying to get the patch mainlined.

The SYN/ACK behavior was observed with a Windows box as the client and 
latest Debian kernel but for the best
of my understanding this can happen with latest kernel versions and 
other client OS (probably also Linux) as well.


The SYN/ACK scenario was tested on a x86 system. The SYN sceanrio was 
only compile tested.


Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Signed-off-by: Ori Finkelman <ori@comsleep.com>


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5200aab..fcd278a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -361,6 +361,7 @@ static inline int tcp_urg_mode(const struct tcp_sock 
*tp)
 #define OPTION_SACK_ADVERTISE  (1 << 0)
 #define OPTION_TS              (1 << 1)
 #define OPTION_MD5             (1 << 2)
+#define OPTION_WSCALE          (1 << 3)
 
 struct tcp_out_options {
        u8 options;             /* bit field of OPTION_* */
@@ -427,7 +428,7 @@ static void tcp_options_write(__be32 *ptr, struct 
tcp_sock *tp,
                               TCPOLEN_SACK_PERM);
        }
 
-       if (unlikely(opts->ws)) {
+       if (unlikely(OPTION_WSCALE & opts->options)) {
                *ptr++ = htonl((TCPOPT_NOP << 24) |
                               (TCPOPT_WINDOW << 16) |
                               (TCPOLEN_WINDOW << 8) |
@@ -494,8 +495,8 @@ static unsigned tcp_syn_options(struct sock *sk, 
struct sk_buff *skb,
        }
        if (likely(sysctl_tcp_window_scaling)) {
                opts->ws = tp->rx_opt.rcv_wscale;
-               if (likely(opts->ws))
-                       size += TCPOLEN_WSCALE_ALIGNED;
+               opts->options |= OPTION_WSCALE;
+               size += TCPOLEN_WSCALE_ALIGNED;
        }
        if (likely(sysctl_tcp_sack)) {
                opts->options |= OPTION_SACK_ADVERTISE;
@@ -537,8 +538,8 @@ static unsigned tcp_synack_options(struct sock *sk,
 
        if (likely(ireq->wscale_ok)) {
                opts->ws = ireq->rcv_wscale;
-               if (likely(opts->ws))
-                       size += TCPOLEN_WSCALE_ALIGNED;
+               opts->options |= OPTION_WSCALE;
+               size += TCPOLEN_WSCALE_ALIGNED;
        }
        if (likely(doing_ts)) {
                opts->options |= OPTION_TS;

-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Now the world has gone to bed
	 Darkness won't engulf my head
	 I can see by infra-red
	 How I hate the night."

