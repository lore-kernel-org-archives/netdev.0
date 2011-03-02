From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: skb->frag_list != NULL in start_xmit for device without
 NETIF_F_FRAGLIST
Date: Wed, 2 Mar 2011 17:42:29 +0000
Message-ID: <1299087749.17907.1792.camel@zakaz.uk.xensource.com>
References: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
	 <AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
	 <1299071546.17907.1755.camel@zakaz.uk.xensource.com>
	 <1299071683.17907.1764.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>, <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:13470 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063Ab1CBRmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 12:42:32 -0500
In-Reply-To: <1299071683.17907.1764.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 13:14 +0000, Ian Campbell wrote:
> On Wed, 2011-03-02 at 13:12 +0000, Ian Campbell wrote:
> > 
> > > I believe that not much has changed in this regard between 2.6.32
> > and net-next.
> > 
> > It turns out I cannot reproduce with either 2.6.32 (pvops xen.git) or
> > a more recent ((26.38-rc) kernel. The kernel where we see this is the
> > XCP kernel which is a 2.6.32 based thing derived from SLES11SP1 + XCP
> > specific updates.
> 
> Paul reminded me that his XCP system where we see this is running
> openvswitch not bridging (all my own tests were with bridging), is this
> something which could be caused by vswitch at all? I don't see any
> interesting ->frag_list usage in openvswitch.git.
> 
> Anyway I'm going to see if I can repro with vswitch.

It seems that was the key.

Using openvswitch.git aae3743bf24cd0e14be726c774a0be49ff0459d7 on top of
2.6.38-rc7 (+ some Xen stuff from linux-next and my netback branch). I
added:
	WARN_ONCE(skb_shinfo(skb)->frag_list, "skb %p has a frag list\n", skb)
to netback's start_xmit and saw it trigger (full trace below).

I've added ovs-dev, you guys can see the complete thread at
http://thread.gmane.org/gmane.linux.network/187720 . The gist is that we
are seeing skb's passed to a driver's start_xmit which have a
->frag_list despite not advertising NETIF_F_FRAGLIST. The netback device
has GSO but not TSO enabled.

(aae3743bf24cd0e14be726c774a0be49ff0459d7 is from the end of January but
it does appear to be the current master, I guess it's a recently rebased
+pushed old commit).

Cheers,
Ian.

------------[ cut here ]------------
WARNING: at /local/scratch/ianc/devel/kernels/linux-2.6/drivers/net/xen-netback/interface.c:84 xenvif_start_xmit+0x109/0x120()
Hardware name: PowerEdge 860
skb cfa14c80 has a frag list
Modules linked in: openvswitch_mod
Pid: 0, comm: swapper Not tainted 2.6.38-rc7-x86_32p-xen0-00190-g0716c28-dirty #375
Call Trace:
 [<c12bfbf9>] ? xenvif_start_xmit+0x109/0x120
 [<c103f17c>] ? warn_slowpath_common+0x6c/0xa0
 [<c12bfbf9>] ? xenvif_start_xmit+0x109/0x120
 [<c103f22e>] ? warn_slowpath_fmt+0x2e/0x30
 [<c12bfbf9>] ? xenvif_start_xmit+0x109/0x120
 [<c13500d4>] ? dev_hard_start_xmit+0x2c4/0x5a0
 [<c134fe58>] ? dev_hard_start_xmit+0x48/0x5a0
 [<c13639ec>] ? sch_direct_xmit+0x12c/0x230
 [<c142be5a>] ? _raw_spin_lock+0x3a/0x40
 [<c13505de>] ? dev_queue_xmit+0x22e/0x7a0
 [<c13503b0>] ? dev_queue_xmit+0x0/0x7a0
 [<f8c77ab7>] ? netdev_send+0x17/0x20 [openvswitch_mod]
 [<f8c755a0>] ? vport_send+0x40/0x100 [openvswitch_mod]
 [<c100790a>] ? xen_force_evtchn_callback+0x1a/0x30
 [<c10080f0>] ? xen_restore_fl_direct+0x0/0x17
 [<f8c6d70b>] ? execute_actions+0x62b/0x7f0 [openvswitch_mod]
 [<c106b0d2>] ? mark_held_locks+0x62/0x80
 [<c106b3f2>] ? trace_hardirqs_on_caller+0xa2/0x1f0
 [<f8c726b3>] ? flow_used+0x63/0x90 [openvswitch_mod]
 [<c1044fb4>] ? local_bh_enable_ip+0xa4/0x110
 [<c142c5b5>] ? _raw_spin_unlock_bh+0x25/0x30
 [<f8c726b3>] ? flow_used+0x63/0x90 [openvswitch_mod]
 [<f8c6f0aa>] ? dp_process_received_packet+0x8a/0x200 [openvswitch_mod]
 [<c10450b6>] ? local_bh_enable+0x96/0x110
 [<c106b3f2>] ? trace_hardirqs_on_caller+0xa2/0x1f0
 [<f8c756ec>] ? vport_receive+0x8c/0xa0 [openvswitch_mod]
 [<f8c756a7>] ? vport_receive+0x47/0xa0 [openvswitch_mod]
 [<f8c77bcf>] ? netdev_frame_hook+0xaf/0xe0 [openvswitch_mod]
 [<c134dff5>] ? __netif_receive_skb+0x185/0x340
 [<c134dee2>] ? __netif_receive_skb+0x72/0x340
 [<c1008114>] ? check_events+0x8/0xc
 [<f8c77b20>] ? netdev_frame_hook+0x0/0xe0 [openvswitch_mod]
 [<c134edbb>] ? netif_receive_skb+0xcb/0xe0
 [<c134ed0a>] ? netif_receive_skb+0x1a/0xe0
 [<c134ef0f>] ? napi_gro_complete+0x3f/0x110
 [<c134ef18>] ? napi_gro_complete+0x48/0x110
 [<c134f140>] ? dev_gro_receive+0x160/0x280
 [<c134f057>] ? dev_gro_receive+0x77/0x280
 [<c134f41b>] ? napi_gro_receive+0xcb/0xe0
 [<c12aae75>] ? tg3_poll_work+0x5e5/0xda0
 [<c106b0d2>] ? mark_held_locks+0x62/0x80
 [<c100790a>] ? xen_force_evtchn_callback+0x1a/0x30
 [<c100790a>] ? xen_force_evtchn_callback+0x1a/0x30
 [<c10080f0>] ? xen_restore_fl_direct+0x0/0x17
 [<c1008114>] ? check_events+0x8/0xc
 [<c100810b>] ? xen_restore_fl_direct_end+0x0/0x1
 [<c100790a>] ? xen_force_evtchn_callback+0x1a/0x30
 [<c10080f0>] ? xen_restore_fl_direct+0x0/0x17
 [<c11d08f0>] ? xen_swiotlb_unmap_page+0x0/0x20
 [<c142c5f1>] ? _raw_spin_unlock_irq+0x31/0x40
 [<c12ab714>] ? tg3_poll+0x44/0x1d0
 [<c134f5fc>] ? net_rx_action+0xcc/0x1a0
 [<c134f5fc>] ? net_rx_action+0xcc/0x1a0
 [<c1044dbf>] ? __do_softirq+0x9f/0x170
 [<c1044d20>] ? __do_softirq+0x0/0x170
 <IRQ>  [<c1003640>] ? xen_cpuid+0x0/0xa0
 [<c1044b45>] ? irq_exit+0x65/0x90
 [<c11c5800>] ? xen_evtchn_do_upcall+0x20/0x30
 [<c100bc2f>] ? xen_do_upcall+0x7/0xc
 [<c1003640>] ? xen_cpuid+0x0/0xa0
 [<c10023a7>] ? hypercall_page+0x3a7/0x1010
 [<c10079f2>] ? xen_safe_halt+0x12/0x30
 [<c1003640>] ? xen_cpuid+0x0/0xa0
 [<c1012d30>] ? default_idle+0x40/0xa0
 [<c100a769>] ? cpu_idle+0x59/0xa0
 [<c1408d71>] ? rest_init+0xa1/0xb0
 [<c1408cd0>] ? rest_init+0x0/0xb0
 [<c10080e0>] ? xen_save_fl_direct+0x0/0xd
 [<c1613a25>] ? start_kernel+0x37c/0x399
 [<c1613467>] ? unknown_bootoption+0x0/0x1f1
 [<c16130b7>] ? i386_start_kernel+0xa6/0xe2
 [<c161676a>] ? xen_start_kernel+0x5fc/0x6b2
---[ end trace 877717720328b880 ]---


