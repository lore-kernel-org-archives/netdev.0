From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ipv6: fib: Provide offload indication using nexthop flags
Date: Tue, 15 Aug 2017 09:09:49 +0200
Message-ID: <20170815070949.1363-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36668 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752494AbdHOHJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 03:09:53 -0400
Received: by mail-wr0-f193.google.com with SMTP id y67so112122wrb.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 00:09:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

IPv6 routes currently lack nexthop flags as in IPv4. This has several
implications.

In the forwarding path, it requires us to check the carrier state of the
nexthop device and potentially ignore a linkdown route, instead of
checking for RTNH_F_LINKDOWN.

It also requires capable drivers to use the user facing IPv6-specific
route flags to provide offload indication, instead of using the nexthop
flags as in IPv4.

Add nexthop flags to IPv6 routes in the 40 bytes hole and use it to
provide offload indication instead of the RTF_OFFLOAD flag, which is
removed while it's still not part of any official kernel release.

In the near future we would like to use the field for the
RTNH_F_{LINKDOWN,DEAD} flags, but this change is more involved and might
not be ready in time for the current cycle.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 8 ++++----
 include/net/ip6_fib.h                                 | 2 ++
 include/uapi/linux/ipv6_route.h                       | 1 -
 net/ipv6/route.c                                      | 7 +------
 4 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 16676ff..4895d5b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2397,7 +2397,7 @@ mlxsw_sp_fib6_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 
 	if (fib_entry->type == MLXSW_SP_FIB_ENTRY_TYPE_LOCAL) {
 		list_first_entry(&fib6_entry->rt6_list, struct mlxsw_sp_rt6,
-				 list)->rt->rt6i_flags |= RTF_OFFLOAD;
+				 list)->rt->rt6i_nh_flags |= RTNH_F_OFFLOAD;
 		return;
 	}
 
@@ -2407,9 +2407,9 @@ mlxsw_sp_fib6_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 
 		nh = mlxsw_sp_rt6_nexthop(nh_grp, mlxsw_sp_rt6);
 		if (nh && nh->offloaded)
-			mlxsw_sp_rt6->rt->rt6i_flags |= RTF_OFFLOAD;
+			mlxsw_sp_rt6->rt->rt6i_nh_flags |= RTNH_F_OFFLOAD;
 		else
-			mlxsw_sp_rt6->rt->rt6i_flags &= ~RTF_OFFLOAD;
+			mlxsw_sp_rt6->rt->rt6i_nh_flags &= ~RTNH_F_OFFLOAD;
 	}
 }
 
@@ -2424,7 +2424,7 @@ mlxsw_sp_fib6_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
 	list_for_each_entry(mlxsw_sp_rt6, &fib6_entry->rt6_list, list) {
 		struct rt6_info *rt = mlxsw_sp_rt6->rt;
 
-		rt->rt6i_flags &= ~RTF_OFFLOAD;
+		rt->rt6i_nh_flags &= ~RTNH_F_OFFLOAD;
 	}
 }
 
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 1d790ea..71c1646 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -120,6 +120,8 @@ struct rt6_info {
 
 	atomic_t			rt6i_ref;
 
+	unsigned int			rt6i_nh_flags;
+
 	/* These are in a separate cache line. */
 	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
 	u32				rt6i_flags;
diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index 33e2a57..d496c02 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -35,7 +35,6 @@
 #define RTF_PREF(pref)	((pref) << 27)
 #define RTF_PREF_MASK	0x18000000
 
-#define RTF_OFFLOAD	0x20000000	/* offloaded route		*/
 #define RTF_PCPU	0x40000000	/* read-only: can not be set by user */
 #define RTF_LOCAL	0x80000000
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 035762f..6793135 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1820,11 +1820,6 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
 		goto out;
 	}
 
-	if (cfg->fc_flags & RTF_OFFLOAD) {
-		NL_SET_ERR_MSG(extack, "Userspace can not set RTF_OFFLOAD");
-		goto out;
-	}
-
 	if (cfg->fc_dst_len > 128) {
 		NL_SET_ERR_MSG(extack, "Invalid prefix length");
 		goto out;
@@ -3335,7 +3330,7 @@ static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
 			goto nla_put_failure;
 	}
 
-	if (rt->rt6i_flags & RTF_OFFLOAD)
+	if (rt->rt6i_nh_flags & RTNH_F_OFFLOAD)
 		*flags |= RTNH_F_OFFLOAD;
 
 	/* not needed for multipath encoding b/c it has a rtnexthop struct */
-- 
2.9.3
