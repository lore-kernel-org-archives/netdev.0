From: pravin b shelar <pravins@calsoftinc.com>
Subject: Re: [PATCH] : bug fix in multipath drr code.
Date: Tue, 24 May 2005 15:27:16 +0530
Message-ID: <4292FA7C.80308@calsoftinc.com>
References: <4291CBFF.6080106@calsoftinc.com> <20050523232224.GA25349@gondor.apana.org.au> <4292CDCE.2090600@calsoftinc.com> <20050524071146.GA30995@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090501030509050709090905"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050524071146.GA30995@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090501030509050709090905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:

>On Tue, May 24, 2005 at 12:16:38PM +0530, pravin b shelar wrote:
>  
>
>In fact this whole MULTIPATHOLDROUTE thing can't possibly
>work at all.  I'd suggest that it be removed.
>  
>
So I think we should ignore MULTIPATHOLDROUTE flag
in drr and rr multipath algorithms as done in random multipath algorithm.

Attached patch does same thing.

Regards,
Pravin.

--------------090501030509050709090905
Content-Type: text/x-patch;
 name="multipath-drr_rr-last_use-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="multipath-drr_rr-last_use-fix.patch"

Signed-off by: Pravin B. Shelar <pravins@calsoftinc.com>

Index: linux-2.6.12-rc4/include/net/route.h
===================================================================
--- linux-2.6.12-rc4.orig/include/net/route.h	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/include/net/route.h	2005-05-24 02:37:10.000000000 -0700
@@ -181,9 +181,6 @@
 		memcpy(&fl, &(*rp)->fl, sizeof(fl));
 		fl.fl_ip_sport = sport;
 		fl.fl_ip_dport = dport;
-#if defined(CONFIG_IP_ROUTE_MULTIPATH_CACHED)
-		fl.flags |= FLOWI_FLAG_MULTIPATHOLDROUTE;
-#endif
 		ip_rt_put(*rp);
 		*rp = NULL;
 		return ip_route_output_flow(rp, &fl, sk, 0);
Index: linux-2.6.12-rc4/net/ipv4/multipath_drr.c
===================================================================
--- linux-2.6.12-rc4.orig/net/ipv4/multipath_drr.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/net/ipv4/multipath_drr.c	2005-05-24 02:37:10.000000000 -0700
@@ -57,7 +57,6 @@
 
 static struct multipath_device state[MULTIPATH_MAX_DEVICECANDIDATES];
 static DEFINE_SPINLOCK(state_lock);
-static struct rtable *last_selection = NULL;
 
 static int inline __multipath_findslot(void)
 {
@@ -111,11 +110,6 @@
 	.notifier_call	= drr_dev_event,
 };
 
-static void drr_remove(struct rtable *rt)
-{
-	if (last_selection == rt)
-		last_selection = NULL;
-}
 
 static void drr_safe_inc(atomic_t *usecount)
 {
@@ -144,14 +138,6 @@
 	int devidx = -1;
 	int cur_min_devidx = -1;
 
-       	/* if necessary and possible utilize the old alternative */
-	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 &&
-	    last_selection != NULL) {
-		result = last_selection;
-		*rp = result;
-		return;
-	}
-
 	/* 1. make sure all alt. nexthops have the same GC related data */
 	/* 2. determine the new candidate to be returned */
 	result = NULL;
@@ -229,12 +215,10 @@
 	}
 
 	*rp = result;
-	last_selection = result;
 }
 
 static struct ip_mp_alg_ops drr_ops = {
 	.mp_alg_select_route	=	drr_select_route,
-	.mp_alg_remove		=	drr_remove,
 };
 
 static int __init drr_init(void)
@@ -244,7 +228,7 @@
 	if (err)
 		return err;
 
-	err = multipath_alg_register(&drr_ops, IP_MP_ALG_RR);
+	err = multipath_alg_register(&drr_ops, IP_MP_ALG_DRR);
 	if (err)
 		goto fail;
 
Index: linux-2.6.12-rc4/net/ipv4/multipath_rr.c
===================================================================
--- linux-2.6.12-rc4.orig/net/ipv4/multipath_rr.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/net/ipv4/multipath_rr.c	2005-05-24 02:37:10.000000000 -0700
@@ -47,29 +47,12 @@
 #include <net/checksum.h>
 #include <net/ip_mp_alg.h>
 
-#define MULTIPATH_MAX_CANDIDATES 40
-
-static struct rtable* last_used = NULL;
-
-static void rr_remove(struct rtable *rt)
-{
-	if (last_used == rt)
-		last_used = NULL;
-}
-
 static void rr_select_route(const struct flowi *flp,
 			    struct rtable *first, struct rtable **rp)
 {
 	struct rtable *nh, *result, *min_use_cand = NULL;
 	int min_use = -1;
 
-	/* if necessary and possible utilize the old alternative */
-	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 &&
-	    last_used != NULL) {
-		result = last_used;
-		goto out;
-	}
-
 	/* 1. make sure all alt. nexthops have the same GC related data
 	 * 2. determine the new candidate to be returned
 	 */
@@ -90,15 +73,12 @@
 	if (!result)
 		result = first;
 
-out:
-	last_used = result;
 	result->u.dst.__use++;
 	*rp = result;
 }
 
 static struct ip_mp_alg_ops rr_ops = {
 	.mp_alg_select_route	=	rr_select_route,
-	.mp_alg_remove		=	rr_remove,
 };
 
 static int __init rr_init(void)

--------------090501030509050709090905--
