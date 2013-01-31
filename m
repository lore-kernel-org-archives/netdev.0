From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx
 path
Date: Thu, 31 Jan 2013 09:48:26 +0800
Message-ID: <1359596906.29117.9.camel@cr0>
References: <1359535089-18348-1-git-send-email-amwang@redhat.com>
	 <CAEP_g=-pdossS=kAVzQMuvTnKU-Sg9PvskiocqcxdsBDtbvdCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab3AaBsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 20:48:35 -0500
In-Reply-To: <CAEP_g=-pdossS=kAVzQMuvTnKU-Sg9PvskiocqcxdsBDtbvdCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 13:54 -0800, Jesse Gross wrote:
> On Wed, Jan 30, 2013 at 12:38 AM, Cong Wang <amwang@redhat.com> wrote:
> > From: Cong Wang <amwang@redhat.com>
> >
> > skb_gso_segment() is almost always called in tx path,
> > except for openvswitch. It calls this function when
> > it receives the packet and tries to queue it to user-space.
> > In this special case, the ->ip_summed check inside
> > skb_gso_segment() is no longer true, as ->ip_summed value
> > has different meanings on rx path.
> 
> I don't think that this is really specific to Open vSwitch - it's
> possible that skb_gso_segment() could be called in the transmit path
> after bridging.  I also don't really think that it is true any more
> that the meaning of skb->ip_summed is different on receive vs.
> transmit paths (this was definitely not the case in the past).
> However, it's certainly possible to see different types of packets.

Take a look at the fat comment in include/linux/skbuff.h, unless it is
out-of-date.

> 
> > This patch adjusts skb_gso_segment() so that we can at least
> > avoid such warnings on checksum.
> 
> When do you see GSO packets with CHECKSUM_NONE on receive?

I see CHECKSUM_UNCESSARY set by ixgbe driver or CHECKSUM_PARTIAL set by
gro. According to comments in include/linux/skbuff.h, CHECKSUM_NONE is
set when device is not able to do checksum, it is not my case. The full
backtrace below is the one I got on RHEL6 kernel:

WARNING: at net/core/dev.c:1760 skb_gso_segment+0x1df/0x2b0() (Not
tainted) 
Hardware name: ProLiant DL580 G7 
802.1Q VLAN Support: caps=(0x190833, 0x0) len=1500 data_len=1448
ip_summed=1 
Modules linked in: bonding 8021q garp stp llc openvswitch sunrpc
cpufreq_ondemand freq_table pcc_cpufreq ipv6 power_meter qlcnic cxgb4
be2net ixgbe dca ptp pps_core mdio netxen_nic mlx4_core microcode
serio_raw iTCO_wdt iTCO_vendor_support hpilo hpwdt sg i7core_edac
edac_core shpchp ext4 mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif
pata_acpi ata_generic ata_piix hpsa radeon ttm drm_kms_helper drm
i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod [last
unloaded: llc] 
Pid: 0, comm: swapper Not tainted 2.6.32-356.el6.x86_64 #1 
Call Trace: 
 <IRQ>  [<ffffffff8106e2e7>] ? warn_slowpath_common+0x87/0xc0 
 [<ffffffff8106e3d6>] ? warn_slowpath_fmt+0x46/0x50 
 [<ffffffff81439084>] ? sock_def_readable+0x44/0x80 
 [<ffffffff8144871f>] ? skb_gso_segment+0x1df/0x2b0 
 [<ffffffffa043f92e>] ? queue_gso_packets+0x4e/0x1d0 [openvswitch] 
 [<ffffffffa0443558>] ? ovs_flow_extract+0x6a8/0xa80 [openvswitch] 
 [<ffffffffa043fb0d>] ? ovs_dp_upcall+0x5d/0xb0 [openvswitch] 
 [<ffffffffa043fc8e>] ? ovs_dp_process_received_packet+0x12e/0x140
