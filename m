From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [atmdrvr zatm] Remove obsolete EXACT_TS support
Date: Tue, 29 Jul 2003 13:15:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307291717.h6THHosG027846@ginger.cmf.nrl.navy.mil>
References: <20030728071323.GT32831@gaz.sfgoth.com>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-reply-to: Your message of "Mon, 28 Jul 2003 00:13:23 PDT."
             <20030728071323.GT32831@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave, please apply the following patch (hopefully one will arrive
shortly that removes cli() et al from zatm as well):

In message <20030728071323.GT32831@gaz.sfgoth.com>,Mitchell Blank Jr writes:
>Chas - here's another 2.6 atm driver patch.  Please push it upstream.
>
>This removes the obsolete "exact timestamp" support from the zatm driver.
>My understanding is that it was part of a research thing Werner did 8 or
>so years ago.  It has no purpose for any production use.  I think 2.6 is
>its time to die.
>
>Besides, these days we use do_gettimeofday() instead of xtime so we should
>have a reasonably accurate timestamp anyways.
>
>The only program that uses the ZATM_GETTHIST ioctl is the src/debug/znth.c
>from the userland distribution.  This isn't even compiled as part of the
>make process so I don't feel any guilt about breaking it.  It should
>probably also just go away.
>
>I don't have the hardware (and really doubt anyone else does either, but
>that's another matter entirely) but it still compiles and insmod's.
>
>Patch is versus 2.6.0-test2.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1596  -> 1.1597 
#	  drivers/atm/zatm.c	1.12    -> 1.13   
#	 drivers/atm/Kconfig	1.5     -> 1.6    
#	  drivers/atm/zatm.h	1.1     -> 1.2    
#	include/linux/atm_zatm.h	1.1     -> 1.2    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/28	chas@relax.cmf.nrl.navy.mil	1.1597
# remove EXACT_TS remove from zatm (untested)
# --------------------------------------------
#
diff -Nru a/drivers/atm/Kconfig b/drivers/atm/Kconfig
--- a/drivers/atm/Kconfig	Tue Jul 29 13:15:41 2003
+++ b/drivers/atm/Kconfig	Tue Jul 29 13:15:41 2003
@@ -164,18 +164,6 @@
 	  Note that extended debugging may create certain race conditions
 	  itself. Enable this ONLY if you suspect problems with the driver.
 
-config ATM_ZATM_EXACT_TS
-	bool "Enable usec resolution timestamps"
-	depends on ATM_ZATM && X86
-	help
-	  The uPD98401 SAR chip supports a high-resolution timer (approx. 30
-	  MHz) that is used for very accurate reception timestamps. Because
-	  that timer overflows after 140 seconds, and also to avoid timer
-	  drift, time measurements need to be periodically synchronized with
-	  the normal system time. Enabling this feature will add some general
-	  overhead for timer synchronization and also per-packet overhead for
-	  time conversion.
-
 #   bool 'Rolfs TI TNETA1570' CONFIG_ATM_TNETA1570 y
 #   if [ "$CONFIG_ATM_TNETA1570" = "y" ]; then
 #      bool '  Enable extended debugging' CONFIG_ATM_TNETA1570_DEBUG n
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	Tue Jul 29 13:15:41 2003
+++ b/drivers/atm/zatm.c	Tue Jul 29 13:15:41 2003
@@ -52,13 +52,6 @@
 #define DPRINTK(format,args...)
 #endif
 
-#ifndef __i386__
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-#warning Precise timestamping only available on i386 platform
-#undef CONFIG_ATM_ZATM_EXACT_TS
-#endif
-#endif
-
 #ifndef CONFIG_ATM_ZATM_DEBUG
 
 
@@ -347,150 +340,6 @@
 	restore_flags(flags);
 }
 
