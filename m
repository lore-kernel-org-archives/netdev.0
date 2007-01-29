From: Chris Lightfoot <chris@ex-parrot.com>
Subject: sky2 problems on Intel Mac Mini
Date: Mon, 29 Jan 2007 23:57:32 +0000
Message-ID: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wumpus2.mythic-beasts.com ([212.69.38.51]:45916 "EHLO
	wumpus2.mythic-beasts.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965242AbXA3Ahy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 19:37:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  [ please cc: me on any reply ]

I'm seeing lots of problems with the sky2 driver on Mac
Minis. Based on the suggestions in,
    http://www.mail-archive.com/netdev@vger.kernel.org/msg28221.html
I am running stock 2.6.19 + the patches from the
mactel-linux.org site to get the kernel booting on the
Apple hardware; none of these touches the sky2 code. The
module is installed with disable_msi=1 and
idle_timeout=10; the chip version is,
    Yukon-EC (0xb6) rev 2

The crashes we're seeing at the moment show (with
debug=16) lots and lots of transmits being queued up and
never being completed, even with the timeout switched on.
For instance, (this is on a machine running NFS root and
vlans)

    [ lots of normal activity alternating tx queued / tx done ]
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 65, len 150 
Jan 29 21:03:22 yeti kernel: sky2 eth0: rx slot 106 status 0x9e2100 len 154 
Jan 29 21:03:22 yeti kernel: eth0: tx done 66 
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 67, len 150 
Jan 29 21:03:22 yeti kernel: sky2 eth0: rx slot 107 status 0x9e2100 len 154 
Jan 29 21:03:22 yeti kernel: eth0: tx done 68 
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 69, len 150 
Jan 29 21:03:22 yeti kernel: sky2 eth0: rx slot 108 status 0x9e2100 len 154 
Jan 29 21:03:22 yeti kernel: eth0: tx done 70 
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 71, len 89 
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 73, len 1090
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 75, len 1514
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 79, len 90 
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 81, len 1514 
Jan 29 21:03:22 yeti kernel: eth0: tx queued, slot 84, len 1090 
Jan 29 21:03:23 yeti kernel: eth0: tx queued, slot 86, len 98 
Jan 29 21:03:23 yeti kernel: eth0: tx queued, slot 88, len 1514 
Jan 29 21:03:23 yeti kernel: eth0: tx queued, slot 91, len 1090 
Jan 29 21:03:23 yeti kernel: eth0: tx queued, slot 93, len 54 
Jan 29 21:03:23 yeti kernel: eth0: tx queued, slot 94, len 66 
Jan 29 21:03:24 yeti kernel: eth0: tx queued, slot 95, len 54 
Jan 29 21:03:24 yeti kernel: eth0: tx queued, slot 96, len 66 
Jan 29 21:03:24 yeti kernel: eth0: tx queued, slot 97, len 98 
    [ ... and so on for a total of 109 tx queued with no tx done, after which
      our watchdog rebooted the machine ] 

-- though we've also seen, e.g., (no NFS root, no vlans)

Jan 28 19:32:16 t1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jan 28 19:32:16 t1 kernel: sky2 eth0: tx timeout
Jan 28 19:32:16 t1 kernel: sky2 eth0: transmit ring 115 .. 92 report=115 done=115
Jan 28 19:32:16 t1 kernel: sky2 hardware hung? flushing
Jan 28 19:32:25 t1 kernel: BUG: soft lockup detected on CPU#0!
Jan 28 19:32:25 t1 kernel:  [<c015495a>] softlockup_tick+0xba/0xe0
Jan 28 19:32:25 t1 kernel:  [<c01327e9>] update_process_times+0x39/0x90
Jan 28 19:32:25 t1 kernel:  [<c0117337>] smp_apic_timer_interrupt+0x97/0xc0
Jan 28 19:32:25 t1 kernel:  [<c0103eab>] apic_timer_interrupt+0x1f/0x24
Jan 28 19:32:25 t1 kernel:  [<c0445107>] _spin_lock_irqsave+0x67/0x80
Jan 28 19:32:25 t1 kernel:  [<c0445136>] _spin_lock_bh+0x6/0x20
Jan 28 19:32:25 t1 kernel:  [<c0302f40>] sky2_tx_clean+0x20/0x70
Jan 28 19:32:25 t1 kernel:  [<c0303904>] sky2_tx_timeout+0x144/0x1b0
Jan 28 19:32:25 t1 kernel:  [<c03da1c0>] dev_watchdog+0x0/0xe0
Jan 28 19:32:25 t1 kernel:  [<c03da28e>] dev_watchdog+0xce/0xe0
Jan 28 19:32:25 t1 kernel:  [<c0132916>] run_timer_softirq+0xc6/0x1c0
Jan 28 19:32:25 t1 kernel:  [<c0120c80>] scheduler_tick+0xb0/0x3a0
Jan 28 19:32:25 t1 kernel:  [<c012d1ea>] __do_softirq+0xca/0xf0
Jan 28 19:32:25 t1 kernel:  [<c012d245>] do_softirq+0x35/0x40
Jan 28 19:32:25 t1 kernel:  [<c012d295>] irq_exit+0x45/0x50
Jan 28 19:32:25 t1 kernel:  [<c011733c>] smp_apic_timer_interrupt+0x9c/0xc0
Jan 28 19:32:25 t1 kernel:  [<c0103eab>] apic_timer_interrupt+0x1f/0x24
Jan 28 19:32:25 t1 kernel:  [<c0101332>] mwait_idle_with_hints+0x32/0x40
Jan 28 19:32:25 t1 kernel:  [<c0101370>] mwait_idle+0x30/0x40
Jan 28 19:32:25 t1 kernel:  [<c0101144>] cpu_idle+0x94/0xe0
Jan 28 19:32:25 t1 kernel:  [<c0592a16>] start_kernel+0x1c6/0x230
Jan 28 19:32:25 t1 kernel:  [<c0592360>] unknown_bootoption+0x0/0x1e0
Jan 28 19:32:25 t1 kernel:  =======================

-- I assume this is just the same problem exhibiting on a
kernel with soft lockups detection enabled?

Hopefully I should be able to actually log into one of
these machines over an alternate connection next time the
problem recurs, at which point I should be able to get
ethtool -d output. Anything else I should do at that
point?

Any suggestions for what to do next to chase this problem
down? I haven't yet tried the sk98lin driver on this
hardware; is that still worth doing? Are there any useful
tests we should try? Unfortunately, though these crashes
happen pretty frequently (several times per day
typically), I don't have a test case to reproduce one;
however, if it'd be useful, I can probably get a pcap
trace of the period immediately before the interface falls
over using port mirroring on the switch to which the
machines are connected. Is that likely to be informative?

-- 
``Is `colons' the plural of `semi-colon' if you know
  you have an even number of them?'' (David Richerby)
