From: "SangOg Na" <nso@pentamedia.com>
Subject: Can I make ipv6 module inactive at my pentaval driver?
Date: Wed, 21 Jun 2006 14:41:32 +0900
Message-ID: <029d01c694f5$5d3d3ab0$3047efcb@nsowork>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_029A_01C69540.C9E4ABD0"
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.239.71.1] ([203.239.71.1]:64683 "EHLO ns.pentamedia.com")
	by vger.kernel.org with ESMTP id S1751113AbWFUFli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 01:41:38 -0400
Received: from nsowork ([203.239.71.48])
	(authenticated)
	by ns.pentamedia.com (8.11.6/8.11.6) with ESMTP id k5L5erh14170
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 14:40:54 +0900
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_029A_01C69540.C9E4ABD0
Content-Type: text/plain;
	format=flowed;
	charset="ks_c_5601-1987";
	reply-type=original
Content-Transfer-Encoding: 7bit

Hi!

I'm working for pentamedia in Korea.
My company makes one-way satellite receiver card whose name is pentavalue.
Pentavalue cards receive DVB-S packets and extract IP packets and
push them into TCP/IP stack.
pentavalue driver works in linux kernel 2.4.20.
I'm porting pentavalue driver to 2.6.17 kernel, but reference count problem 
occurs.
There is no code updating reference count in driver source.
I insert debug code in kernel source at dev_put and dev_hold
in include/linux/netdevice.h file.
 static inline void dev_put(struct net_device *dev)
 {
         atomic_dec(&dev->refcnt);
+        if (*(dev)->name=='p') {
+                printk("-%s- %d\n",dev->name,atomic_read(&dev->refcnt));
+                dump_stack();
+        }
 }

 static inline void dev_hold(struct net_device *dev)
 {
         atomic_inc(&dev->refcnt);
+        if (*(dev)->name=='p') {
+                printk("+%s+ %d\n",dev->name,atomic_read(&dev->refcnt));
+                dump_stack();
+        }
 }

I found ipv6 module notifier increase refcnt and not decrease refcnt.
refcnt increases by 3 when the device opens and closes using ifconfig.
I modified driver source for enabling rmmod by setting refcnt to 4 before 
cleanup module.
I will attach command log file. 

------=_NextPart_000_029A_01C69540.C9E4ABD0
Content-Type: application/octet-stream;
	name="pentaval.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="pentaval.log"


# modprobe pentaval
# dmesg -c

PentaVal_init_one: [bus:0x0,device:0x8,function:0x0]
PentaVal_init_one: =
[vender/device/subvendor/subdevice:0x109e,0x036e,0x15c8,0x0133]
PentaVal_init_board: MMIO region size:start 0xF7FFF000-> =
0xF7FFFFFF,len:0x1000
ACPI: PCI Interrupt 0000:00:08.0[A] -> GSI 16 (level, low) -> IRQ 20
PentaVal_init_board: Physical MMIO region start 0xF7FFF000
PentaVal_init_board: Virtual MMIO region start 0xDE87E000
PentaVal_init_one: PCI FN0 Physical start:0xF7FFF000
PentaVal_init_one: PCI FN0 Virtual start:0xDE87E000
PentaVal_init_one: [bus:0x0,device:0x8,function:0x1]
PentaVal_init_one: =
[vender/device/subvendor/subdevice:0x109e,0x0878,0x15c8,0x0133]
PentaVal_init_board: MMIO region size:start 0xF7FFE000-> =
0xF7FFEFFF,len:0x1000
ACPI: PCI Interrupt 0000:00:08.1[A] -> GSI 16 (level, low) -> IRQ 20
PentaVal_init_board: Physical MMIO region start 0xF7FFE000
PentaVal_init_board: Virtual MMIO region start 0xDEC24000
PentaVal_init_one: PCI FN1 Physical start:0xF7FFE000
PentaVal_init_one: PCI FN1 Virtual start:0xDEC24000

+pentaval0+ 1
 <c035d577> alloc_divert_blk+0x6b/0x6f  <c035560f> =
register_netdevice+0x67/0x2b5
 <c03558b8> register_netdev+0x5b/0x68  <ded805d8> =
