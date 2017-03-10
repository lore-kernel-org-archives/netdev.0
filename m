From: fgao@ikuai8.com
Subject: [PATCH v2 net-next 2/2] net: Eliminate duplicated codes by creating one new function in_dev_select_addr
Date: Fri, 10 Mar 2017 09:44:33 +0800
Message-ID: <1489110273-29481-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg320.qq.com ([14.17.32.29]:41983 "EHLO smtpbg320.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932097AbdCJBql (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 20:46:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are two duplicated loops codes which used to select right
address in current codes. Now eliminate these codes by creating
one new function in_dev_select_addr.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Correct the comit log and remove useless braces, per Sergei
 v1: Initial Version

 net/ipv4/devinet.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 1a9e550..f82d545 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1191,6 +1191,18 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
 	return done;
 }
 
+static __be32 in_dev_select_addr(const struct in_device *in_dev,
+				 int scope)
+{
+	for_primary_ifa(in_dev) {
+		if (ifa->ifa_scope != RT_SCOPE_LINK &&
+		    ifa->ifa_scope <= scope)
+			return ifa->ifa_local;
+	} endfor_ifa(in_dev);
+
+	return 0;
+}
+
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 {
 	__be32 addr = 0;
@@ -1229,13 +1241,9 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
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
 
@@ -1250,14 +1258,9 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
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