-
-/*----------------------- high-precision timestamps -------------------------*/
-
-
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-
-static struct timer_list sync_timer;
-
-
-/*
- * Note: the exact time is not normalized, i.e. tv_usec can be > 1000000.
- * This must be handled by higher layers.
- */
-
-static inline struct timeval exact_time(struct zatm_dev *zatm_dev,u32 ticks)
-{
-	struct timeval tmp;
-
-	tmp = zatm_dev->last_time;
-	tmp.tv_usec += ((s64) (ticks-zatm_dev->last_clk)*
-	    (s64) zatm_dev->factor) >> TIMER_SHIFT;
-	return tmp;
-}
-
-
-static void zatm_clock_sync(unsigned long dummy)
-{
-	struct atm_dev *atm_dev;
-	struct zatm_dev *zatm_dev;
-
-	for (atm_dev = zatm_boards; atm_dev; atm_dev = zatm_dev->more) {
-		unsigned long flags,interval;
-		int diff;
-		struct timeval now,expected;
-		u32 ticks;
-
-		zatm_dev = ZATM_DEV(atm_dev);
-		save_flags(flags);
-		cli();
-		ticks = zpeekl(zatm_dev,uPD98401_TSR);
-		do_gettimeofday(&now);
-		restore_flags(flags);
-		expected = exact_time(zatm_dev,ticks);
-		diff = 1000000*(expected.tv_sec-now.tv_sec)+
-		    (expected.tv_usec-now.tv_usec);
-		zatm_dev->timer_history[zatm_dev->th_curr].real = now;
-		zatm_dev->timer_history[zatm_dev->th_curr].expected = expected;
-		zatm_dev->th_curr = (zatm_dev->th_curr+1) &
-		    (ZATM_TIMER_HISTORY_SIZE-1);
-		interval = 1000000*(now.tv_sec-zatm_dev->last_real_time.tv_sec)
-		    +(now.tv_usec-zatm_dev->last_real_time.tv_usec);
-		if (diff >= -ADJ_REP_THRES && diff <= ADJ_REP_THRES)
-			zatm_dev->timer_diffs = 0;
-		else
-#ifndef AGGRESSIVE_DEBUGGING
-			if (++zatm_dev->timer_diffs >= ADJ_MSG_THRES)
-#endif
-			{
-			zatm_dev->timer_diffs = 0;
-			printk(KERN_INFO DEV_LABEL ": TSR update after %ld us:"
-			    " calculation differed by %d us\n",interval,diff);
-#ifdef AGGRESSIVE_DEBUGGING
-			printk(KERN_DEBUG "  %d.%08d -> %d.%08d (%lu)\n",
-			    zatm_dev->last_real_time.tv_sec,
-			    zatm_dev->last_real_time.tv_usec,
-			    now.tv_sec,now.tv_usec,interval);
-			printk(KERN_DEBUG "  %u -> %u (%d)\n",
-			    zatm_dev->last_clk,ticks,ticks-zatm_dev->last_clk);
-			printk(KERN_DEBUG "  factor %u\n",zatm_dev->factor);
-#endif
-		}
-		if (diff < -ADJ_IGN_THRES || diff > ADJ_IGN_THRES) {
-		    /* filter out any major changes (e.g. time zone setup and
-		       such) */
-			zatm_dev->last_time = now;
-			zatm_dev->factor =
-			    (1000 << TIMER_SHIFT)/(zatm_dev->khz+1);
-		}
-		else {
-			zatm_dev->last_time = expected;
-			/*
-			 * Is the accuracy of udelay really only about 1:300 on
-			 * a 90 MHz Pentium ? Well, the following line avoids
-			 * the problem, but ...
-			 *
-			 * What it does is simply:
-			 *
-			 * zatm_dev->factor = (interval << TIMER_SHIFT)/
-			 *     (ticks-zatm_dev->last_clk);
-			 */
-#define S(x) #x		/* "stringification" ... */
-#define SX(x) S(x)
-			asm("movl %2,%%ebx\n\t"
-			    "subl %3,%%ebx\n\t"
-			    "xorl %%edx,%%edx\n\t"
-			    "shldl $" SX(TIMER_SHIFT) ",%1,%%edx\n\t"
-			    "shl $" SX(TIMER_SHIFT) ",%1\n\t"
-			    "divl %%ebx\n\t"
-			    : "=a" (zatm_dev->factor)
-			    : "0" (interval-diff),"g" (ticks),
-			      "g" (zatm_dev->last_clk)
-			    : "ebx","edx","cc");
-#undef S
-#undef SX
-#ifdef AGGRESSIVE_DEBUGGING
-			printk(KERN_DEBUG "  (%ld << %d)/(%u-%u) = %u\n",
-			    interval,TIMER_SHIFT,ticks,zatm_dev->last_clk,
-			    zatm_dev->factor);
-#endif
-		}
-		zatm_dev->last_real_time = now;
-		zatm_dev->last_clk = ticks;
-	}
-	mod_timer(&sync_timer,sync_timer.expires+POLL_INTERVAL*HZ);
-}
-
-
-static void __init zatm_clock_init(struct zatm_dev *zatm_dev)
-{
-	static int start_timer = 1;
-	unsigned long flags;
-
-	zatm_dev->factor = (1000 << TIMER_SHIFT)/(zatm_dev->khz+1);
-	zatm_dev->timer_diffs = 0;
-	memset(zatm_dev->timer_history,0,sizeof(zatm_dev->timer_history));
-	zatm_dev->th_curr = 0;
-	save_flags(flags);
-	cli();
-	do_gettimeofday(&zatm_dev->last_time);
-	zatm_dev->last_clk = zpeekl(zatm_dev,uPD98401_TSR);
-	if (start_timer) {
-		start_timer = 0;
-		init_timer(&sync_timer);
-		sync_timer.expires = jiffies+POLL_INTERVAL*HZ;
-		sync_timer.function = zatm_clock_sync;
-		add_timer(&sync_timer);
-	}
-	restore_flags(flags);
-}
-
-
-#endif
-
-
 /*----------------------------------- RX ------------------------------------*/
 
 
@@ -581,11 +430,7 @@
 EVENT("error code 0x%x/0x%x\n",(here[3] & uPD98401_AAL5_ES) >>
   uPD98401_AAL5_ES_SHIFT,error);
 		skb = ((struct rx_buffer_head *) bus_to_virt(here[2]))->skb;
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-		skb->stamp = exact_time(zatm_dev,here[1]);
-#else
 		do_gettimeofday(&skb->stamp);
