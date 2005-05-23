From: pravin <pravins@calsoftinc.com>
Subject: [PATCH] : bug fix in multipath drr code.
Date: Mon, 23 May 2005 17:56:39 +0530
Message-ID: <4291CBFF.6080106@calsoftinc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000707030603080303070608"
Cc: "David S. Miller" <davem@davemloft.net>,
        "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000707030603080303070608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

hi
  AFAIU, there is a race condition in multipath_drr code,
these code paths try to access & change last_selection variable
without any synchronization.

Please correct me if I am wrong.

Code Path - 1

__ip_route_output_key(...)
{
   ...
   calls drr_select_route
       if(FLOWI_FLAG_MULTIPATHOLDROUTE set){
           check last_selection.
           return  last_selection //so it can return NULL  pointer
       }
   ....
}

Code Path - 2  

rt_secret_rebuild()
{
.....
rt_run_flush(..);
      ->rt_free(rth);
              -> multipath_remove(rt)
                      ->drr_remove()
                              reset last_selection.
....
}

Attached patch also fixes bug in function drr_init ::
multipath_alg_register(..) is called with wrong algorithm ID.


Regards
Pravin.


--------------000707030603080303070608
Content-Type: text/x-patch;
 name="multipath-last_selection-race-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="multipath-last_selection-race-fix.patch"

Signed-off by: Pravin B. Shelar <pravins@calsoftinc.com>

Index: linux-2.6.12-rc4/net/ipv4/multipath_drr.c
===================================================================
--- linux-2.6.12-rc4.orig/net/ipv4/multipath_drr.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/net/ipv4/multipath_drr.c	2005-05-22 06:41:39.000000000 -0700
@@ -145,11 +145,13 @@
 	int cur_min_devidx = -1;
 
        	/* if necessary and possible utilize the old alternative */
-	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 &&
-	    last_selection != NULL) {
-		result = last_selection;
-		*rp = result;
-		return;
+	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 ) {
+		struct rtable *last_result = last_selection;
+		if(last_result != NULL &&
+		   multipath_comparekeys(&last_result->fl, flp)) {
+			*rp = last_result;
+			return;
+		}
 	}
 
 	/* 1. make sure all alt. nexthops have the same GC related data */
@@ -244,7 +246,7 @@
 	if (err)
 		return err;
 
-	err = multipath_alg_register(&drr_ops, IP_MP_ALG_RR);
+	err = multipath_alg_register(&drr_ops, IP_MP_ALG_DRR);
 	if (err)
 		goto fail;
 
Index: linux-2.6.12-rc4/net/ipv4/multipath_rr.c
===================================================================
--- linux-2.6.12-rc4.orig/net/ipv4/multipath_rr.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/net/ipv4/multipath_rr.c	2005-05-22 06:41:20.000000000 -0700
@@ -64,10 +64,13 @@
 	int min_use = -1;
 
 	/* if necessary and possible utilize the old alternative */
-	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 &&
-	    last_used != NULL) {
-		result = last_used;
-		goto out;
+	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 ) {
+		struct rtable *last_result = last_used;
+		if(last_result != NULL &&
+		   multipath_comparekeys(&last_result->fl, flp)) {
+			result = last_result;
+			goto out;
+		}
 	}
 
 	/* 1. make sure all alt. nexthops have the same GC related data

--------------000707030603080303070608--
