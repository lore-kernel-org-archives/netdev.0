From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen: causing lots of errors in console log
Date: Fri, 11 Mar 2005 14:58:32 +0100
Message-ID: <16945.41992.799695.358632@robur.slu.se>
References: <20050308140826.451435e5@dxpl.pdx.osdl.net>
	<16942.55689.924299.906304@robur.slu.se>
	<20050310104830.58c467c0@es175>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: cliff white <cliffw@osdl.org>
In-Reply-To: <20050310104830.58c467c0@es175>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


cliff white writes:

 > Okay,  I can reproduce it on two machines, no problem.

 I too with CONFIG_PREEMPT=y. Thanks.

 Please try:


--- net/core/pktgen.c.050310	2005-03-10 22:12:43.000000000 +0100
+++ net/core/pktgen.c	2005-03-11 10:48:43.000000000 +0100
@@ -151,7 +151,7 @@
 #include <asm/timex.h>
 
 
-#define VERSION  "pktgen v2.59: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.60: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a) 
@@ -1419,7 +1419,6 @@
 	if (debug) 
 		printk("pktgen: t=%s, count=%lu\n", name, count);
         
-	thread_lock();
 
         t = (struct pktgen_thread*)(data);
 	if(!t) {
@@ -1441,14 +1440,18 @@
 		if( copy_from_user(f, &user_buffer[i], len) )
 			return -EFAULT;
 		i += len;
+		thread_lock();
                 pktgen_add_device(t, f);
+		thread_unlock();
                 ret = count;
                 sprintf(pg_result, "OK: add_device=%s", f);
 		goto out;
 	}
 
         if (!strcmp(name, "rem_device_all")) {
+		thread_lock();
 		t->control |= T_REMDEV;
+		thread_unlock();
 		current->state = TASK_INTERRUPTIBLE;
 		schedule_timeout(HZ/8);  /* Propagate thread->control  */
 		ret = count;
@@ -1456,10 +1459,11 @@
 		goto out;
 	}
 
-
         if (!strcmp(name, "max_before_softirq")) {
                 len = num_arg(&user_buffer[i], 10, &value);
+		thread_lock();
                 t->max_before_softirq = value;
+		thread_unlock();
                 ret = count;
                 sprintf(pg_result, "OK: max_before_softirq=%lu", value);
 		goto out;
@@ -1467,7 +1471,6 @@
 
 	ret = -EINVAL;
  out:
-	thread_unlock();
 
 	return ret;
 }



						--ro
