From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 2.6] compat_sys_[gs]etsockopt need to check for level
Date: Mon, 24 May 2004 13:33:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524113331.GF23568@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Cc: meissner@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The 32bit emulation functions for setsockopt/getsockopt try
to catch a few special cases by looking at the option name,
without checking for the option level. This breaks IPV6_V6ONLY
and probably a few others.

The bug was found by Marcus Meissner.

I hope I got the level for IPT_SO_SET_REPLACE right (I think it's SOL_IP).
I would appreciate if someone could double-check.

Cheers,
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=setsockopt-compat

--- linux-2.6.5/net/compat.c.orig	2004-04-04 05:37:24.000000000 +0200
+++ linux-2.6.5/net/compat.c	2004-05-24 13:32:27.000000000 +0200
@@ -457,13 +457,14 @@
 asmlinkage long compat_sys_setsockopt(int fd, int level, int optname,
 				char *optval, int optlen)
 {
-	if (optname == IPT_SO_SET_REPLACE)
+	if (level == SOL_IP && optname == IPT_SO_SET_REPLACE)
 		return do_netfilter_replace(fd, level, optname,
 					    optval, optlen);
-	if (optname == SO_ATTACH_FILTER)
+	if (level == SOL_SOCKET && optname == SO_ATTACH_FILTER)
 		return do_set_attach_filter(fd, level, optname,
 					    optval, optlen);
-	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
+	if (level == SOL_SOCKET && 
+	    (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO))
 		return do_set_sock_timeout(fd, level, optname, optval, optlen);
 
 	return sys_setsockopt(fd, level, optname, optval, optlen);
@@ -500,7 +501,8 @@
 asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 				char *optval, int *optlen)
 {
-	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
+	if (level == SOL_SOCKET &&
+	    (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO))
 		return do_get_sock_timeout(fd, level, optname, optval, optlen);
 	return sys_getsockopt(fd, level, optname, optval, optlen);
 }

--BOKacYhQ+x31HxR3--
