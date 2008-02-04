From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: locking api self-test hanging
Date: Mon, 4 Feb 2008 05:04:21 -0800
Message-ID: <20080204050421.0febc754.akpm@linux-foundation.org>
References: <20080203150246.50647fa4.akpm@linux-foundation.org>
	<20080203150744.cf7d0415.akpm@linux-foundation.org>
	<20080204044304.d244e761.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Bernhard Walle <bwalle@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40802 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751529AbYBDNE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 08:04:27 -0500
In-Reply-To: <20080204044304.d244e761.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Feb 2008 04:43:04 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 3 Feb 2008 15:07:44 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Sun, 3 Feb 2008 15:02:46 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > 
> > > With current mainline I'm getting intermittent hangs here:
> > > 
> > > 	http://userweb.kernel.org/~akpm/p2033590.jpg
> > > 
> > > with this config:
> > > 
> > > 	http://userweb.kernel.org/~akpm/config-sony.txt
> > > 
> > > on the Vaio.  Sometimes it boots (then hits another different hang),
> > > sometimes it gets stuck there.
> 
> CONFIG_DEBUG_LOCKING_API_SELFTESTS=n fixed that up.
> 
> > 
> > The second hang is in kobject_uevent_init().  All that function does is call
> > netlink_kernel_create().
> 
> And I've fully bisected this hang twice and both times came up with
> 
> commit 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Mon Nov 19 19:24:52 2007 -0800
> 
>     [NETPOLL]: Kill NETPOLL_RX_DROP, set but never tested.
> 
> which is stupid because that patch doesn't do anything.
> 
> However I am using netconsole-over-e100 and the hang does go away when I
> disable netconsole on the kernel boot command line.
> 

After disabling both CONFIG_DEBUG_LOCKING_API_SELFTESTS and netconsole
(using current mainline) I get a login prompt, and also...

[    5.181668] SELinux: policy loaded with handle_unknown=deny
[    5.183315] type=1403 audit(1202100038.157:3): policy loaded auid=4294967295 ses=4294967295
[    5.822073] SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
[    7.819146] ------------[ cut here ]------------
[    7.819146] WARNING: at kernel/lockdep.c:2033 trace_hardirqs_on+0x9b/0x10d()
[    7.819146] Modules linked in: generic ext3 jbd ide_disk ide_core
[    7.819146] Pid: 399, comm: hwclock Not tainted 2.6.24 #4
[    7.819146]  [<c011d140>] warn_on_slowpath+0x41/0x51
[    7.819146]  [<c01364a9>] ? lock_release_holdtime+0x50/0x56
[    7.819146]  [<c013770c>] ? check_usage_forwards+0x19/0x3b
[    7.819146]  [<c01390c4>] ? __lock_acquire+0xac3/0xb0b
[    7.819146]  [<c0108c98>] ? native_sched_clock+0x8b/0x9f
[    7.819146]  [<c01364a9>] ? lock_release_holdtime+0x50/0x56
[    7.819146]  [<c030ca6c>] ? _spin_unlock_irq+0x22/0x42
[    7.819146]  [<c013848b>] trace_hardirqs_on+0x9b/0x10d
[    7.819146]  [<c030ca6c>] _spin_unlock_irq+0x22/0x42
[    7.819146]  [<c011481e>] hpet_rtc_interrupt+0xdf/0x290
[    7.819146]  [<c014ea90>] handle_IRQ_event+0x1a/0x46
[    7.819146]  [<c014f8ea>] handle_edge_irq+0xbe/0xff
[    7.819146]  [<c0106e08>] do_IRQ+0x6d/0x84
[    7.819146]  [<c0105596>] common_interrupt+0x2e/0x34
[    7.819146]  [<c013007b>] ? ktime_get_ts+0x8/0x3f
[    7.819146]  [<c0139420>] ? lock_release+0x167/0x16f
[    7.819146]  [<c017974a>] ? core_sys_select+0x2c/0x327
[    7.819146]  [<c0179792>] core_sys_select+0x74/0x327
[    7.819146]  [<c0108c98>] ? native_sched_clock+0x8b/0x9f
[    7.819146]  [<c01364a9>] ? lock_release_holdtime+0x50/0x56
[    7.819146]  [<c030ca6c>] ? _spin_unlock_irq+0x22/0x42
[    7.819146]  [<c01384d6>] ? trace_hardirqs_on+0xe6/0x10d
[    7.819146]  [<c030ca77>] ? _spin_unlock_irq+0x2d/0x42
[    7.819146]  [<c023b437>] ? rtc_do_ioctl+0x11b/0x677
[    7.819146]  [<c01c487e>] ? inode_has_perm+0x5e/0x68
[    7.819146]  [<c01364a9>] ? lock_release_holdtime+0x50/0x56
[    7.819146]  [<c0108c98>] ? native_sched_clock+0x8b/0x9f
[    7.819146]  [<c01c490b>] ? file_has_perm+0x83/0x8c
[    7.819146]  [<c023ba08>] ? rtc_ioctl+0xf/0x11
[    7.819146]  [<c017898d>] ? do_ioctl+0x55/0x67
[    7.819146]  [<c0179d15>] sys_select+0x93/0x163
[    7.819146]  [<c0104b39>] ? sysenter_past_esp+0x9a/0xa5
[    7.819146]  [<c0104afe>] sysenter_past_esp+0x5f/0xa5
[    7.819146]  =======================
[    7.819146] ---[ end trace 96540ca301ffb84c ]---
[    7.819210] rtc: lost 6 interrupts
[    7.870668] type=1400 audit(1202128840.794:4): avc:  denied  { audit_write } for  pid=399 comm="hwclock" capability=29 scontext=system_u:system_r:hwclock_t:s0 tcontext=system_u:system_r:hwclock_t:s0 tclass=capability
[    9.538866] input: PC Speaker as /class/input/input5

