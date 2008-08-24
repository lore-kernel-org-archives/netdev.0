From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window scale is unused
Date: Sun, 24 Aug 2008 10:40:23 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069081@europa>
References: <20080823.214013.29359753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, love_phil@emc.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:8005 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbYHXRlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 13:41:35 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1545240wfd.4
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 10:41:34 -0700 (PDT)
In-Reply-To: <20080823.214013.29359753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Love <love_phil@emc.com>

tcp: fix tcp header size miscalculation when window scale is unused

The size of the TCP header is miscalculated when the window scale ends up being
0. Additionally, this can be induced by sending a SYN to a passive open port
with a window scale option with value 0.

Signed-off-by: Philip Love <love_phil@emc.com>
Signed-off-by: Adam Langley <agl@imperialviolet.org>

---

 net/ipv4/tcp_output.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a00532d..71eea00 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -468,7 +468,8 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	}
 	if (likely(sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
-		size += TCPOLEN_WSCALE_ALIGNED;
+		if (likely(opts->ws))
+			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(sysctl_tcp_sack)) {
 		opts->options |= OPTION_SACK_ADVERTISE;
@@ -509,7 +510,8 @@ static unsigned tcp_synack_options(struct sock *sk,
 
 	if (likely(ireq->wscale_ok)) {
 		opts->ws = ireq->rcv_wscale;
-		size += TCPOLEN_WSCALE_ALIGNED;
+		if (likely(opts->ws))
+			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(doing_ts)) {
 		opts->options |= OPTION_TS;
