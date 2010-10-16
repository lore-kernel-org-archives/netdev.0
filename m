From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] bonding: various fixes for bonding, netpoll & netconsole
 (v2)
Date: Fri, 15 Oct 2010 21:45:19 -0300
Message-ID: <20101016003831.GM2754@redhat.com>
References: <1286973334-4339-1-git-send-email-nhorman@tuxdriver.com>
 <20101015234115.GB2747@redhat.com>
 <20101016000634.GA6986@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net,
	amwang@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab0JPApq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 20:45:46 -0400
Content-Disposition: inline
In-Reply-To: <20101016000634.GA6986@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 08:06:34PM -0400, Neil Horman wrote:
> On Fri, Oct 15, 2010 at 08:41:15PM -0300, Flavio Leitner wrote:
> > On Wed, Oct 13, 2010 at 08:35:29AM -0400, nhorman@tuxdriver.com wrote:
> > > Version 2, taking teh following changes into account:
> > > 
> > > 1) Moved tx blocking/checking macros to netpoll.h as suggested by amwang
> > > 
> > > 2) Added tx blocking macro calls to sysfs paths, as they can deadlock in the
> > > same way that the link monitoring paths can.
> > > 
> > > Summary: 
> > > A while ago we tried to enable netpoll on the bonding driver to enable
> > > netconsole.  That worked well in a steady state, but deadlocked frequently in
> > > failover conditions due to some recursive lock-taking (as well as a few other
> > > problems).  I've gone through the driver, netconsole and netpoll code, fixed up
> > > those deadlocks, and confirmed that, with this patch series, we can use
> > > netconsole on bonding without deadlock in all bonding modes with all slaves,
> > > even accross failovers.  I've also fixed up some incidental bugs that I ran
> > > across while looking through this code, as described in individual patches
> > > 
> > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > 
> > I've tested these patch series and found this:
> > 
> > netconsole: network logging started
> > bonding: bond0: making interface eth0 the new active one.
> > ------------[ cut here ]------------
> > WARNING: at kernel/softirq.c:143 _local_bh_enable_ip+0x4e/0xd7()
> > Hardware name: Precision WorkStation 490    
> > Modules linked in: netconsole configfs sunrpc bonding ip6t_REJECT
> > nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 p4_clockmod freq_table
> > speedstep_lib dm_multipath uinput snd_hda_codec_idt snd_hda_intel
> > snd_hda_codec snd_hwdep snd_seq snd_seq_device i5k_amb snd_pcm hwmon
> > i5000_edac snd_timer edac_core e1000 snd ppdev parport_pc iTCO_wdt
> > parport iTCO_vendor_support soundcore tg3 dcdbas pcspkr shpchp i2c_i801
> > serio_raw snd_page_alloc nouveau ttm drm_kms_helper drm i2c_algo_bit
> > video output i2c_core [last unloaded: netconsole]
> > Pid: 8, comm: kworker/1:0 Not tainted 2.6.36-rc7+ #26
> > Call Trace:
> >  [<ffffffff810510c5>] warn_slowpath_common+0x85/0x9d
> >  [<ffffffff813cfcf2>] ? rcu_read_unlock_bh+0x26/0x28
> >  [<ffffffff810510f7>] warn_slowpath_null+0x1a/0x1c
> >  [<ffffffff810574fa>] _local_bh_enable_ip+0x4e/0xd7
> >  [<ffffffff810575a5>] local_bh_enable+0x12/0x14 <-- enabling again
> >  [<ffffffff813cfcf2>] rcu_read_unlock_bh+0x26/0x28
> >  [<ffffffff813d08a1>] dev_queue_xmit+0x363/0x375
> >  [<ffffffff813d053e>] ? dev_queue_xmit+0x0/0x375
> >  [<ffffffffa028c1e0>] bond_dev_queue_xmit+0xbe/0xdb [bonding]
> >  [<ffffffffa028c46e>] bond_start_xmit+0x271/0x4df [bonding]
> >  [<ffffffff813e0a15>] queue_process+0xcd/0x18a <- interrupts disabled
> >  [<ffffffff813e0948>] ? queue_process+0x0/0x18a
> >  [<ffffffff810673cf>] process_one_work+0x216/0x37d
> >  [<ffffffff81067344>] ? process_one_work+0x18b/0x37d
> >  [<ffffffff8106920d>] ? manage_workers+0x10b/0x195
> >  [<ffffffff810693d8>] worker_thread+0x141/0x21e
> >  [<ffffffff81069297>] ? worker_thread+0x0/0x21e
> >  [<ffffffff8106c988>] kthread+0x9d/0xa5
> >  [<ffffffff8100aaa4>] kernel_thread_helper+0x4/0x10
> >  [<ffffffff8147f950>] ? restore_args+0x0/0x30
> >  [<ffffffff8106c8eb>] ? kthread+0x0/0xa5
> >  [<ffffffff8100aaa0>] ? kernel_thread_helper+0x0/0x10
> > ---[ end trace 55688f5173e9b393 ]---
> > e1000: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> > bonding: bond0: link status definitely up for interface eth1.
> > 0)
> > 
> > It happens because queue_process() disables the local
> > interrupts before call ->ndo_start_xmit() and then
> > dev_queue_xmit() will enable them back.
> > 
> > I have CONFIG_TRACE_IRQFLAGS=y on my .config.
> > 
> Well, you look to be correct, although I'm not sure why you're replying to this
> thread to note the condition.  This patch series doesn't change any of that
> code (although it does make use of the existing function).  This problem could
> just as easily happen to any driver that returns NETDEV_TX_BUSY in response to a
> netpoll transmit, or anytime a netpoll gets blocked because the xmit_lock is
> already held or the tx queue is stopped.  Can you please write a patch to fix
> it?

Hm, right. I had disabled netconsole before and didn't notice that until
now testing your patch series.

Other than that the patches look okay and work out on my tests.
nice work, thanks

Acked-by: Flavio Leitner <fleitner@redhat.com>

-- 
Flavio
