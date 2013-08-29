From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [nf-next PATCH] netfilter: SYNPROXY let unrelated packets continue
Date: Thu, 29 Aug 2013 12:18:46 +0200
Message-ID: <20130829101625.14346.41071.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com, Jesper Dangaard Brouer <brouer@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079Ab3H2KHR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 06:07:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets reaching SYNPROXY were default dropped, as they were most
likely invalid (given the recommended state matching).  This
patch, changes SYNPROXY target to let packets, not consumed,
continue being processed by the stack.

This will be more in line other target modules. As it will allow
more flexible configurations of handling, logging or matching on
packets in INVALID states.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
comments:
 - This patch depend applying the TCP flags fix patch send earlier
 - This replaces my patch: "netfilter: Extend SYNPROXY with a --continue option"

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
