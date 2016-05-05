From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 01/13] net: vrf: Create FIB tables on link create
Date: Wed,  4 May 2016 20:33:18 -0700
Message-ID: <1462419210-10463-2-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35776 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755576AbcEEDeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:08 -0400
Received: by mail-pf0-f175.google.com with SMTP id 77so32404099pfv.2
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:08 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tables have to exist for VRFs to function. Ensure they exist
when VRF device is created.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c       | 11 +++++++++--
 net/ipv4/fib_frontend.c |  1 +
 net/ipv6/ip6_fib.c      |  1 +
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 8a8f1e58b415..2f2aac1b598f 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -372,9 +372,13 @@ static int vrf_rt6_create(struct net_device *dev)
 	if (!rt6)
 		goto out;
 
-	rt6->dst.output	= vrf_output6;
-	rt6->rt6i_table = fib6_get_table(net, vrf->tb_id);
 	dst_hold(&rt6->dst);
+
+	rt6->rt6i_table = fib6_new_table(net, vrf->tb_id);
+	if (!rt6->rt6i_table)
+		goto out;
+
+	rt6->dst.output	= vrf_output6;
 	vrf->rt6 = rt6;
 	rc = 0;
 out:
@@ -462,6 +466,9 @@ static struct rtable *vrf_rtable_create(struct net_device *dev)
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct rtable *rth;
 
+	if (!fib_new_table(dev_net(dev), vrf->tb_id))
+		return NULL;
+
 	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
 	if (rth) {
 		rth->dst.output	= vrf_output;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 63566ec54794..ef2ebeb89d0f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -110,6 +110,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	hlist_add_head_rcu(&tb->tb_hlist, &net->ipv4.fib_table_hash[h]);
 	return tb;
 }
+EXPORT_SYMBOL_GPL(fib_new_table);
 
 /* caller must hold either rtnl or rcu read lock */
 struct fib_table *fib_get_table(struct net *net, u32 id)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ea071fad67a0..1bcef2369d64 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -240,6 +240,7 @@ struct fib6_table *fib6_new_table(struct net *net, u32 id)
 
 	return tb;
 }
+EXPORT_SYMBOL_GPL(fib6_new_table);
 
 struct fib6_table *fib6_get_table(struct net *net, u32 id)
 {
-- 
2.1.4
