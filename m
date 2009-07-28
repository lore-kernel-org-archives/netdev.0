From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 28 Jul 2009 11:48:05 +0200
Message-ID: <4A6EC955.4030401@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at>	<20090723102848.00a56ad1@nehalam>	<4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:60146 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbZG1JsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 05:48:16 -0400
In-Reply-To: <20090727153548.7c0d9f85@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Stephen Hemminger wrote:
> Does this help?
> 
> --- a/drivers/net/sky2.c	2009-07-27 15:28:27.653757064 -0700
> +++ b/drivers/net/sky2.c	2009-07-27 15:34:24.358730966 -0700
> @@ -2763,6 +2763,11 @@ static int sky2_poll(struct napi_struct 
>  	int work_done = 0;
>  	u16 idx;
>  
> +	if (unlikely(status == ~0)) {
> +		dev_info(&hw->pdev->dev, "device status error\n");
> +		goto clear_napi;
> +	}
> +
>  	if (unlikely(status & Y2_IS_ERROR))
>  		sky2_err_intr(hw, status);
>  
> @@ -2779,6 +2784,7 @@ static int sky2_poll(struct napi_struct 
>  			goto done;
>  	}
>  
> +clear_napi:
>  	napi_complete(napi);
>  	sky2_read32(hw, B0_Y2_SP_LISR);
>  done:

With this applied, the behaviour is certainly different: On first
networking restart, the kernel still continues to run although there are
some phy errors. On the second restart, there is no Oops, but a BUG.


[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...Removed VLAN -:quara.6:-
[  269.681295] sky2 0000:03:00.0: dmz: phy I/O error
[  269.686079] sky2 0000:03:00.0: dmz: phy I/O error
[  269.691000] sky2 0000:03:00.0: dmz: phy I/O error
[  269.695880] sky2 0000:03:00.0: dmz: phy I/O error
[  269.700751] sky2 0000:03:00.0: dmz: phy I/O error
[  269.705613] sky2 0000:03:00.0: dmz: phy I/O error
[  269.710519] sky2 0000:03:00.0: dmz: phy I/O error
[  269.715420] sky2 0000:03:00.0: dmz: phy I/O error
[  269.720290] sky2 0000:03:00.0: dmz: phy I/O error
[  269.725203] sky2 0000:03:00.0: dmz: phy I/O error
Set name-type for VLAN subsystem. Should be visible in /proc/net/vlan/config
Added VLAN with VID == 6 to IF -:testnet:-


[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...[  298.296616] ICMPv6 NA: someone
advertises our address on lan!

[  299.360719] lan: hw csum failure.

[  299.364169] Pid: 11563, comm: sh Not tainted 2.6.28.10 #3

[  299.369763] Call Trace:

[  299.372317]  [<c09eb603>] __skb_checksum_complete_head+0x3e/0x4f

[  299.378536]  [<f827f1f7>] udp_error+0x124/0x198 [nf_conntrack]

[  299.384571]  [<f827f0d3>] udp_error+0x0/0x198 [nf_conntrack]

[  299.390429]  [<f827b7bd>] nf_conntrack_in+0x117/0x72a [nf_conntrack]

[  299.397138]  [<c08718e1>] handle_mm_fault+0x54a/0xbfa

[  299.402464]  [<c0a04da4>] nf_iterate+0x30/0x61

[  299.407148]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af

[  299.412108]  [<c0a04f17>] nf_hook_slow+0x49/0xbd

[  299.416893]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af

[  299.421760]  [<c0a0a5a9>] ip_rcv+0x1d6/0x20e

[  299.426185]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af

[  299.431067]  [<c09ef01d>] netif_receive_skb+0x3f7/0x435

[  299.436479]  [<f8085143>] sky2_poll+0x844/0xc21 [sky2]

[  299.441780]  [<f817f52e>] au_reval_and_lock_fdi+0x7e/0x540 [aufs]

[  299.448088]  [<f817f3aa>] au_reopen_nondir+0x0/0x106 [aufs]

[  299.453825]  [<c09eda45>] net_rx_action+0xb8/0x1f6

[  299.458886]  [<c082f954>] __do_softirq+0x95/0x142

[  299.463850]  [<c082fa49>] do_softirq+0x48/0x57

[  299.468547]  [<c082fbc9>] irq_exit+0x3b/0x78

[  299.473053]  [<c0806642>] do_IRQ+0x7a/0x8c

[  299.477306]  [<c0804e23>] common_interrupt+0x23/0x30

[  299.482543]  [<c089f0f1>] fsstack_copy_inode_size+0x1d/0x3f

[  299.488314]  [<f817b3a4>] au_cpup_attr_timesizes+0x4e/0x58 [aufs]

[  299.494615]  [<f8180b06>] aufs_flush+0x93/0xc9 [aufs]

[  299.499837]  [<c0884a24>] filp_close+0x2e/0x53

[  299.504559]  [<c0884ab4>] sys_close+0x6b/0xa4

[  299.509178]  [<c0803cb2>] syscall_call+0x7/0xb

[  299.513893]  [<c0a60000>] rwsem_down_failed_common+0xa4/0x175

[  299.621662] ------------[ cut here ]------------

[  299.625591] kernel BUG at drivers/net/sky2.c:1781!

[  299.625591] invalid opcode: 0000 [#1] PREEMPT SMP

[  299.625591] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

[  299.625591] Modules linked in: xt_multiport cpufreq_userspace xt_DSCP
xt_length xt_mark xt_dscp xt_MARK xt_CONNMARK xt_comment xt_policy
ipt_REDIRECT ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle
ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG
xt_limit xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod
p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat
nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack
nf_defrag_ipv4 ipv6 evdev parport_pc parport pcspkr serio_raw i2c_i801
i2c_core iTCO_wdt rng_core intel_agp agpgart squashfs sqlzma unlzma loop
aufs exportfs nls_utf8 nls_cp437 ide_generic sd_mod ide_gd_mod
ata_generic pata_acpi ata_piix piix ide_pci_generic ide_core skge sky2
thermal_sys
[  299.625591]

[  299.625591] Pid: 11626, comm: ip Not tainted (2.6.28.10 #3)

[  299.625591] EIP: 0060:[<f80836a5>] EFLAGS: 00010256 CPU: 0

[  299.625591] EIP is at sky2_down+0x84/0x5c3 [sky2]

[  299.625591] EAX: f8010000 EBX: 00000280 ECX: 000006b4 EDX: f7060000

[  299.625591] ESI: 00000000 EDI: f684e980 EBP: 00000001 ESP: f5e35b78

[  299.625591]  DS: 0068 ES: 0068 FS: 00d8 GS: 0033 SS: 0068

[  299.625591] Process ip (pid: 11626, ti=f5e34000 task=f4a7e140
task.ti=f5e34000)

[  299.625591] Stack:

[  299.625591]  f7060000 00000303 00000004 f7060500 00000004 c09fc8c5
00000000 f7060290

[  299.625591]  f7060000 00001002 00001003 00000001 c09f00bd f7060000
c09efe15 00000000

[  299.625591]  ffffffef 00000000 00000000 f5e35ce4 c09f66b8 f5e35c28
f5e8f410 f7060000

[  299.625591] Call Trace:

[  299.625591]  [<c09fc8c5>] dev_deactivate+0x116/0x13b

[  299.625591]  [<c09f00bd>] dev_close+0x5f/0x7b

[  299.625591]  [<c09efe15>] dev_change_flags+0x9e/0x14f

[  299.625591]  [<c09f66b8>] do_setlink+0x28b/0x349

[  299.625591]  [<f80438b2>] skge_get_stats+0x2f/0x7b [skge]

[  299.625591]  [<c09f77a2>] rtnl_newlink+0x292/0x3f7

[  299.625591]  [<c09f756a>] rtnl_newlink+0x5a/0x3f7

[  299.625591]  [<c09f75aa>] rtnl_newlink+0x9a/0x3f7

[  299.625591]  [<c0862c3d>] find_get_page+0x87/0xaa

[  299.625591]  [<c09f7510>] rtnl_newlink+0x0/0x3f7

[  299.625591]  [<c09f74f6>] rtnetlink_rcv_msg+0x188/0x1a2

[  299.625591]  [<c09f736e>] rtnetlink_rcv_msg+0x0/0x1a2

[  299.625591]  [<c0a0390e>] netlink_rcv_skb+0x2d/0x73

[  299.625591]  [<c09f7368>] rtnetlink_rcv+0x19/0x1f

[  299.625591]  [<c0a03477>] netlink_unicast+0x1c7/0x229

[  299.625591]  [<c0a03729>] netlink_sendmsg+0x250/0x25d

[  299.625591]  [<c09e497a>] sock_sendmsg+0xc7/0xe1

[  299.625591]  [<c083b5fc>] autoremove_wake_function+0x0/0x2d

[  299.625591]  [<c083b5fc>] autoremove_wake_function+0x0/0x2d

[  299.625591]  [<c083b5fc>] autoremove_wake_function+0x0/0x2d

[  299.625591]  [<c09eb21b>] verify_iovec+0x3e/0x6b

[  299.625591]  [<c09e4b18>] sys_sendmsg+0x184/0x1e3

[  299.625591]  [<c09e574f>] sys_recvmsg+0x147/0x1e5

[  299.625591]  [<c09e5413>] sys_sendto+0xf9/0x124

[  299.625591]  [<c0a0298c>] netlink_insert+0xd2/0xef

[  299.625591]  [<c08757bb>] vma_merge+0x1d7/0x3ac

[  299.625591]  [<c09e5dd8>] sys_socketcall+0x177/0x1a9

[  299.625591]  [<c0875f3b>] sys_brk+0xd1/0xd9

[  299.625591]  [<c0803cb2>] syscall_call+0x7/0xb

[  299.625591]  [<c0a60000>] rwsem_down_failed_common+0xa4/0x175

[  299.625591] Code: b5 00 66 08 f8 b8 00 02 00 00 8d 8b 34 04 00 00 89
ca 03 17 89 02 8b 14 24 8b 82 00 05 00 00 8b 00 83 c0 04 66 8b 00 66 40
75 04 <0f> 0b eb fe 89 c8 03 07 8b 00 ba 05 00 00 00 8d 83 28 08 00 00

[  299.625591] EIP: [<f80836a5>] sky2_down+0x84/0x5c3 [sky2] SS:ESP
0068:f5e35b78

[  299.969972] sky2 0000:03:00.0: device status error


Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel[  299.982399] ---[ end trace c27f023d76d6060f ]---
:[  299.621662] ------------[ cut here ]------------

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591] invalid opcode: 0000 [#1] PREEMPT SMP

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed


Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591] Process ip (pid: 11626, ti=f5e34000 task=f4a7e140
task.ti=f5e34000)


Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591] Stack:

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  f7060000 00001002 00001003 00000001 c09f00bd
f7060000 c09efe15 00000000


Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  ffffffef 00000000 00000000 f5e35ce4 c09f66b8
f5e35c28 f5e8f410 f7060000


Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591] Call Trace:

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09fc8c5>] dev_deactivate+0x116/0x13b

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09f00bd>] dev_close+0x5f/0x7b

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09efe15>] dev_change_flags+0x9e/0x14f

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.6[  300.125238] lan: hw csum failure.
25591]  [<c09f66[  300.128944] Pid: 0, comm: swapper Tainted: G      D
  2.6.28.10 #3

b8>] do_setlink+[  300.136882] Call Trace:

