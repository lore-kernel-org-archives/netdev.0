From: Anton Blanchard <anton@samba.org>
Subject: ARP garbage collection issues in 3.1?
Date: Wed, 2 Nov 2011 15:34:43 +1100
Message-ID: <20111102153443.38cc1e5c@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46284 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781Ab1KBEep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 00:34:45 -0400
Received: from kryten (ppp121-44-79-234.lns20.syd6.internode.on.net [121.44.79.234])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(Client did not present a certificate)
	by ozlabs.org (Postfix) with ESMTPSA id 5946CB6F6F
	for <netdev@vger.kernel.org>; Wed,  2 Nov 2011 15:34:44 +1100 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I've been getting complaints about machines not garbage collecting
ARP entries. The network in question has a lot of MAC addresses on it
(probably more than gc_thresh3 - 1024), but this machine is only
talking over the network to a few targets.

Over a period of hours or days the ARP table slowly grows until it hits
gc_thresh3 and at that stage we get "Neighbour table overflow" errors.
Increasing gc_thresh3 makes the issue go away as expected. The question
is, why isn't this slow growth of the ARP table being managed by the
gc_thresh1 and gc_thresh2 watermarks?

I tried this simple test on 3.1-git*:

machine A:
for i in `seq 2 254`; do ifconfig eth0:$i 192.168.111.$i; done

machine B:
echo 64 > /proc/sys/net/ipv4/neigh/default/gc_thresh1
echo 128 > /proc/sys/net/ipv4/neigh/default/gc_thresh2
echo 192 > /proc/sys/net/ipv4/neigh/default/gc_thresh3

ifconfig eth0:1 192.168.111.1
for i in `seq 2 254`; do ping -c 1 192.168.111.$i; done

I was expecting to get the "Neighbour table overflow" errors and then
after a period of time the route and ARP garbage collection would kick
in. I waited for over an hour and this had not happened, we had
gc_thresh3 (192) ARP entries and no new ARP entries could be added to
the table.

The problem seems to be that our neighbour garbage collection thresholds
are set low (1024) and our route threshold is set high (524288). When we
get into trouble we do try to garbage collect routes but
rt_garbage_collect never sees enough entries to invoke garbage
collection. In effect the ARP entries are pinned, and gc_thresh1
gc_thresh2 are useless.

My first thought was the patch below. It does help but it's Russian
Roulette since we shoot one entry down at random and it might not be
one in the neighbour table. As such, it often takes a number of goes to
clear a stale ARP entry.

Any ideas how we could make this behave a bit better? I know setting
gc_thresh3 higher is the ultimate solution, but if gc_thresh1 and
gc_thresh2 are always below the route threshold we should either fix
this issue or remove them completely.

Anton

---
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 155138d..8104d41 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -876,7 +876,7 @@ static void rt_emergency_hash_rebuild(struct net *net)
    and when load increases it reduces to limit cache size.
  */
 
-static int rt_garbage_collect(struct dst_ops *ops)
+static int __rt_garbage_collect(struct dst_ops *ops, int force)
 {
 	static unsigned long expire = RT_GC_TIMEOUT;
 	static unsigned long last_gc;
@@ -895,7 +895,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
 
 	RT_CACHE_STAT_INC(gc_total);
 
-	if (now - last_gc < ip_rt_gc_min_interval &&
+	if (!force && now - last_gc < ip_rt_gc_min_interval &&
 	    entries < ip_rt_max_size) {
 		RT_CACHE_STAT_INC(gc_ignored);
 		goto out;
@@ -920,6 +920,9 @@ static int rt_garbage_collect(struct dst_ops *ops)
 		equilibrium = entries - goal;
 	}
 
+	if (force)
+		goal = 1;
+
 	if (now - last_gc >= ip_rt_gc_min_interval)
 		last_gc = now;
 
@@ -996,6 +999,11 @@ work_done:
 out:	return 0;
 }
 
+static int rt_garbage_collect(struct dst_ops *ops)
+{
+	return __rt_garbage_collect(ops, 0);
+}
+
 /*
  * Returns number of entries in a hash chain that have different hash_inputs
  */
@@ -1192,7 +1200,7 @@ restart:
 				int saved_int = ip_rt_gc_min_interval;
 				ip_rt_gc_elasticity	= 1;
 				ip_rt_gc_min_interval	= 0;
-				rt_garbage_collect(&ipv4_dst_ops);
+				__rt_garbage_collect(&ipv4_dst_ops, 1);
 				ip_rt_gc_min_interval	= saved_int;
 				ip_rt_gc_elasticity	= saved_elasticity;
 				goto restart;
