From: Rene Mayrhofer <rene@mayrhofer.eu.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 11 Aug 2009 10:54:53 +0200
Message-ID: <4A8131DD.7010700@mayrhofer.eu.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com> <4A78BC48.4060200@gibraltar.at> <4A78BD5F.2030901@mayrhofer.eu.org> <4A78CA13.6040409@ring3k.org> <4A7977A0.7070807@mayrhofer.eu.org> <4A7A0CBE.4020304@ring3k.org> <4A7FF66A.1090506@mayrhofer.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:51781 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbZHKL7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:59:40 -0400
In-Reply-To: <4A7FF66A.1090506@mayrhofer.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Rene Mayrhofer wrote:
> Mike McCormack wrote:
>> Rene Mayrhofer wrote:
> 
>>> What would be the simplest change to stop disabling phy when the last
>>> device goes down?
>> Commenting out the following line should stop all the phys from powering off:
> 
>> sky2_phy_power_down(hw, port);
> 
>> If you have a chance, please test "sky2: Add a mutex around ethtools operations" also.
>> it probably won't fix the problem you're seeing, but you never know...
> 
> It seems that hardware is faulty, although in a very "interesting" way.
> We tried changing the "slot" modules with 4 NICs each, which did not
> change matters. However, another similar hardware appliance works. 

Actually, it's not. After producing a bit of traffic, we still see the
same issue with the other hardware. It is therefore not likely to be a
real hardware fault in the sense that a specific appliances is broken.

Even after disabling the sky2_phy_power_down call in sky2_down, I get
the oops on restarting the interfaces:



