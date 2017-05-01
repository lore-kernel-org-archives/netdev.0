From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 40/53] netfilter: SYNPROXY: Return NF_STOLEN instead of NF_DROP during handshaking
Date: Mon,  1 May 2017 12:47:07 +0200
Message-ID: <1493635640-24325-41-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49782 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378990AbdEAKs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AF1B121057B
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A05B9FF2D8
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 71E5A468
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:59 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Current SYNPROXY codes return NF_DROP during normal TCP handshaking,
it is not friendly to caller. Because the nf_hook_slow would treat
the NF_DROP as an error, and return -EPERM.
As a result, it may cause the top caller think it meets one error.

For example, the following codes are from cfv_rx_poll()
	err = netif_receive_skb(skb);
	if (unlikely(err)) {
		++cfv->ndev->stats.rx_dropped;
	} else {
		++cfv->ndev->stats.rx_packets;
		cfv->ndev->stats.rx_bytes += skb_len;
	}
When SYNPROXY returns NF_DROP, then netif_receive_skb returns -EPERM.
As a result, the cfv driver would treat it as an error, and increase
the rx_dropped counter.

So use NF_STOLEN instead of NF_DROP now because there is no error
happened indeed, and free the skb directly.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  | 21 ++++++++++++++-------
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 20 ++++++++++++++------
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index c308ee0ee0bc..af2b69b6895f 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -293,12 +293,16 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(net, skb, th, &opts);
-		return NF_DROP;
-
+		consume_skb(skb);
+		return NF_STOLEN;
 	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
-		synproxy_recv_client_ack(net, skb, th, &opts, ntohl(th->seq));
-		return NF_DROP;
+		if (synproxy_recv_client_ack(net, skb, th, &opts, ntohl(th->seq))) {
+			consume_skb(skb);
+			return NF_STOLEN;
+		} else {
+			return NF_DROP;
+		}
 	}
 
 	return XT_CONTINUE;
@@ -367,10 +371,13 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 			 * number match the one of first SYN.
 			 */
 			if (synproxy_recv_client_ack(net, skb, th, &opts,
-						     ntohl(th->seq) + 1))
+						     ntohl(th->seq) + 1)) {
 				this_cpu_inc(snet->stats->cookie_retrans);
-
-			return NF_DROP;
+				consume_skb(skb);
+				return NF_STOLEN;
+			} else {
+				return NF_DROP;
+			}
 		}
 
 		synproxy->isn = ntohl(th->ack_seq);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 1252537f215f..d3c4daa708b9 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -307,12 +307,17 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(net, skb, th, &opts);
-		return NF_DROP;
+		consume_skb(skb);
+		return NF_STOLEN;
 
 	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
-		synproxy_recv_client_ack(net, skb, th, &opts, ntohl(th->seq));
-		return NF_DROP;
+		if (synproxy_recv_client_ack(net, skb, th, &opts, ntohl(th->seq))) {
+			consume_skb(skb);
+			return NF_STOLEN;
+		} else {
+			return NF_DROP;
+		}
 	}
 
 	return XT_CONTINUE;
@@ -388,10 +393,13 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 			 * number match the one of first SYN.
 			 */
 			if (synproxy_recv_client_ack(net, skb, th, &opts,
-						     ntohl(th->seq) + 1))
+						     ntohl(th->seq) + 1)) {
 				this_cpu_inc(snet->stats->cookie_retrans);
-
-			return NF_DROP;
+				consume_skb(skb);
+				return NF_STOLEN;
+			} else {
+				return NF_DROP;
+			}
 		}
 
 		synproxy->isn = ntohl(th->ack_seq);
-- 
2.1.4
