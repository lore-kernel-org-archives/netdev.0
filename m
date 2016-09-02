From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Subject: [PATCH] net: Don't delete routes in different VRFs
Date: Fri,  2 Sep 2016 17:26:07 +1200
Message-ID: <20160902052607.9303-1-mark.tomlinson@alliedtelesis.co.nz>
Cc: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:36405 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbcIBF0O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:26:14 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id CAB27806B6
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 17:26:10 +1200 (NZST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When deleting an IP address from an interface, there is a clean-up of
routes which refer to this local address. However, there was no check to
see that the VRF matched. This meant that deletion wasn't confined to
the VRF it should have been.

To solve this, a new field has been added to fib_info to hold a table
id. When removing fib entries corresponding to a local ip address, this
table id is also used in the comparison.

The table id is populated when the fib_info is created. This was already
done in some places, but not in ip_rt_ioctl(). This has now been fixed.

Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
---
 include/net/ip_fib.h     | 3 ++-
 net/ipv4/fib_frontend.c  | 3 ++-
 net/ipv4/fib_semantics.c | 8 ++++++--
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 4079fc1..7d4a72e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -111,6 +111,7 @@ struct fib_info {
 	unsigned char		fib_scope;
 	unsigned char		fib_type;
 	__be32			fib_prefsrc;
+	u32			fib_tb_id;
 	u32			fib_priority;
 	u32			*fib_metrics;
 #define fib_mtu fib_metrics[RTAX_MTU-1]
@@ -319,7 +320,7 @@ void fib_flush_external(struct net *net);
 /* Exported by fib_semantics.c */
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
 int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force);
-int fib_sync_down_addr(struct net *net, __be32 local);
+int fib_sync_down_addr(struct net_device *dev, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 
 extern u32 fib_multipath_secret __read_mostly;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index ef2ebeb..1b25daf 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -509,6 +509,7 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 		if (!dev)
 			return -ENODEV;
 		cfg->fc_oif = dev->ifindex;
+		cfg->fc_table = l3mdev_fib_table(dev);
 		if (colon) {
 			struct in_ifaddr *ifa;
 			struct in_device *in_dev = __in_dev_get_rtnl(dev);
@@ -1027,7 +1028,7 @@ no_promotions:
 			 * First of all, we scan fib_info list searching
 			 * for stray nexthop entries, then ignite fib_flush.
 			 */
-			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local))
+			if (fib_sync_down_addr(dev, ifa->ifa_local))
 				fib_flush(dev_net(dev));
 		}
 	}
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 539fa26..e9f5622 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1057,6 +1057,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi->fib_priority = cfg->fc_priority;
 	fi->fib_prefsrc = cfg->fc_prefsrc;
 	fi->fib_type = cfg->fc_type;
+	fi->fib_tb_id = cfg->fc_table;
 
 	fi->fib_nhs = nhs;
 	change_nexthops(fi) {
@@ -1337,18 +1338,21 @@ nla_put_failure:
  *   referring to it.
  * - device went down -> we must shutdown all nexthops going via it.
  */
-int fib_sync_down_addr(struct net *net, __be32 local)
+int fib_sync_down_addr(struct net_device *dev, __be32 local)
 {
 	int ret = 0;
 	unsigned int hash = fib_laddr_hashfn(local);
 	struct hlist_head *head = &fib_info_laddrhash[hash];
+	struct net *net = dev_net(dev);
+	int tb_id = l3mdev_fib_table(dev);
 	struct fib_info *fi;
 
 	if (!fib_info_laddrhash || local == 0)
 		return 0;
 
 	hlist_for_each_entry(fi, head, fib_lhash) {
-		if (!net_eq(fi->fib_net, net))
+		if (!net_eq(fi->fib_net, net) ||
+		    fi->fib_tb_id != tb_id)
 			continue;
 		if (fi->fib_prefsrc == local) {
 			fi->fib_flags |= RTNH_F_DEAD;
-- 
2.9.3
