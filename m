From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v8 07/11] vxlan: respect disable_ipv6 sysctl
Date: Fri, 17 May 2013 08:21:35 +0800
Message-ID: <1368750099-14086-8-git-send-email-amwang@redhat.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755129Ab3EQAWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 20:22:07 -0400
In-Reply-To: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

When disable_ipv6 is set, we should not allow IPv6 vxlan
device created on top of it.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 46c59a6..1ee79e0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1681,6 +1681,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	struct vxlan_rdst *dst = &vxlan->default_dst;
 	__u32 vni;
 	int err;
+	bool use_ipv6 = false;
 
 	if (!data[IFLA_VXLAN_ID])
 		return -EINVAL;
@@ -1703,6 +1704,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		nla_memcpy(&dst->remote_ip.sin6.sin6_addr, data[IFLA_VXLAN_GROUP6],
 			   sizeof(struct in6_addr));
 		dst->remote_ip.sa.sa_family = AF_INET6;
+		use_ipv6 = true;
 #else
 		return -EPFNOSUPPORT;
 #endif
@@ -1719,6 +1721,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		nla_memcpy(&vxlan->saddr.sin6.sin6_addr, data[IFLA_VXLAN_LOCAL6],
 			   sizeof(struct in6_addr));
 		vxlan->saddr.sa.sa_family = AF_INET6;
+		use_ipv6 = true;
 #else
 		return -EPFNOSUPPORT;
 #endif
@@ -1734,6 +1737,17 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 			return -ENODEV;
 		}
 
+#if IS_ENABLED(CONFIG_IPV6)
+		if (use_ipv6) {
+			struct inet6_dev *idev = in6_dev_get(lowerdev);
+			if (idev && idev->cnf.disable_ipv6) {
+				pr_info("IPv6 is disabled via sysctl\n");
+				return -EPERM;
+			}
+		}
+#else
+		BUG_ON(use_ipv6);
+#endif
 		if (!tb[IFLA_MTU])
 			dev->mtu = lowerdev->mtu - VXLAN_HEADROOM;
 
-- 
1.7.7.6
