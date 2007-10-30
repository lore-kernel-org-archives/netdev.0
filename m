From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 1/1][NETNS] resend:  fix net released by rcu callback
Date: Tue, 30 Oct 2007 17:21:40 +0100
Message-ID: <20071030162305.458123510@mai.toulouse-stg.fr.ibm.com>
References: <20071030162139.954791193@mai.toulouse-stg.fr.ibm.com>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=fix-release-net-by-rcu.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

When a network namespace reference is held by a network subsystem,
and when this reference is decremented in a rcu update callback, we
must ensure that there is no more outstanding rcu update before 
trying to free the network namespace.

In the normal case, the rcu_barrier is called when the network namespace
is exiting in the cleanup_net function.

But when a network namespace creation fails, and the subsystems are
undone (like the cleanup), the rcu_barrier is missing.

This patch adds the missing rcu_barrier.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 net/core/net_namespace.c |    2 ++
 1 file changed, 2 insertions(+)

Index: net-2.6/net/core/net_namespace.c
===================================================================
--- net-2.6.orig/net/core/net_namespace.c
+++ net-2.6/net/core/net_namespace.c
@@ -112,6 +112,8 @@ out_undo:
 		if (ops->exit)
 			ops->exit(net);
 	}
+
+	rcu_barrier();
 	goto out;
 }
 

-- 
