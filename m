From: Andrew <nitr0@seti.kr.ua>
Subject: 4.1.12 kernel crash in rtnetlink_put_metrics
Date: Wed, 4 Nov 2015 18:00:39 +0200
Message-ID: <563A2BA7.9080202@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pop3.seti.kr.ua ([91.202.132.4]:39318 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbbKDQAo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 11:00:44 -0500
Received: from [91.202.135.243] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1Zu0UJ-0001RN-PE
	for netdev@vger.kernel.org; Wed, 04 Nov 2015 18:00:40 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

Today I've got a crash on one of servers (PPPoE BRAS with BGP/OSPF). 
This server becomes unstable after updating from 3.2.x kernel to 4.1.x 
(other servers with slightly different CPUs/MBs also have troubles - but 
they hang less frequently).

Place in kernel code:
(gdb) list *rtnetlink_put_metrics+0x50
0xc131c7d0 is in rtnetlink_put_metrics 
(/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/net/core/rtnetlink.c:672).
667        mx = nla_nest_start(skb, RTA_METRICS);
668        if (mx == NULL)
669            return -ENOBUFS;
670
671        for (i = 0; i < RTAX_MAX; i++) {
672            if (metrics[i]) {
673                if (i == RTAX_CC_ALGO - 1) {
674                    char tmp[TCP_CA_NAME_MAX], *name;
675
676                    name = tcp_ca_get_name_by_key(metrics[i], tmp);


Here's trace:

[41358.475254]BUG:unable to handle kernel NULL pointer dereference at 
(null)[41358.475333]IP:[<c131c7d0>]rtnetlink_put_metrics+0x50/0x180[41358.475376]*pdpt 
=0000000026d58001*pde =0000000000000000[41358.475413]Oops:0000[#1] SMP 
[41358.475453]Moduleslinked in:act_mirred pppoe pppox ppp_generic slhc 
iptable_filter xt_length xt_TCPMSS xt_tcpudp xt_mark xt_dscp 
iptable_mangle ip_tables x_tables ipv6 sch_sfq sch_htb cls_u32 
sch_ingress sch_prio sch_tbf cls_flow cls_fw act_police ifb 8021qmrp 
garp stp llc softdog parport_pc parport acpi_cpufreq processor 
thermal_sys igb(O)k10temp hwmon dca ohci_pci ohci_hcd ptp pps_core 
i2c_piix4 i2c_core sp5100_tco sd_mod pata_acpi pata_atiixp pcspkr 
ata_generic ahci libahci libata ehci_pci ehci_hcd scsi_mod usbcore 
usb_common ext4 mbcache jbd2 crc16 vfat fat isofs 
[41358.475807]CPU:2PID:10877Comm:bird Tainted:G           O 4.1.12-i686 
#1[41358.475880]Hardwarename:MICRO-STAR INTERNATIONAL CO.,LTD 
MS-7596/760GM-E51(MS-7596),BIOS 
V3.301/12/2012[41358.475955]task:f5302da0 ti:e1364000 task.ti:e1364000 
[41358.475993]EIP:0060:[<c131c7d0>]EFLAGS:00010282CPU:2[41358.476030]EIP 
isat 
rtnetlink_put_metrics+0x50/0x180[41358.476066]EAX:00000000EBX:00000001ECX:00000004EDX:00000000[41358.476106]ESI:00000000EDI:e0b38000 
EBP:e1365ca8 ESP:e1365c78 
[41358.476143] DS:007bES:007bFS:00d8GS:0033SS:0068[41358.476179]CR0:8005003bCR2:00000000CR3:34966ac0CR4:000006f0[41358.476216]Stack:[41358.476249]00000000c1213873 
d4316f64 00000000e0b38000 e1365d00 c1213989 
00000fe4[41358.476330] e0b38000 00000000d4316f30 e0b38000 e1365d00 
c138362e e1365cd8 
0000000c[41358.476405]00000002000000020000000000000000c13bba01 e0b38000 
000000fe007d8196[41358.476482]CallTrace:[41358.476522][<c1213873>]?__nla_reserve+0x23/0xe0[41358.476557][<c1213989>]?__nla_put+0x9/0xb0[41358.476595][<c138362e>]?fib_dump_info+0x15e/0x3e0[41358.476636][<c13bba01>]?irq_entries_start+0x639/0x678[41358.476671][<c1386823>]?fib_table_dump+0xf3/0x180[41358.476708][<c138053d>]?inet_dump_fib+0x7d/0x100[41358.476746][<c1337ef1>]?netlink_dump+0x121/0x270[41358.476781][<c1303572>]?skb_free_datagram+0x12/0x40[41358.476818][<c1338284>]?netlink_recvmsg+0x244/0x360[41358.476855][<c12f3f8d>]?sock_recvmsg+0x1d/0x30[41358.476890][<c12f3f70>]?sock_recvmsg_nosec+0x30/0x30[41358.476924][<c12f5cec>]?___sys_recvmsg+0x9c/0x120[41358.476958][<c12f3f70>]?sock_recvmsg_nosec+0x30/0x30[41358.476994][<c10740e4>]?update_cfs_rq_blocked_load+0xc4/0x130[41358.477030][<c109
 4bb4>]?hrtimer_forward+0xa4/0x1c0[41358.477065][<c12f4cdd>]?sockfd_lookup_light+0x1d/0x80[41358.477099][<c12f6c5e>]?__sys_recvmsg+0x3e/0x80[41358.477134][<c12f6ff1>]?SyS_socketcall+0xb1/0x2a0[41358.477168][<c108657c>]?handle_irq_event+0x3c/0x60[41358.477203][<c1088efd>]?handle_edge_irq+0x7d/0x100[41358.477238][<c130a2e6>]?rps_trigger_softirq+0x26/0x30[41358.477273][<c10a88e3>]?flush_smp_call_function_queue+0x83/0x120[41358.477307][<c13bb2be>]?syscall_call+0x7/0x7[41358.477341]Code:008945d8 
89c3 89f8 e8 7e72ef ff 85c0 0f889e00000085db 0f8496000000bb 01000000c7 
45dc 000000006690<8b>449efc 85c0 742b83fb 100f84840000008945e0 
8d[41358.477509]EIP:[<c131c7d0>]rtnetlink_put_metrics+0x50/0x180SS:ESP 
0068:e1365c78 
[41358.477576]CR2:0000000000000000[41358.477880]---[endtrace 
6e3e7e6b81407c0a]---[41358.499813]------------[cut here 
]------------[41358.499879]WARNING:CPU:2PID:0at 
/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/net/netlink/af_netlink.c:944netlink_sock_destruct+0xa8/0xc0()[41358.500003]Moduleslinked 
in:act_mirred pppoe pppox ppp_generic slhc iptable_filter xt_length 
xt_TCPMSS xt_tcpudp xt_mark xt_dscp iptable_mangle ip_tables x_tables 
ipv6 sch_sfq sch_htb cls_u32 sch_ingress sch_prio sch_tbf cls_flow 
cls_fw act_police ifb 8021qmrp garp stp llc softdog parport_pc parport 
acpi_cpufreq processor thermal_sys igb(O)k10temp hwmon dca ohci_pci 
ohci_hcd ptp pps_core i2c_piix4 i2c_core sp5100_tco sd_mod pata_acpi 
pata_atiixp pcspkr ata_generic ahci libahci libata ehci_pci ehci_hcd 
scsi_mod usbcore usb_common ext4 mbcache jbd2 crc16 vfat fat isofs 
[41358.502110]CPU:2PID:0Comm:swapper/2Tainted:G      D    O 4.1.12-i686 
#1[41358.502213]Hardwarename:MICRO-STAR INTERNATIONAL CO.,LTD 
MS-7596/760GM-E51(MS-7596),BIOS V3.301/12/2012[41358.502305] c14b0540 
f5259f40 c13b6ee2 00000000c104b5a3 c1475fd4 
0000000200000000[41358.502610] c14b0540 000003b0c13373e8 
00000009c13373e8 f2204c00 0000000a0000000a[41358.502920] f5259f50 
c104b680 0000000900000000f5259f64 c13373e8 c108f4d7 c108f4d7 
[41358.503230]CallTrace:[41358.503292][<c13b6ee2>]?dump_stack+0x3e/0x4e[41358.503357][<c104b5a3>]?warn_slowpath_common+0x93/0xd0[41358.503420][<c13373e8>]?netlink_sock_destruct+0xa8/0xc0[41358.503484][<c13373e8>]?netlink_sock_destruct+0xa8/0xc0[41358.503548][<c104b680>]?warn_slowpath_null+0x20/0x30[41358.503609][<c13373e8>]?netlink_sock_destruct+0xa8/0xc0[41358.503671][<c108f4d7>]?rcu_process_callbacks+0x1b7/0x4e0[41358.503732][<c108f4d7>]?rcu_process_callbacks+0x1b7/0x4e0[41358.503794][<c12f9b88>]?__sk_free+0x18/0xf0[41358.503862][<c108f513>]?rcu_process_callbacks+0x1f3/0x4e0[41358.503929][<c104e753>]?__do_softirq+0xc3/0x240[41358.503992][<c104e690>]?__tasklet_hrtimer_trampoline+0x50/0x50[41358.504056][<c1004729>]?do_softirq_own_stack+0x29/0x40[41358.504117]<IRQ>[<c104ea9e>]?irq_exit+0x6e
 /0x90[41358.504208][<c13bc3f8>]?smp_apic_timer_interrupt+0x38/0x50[41358.504270][<c13bbcd9>]?apic_timer_interrupt+0x2d/0x34[41358.504332][<c100bfc9>]?default_idle+0x19/0xb0[41358.504395][<c100cd2e>]?arch_cpu_idle+0xe/0x10[41358.504458][<c107ec55>]?cpu_startup_entry+0x215/0x310[41358.504519]---[endtrace 
6e3e7e6b81407c0b]---
