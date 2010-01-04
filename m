From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Mon, 4 Jan 2010 09:29:58 -0200
Message-ID: <20100104112957.GA2573@sysclose.org>
References: <1262183005-28406-1-git-send-email-fleitner@redhat.com>
 <20100103.215441.43026709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:57726 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab0ADLam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 06:30:42 -0500
Received: from homiemail-a17.g.dreamhost.com (caiajhbdcagg.dreamhost.com [208.97.132.66])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 0E81717DA03
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2010 03:30:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100103.215441.43026709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 03, 2010 at 09:54:41PM -0800, David Miller wrote:
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Wed, 30 Dec 2009 12:23:25 -0200
> 
> > Almost all igmp functions accessing inet->mc_list are protected by
> > rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
> > so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
> > remove an entry while ip_mc_sf_allow is running causing a crash.
> > 
> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> 
> Have you triggered this in practice or is this due purely
> to code inspection?

I had to modify the code to reproduce introducing a delay in 
ip_mc_sf_allow(), but a customer is able to reproduce it when
avahi-daemon runs at boot time.

CPU: Intel(R) Xeon(R) CPU X5570  @ 2.93GHz stepping 05

BUG: unable to handle kernel paging request at virtual address 005e0005
printing eip:
c05f2194
*pde = 00000000
Oops: 0000 [#1]
SMP
last sysfs file: /devices/pci0000:7f/0000:7f:06.0/irq
Modules linked in: nfs lockd fscache nfs_acl autofs4 hidp l2cap
bluetooth sunrpc 8021q ipv6 xfrm_nalgo crypto_api dm_multipath scsi_dh
video hwmon backlight sbs i2c_ec i2c_core but ton battery asus_acpi ac
parport_pc lp parport sg e1000(U) pcspkr dm_raid45 dm_message dm_
region_hash dm_mem_cache dm_snapshot dm_zero dm_mirror dm_log dm_mod
hfcldd(FU) sd_mod scs i_mod hfcldd_conf(U) hraslog_link(U) ext3 jbd
uhci_hcd ohci_hcd ehci_hcd
CPU:    0
EIP:    0060:[<c05f2194>]    Tainted: GF     VLI
EFLAGS: 00210202   (2.6.18-128.el5PAE #1)
EIP is at ip_mc_sf_allow+0x20/0x79
eax: 005e0001   ebx: f6cb9100   ecx: 00000008   edx: fb0000e0
esi: 5acb10ac   edi: f63414e9   ebp: f7ae3200   esp: c0732ea4
ds: 007b   es: 007b   ss: 0068
Process xlinpack_xeon32 (pid: 5194, ti=c0732000 task=cfd2daa0
task.ti=f5d30000)
Stack: f6cb9108 f6cb9100 c05ea1eb 00000008 d03e9034 5acb10ac fb0000e0 e9140000
      00000008 e91414e9 f7ae3200 c06ab4a8 00000000 00000000 c05ce1d5 f7ae3200
      00000000 f7ae3200 d03e9020 c05ce042 f7ae3200 c07d6988 c06ab560 00000008
Call Trace:
[<c05ea1eb>] udp_rcv+0x1f4/0x514
[<c05ce1d5>] ip_local_deliver+0x159/0x204
[<c05ce042>] ip_rcv+0x46f/0x4a9
[<c05b397d>] netif_receive_skb+0x30c/0x330
[<f8924be0>] e1000_clean_rx_irq+0xf0/0x3e0 [e1000]
[<f8924af0>] e1000_clean_rx_irq+0x0/0x3e0 [e1000]
[<f8922bd4>] e1000_clean+0xf4/0x340 [e1000]
[<c04074d6>] do_IRQ+0xb5/0xc3
[<c05b52d4>] net_rx_action+0x92/0x175
[<c042900f>] __do_softirq+0x87/0x114
[<c04073d7>] do_softirq+0x52/0x9c
[<c04059d7>] apic_timer_interrupt+0x1f/0x24
=======================
Code: 81 c4 8c 00 00 00 5b 5e 5f 5d c3 56 89 ce 53 89 c3 8b 4c 24 0c 89
d0 25 f0 00 00 00
3d e0 00 00 00 75 59 8b 83 84 01 00 00 eb 0c <39> 50 04 75 05 39 48 0c
74 08 8b 00 85 c0 75 f0 eb 3f 8b 50 14
EIP: [<c05f2194>] ip_mc_sf_allow+0x20/0x79 SS:ESP 0068:c0732ea4
<0>Kernel panic - not syncing: Fatal exception in interrupt
--- snip ---


> That new synchronize_rcu() is very expensive and will decrease
> the rate at which groups can be joined and left, _especially_
> on high cpu count machines.

Well, I tried using read-write locking but then the packet reception
was slower while another task was playing with multicasting groups.

Then, I tried using call_rcu() to avoid the problem you are saying,
but when you stop the reproducer, sk_free() will warn printing 
"optmem leakage.." because the rcu callback didn't run yet.


> I do not think it is therefore a suitable problem to this
> race, if it does in fact exist.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Flavio
