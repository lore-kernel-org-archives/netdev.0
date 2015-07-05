From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 6/6] net: mvneta: Statically assign queues to CPUs
Date: Sun, 5 Jul 2015 15:00:11 +0200
Message-ID: <20150705130011.GB24162@1wt.eu>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com> <1435933551-28696-7-git-send-email-maxime.ripard@free-electrons.com> <20150703164624.77188a63@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150703164624.77188a63@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,

On Fri, Jul 03, 2015 at 04:46:24PM +0200, Thomas Petazzoni wrote:
> Maxime,
> 
> On Fri,  3 Jul 2015 16:25:51 +0200, Maxime Ripard wrote:
> 
> > +static void mvneta_percpu_enable(void *arg)
> > +{
> > +	struct mvneta_port *pp = arg;
> > +
> > +	enable_percpu_irq(pp->dev->irq, IRQ_TYPE_NONE);
> > +}
> > +
> >  static int mvneta_open(struct net_device *dev)
> >  {
> >  	struct mvneta_port *pp = netdev_priv(dev);
> > @@ -2655,6 +2662,19 @@ static int mvneta_open(struct net_device *dev)
> >  		goto err_cleanup_txqs;
> >  	}
> >  
> > +	/*
> > +	 * Even though the documentation says that request_percpu_irq
> > +	 * doesn't enable the interrupts automatically, it actually
> > +	 * does so on the local CPU.
> > +	 *
> > +	 * Make sure it's disabled.
> > +	 */
> > +	disable_percpu_irq(pp->dev->irq);
> > +
> > +	/* Enable per-CPU interrupt on the one CPU we care about */
> > +	smp_call_function_single(rxq_def % num_online_cpus(),
> > +				 mvneta_percpu_enable, pp, true);
> 
> What happens if that CPU goes offline through CPU hotplug?

I just tried : if I start mvneta with "rxq_def=1", then my irq runs on
CPU1. Then I offline CPU1 and the irqs are automatically handled by CPU0.
Then I online CPU1 and irqs stay on CPU0.

More or less related, I found that if I enable a queue number larger than
the CPU count it does work, but then the system complains during rmmod :

[  877.146203] ------------[ cut here ]------------
[  877.146227] WARNING: CPU: 1 PID: 1731 at fs/proc/generic.c:552 remove_proc_entry+0x144/0x15c()
[  877.146233] remove_proc_entry: removing non-empty directory 'irq/29', leaking at least 'mvneta'
[  877.146238] Modules linked in: mvneta(-) [last unloaded: mvneta]
[  877.146254] CPU: 1 PID: 1731 Comm: rmmod Tainted: G        W       4.1.1-mvebu-00006-g3d317ed-dirty #5
[  877.146260] Hardware name: Marvell Armada 370/XP (Device Tree)
[  877.146281] [<c0017194>] (unwind_backtrace) from [<c00126d4>] (show_stack+0x10/0x14)
[  877.146293] [<c00126d4>] (show_stack) from [<c04d32e4>] (dump_stack+0x74/0x90)
[  877.146305] [<c04d32e4>] (dump_stack) from [<c0025200>] (warn_slowpath_common+0x74/0xb0)
[  877.146315] [<c0025200>] (warn_slowpath_common) from [<c00252d0>] (warn_slowpath_fmt+0x30/0x40)
[  877.146325] [<c00252d0>] (warn_slowpath_fmt) from [<c0115694>] (remove_proc_entry+0x144/0x15c)
[  877.146336] [<c0115694>] (remove_proc_entry) from [<c0060fd4>] (unregister_irq_proc+0x8c/0xb0)
[  877.146347] [<c0060fd4>] (unregister_irq_proc) from [<c0059f84>] (free_desc+0x28/0x58)
[  877.146356] [<c0059f84>] (free_desc) from [<c005a028>] (irq_free_descs+0x44/0x80)
[  877.146368] [<c005a028>] (irq_free_descs) from [<bf015748>] (mvneta_remove+0x3c/0x4c [mvneta])
[  877.146382] [<bf015748>] (mvneta_remove [mvneta]) from [<c024d6e8>] (platform_drv_remove+0x18/0x30)
[  877.146393] [<c024d6e8>] (platform_drv_remove) from [<c024bd50>] (__device_release_driver+0x70/0xe4)
[  877.146402] [<c024bd50>] (__device_release_driver) from [<c024c5b8>] (driver_detach+0xcc/0xd0)
[  877.146411] [<c024c5b8>] (driver_detach) from [<c024bbe0>] (bus_remove_driver+0x4c/0x90)
[  877.146425] [<c024bbe0>] (bus_remove_driver) from [<c007d3f0>] (SyS_delete_module+0x164/0x1b4)
[  877.146437] [<c007d3f0>] (SyS_delete_module) from [<c000f4c0>] (ret_fast_syscall+0x0/0x3c)
[  877.146443] ---[ end trace 48713a9ae31204b1 ]---

This was on the AX3 (dual-proc) with rxq_def=2.

Hoping this helps,
Willy