PentaVal_init_one+0x26d/0x30f [pentaval]
 <c01cca22> pci_call_probe+0xf/0x12  <c01cca58> =
__pci_device_probe+0x33/0x47
 <c01cca8b> pci_device_probe+0x1f/0x34  <c021ce2e> =
driver_probe_device+0x43/0x9c
 <c021cee7> __driver_attach+0x0/0x5c  <c021cf1e> =
__driver_attach+0x37/0x5c
 <c021c57d> bus_for_each_dev+0x46/0x6c  <c01c5225> kobject_add+0x94/0xb3
 <c021cf57> driver_attach+0x14/0x18  <c021cee7> __driver_attach+0x0/0x5c
 <c021c992> bus_add_driver+0x54/0x84  <c021d33d> =
driver_register+0x7b/0x80
 <c01ccc46> __pci_register_driver+0x3e/0x4f  <c011d80d> =
blocking_notifier_call_chain+0x20/0x37
 <de82c00f> PentaVal_init_module+0xf/0x12 [pentaval]  <c0127ca4> =
sys_init_module+0x89/0x13d
 <c0102487> syscall_call+0x7/0xb=20

+pentaval0+ 2
 <c0355830> register_netdevice+0x288/0x2b5  <c03558b8> =
register_netdev+0x5b/0x68
 <ded805d8> PentaVal_init_one+0x26d/0x30f [pentaval]  <c01cca22> =
pci_call_probe+0xf/0x12
 <c01cca58> __pci_device_probe+0x33/0x47  <c01cca8b> =
pci_device_probe+0x1f/0x34
 <c021ce2e> driver_probe_device+0x43/0x9c  <c021cee7> =
__driver_attach+0x0/0x5c
 <c021cf1e> __driver_attach+0x37/0x5c  <c021c57d> =
bus_for_each_dev+0x46/0x6c
 <c01c5225> kobject_add+0x94/0xb3  <c021cf57> driver_attach+0x14/0x18
 <c021cee7> __driver_attach+0x0/0x5c  <c021c992> =
bus_add_driver+0x54/0x84
 <c021d33d> driver_register+0x7b/0x80  <c01ccc46> =
__pci_register_driver+0x3e/0x4f
 <c011d80d> blocking_notifier_call_chain+0x20/0x37  <de82c00f> =
PentaVal_init_module+0xf/0x12 [pentaval]
 <c0127ca4> sys_init_module+0x89/0x13d  <c0102487> syscall_call+0x7/0xb
