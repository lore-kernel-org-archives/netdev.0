From: Eugene Surovegin <ebs@ebshome.net>
Subject: [IPSEC] fix ref counting in __xfrm4_bundle_create()
Date: Fri, 28 May 2004 17:14:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529001450.GA647@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all!

I think there is a ref counting bug in error path of __xfrm4_bundle_create().

xfrm_lookup() assumes that xfrm_bundle_create() will take ownership of 
xfrm_state array passed to it. If xfrm_bundle_create() fails, xfrm_lookup() will 
call xfrm_state_put() to release this array. 

Unfortunately, error path in __xfrm4_bundle_create() also calls xfrm_state_put() 
(indirectly through dst_free() -> ... -> xfrm_dst_destroy()) and we end up 
calling xfrm_state_put() _twice_.

This causes "infamous" :) "x->km.state == XFRM_STATE_DEAD" assertion in some our 
tests when interface is removed when IPSec traffic is going through it.

IPv6 version (__xfrm6_bundle_create()) seems to have the same problem. I'll send 
IPv6 version if my analysis and fix are correct :).

Here is IPv4 version (patch is against current linux-2.5 BK).

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>

===== net/ipv4/xfrm4_policy.c 1.8 vs edited =====
--- 1.8/net/ipv4/xfrm4_policy.c	Fri Mar 19 19:35:32 2004
+++ edited/net/ipv4/xfrm4_policy.c	Fri May 28 16:22:35 2004
@@ -87,6 +87,7 @@
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
+			nx = i;
 			goto error;
 		}
 
@@ -157,8 +158,14 @@
 	return 0;
 
 error:
-	if (dst)
+	if (dst){
+		/* bump refcount because dst_free will decrement it
+		   and our caller (xfrm_lookup) will do the same on error.
+		*/
+		for (i = 0; i < nx; i++)
+			xfrm_state_hold(xfrm[i]);
 		dst_free(dst);
+	}	
 	return err;
 }
 
