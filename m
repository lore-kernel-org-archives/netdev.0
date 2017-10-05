From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH v3] netfilter: SYNPROXY: fix process non tcp packet bug in {ipv4,ipv6}_synproxy_hook
Date: Fri,  6 Oct 2017 00:44:03 +0800
Message-ID: <1507221843-4915-1-git-send-email-xiaolou4617@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Lin Zhang <xiaolou4617@gmail.com>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function {ipv4,ipv6}_synproxy_hook we expect a normal tcp packet,
but the real server maybe reply an icmp error packet related to the
exist tcp conntrack, so we will access wrong tcp data.

For fix it, check for the protocol field and only process tcp traffic.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
changelog:

v1 -> v2:
	* we only deal with TCP traffic, per Pablo Neira.
v2 -> v3:
	* fix parse L4 protocol field error in ipv6
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  | 3 ++-
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 811689e..f75fc6b 100644
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
index a5cd43d..437af8c 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -353,7 +353,7 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 	nexthdr = ipv6_hdr(skb)->nexthdr;
 	thoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr,
 				 &frag_off);
-	if (thoff < 0)
+	if (thoff < 0 || nexthdr != IPPROTO_TCP)
 		return NF_ACCEPT;
 
 	th = skb_header_pointer(skb, thoff, sizeof(_th), &_th);
-- 
1.8.3.1

