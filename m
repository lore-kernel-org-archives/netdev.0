From: Caglar Akyuz <caglarakyuz@gmail.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Sat, 11 Sep 2010 11:54:41 +0300
Message-ID: <201009111154.42171.caglarakyuz@gmail.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <4C8950D4.9060102@criticallink.com> <201009101823.52755.caglarakyuz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Williamson <michael.williamson@criticallink.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: cyril@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <201009101823.52755.caglarakyuz@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 10 September 2010 06:23:52 pm Caglar Akyuz wrote:
> On Friday 10 September 2010 12:25:40 am Michael Williamson wrote:
> > Hi Cyril,
> >
> > On 09/09/2010 03:51 PM, Cyril Chemparathy wrote:
> > > Hi Mike,
> > >
> > > [...]
> > >
> > >> The hang is in wait_for_user_access() in the davinci_mdio_read() call.
> > >> Looks like the state machine got put back into IDLE somewhere between
> > >> the MDIO probe and the EMAC probe. Seems like there should be some
> > >> sort of time-out and error message in the wait_for_user_access()
> > >> method.... (maybe even a check for IDLE??)
> > >>
> > >> If I add a patch to check the state machine for IDLE and then
> > >> re-enable it in the davinci_mdio_read() call, it is able to press on
> > >> and come up. I don't see any calls to the davinci_mdio_suspend() call,
> > >> so I am wondering if the EMAC probe routine, particularly the
> > >> application of the SOFTRESET, is causing the MDIO to drop back to IDLE
> > >> / disabled.
> > >>
> > >> I can post the patch if you like, but it is a bit of a hack...
> > >
> > > An EMAC soft-reset clobbering the MDIO controller state is a
> > > possibility.  I will poll TI designers to see if this could be the
> > > case.
> > >
> > > In any case, a couple of unanswered questions remain:
> > >
> > >   1. Why don't other davinci devices display similar behavior?
> > >
> > >   2. If the answer to #1 above is that the timing window is pretty slim
> > >      (i.e., only if an MDIO read/write is in progress during EMAC
> > >      soft-reset), why do we hit this situation consistently on
> > >      mityomap?
> >
> > Has it been confirmed that this only happens on mityomap?  Has anyone had
> >  success using a da850 evm or other da850 platform?  The configuration
> > for
> 
> Same problem exists on another DA850 board, Hawkboard.(Sorry no support in
> mainline yet)
> 
> >  the mityomap, wrt to the EMAC/MII/MDIO, is pretty much identical to the
> >  da850 evm using the MII interface. The only difference I am aware of is
> >  the assigned address to the PHY chip.  The reference clocks and rates
> > are identical, AFAIK, to the evm.
> >
> > > I have put together a quick patch (tested dm365).  See attached.
> >
> > Your patch doesn't work with my board.  It does attempt to reset the bus
> > on
> 
> This patch fixes the problem here. I'm using kernel IP auto configuration
>  and mounting fs over NFS. My system boots and I can login to my board.
> 
> Regards,
> Caglar
> 

Unfortunately emac driver is not stable after this series. I face lock-ups 
time to time, followed by attached kernel trace.

Regards,
Caglar
_________________________________________________________________

[ 1651.440000] nfs: server 192.168.2.34 not responding, still trying
[ 1859.010000] ------------[ cut here ]------------
[ 1859.010000] WARNING: at net/sched/sch_generic.c:258 
dev_watchdog+0x184/0x294()
[ 1859.020000] NETDEV WATCHDOG: eth0 (davinci_emac): transmit queue 0 timed 
out
[ 1859.020000] Modules linked in:
[ 1859.030000] Backtrace:
[ 1859.030000] [<c0030444>] (dump_backtrace+0x0/0x10c) from [<c02d9820>] 
(dump_stack+0x18/0x1c)
[ 1859.040000]  r7:c03b5de8 r6:c025a13c r5:c039045c r4:00000102
[ 1859.040000] [<c02d9808>] (dump_stack+0x0/0x1c) from [<c0042e44>] 
(warn_slowpath_common+0x58/0x70)
[ 1859.050000] [<c0042dec>] (warn_slowpath_common+0x0/0x70) from [<c0042f00>] 
(warn_slowpath_fmt+0x38/0x40)
[ 1859.060000]  r8:c03b4000 r7:00000030 r6:c0437564 r5:c7bbc000 r4:00000000
[ 1859.070000] [<c0042ec8>] (warn_slowpath_fmt+0x0/0x40) from [<c025a13c>] 
(dev_watchdog+0x184/0x294)
[ 1859.080000]  r3:c7bbc000 r2:c0390474
[ 1859.080000] [<c0259fb8>] (dev_watchdog+0x0/0x294) from [<c004e918>] 
(run_timer_softirq+0x1c4/0x29c)
[ 1859.090000] [<c004e754>] (run_timer_softirq+0x0/0x29c) from [<c0048b94>] 
(__do_softirq+0x98/0x12c)
[ 1859.100000] [<c0048afc>] (__do_softirq+0x0/0x12c) from [<c0048c70>] 
(irq_exit+0x48/0x9c)
[ 1859.110000] [<c0048c28>] (irq_exit+0x0/0x9c) from [<c002c080>] 
(asm_do_IRQ+0x80/0xa0)
[ 1859.120000] [<c002c000>] (asm_do_IRQ+0x0/0xa0) from [<c002cb2c>] 
(__irq_svc+0x4c/0x9c)
[ 1859.120000] Exception stack(0xc03b5f38 to 0xc03b5f80)
[ 1859.130000] 5f20:                                                       
00000000 0005317f
[ 1859.140000] 5f40: 0005217f 60000013 c03b4000 c03b8ba0 c03b89d4 c03dcc50 
c0023e04 41069265
[ 1859.150000] 5f60: c0023d94 c03b5f8c 600000d3 c03b5f80 c002da6c c002da78 
60000013 ffffffff
[ 1859.150000]  r5:febfd000 r4:ffffffff
[ 1859.160000] [<c002da48>] (default_idle+0x0/0x34) from [<c002dff0>] 
(cpu_idle+0x74/0xdc)
[ 1859.170000] [<c002df7c>] (cpu_idle+0x0/0xdc) from [<c02d59d4>] 
(rest_init+0xa4/0xbc)
[ 1859.170000]  r7:c03b89c8 r6:c0026018 r5:c03dcc1c r4:00000002
[ 1859.180000] [<c02d5930>] (rest_init+0x0/0xbc) from [<c0008bc4>] 
(start_kernel+0x270/0x2d0)
[ 1859.190000]  r4:c042d70c
[ 1859.190000] [<c0008954>] (start_kernel+0x0/0x2d0) from [<c0008034>] 
(__enable_mmu+0x0/0x2c)
[ 1859.200000]  r6:c002641c r5:c03dcc78 r4:00053175
[ 1859.200000] ---[ end trace d278f645c502dc20 ]---
