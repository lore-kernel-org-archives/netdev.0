From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: SYNPROXY: fix sending window update to client
Date: Mon, 10 Aug 2015 19:58:39 +0200
Message-ID: <1439229519-7640-6-git-send-email-pablo@netfilter.org>
References: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Sutter <phil@nwl.cc>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  |    3 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

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
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index bcebc24..ebbb754 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -243,7 +243,8 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(snet, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	                  niph, nth, tcp_hdr_size);
 }
 
 static bool
-- 
1.7.10.4

