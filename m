From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: softirq warnings when calling dev_kfree_skb_irq - bug in conntrack?
Date: Mon, 02 Aug 2010 11:54:46 -0700
Message-ID: <4C571476.7070301@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Xu, Dongxiao" <dongxiao.xu@intel.com>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:34883 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754170Ab0HBSys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 14:54:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi,

I'm seeing this in the current linux-next tree:

------------[ cut here ]------------
WARNING: at kernel/softirq.c:143 local_bh_enable+0x40/0x87()
Modules linked in: xt_state dm_mirror dm_region_hash dm_log microcode [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper Not tainted 2.6.35-rc6-next-20100729+ #29
Call Trace:
  <IRQ>   [<ffffffff81030de3>] warn_slowpath_common+0x80/0x98
  [<ffffffff81030e10>] warn_slowpath_null+0x15/0x17
  [<ffffffff81035ff3>] local_bh_enable+0x40/0x87
  [<ffffffff814236e5>] destroy_conntrack+0x78/0x9e
  [<ffffffff810bea55>] ? __kmalloc_track_caller+0xc3/0x135
  [<ffffffff814203b4>] nf_conntrack_destroy+0x16/0x18
  [<ffffffff813fadee>] skb_release_head_state+0x97/0xd9
  [<ffffffff813fabbe>] __kfree_skb+0x11/0x7a
  [<ffffffff813fac4e>] consume_skb+0x27/0x29
  [<ffffffff81402d3a>] dev_kfree_skb_irq+0x18/0x62
  [<ffffffff8130a762>] xennet_tx_buf_gc+0xfc/0x192
  [<ffffffff8130a8fb>] smart_poll_function+0x50/0x121
  [<ffffffff8130a8ab>] ? smart_poll_function+0x0/0x121
  [<ffffffff8104b8d1>] __run_hrtimer+0xcc/0x127
  [<ffffffff8104bad3>] hrtimer_interrupt+0x9c/0x17b
  [<ffffffff81005f24>] xen_timer_interrupt+0x2a/0x13e
  [<ffffffff81006180>] ? check_events+0x12/0x22
  [<ffffffff81005be9>] ? xen_force_evtchn_callback+0xd/0xf
  [<ffffffff81005be9>] ? xen_force_evtchn_callback+0xd/0xf
  [<ffffffff81077641>] handle_IRQ_event+0x52/0x119
  [<ffffffff81079abe>] handle_level_irq+0x6c/0xb2
  [<ffffffff8127b3dd>] __xen_evtchn_do_upcall+0xa9/0x12a
  [<ffffffff8100616d>] ? xen_restore_fl_direct_end+0x0/0x1
  [<ffffffff8127b491>] xen_evtchn_do_upcall+0x28/0x39
  [<ffffffff810097ac>] xen_do_hypervisor_callback+0x1c/0x30
  <EOI>   [<ffffffff810013aa>] ? hypercall_page+0x3aa/0x1000
  [<ffffffff810013aa>] ? hypercall_page+0x3aa/0x1000
  [<ffffffff81005c2d>] ? xen_safe_halt+0x10/0x1a
  [<ffffffff81003eb4>] ? xen_idle+0x38/0x44
  [<ffffffff81007de4>] ? cpu_idle+0x82/0xe9
  [<ffffffff814b84e3>] ? rest_init+0x67/0x69
  [<ffffffff81afcc10>] ? start_kernel+0x387/0x392
  [<ffffffff81afc2c8>] ? x86_64_start_reservations+0xb3/0xb7
  [<ffffffff81affed2>] ? xen_start_kernel+0x4be/0x4c2
---[ end trace 755676650ea49003 ]---


The warning is:

	WARN_ON_ONCE(in_irq() || irqs_disabled());


It seems the basic problem is that xennet_tx_buf_gc() is being called in 
interrupt context - with smartpoll it's from the timer interrupt, but 
even without it is being called from xennet_interrupt(), which in turn 
calls dev_kfree_skb_irq().

Since this should be perfectly OK, it appears the problem is actually in 
conntrack.  I'm not sure where this bug started happening, but its 
relatively recently I think.

Thanks,
     J