0x28b/0x349

[  300.140827]  [<c09eb603>] __skb_checksum_complete_head+0x3e/0x4f


Message from s[  300.148422]  [<f827f1f7>] udp_error+0x124/0x198
[nf_conntrack]
yslogd@gibraltar[  300.155814]  [<f827f0d3>] udp_error+0x0/0x198
[nf_conntrack]
3-esys-master at[  300.163067]  [<f827b7bd>] nf_conntrack_in+0x117/0x72a
[nf_conntrack]

 Jul 28 11:46:45[  300.170988]  [<c08620a9>] cpupri_set+0xcf/0xeb

 ...

 kernel:[[  300.177061]  [<c08232cf>] enqueue_task_rt+0xfd/0x1ba

  299.625591]  [[  300.183686]  [<c081f9e3>] enqueue_task+0x52/0x5d

<f80438b2>] skge[  300.189847]  [<c0a604e8>]
_spin_unlock_irqrestore+0x22/0x39
_get_stats+0x2f/[  300.196991]  [<c0827013>] try_to_wake_up+0x158/0x162

0x7b [skge]

[  300.203501]  [<c0a04da4>] nf_iterate+0x30/0x61


Message from s[  300.209498]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
yslogd@gibraltar[  300.215661]  [<c0a04f17>] nf_hook_slow+0x49/0xbd
3-esys-master at[  300.221842]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
 Jul 28 11:46:45[  300.228078]  [<c0a0a5a9>] ip_rcv+0x1d6/0x20e
 ...
 kernel:[[  300.233875]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
  299.625591]  [[  300.240132]  [<c09ef01d>] netif_receive_skb+0x3f7/0x435
<c09f77a2>] rtnl[  300.246911]  [<f8085143>] sky2_poll+0x844/0xc21 [sky2]
_newlink+0x292/0[  300.253594]  [<c09eda45>] net_rx_action+0xb8/0x1f6
x3f7

