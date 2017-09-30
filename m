From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH v2] netfilter: SYNPROXY: fix process non tcp packet bug in {ipv4,ipv6}_synproxy_hook
Date: Sat, 30 Sep 2017 18:25:15 +0800
Message-ID: <1506767115-10051-1-git-send-email-xiaolou4617@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Lin Zhang <xiaolou4617@gmail.com>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36990 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdI3KZX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 06:25:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function {ipv4,ipv6}_synproxy_hook we expect a normal tcp packet,
but the real server maybe reply an icmp error packet related to the 
exist tcp conntrack, so we will access wrong tcp data.

For fix it, check for the protocol field and only process tcp traffic.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
changelog:

v1 -> v2:
	* we only deal with TCP traffic, per Pablo Neira.
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  | 3 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 811689e..13bec90 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -330,7 +330,8 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 	if (synproxy == NULL)
 		return NF_ACCEPT;
 
-	if (nf_is_loopback_packet(skb))
+	if (nf_is_loopback_packet(skb) ||
+	    ip_hdr(skb)->protocol != IPPROTO_TCP)
 		return NF_ACCEPT;
 
 	thoff = ip_hdrlen(skb);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index a5cd43d..af19c16 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -347,7 +347,8 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 	if (synproxy == NULL)
 		return NF_ACCEPT;
 
-	if (nf_is_loopback_packet(skb))
+	if (nf_is_loopback_packet(skb) ||
+	    ipv6_hdr(skb)->protocol != IPPROTO_TCP)
 		return NF_ACCEPT;
 
 	nexthdr = ipv6_hdr(skb)->nexthdr;
-- 
1.8.3.1
