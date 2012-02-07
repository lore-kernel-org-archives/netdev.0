From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: Sudden kernel panic with skge in 3.3-rc2
Date: Mon, 6 Feb 2012 19:11:27 -0500
Message-ID: <CAP=VYLp6Kh7OtN0nsTBDkvTvNLMV0jymAmbR0tJX4r-yMdTSQA@mail.gmail.com>
References: <20120202192115.GA8480@elliptictech.com>
	<20120202124529.3e274223@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:65515 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065Ab2BGAL2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:11:28 -0500
In-Reply-To: <20120202124529.3e274223@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 3:45 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:

[...]

>
> Try reverting this commit, it seems problematic
> commit d0249e44432aa0ffcf710b64449b8eaa3722547e
> Author: stephen hemminger <shemminger@vyatta.com>
> Date: =A0 Thu Jan 19 14:37:18 2012 +0000
>
> =A0 =A0skge: check for PCI dma mapping errors
>

I'm seeing similar issues, and a revert of the above caused the
problems to go away.  I'm testing on a baseline of net-next
as of today (3238a9be4d7a) plus some TIPC patches I was
trying to test (which are 99.9% unrelated to this, I'm sure).

Details captured from serial console are below.  100% reproducible.

I can probably try a test/debug patch for you if need be.

Paul.

---

00:09.0 Ethernet controller: 3Com Corporation 3c940 10/100/1000Base-T
[Marvell] (rev 12)
(right on motherboard, older AMD platform with NVIDIA chipset)

[    1.698965] skge 0000:00:09.0: PCI: Disallowing DAC for device
[    1.704861] skge: 1.14 addr 0xef000000 irq 18 chip Yukon rev 1
[    1.711171] skge 0000:00:09.0: eth0: addr 00:0e:a6:71:ed:b4

These hw csum failure repeat on regular intervals:

[  162.830840] eth0: hw csum failure
[  162.831829] Pid: 0, comm: swapper/0 Not tainted 3.3.0-rc1+ #5
[  162.831829] Call Trace:
[  162.831829]  [<c16912bf>] ? printk+0x18/0x1a
[  162.831829]  [<c1515607>] netdev_rx_csum_fault+0x37/0x40
[  162.831829]  [<c1510dff>] __skb_checksum_complete_head+0x5f/0x70
[  162.831829]  [<c1510e1b>] __skb_checksum_complete+0xb/0x10
[  162.831829]  [<c1593332>] nf_ip_checksum+0x62/0x130
[  162.831829]  [<c15455d7>] udp_error+0xa7/0x260
[  162.831829]  [<c1598f27>] ? ipt_do_table+0x1e7/0x370
[  162.831829]  [<c1545530>] ? udp_print_tuple+0x40/0x40
[  162.831829]  [<c1540cf0>] nf_conntrack_in+0xc0/0x5f0
[  162.831829]  [<c1599955>] ? nf_nat_rule_find+0x85/0xa0
[  162.831829]  [<c1551a38>] ? ip_route_input_common+0x368/0xb20
[  162.831829]  [<c153fe69>] ? nf_conntrack_free+0x49/0x60
[  162.831829]  [<c153fe69>] ? nf_conntrack_free+0x49/0x60
[  162.831829]  [<c15538f0>] ? inet_del_protocol+0x30/0x30
[  162.831829]  [<c159432e>] ipv4_conntrack_in+0x1e/0x30
[  162.831829]  [<c153d1f3>] nf_iterate+0x63/0x90
[  162.831829]  [<c15538f0>] ? inet_del_protocol+0x30/0x30
[  162.831829]  [<c153d27a>] nf_hook_slow+0x5a/0x110
[  162.831829]  [<c15538f0>] ? inet_del_protocol+0x30/0x30
[  162.831829]  [<c1554265>] ip_rcv+0x235/0x310
[  162.831829]  [<c15538f0>] ? inet_del_protocol+0x30/0x30
[  162.831829]  [<c1517887>] __netif_receive_skb+0x477/0x530
[  162.831829]  [<c1518d22>] netif_receive_skb+0x22/0x80
[  162.831829]  [<c10077b8>] ? nommu_map_page+0x38/0x70
[  162.831829]  [<c1518ea7>] napi_skb_finish+0x37/0x50
[  162.831829]  [<c151937b>] napi_gro_receive+0xbb/0xd0
[  162.831829]  [<c13edc41>] skge_poll+0x381/0x690
[  162.831829]  [<c141d7e1>] ? usb_hcd_poll_rh_status+0xf1/0x120
[  162.831829]  [<c100a27d>] ? save_i387_fxsave+0x3d/0xa0
[  162.831829]  [<c151950d>] net_rx_action+0xed/0x1d0
[  162.831829]  [<c141deb0>] ? usb_add_hcd+0x6a0/0x6a0
[  162.831829]  [<c1034196>] __do_softirq+0x86/0x170
[  162.831829]  [<c1034110>] ? send_remote_softirq+0x30/0x30
[  162.831829]  <IRQ>  [<c103448e>] ? irq_exit+0x6e/0x90
[  162.831829]  [<c1004116>] ? do_IRQ+0x46/0xb0
[  162.831829]  [<c1034477>] ? irq_exit+0x57/0x90
[  162.831829]  [<c101ba64>] ? smp_apic_timer_interrupt+0x54/0x90
[  162.831829]  [<c169a2e9>] ? common_interrupt+0x29/0x30
[  162.831829]  [<c1009589>] ? default_idle+0x69/0x160
[  162.831829]  [<c100190f>] ? cpu_idle+0x5f/0xa0
[  162.831829]  [<c16729c8>] ? rest_init+0x58/0x60
[  162.831829]  [<c19136c5>] ? start_kernel+0x2db/0x2e1
[  162.831829]  [<c1913172>] ? loglevel+0x2b/0x2b
[  162.831829]  [<c1913075>] ? i386_start_kernel+0x75/0x79

root@asus-a7v600:~# cat /proc/net/dev
Inter-|   Receive                                                |  Tra=
nsmit
 face |bytes    packets errs drop fifo frame compressed
multicast|bytes    packets errs drop fifo colls carrier compressed
    lo:      88       1    0    0    0     0          0         0
 88       1    0    0    0     0       0          0
  sit0:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth0:  641588    6994    0    0    0     0          0      6957
8544      47    0    0    0     0       0          0
root@asus-a7v600:~#

This happens when I reboot it:

[ OK ] processes ended within 1 seconds....                            =
        d
 * Deconfiguring network interfaces...        [  402.315402] BUG: unabl=
e to han
le kernel NULL pointer dereference at 00000c78
[  402.316001] IP: [<c10c6c40>] pagevec_move_tail+0x30/0x30
[  402.316001] *pde =3D 00000000
[  402.316001] Oops: 0000 [#1] SMP
[  402.316001] Modules linked in:
[  402.316001]                                                         =
        r
[  402.316001] Pid: 4201, comm: ip Not tainted 3.3.0-rc1+ #2 System Man=
ufacture
 System Name/A7V600
[  402.316001] EIP: 0060:[<c10c6c40>] EFLAGS: 00010202 CPU: 0
[  402.316001] EIP is at put_page+0x0/0x40
[  402.316001] EAX: 00000c78 EBX: 00000001 ECX: f42ca640 EDX: 00000001
[  402.316001] ESI: f4164000 EDI: f4ff27e0 EBP: f419ba4c ESP: f419ba40
[  402.316001]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068           =
        0
[  402.316001] Process ip (pid: 4201, ti=3Df419a000 task=3Df6df44e0 tas=
k.ti=3Df419a00
)
[  402.316001] Stack:
[  402.316001]  c14c0c84 f4164000 f4164000 f419ba58 c14c0cf2 f4d5c000 f=
419ba68
14c0d96                                                                =
        0
[  402.316001]  f4d5c000 00000000 f419ba88 c13a0b3c 00000aa8 f4d72000 f=
4d72488
0000000                                                                =
        f
[  402.316001]  00000001 00000001 f419bab4 c13a2426 00001800 c17fea66 0=
0000000
4d72400
[  402.316001] Call Trace:
[  402.316001]  [<c14c0c84>] ? skb_release_data+0x54/0xb0
[  402.316001]  [<c14c0cf2>] __kfree_skb+0x12/0x90
[  402.316001]  [<c14c0d96>] consume_skb+0x26/0x60
[  402.316001]  [<c13a0b3c>] skge_rx_clean.clone.77+0x5c/0x80
[  402.316001]  [<c13a2426>] skge_down+0x3d6/0x4f0
[  402.316001]  [<c14c9f49>] __dev_close_many+0x69/0xb0
[  402.316001]  [<c139ee38>] ? skge_set_multicast+0x8/0x10
[  402.316001]  [<c14c9faf>] __dev_close+0x1f/0x30
[  402.316001]  [<c14ceaad>] __dev_change_flags+0x7d/0x150
[  402.316001]  [<c14cec1e>] dev_change_flags+0x1e/0x60
[  402.316001]  [<c14d9e37>] do_setlink+0x177/0x900
[  402.316001]  [<c122885f>] ? nla_parse+0x1f/0xa0
[  402.316001]  [<c10e1a54>] ? page_add_new_anon_rmap+0x74/0x90
[  402.316001]  [<c14daf19>] rtnl_newlink+0x359/0x530
[  402.316001]  [<c11d02fe>] ? selinux_capable+0x2e/0x40
[  402.316001]  [<c1037200>] ? sys_sysctl+0x100/0x1a0
[  402.316001]  [<c14da820>] rtnetlink_rcv_msg+0x140/0x290
[  402.316001]  [<c10eff24>] ? kmem_cache_alloc+0x24/0x100
[  402.316001]  [<c14c0cc0>] ? skb_release_data+0x90/0xb0
[  402.316001]  [<c14dabc0>] ? rtnl_configure_link+0x80/0x80
[  402.316001]  [<c14da6e0>] ? __rtnl_unlock+0x10/0x10
[  402.316001]  [<c14ef5ae>] netlink_rcv_skb+0x8e/0xb0
[  402.316001]  [<c14d8dd7>] rtnetlink_rcv+0x17/0x20
[  402.316001]  [<c14ef045>] netlink_unicast+0x175/0x1c0
[  402.316001]  [<c14ef271>] netlink_sendmsg+0x1e1/0x2e0
[  402.316001]  [<c14bb03f>] sock_sendmsg+0xdf/0x110
[  402.316001]  [<c1028f0e>] ? __kmap_atomic+0xe/0x10
[  402.316001]  [<c10c2470>] ? get_page_from_freelist+0x250/0x4a0
[  402.316001]  [<c121ca3f>] ? _copy_from_user+0x3f/0x60
[  402.316001]  [<c14c4903>] ? verify_iovec+0x53/0xb0
[  402.316001]  [<c14bb36d>] __sys_sendmsg+0x2ad/0x2c0
[  402.316001]  [<c10bc64d>] ? unlock_page+0x3d/0x40
[  402.316001]  [<c10d8cc8>] ? __do_fault+0x368/0x460
[  402.316001]  [<c10dafe0>] ? handle_pte_fault+0x80/0x690
[  402.316001]  [<c1227ef5>] ? __percpu_counter_add+0x75/0xa0
[  402.316001]  [<c10db693>] ? handle_mm_fault+0xa3/0x130
[  402.316001]  [<c14ba1d4>] ? sockfd_lookup_light+0x24/0x80
[  402.316001]  [<c14bc336>] sys_sendmsg+0x36/0x60
[  402.316001]  [<c14bc82b>] sys_socketcall+0xfb/0x2c0
[  402.316001]  [<c164da4c>] sysenter_do_call+0x12/0x22
