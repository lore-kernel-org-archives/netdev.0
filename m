From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] ipv4: fix redirect handling for TCP packets
Date: Mon, 27 May 2013 09:47:56 +0200
Message-ID: <20130527080120.424C662C67@unicorn.suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47103 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756280Ab3E0IBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 04:01:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ipv4_redirect() and ipv4_sk_redirect(), ip_do_redirect()
doesn't call __build_flow_key() directly but via
ip_rt_build_flow_key() wrapper. This leads to __build_flow_key()
getting pointer to IPv4 header of the ICMP redirect packet
rather than pointer to the embedded IPv4 header of the packet
initiating the redirect.

As a result, handling of ICMP redirects initiated by TCP packets
is broken. Issue was introduced by commit 4895c771c (v3.6-rc1).

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