-> www.pentamedia.com/english/products/penta-value.htm
Pentamedia Satellite Data Broadcast Receiver PCI Pent@VALUE(#1)
pentaval0: at 0xf7fff000 0xf7ffe000 IRQ 20
pentaval0: vendor 0x109e device 0x878
pentaval0: subsystem 0x15c8 subsystem vendor 0x133
pentaval0: ver 2.1.10  release date 2002/11/11

# ifconfig pentaval0 up
# dmesg -c

#nso:2
PentaVal_open: pentaval0: Starting up Pent@VALUE card (card idx =3D 0)
#nso:2

+pentaval0+ 3
 <c0361b8e> qdisc_alloc+0xa8/0xc2  <ded82e13> HWP_SetMultiCast+0xe5/0xf3 =
[pentaval]
 <ded81046> PentaVal_set_rx_mode+0x0/0xa1 [pentaval]  <c0361bb8> =
qdisc_create_dflt+0x10/0x3e
 <c0361df9> dev_activate+0x26/0xd1  <c0353cf6> dev_open+0x4e/0x65
 <c0354f18> dev_change_flags+0x49/0xeb  <c038b083> =
devinet_ioctl+0x24b/0x4bc
 <c038c9ce> inet_ioctl+0x44/0x63  <c034c6cf> sock_ioctl+0x1aa/0x1c7
 <c015011e> do_ioctl+0x26/0x4f  <c0150375> vfs_ioctl+0x16c/0x179
 <c01503ad> sys_ioctl+0x2b/0x46  <c0102487> syscall_call+0x7/0xb

+pentaval0+ 4
 <c0358e10> neigh_parms_alloc+0xa5/0xd7  <ded50ffc> =
ipv6_add_dev+0x92/0x1d1 [ipv6]
 <ded5117b> ipv6_find_idev+0x40/0x5b [ipv6]  <ded5292e> =
addrconf_add_dev+0x36/0x52 [ipv6]
 <ded533b2> addrconf_dev_config+0x5d/0x9a [ipv6]  <c035ba9a> =
rtmsg_ifinfo+0x69/0x71
 <ded535e0> addrconf_notify+0xc5/0x19b [ipv6]  <c011d6e2> =
notifier_call_chain+0x1c/0x33
 <c011d855> raw_notifier_call_chain+0x11/0x15  <c0353d03> =
dev_open+0x5b/0x65
 <c0354f18> dev_change_flags+0x49/0xeb  <c038b083> =
devinet_ioctl+0x24b/0x4bc
 <c038c9ce> inet_ioctl+0x44/0x63  <c034c6cf> sock_ioctl+0x1aa/0x1c7
 <c015011e> do_ioctl+0x26/0x4f  <c0150375> vfs_ioctl+0x16c/0x179
 <c01503ad> sys_ioctl+0x2b/0x46  <c0102487> syscall_call+0x7/0xb

+pentaval0+ 5
 <ded51037> ipv6_add_dev+0xcd/0x1d1 [ipv6]  <ded5117b> =
ipv6_find_idev+0x40/0x5b [ipv6]
 <ded5292e> addrconf_add_dev+0x36/0x52 [ipv6]  <ded533b2> =
addrconf_dev_config+0x5d/0x9a [ipv6]
 <c035ba9a> rtmsg_ifinfo+0x69/0x71  <ded535e0> =
addrconf_notify+0xc5/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d03> dev_open+0x5b/0x65  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

+pentaval0+ 6
 <c03537d0> dev_get_by_index+0x36/0x3a  <ded56fc6> =
ip6_route_add+0x73/0x635 [ipv6]
 <c0118a66> register_proc_table+0xcb/0xdf  <ded5286f> =
addrconf_add_mroute+0x66/0x6b [ipv6]
 <ded5293d> addrconf_add_dev+0x45/0x52 [ipv6]  <ded533b2> =
addrconf_dev_config+0x5d/0x9a [ipv6]
 <c035ba9a> rtmsg_ifinfo+0x69/0x71  <ded535e0> =
addrconf_notify+0xc5/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d03> dev_open+0x5b/0x65  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

+pentaval0+ 7
 <c03537d0> dev_get_by_index+0x36/0x3a  <ded56fc6> =
ip6_route_add+0x73/0x635 [ipv6]
 <ded52801> addrconf_prefix_route+0x7d/0x85 [ipv6]  <ded528f4> =
addrconf_add_lroute+0x34/0x38 [ipv6]
 <ded52943> addrconf_add_dev+0x4b/0x52 [ipv6]  <ded533b2> =
addrconf_dev_config+0x5d/0x9a [ipv6]
 <c035ba9a> rtmsg_ifinfo+0x69/0x71  <ded535e0> =
addrconf_notify+0xc5/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d03> dev_open+0x5b/0x65  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

+pentaval0+ 8
 <c03537d0> dev_get_by_index+0x36/0x3a  <ded56fc6> =
ip6_route_add+0x73/0x635 [ipv6]
 <ded52801> addrconf_prefix_route+0x7d/0x85 [ipv6]  <ded53a79> =
addrconf_dad_start+0x36/0xb9 [ipv6]
 <ded5333d> addrconf_add_linklocal+0x2b/0x43 [ipv6]  <ded533e5> =
addrconf_dev_config+0x90/0x9a [ipv6]
 <ded535e0> addrconf_notify+0xc5/0x19b [ipv6]  <c011d6e2> =
notifier_call_chain+0x1c/0x33
 <c011d855> raw_notifier_call_chain+0x11/0x15  <c0353d03> =
dev_open+0x5b/0x65
 <c0354f18> dev_change_flags+0x49/0xeb  <c038b083> =
devinet_ioctl+0x24b/0x4bc
 <c038c9ce> inet_ioctl+0x44/0x63  <c034c6cf> sock_ioctl+0x1aa/0x1c7
 <c015011e> do_ioctl+0x26/0x4f  <c0150375> vfs_ioctl+0x16c/0x179
 <c01503ad> sys_ioctl+0x2b/0x46  <c0102487> syscall_call+0x7/0xb

-pentaval0- 7
 <c0357527> dst_destroy+0x88/0xc1  <ded5915f> fib6_add+0xa3/0xb7 [ipv6]
 <ded5675c> ip6_ins_rt+0x29/0x37 [ipv6]  <ded52801> =
addrconf_prefix_route+0x7d/0x85 [ipv6]
 <ded53a79> addrconf_dad_start+0x36/0xb9 [ipv6]  <ded5333d> =
addrconf_add_linklocal+0x2b/0x43 [ipv6]
 <ded533e5> addrconf_dev_config+0x90/0x9a [ipv6]  <ded535e0> =
addrconf_notify+0xc5/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d03> dev_open+0x5b/0x65  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

+pentaval0+ 8
 <ded56d65> ndisc_dst_alloc+0x70/0x121 [ipv6]  <ded5b998> =
ndisc_send_rs+0x5e/0x363 [ipv6]
 <ded4e7f3> ip6_output+0x0/0x40 [ipv6]  <ded5996a> =
fib6_prune_clones+0x14/0x18 [ipv6]
 <ded59943> fib6_prune_clone+0x0/0x13 [ipv6]  <ded53c38> =
addrconf_dad_completed+0x69/0xa5 [ipv6]
 <ded5333d> addrconf_add_linklocal+0x2b/0x43 [ipv6]  <ded533e5> =
addrconf_dev_config+0x90/0x9a [ipv6]
 <ded535e0> addrconf_notify+0xc5/0x19b [ipv6]  <c011d6e2> =
notifier_call_chain+0x1c/0x33
 <c011d855> raw_notifier_call_chain+0x11/0x15  <c0353d03> =
dev_open+0x5b/0x65
 <c0354f18> dev_change_flags+0x49/0xeb  <c038b083> =
devinet_ioctl+0x24b/0x4bc
 <c038c9ce> inet_ioctl+0x44/0x63  <c034c6cf> sock_ioctl+0x1aa/0x1c7
 <c015011e> do_ioctl+0x26/0x4f  <c0150375> vfs_ioctl+0x16c/0x179
 <c01503ad> sys_ioctl+0x2b/0x46  <c0102487> syscall_call+0x7/0xb

+pentaval0+ 9
 <c0357c63> neigh_create+0x67/0x1a6  <c0357b13> neigh_lookup+0x1a/0x87
 <c0357b79> neigh_lookup+0x80/0x87  <ded56d93> =
ndisc_dst_alloc+0x9e/0x121 [ipv6]
 <ded5b998> ndisc_send_rs+0x5e/0x363 [ipv6]  <ded4e7f3> =
ip6_output+0x0/0x40 [ipv6]
 <ded5996a> fib6_prune_clones+0x14/0x18 [ipv6]  <ded59943> =
fib6_prune_clone+0x0/0x13 [ipv6]
 <ded53c38> addrconf_dad_completed+0x69/0xa5 [ipv6]  <ded5333d> =
addrconf_add_linklocal+0x2b/0x43 [ipv6]
 <ded533e5> addrconf_dev_config+0x90/0x9a [ipv6]  <ded535e0> =
addrconf_notify+0xc5/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d03> dev_open+0x5b/0x65  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

+pentaval0+ 10
 <ded56d65> ndisc_dst_alloc+0x70/0x121 [ipv6]  <ded5b998> =
ndisc_send_rs+0x5e/0x363 [ipv6]
 <ded4e7f3> ip6_output+0x0/0x40 [ipv6]  <ded53962> =
addrconf_rs_timer+0x0/0xa7 [ipv6]
 <ded539df> addrconf_rs_timer+0x7d/0xa7 [ipv6]  <c011ac27> =
run_timer_softirq+0x114/0x157
 <c0117bb0> __do_softirq+0x34/0x7d  <c0117c1b> do_softirq+0x22/0x26
 <c0104996> do_IRQ+0x1e/0x24  <c01033fa> common_interrupt+0x1a/0x20
 <c0100bcd> mwait_idle+0x1a/0x2a  <c0100b25> cpu_idle+0x42/0x57
 <c0520612> start_kernel+0x17b/0x17d=20

+pentaval0+ 11
 <ded56d65> ndisc_dst_alloc+0x70/0x121 [ipv6]  <ded5b998> =
ndisc_send_rs+0x5e/0x363 [ipv6]
 <ded4e7f3> ip6_output+0x0/0x40 [ipv6]  <c034fb22> =
kfree_skbmem+0x69/0x6d
 <ded53962> addrconf_rs_timer+0x0/0xa7 [ipv6]  <ded539df> =
addrconf_rs_timer+0x7d/0xa7 [ipv6]
 <c011ac27> run_timer_softirq+0x114/0x157  <c0117bb0> =
__do_softirq+0x34/0x7d
 <c0117c1b> do_softirq+0x22/0x26  <c0104996> do_IRQ+0x1e/0x24
 <c01033fa> common_interrupt+0x1a/0x20  <c0100bcd> mwait_idle+0x1a/0x2a
 <c0100b25> cpu_idle+0x42/0x57  <c0520612> start_kernel+0x17b/0x17d
pentaval0: no IPv6 routers present

# ifconfig pentaval0 down
# dmesg -c

=3Dnso:11
PentaVal_close: pentaval0: Shutting down Pent@VALUE card (card idx =3D0)
=3Dnso:11

-pentaval0- 10
 <c0357527> dst_destroy+0x88/0xc1  <ded59686> fib6_del_route+0x134/0x14d =
[ipv6]
 <ded596f9> fib6_del+0x5a/0xb3 [ipv6]  <ded598ca> =
fib6_clean_node+0x29/0x6b [ipv6]
 <ded597d7> fib6_walk_continue+0x85/0xe6 [ipv6]  <ded59877> =
fib6_walk+0x3f/0x69 [ipv6]
 <ded5993f> fib6_clean_tree+0x33/0x37 [ipv6]  <ded598a1> =
fib6_clean_node+0x0/0x6b [ipv6]
 <ded5993f> fib6_clean_tree+0x33/0x37 [ipv6]  <ded57e7b> =
fib6_ifdown+0x0/0x1f [ipv6]
 <ded57ebe> rt6_ifdown+0x24/0x2c [ipv6]  <ded57e7b> fib6_ifdown+0x0/0x1f =
[ipv6]
 <ded53707> addrconf_ifdown+0x51/0x2ac [ipv6]  <ded53667> =
addrconf_notify+0x14c/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d68> dev_close+0x5b/0x62  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

-pentaval0- 9
 <c0357527> dst_destroy+0x88/0xc1  <ded59686> fib6_del_route+0x134/0x14d =
[ipv6]
 <ded596f9> fib6_del+0x5a/0xb3 [ipv6]  <ded598ca> =
fib6_clean_node+0x29/0x6b [ipv6]
 <ded597d7> fib6_walk_continue+0x85/0xe6 [ipv6]  <ded59877> =
fib6_walk+0x3f/0x69 [ipv6]
 <ded5993f> fib6_clean_tree+0x33/0x37 [ipv6]  <ded598a1> =
fib6_clean_node+0x0/0x6b [ipv6]
 <ded5993f> fib6_clean_tree+0x33/0x37 [ipv6]  <ded57e7b> =
fib6_ifdown+0x0/0x1f [ipv6]
 <ded57ebe> rt6_ifdown+0x24/0x2c [ipv6]  <ded57e7b> fib6_ifdown+0x0/0x1f =
[ipv6]
 <ded53707> addrconf_ifdown+0x51/0x2ac [ipv6]  <ded53667> =
addrconf_notify+0x14c/0x19b [ipv6]
 <c011d6e2> notifier_call_chain+0x1c/0x33  <c011d855> =
raw_notifier_call_chain+0x11/0x15
 <c0353d68> dev_close+0x5b/0x62  <c0354f18> dev_change_flags+0x49/0xeb
 <c038b083> devinet_ioctl+0x24b/0x4bc  <c038c9ce> inet_ioctl+0x44/0x63
 <c034c6cf> sock_ioctl+0x1aa/0x1c7  <c015011e> do_ioctl+0x26/0x4f
 <c0150375> vfs_ioctl+0x16c/0x179  <c01503ad> sys_ioctl+0x2b/0x46
 <c0102487> syscall_call+0x7/0xb=20

# rmmod pentaval
# dmesg -c

nso:9
mtu:1500

-pentaval0- 3
 <c0358ed3> neigh_parms_release+0x76/0xa5  <ded53938> =
addrconf_ifdown+0x282/0x2ac [ipv6]
 <ded53667> addrconf_notify+0x14c/0x19b [ipv6]  <c011d6e2> =
notifier_call_chain+0x1c/0x33
 <c011d855> raw_notifier_call_chain+0x11/0x15  <c0355cc8> =
unregister_netdevice+0x151/0x1e1
 <c0355d68> unregister_netdev+0x10/0x18  <ded8072f> =
PentaVal_remove_one+0xb5/0x11d [pentaval]
 <c01ccab9> pci_device_remove+0x19/0x2c  <c021cfb3> =
__device_release_driver+0x58/0x85
 <c021d04f> driver_detach+0x49/0x76  <c021c9ee> =
bus_remove_driver+0x2c/0x4d
 <c021d34d> driver_unregister+0xb/0x15  <c01ccc65> =
pci_unregister_driver+0xe/0x19
 <ded84c0a> PentaVal_cleanup_module+0xa/0xc [pentaval]  <c01266c7> =
sys_delete_module+0x10d/0x132
 <c01375e5> do_munmap+0xdf/0xeb  <c0137622> sys_munmap+0x31/0x4b
 <c0102487> syscall_call+0x7/0xb=20

-pentaval0- 2
 <c0355d07> unregister_netdevice+0x190/0x1e1  <c0355d68> =
unregister_netdev+0x10/0x18
 <ded8072f> PentaVal_remove_one+0xb5/0x11d [pentaval]  <c01ccab9> =
pci_device_remove+0x19/0x2c
 <c021cfb3> __device_release_driver+0x58/0x85  <c021d04f> =
driver_detach+0x49/0x76
 <c021c9ee> bus_remove_driver+0x2c/0x4d  <c021d34d> =
driver_unregister+0xb/0x15
 <c01ccc65> pci_unregister_driver+0xe/0x19  <ded84c0a> =
PentaVal_cleanup_module+0xa/0xc [pentaval]
 <c01266c7> sys_delete_module+0x10d/0x132  <c01375e5> =
do_munmap+0xdf/0xeb
 <c0137622> sys_munmap+0x31/0x4b  <c0102487> syscall_call+0x7/0xb

-pentaval0- 1
 <c0361c6f> __qdisc_destroy+0x76/0x84  <c01205fe> rcu_do_batch+0x1a/0x71
 <c01207a4> rcu_process_callbacks+0xf/0x22  <c0117dc3> =
tasklet_action+0x3a/0x59
 <c0117bb0> __do_softirq+0x34/0x7d  <c0117c1b> do_softirq+0x22/0x26
 <c0104996> do_IRQ+0x1e/0x24  <c01033fa> common_interrupt+0x1a/0x20
 <c0100bcd> mwait_idle+0x1a/0x2a  <c0100b25> cpu_idle+0x42/0x57
 <c0520612> start_kernel+0x17b/0x17d=20

-pentaval0- 0
 <c0355d52> unregister_netdevice+0x1db/0x1e1  <c0355d68> =
unregister_netdev+0x10/0x18
 <ded8072f> PentaVal_remove_one+0xb5/0x11d [pentaval]  <c01ccab9> =
pci_device_remove+0x19/0x2c
 <c021cfb3> __device_release_driver+0x58/0x85  <c021d04f> =
driver_detach+0x49/0x76
 <c021c9ee> bus_remove_driver+0x2c/0x4d  <c021d34d> =
driver_unregister+0xb/0x15
 <c01ccc65> pci_unregister_driver+0xe/0x19  <ded84c0a> =
PentaVal_cleanup_module+0xa/0xc [pentaval]
 <c01266c7> sys_delete_module+0x10d/0x132  <c01375e5> =
do_munmap+0xdf/0xeb
 <c0137622> sys_munmap+0x31/0x4b  <c0102487> syscall_call+0x7/0xb
ACPI: PCI interrupt for device 0000:00:08.1 disabled
------=_NextPart_000_029A_01C69540.C9E4ABD0--

