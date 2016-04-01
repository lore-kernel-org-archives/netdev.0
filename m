From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v3 net-next] net: ipv4: Consider failed nexthops in multipath routes
Date: Fri,  1 Apr 2016 08:17:04 -0700
Message-ID: <1459523824-29828-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ja@ssi.bg, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33396 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbcDAPRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:17:11 -0400
Received: by mail-pa0-f45.google.com with SMTP id zm5so93077858pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:17:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multipath route lookups should consider knowledge about next hops and not
select a hop that is known to be failed.

Example:

                     [h2]                   [h3]   15.0.0.5
                      |                      |
                     3|                     3|
                    [SP1]                  [SP2]--+
                     1  2                   1     2
                     |  |     /-------------+     |
                     |   \   /                    |
                     |     X                      |
                     |    / \                     |
                     |   /   \---------------\    |
                     1  2                     1   2
         12.0.0.2  [TOR1] 3-----------------3 [TOR2] 12.0.0.3
                     4                         4
                      \                       /
                        \                    /
                         \                  /
                          -------|   |-----/
                                 1   2
                                [TOR3]
                                  3|
                                   |
                                  [h1]  12.0.0.1

host h1 with IP 12.0.0.1 has 2 paths to host h3 at 15.0.0.5:

    root@h1:~# ip ro ls
    ...
    12.0.0.0/24 dev swp1  proto kernel  scope link  src 12.0.0.1
    15.0.0.0/16
            nexthop via 12.0.0.2  dev swp1 weight 1
            nexthop via 12.0.0.3  dev swp1 weight 1
    ...

If the link between tor3 and tor1 is down and the link between tor1
and tor2 then tor1 is effectively cut-off from h1. Yet the route lookups
in h1 are alternating between the 2 routes: ping 15.0.0.5 gets one and
ssh 15.0.0.5 gets the other. Connections that attempt to use the
12.0.0.2 nexthop fail since that neighbor is not reachable:

    root@h1:~# ip neigh show
    ...
    12.0.0.3 dev swp1 lladdr 00:02:00:00:00:1b REACHABLE
    12.0.0.2 dev swp1  FAILED
    ...

The failed path can be avoided by considering known neighbor information
when selecting next hops. If the neighbor lookup fails we have no
knowledge about the nexthop, so give it a shot. If there is an entry
then only select the nexthop if the state is sane. This is similar to
what fib_detect_death does. If all neighbors have failed then
fallback to first selection as done today.

To maintain backward compatibility use of the neighbor information is
based on a new sysctl, fib_multipath_use_neigh.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- Julian comments: changed use of dead in documentation to failed,
  init state to NUD_REACHABLE which simplifies fib_good_nh, use of
  nh_dev for neighbor lookup, fallback to first entry which is what
  current logic does

v2
- use rcu locking to avoid refcnts per Eric's suggestion
- only consider neighbor info for nh_scope == RT_SCOPE_LINK per Julian's
  comment
- drop the 'state == NUD_REACHABLE' from the state check since it is
  part of NUD_VALID (comment from Julian)
- wrapped the use of the neigh in a sysctl

 Documentation/networking/ip-sysctl.txt | 10 ++++++++++
 include/net/netns/ipv4.h               |  3 +++
 net/ipv4/fib_semantics.c               | 32 ++++++++++++++++++++++++++++----
 net/ipv4/sysctl_net_ipv4.c             | 11 +++++++++++
 4 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index b183e2b606c8..d6b3a3b06392 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -63,6 +63,16 @@ fwmark_reflect - BOOLEAN
 	fwmark of the packet they are replying to.
 	Default: 0
 
+fib_multipath_use_neigh - BOOLEAN
+	Use status of existing neighbor entry when determining nexthop for
+	multipath routes. If disabled, neighbor information is not used and
+	packets could be directed to a failed nexthop. Only valid for kernels
+	built with CONFIG_IP_ROUTE_MULTIPATH enabled.
+	Default: 0 (disabled)
+	Possible values:
+	0 - disabled
+	1 - enabled
+
 route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
 	this when using large numbers of interfaces and/or routes.
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index a69cde3ce460..d061ffeb1e71 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -133,6 +133,9 @@ struct netns_ipv4 {
 	struct fib_rules_ops	*mr_rules_ops;
 #endif
 #endif
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	int sysctl_fib_multipath_use_neigh;
+#endif
 	atomic_t	rt_genid;
 };
 #endif
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d97268e8ff10..e08abf96824a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1559,21 +1559,45 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
+static bool fib_good_nh(const struct fib_nh *nh)
+{
+	int state = NUD_REACHABLE;
+
+	if (nh->nh_scope == RT_SCOPE_LINK) {
+		struct neighbour *n = NULL;
+
+		rcu_read_lock_bh();
+
+		n = __neigh_lookup_noref(&arp_tbl, &nh->nh_gw, nh->nh_dev);
+		if (n)
+			state = n->nud_state;
+
+		rcu_read_unlock_bh();
+	}
+
+	return !!(state & NUD_VALID);
+}
 
 void fib_select_multipath(struct fib_result *res, int hash)
 {
 	struct fib_info *fi = res->fi;
+	struct net *net = fi->fib_net;
+	unsigned char first_nhsel = 0;
 
 	for_nexthops(fi) {
 		if (hash > atomic_read(&nh->nh_upper_bound))
 			continue;
 
-		res->nh_sel = nhsel;
-		return;
+		if (!net->ipv4.sysctl_fib_multipath_use_neigh ||
+		    fib_good_nh(nh)) {
+			res->nh_sel = nhsel;
+			return;
+		}
+		if (!first_nhsel)
+			first_nhsel = nhsel;
 	} endfor_nexthops(fi);
 
-	/* Race condition: route has just become dead. */
-	res->nh_sel = 0;
+	res->nh_sel = first_nhsel;
 }
 #endif
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1e1fe6086dd9..bb0419582b8d 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -960,6 +960,17 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	{
+		.procname	= "fib_multipath_use_neigh",
+		.data		= &init_net.ipv4.sysctl_fib_multipath_use_neigh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
 	{ }
 };
 
-- 
1.9.1
