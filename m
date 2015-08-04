From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mpls: small cleanup in inet/inet6_fib_lookup_dev()
Date: Tue, 4 Aug 2015 10:44:22 +0300
Message-ID: <20150804074422.GB10867@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We recently changed this code from returning NULL to returning ERR_PTR.
There are some left over NULL assignments which we can remove.  We can
preserve the error code from ip_route_output() instead of always
returning -ENODEV.  Also these functions use a mix of gotos and direct
returns.  There is no cleanup necessary so I changed the gotos to
direct returns.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 88cfaa2..d933059 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -337,14 +337,14 @@ static unsigned find_free_label(struct net *net)
 #if IS_ENABLED(CONFIG_INET)
 static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 {
-	struct net_device *dev = NULL;
+	struct net_device *dev;
 	struct rtable *rt;
 	struct in_addr daddr;
 
 	memcpy(&daddr, addr, sizeof(struct in_addr));
 	rt = ip_route_output(net, daddr.s_addr, 0, 0, 0);
 	if (IS_ERR(rt))
-		goto errout;
+		return ERR_CAST(rt);
 
 	dev = rt->dst.dev;
 	dev_hold(dev);
@@ -352,8 +352,6 @@ static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 	ip_rt_put(rt);
 
 	return dev;
-errout:
-	return ERR_PTR(-ENODEV);
 }
 #else
 static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
@@ -365,7 +363,7 @@ static struct net_device *inet_fib_lookup_dev(struct net *net, void *addr)
 #if IS_ENABLED(CONFIG_IPV6)
 static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 {
-	struct net_device *dev = NULL;
+	struct net_device *dev;
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 	int err;
@@ -377,16 +375,13 @@ static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 	memcpy(&fl6.daddr, addr, sizeof(struct in6_addr));
 	err = ipv6_stub->ipv6_dst_lookup(net, NULL, &dst, &fl6);
 	if (err)
-		goto errout;
+		return ERR_PTR(err);
 
 	dev = dst->dev;
 	dev_hold(dev);
 	dst_release(dst);
 
 	return dev;
-
-errout:
-	return ERR_PTR(err);
 }
 #else
 static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
