From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Compat32 setsockopt overzealous conversions
Date: Thu, 09 Sep 2004 08:53:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094716398.15909.27.camel@localhost.localdomain>
References: <1094563381.5122.8.camel@localhost.localdomain>
	 <20040907140649.42eaa278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040907140649.42eaa278.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-07 at 14:06 -0700, David S. Miller wrote:
> I know it's a pain in the ass, but could you cook up
> a 2.4.x version?  Thanks.

Untested -- I feel dirty enough just for _looking_ at such ancient code,
let alone compiling it for all the various platforms which each used to
have their own version of the 32/64 compatibility stuff in those days.

I note mips64 and x86_64 have a 'do_set_icmpv6_filter' which the 2.6
compat_sys_setsockopt() lacks.

Back in the real world of 2.6, we REALLY do need to stop trying to do
all this in a sockopt syscall wrapper, and instead pass down a 32/64 bit
flag to the code which actually handles the sockopt -- although the
optlen ought to be sufficient for the _majority_ of cases. Or maybe we
should handle it like we do ioctls? 

===== arch/mips64/kernel/linux32.c 1.12 vs edited =====
--- 1.12/arch/mips64/kernel/linux32.c	2003-10-31 15:58:30 +00:00
+++ edited/arch/mips64/kernel/linux32.c	2004-09-09 08:51:03 +01:00
@@ -1568,7 +1568,7 @@
 asmlinkage int sys32_setsockopt(int fd, int level, int optname,
 				char *optval, int optlen)
 {
-	if (optname == SO_ATTACH_FILTER)
+	if (level == SOL_SOCKET && optname == SO_ATTACH_FILTER)
 		return do_set_attach_filter(fd, level, optname,
 					    optval, optlen);
 	if (level == SOL_ICMPV6 && optname == ICMPV6_FILTER)
===== arch/ppc64/kernel/sys_ppc32.c 1.8 vs edited =====
--- 1.8/arch/ppc64/kernel/sys_ppc32.c	2003-12-15 05:55:19 +00:00
+++ edited/arch/ppc64/kernel/sys_ppc32.c	2004-09-09 08:46:05 +01:00
@@ -3221,7 +3221,7 @@
 	
 	PPCDBG(PPCDBG_SYS32,"sys32_setsockopt - running - pid=%ld, comm=%s\n", current->pid, current->comm);
 
-	if (optname == SO_ATTACH_FILTER) {
+	if (level == SOL_SOCKET && optname == SO_ATTACH_FILTER) {
 		struct sock_fprog32 {
 			__u16 len;
 			__u32 filter;
===== arch/sparc64/kernel/sys_sparc32.c 1.33 vs edited =====
--- 1.33/arch/sparc64/kernel/sys_sparc32.c	2004-03-27 05:08:52 +00:00
+++ edited/arch/sparc64/kernel/sys_sparc32.c	2004-09-09 08:47:26 +01:00
@@ -2996,10 +2996,11 @@
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
===== arch/x86_64/ia32/socket32.c 1.4 vs edited =====
--- 1.4/arch/x86_64/ia32/socket32.c	2003-06-24 21:44:22 +01:00
+++ edited/arch/x86_64/ia32/socket32.c	2004-09-09 08:52:23 +01:00
@@ -555,7 +555,7 @@
 asmlinkage long sys32_setsockopt(int fd, int level, int optname,
 				char *optval, int optlen)
 {
-	if (optname == SO_ATTACH_FILTER)
+	if (level == SOL_SOCKET && optname == SO_ATTACH_FILTER)
 		return do_set_attach_filter(fd, level, optname,
 					    optval, optlen);
 	if (level == SOL_ICMPV6 && optname == ICMPV6_FILTER)



-- 
dwmw2
