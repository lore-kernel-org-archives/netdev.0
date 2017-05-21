From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 4/4] net: ipv6: Add extack messages for route add failures
Date: Sun, 21 May 2017 10:12:05 -0600
Message-ID: <20170521161205.36720-5-dsahern@gmail.com>
References: <20170521161205.36720-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35780 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756191AbdEUQM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:12:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id u26so14777654pfd.2
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:12:26 -0700 (PDT)
In-Reply-To: <20170521161205.36720-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add messages for non-obvious errors (e.g, no need to add text for malloc
failures or ENODEV failures). This mostly covers the annoying EINVAL errors
Some message strings violate the 80-columns but searchable strings need to
trump that rule.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv6/ip6_fib.c |  4 ++++
 net/ipv6/route.c   | 40 ++++++++++++++++++++++++++++++++--------
 2 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c1197e167d3e..deea901746c8 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -498,6 +498,8 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit)) {
 			if (!allow_create) {
 				if (replace_required) {
+					NL_SET_ERR_MSG(extack,
+						       "Can not replace route - no match found");
 					pr_warn("Can't replace route, no match found\n");
 					return ERR_PTR(-ENOENT);
 				}
@@ -544,6 +546,8 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 		 * That would keep IPv6 consistent with IPv4
 		 */
 		if (replace_required) {
+			NL_SET_ERR_MSG(extack,
+				       "Can not replace route - no match found");
 			pr_warn("Can't replace route, no match found\n");
 			return ERR_PTR(-ENOENT);
 		}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ca754ec4054a..80bda31ffbbe 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1857,14 +1857,25 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 	int err = -EINVAL;
 
 	/* RTF_PCPU is an internal flag; can not be set by userspace */
-	if (cfg->fc_flags & RTF_PCPU)
+	if (cfg->fc_flags & RTF_PCPU) {
+		NL_SET_ERR_MSG(extack, "Userspace can not set RTF_PCPU");
 		goto out;
+	}
 
-	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
+	if (cfg->fc_dst_len > 128) {
+		NL_SET_ERR_MSG(extack, "Invalid prefix length");
+		goto out;
+	}
+	if (cfg->fc_src_len > 128) {
+		NL_SET_ERR_MSG(extack, "Invalid source address length");
 		goto out;
+	}
 #ifndef CONFIG_IPV6_SUBTREES
-	if (cfg->fc_src_len)
+	if (cfg->fc_src_len) {
+		NL_SET_ERR_MSG(extack,
+			       "Specifying source address requires IPV6_SUBTREES to be enabled");
 		goto out;
+	}
 #endif
 	if (cfg->fc_ifindex) {
 		err = -ENODEV;
@@ -2015,9 +2026,10 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 		err = -EINVAL;
 		if (ipv6_chk_addr_and_flags(net, gw_addr,
 					    gwa_type & IPV6_ADDR_LINKLOCAL ?
-					    dev : NULL, 0, 0))
+					    dev : NULL, 0, 0)) {
+			NL_SET_ERR_MSG(extack, "Invalid gateway address");
 			goto out;
-
+		}
 		rt->rt6i_gateway = *gw_addr;
 
 		if (gwa_type != (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST)) {
@@ -2033,8 +2045,11 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 			   addressing
 			 */
 			if (!(gwa_type & (IPV6_ADDR_UNICAST |
-					  IPV6_ADDR_MAPPED)))
+					  IPV6_ADDR_MAPPED))) {
+				NL_SET_ERR_MSG(extack,
+					       "Invalid gateway address");
 				goto out;
+			}
 
 			if (cfg->fc_table) {
 				grt = ip6_nh_lookup_table(net, cfg, gw_addr);
@@ -2074,8 +2089,14 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 				goto out;
 		}
 		err = -EINVAL;
-		if (!dev || (dev->flags & IFF_LOOPBACK))
+		if (!dev) {
+			NL_SET_ERR_MSG(extack, "Egress device not specified");
+			goto out;
+		} else if (dev->flags & IFF_LOOPBACK) {
+			NL_SET_ERR_MSG(extack,
+				       "Egress device can not be loopback device for this route");
 			goto out;
+		}
 	}
 
 	err = -ENODEV;
@@ -2084,6 +2105,7 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 
 	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
 		if (!ipv6_chk_addr(net, &cfg->fc_prefsrc, dev, 0)) {
+			NL_SET_ERR_MSG(extack, "Invalid source address");
 			err = -EINVAL;
 			goto out;
 		}
@@ -2234,8 +2256,10 @@ static int ip6_route_del(struct fib6_config *cfg,
 	int err = -ESRCH;
 
 	table = fib6_get_table(cfg->fc_nlinfo.nl_net, cfg->fc_table);
-	if (!table)
+	if (!table) {
+		NL_SET_ERR_MSG(extack, "FIB table does not exist");
 		return err;
+	}
 
 	read_lock_bh(&table->tb6_lock);
 
-- 
2.11.0 (Apple Git-81)
