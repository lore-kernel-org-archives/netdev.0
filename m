From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: xt_rpfilter: skip locally generated broadcast/multicast, too
Date: Fri, 19 Apr 2013 03:16:02 +0200
Message-ID: <1366334162-4958-3-git-send-email-pablo@netfilter.org>
References: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Alex Efros reported rpfilter module doesn't match following packets:
IN=br.qemu SRC=192.168.2.1 DST=192.168.2.255 [ .. ]
(netfilter bugzilla #814).

Problem is that network stack arranges for the locally generated broadcasts
to appear on the interface they were sent out, so the IFF_LOOPBACK check
doesn't trigger.

As -m rpfilter is restricted to PREROUTING, we can check for existing
rtable instead, it catches locally-generated broad/multicast case, too.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_rpfilter.c  |    8 +++++++-
 net/ipv6/netfilter/ip6t_rpfilter.c |    8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index c301300..c49dcd0 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -66,6 +66,12 @@ static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
 	return dev_match;
 }
 
+static bool rpfilter_is_local(const struct sk_buff *skb)
+{
+	const struct rtable *rt = skb_rtable(skb);
+	return rt && (rt->rt_flags & RTCF_LOCAL);
+}
+
 static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_rpfilter_info *info;
@@ -76,7 +82,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	info = par->matchinfo;
 	invert = info->flags & XT_RPFILTER_INVERT;
 
-	if (par->in->flags & IFF_LOOPBACK)
+	if (rpfilter_is_local(skb))
 		return true ^ invert;
 
 	iph = ip_hdr(skb);
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
index 5060d54..e0983f3 100644
--- a/net/ipv6/netfilter/ip6t_rpfilter.c
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -71,6 +71,12 @@ static bool rpfilter_lookup_reverse6(const struct sk_buff *skb,
 	return ret;
 }
 
+static bool rpfilter_is_local(const struct sk_buff *skb)
+{
+	const struct rt6_info *rt = (const void *) skb_dst(skb);
+	return rt && (rt->rt6i_flags & RTF_LOCAL);
+}
+
 static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_rpfilter_info *info = par->matchinfo;
@@ -78,7 +84,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct ipv6hdr *iph;
 	bool invert = info->flags & XT_RPFILTER_INVERT;
 
-	if (par->in->flags & IFF_LOOPBACK)
+	if (rpfilter_is_local(skb))
 		return true ^ invert;
 
 	iph = ipv6_hdr(skb);
-- 
1.7.10.4

