From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Compat32 setsockopt overzealous conversions
Date: Tue, 07 Sep 2004 14:23:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094563381.5122.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

compat_sys_setsockopt() is a little overzealous about converting 32-bit
stuff into 64-bit. It should match on level _and_ optname, not just
optname. Currently it eats the IPV6_V6ONLY sockopt because its value
(26) happens to match SO_ATTACH_FILTER.

This makes it at least check 'level' for everything but
IPT_SO_SET_REPLACE == IPT6_SO_SET_REPLACE, because that does seem to be
the same in different levels. But do_netfilter_replace() is another can
of worms entirely -- it doesn't actually work either, because some
netfilter modules (like ipt_limit) include kernel-only bits which change
size in the structure they share with userspace. 

--- net/compat.c~	2004-08-14 06:37:15.000000000 +0100
+++ net/compat.c	2004-09-03 17:47:26.260926176 +0100
@@ -455,13 +455,15 @@
 asmlinkage long compat_sys_setsockopt(int fd, int level, int optname,
 				char __user *optval, int optlen)
 {
+	/* SO_SET_REPLACE seems to be the same in all levels */
 	if (optname == IPT_SO_SET_REPLACE)
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



-- 
dwmw2