Because hpet_rtc_interrupt()'s call to get_rtc_time() ends up
resolving to include/asm-generic/rtc.h's (hilariously inlined)
get_rtc_time(), which does spin_unlock_irq() from hard IRQ context.

That warning in lockdep.c should have a comment explaining to readers under
which circumstances it will trigger, and what they did wrong.  In fact if
I've interpreted it correctly I don't see why it's a DEBUG_LOCKS_WARN_ON
thing at all?  It should be a first-class lockdep warning?

The obvious patch fixes it:

--- a/include/asm-generic/rtc.h~a
+++ a/include/asm-generic/rtc.h
@@ -35,10 +35,11 @@
 static inline unsigned char rtc_is_updating(void)
 {
 	unsigned char uip;
+	unsigned long flags;
 
-	spin_lock_irq(&rtc_lock);
+	spin_lock_irqsave(&rtc_lock, flags);
 	uip = (CMOS_READ(RTC_FREQ_SELECT) & RTC_UIP);
-	spin_unlock_irq(&rtc_lock);
+	spin_unlock_irqrestore(&rtc_lock, flags);
 	return uip;
 }
 
@@ -46,6 +47,8 @@ static inline unsigned int get_rtc_time(
 {
 	unsigned long uip_watchdog = jiffies;
 	unsigned char ctrl;
+	unsigned long flags;
+
 #ifdef CONFIG_MACH_DECSTATION
 	unsigned int real_year;
 #endif
@@ -72,7 +75,7 @@ static inline unsigned int get_rtc_time(
 	 * RTC has RTC_DAY_OF_WEEK, we ignore it, as it is only updated
 	 * by the RTC when initially set to a non-zero value.
 	 */
-	spin_lock_irq(&rtc_lock);
+	spin_lock_irqsave(&rtc_lock, flags);
 	time->tm_sec = CMOS_READ(RTC_SECONDS);
 	time->tm_min = CMOS_READ(RTC_MINUTES);
 	time->tm_hour = CMOS_READ(RTC_HOURS);
@@ -83,7 +86,7 @@ static inline unsigned int get_rtc_time(
 	real_year = CMOS_READ(RTC_DEC_YEAR);
 #endif
 	ctrl = CMOS_READ(RTC_CONTROL);
-	spin_unlock_irq(&rtc_lock);
+	spin_unlock_irqrestore(&rtc_lock, flags);
 
 	if (!(ctrl & RTC_DM_BINARY) || RTC_ALWAYS_BCD)
 	{
_


but that code really needs help.

Bernhard, I believe the checklist items in Documentation/SubmitChecklist
would have prevented this at the source.


ObProcessObservation: afacit the offending commit went mailing list ->
git-x86 -> mainline in about three days flat, a week after the merge
window had opened.

