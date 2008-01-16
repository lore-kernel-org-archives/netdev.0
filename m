From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPV4] FIB_HASH : Avoid unecessary loop in fn_hash_dump_zone()
Date: Wed, 16 Jan 2008 18:19:25 +0100
Message-ID: <20080116181925.2c5c540f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:57047 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbYAPRUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 12:20:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed "ip route list" was slower than "cat /proc/net/route" on a machine with a full Internet
routing table (214392 entries : Special thanks to Robert ;) )

This is similar to problem reported in commit d8c9283089287341c85a0a69de32c2287a990e71

Fix is to avoid scanning the begining of fz_hash table, but directly seek to the right offset.

Before patch :

time ip route >/tmp/ROUTE

real    0m1.285s
user    0m0.712s
sys     0m0.436s

After patch

# time ip route >/tmp/ROUTE

real    0m0.835s
user    0m0.692s
sys     0m0.124s

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/ipv4/fib_hash.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 527a6e0..4156988 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -718,19 +718,18 @@ fn_hash_dump_zone(struct sk_buff *skb, struct netlink_callback *cb,
 {
 	int h, s_h;
 
+	if (fz->fz_hash == NULL)
+		return skb->len;
 	s_h = cb->args[3];
-	for (h=0; h < fz->fz_divisor; h++) {
-		if (h < s_h) continue;
-		if (h > s_h)
-			memset(&cb->args[4], 0,
-			       sizeof(cb->args) - 4*sizeof(cb->args[0]));
-		if (fz->fz_hash == NULL ||
-		    hlist_empty(&fz->fz_hash[h]))
+	for (h = s_h; h < fz->fz_divisor; h++) {
+		if (hlist_empty(&fz->fz_hash[h]))
 			continue;
-		if (fn_hash_dump_bucket(skb, cb, tb, fz, &fz->fz_hash[h])<0) {
+		if (fn_hash_dump_bucket(skb, cb, tb, fz, &fz->fz_hash[h]) < 0) {
 			cb->args[3] = h;
 			return -1;
 		}
+		memset(&cb->args[4], 0,
+		       sizeof(cb->args) - 4*sizeof(cb->args[0]));
 	}
 	cb->args[3] = h;
 	return skb->len;
@@ -746,14 +745,13 @@ static int fn_hash_dump(struct fib_table *tb, struct sk_buff *skb, struct netlin
 	read_lock(&fib_hash_lock);
 	for (fz = table->fn_zone_list, m=0; fz; fz = fz->fz_next, m++) {
 		if (m < s_m) continue;
-		if (m > s_m)
-			memset(&cb->args[3], 0,
-			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 		if (fn_hash_dump_zone(skb, cb, tb, fz) < 0) {
 			cb->args[2] = m;
 			read_unlock(&fib_hash_lock);
 			return -1;
 		}
+		memset(&cb->args[3], 0,
+		       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 	}
 	read_unlock(&fib_hash_lock);
 	cb->args[2] = m;