[openvswitch] 
 [<ffffffffa0443a30>] ? ovs_vport_receive+0x30/0x40 [openvswitch] 
 [<ffffffffa0444893>] ? ovs_netdev_frame_hook+0x83/0xac [openvswitch] 
 [<ffffffff814482aa>] ? __netif_receive_skb+0x60a/0x750 
 [<ffffffff8144a528>] ? netif_receive_skb+0x58/0x60 
 [<ffffffff8144a630>] ? napi_skb_finish+0x50/0x70 
 [<ffffffff814e7024>] ? vlan_gro_receive+0x84/0xa0 
 [<ffffffffa030c08e>] ? ixgbe_poll+0x6ae/0x1280 [ixgbe] 
 [<ffffffff810e3d48>] ? handle_edge_irq+0x98/0x180 
 [<ffffffff8144ccf3>] ? net_rx_action+0x103/0x2f0 
 [<ffffffff81076fb1>] ? __do_softirq+0xc1/0x1e0 
 [<ffffffff810e1640>] ? handle_IRQ_event+0x60/0x170 
 [<ffffffff8100c1cc>] ? call_softirq+0x1c/0x30 
 [<ffffffff8100de05>] ? do_softirq+0x65/0xa0 
 [<ffffffff81076d95>] ? irq_exit+0x85/0x90 
 [<ffffffff81516c45>] ? do_IRQ+0x75/0xf0 
 [<ffffffff8100b9d3>] ? ret_from_intr+0x0/0x11 
 <EOI>  [<ffffffff810a871d>] ? tick_nohz_restart_sched_tick+0x16d/0x190 
 [<ffffffff810a870f>] ? tick_nohz_restart_sched_tick+0x15f/0x190 
 [<ffffffff81009f90>] ? cpu_idle+0x80/0x110 
 [<ffffffff81009ff9>] ? cpu_idle+0xe9/0x110 
 [<ffffffff814f2eda>] ? rest_init+0x7a/0x80 
 [<ffffffff81c27f7b>] ? start_kernel+0x424/0x430 
 [<ffffffff81c2733a>] ? x86_64_start_reservations+0x125/0x129 
 [<ffffffff81c27438>] ? x86_64_start_kernel+0xfa/0x109 
---[ end trace 84ef9bd9ae5d9360 ]--- 


