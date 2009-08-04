From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 04 Aug 2009 23:31:53 +0200
Message-ID: <4A78A8C9.50409@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <4A78190C.1080909@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:52159 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932833AbZHDVcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 17:32:04 -0400
In-Reply-To: <4A78190C.1080909@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Mike McCormack wrote:
> 2009/8/4 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:
> 
>> Does anybody have an idea on what might be wrong in sky2_down?
> 
> I had a look into this, and noticed that we don't hold phy_lock when calling 
> sky2_phy_power_down() in sky2_down(). sky2_phy_power_down() does some PCI
> manipulation, so it's possible this could cause bad things to happen...
> 
> Does the following patch help?

It does certainly change things:

[~]# [  394.651649] ------------[ cut here ]------------
[  394.655499] kernel BUG at net/core/skbuff.c:1086!
[  394.655499] invalid opcode: 0000 [#1] PREEMPT SMP
[  394.655499] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

[  394.655499] Modules linked in: xt_multiport cpufreq_userspace xt_DSCP
xt_length xt_mark xt_dscp xt_MARK xt_CONNMARK xt_comment xt_policy
ipt_REDIRECT ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
nf_defrag_ipv4 ipv6 evdev parport_pc parport i2c_i801 iTCO_wdt serio_raw
i2c_core rng_core pcspkr intel_agp loop aufs exportfs nls_utf8 nls_cp437
ide_generic sd_mod ide_gd_mod ata_generic pata_acpi skge ata_piix piix
ide_pci_generic ide_core sky2 thermal_sys

[  394.655499]

[  394.655499] Pid: 0, comm: swapper Not tainted (2.6.30.4 #2)

[  394.655499] EIP: 0060:[<c045e0cd>] EFLAGS: 00010206 CPU: 0

[  394.655499] EIP is at skb_put+0x23/0x8c

[  394.655499] EAX: e1ebb022 EBX: e1eb4880 ECX: e1eb4880 EDX: 000000cc

[  394.655499] ESI: 000000cc EDI: f71f145c EBP: c065be64 ESP: c065be58

[  394.655499]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068

[  394.655499] Process swapper (pid: 0, ti=c065a000 task=c061d300
task.ti=c065a000)

[  394.655499] Stack:

[  394.655499]  9d5834df e1eb4880 00000600 c065beb0 f80ea72f 000202d2
00000040 f71e9388

[  394.655499]  97a234df f71e9380 f71e9000 f690cb80 e1ff8030 00000002
9d5834df c065bec8

[  394.655499]  f71e9380 000000cc 9d5834df f71e9388 00000040 00000000
c065bedc c0463ce6

[  394.655499] Call Trace:

[  394.655499]  [<f80ea72f>] ? skge_poll+0x41f/0x5b6 [skge]

[  394.655499]  [<c0463ce6>] ? net_rx_action+0x9e/0x1a2

[  394.655499]  [<c0237b6e>] ? __do_softirq+0xb2/0x188

[  394.655499]  [<c0237c83>] ? do_softirq+0x3f/0x5c

[  394.655499]  [<c0237e0d>] ? irq_exit+0x37/0x80

[  394.655499]  [<c0204cd2>] ? do_IRQ+0x79/0xa0

[  394.655499]  [<c02034d0>] ? common_interrupt+0x30/0x38

[  394.655499]  [<c0209ade>] ? mwait_idle+0xad/0x116

[  394.655499]  [<c0201eb4>] ? cpu_idle+0x96/0xc6

[  394.655499]  [<c04dbb19>] ? rest_init+0x75/0x88

[  394.655499]  [<c0660a16>] ? start_kernel+0x32d/0x343

[  394.655499]  [<c0660078>] ? __init_begin+0x78/0x8e

[  394.655499] Code: ff 8d 65 f8 5b 5e 5d c3 55 89 c1 89 e5 56 89 d6 53
83 ec 04 65 a1 14 00 00 00 89 45 f4 31 c0 83 79 58 00 8b 81 a8 00 00 00
74 04 <0f> 0b eb fe 8d 1c 10 01 51 54 3b 99 ac 00 00 00 89 99 a8 00 00

[  394.655499] EIP: [<c045e0cd>] skb_put+0x23/0x8c SS:ESP 0068:c065be58

[  394.913195] ---[ end trace d93328fae040abf9 ]---

[  394.918175] Kernel panic - not syncing: Fatal exception in interrupt

[  394.924926] Pid: 0, comm: swapper Tainted: G      D    2.6.30.4 #2

[  394.931491] Call Trace:

[  394.934153]  [<c04eb041>] ? printk+0x1d/0x30

[  394.938722]  [<c04eaf7f>] panic+0x53/0xf8

[  394.943025]  [<c0206368>] oops_end+0x9f/0xbf

[  394.947565]  [<c020656f>] die+0x5f/0x77

[  394.951672]  [<c0203ae1>] do_trap+0x9f/0xca

[  394.956129]  [<c0203ea8>] ? do_invalid_op+0x0/0xa2

[  394.961254]  [<c0203f2f>] do_invalid_op+0x87/0xa2

[  394.966274]  [<c045e0cd>] ? skb_put+0x23/0x8c

[  394.970951]  [<c04a7672>] ? udp_rcv+0x21/0x34

[  394.975611]  [<c0487922>] ? ip_local_deliver_finish+0x197/0x1ef

[  394.981912]  [<c04879e9>] ? ip_local_deliver+0x6f/0x89

[  394.987390]  [<c0487527>] ? ip_rcv_finish+0x28b/0x2b2

[  394.992768]  [<c04ee71a>] error_code+0x7a/0x80

[  394.997517]  [<c045e0cd>] ? skb_put+0x23/0x8c

[  395.002192]  [<f80ea72f>] skge_poll+0x41f/0x5b6 [skge]

[  395.007671]  [<c0463ce6>] net_rx_action+0x9e/0x1a2

[  395.012798]  [<c0237b6e>] __do_softirq+0xb2/0x188

[  395.017818]  [<c0237c83>] do_softirq+0x3f/0x5c

[  395.022561]  [<c0237e0d>] irq_exit+0x37/0x80

[  395.027122]  [<c0204cd2>] do_IRQ+0x79/0xa0

[  395.031502]  [<c02034d0>] common_interrupt+0x30/0x38

[  395.036815]  [<c0209ade>] ? mwait_idle+0xad/0x116

[  395.041844]  [<c0201eb4>] cpu_idle+0x96/0xc6

[  395.046397]  [<c04dbb19>] rest_init+0x75/0x88

[  395.051049]  [<c0660a16>] start_kernel+0x32d/0x343

[  395.056178]  [<c0660078>] __init_begin+0x78/0x8e

[  395.061107] Rebooting in 30 seconds..

Interesting that there are no sky2 errors anymore but that skge
oopses... After a reboot and rmmod skge before networking restart, it
suddenly starts to work! I only get these errors during ifdown/ifup:

[  534.141904] sky2 wan: disabling interface

[  534.342464] sky2 gibsrv: disabling interface

[  534.679531] sky2 dmz: disabling interface

[  535.000035] sky2 0000:01:00.0: device status error

[  535.000043] sky2 0000:03:00.0: device status error

[  535.017519] sky2 lan: disabling interface

[  536.000030] sky2 0000:01:00.0: device status error

[  536.000038] sky2 0000:03:00.0: device status error

[  536.000042] sky2 0000:04:00.0: device status error

[  537.000028] sky2 0000:01:00.0: device status error

[  537.000035] sky2 0000:03:00.0: device status error

[  537.000040] sky2 0000:04:00.0: device status error

[  537.009455] sky2 0000:01:00.0: wan: phy I/O error

[  537.014229] sky2 0000:01:00.0: wan: phy I/O error

[  537.018975] sky2 0000:01:00.0: wan: phy I/O error

[  537.023716] sky2 0000:01:00.0: wan: phy I/O error

[  537.028463] sky2 0000:01:00.0: wan: phy I/O error

[  537.033210] sky2 0000:01:00.0: wan: phy I/O error

[  537.037950] sky2 0000:01:00.0: wan: phy I/O error

[  537.042694] sky2 0000:01:00.0: wan: phy I/O error

[  537.047435] sky2 0000:01:00.0: wan: phy I/O error

[  537.052177] sky2 0000:01:00.0: wan: phy I/O error

[  537.057639] sky2 wan: enabling interface

[  537.057852] ADDRCONF(NETDEV_UP): wan: link is not ready

[  537.288286] sky2 gibsrv: enabling interface

[  537.288459] ADDRCONF(NETDEV_UP): gibsrv: link is not ready

[  537.627866] sky2 0000:03:00.0: dmz: phy I/O error

[  537.632634] sky2 0000:03:00.0: dmz: phy I/O error

[  537.637377] sky2 0000:03:00.0: dmz: phy I/O error

[  537.642118] sky2 0000:03:00.0: dmz: phy I/O error

[  537.646862] sky2 0000:03:00.0: dmz: phy I/O error

[  537.651610] sky2 0000:03:00.0: dmz: phy I/O error

[  537.656353] sky2 0000:03:00.0: dmz: phy I/O error

[  537.661097] sky2 0000:03:00.0: dmz: phy I/O error

[  537.665846] sky2 0000:03:00.0: dmz: phy I/O error

[  537.670589] sky2 0000:03:00.0: dmz: phy I/O error

[  537.676143] sky2 dmz: enabling interface

[  537.676317] ADDRCONF(NETDEV_UP): dmz: link is not ready

[  538.000031] sky2 0000:01:00.0: device status error

[  538.000039] sky2 0000:03:00.0: device status error

[  538.000044] sky2 0000:04:00.0: device status error

[  538.024201] sky2 0000:04:00.0: lan: phy I/O error

[  538.028971] sky2 0000:04:00.0: lan: phy I/O error

[  538.033712] sky2 0000:04:00.0: lan: phy I/O error

[  538.038455] sky2 0000:04:00.0: lan: phy I/O error
[  538.043199] sky2 0000:04:00.0: lan: phy I/O error
[  538.047939] sky2 0000:04:00.0: lan: phy I/O error
[  538.052681] sky2 0000:04:00.0: lan: phy I/O error
[  538.057424] sky2 0000:04:00.0: lan: phy I/O error
[  538.062167] sky2 0000:04:00.0: lan: phy I/O error
[  538.066908] sky2 0000:04:00.0: lan: phy I/O error
[  538.072982] sky2 lan: enabling interface
[  538.073196] ADDRCONF(NETDEV_UP): lan: link is not ready
[  539.000021] sky2 0000:01:00.0: device status error
[  539.000029] sky2 0000:03:00.0: device status error
[  539.000034] sky2 0000:04:00.0: device status error
[  539.447535] tun6to4: Disabled Privacy Extensions
[  540.000022] sky2 0000:01:00.0: device status error
[  540.000033] sky2 0000:03:00.0: device status error
[  540.000039] sky2 0000:04:00.0: device status error
[  541.000020] sky2 0000:01:00.0: device status error
[  541.000032] sky2 0000:03:00.0: device status error
[  541.000038] sky2 0000:04:00.0: device status error
[  542.000025] sky2 0000:01:00.0: device status error
[  542.000035] sky2 0000:03:00.0: device status error
[  542.000046] sky2 0000:04:00.0: device status error
[  543.000030] sky2 0000:01:00.0: device status error
[  543.000044] sky2 0000:03:00.0: device status error
[  543.000054] sky2 0000:04:00.0: device status error

Unfortunately, these errors continue and the device refuses to send or
receive any packets afterwards.

I will next try to use sky2.c from netdev git, as suggested.

best regards,
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp4qMUACgkQq7SPDcPCS94EPQCgx6nYmqUaZQbnXqNUTYPOulfA
bGMAn2oSt+KedkNOBGpF1y55JIjCdstl
=fH02
-----END PGP SIGNATURE-----
