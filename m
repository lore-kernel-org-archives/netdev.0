From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: [PATCH] fix missing security_*() check in net/compat.c
Date: Tue, 30 Nov 2004 06:54:44 -0800
Message-ID: <20041130145444.GF63669@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While looking at the SCM passing code in net/core/scm.c I noticed that there's
a 32-bit compat implementation of scm_detach_fds()'s called 
scm_detach_fds_compat() living in net/compat.c.  While these two functions
are mostly the same the latter does not include the call to the
security_file_receive() hook which is almost certainly a bug.

My sparc64 test box isn't set up currently so this is not tested.  Someone
running a 64-bit kernel with CONFIG_COMPAT should verify that this at
least compiles.

Signed-off-by: Mitchell Blank Jr <mitch@sfgoth.com>

-Mitch

--- linux-2.6.10-rc2-bk9-VIRGIN/net/compat.c	2004-10-18 14:54:37.000000000 -0700
+++ linux-2.6.10-rc2-bk9/net/compat.c	2004-11-30 06:40:52.156434868 -0800
@@ -22,6 +22,7 @@
 #include <linux/filter.h>
 #include <linux/compat.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/security.h>
 
 #include <net/scm.h>
 #include <net/sock.h>
@@ -264,6 +265,9 @@
 
 	for (i = 0, cmfptr = (int __user *) CMSG_COMPAT_DATA(cm); i < fdmax; i++, cmfptr++) {
 		int new_fd;
+		err = security_file_receive(fp[i]);
+		if (err)
+			break;
 		err = get_unused_fd();
 		if (err < 0)
 			break;
