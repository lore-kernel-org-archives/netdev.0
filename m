From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net] mpls: fix sending of local encapped packets
Date: Mon, 7 Dec 2015 12:53:15 +0000
Message-ID: <1449492795-12406-1-git-send-email-rshearma@brocade.com>
References: <56656219.7070009@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <roopa@cumulusnetworks.com>,
	<ebiederm@xmission.com>, Sam Russell <sam.h.russell@gmail.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:2345 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754978AbbLGMx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:53:57 -0500
In-Reply-To: <56656219.7070009@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locally generated IPv4 and (probably) IPv6 packets are dropped because
skb->protocol isn't set. We could write wrappers to lwtunnel_output
for IPv4 and IPv6 that set the protocol accordingly and then call
lwtunnel_output, but mpls_output relies on the AF-specific type of dst
anyway to get the via address.

Therefore, make use of dst->dst_ops->family in mpls_output to
determine the type of nexthop and thus protocol of the packet instead
of checking skb->protocol.

Fixes: 61adedf3e3f1 ("route: move lwtunnel state to dst_entry")
Reported-by: Sam Russell <sam.h.russell@gmail.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/mpls_iptunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 67591aef9cae..64afd3d0b144 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -54,10 +54,10 @@ int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	unsigned int ttl;
 
 	/* Obtain the ttl */
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (dst->ops->family == AF_INET) {
 		ttl = ip_hdr(skb)->ttl;
 		rt = (struct rtable *)dst;
-	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+	} else if (dst->ops->family == AF_INET6) {
 		ttl = ipv6_hdr(skb)->hop_limit;
 		rt6 = (struct rt6_info *)dst;
 	} else {
-- 
2.1.4
