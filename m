From: Neil Horman <nhorman@redhat.com>
Subject: Re: netpoll_send_skb_on_dev warning with bnx2
Date: Wed, 7 Oct 2015 10:38:27 -0400
Message-ID: <20151007143827.GB26644@hmsreliant.think-freely.org>
References: <CAHTgTXVCwhYKFKHPJHK19uLPX4na8+WJ7WMEv15BZMPocNQBwA@mail.gmail.com>
 <20151002131027.GC10731@hmsreliant.think-freely.org>
 <CAHTgTXW2HnJ2j=r3McsSm4q0XVQ4_NhjzwzFx9vmRFtt6rbVOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHTgTXW2HnJ2j=r3McsSm4q0XVQ4_NhjzwzFx9vmRFtt6rbVOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 06, 2015 at 10:12:56PM -0700, Vinson Lee wrote:
> On Fri, Oct 2, 2015 at 6:10 AM, Neil Horman <nhorman@redhat.com> wrote:
> > On Thu, Oct 01, 2015 at 08:25:46PM -0700, Vinson Lee wrote:
> >> Hi.
> >>
> >> I am seeing a netpoll_send_skb_on_dev warning with bnx2. It happens on
> >> Linux 4.1 and I am able to reproduce the warning with Linux 4.3-rc3.
> >>
> >> ------------[ cut here ]------------
> >> WARNING: CPU: 11 PID: 3110 at net/core/netpoll.c:368
> >> netpoll_send_skb_on_dev+0x183/0x201()
> >> netpoll_send_skb_on_dev(): eth0 enabled interrupts in poll
> >> (bnx2_start_xmit+0x0/0x5d4 [bnx2])
> >> Modules linked in: netconsole(+) configfs ipv6 ppdev parport_pc lp
> >> parport tcp_diag inet_diag ipmi_devintf serio_raw iTCO_wdt
> >> iTCO_vendor_support ipmi_si ipmi_msghandler hpilo hpwdt bnx2 coretemp
> >> kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode lpc_ich
> >> mfd_core i7core_edac edac_core pcc_cpufreq acpi_cpufreq shpchp
> >> sch_fq_codel hpsa radeon ttm drm_kms_helper drm fb_sys_fops sysimgblt
> >> sysfillrect syscopyarea i2c_algo_bit i2c_core
> >> CPU: 11 PID: 3110 Comm: modprobe Not tainted 4.3.0-rc3 #1
> >>  0000000000000170 ffff88060be17a18 ffffffff812bc84c ffffffff818b1a78
> >>  ffff88060be17a68 ffff88060be17a58 ffffffff81064712 000000000be17a68
> >>  ffffffff814ec12e ffff88060bc10900 0000000000000000 ffff8800d941c000
> >> Call Trace:
> >>  [<ffffffff812bc84c>] dump_stack+0x48/0x5c
> >>  [<ffffffff81064712>] warn_slowpath_common+0xa1/0xbb
> >>  [<ffffffff814ec12e>] ? netpoll_send_skb_on_dev+0x183/0x201
> >>  [<ffffffff810647cf>] warn_slowpath_fmt+0x46/0x48
> >>  [<ffffffffa039a6b9>] ? bnx2_run_loopback+0x391/0x391 [bnx2]
> >>  [<ffffffff814ec12e>] netpoll_send_skb_on_dev+0x183/0x201
> >>  [<ffffffff814ec58b>] netpoll_send_udp+0x3df/0x3f1
> >>  [<ffffffffa049324a>] write_msg+0xaf/0xe9 [netconsole]
> >>  [<ffffffff810a6daa>] call_console_drivers.clone.2+0xd1/0xe9
> >>  [<ffffffff810a70d0>] console_unlock+0x30e/0x3a5
> >>  [<ffffffff810a757d>] register_console+0x2af/0x322
> >>  [<ffffffffa04971b4>] init_netconsole+0x1b4/0x224 [netconsole]
> >>  [<ffffffffa0497000>] ? 0xffffffffa0497000
> >>  [<ffffffff810002bf>] do_one_initcall+0xf7/0x182
> >>  [<ffffffff811764fe>] ? kmem_cache_alloc_trace+0xb6/0xf0
> >>  [<ffffffff810cb8d8>] ? do_init_module+0x31/0x1e4
> >>  [<ffffffff810cb910>] do_init_module+0x69/0x1e4
> >>  [<ffffffff810ccedc>] load_module+0x1451/0x160b
> >>  [<ffffffff810ca1a3>] ? mod_kobject_put+0x4d/0x4d
> >>  [<ffffffff811606f3>] ? __vmalloc_node+0x3e/0x40
> >>  [<ffffffff810cd2aa>] SyS_init_module+0x14f/0x155
> >>  [<ffffffff815833d7>] entry_SYSCALL_64_fastpath+0x12/0x6a
> >> ---[ end trace 878215466e581776 ]---
> >>
> >> Cheers,
> >> Vinson
> >
> > Hmm, that would suggest that someone called local_irq_enable in either the xmit,
> > poll_controller or napi poll paths (or one of its always-disable, bretheren),
> > but I dont see where that might be happening.  Are you able to instrument the
> > kernel (either by cloning that WARN_ON_ONCE call or via stap script), so we can
> > further isolate which call path the problem is happening in?
> >
> > Neil
> >
> 
> I bisected the regression and it is introduced with this Linux 3.19-rc1 commit.
> 
> e22b886a8a43b147e1994a9f970f678fc0df2033 is the first bad commit
> commit e22b886a8a43b147e1994a9f970f678fc0df2033
> Author: Peter Zijlstra <peterz@infradead.org>
> Date:   Wed Sep 24 10:18:48 2014 +0200
> 
>     sched/wait: Add might_sleep() checks
> 
>     Add more might_sleep() checks, suppose someone put a wait_event() like
>     thing in a wait loop..
> 
>     Can't put might_sleep() in ___wait_event() because there's the locked
>     primitives which call ___wait_event() with locks held.
> 
>     Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>     Cc: tglx@linutronix.de
>     Cc: ilya.dryomov@inktank.com
>     Cc: umgwanakikbuti@gmail.com
>     Cc: Oleg Nesterov <oleg@redhat.com>
>     Cc: Linus Torvalds <torvalds@linux-foundation.org>
>     Link: http://lkml.kernel.org/r/20140924082242.119255706@infradead.org
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> 
> :040000 040000 1536c4cc3c706b4129452ce023c69733b46a23e4
> 22c894c6ae02be75e5f772d39fde178f036e906f M    include
> 
> Vinson

That doesn't make any sense.  That commitis just adding some warning messages,
it doesn't change any locking or irq enablement states.  That in turn suggests
that you are seeing something is transient and sensitive to timing.  What driver
is eth0 using?  Is it bnx2 or something else?

Neil
