From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] flag parameters: paccept w/out set_restore_sigmask
Date: Tue, 13 May 2008 01:05:50 -0400
Message-ID: <200805130505.m4D55oq0018179@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487AbYEMFFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:05:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some platforms do not have support to restore the signal mask in the
return path from a syscall.  For those platforms syscalls like pselect
are not defined at all.  This is, I think, not a good choice for
paccept() since paccept() adds more value on top of accept() than just
the signal mask handling.

Therefore this patch defines a scaled down version of the sys_paccept
function for those platforms.  It returns -EINVAL in case the signal
mask is non-NULL but behaves the same otherwise.

Note that I explicitly included <linux/thread_info.h>.  I saw that it
is currently included but indirectly two levels down.  There is too
much risk in relying on this.  The header might change and then
suddenly the function definition would change without anyone
immediately noticing.

 socket.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/net/socket.c b/net/socket.c
index 5111af1..e25049f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -68,6 +68,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/mutex.h>
+#include <linux/thread_info.h>
 #include <linux/wanrouter.h>
 #include <linux/if_bridge.h>
 #include <linux/if_frad.h>
@@ -1509,6 +1510,7 @@ out_fd:
 	goto out_put;
 }
 
+#ifdef HAVE_SET_RESTORE_SIGMASK
 asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
 			    int __user *upeer_addrlen,
 			    const sigset_t __user *sigmask,
@@ -1546,6 +1548,21 @@ asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
 
 	return ret;
 }
+#else
+asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
+			    int __user *upeer_addrlen,
+			    const sigset_t __user *sigmask,
+			    size_t sigsetsize, int flags)
+{
+	/* The platform does not support restoring the signal mask in the
+	 * return path.  So we do not allow using paccept() with a signal
+	 * mask.  */
+	if (sigmask)
+		return -EINVAL;
+
+	return do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
+}
+#endif
 
 asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
 			   int __user *upeer_addrlen)
