From: Ingo Molnar <mingo@elte.hu>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 22:35:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512203500.GA17999@elte.hu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <200405121947.i4CJlJm5029666@turing-police.cc.vt.edu> <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com> <200405122007.i4CK7GPQ020444@turing-police.cc.vt.edu> <20040512202807.GA16849@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ikeVEW9yuYc//A+q"
Cc: Davide Libenzi <davidel@xmailserver.org>, Jeff Garzik <jgarzik@pobox.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
Content-Disposition: inline
In-Reply-To: <20040512202807.GA16849@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


* Ingo Molnar <mingo@elte.hu> wrote:

> the attached patch (against BK-curr) cleans this up and makes the
> defines generic and arch-independent.

new patch attached - this adopts the overflow-safe variant from sctp.h,
removes it from sctp.h and moves it into a generic include file and also
does the HZ=1000 simplification.

	Ingo

--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hz-cleanup-2.6.6-A1"

--- linux/include/linux/time.h.orig	
+++ linux/include/linux/time.h	
@@ -177,6 +177,17 @@ struct timezone {
 	(SH_DIV((MAX_JIFFY_OFFSET >> SEC_JIFFIE_SC) * TICK_NSEC, NSEC_PER_SEC, 1) - 1)
 
 #endif
+
+#if HZ == 1000
+# define JIFFIES_TO_MSEC(x)	(x)
+# define MSEC_TO_JIFFIES(x)	(x)
+#else
+#define MSECS_TO_JIFFIES(msec) \
+        (((msec / 1000) * HZ) + ((msec % 1000) * HZ) / 1000)
+#define JIFFIES_TO_MSECS(jiff) \
+        (((jiff / HZ) * 1000) + ((jiff % HZ) * 1000) / HZ)
+#endif
+
 /*
  * The TICK_NSEC - 1 rounds up the value to the next resolution.  Note
  * that a remainder subtract here would not do the right thing as the
--- linux/include/net/sctp/sctp.h.orig	
+++ linux/include/net/sctp/sctp.h	
@@ -116,11 +116,6 @@
 #define SCTP_STATIC static
 #endif
 
-#define MSECS_TO_JIFFIES(msec) \
-	(((msec / 1000) * HZ) + ((msec % 1000) * HZ) / 1000)
-#define JIFFIES_TO_MSECS(jiff) \
-	(((jiff / HZ) * 1000) + ((jiff % HZ) * 1000) / HZ)
-
 /*
  * Function declarations.
  */
--- linux/include/asm-i386/param.h.orig	
+++ linux/include/asm-i386/param.h	
@@ -5,8 +5,6 @@
 # define HZ		1000		/* Internal kernel timer frequency */
 # define USER_HZ	100		/* .. some user interfaces are in "ticks" */
 # define CLOCKS_PER_SEC		(USER_HZ)	/* like times() */
-# define JIFFIES_TO_MSEC(x)	(x)
-# define MSEC_TO_JIFFIES(x)	(x)
 #endif
 
 #ifndef HZ
--- linux/kernel/sched.c.orig	
+++ linux/kernel/sched.c	
@@ -75,13 +75,6 @@
 #define NS_TO_JIFFIES(TIME)	((TIME) / (1000000000 / HZ))
 #define JIFFIES_TO_NS(TIME)	((TIME) * (1000000000 / HZ))
 
-#ifndef JIFFIES_TO_MSEC
-# define JIFFIES_TO_MSEC(x) ((x) * 1000 / HZ)
-#endif
-#ifndef MSEC_TO_JIFFIES
-# define MSEC_TO_JIFFIES(x) ((x) * HZ / 1000)
-#endif
-
 /*
  * These are the 'tuning knobs' of the scheduler:
  *

--ikeVEW9yuYc//A+q--
