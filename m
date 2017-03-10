From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next 1/3] vxlan: don't allow link-local IPv6 local/remote addresses without interface
Date: Fri, 10 Mar 2017 23:39:42 +0100
Message-ID: <58db316c71cf5257ef5da86763c511f8c5938987.1489184335.git.mschiffer@universe-factory.net>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:41716 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932944AbdCJWkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 17:40:45 -0500
In-Reply-To: <cover.1489184335.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1489184335.git.mschiffer@universe-factory.net>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/vxlan.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e375560cc74e..cc0ace73d02e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2922,6 +2922,18 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		pr_info("multicast destination requires interface to be specified\n");
 		return -EINVAL;
 	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (!conf->remote_ifindex &&
+		 ((conf->saddr.sa.sa_family == AF_INET6 &&
+		  (ipv6_addr_type(&conf->saddr.sin6.sin6_addr) &
+		   IPV6_ADDR_LINKLOCAL)) ||
+		  (dst->remote_ip.sa.sa_family == AF_INET6 &&
+		   (ipv6_addr_type(&dst->remote_ip.sin6.sin6_addr) &
+		    IPV6_ADDR_LINKLOCAL)))) {
+		pr_info("link-local local/remote addresses require interface to be specified\n");
+		return -EINVAL;
+	}
+#endif
 
 	if (conf->mtu) {
 		int max_mtu = ETH_MAX_MTU;
-- 
2.12.0
