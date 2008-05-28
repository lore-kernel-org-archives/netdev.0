From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] sysctl: permission check based on capability not euid
Date: Wed, 28 May 2008 12:12:00 -0700
Message-ID: <20080528121200.54c04b5a@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Chris Wright <chrisw@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56554 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbYE1TMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 15:12:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies the permission checks for sysctl's from being based on uid=0 (root)
to use the capability system. This matches the behavior of other OS's using sysctl's
and capabilities. Linux has tried to get away from using uid=0 for security overrides
and use capabilities instead. 

I was working on Quagga enhancement that involved enabling a sysctl, and it didn't
work because is a safe daemon and drops privileges and resets its real/effective uid
after initialization; it then re-enables only the capabilities when it needs to
do some privileged operation. This wouldn't work because sysctl's were still using
the root based permission check. The existing code in quagga to enable ip forwarding
doesn't work for the same reason.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Maybe once the BKL is gone, the last vestiges of current->euid == 0 can be wiped out
as well.

--- a/include/linux/capability.h	2008-05-27 17:33:02.000000000 -0700
+++ b/include/linux/capability.h	2008-05-27 17:33:27.000000000 -0700
@@ -261,6 +261,7 @@ typedef struct kernel_cap_struct {
    arbitrary SCSI commands */
 /* Allow setting encryption key on loopback filesystem */
 /* Allow setting zone reclaim policy */
+/* Allow setting any sysctl value */
 
 #define CAP_SYS_ADMIN        21
 
--- a/kernel/sysctl.c	2008-05-27 17:32:33.000000000 -0700
+++ b/kernel/sysctl.c	2008-05-27 17:32:46.000000000 -0700
@@ -1561,7 +1561,7 @@ out:
 
 static int test_perm(int mode, int op)
 {
-	if (!current->euid)
+	if (capable(CAP_SYS_ADMIN))
 		mode >>= 6;
 	else if (in_egroup_p(0))
 		mode >>= 3;
