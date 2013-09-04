From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: SYNPROXY: let unrelated packets continue
Date: Wed,  4 Sep 2013 15:00:24 +0200
Message-ID: <1378299625-4638-4-git-send-email-pablo@netfilter.org>
References: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36056 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762543Ab3IDNAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:00:40 -0400
In-Reply-To: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Packets reaching SYNPROXY were default dropped, as they were most
likely invalid (given the recommended state matching).  This
patch, changes SYNPROXY target to let packets, not consumed,
continue being processed by the stack.

This will be more in line other target modules. As it will allow
more flexible configurations of handling, logging or matching on
packets in INVALID states.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  |    8 ++++++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c |    8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 90e489e..67e17dc 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -285,11 +285,15 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst || th->syn))
+		return NF_DROP;
+
+	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
 		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
+		return NF_DROP;
+	}
 
-	return NF_DROP;
+	return XT_CONTINUE;
 }
 
 static unsigned int ipv4_synproxy_hook(unsigned int hooknum,
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index a5af0bf..19cfea8 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -300,11 +300,15 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst || th->syn))
+		return NF_DROP;
+
+	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
 		/* ACK from client */
 		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
+		return NF_DROP;
+	}
 
-	return NF_DROP;
+	return XT_CONTINUE;
 }
 
 static unsigned int ipv6_synproxy_hook(unsigned int hooknum,
-- 
1.7.10.4