Messa[  300.259939]  [<c082f954>] __do_softirq+0x95/0x142
ge from syslogd@[  300.266166]  [<c082fa49>] do_softirq+0x48/0x57
gibraltar3-esys-[  300.272137]  [<c082fbc9>] irq_exit+0x3b/0x78
master at Jul 28[  300.277945]  [<c0806642>] do_IRQ+0x7a/0x8c
 11:46:45 ...
[  300.283559]  [<c0804e23>] common_interrupt+0x23/0x30
 kernel:[  299.6[  300.290055]  [<c080a2c6>] mwait_idle+0x2f/0x3b
25591]  [<c09f75[  300.296043]  [<c0802ac9>] cpu_idle+0x7a/0xad
6a>] rtnl_newlink+0x5a/0x3f7

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09f75aa>] rtnl_newlink+0x9a/0x3f7

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c0862c3d>] find_get_page+0x87/0xaa

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09f7510>] rtnl_newlink+0x0/0x3f7

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09f74f6>] rtnetlink_rcv_msg+0x188/0x1a2

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09f736e>] rtnetlink_rcv_msg+0x0/0x1a2

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c0a0390e>] netlink_rcv_skb+0x2d/0x73

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09f7368>] rtnetlink_rcv+0x19/0x1f

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c0a03477>] netlink_unicast+0x1c7/0x229

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c0a03729>] netlink_sendmsg+0x250/0x25d

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09e497a>] sock_sendmsg+0xc7/0xe1

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c083b5fc>] autoremove_wake_function+0x0/0x2d

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:last message repeated 2 times

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09eb21b>] verify_iovec+0x3e/0x6b

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09e4b18>] sys_sendmsg+0x184/0x1e3

