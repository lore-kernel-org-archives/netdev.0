From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 5/5] schedule() bug in xfrm_lookup()
Date: Tue, 13 Jan 2004 13:26:21 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401131324340.25742-100000@linux-udp14999547uds>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


When xfrm_tmpl_resolve fails, schedule() before retrying. Also, cleaned
up the set_task_* routines to use set_current_*, etc.

This needs to be applied after [PATCH 3/5].

thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_policy.c linux-2.6.0-rc2-bk6/net/xfrm/xfrm_policy.c
--- linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_policy.c	2004-01-09 12:42:53.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/xfrm/xfrm_policy.c	2004-01-12 09:55:26.000000000 -0800
@@ -775,20 +775,17 @@

 		if (unlikely(nx<0)) {
 			err = nx;
-			if (err == -EAGAIN) {
-				struct task_struct *tsk = current;
-				DECLARE_WAITQUEUE(wait, tsk);
-				if (!flags)
-					goto error;
+			if (err == -EAGAIN && !flags) {
+				DECLARE_WAITQUEUE(wait, current);

-				__set_task_state(tsk, TASK_INTERRUPTIBLE);
 				add_wait_queue(&km_waitq, &wait);
-				nx = xfrm_tmpl_resolve(policy, fl, xfrm, family);
-				if (nx == -EAGAIN)
-					schedule();
-				__set_task_state(tsk, TASK_RUNNING);
+				set_current_state(TASK_INTERRUPTIBLE);
+				schedule();
+				set_current_state(TASK_RUNNING);
 				remove_wait_queue(&km_waitq, &wait);

+				nx = xfrm_tmpl_resolve(policy, fl, xfrm, family);
+
 				if (nx == -EAGAIN && signal_pending(current)) {
 					err = -ERESTART;
 					goto error;
