From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: [PATCH] ipsec: Fix error handling in the function xfrm6_get_addr
Date: Tue,  5 Apr 2016 10:23:39 -0400
Message-ID: <1459866219-19195-1-git-send-email-bastienphilbert@gmail.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the error handling in the function xfrm_get_addr by
checking if the call to ipv6_dev_get_saddr has failed and if
so return -EADDRNOTAVAIL to signal to the caller of xfrm6_get_addr
that the call has failed the error should be handled by the caller
while also freeing the dst_entry structure pointer in use by this

Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
---
 net/ipv6/xfrm6_policy.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c074771..759473e 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -64,7 +64,10 @@ static int xfrm6_get_saddr(struct net *net, int oif,
 		return -EHOSTUNREACH;
 
 	dev = ip6_dst_idev(dst)->dev;
-	ipv6_dev_get_saddr(dev_net(dev), dev, &daddr->in6, 0, &saddr->in6);
+	if (ipv6_dev_get_saddr(dev_net(dev), dev, &daddr->in6, 0, &saddr->in6)) {
+		dst_release(dst);
+		return -EADDRNOTAVAIL;
+	}
 	dst_release(dst);
 	return 0;
 }
-- 
2.5.0
