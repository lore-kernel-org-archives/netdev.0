From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v2] ipv4: fix redirect handling for TCP packets
Date: Tue, 28 May 2013 08:26:49 +0200
Message-ID: <20130528063301.11B7662C67@unicorn.suse.cz>
References: <20130527.232350.1126293930261151421.davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54093 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933037Ab3E1GdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 02:33:03 -0400
In-Reply-To: <20130527.232350.1126293930261151421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ipv4_redirect() and ipv4_sk_redirect(), ip_do_redirect()
doesn't call __build_flow_key() directly but via
ip_rt_build_flow_key() wrapper. This leads to __build_flow_key()
getting pointer to IPv4 header of the ICMP redirect packet
rather than pointer to the embedded IPv4 header of the packet
initiating the redirect.

As a result, handling of ICMP redirects initiated by TCP packets
is broken. Issue was introduced by

	4895c771c ("ipv4: Add FIB nexthop exceptions.")

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/route.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 550781a..d35bbf0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -737,10 +737,15 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 {
 	struct rtable *rt;
 	struct flowi4 fl4;
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	int oif = skb->dev->ifindex;
+	u8 tos = RT_TOS(iph->tos);
+	u8 prot = iph->protocol;
+	u32 mark = skb->mark;
 
 	rt = (struct rtable *) dst;
 
-	ip_rt_build_flow_key(&fl4, sk, skb);
+	__build_flow_key(&fl4, sk, iph, oif, tos, prot, mark, 0);
 	__ip_do_redirect(rt, skb, &fl4, true);
 }
 
-- 
1.8.1.4