[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...Removed VLAN -:quara.6:-
RTNETLINK answers: Cannot assign requested address
run-parts: /etc/network/if-up.d/40address exited with return code 2
SIOCSIFFLAGS: Cannot assign requested address
Failed to bring up dmz.
Set name-type for VLAN subsystem. Should be visible in /proc/net/vlan/config
Added VLAN with VID == 6 to IF -:testnet:-
Starting radvd: radvd.
done.
[~]#
[~]#
[~]#
[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...[  707.000123] sky2 0000:01:00.0:
error interrupt status=0xffffffff

[  707.006858] sky2 0000:01:00.0: PCI hardware error (0xffff)

[  707.012977] sky2 0000:01:00.0: PCI Express error (0xffffffff)

[  707.019381] sky2 wan: ram data read parity error

[  707.024531] sky2 wan: ram data write parity error

[  707.029775] sky2 wan: MAC parity error

[  707.033969] sky2 wan: RX parity error

[  707.038060] sky2 wan: TCP segmentation error

[  707.042904] BUG: unable to handle kernel NULL pointer dereference at
0000038d
[  707.046812] IP: [<f8068d2d>] sky2_mac_intr+0x30/0xc1 [sky2]

[  707.046812] *pde = 00000000

[  707.046812] Oops: 0000 [#1] PREEMPT SMP

[  707.046812] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

[  707.046812] Modules linked in: xt_multiport cpufreq_userspace
ip6t_REJECT xt_DSCP xt_length xt_mark xt_dscp xt_MARK xt_IMQ xt_CONNMARK
xt_comment xt_policy ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
nf_defrag_ipv4 ipv6 evdev parport_pc parport i2c_i801 button i2c_core
iTCO_wdt processor serio_raw rng_core intel_agp pcspkr loop aufs
exportfs nls_utf8 nls_cp437 ide_generic sd_mod ata_generic pata_acpi
ata_piix ide_pci_generic skge ide_core sky2 thermal fan thermal_sys

[  707.145223]

[  707.145223] Pid: 11650, comm: 60address Not tainted (2.6.30.4 #3)

[  707.145223] EIP: 0060:[<f8068d2d>] EFLAGS: 00010286 CPU: 0

[  707.145223] EIP is at sky2_mac_intr+0x30/0xc1 [sky2]

[  707.145223] EAX: f8080f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff

[  707.169707] ESI: 00000000 EDI: f68c8e80 EBP: e1983c08 ESP: e1983bf0

[  707.169707]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068

[  707.169707] Process 60address (pid: 11650, ti=e1982000 task=dc0ce030
task.ti=e1982000)

[  707.195323] Stack:

[  707.195323]  00000080 ff8c8e80 6f11c339 f71cef60 ffffffff ffffffff
e1983c94 f806c064

[  707.195323]  c04ee377 6f11c339 00000040 f68c8e88 f70c4bcc 00000000
f68c8e80 ffffffff

[  707.212226]  e1983ca4 f71d5800 c0243594 00000000 c06b7134 f707c230
00000001 00000000

[  707.212226] Call Trace:

[  707.212226]  [<f806c064>] ? sky2_poll+0x1d2/0xb66 [sky2]

[  707.232409]  [<c04ee377>] ? _spin_unlock+0x29/0x3c

[  707.232409]  [<c0243594>] ? insert_work+0xa5/0xbf

[  707.232409]  [<c047732c>] ? __qdisc_run+0x73/0x1ca

[  707.245403]  [<c0463cf6>] ? net_rx_action+0x9e/0x1a2

[  707.245403]  [<c0237b6e>] ? __do_softirq+0xb2/0x188

[  707.245403]  [<c0237c83>] ? do_softirq+0x3f/0x5c

[  707.245403]  [<c0237e0d>] ? irq_exit+0x37/0x80

[  707.245403]  [<c0213cfd>] ? smp_apic_timer_interrupt+0x7c/0x9b

[  707.245403]  [<c02037dd>] ? apic_timer_interrupt+0x31/0x38

[  707.245403]  [<c029804c>] ? unmap_vmas+0x1df/0x655

[  707.245403]  [<c028d170>] ? ____pagevec_lru_add+0x10b/0x12a

[  707.245403]  [<c029c293>] ? exit_mmap+0xb8/0x158

[  707.295480]  [<c02305e1>] ? mmput+0x2f/0xa5

[  707.295480]  [<c02b43b1>] ? flush_old_exec+0x3a0/0x630

[  707.295480]  [<c02b46da>] ? kernel_read+0x40/0x63

[  707.295480]  [<c02e25e9>] ? load_elf_binary+0x355/0x11e4

[  707.295480]  [<c0299591>] ? __get_user_pages+0x28f/0x310

[  707.295480]  [<c029964a>] ? get_user_pages+0x38/0x50

[  707.295480]  [<c02b3825>] ? get_arg_page+0x38/0x9c

[  707.295480]  [<c02b3b80>] ? search_binary_handler+0xed/0x273

[  707.295480]  [<c02e2294>] ? load_elf_binary+0x0/0x11e4

[  707.345549]  [<c02b4ed8>] ? do_execve+0x24d/0x35c

[  707.345549]  [<c02016f0>] ? sys_execve+0x34/0x6d

[  707.345549]  [<c0202df3>] ? sysenter_do_call+0x12/0x28

[  707.345549] Code: c7 56 53 89 d3 83 ec 0c 65 a1 14 00 00 00 89 45 f0
31 c0 8b 74 97 3c c1 e2 07 89 d0 05 08 0f 00 00 89 55 e8 03 07 8a 10 88
55 ef <f6> 86 8d 03 00 00 02 74 12 0f b6 c2 50 56 68 b4 e3 06 f8 e8 f3

[  707.345549] EIP: [<f8068d2d>] sky2_mac_intr+0x30/0xc1 [sky2] SS:ESP
0068:e1983bf0

[  707.395629] CR2: 000000000000038d

[  707.401711] ---[ end trace 78f2d616187daf45 ]---

[  707.406932] Kernel panic - not syncing: Fatal exception in interrupt


Message from[  707.414147] Pid: 11650, comm: 60address Tainted: G      D
   2.6.30.4 #3

 syslogd@gibralt[  707.423018] Call Trace:

ar3-esys-master [  707.427230]  [<c04eb055>] ? printk+0x1d/0x30

at Aug 11 10:47:[  707.433435]  [<c04eaf93>] panic+0x53/0xf8

03 ...

 kernel[  707.439358]  [<c0206368>] oops_end+0x9f/0xbf

:[  707.046812] [  707.445562]  [<c021ceb4>] no_context+0x11a/0x135

Oops: 0000 [#1] [  707.452146]  [<c021d005>]
__bad_area_nosemaphore+0x136/0x14f
PREEMPT SMP

[  707.459910]  [<c0374f70>] ? vsnprintf+0x91/0x332


Message from [  707.466510]  [<c04ee2bd>] ?
_spin_unlock_irqrestore+0x31/0x44
syslogd@gibralta[  707.474345]  [<c04ee2bd>] ?
_spin_unlock_irqrestore+0x31/0x44
r3-esys-master a[  707.482190]  [<c0232f4f>] ?
release_console_sem+0x18b/0x1c9
t Aug 11 10:47:0[  707.489813]  [<c021d03b>]
bad_area_nosemaphore+0x1d/0x34
3 ...

 kernel:[  707.497163]  [<c021d30b>] do_page_fault+0x110/0x21b

[  707.046812] l[  707.504052]  [<c021d1fb>] ? do_page_fault+0x0/0x21b

ast sysfs file: [  707.510906]  [<c04ee732>] error_code+0x7a/0x80

/sys/devices/sys[  707.517321]  [<c037007b>] ? add_uevent_var+0x7/0xb9

tem/cpu/cpu0/cpu[  707.524189]  [<f8068d2d>] ? sky2_mac_intr+0x30/0xc1
[sky2]
freq/scaling_set[  707.531735]  [<f806c064>] sky2_poll+0x1d2/0xb66
[sky2]
speed


Mess[  707.538873]  [<c04ee377>] ? _spin_unlock+0x29/0x3c
age from syslogd[  707.545648]  [<c0243594>] ? insert_work+0xa5/0xbf
@gibraltar3-esys[  707.552333]  [<c047732c>] ? __qdisc_run+0x73/0x1ca
- -master at Aug 1[  707.559115]  [<c0463cf6>] net_rx_action+0x9e/0x1a2
[  707.565893]  [<c0237b6e>] __do_softirq+0xb2/0x188

 kernel:[  707.[  707.572571]  [<c0237c83>] do_softirq+0x3f/0x5c
169707] Process [  707.578968]  [<c0237e0d>] irq_exit+0x37/0x80
60address (pid: [  707.585194]  [<c0213cfd>]
smp_apic_timer_interrupt+0x7c/0x9b
11650, ti=e19820[  707.592938]  [<c02037dd>]
apic_timer_interrupt+0x31/0x38
00 task=dc0ce030[  707.600296]  [<c029804c>] ? unmap_vmas+0x1df/0x655

 task.ti=e198200[  707.607074]  [<c028d170>] ?
____pagevec_lru_add+0x10b/0x12a
0)


Message[  707.614707]  [<c029c293>] exit_mmap+0xb8/0x158
 from syslogd@gi[  707.621097]  [<c02305e1>] mmput+0x2f/0xa5
braltar3-esys-ma[  707.627024]  [<c02b43b1>] flush_old_exec+0x3a0/0x630
ster at Aug 11 1[  707.633988]  [<c02b46da>] ? kernel_read+0x40/0x63
0:47:03 ...
 k[  707.640669]  [<c02e25e9>] load_elf_binary+0x355/0x11e4
ernel:[  707.195[  707.647821]  [<c0299591>] ? __get_user_pages+0x28f/0x310
323] Stack:
[  707.655179]  [<c029964a>] ? get_user_pages+0x38/0x50

Message from s[  707.662148]  [<c02b3825>] ? get_arg_page+0x38/0x9c
yslogd@gibraltar[  707.668929]  [<c02b3b80>]
search_binary_handler+0xed/0x273
3-esys-master at[  707.676471]  [<c02e2294>] ?
load_elf_binary+0x0/0x11e4
 Aug 11 10:47:03[  707.683677]  [<c02b4ed8>] do_execve+0x24d/0x35c

 ...

 kernel:[[  707.690143]  [<c02016f0>] sys_execve+0x34/0x6d

  707.195323]  c[  707.696519]  [<c0202df3>] sysenter_do_call+0x12/0x28

04ee377 6f11c339[  707.703480] Rebooting in 30 seconds..


Thus, there really seems to be an uncaught case in sky2.c. When
sky2_phy_power_down is not called, chip should not go down, right? But
still sky2_poll seems to be called (maybe by an interrupt belonging to
another network interface but the same chip)?

Any other hints?
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkqBMdoACgkQq7SPDcPCS94SugCguCfe45JB+nNi+jE28JynRWtX
2M4Ani/SHmCaslHWy9gf0UT2Egp6Ql1+
=K4Qh
-----END PGP SIGNATURE-----
