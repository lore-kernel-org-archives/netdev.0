From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : restore multipath routing after rt_next changes
Date: Sat, 10 Feb 2007 12:11:31 +0100
Message-ID: <45CDA863.1060103@cosmosbay.com>
References: <20070210023710.c7383c32.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050804020900090402050902"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41954 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbXBJLLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 06:11:49 -0500
In-Reply-To: <20070210023710.c7383c32.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050804020900090402050902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Andrew Morton a écrit :
> net/ipv4/multipath_rr.c: In function 'rr_select_route':
> net/ipv4/multipath_rr.c:60: error: 'union <anonymous>' has no member named 'rt_next'
> net/ipv4/multipath_rr.c:60: warning: type defaults to 'int' in declaration of '_________p1'
> net/ipv4/multipath_rr.c:60: error: 'union <anonymous>' has no member named 'rt_next'
> net/ipv4/multipath_rr.c:60: warning: assignment makes pointer from integer without a cast
> make[2]: *** [net/ipv4/multipath_rr.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> net/ipv4/multipath_random.c: In function 'random_select_route':
> net/ipv4/multipath_random.c:76: error: 'union <anonymous>' has no member named 'rt_next'
> net/ipv4/multipath_random.c:76: warning: type defaults to 'int' in declaration of '_________p1'
> net/ipv4/multipath_random.c:76: error: 'union <anonymous>' has no member named 'rt_next'
> net/ipv4/multipath_random.c:76: warning: assignment makes pointer from integer without a cast
> net/ipv4/multipath_random.c:92: error: 'union <anonymous>' has no member named 'rt_next'
> 
> 

[PATCH] : NET : restore multipath routing after rt_next changes

I forgot to test build this part of the networking code... Sorry guys.
This patch renames u.rt_next to u.dst.rt_next

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------050804020900090402050902
Content-Type: text/plain;
 name="multipath.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="multipath.patch"

--- net-2.6/net/ipv4/multipath_rr.c	2007-02-10 13:01:22.000000000 +0100
+++ net-2.6-ed/net/ipv4/multipath_rr.c	2007-02-10 13:01:47.000000000 +0100
@@ -58,7 +58,7 @@ static void rr_select_route(const struct
 	 */
 	result = NULL;
 	for (nh = rcu_dereference(first); nh;
-	     nh = rcu_dereference(nh->u.rt_next)) {
+	     nh = rcu_dereference(nh->u.dst.rt_next)) {
 		if ((nh->u.dst.flags & DST_BALANCED) != 0 &&
 		    multipath_comparekeys(&nh->fl, flp)) {
 			nh->u.dst.lastuse = jiffies;
--- net-2.6/net/ipv4/multipath_random.c	2007-02-10 13:04:28.000000000 +0100
+++ net-2.6-ed/net/ipv4/multipath_random.c	2007-02-10 13:04:47.000000000 +0100
@@ -74,7 +74,7 @@ static void random_select_route(const st
 
 	/* count all candidate */
 	for (rt = rcu_dereference(first); rt;
-	     rt = rcu_dereference(rt->u.rt_next)) {
+	     rt = rcu_dereference(rt->u.dst.rt_next)) {
 		if ((rt->u.dst.flags & DST_BALANCED) != 0 &&
 		    multipath_comparekeys(&rt->fl, flp))
 			++candidate_count;
@@ -90,7 +90,7 @@ static void random_select_route(const st
 		/* find chosen candidate and adjust GC data for all candidates
 		 * to ensure they stay in cache
 		 */
-		for (rt = first; rt; rt = rt->u.rt_next) {
+		for (rt = first; rt; rt = rt->u.dst.rt_next) {
 			if ((rt->u.dst.flags & DST_BALANCED) != 0 &&
 			    multipath_comparekeys(&rt->fl, flp)) {
 				rt->u.dst.lastuse = jiffies;
--- net-2.6/net/ipv4/multipath_wrandom.c	2007-02-10 13:05:54.000000000 +0100
+++ net-2.6-ed/net/ipv4/multipath_wrandom.c	2007-02-10 13:06:16.000000000 +0100
@@ -167,7 +167,7 @@ static void wrandom_select_route(const s
 
 	/* collect all candidates and identify their weights */
 	for (rt = rcu_dereference(first); rt;
-	     rt = rcu_dereference(rt->u.rt_next)) {
+	     rt = rcu_dereference(rt->u.dst.rt_next)) {
 		if ((rt->u.dst.flags & DST_BALANCED) != 0 &&
 		    multipath_comparekeys(&rt->fl, flp)) {
 			struct multipath_candidate* mpc =
--- net-2.6/net/ipv4/multipath_drr.c	2007-02-10 13:06:52.000000000 +0100
+++ net-2.6-ed/net/ipv4/multipath_drr.c	2007-02-10 13:07:04.000000000 +0100
@@ -143,7 +143,7 @@ static void drr_select_route(const struc
 	result = NULL;
 	cur_min = NULL;
 	for (nh = rcu_dereference(first); nh;
-	     nh = rcu_dereference(nh->u.rt_next)) {
+	     nh = rcu_dereference(nh->u.dst.rt_next)) {
 		if ((nh->u.dst.flags & DST_BALANCED) != 0 &&
 		    multipath_comparekeys(&nh->fl, flp)) {
 			int nh_ifidx = nh->u.dst.dev->ifindex;

--------------050804020900090402050902--
