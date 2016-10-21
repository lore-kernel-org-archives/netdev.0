From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] lwt: Remove unused len field
Date: Fri, 21 Oct 2016 16:10:22 +0200
Message-ID: <fb52764c89fa8c11ec832bd4ddf7595b6a673ce1.1477058913.git.tgraf@suug.ch>
Cc: tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60864 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933190AbcJUOKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The field is initialized by ILA and MPLS but never used. Remove it.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/lwtunnel.h   | 3 +--
 net/ipv6/ila/ila_lwt.c   | 4 +---
 net/mpls/mpls_iptunnel.c | 5 +----
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 67d235f..82e76fe 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -24,11 +24,10 @@ enum {
 struct lwtunnel_state {
 	__u16		type;
 	__u16		flags;
+	__u16		headroom;
 	atomic_t	refcnt;
 	int		(*orig_output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int		(*orig_input)(struct sk_buff *);
-	int             len;
-	__u16		headroom;
 	struct		rcu_head rcu;
 	__u8            data[0];
 };
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index c7a39d0..a7bc54a 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -122,7 +122,6 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	struct ila_lwt *ilwt;
 	struct ila_params *p;
 	struct nlattr *tb[ILA_ATTR_MAX + 1];
-	size_t encap_len = sizeof(*ilwt);
 	struct lwtunnel_state *newts;
 	const struct fib6_config *cfg6 = cfg;
 	struct ila_addr *iaddr;
@@ -155,7 +154,7 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	if (!tb[ILA_ATTR_LOCATOR])
 		return -EINVAL;
 
-	newts = lwtunnel_state_alloc(encap_len);
+	newts = lwtunnel_state_alloc(sizeof(*ilwt));
 	if (!newts)
 		return -ENOMEM;
 
@@ -166,7 +165,6 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 		return ret;
 	}
 
-	newts->len = encap_len;
 	p = ila_params_lwtunnel(newts);
 
 	p->locator.v64 = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index cf52cf3..2f7ccd9 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -133,7 +133,6 @@ static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct nlattr *tb[MPLS_IPTUNNEL_MAX + 1];
 	struct lwtunnel_state *newts;
-	int tun_encap_info_len;
 	int ret;
 
 	ret = nla_parse_nested(tb, MPLS_IPTUNNEL_MAX, nla,
@@ -144,13 +143,11 @@ static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
 	if (!tb[MPLS_IPTUNNEL_DST])
 		return -EINVAL;
 
-	tun_encap_info_len = sizeof(*tun_encap_info);
 
-	newts = lwtunnel_state_alloc(tun_encap_info_len);
+	newts = lwtunnel_state_alloc(sizeof(*tun_encap_info));
 	if (!newts)
 		return -ENOMEM;
 
-	newts->len = tun_encap_info_len;
 	tun_encap_info = mpls_lwtunnel_encap(newts);
 	ret = nla_get_labels(tb[MPLS_IPTUNNEL_DST], MAX_NEW_LABELS,
 			     &tun_encap_info->labels, tun_encap_info->label);
-- 
2.7.4