> 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index a87bc74..f6e7b3f 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2347,7 +2356,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
> >         rcu_read_lock();
> >         list_for_each_entry_rcu(ptype, &offload_base, list) {
> >                 if (ptype->type == type && ptype->callbacks.gso_segment) {
> > -                       if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
> > +                       if (unlikely(skb_needs_check(skb))) {
> >                                 err = ptype->callbacks.gso_send_check(skb);
> >                                 segs = ERR_PTR(err);
> >                                 if (err || skb_gso_ok(skb, features))
> 
> Even if we don't warn we likely still need to fix the checksum.

By calling skb_checksum_complete()? My initial version patch had it, but
it didn't work.

> 
> > diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> > index d8c13a9..0b75964 100644
> > --- a/net/openvswitch/datapath.c
> > +++ b/net/openvswitch/datapath.c
> > @@ -302,7 +302,7 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
> >         int err;
> >
> >         segs = skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM);
> > -       if (IS_ERR(segs))
> > +       if (IS_ERR_OR_NULL(segs))
> >                 return PTR_ERR(segs);
> 
> In what case would we expect that NULL is returned here?


BUG: unable to handle kernel NULL pointer dereference at
00000000000000b9 
IP: [<ffffffffa043f581>] queue_userspace_packet+0x21/0x380
[openvswitch] 
PGD 0  
Oops: 0000 [#1] SMP  
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:03.0/irq 
CPU 0  
Modules linked in: bonding 8021q garp stp llc openvswitch sunrpc
cpufreq_ondemand freq_table pcc_cpufreq ipv6 power_meter qlcnic cxgb4
be2net ixgbe dca ptp pps_core mdio netxen_nic mlx4_core microcode
serio_raw iTCO_wdt iTCO_vendor_support hpilo hpwdt sg i7core_edac
edac_core shpchp ext4 mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif
pata_acpi ata_generic ata_piix hpsa radeon ttm drm_kms_helper drm
i2c_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod [last
unloaded: llc] 
 
Pid: 0, comm: swapper Tainted: G        W  ---------------
2.6.32-356.el6.x86_64 #1 HP ProLiant DL580 G7 
RIP: 0010:[<ffffffffa043f581>]  [<ffffffffa043f581>]
queue_userspace_packet+0x21/0x380 [openvswitch] 
RSP: 0018:ffff88002f6039d0  EFLAGS: 00010282 
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff880228c58422 
RDX: ffff88002f603b70 RSI: 0000000000000000 RDI: 0000000000000060 
RBP: ffff88002f603a40 R08: ffffffff81c07728 R09: 0000000000000040 
R10: 000000000000000f R11: 0000000000000008 R12: 0000000000000000 
R13: ffff88002f603b70 R14: 0000000000000060 R15: 0000000000000000 
FS:  0000000000000000(0000) GS:ffff88002f600000(0000)
knlGS:0000000000000000 
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b 
CR2: 00000000000000b9 CR3: 0000000001a85000 CR4: 00000000000007f0 
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
Process swapper (pid: 0, threadinfo ffffffff81a00000, task
ffffffff81a8d020) 
Stack: 
 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
<d> 0000000000000000 0000000000000000 0000000200000000 0241c7121a501498 
<d> ffff880000031dd8 0000000000000000 0000000000000000 ffff88002f603b70 
Call Trace: 
 <IRQ>  
 [<ffffffffa043f96a>] queue_gso_packets+0x8a/0x1d0 [openvswitch] 
 [<ffffffffa0443558>] ? ovs_flow_extract+0x6a8/0xa80 [openvswitch] 
 [<ffffffffa043fb0d>] ovs_dp_upcall+0x5d/0xb0 [openvswitch] 
 [<ffffffffa043fc8e>] ovs_dp_process_received_packet+0x12e/0x140
[openvswitch] 
 [<ffffffffa0443a30>] ovs_vport_receive+0x30/0x40 [openvswitch] 
 [<ffffffffa0444893>] ovs_netdev_frame_hook+0x83/0xac [openvswitch] 
 [<ffffffff814482aa>] __netif_receive_skb+0x60a/0x750 
 [<ffffffff8144a528>] netif_receive_skb+0x58/0x60 
 [<ffffffff8144a630>] napi_skb_finish+0x50/0x70 
 [<ffffffff814e7024>] vlan_gro_receive+0x84/0xa0 
 [<ffffffffa030c08e>] ixgbe_poll+0x6ae/0x1280 [ixgbe] 
 [<ffffffff810e3d48>] ? handle_edge_irq+0x98/0x180 
 [<ffffffff8144ccf3>] net_rx_action+0x103/0x2f0 
 [<ffffffff81076fb1>] __do_softirq+0xc1/0x1e0 
 [<ffffffff810e1640>] ? handle_IRQ_event+0x60/0x170 
 [<ffffffff8100c1cc>] call_softirq+0x1c/0x30 
 [<ffffffff8100de05>] do_softirq+0x65/0xa0 
 [<ffffffff81076d95>] irq_exit+0x85/0x90 
 [<ffffffff81516c45>] do_IRQ+0x75/0xf0 
 [<ffffffff8100b9d3>] ret_from_intr+0x0/0x11 
 <EOI>  
 [<ffffffff810a871d>] ? tick_nohz_restart_sched_tick+0x16d/0x190 
 [<ffffffff810a870f>] ? tick_nohz_restart_sched_tick+0x15f/0x190 
 [<ffffffff81009f90>] ? cpu_idle+0x80/0x110 
 [<ffffffff81009ff9>] cpu_idle+0xe9/0x110 
 [<ffffffff814f2eda>] rest_init+0x7a/0x80 
 [<ffffffff81c27f7b>] start_kernel+0x424/0x430 
 [<ffffffff81c2733a>] x86_64_start_reservations+0x125/0x129 
 [<ffffffff81c27438>] x86_64_start_kernel+0xfa/0x109 