-#endif
 #if 0
 printk("[-3..0] 0x%08lx 0x%08lx 0x%08lx 0x%08lx\n",((unsigned *) skb->data)[-3],
   ((unsigned *) skb->data)[-2],((unsigned *) skb->data)[-1],
@@ -1455,9 +1300,6 @@
 	    "MHz\n",dev->number,
 	    (zin(VER) & uPD98401_MAJOR) >> uPD98401_MAJOR_SHIFT,
             zin(VER) & uPD98401_MINOR,zatm_dev->khz/1000,zatm_dev->khz % 1000);
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-	zatm_clock_init(zatm_dev);
-#endif
 	return uPD98402_init(dev);
 }
 
@@ -1699,22 +1541,6 @@
 				restore_flags(flags);
 				return 0;
 			}
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-		case ZATM_GETTHIST:
-			{
-				int i;
-				struct zatm_t_hist hs[ZATM_TIMER_HISTORY_SIZE];
-				save_flags(flags);
-				cli();
-				for (i = 0; i < ZATM_TIMER_HISTORY_SIZE; i++)
-					hs[i] = zatm_dev->timer_history[
-					    (zatm_dev->th_curr+i) &
-					    (ZATM_TIMER_HISTORY_SIZE-1)];
-				restore_flags(flags);
-				return copy_to_user((struct zatm_t_hist *) arg,
-				    hs, sizeof(hs)) ? -EFAULT : 0;
-			}
-#endif
 		default:
         		if (!dev->phy->ioctl) return -ENOIOCTLCMD;
 		        return dev->phy->ioctl(dev,cmd,arg);
diff -Nru a/drivers/atm/zatm.h b/drivers/atm/zatm.h
--- a/drivers/atm/zatm.h	Tue Jul 29 13:15:41 2003
+++ b/drivers/atm/zatm.h	Tue Jul 29 13:15:41 2003
@@ -40,31 +40,6 @@
 #define MBX_TX_0	2
 #define MBX_TX_1	3
 
-
-/*
- * mkdep doesn't spot this dependency, but that's okay, because zatm.c uses
- * CONFIG_ATM_ZATM_EXACT_TS too.
- */
-
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-#define POLL_INTERVAL	60	/* TSR poll interval in seconds; must be <=
-				   (2^31-1)/clock */
-#define TIMER_SHIFT	20	/* scale factor for fixed-point arithmetic;
-				   1 << TIMER_SHIFT must be
-				     (1)  <= (2^64-1)/(POLL_INTERVAL*clock),
-				     (2)  >> clock/10^6, and
-				     (3)  <= (2^32-1)/1000  */
-#define ADJ_IGN_THRES	1000000	/* don't adjust if we're off by more than that
-				   many usecs - this filters clock corrections,
-				   time zone changes, etc. */
-#define ADJ_REP_THRES	20000	/* report only differences of more than that
-				   many usecs (don't mention single lost timer
-				   ticks; 10 msec is only 0.03% anyway) */
-#define ADJ_MSG_THRES	5	/* issue complaints only if getting that many
-				   significant timer differences in a row */
-#endif
-
-
 struct zatm_vcc {
 	/*-------------------------------- RX part */
 	int rx_chan;			/* RX channel, 0 if none */
@@ -103,17 +78,6 @@
 	u32 pool_base;			/* Free buffer pool dsc (word addr) */
 	/*-------------------------------- ZATM links */
 	struct atm_dev *more;		/* other ZATM devices */
-#ifdef CONFIG_ATM_ZATM_EXACT_TS
-	/*-------------------------------- timestamp calculation */
-	u32 last_clk;			/* results of last poll: clock, */
-	struct timeval last_time;	/*   virtual time and */
-	struct timeval last_real_time;	/*   real time */
-	u32 factor;			/* multiplication factor */
-	int timer_diffs;		/* number of significant deviations */
-	struct zatm_t_hist timer_history[ZATM_TIMER_HISTORY_SIZE];
-					/* record of timer synchronizations */
-	int th_curr;			/* current position */
-#endif
 	/*-------------------------------- general information */
 	int mem;			/* RAM on board (in bytes) */
 	int khz;			/* timer clock */
diff -Nru a/include/linux/atm_zatm.h b/include/linux/atm_zatm.h
--- a/include/linux/atm_zatm.h	Tue Jul 29 13:15:41 2003
+++ b/include/linux/atm_zatm.h	Tue Jul 29 13:15:41 2003
@@ -21,9 +21,6 @@
 						/* get statistics and zero */
 #define ZATM_SETPOOL	_IOW('a',ATMIOC_SARPRV+3,struct atmif_sioc)
 						/* set pool parameters */
-#define ZATM_GETTHIST	_IOW('a',ATMIOC_SARPRV+4,struct atmif_sioc)
-						/* get a history of timer
-						   differences */
 
 struct zatm_pool_info {
 	int ref_count;			/* free buffer pool usage counters */
