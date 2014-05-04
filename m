From: Ying Cai <ycai@google.com>
Subject: [PATCH net v3] ip_tunnel: Set network header properly for IP_ECN_decapsulate()
Date: Sun,  4 May 2014 15:20:04 -0700
Message-ID: <1399242005-28999-1-git-send-email-ycai@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ying Cai <ycai@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:33882 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbaEDWVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 18:21:43 -0400
Received: by mail-qa0-f74.google.com with SMTP id ih12so251192qab.3
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 15:21:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip_tunnel_rcv(), set skb->network_header to inner IP header
before IP_ECN_decapsulate().

Without the fix, IP_ECN_decapsulate() takes outer IP header as
inner IP header, possibly causing error messages or packet drops.

Note that this skb_reset_network_header() call was in this spot when
the original feature for checking consistency of ECN bits through
tunnels was added in eccc1bb8d4b4 ("tunnel: drop packet if ECN present
with not-ECT"). It was only removed from this spot in 3d7b46cd20e3
("ip_tunnel: push generic protocol handling to ip_tunnel module.").

Fixes: 3d7b46cd20e3 ("ip_tunnel: push generic protocol handling to ip_tunnel module.")
Reported-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Ying Cai <ycai@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/ip_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fa5b751..b3f8597 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -442,6 +442,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		tunnel->i_seqno = ntohl(tpi->seq) + 1;
 	}
 
+	skb_reset_network_header(skb);
+
 	err = IP_ECN_decapsulate(iph, skb);
 	if (unlikely(err)) {
 		if (log_ecn_error)
-- 
1.9.1.423.g4596e3a
