From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Thu, 9 Jul 2009 00:34:59 +0200
Message-ID: <20090708223459.GB3666@ami.dom.local>
References: <4A49CE8B.7080402@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?us-ascii?B?PT9VVEYtOD9CP1VHRjNaY1dDSUZOMFlYTjZaWGR6YTJrPT89?=
	<pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:42540 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758773AbZGHWfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:35:16 -0400
Received: by bwz25 with SMTP id 25so3155443bwz.37
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2009 15:35:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A49CE8B.7080402@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawel Staszewski wrote, On 06/30/2009 10:36 AM:
...
>>>>> rt_worker_func() taking 13% of cpu0 is an alarm for me :)
>>>>> And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...

Pawel, here is a patch which changes this function (or what it calls)
back to 2.6.28 version; I'm not sure it's OK, so try it very
cautiously...

Cheers,
Jarek P.
--- (for debugging only; apply to 2.6.29.5 or .6)

diff -Nurp a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2009-07-08 23:42:15.000000000 +0200
+++ b/net/ipv4/route.c	2009-07-08 22:47:52.000000000 +0200
@@ -769,24 +769,11 @@ static void rt_do_flush(int process_cont
 	}
 }
 
-/*
- * While freeing expired entries, we compute average chain length
- * and standard deviation, using fixed-point arithmetic.
- * This to have an estimation of rt_chain_length_max
- *  rt_chain_length_max = max(elasticity, AVG + 4*SD)
- * We use 3 bits for frational part, and 29 (or 61) for magnitude.
- */
-
-#define FRACT_BITS 3
-#define ONE (1UL << FRACT_BITS)
-
 static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
-	struct rtable *rth, *aux, **rthp;
-	unsigned long samples = 0;
-	unsigned long sum = 0, sum2 = 0;
+	struct rtable *rth, **rthp;
 	u64 mult;
 
 	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
@@ -797,7 +784,6 @@ static void rt_check_expire(void)
 		goal = rt_hash_mask + 1;
 	for (; goal > 0; goal--) {
 		unsigned long tmo = ip_rt_gc_timeout;
-		unsigned long length;
 
 		i = (i + 1) & rt_hash_mask;
 		rthp = &rt_hash_table[i].chain;
@@ -805,14 +791,10 @@ static void rt_check_expire(void)
 		if (need_resched())
 			cond_resched();
 
-		samples++;
-
 		if (*rthp == NULL)
 			continue;
-		length = 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth = *rthp) != NULL) {
-			prefetch(rth->u.dst.rt_next);
 			if (rt_is_expired(rth)) {
 				*rthp = rth->u.dst.rt_next;
 				rt_free(rth);
@@ -821,46 +803,23 @@ static void rt_check_expire(void)
 			if (rth->u.dst.expires) {
 				/* Entry is expired even if it is in use */
 				if (time_before_eq(jiffies, rth->u.dst.expires)) {
-nofree:
 					tmo >>= 1;
 					rthp = &rth->u.dst.rt_next;
-					/*
-					 * We only count entries on
-					 * a chain with equal hash inputs once
-					 * so that entries for different QOS
-					 * levels, and other non-hash input
-					 * attributes don't unfairly skew
-					 * the length computation
-					 */
-					for (aux = rt_hash_table[i].chain;;) {
-						if (aux == rth) {
-							length += ONE;
-							break;
-						}
-						if (compare_hash_inputs(&aux->fl, &rth->fl))
-							break;
-						aux = aux->u.dst.rt_next;
-					}
 					continue;
 				}
-			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
-				goto nofree;
+			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
+				tmo >>= 1;
+				rthp = &rth->u.dst.rt_next;
+				continue;
+			}
 
 			/* Cleanup aged off entries. */
 			*rthp = rth->u.dst.rt_next;
 			rt_free(rth);
 		}
 		spin_unlock_bh(rt_hash_lock_addr(i));
-		sum += length;
-		sum2 += length*length;
-	}
-	if (samples) {
-		unsigned long avg = sum / samples;
-		unsigned long sd = int_sqrt(sum2 / samples - avg*avg);
-		rt_chain_length_max = max_t(unsigned long,
-					ip_rt_gc_elasticity,
-					(avg + 4*sd) >> FRACT_BITS);
 	}
+	rt_chain_length_max = ip_rt_gc_elasticity;
 	rover = i;
 }
 
