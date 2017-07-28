From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH] netfilter: SYNPROXY: fix process non tcp packet bug in {ipv4,ipv6}_synproxy_hook
Date: Fri, 28 Jul 2017 14:03:04 +0800
Message-ID: <1501221784-18226-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38049 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdG1GEN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 02:04:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function {ipv4,ipv6}_synproxy_hook we expect a normal tcp packet,
but the real server maybe reply an icmp error packet related to the 
exist tcp conntrack, so we will access wrong tcp data.

For fix it, we simply pass IP_CT_RELATED_REPLY packets.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  | 2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index f1528f7..3971fd9 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -330,7 +330,7 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 	if (synproxy == NULL)
 		return NF_ACCEPT;
 
-	if (nf_is_loopback_packet(skb))
+	if (nf_is_loopback_packet(skb) || ctinfo == IP_CT_RELATED_REPLY)
 		return NF_ACCEPT;
 
 	thoff = ip_hdrlen(skb);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index ce203dd..c4bcefe 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -347,7 +347,7 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 	if (synproxy == NULL)
 		return NF_ACCEPT;
 
-	if (nf_is_loopback_packet(skb))
+	if (nf_is_loopback_packet(skb) || ctinfo == IP_CT_RELATED_REPLY)
 		return NF_ACCEPT;
 
 	nexthdr = ipv6_hdr(skb)->nexthdr;
-- 
1.8.3.1
