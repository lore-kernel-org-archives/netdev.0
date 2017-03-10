From: fgao@ikuai8.com
Subject: [PATCH v4 net-next 1/1] net: Eliminate duplicated codes by creating one new function in_dev_select_addr
Date: Fri, 10 Mar 2017 12:38:47 +0800
Message-ID: <1489120727-22775-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg328.qq.com ([14.17.43.160]:48702 "EHLO smtpbg328.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754151AbdCJEka (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 23:40:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are two duplicated loops codes which used to select right
address in current codes. Now eliminate these codes by creating
one new function in_dev_select_addr.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v4: Drop the first patch in series, per David Ahern
 v3: Add the cover letter, per David
 v2: Correct the comit log and remove useless braces, per Sergei
 v1: Initial Version

 net/ipv4/devinet.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5d367b7..6bdcd21 100644
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
@@ -1227,13 +1239,9 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	if (master_idx &&
 	    (dev = dev_get_by_index_rcu(net, master_idx)) &&
 	    (in_dev = __in_dev_get_rcu(dev))) {
-		for_primary_ifa(in_dev) {
-			if (ifa->ifa_scope != RT_SCOPE_LINK &&
-			    ifa->ifa_scope <= scope) {
-				addr = ifa->ifa_local;
-				goto out_unlock;
-			}
-		} endfor_ifa(in_dev);
+		addr = in_dev_select_addr(in_dev, scope);
+		if (addr)
+			goto out_unlock;
 	}
 
 	/* Not loopback addresses on loopback should be preferred
@@ -1248,13 +1256,9 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 		if (!in_dev)
 			continue;
 
-		for_primary_ifa(in_dev) {
-			if (ifa->ifa_scope != RT_SCOPE_LINK &&
-			    ifa->ifa_scope <= scope) {
-				addr = ifa->ifa_local;
-				goto out_unlock;
-			}
-		} endfor_ifa(in_dev);
+		addr = in_dev_select_addr(in_dev, scope);
+		if (addr)
+			goto out_unlock;
 	}
 out_unlock:
 	rcu_read_unlock();
-- 
1.9.1
