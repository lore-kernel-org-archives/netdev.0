From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH 1/2] uapi: add a compatibility layer between linux/time.h and glibc
Date: Wed, 22 Feb 2017 05:29:22 +0300
Message-ID: <20170222022922.GB32359@altlinux.org>
References: <20170220115841.GA6846@altlinux.org> <20170221.121022.676021611021776681.davem@davemloft.net> <20170221201914.GA28360@altlinux.org> <20170222022259.GA32359@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Carlos O'Donell <carlos@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170222022259.GA32359@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not define struct itimerspec, struct timespec, struct timeval,
and TIMER_ABSTIME in linux/time.h when <time.h> is already included
and provides these definitions.

This fixes the following compilation errors and warnings when <time.h>
is included before <linux/time.h>:

/usr/include/linux/time.h:9:8: error: redefinition of 'struct timespec'
/usr/include/linux/time.h:15:8: error: redefinition of 'struct timeval'
/usr/include/linux/time.h:34:8: error: redefinition of 'struct itimerspec'
/usr/include/linux/time.h:67:0: warning: "TIMER_ABSTIME" redefined

Do not define struct itimerval, struct timespec, struct timeval, struct
timezone, ITIMER_REAL, ITIMER_VIRTUAL, and ITIMER_PROF in linux/time.h
when <sys/time.h> is already included and provides these definitions.

This fixes the following compilation errors and warnings when <sys/time.h>
is included before <linux/time.h>:

/usr/include/linux/time.h:9:8: error: redefinition of 'struct timespec'
/usr/include/linux/time.h:15:8: error: redefinition of 'struct timeval'
/usr/include/linux/time.h:20:8: error: redefinition of 'struct timezone'
/usr/include/linux/time.h:30:0: warning: "ITIMER_REAL" redefined
/usr/include/linux/time.h:31:0: warning: "ITIMER_VIRTUAL" redefined
/usr/include/linux/time.h:32:0: warning: "ITIMER_PROF" redefined
/usr/include/linux/time.h:39:8: error: redefinition of 'struct itimerval'

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/libc-compat.h | 56 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/time.h        | 31 ++++++++++++++++++++--
 2 files changed, 85 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 44b8a6b..481e3b1 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -158,6 +158,53 @@
 
 #endif /* defined(__NETIPX_IPX_H) */
 
+/* Coordinate with glibc time.h header. */
+#if (defined(__itimerspec_defined) && __itimerspec_defined) || \
+    (defined(_TIME_H) && defined(__USE_POSIX199309))
+/* __itimerspec_defined was introduced in glibc-2.25 */
+#define __UAPI_DEF_ITIMERSPEC		0
+#else
+#define __UAPI_DEF_ITIMERSPEC		1
+#endif
+
+#if (defined(__timespec_defined) && __timespec_defined) || \
+    (defined(_STRUCT_TIMESPEC) && _STRUCT_TIMESPEC)
+/* __timespec_defined was introduced in glibc-2.3.2 */
+#define __UAPI_DEF_TIMESPEC		0
+#else
+#define __UAPI_DEF_TIMESPEC		1
+#endif
+
+#if (defined(__timeval_defined) && __timeval_defined) || \
+    (defined(_STRUCT_TIMEVAL) && _STRUCT_TIMEVAL)
+/* __timeval_defined was introduced in glibc-2.25 */
+#define __UAPI_DEF_TIMEVAL		0
+#else
+#define __UAPI_DEF_TIMEVAL		1
+#endif
+
+/* Coordinate with glibc bits/time.h header. */
+#if defined(_BITS_TIME_H) && defined(__USE_POSIX199309)
+#define __UAPI_DEF_TIMER_ABSTIME	0
+#else
+#define __UAPI_DEF_TIMER_ABSTIME	1
+#endif
+
+/* Coordinate with glibc sys/time.h header. */
+#if defined(_SYS_TIME_H)
+#define __UAPI_DEF_ITIMERVAL			0
+#define __UAPI_DEF_ITIMER_REAL_VIRTUAL_PROF	0
+#else
+#define __UAPI_DEF_ITIMERVAL			1
+#define __UAPI_DEF_ITIMER_REAL_VIRTUAL_PROF	1
+#endif
+
+#if defined(_SYS_TIME_H) && defined(__USE_MISC)
+#define __UAPI_DEF_TIMEZONE		0
+#else
+#define __UAPI_DEF_TIMEZONE		1
+#endif
+
 /* Definitions for xattr.h */
 #if defined(_SYS_XATTR_H)
 #define __UAPI_DEF_XATTR		0
