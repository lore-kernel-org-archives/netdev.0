From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: sunrpc: what prevents an xprt from being freed before task_cleanup
 runs?
Date: Tue, 3 Aug 2010 13:24:53 -0400
Message-ID: <20100803132453.4fa18444@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org
To: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We got a report recently about a panic in RHEL5 (2.6.18 based kernel).
The problem appears to be that a task_cleanup workqueue job ran and got
passed a pointer to an xprt that had been freed. The bug is here in
case anyone is interested in the details:

    https://bugzilla.redhat.com/show_bug.cgi?id=611938

The situation seems to be pretty difficult to reproduce, but I don't
see anything that's intended to ensure that this doesn't occur in RHEL5
or mainline. The task_cleanup workqueue job doesn't hold a reference to
the xprt, and the job isn't canceled when the xprt is torn down.

Bruce had a look and suggested that we may need something like the
patch below (pasted in, so it probably won't apply correctly). I've
tested a backported version of it on RHEL5 and it seems to work fine.

Is it reasonable to cancel task_cleanup when destroying the xprt? Or,
am I missing something that should prevent this situation in mainline
(and perhaps isn't in RHEL5's kernel).

Any help is appreciated...

-----------------------------[snip]---------------------------------
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index dcd0132..2a1f664 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1129,6 +1129,7 @@ static void xprt_destroy(struct kref *kref)
  rpc_destroy_wait_queue(&xprt->sending);
  rpc_destroy_wait_queue(&xprt->resend);
  rpc_destroy_wait_queue(&xprt->backlog);
+ cancel_work_sync(&xprt->task_cleanup);
  /*
   * Tear down transport state and free the rpc_xprt
   */
-----------------------------[snip]---------------------------------

Thanks,
-- 
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
