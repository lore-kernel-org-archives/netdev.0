From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: more strict TCP flag matching in SYNPROXY
Date: Wed,  4 Sep 2013 15:00:22 +0200
Message-ID: <1378299625-4638-2-git-send-email-pablo@netfilter.org>
References: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>

Its seems Patrick missed to incoorporate some of my requested changes
during review v2 of SYNPROXY netfilter module.

Which were, to avoid SYN+ACK packets to enter the path, meant for the
ACK packet from the client (from the 3WHS).

Further there were a bug in ip6t_SYNPROXY.c, for matching SYN packets
that didn't exclude the ACK flag.

Go a step further with SYN packet/flag matching by excluding flags
ACK+FIN+RST, in both IPv4 and IPv6 modules.

The intented usage of SYNPROXY is as follows:
(gracefully describing usage in commit)

 iptables -t raw -A PREROUTING -i eth0 -p tcp --dport 80 --syn -j NOTRACK
 iptables -A INPUT -i eth0 -p tcp --dport 80 -m state UNTRACKED,INVALID \
         -j SYNPROXY --sack-perm --timestamp --mss 1480 --wscale 7 --ecn

 echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose

This does filter SYN flags early, for packets in the UNTRACKED state,
but packets in the INVALID state with other TCP flags could still
reach the module, thus this stricter flag matching is still needed.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  |    4 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 94371db..90e489e 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -269,7 +269,7 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 
 	synproxy_parse_options(skb, par->thoff, th, &opts);
 
-	if (th->syn && !th->ack) {
+	if (th->syn && !(th->ack || th->fin || th->rst)) {
 		/* Initial SYN from client */
 		this_cpu_inc(snet->stats->syn_received);
 
@@ -285,7 +285,7 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst))
+	} else if (th->ack && !(th->fin || th->rst || th->syn))
 		/* ACK from client */
 		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
 
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 4270a9b..a5af0bf 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -284,7 +284,7 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 
 	synproxy_parse_options(skb, par->thoff, th, &opts);
 
-	if (th->syn) {
+	if (th->syn && !(th->ack || th->fin || th->rst)) {
 		/* Initial SYN from client */
 		this_cpu_inc(snet->stats->syn_received);
 
@@ -300,7 +300,7 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst))
+	} else if (th->ack && !(th->fin || th->rst || th->syn))
 		/* ACK from client */
 		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
 
-- 
1.7.10.4

