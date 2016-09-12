From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/2] uapi glibc compat: make linux/time.h compile with user time.h files
Date: Mon, 12 Sep 2016 13:05:29 -0400
Message-ID: <1473699930-58865-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1473699930-58865-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        john.stultz@linaro.rg, bmoses@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473699930-58865-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

Add libc-compat workaround for definitions in linux/time.h that
duplicate those in libc time.h, sys/time.h and bits/time.h.

With this change, userspace builds succeeds when linux/time.h is
included after libc time.h and when it is included after sys/time.h.

The inverse requires additional changes to those userspace headers.

Without this patch, when compiling the following program after
make headers_install:

  echo -e "#include <time.h>\n#include <linux/time.h>" | \
  	gcc -Wall -Werror -Iusr/include -c -xc -

gcc gives these errors:

  #include <time.h>
  #include <linux/time.h>

    In file included from ../test_time.c:3:0:
    /usr/include/time.h:120:8: error: redefinition of ‘struct timespec’
     struct timespec
    	^
    In file included from ../test_time.c:2:0:
    ./usr/include/linux/time.h:9:8: note: originally defined here
     struct timespec {
    	^
    In file included from ../test_time.c:3:0:
    /usr/include/time.h:161:8: error: redefinition of ‘struct itimerspec’
     struct itimerspec
    	^
    In file included from ../test_time.c:2:0:
    ./usr/include/linux/time.h:34:8: note: originally defined here
     struct itimerspec {

and this warning by indirect inclusion of bits/time.h:

    In file included from ../test_time.c:4:0:
    ./usr/include/linux/time.h:67:0: error: "TIMER_ABSTIME" redefined [-Werror]
     #define TIMER_ABSTIME   0x01
     ^
    In file included from /usr/include/time.h:41:0,
    		 from ../test_time.c:3:
    /usr/include/x86_64-linux-gnu/bits/time.h:82:0: note: this is the location of the previous definition
     #   define TIMER_ABSTIME  1
     ^

The _SYS_TIME_H variant resolves similar errors for timeval, timezone,
itimerval and warnings for ITIMER_REAL, ITIMER_VIRTUAL, ITIMER_PROF.

Ran the same program for sys/time.h and bits/time.h.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/libc-compat.h | 50 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/time.h        | 15 ++++++++++++
 2 files changed, 65 insertions(+)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 44b8a6b..b08b0f5 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -165,6 +165,43 @@
 #define __UAPI_DEF_XATTR		1
 #endif
 
+/* Definitions for time.h */
+#if defined(__timespec_defined)
+#define __UAPI_DEF_TIMESPEC		0
+#else
+#define __UAPI_DEF_TIMESPEC		1
+#endif
+
+#if defined(_TIME_H) && defined(__USE_POSIX199309)
+#define __UAPI_DEF_ITIMERSPEC		0
+#else
+#define __UAPI_DEF_ITIMERSPEC		1
+#endif
+
+/* Definitions for sys/time.h */
+#if defined(_SYS_TIME_H)
+#define __UAPI_DEF_TIMEVAL		0
+#define __UAPI_DEF_ITIMERVAL		0
+#define __UAPI_DEF_ITIMER_WHICH		0
+#else
+#define __UAPI_DEF_TIMEVAL		1
+#define __UAPI_DEF_ITIMERVAL		1
+#define __UAPI_DEF_ITIMER_WHICH		1
+#endif
+
+/* Definitions for bits/time.h */
+#if defined(_BITS_TIME_H)
+#define __UAPI_DEF_ABSTIME		0
+#else
+#define __UAPI_DEF_ABSTIME		1
+#endif
+
+#if defined(_SYS_TIME_H) && defined(__USE_BSD)
+#define __UAPI_DEF_TIMEZONE		0
+#else
+#define __UAPI_DEF_TIMEZONE		1
+#endif
+
 /* If we did not see any headers from any supported C libraries,
  * or we are being included in the kernel, then define everything
  * that we need. */
@@ -208,6 +245,19 @@
 /* Definitions for xattr.h */
 #define __UAPI_DEF_XATTR		1
 
+/* Definitions for time.h */
+#define __UAPI_DEF_TIMESPEC		1
+#define __UAPI_DEF_ITIMERSPEC		1
+
+/* Definitions for sys/time.h */
+#define __UAPI_DEF_TIMEVAL		1
+#define __UAPI_DEF_ITIMERVAL		1
+#define __UAPI_DEF_ITIMER_WHICH		1
+#define __UAPI_DEF_TIMEZONE		1
+
+/* Definitions for bits/time.h */
+#define __UAPI_DEF_ABSTIME		1
+
 #endif /* __GLIBC__ */
 
 #endif /* _UAPI_LIBC_COMPAT_H */
diff --git a/include/uapi/linux/time.h b/include/uapi/linux/time.h
index e75e1b6..4e7333c 100644
--- a/include/uapi/linux/time.h
+++ b/include/uapi/linux/time.h
@@ -1,9 +1,11 @@
 #ifndef _UAPI_LINUX_TIME_H
 #define _UAPI_LINUX_TIME_H
 
+#include <linux/libc-compat.h>
 #include <linux/types.h>
 
 
+#if __UAPI_DEF_TIMESPEC
 #ifndef _STRUCT_TIMESPEC
 #define _STRUCT_TIMESPEC
 struct timespec {
@@ -11,35 +13,46 @@ struct timespec {
 	long		tv_nsec;		/* nanoseconds */
 };
 #endif
+#endif
 
+#if __UAPI_DEF_TIMEVAL
 struct timeval {
 	__kernel_time_t		tv_sec;		/* seconds */
 	__kernel_suseconds_t	tv_usec;	/* microseconds */
 };
+#endif
 
+#if __UAPI_DEF_TIMEZONE
 struct timezone {
 	int	tz_minuteswest;	/* minutes west of Greenwich */
 	int	tz_dsttime;	/* type of dst correction */
 };
+#endif
 
 
 /*
  * Names of the interval timers, and structure
  * defining a timer setting:
  */
+#if __UAPI_DEF_ITIMER_WHICH
 #define	ITIMER_REAL		0
 #define	ITIMER_VIRTUAL		1
 #define	ITIMER_PROF		2
+#endif
 
+#if __UAPI_DEF_ITIMERSPEC
 struct itimerspec {
 	struct timespec it_interval;	/* timer period */
 	struct timespec it_value;	/* timer expiration */
 };
+#endif
 
+#if __UAPI_DEF_ITIMERVAL
 struct itimerval {
 	struct timeval it_interval;	/* timer interval */
 	struct timeval it_value;	/* current value */
 };
+#endif
 
 /*
  * The IDs of the various system clocks (for POSIX.1b interval timers):
@@ -64,6 +77,8 @@ struct itimerval {
 /*
  * The various flags for setting POSIX.1b interval timers:
  */
+#if __UAPI_DEF_ABSTIME
 #define TIMER_ABSTIME			0x01
+#endif
 
 #endif /* _UAPI_LINUX_TIME_H */
-- 
2.8.0.rc3.226.g39d4020
