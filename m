From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipv4: add missing initialization for flowi4_uid
Date: Sun, 26 Feb 2017 15:50:52 +0200
Message-ID: <1488117052-20835-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51497 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752140AbdBZOCp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Feb 2017 09:02:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid matching of random stack value for uid when rules
are looked up on input route or when RP filter is used.
Problem should affect only setups that use ip rules with
uid range.

Fixes: 622ec2c9d524 ("net: core: add UID to flows, rules, and routes")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_frontend.c | 6 +++---
 net/ipv4/route.c        | 1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

I'm not sure if this is the correct way to initialize the uid. I see
other places that simply do memset and use 0 for uid.

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7db2ad2..b39a791 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -319,7 +319,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	int ret, no_addr;
 	struct fib_result res;
 	struct flowi4 fl4;
-	struct net *net;
+	struct net *net = dev_net(dev);
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
@@ -332,6 +332,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 	fl4.flowi4_tun_key.tun_id = 0;
 	fl4.flowi4_flags = 0;
+	fl4.flowi4_uid = sock_net_uid(net, NULL);
 
 	no_addr = idev->ifa_list == NULL;
 
@@ -339,13 +340,12 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 
 	trace_fib_validate_source(dev, &fl4);
 
-	net = dev_net(dev);
 	if (fib_lookup(net, &fl4, &res, 0))
 		goto last_resort;
 	if (res.type != RTN_UNICAST &&
 	    (res.type != RTN_LOCAL || !IN_DEV_ACCEPT_LOCAL(idev)))
 		goto e_inval;
-	if (!rpf && !fib_num_tclassid_users(dev_net(dev)) &&
+	if (!rpf && !fib_num_tclassid_users(net) &&
 	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev)))
 		goto last_resort;
 	fib_combine_itag(itag, &res);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cb494a5..584ed66 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1876,6 +1876,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.flowi4_flags = 0;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
+	fl4.flowi4_uid = sock_net_uid(net, NULL);
 	err = fib_lookup(net, &fl4, &res, 0);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
-- 
1.9.3