@@ -205,6 +252,15 @@
 #define __UAPI_DEF_IPX_CONFIG_DATA		1
 #define __UAPI_DEF_IPX_ROUTE_DEF		1
 
+/* Definitions for time.h */
+#define __UAPI_DEF_ITIMERSPEC			1
+#define __UAPI_DEF_ITIMERVAL			1
+#define __UAPI_DEF_ITIMER_REAL_VIRTUAL_PROF	1
+#define __UAPI_DEF_TIMER_ABSTIME		1
+#define __UAPI_DEF_TIMESPEC			1
+#define __UAPI_DEF_TIMEVAL			1
+#define __UAPI_DEF_TIMEZONE			1
+
 /* Definitions for xattr.h */
 #define __UAPI_DEF_XATTR		1
 
diff --git a/include/uapi/linux/time.h b/include/uapi/linux/time.h
index e75e1b6..9d03ca4 100644
--- a/include/uapi/linux/time.h
+++ b/include/uapi/linux/time.h
@@ -1,45 +1,70 @@
 #ifndef _UAPI_LINUX_TIME_H
 #define _UAPI_LINUX_TIME_H
 
+#include <linux/libc-compat.h>
 #include <linux/types.h>
 
 
+#if __UAPI_DEF_TIMESPEC
+#ifndef __timespec_defined
+#define __timespec_defined	1
+#endif
 #ifndef _STRUCT_TIMESPEC
-#define _STRUCT_TIMESPEC
+#define _STRUCT_TIMESPEC	1
+#endif
 struct timespec {
 	__kernel_time_t	tv_sec;			/* seconds */
 	long		tv_nsec;		/* nanoseconds */
 };
-#endif
+#endif /* __UAPI_DEF_TIMESPEC */
 
+#if __UAPI_DEF_TIMEVAL
+#ifndef __timeval_defined
+#define __timeval_defined	1
+#endif
+#ifndef _STRUCT_TIMEVAL
+#define _STRUCT_TIMEVAL		1
+#endif
 struct timeval {
 	__kernel_time_t		tv_sec;		/* seconds */
 	__kernel_suseconds_t	tv_usec;	/* microseconds */
 };
+#endif /* __UAPI_DEF_TIMEVAL */
 
+#if __UAPI_DEF_TIMEZONE
 struct timezone {
 	int	tz_minuteswest;	/* minutes west of Greenwich */
 	int	tz_dsttime;	/* type of dst correction */
 };
+#endif /* __UAPI_DEF_TIMEZONE */
 
 
 /*
  * Names of the interval timers, and structure
  * defining a timer setting:
  */
+#if __UAPI_DEF_ITIMER_REAL_VIRTUAL_PROF
 #define	ITIMER_REAL		0
 #define	ITIMER_VIRTUAL		1
 #define	ITIMER_PROF		2
+#endif /* __UAPI_DEF_ITIMER_REAL_VIRTUAL_PROF */
 
+#if __UAPI_DEF_ITIMERSPEC
+#ifndef __itimerspec_defined
+#define __itimerspec_defined	1
+#endif
 struct itimerspec {
 	struct timespec it_interval;	/* timer period */
 	struct timespec it_value;	/* timer expiration */
 };
+#endif /* __UAPI_DEF_ITIMERSPEC */
 
+#if __UAPI_DEF_ITIMERVAL
 struct itimerval {
 	struct timeval it_interval;	/* timer interval */
 	struct timeval it_value;	/* current value */
 };
+#endif /* __UAPI_DEF_ITIMERVAL */
 
 /*
  * The IDs of the various system clocks (for POSIX.1b interval timers):
@@ -64,6 +89,8 @@ struct itimerval {
 /*
  * The various flags for setting POSIX.1b interval timers:
  */
+#if __UAPI_DEF_TIMER_ABSTIME
 #define TIMER_ABSTIME			0x01
+#endif
 
 #endif /* _UAPI_LINUX_TIME_H */
-- 
ldv
