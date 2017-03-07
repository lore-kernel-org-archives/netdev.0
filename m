From: fgao@ikuai8.com
Subject: [PATCH net-next 2/2] net: Eliminate duplicated codes by creating one new function in_dev_select_addr
Date: Tue,  7 Mar 2017 22:51:19 +0800
Message-ID: <1488898279-18930-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG252.QQ.COM ([183.60.52.105]:34832 "EHLO smtpbg252.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932589AbdCGO4T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 09:56:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are two duplicated loop codes which used to select right
address in current codes. Now eliminate these codes by creating
one new function in_dev_select_addr.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/devinet.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 1a9e550..d0964c5 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1191,6 +1191,19 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
 	return done;
 }
 
+static __be32 in_dev_select_addr(const struct in_device *in_dev,
+				 int scope)
+{
+	for_primary_ifa(in_dev) {
+		if (ifa->ifa_scope != RT_SCOPE_LINK &&
+		    ifa->ifa_scope <= scope) {
+			return ifa->ifa_local;
+		}
+	} endfor_ifa(in_dev);
+
+	return 0;
+}
+
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 {
 	__be32 addr = 0;
@@ -1229,13 +1242,9 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 		if (dev) {
 			in_dev = __in_dev_get_rcu(dev);
 			if (in_dev) {
-				for_primary_ifa(in_dev) {
-					if (ifa->ifa_scope != RT_SCOPE_LINK &&
-					    ifa->ifa_scope <= scope) {
-						addr = ifa->ifa_local;
-						goto out_unlock;
-					}
-				} endfor_ifa(in_dev);
+				addr = in_dev_select_addr(in_dev, scope);
+				if (addr)
+					goto out_unlock;
 			}
 		}
 
@@ -1250,14 +1259,9 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 			in_dev = __in_dev_get_rcu(dev);
 			if (!in_dev)
 				continue;
-
-			for_primary_ifa(in_dev) {
-				if (ifa->ifa_scope != RT_SCOPE_LINK &&
-				    ifa->ifa_scope <= scope) {
-					addr = ifa->ifa_local;
-					goto out_unlock;
-				}
-			} endfor_ifa(in_dev);
+			addr = in_dev_select_addr(in_dev, scope);
+			if (addr)
+				goto out_unlock;
 		}
 	}
 out_unlock:
-- 
1.9.1
