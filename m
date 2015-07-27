From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] netfilter: ipt_SYNPROXY: fix sending window update to client
Date: Tue, 28 Jul 2015 00:53:26 +0200
Message-ID: <1438037606-5462-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:43509 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754401AbbG0Wx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 18:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon receipt of SYNACK from the server, ipt_SYNPROXY first sends back an ACK to
finish the server handshake, then calls nf_ct_seqadj_init() to initiate
sequence number adjustment of forwarded packets to the client and finally sends
a window update to the client to unblock it's TX queue.

Since synproxy_send_client_ack() does not set synproxy_send_tcp()'s nfct
parameter, no sequence number adjustment happens and the client receives the
window update with incorrect sequence number. Depending on client TCP
implementation, this leads to a significant delay (until a window probe is
being sent).

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index fe8cc18..95ea633e 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -226,7 +226,8 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	                  niph, nth, tcp_hdr_size);
 }
 
 static bool
-- 
1.8.3.1
