From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 3/5] xfrm_lookup bugs
Date: Tue, 13 Jan 2004 13:23:35 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401131322440.25742-100000@linux-udp14999547uds>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


In xfrm_lookup, a couple of bugs :
	- the found or allocated xfrm_states are not passed correctly to
	  xfrm_bundle_create (and to the subsequent frees in case of create
	  failing) if the first xfrm_tmpl_resolve failed and the second one
	  succeeded.
	- error handling is wrong.

thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_policy.c linux-2.6.0-rc2-bk6/net/xfrm/xfrm_policy.c
--- linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_policy.c	2004-01-09 12:42:53.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/xfrm/xfrm_policy.c	2004-01-12 09:55:26.000000000 -0800
@@ -783,25 +783,27 @@

 				__set_task_state(tsk, TASK_INTERRUPTIBLE);
 				add_wait_queue(&km_waitq, &wait);
-				err = xfrm_tmpl_resolve(policy, fl, xfrm, family);
-				if (err == -EAGAIN)
+				nx = xfrm_tmpl_resolve(policy, fl, xfrm, family);
+				if (nx == -EAGAIN)
 					schedule();
 				__set_task_state(tsk, TASK_RUNNING);
 				remove_wait_queue(&km_waitq, &wait);

-				if (err == -EAGAIN && signal_pending(current)) {
+				if (nx == -EAGAIN && signal_pending(current)) {
 					err = -ERESTART;
 					goto error;
 				}
-				if (err == -EAGAIN ||
+				if (nx == -EAGAIN ||
 				    genid != atomic_read(&flow_cache_genid)) {
 					xfrm_pol_put(policy);
 					goto restart;
 				}
+				err = nx;
 			}
-			if (err)
+			if (err < 0)
 				goto error;
-		} else if (nx == 0) {
+		}
+		if (nx == 0) {
 			/* Flow passes not transformed. */
 			xfrm_pol_put(policy);
 			return 0;
