From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 15:18:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512221823.GK1397@holomorphy.com>
References: <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <200405121947.i4CJlJm5029666@turing-police.cc.vt.edu> <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com> <200405122007.i4CK7GPQ020444@turing-police.cc.vt.edu> <20040512202807.GA16849@elte.hu> <20040512203500.GA17999@elte.hu> <20040512205028.GA18806@elte.hu> <20040512140729.476ace9e.akpm@osdl.org> <20040512211748.GB20800@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Valdis.Kletnieks@vt.edu,
        davidel@xmailserver.org, jgarzik@pobox.com, greg@kroah.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20040512211748.GB20800@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 12, 2004 at 11:17:48PM +0200, Ingo Molnar wrote:
> ok. -A3 attached, it does the roundup in the msec->jiffies conversion. 
> (not the other way around though, and that's fine.)

I'm assuming -A3 is current, then:

Optimize the cases where HZ is a divisor of 1000 or vice-versa in
JIFFIES_TO_MSECS() and MSECS_TO_JIFFIES() by allowing the nonvanishing(!)
integral ratios to appear as a parenthesized expressions eligible for
constant folding optimizations.


-- wli


Index: linux-2.5/include/linux/time.h
===================================================================
--- linux-2.5.orig/include/linux/time.h	2004-05-12 15:04:10.000000000 -0700
+++ linux-2.5/include/linux/time.h	2004-05-12 15:12:49.000000000 -0700
@@ -184,12 +184,12 @@
  * Avoid unnecessary multiplications/divisions in the
  * two most common HZ cases:
  */
-#if HZ == 1000
-# define JIFFIES_TO_MSECS(x)	(x)
-# define MSECS_TO_JIFFIES(x)	(x)
-#elif HZ == 100
-# define JIFFIES_TO_MSECS(x)	((x) * 10)
-# define MSECS_TO_JIFFIES(x)	(((x) + 9) / 10)
+#if HZ <= 1000 && !(1000 % HZ)
+# define JIFFIES_TO_MSECS(j)	((1000/HZ)*(j))
+# define MSECS_TO_JIFFIES(m)	(((m) + (1000/HZ) - 1)/(1000/HZ))
+#elif HZ > 1000 && !(HZ % 1000)
+# define JIFFIES_TO_MSECS(j)	(((j) + (HZ/1000) - 1)/(HZ/1000))
+# define MSECS_TO_JIFFIES(m)	((m)*(HZ/1000))
 #else
 # define JIFFIES_TO_MSECS(x)	(((x) * 1000) / HZ)
 # define MSECS_TO_JIFFIES(x)	(((x) * HZ + 999) / 1000)
