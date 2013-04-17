From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Wed, 17 Apr 2013 13:10:21 +0800
Message-ID: <1366175423-27310-5-git-send-email-amwang@redhat.com>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab3DQFLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 01:11:14 -0400
In-Reply-To: <1366175423-27310-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As David suggested, we should support ll addr, which requires
scope id.

Cc: David Stevens <dlstevens@us.ibm.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 43ed40f..531c5e2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -92,9 +92,10 @@ struct vxlan_addr {
 		struct sockaddr_in6	sin6;
 		struct sockaddr		sa;
 	} u;
-#define va_sin  u.sin.sin_addr.s_addr
-#define va_sin6 u.sin6.sin6_addr
-#define va_sa   u.sa.sa_family
+#define va_sin		u.sin.sin_addr.s_addr
+#define va_sin6		u.sin6.sin6_addr
+#define va_scope_id	u.sin6.sin6_scope_id
+#define va_sa		u.sa.sa_family
 };
 
 struct vxlan_rdst {
@@ -1674,6 +1675,9 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		nla_memcpy(&dst->remote_ip.va_sin6, data[IFLA_VXLAN_REMOTE6],
 			   sizeof(struct in6_addr));
 		dst->remote_ip.va_sa = AF_INET6;
+		if (__ipv6_addr_needs_scope_id(__ipv6_addr_type(&dst->remote_ip.va_sin6))
+			    && !data[IFLA_VXLAN_LINK])
+					return -EINVAL;
 #else
 		return -EPFNOSUPPORT;
 #endif
@@ -1708,6 +1712,17 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		/* update header length based on lower device */
 		dev->hard_header_len = lowerdev->hard_header_len +
 				       VXLAN_HEADROOM;
+#if IS_ENABLED(CONFIG_IPV6)
+		dst->remote_ip.va_scope_id = ipv6_iface_scope_id(&dst->remote_ip.va_sin6,
+								 dst->remote_ifindex);
+		if (ipv6_addr_type(&dst->remote_ip.va_sin6) & IPV6_ADDR_LINKLOCAL) {
+			struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+			struct sock *sk = vn->sock->sk;
+
+                        sk->sk_bound_dev_if = dst->remote_ip.va_scope_id;
+		}
+#endif
+
 	}
 
 	if (data[IFLA_VXLAN_TOS])
-- 
1.7.7.6
