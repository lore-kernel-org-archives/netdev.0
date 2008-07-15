From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: r8169 device jumps from 12k/sec interrupts with traffic to over 100k/sec interrupts without traffic
Date: Mon, 14 Jul 2008 23:30:40 -0400
Message-ID: <76366b180807142030y38b97508id8523b699d2baf37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:58338 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbYGODal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:30:41 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5794547rvb.1
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 20:30:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm currently running 2.6.26-rc8 (NAPI enabled) and my r8169 device is
going a little crazy after a short time under load.

Test scenario is as follows...
r8169-system: nc -l -p 8888 > /dev/null
remote-system: cat /dev/zero | nc r8169-system 8888

While this is running, I also do the following:
r8169-system: dd if=/dev/sda of=/dev/null

While both commands are running under the r8169 system, I run the
following to see the # of interrupts/sec occuring:
while true; do cat /proc/interrupts | grep eth0; sleep 1; done

I see roughly 12k/sec interrupts on eth0 and ~ 400/sec interrupts on
sata_sil. This continues for some time at which point the system
appears to hang (I no longer see the /proc/interrupts output every
second). I switched back to the r8169 netcat and ctrl-c'd it. At this
point the system is still acting really really sluggish and finally
the cat /proc/interrupts output begins again. The only difference is
now that I see it has exploded to 110k/sec interrupts on eth0 even
though there is no data flowing to the system! The stats on ifconfig
eth0 show no rx/tx byte counters increasing yet there is a constant
100+k/sec interrupt load on the device.

It appears to be affecting the rest of the system because during this
time I also get other strange behavior.. For instance I see libata
timeouts on the disks and they soft reset occasionally. Another
example of something which happens in this state:

NETDEV WATCHDOG: eth0: transmit timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x80/0xc3()
Pid: 738, comm: dd Not tainted 2.6.26-rc8 #8
 [<c0216072>] warn_on_slowpath+0x3b/0x61
 [<c0222d35>] autoremove_wake_function+0xc/0x2b
 [<c02124f8>] __wake_up_common+0x2d/0x52
 [<c03a6879>] dev_watchdog+0x0/0xc3
 [<c0213bd0>] __wake_up+0xf/0x15
 [<c0216416>] wake_up_klogd+0x2b/0x2d
 [<c0224c16>] hrtimer_forward+0xe2/0xfe
 [<c0206bf0>] read_tsc+0x6/0x22
 [<c0226b5b>] getnstimeofday+0x32/0xaf
 [<c0206a53>] pit_next_event+0x16/0x1a
 [<c0228e78>] clockevents_program_event+0xd1/0xe0
 [<c0220de2>] queue_delayed_work_on+0x70/0x7b
 [<c03a6879>] dev_watchdog+0x0/0xc3
 [<c0220e13>] queue_delayed_work+0x16/0x18
 [<c03a6879>] dev_watchdog+0x0/0xc3
 [<c03a68f9>] dev_watchdog+0x80/0xc3
 [<c021c051>] run_timer_softirq+0xf3/0x137
 [<c02195c0>] __do_softirq+0x35/0x75
 [<c0219622>] do_softirq+0x22/0x26
 [<c021989e>] irq_exit+0x25/0x53
 [<c0204cc3>] do_IRQ+0x4d/0x5d
 [<c0203833>] common_interrupt+0x23/0x28
 [<c0260000>] sys_futimesat+0x6/0x81
 [<c0247eeb>] rw_verify_area+0x5d/0x78
 [<c0248402>] vfs_write+0x62/0xec
 [<c0248863>] sys_write+0x3c/0x63
 [<c02036aa>] syscall_call+0x7/0xb
 =======================
---[ end trace f4d1fed7dd1e3699 ]---
r8169: eth0: link up

What can I do to further debug this problem?

Thanks,
-Andrew