Message from syslogd@gibraltar3-esys-master at Jul 28 11:46:45 ...
 kernel:[  299.625591]  [<c09e574f>] sys_recvmsg+0x
Message from/etc/network/if-down.d/60address: line 25: 11626
Segmentation fault      ip link set dev $DEV down

run-parts: /etc/network/if-down.d/60address exited with return code 139

[  300.968019] sky2 0000:03:00.0: device status error

^C

[~]# [  302.000024] sky2 0000:03:00.0: device status error
[  302.746708] lan: hw csum failure.
[  302.750282] Pid: 0, comm: swapper Tainted: G      D    2.6.28.10 #3
[  302.757023] Call Trace:
[  302.759602]  [<c09eb603>] __skb_checksum_complete_head+0x3e/0x4f
[  302.765863]  [<f827f1f7>] udp_error+0x124/0x198 [nf_conntrack]
[  302.771934]  [<f827f0d3>] udp_error+0x0/0x198 [nf_conntrack]
[  302.777799]  [<f827b7bd>] nf_conntrack_in+0x117/0x72a [nf_conntrack]
[  302.784380]  [<c08210dd>] __wake_up_sync+0x2a/0x3e
[  302.789356]  [<c0a604e8>] _spin_unlock_irqrestore+0x22/0x39
[  302.795129]  [<c09e6ca5>] sock_def_readable+0x32/0x5b
[  302.800379]  [<c0a6050d>] _read_unlock+0xe/0x21
[  302.805080]  [<c09e8064>] sock_queue_rcv_skb+0xb5/0xbd
[  302.810421]  [<c0a25e9f>] __udp_queue_rcv_skb+0x12/0x86
[  302.815849]  [<c0a04da4>] nf_iterate+0x30/0x61
[  302.820442]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  302.825356]  [<c0a04f17>] nf_hook_slow+0x49/0xbd
[  302.830416]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  302.835510]  [<c0a0a5a9>] ip_rcv+0x1d6/0x20e
[  302.840117]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  302.845167]  [<c09ef01d>] netif_receive_skb+0x3f7/0x435
[  302.850791]  [<f8085143>] sky2_poll+0x844/0xc21 [sky2]
[  302.856337]  [<c0811a18>] lapic_next_event+0x10/0x13
[  302.861672]  [<c09eda45>] net_rx_action+0xb8/0x1f6
[  302.866654]  [<c082f954>] __do_softirq+0x95/0x142
[  302.871590]  [<c082fa49>] do_softirq+0x48/0x57
[  302.876335]  [<c082fbc9>] irq_exit+0x3b/0x78
[  302.880861]  [<c0806642>] do_IRQ+0x7a/0x8c
[  302.885184]  [<c0804e23>] common_interrupt+0x23/0x30
[  302.890422]  [<c080a2c6>] mwait_idle+0x2f/0x3b
[  302.896051]  [<c0802ac9>] cpu_idle+0x7a/0xad
[  303.000027] sky2 0000:03:00.0: device status error
[  303.058758] lan: hw csum failure.
[  303.062367] Pid: 0, comm: swapper Tainted: G      D    2.6.28.10 #3
[  303.068861] Call Trace:
[  303.071406]  [<c09eb603>] __skb_checksum_complete_head+0x3e/0x4f
[  303.077789]  [<f827f1f7>] udp_error+0x124/0x198 [nf_conntrack]
[  303.083871]  [<c0811a18>] lapic_next_event+0x10/0x13
[  303.089068]  [<f827f0d3>] udp_error+0x0/0x198 [nf_conntrack]
[  303.094929]  [<f827b7bd>] nf_conntrack_in+0x117/0x72a [nf_conntrack]
[  303.101514]  [<c0844533>] tick_program_event+0x2c/0x32
[  303.106851]  [<c083e621>] hrtimer_interrupt+0x146/0x16e
[  303.112313]  [<c082fb99>] irq_exit+0xb/0x78
[  303.116669]  [<c081218f>] smp_apic_timer_interrupt+0x75/0x7f
[  303.122585]  [<c0a04da4>] nf_iterate+0x30/0x61
[  303.127184]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  303.132067]  [<c0a04f17>] nf_hook_slow+0x49/0xbd
[  303.136911]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  303.141785]  [<c0a0a5a9>] ip_rcv+0x1d6/0x20e
[  303.146239]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  303.151112]  [<c09ef01d>] netif_receive_skb+0x3f7/0x435
[  303.156552]  [<f8085143>] sky2_poll+0x844/0xc21 [sky2]
[  303.161923]  [<c08417f0>] getnstimeofday+0x4f/0xd5
[  303.166879]  [<c09eda45>] net_rx_action+0xb8/0x1f6
[  303.171889]  [<c082f954>] __do_softirq+0x95/0x142
[  303.176758]  [<c082fa49>] do_softirq+0x48/0x57
[  303.181403]  [<c082fbc9>] irq_exit+0x3b/0x78
[  303.185850]  [<c0806642>] do_IRQ+0x7a/0x8c
[  303.190128]  [<c0804e23>] common_interrupt+0x23/0x30
[  303.195241]  [<c080a2c6>] mwait_idle+0x2f/0x3b
[  303.199879]  [<c0802ac9>] cpu_idle+0x7a/0xad
[  304.000039] sky2 0000:03:00.0: device status error
[  304.150934] lan: hw csum failure.
[  304.154546] Pid: 0, comm: swapper Tainted: G      D    2.6.28.10 #3
[  304.161288] Call Trace:
[  304.163876]  [<c09eb603>] __skb_checksum_complete_head+0x3e/0x4f
[  304.170102]  [<f827f1f7>] udp_error+0x124/0x198 [nf_conntrack]
[  304.176113]  [<c0811a18>] lapic_next_event+0x10/0x13
[  304.181260]  [<f827f0d3>] udp_error+0x0/0x198 [nf_conntrack]
[  304.187188]  [<f827b7bd>] nf_conntrack_in+0x117/0x72a [nf_conntrack]
[  304.193794]  [<c0844533>] tick_program_event+0x2c/0x32
[  304.199092]  [<c083e621>] hrtimer_interrupt+0x146/0x16e
[  304.204545]  [<c082fb99>] irq_exit+0xb/0x78
[  304.208887]  [<c081218f>] smp_apic_timer_interrupt+0x75/0x7f
[  304.214774]  [<c0a04da4>] nf_iterate+0x30/0x61
[  304.219390]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  304.224251]  [<c0a04f17>] nf_hook_slow+0x49/0xbd
[  304.229045]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  304.233922]  [<c0a0a5a9>] ip_rcv+0x1d6/0x20e
[  304.238348]  [<c0a0a124>] ip_rcv_finish+0x0/0x2af
[  304.243199]  [<c09ef01d>] netif_receive_skb+0x3f7/0x435
[  304.248634]  [<f8085143>] sky2_poll+0x844/0xc21 [sky2]
[  304.253961]  [<c0811a18>] lapic_next_event+0x10/0x13
[  304.259076]  [<c09eda45>] net_rx_action+0xb8/0x1f6
[  304.264063]  [<c082f954>] __do_softirq+0x95/0x142
[  304.268988]  [<c082fa49>] do_softirq+0x48/0x57
[  304.273595]  [<c082fbc9>] irq_exit+0x3b/0x78
[  304.278053]  [<c0806642>] do_IRQ+0x7a/0x8c
[  304.282326]  [<c0804e23>] common_interrupt+0x23/0x30
[  304.287467]  [<c080a2c6>] mwait_idle+0x2f/0x3b
[  304.292095]  [<c0802ac9>] cpu_idle+0x7a/0xad
[  305.000039] sky2 0000:03:00.0: device status error
[  306.000049] sky2 0000:03:00.0: device status error
[  307.000058] sky2 0000:03:00.0: device status error
[  308.000090] sky2 0000:03:00.0: device status error
[  309.000145] sky2 0000:03:00.0: device status error

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkpuyU0ACgkQq7SPDcPCS95M+gCg/Sc8kO3FmHrQTdIqeKIzq1XI
gEwAoJez4jZCId+81exvRH6jF4Lzj922
=ryPP
-----END PGP SIGNATURE-----
