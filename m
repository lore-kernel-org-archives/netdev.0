From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v4 4/6] timer: move sys_alarm from timer.c to itimer.c
Date: Fri, 11 Nov 2016 00:10:08 -0500
Message-ID: <1478841010-28605-5-git-send-email-nicolas.pitre@linaro.org>
References: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the only user of alarm_setitimer to itimer.c where it is defined.
This allows for making alarm_setitimer static, and dropping it from the
build when __ARCH_WANT_SYS_ALARM is not defined.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
---
 include/linux/time.h |  2 --
 kernel/time/itimer.c | 15 ++++++++++++++-
 kernel/time/timer.c  | 13 -------------
 3 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/include/linux/time.h b/include/linux/time.h
index 4cea09d942..23f0f5ce30 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -172,8 +172,6 @@ extern int do_setitimer(int which, struct itimerval *value,
 			struct itimerval *ovalue);
 extern int do_getitimer(int which, struct itimerval *value);
 
-extern unsigned int alarm_setitimer(unsigned int seconds);
-
 extern long do_utimes(int dfd, const char __user *filename, struct timespec *times, int flags);
 
 struct tms;
diff --git a/kernel/time/itimer.c b/kernel/time/itimer.c
index 1d5c7204dd..2b9f45bc95 100644
--- a/kernel/time/itimer.c
+++ b/kernel/time/itimer.c
@@ -238,6 +238,8 @@ int do_setitimer(int which, struct itimerval *value, struct itimerval *ovalue)
 	return 0;
 }
 
+#ifdef __ARCH_WANT_SYS_ALARM
+
 /**
  * alarm_setitimer - set alarm in seconds
  *
@@ -250,7 +252,7 @@ int do_setitimer(int which, struct itimerval *value, struct itimerval *ovalue)
  * On 32 bit machines the seconds value is limited to (INT_MAX/2) to avoid
  * negative timeval settings which would cause immediate expiry.
  */
-unsigned int alarm_setitimer(unsigned int seconds)
+static unsigned int alarm_setitimer(unsigned int seconds)
 {
 	struct itimerval it_new, it_old;
 
@@ -275,6 +277,17 @@ unsigned int alarm_setitimer(unsigned int seconds)
 	return it_old.it_value.tv_sec;
 }
 
+/*
+ * For backwards compatibility?  This can be done in libc so Alpha
+ * and all newer ports shouldn't need it.
+ */
+SYSCALL_DEFINE1(alarm, unsigned int, seconds)
+{
+	return alarm_setitimer(seconds);
+}
+
+#endif
+
 SYSCALL_DEFINE3(setitimer, int, which, struct itimerval __user *, value,
 		struct itimerval __user *, ovalue)
 {
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2d47980a1b..3ed6c67e17 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1662,19 +1662,6 @@ void run_local_timers(void)
 	raise_softirq(TIMER_SOFTIRQ);
 }
 
-#ifdef __ARCH_WANT_SYS_ALARM
-
-/*
- * For backwards compatibility?  This can be done in libc so Alpha
- * and all newer ports shouldn't need it.
- */
-SYSCALL_DEFINE1(alarm, unsigned int, seconds)
-{
-	return alarm_setitimer(seconds);
-}
-
-#endif
-
 static void process_timeout(unsigned long __data)
 {
 	wake_up_process((struct task_struct *)__data);
-- 
2.7.4
