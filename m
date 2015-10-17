From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/35] netfilter: turn NF_HOOK into an inline function
Date: Sat, 17 Oct 2015 13:33:05 +0200
Message-ID: <1445081590-2924-31-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48452 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836AbbJQL0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:32 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

A recent change to the dst_output handling caused a new warning
when the call to NF_HOOK() is the only used of a local variable
passed as 'dev', and CONFIG_NETFILTER is disabled:

net/ipv6/ip6_output.c: In function 'ip6_output':
net/ipv6/ip6_output.c:135:21: warning: unused variable 'dev' [-Wunused-variable]

The reason for this is that the NF_HOOK macro in this case does
not reference the variable at all, and the call to dev_net(dev)
got removed from the ip6_output function. To avoid that warning now
and in the future, this changes the macro into an equivalent
inline function, which tells the compiler that the variable is
passed correctly but still unused.

The dn_forward function apparently had the same problem in
the past and added a local workaround that no longer works
with the inline function. In order to avoid a regression, we
have to also remove the #ifdef from decnet in the same patch.

Fixes: ede2059dbaf9 ("dst: Pass net into dst->output")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h | 19 +++++++++++++++++--
 net/decnet/dn_route.c     |  2 --
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index ef11e1d..0ad5567 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -346,8 +346,23 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, net, sk, skb, indev, outdev, okfn) (okfn)(net, sk, skb)
-#define NF_HOOK_COND(pf, hook, net, sk, skb, indev, outdev, okfn, cond) (okfn)(net, sk, skb)
+static inline int
+NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
+	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
+	     int (*okfn)(struct net *, struct sock *, struct sk_buff *),
+	     bool cond)
+{
+	return okfn(net, sk, skb);
+}
+
+static inline int
+NF_HOOK(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
+	struct sk_buff *skb, struct net_device *in, struct net_device *out,
+	int (*okfn)(struct net *, struct sock *, struct sk_buff *))
+{
+	return okfn(net, sk, skb);
+}
+
 static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 			  struct sock *sk, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index e930321..0c491fc 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -789,9 +789,7 @@ static int dn_forward(struct sk_buff *skb)
 	struct dn_dev *dn_db = rcu_dereference(dst->dev->dn_ptr);
 	struct dn_route *rt;
 	int header_len;
-#ifdef CONFIG_NETFILTER
 	struct net_device *dev = skb->dev;
-#endif
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
-- 
2.1.4
