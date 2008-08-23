From: Philip Love <love_phil@emc.com>
Subject: [PATCH] tcp: fix tcp header size miscalculation when window scale is unused
Date: Sat, 23 Aug 2008 10:18:27 -0700
Message-ID: <C2868EA2-EAC8-48F4-8CA5-01B7437FD72D@emc.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from posteaux1.caltech.edu ([131.215.239.119]:57485 "EHLO
	mail.alumni.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbYHWRSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 13:18:36 -0400
Received: from [192.168.0.188] (adsl-69-230-77-203.dsl.irvnca.pacbell.net [69.230.77.203])
	by mail.alumni.caltech.edu (Postfix) with ESMTP id C54E93F044D
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 10:18:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: fix tcp header size miscalculation when window scale is unused

The size of the TCP header is miscalculated when the window scale ends  
up being
0. Additionally, this can be induced by sending a SYN to a passive  
open port
with a window scale option with value 0.

Signed-off-by: Philip Love <love_phil@emc.com>

---

net/ipv4/tcp_output.c |    6 ++++--
1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a00532d..71eea00 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -468,7 +468,8 @@ static unsigned tcp_syn_options(struct sock *sk,  
struct sk_buff *skb,
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
