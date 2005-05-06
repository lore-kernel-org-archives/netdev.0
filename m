From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Avoid useless iterating in netlink dump functions
Date: Fri, 06 May 2005 17:39:47 +0200
Message-ID: <427B8FC3.4000305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010904070101080906080802"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010904070101080906080802
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This patch changes a couple of places like this:

       for (h = 0; h <= tbl->hash_mask; h++) {
               if (h < s_h)
                       continue;

to this:

       for (h = s_h; h <= tbl->hash_mask; h++) {

The only difference is that we can now get past the loop with
h > tbl->hash_mask if hash_mask was decreased between two callbacks
and h was already past the new value. But it still behaves identical,
nothing is dumped.



--------------010904070101080906080802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Avoid useless iterating in netlink dump functions

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4c2ae3efd96b7c6ed7ae62d820c13e95ba8564f1
tree 9f5362e759864bc9b3185ba39b0441952b0b8468
parent 6a800d456a81a9046634bcd26d868fd537f0c9ae
author Patrick McHardy <kaber@trash.net> 1115327686 +0200
committer Patrick McHardy <kaber@trash.net> 1115327686 +0200

Index: net/core/neighbour.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/core/neighbour.c  (mode:100644 sha1:43bdc521e20d9564ccec6472b30d95328e7d1329)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/core/neighbour.c  (mode:100644 sha1:71d444de4bb752511ea838710248130d1559eb4e)
@@ -1598,9 +1598,7 @@
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
 
-	for (h = 0; h <= tbl->hash_mask; h++) {
-		if (h < s_h)
-			continue;
+	for (h = s_h; h <= tbl->hash_mask; h++) {
 		if (h > s_h)
 			s_idx = 0;
 		read_lock_bh(&tbl->lock);
Index: net/core/rtnetlink.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/core/rtnetlink.c  (mode:100644 sha1:00caf4b318b20831c8fad5226c7c3cd358b4995b)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/core/rtnetlink.c  (mode:100644 sha1:bfb5b8efa710524ba4ee7cd14acf7c49a6fac004)
@@ -419,9 +419,9 @@
 
 	if (s_idx == 0)
 		s_idx = 1;
-	for (idx=1; idx<NPROTO; idx++) {
+	for (idx = s_idx; idx < NPROTO; idx++) {
 		int type = cb->nlh->nlmsg_type-RTM_BASE;
-		if (idx < s_idx || idx == PF_PACKET)
+		if (idx == PF_PACKET)
 			continue;
 		if (rtnetlink_links[idx] == NULL ||
 		    rtnetlink_links[idx][type].dumpit == NULL)
Index: net/decnet/dn_route.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/decnet/dn_route.c  (mode:100644 sha1:1e7b5c3ea2154d94251d04ea0de69fda06f9f58e)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/decnet/dn_route.c  (mode:100644 sha1:2b2bad3e4f902a8fb595596c35263c96e7c10779)
@@ -1631,9 +1631,7 @@
 
 	s_h = cb->args[0];
 	s_idx = idx = cb->args[1];
-	for(h = 0; h <= dn_rt_hash_mask; h++) {
-		if (h < s_h)
-			continue;
+	for(h = s_h; h <= dn_rt_hash_mask; h++) {
 		if (h > s_h)
 			s_idx = 0;
 		rcu_read_lock_bh();
Index: net/decnet/dn_table.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/decnet/dn_table.c  (mode:100644 sha1:dad5603912be3ed4959fb4d5565c9df4d5830f25)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/decnet/dn_table.c  (mode:100644 sha1:23d106be9fdf41e4afd1e83377607084c08e8c68)
@@ -394,9 +394,7 @@
 	int h, s_h;
 
 	s_h = cb->args[2];
-	for(h = 0; h < dz->dz_divisor; h++) {
-		if (h < s_h)
-			continue;
+	for(h = s_h; h < dz->dz_divisor; h++) {
 		if (h > s_h)
 			memset(&cb->args[3], 0, sizeof(cb->args) - 3*sizeof(cb->args[0]));
 		if (dz->dz_hash == NULL || dz->dz_hash[h] == NULL)
Index: net/ipv4/fib_frontend.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/ipv4/fib_frontend.c  (mode:100644 sha1:563e7d61270612b64a5f67684c5eea1662b66a31)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/ipv4/fib_frontend.c  (mode:100644 sha1:f398b2fc63c1c48cdbfb20fae330ff3a60e51ed8)
@@ -344,8 +344,7 @@
 	if (s_t == 0)
 		s_t = cb->args[0] = RT_TABLE_MIN;
 
-	for (t=s_t; t<=RT_TABLE_MAX; t++) {
-		if (t < s_t) continue;
+	for (t = s_t; t <= RT_TABLE_MAX; t++) {
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
 		if ((tb = fib_get_table(t))==NULL)
Index: net/ipv4/fib_hash.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/ipv4/fib_hash.c  (mode:100644 sha1:6506dcc01b460e7c5af35ff756f4819c23bd5d30)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/ipv4/fib_hash.c  (mode:100644 sha1:c1cebf82001b3a2c9d512c75b769baf0d4b6888f)
@@ -723,8 +723,7 @@
 	int h, s_h;
 
 	s_h = cb->args[2];
-	for (h=0; h < fz->fz_divisor; h++) {
-		if (h < s_h) continue;
+	for (h = s_h; h < fz->fz_divisor; h++) {
 		if (h > s_h)
 			memset(&cb->args[3], 0,
 			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
Index: net/ipv4/route.c
===================================================================
--- b969230022b6b8a7a93466b7ddef6b3d0a79fea3/net/ipv4/route.c  (mode:100644 sha1:199311746932ee3952abebc5d008b8c9daf9c11b)
+++ 9f5362e759864bc9b3185ba39b0441952b0b8468/net/ipv4/route.c  (mode:100644 sha1:6a96ebfb4a1a23f7c6ce8a743160b3ae3e74020e)
@@ -2770,8 +2770,7 @@
 
 	s_h = cb->args[0];
 	s_idx = idx = cb->args[1];
-	for (h = 0; h <= rt_hash_mask; h++) {
-		if (h < s_h) continue;
+	for (h = s_h; h <= rt_hash_mask; h++) {
 		if (h > s_h)
 			s_idx = 0;
 		rcu_read_lock_bh();

--------------010904070101080906080802--
