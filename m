From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: ipv4: Multipath needs to handle unreachable nexthops
Date: Thu, 24 Mar 2016 08:25:54 -0700
Message-ID: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33562 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbcCXP0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 11:26:04 -0400
Received: by mail-pa0-f54.google.com with SMTP id fl4so24877709pad.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 08:26:04 -0700 (PDT)
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
when selecting next hops. If the neighbor lookups fails we have no
knowledge about the nexthop, so give it a shot. If there is an entry
then only select the nexthop if the state is sane. This is similar to
what fib_detect_death does for some single path cases.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_semantics.c | 34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d97268e8ff10..28fc6700c2b1 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1563,13 +1563,43 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
 void fib_select_multipath(struct fib_result *res, int hash)
 {
 	struct fib_info *fi = res->fi;
+	struct neighbour *n;
+	int state;
 
 	for_nexthops(fi) {
 		if (hash > atomic_read(&nh->nh_upper_bound))
 			continue;
 
-		res->nh_sel = nhsel;
-		return;
+		state = NUD_NONE;
+		n = neigh_lookup(&arp_tbl, &nh->nh_gw, fi->fib_dev);
+		if (n) {
+			state = n->nud_state;
+			neigh_release(n);
+		}
+		if (!n || (state == NUD_REACHABLE) || (state & NUD_VALID)) {
+			res->nh_sel = nhsel;
+			return;
+		}
+	} endfor_nexthops(fi);
+
+	/* try the nexthops again, but covering the entries
+	 * skipped by the hash
+	 */
+	fi = res->fi;
+	for_nexthops(fi) {
+		if (hash <= atomic_read(&nh->nh_upper_bound))
+			continue;
+
+		state = NUD_NONE;
+		n = neigh_lookup(&arp_tbl, &nh->nh_gw, fi->fib_dev);
+		if (n) {
+			state = n->nud_state;
+			neigh_release(n);
+		}
+		if (!n || (state == NUD_REACHABLE) || (state & NUD_VALID)) {
+			res->nh_sel = nhsel;
+			return;
+		}
 	} endfor_nexthops(fi);
 
 	/* Race condition: route has just become dead. */
-- 
1.9.1
