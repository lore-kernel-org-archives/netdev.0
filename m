From: fgao@ikuai8.com
Subject: [PATCH net-next 1/2] net: Avoid unnessary loop when master_idx is invalid in inet_select_addr
Date: Tue,  7 Mar 2017 22:50:59 +0800
Message-ID: <1488898259-18874-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg342.qq.com ([14.17.44.37]:55374 "EHLO smtpbg342.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751270AbdCGO5A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 09:57:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When master_idx is invalid, it is zero. It is unnecessary to iterate
all netdevs. Because l3mdev_master_ifindex_rcu(dev) != master_idx must
be true.
Now put this loop into the condition block when master_idx is valid.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/devinet.c | 68 +++++++++++++++++++++++++++++-------------------------
 1 file changed, 36 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5d367b7..1a9e550 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1219,42 +1219,46 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 no_in_dev:
 	master_idx = l3mdev_master_ifindex_rcu(dev);
 
-	/* For VRFs, the VRF device takes the place of the loopback device,
-	 * with addresses on it being preferred.  Note in such cases the
-	 * loopback device will be among the devices that fail the master_idx
-	 * equality check in the loop below.
-	 */
-	if (master_idx &&
-	    (dev = dev_get_by_index_rcu(net, master_idx)) &&
-	    (in_dev = __in_dev_get_rcu(dev))) {
-		for_primary_ifa(in_dev) {
-			if (ifa->ifa_scope != RT_SCOPE_LINK &&
-			    ifa->ifa_scope <= scope) {
-				addr = ifa->ifa_local;
-				goto out_unlock;
+	if (master_idx) {
+		/* For VRFs, the VRF device takes the place of the loopback device,
+		 * with addresses on it being preferred.  Note in such cases the
+		 * loopback device will be among the devices that fail the master_idx
+		 * equality check in the loop below.
+		 */
+		dev = dev_get_by_index_rcu(net, master_idx);
+		if (dev) {
+			in_dev = __in_dev_get_rcu(dev);
+			if (in_dev) {
+				for_primary_ifa(in_dev) {
+					if (ifa->ifa_scope != RT_SCOPE_LINK &&
+					    ifa->ifa_scope <= scope) {
+						addr = ifa->ifa_local;
+						goto out_unlock;
+					}
+				} endfor_ifa(in_dev);
 			}
-		} endfor_ifa(in_dev);
-	}
+		}
 
-	/* Not loopback addresses on loopback should be preferred
-	   in this case. It is important that lo is the first interface
-	   in dev_base list.
-	 */
-	for_each_netdev_rcu(net, dev) {
-		if (l3mdev_master_ifindex_rcu(dev) != master_idx)
-			continue;
+		/* Not loopback addresses on loopback should be preferred
+		   in this case. It is important that lo is the first interface
+		   in dev_base list.
+		 */
+		for_each_netdev_rcu(net, dev) {
+			if (l3mdev_master_ifindex_rcu(dev) != master_idx)
+				continue;
 
-		in_dev = __in_dev_get_rcu(dev);
-		if (!in_dev)
-			continue;
+			in_dev = __in_dev_get_rcu(dev);
+			if (!in_dev)
+				continue;
 
-		for_primary_ifa(in_dev) {
-			if (ifa->ifa_scope != RT_SCOPE_LINK &&
-			    ifa->ifa_scope <= scope) {
-				addr = ifa->ifa_local;
-				goto out_unlock;
-			}
-		} endfor_ifa(in_dev);
+			for_primary_ifa(in_dev) {
+				if (ifa->ifa_scope != RT_SCOPE_LINK &&
+				    ifa->ifa_scope <= scope) {
+					addr = ifa->ifa_local;
+					goto out_unlock;
+				}
+			} endfor_ifa(in_dev);
+		}
 	}
 out_unlock:
 	rcu_read_unlock();
-- 
1.9.1
