From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] select: fix sys_select to not leak ERESTARTNOHAND to userspace
Date: Mon, 22 Jan 2007 08:00:20 -0500
Message-ID: <20070122130020.GA21059@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4075 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796AbXAVNAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 08:00:54 -0500
To: akpm@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As it is currently written, sys_select checks its return code to convert
ERESTARTNOHAND to EINTR.  However, the check is within an if (tvp) clause, and
so if select is called from userspace with a NULL timeval, then it is possible
for the ERESTARTNOHAND errno to leak into userspace, which is incorrect.  This
patch moves that check outside of the conditional, and prevents the errno leak.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 select.c |   18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)


diff --git a/fs/select.c b/fs/select.c
index fe0893a..afcd691 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -415,20 +415,12 @@ asmlinkage long sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 		rtv.tv_sec = timeout;
 		if (timeval_compare(&rtv, &tv) >= 0)
 			rtv = tv;
-		if (copy_to_user(tvp, &rtv, sizeof(rtv))) {
-sticky:
-			/*
-			 * If an application puts its timeval in read-only
-			 * memory, we don't want the Linux-specific update to
-			 * the timeval to cause a fault after the select has
-			 * completed successfully. However, because we're not
-			 * updating the timeval, we can't restart the system
-			 * call.
-			 */
-			if (ret == -ERESTARTNOHAND)
-				ret = -EINTR;
-		}
+		if (copy_to_user(tvp, &rtv, sizeof(rtv)))
+			return -EFAULT;
 	}
+sticky:
+	if (ret == -ERESTARTNOHAND)
+		ret = -EINTR;
 
 	return ret;
 }
