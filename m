From: "Denys" <denys@visp.net.lb>
Subject: more... iproute2/htb/whatever critical bug ?
Date: Mon, 26 Mar 2007 21:49:15 +0300
Message-ID: <20070326182654.M24011@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb>	<46026717.9060909@trash.net>	<20070322124533.M79867@visp.net.lb>	<46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty> <4602B96A.5000308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:49866 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbXCZSt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 14:49:58 -0400
In-Reply-To: <4602B96A.5000308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello again

one more bug, and seems even more painful, kernel panic...


kernel 2.6.20.3

It is kind of complicated setup:

Init of shaper on ifb0 device

$TC qdisc add dev ifb0 root handle 1: htb default 1000
$TC filter add dev ifb0 parent 1:0 prio 1000 protocol ip u32 match ip dst 
0.0.0.0/0 classid 1:131

Then when interface go up

    $TC class add dev ifb0 classid 1:${id} parent 1: htb rate ${rate}bit 
quantum 1600
    $TC qdisc add dev ifb0 parent 1:${id} handle ${id}: sfq perturb 5
    $TC filter add dev ifb0 protocol ip pref ${id} parent 1: handle ${id} fw 
classid 1:${id}
    $TC qdisc del dev $2 ingress 1>/dev/null 2>/dev/null
    $TC qdisc add dev $2 ingress
    $TC filter add dev $2 parent ffff: protocol ip prio 10 u32 \
      match u32 0 0 flowid 1:1 \
      action ipt -j MARK --set-mark ${id} \
      action mirred egress redirect dev ifb0

It happens when interface (pppN) go down, commands executed in ip-down

   $TC filter del dev ifb0 protocol ip pref ${id}
   $TC class del dev ifb0 classid 1:${id}



Mar 26 23:21:11 ROUTER-75 pppd[22773]: Connection terminated.
Mar 26 21:20:04 ROUTER-75 [  551.481081] BUG: unable to handle kernel NULL 
pointer dereference
Mar 26 21:20:04 ROUTER-75 at virtual address 00000074
Mar 26 21:20:04 ROUTER-75 [  551.481187]  printing eip:
Mar 26 21:20:04 ROUTER-75 [  551.481236] f8a11df1
Mar 26 21:20:04 ROUTER-75 [  551.481289] *pde = 00000000
Mar 26 21:20:04 ROUTER-75 [  551.481340] Oops: 0000 [#1]
Mar 26 21:20:04 ROUTER-75 [  551.481384]
Mar 26 21:20:04 ROUTER-75 SMP
Mar 26 21:20:04 ROUTER-75
Mar 26 21:20:04 ROUTER-75 [  551.481549] Modules linked in:
.... long module list
ar 26 21:20:04 ROUTER-75 [  551.485237] CPU:    0
Mar 26 21:20:04 ROUTER-75 [  551.485238] EIP:    0060:[<f8a11df1>]    Not 
tainted VLI
Mar 26 21:20:04 ROUTER-75 [  551.485239] EFLAGS: 00010282   (2.6.20.3-build-
0001 #4)
Mar 26 21:20:04 ROUTER-75 [  551.485438] EIP is at htb_qlen_notify+0x9/0x79 
[sch_htb]
Mar 26 21:20:04 ROUTER-75 [  551.485487] eax: f3aa9800   ebx: 00000000   ecx: 
00000000   edx: 00000000
Mar 26 21:20:04 ROUTER-75 [  551.485594] esi: f3aa9800   edi: f8a13420   ebp: 
0000000c   esp: f22c3c40
Mar 26 21:20:04 ROUTER-75 [  551.485644] ds: 007b   es: 007b   ss: 0068
Mar 26 21:20:04 ROUTER-75 [  551.485691] Process tc (pid: 24816, ti=f22c2000 
task=f204a030 task.ti=f22c2000)
Mar 26 21:20:04 ROUTER-75
Mar 26 21:20:04 ROUTER-75 [  551.485741] Stack:
Mar 26 21:20:04 ROUTER-75 f2214000
Mar 26 21:20:04 ROUTER-75 f220e000
Mar 26 21:20:04 ROUTER-75 00000000
Mar 26 21:20:04 ROUTER-75 00010263
Mar 26 21:20:04 ROUTER-75 00000000
Mar 26 21:20:04 ROUTER-75 f3aa9800
Mar 26 21:20:04 ROUTER-75 c021b0b5
Mar 26 21:20:04 ROUTER-75 0000000c
Mar 26 21:20:04 ROUTER-75
Mar 26 21:20:04 ROUTER-75 [  551.486247]
Mar 26 21:20:04 ROUTER-75 f2a4c600
Mar 26 21:20:04 ROUTER-75 00000000
Mar 26 21:20:04 ROUTER-75 f3aa9800
Mar 26 21:20:04 ROUTER-75
Mar 26 21:20:04 ROUTER-75 [  551.486705]
Mar 26 21:20:04 ROUTER-75 00000000
Mar 26 21:20:04 ROUTER-75 f2a4c600
Mar 26 21:20:04 ROUTER-75 ffffffed
Mar 26 21:20:04 ROUTER-75 00010263
Mar 26 21:20:04 ROUTER-75 c02e5318
Mar 26 21:20:04 ROUTER-75 [  551.487226] Call Trace:
Mar 26 21:20:04 ROUTER-75 tc_ctl_tclass+0x144/0x1fd
Mar 26 21:20:04 ROUTER-75 rtnetlink_rcv_msg+0x0/0x1d2
Mar 26 21:20:04 ROUTER-75 [  551.488183]  [<c02144d5>]
Mar 26 21:20:04 ROUTER-75 [  551.488266]  [<c0220aae>]
Mar 26 21:20:04 ROUTER-75 netlink_data_ready+0x12/0x4c
Mar 26 21:20:04 ROUTER-75 [  551.488415]  [<c021fab9>]
Mar 26 21:20:04 ROUTER-75 [  551.488498]  [<c0220a90>]
Mar 26 21:20:04 ROUTER-75 netlink_sendmsg+0x23b/0x247
Mar 26 21:20:04 ROUTER-75 [  551.488658]  [<c0204f0c>]
Mar 26 21:20:04 ROUTER-75 sock_sendmsg+0xbc/0xd4
Mar 26 21:20:04 ROUTER-75 autoremove_wake_function+0x0/0x35
Mar 26 21:20:04 ROUTER-75 [  551.488913]  [<c0126545>]
Mar 26 21:20:04 ROUTER-75 autoremove_wake_function+0x0/0x35
Mar 26 21:20:04 ROUTER-75 [  551.489006]  [<c021ad27>]
Mar 26 21:20:04 ROUTER-75 __qdisc_run+0x2e/0x182
Mar 26 21:20:04 ROUTER-75 [  551.489158]  [<f8a0a03e>]
Mar 26 21:20:04 ROUTER-75 tcf_mirred+0x0/0x14d [act_mirred]
Mar 26 21:20:04 ROUTER-75 [  551.489249]  [<c020ad12>]
Mar 26 21:20:04 ROUTER-75 verify_iovec+0x3e/0x70
Mar 26 21:20:04 ROUTER-75 sys_sendmsg+0x194/0x1f9
Mar 26 21:20:04 ROUTER-75 [  551.489483]  [<c020585d>]
Mar 26 21:20:04 ROUTER-75 sys_recvmsg+0x14d/0x1cf
Mar 26 21:20:04 ROUTER-75 [  551.489628]  [<c0137d13>]
Mar 26 21:20:04 ROUTER-75 get_page_from_freelist+0x253/0x2d3
Mar 26 21:20:04 ROUTER-75 [  551.489717]  [<f8a2d18f>]
Mar 26 21:20:04 ROUTER-75 ppp_input+0xc6/0xe6 [ppp_generic]
Mar 26 21:20:04 ROUTER-75 [  551.489868]  [<f8a34cc4>]
Mar 26 21:20:04 ROUTER-75 [  551.489960]  [<c021b315>]
Mar 26 21:20:04 ROUTER-75 tc_classify+0x34/0xbc
Mar 26 21:20:04 ROUTER-75 [  551.490110]  [<f89d010b>]
Mar 26 21:20:04 ROUTER-75 ingress_enqueue+0x16/0x55 [sch_ingress]
Mar 26 21:20:04 ROUTER-75 [  551.490200]  [<c020d88b>]
Mar 26 21:20:04 ROUTER-75 netif_receive_skb+0x215/0x349
Mar 26 21:20:04 ROUTER-75 [  551.490346]  [<f8914b48>]
Mar 26 21:20:04 ROUTER-75 rtl8139_interrupt+0x2a1/0x3c5 [8139too]
Mar 26 21:20:04 ROUTER-75 [  551.490438]  [<c020f143>]
Mar 26 21:20:04 ROUTER-75 [  551.490907] Code:
Mar 26 21:20:04 ROUTER-75 83
Mar 26 21:20:04 ROUTER-75 24
Mar 26 21:20:04 ROUTER-75 ff
Mar 26 21:20:04 ROUTER-75 0f
Mar 26 21:20:04 ROUTER-75 85
Mar 26 21:20:04 ROUTER-75 4f
Mar 26 21:20:04 ROUTER-75 ff
Mar 26 21:20:04 ROUTER-75 ff
Mar 26 21:20:04 ROUTER-75 24
Mar 26 21:20:04 ROUTER-75 1c
Mar 26 21:20:04 ROUTER-75 00
Mar 26 21:20:04 ROUTER-75 8b
Mar 26 21:20:04 ROUTER-75 1c
Mar 26 21:20:04 ROUTER-75 20
Mar 26 21:20:04 ROUTER-75 5b
Mar 26 21:20:04 ROUTER-75 5f
Mar 26 21:20:04 ROUTER-75 5d
Mar 26 21:20:04 ROUTER-75 c3
Mar 26 21:20:04 ROUTER-75 56
Mar 26 21:20:04 ROUTER-75 c6
Mar 26 21:20:04 ROUTER-75 53
Mar 26 21:20:04 ROUTER-75 83
Mar 26 21:20:04 ROUTER-75 ec
Mar 26 21:20:04 ROUTER-75 10
Mar 26 21:20:04 ROUTER-75 unparseable log message: "<8b> "
Mar 26 21:20:04 ROUTER-75 74
Mar 26 21:20:04 ROUTER-75 00
Mar 26 21:20:04 ROUTER-75 83
Mar 26 21:20:04 ROUTER-75 01
Mar 26 21:20:04 ROUTER-75 00
Mar 26 21:20:04 ROUTER-75 00
Mar 26 21:20:04 ROUTER-75 24
Mar 26 21:20:04 ROUTER-75 c7
Mar 26 21:20:04 ROUTER-75
Mar 26 21:20:04 ROUTER-75 [  551.493934] EIP: [<f8a11df1>]
Mar 26 21:20:04 ROUTER-75 htb_qlen_notify+0x9/0x79 [sch_htb]
Mar 26 21:20:04 ROUTER-75 SS:ESP 0068:f22c3c40
Mar 26 21:20:04 ROUTER-75 [  551.494059]
Mar 26 21:20:04 ROUTER-75 Kernel panic - not syncing: Fatal exception in 
interrupt
Mar 26 21:20:04 ROUTER-75 Rebooting in 10 seconds..

One more panic

Mar 26 21:39:30 ROUTER-75 [  429.699144] BUG: unable to handle kernel NULL 
pointer dereference
Mar 26 21:39:30 ROUTER-75 at virtual address 00000074
Mar 26 21:39:30 ROUTER-75 [  429.699272]  printing eip:
Mar 26 21:39:30 ROUTER-75 [  429.699328] f8a11df1
Mar 26 21:39:30 ROUTER-75 [  429.699386] *pde = 00000000
Mar 26 21:39:30 ROUTER-75 [  429.699441] Oops: 0000 [#1]
Mar 26 21:39:30 ROUTER-75 [  429.699490]
Mar 26 21:39:30 ROUTER-75 SMP
Mar 26 21:39:30 ROUTER-75
Mar 26 21:39:30 ROUTER-75 [  429.699607] Modules linked in:
.... list of modules
Mar 26 21:39:30 ROUTER-75 [  429.702737] CPU:    1
Mar 26 21:39:30 ROUTER-75 [  429.702738] EIP:    0060:[<f8a11df1>]    Not 
tainted VLI
Mar 26 21:39:30 ROUTER-75 [  429.702740] EFLAGS: 00010282   (2.6.20.3-build-
0001 #4)
Mar 26 21:39:30 ROUTER-75 [  429.702889] EIP is at htb_qlen_notify+0x9/0x79 
[sch_htb]
Mar 26 21:39:30 ROUTER-75 [  429.702940] eax: f36d3800   ebx: 00000000   ecx: 
00000000   edx: 00000000
Mar 26 21:39:30 ROUTER-75 [  429.702994] esi: f36d3800   edi: f8a13420   ebp: 
0000000e   esp: f2093c40
Mar 26 21:39:30 ROUTER-75 [  429.703048] ds: 007b   es: 007b   ss: 0068
Mar 26 21:39:30 ROUTER-75 [  429.703098] Process tc (pid: 27124, ti=f2092000 
task=f2840550 task.ti=f2092000)
Mar 26 21:39:30 ROUTER-75
Mar 26 21:39:30 ROUTER-75 [  429.703151] Stack:
Mar 26 21:39:30 ROUTER-75 00000000
Mar 26 21:39:30 ROUTER-75 00010253
Mar 26 21:39:30 ROUTER-75 c021b0b5
Mar 26 21:39:30 ROUTER-75 0000000e
Mar 26 21:39:30 ROUTER-75 [  429.703509]
Mar 26 21:39:30 ROUTER-75 f2dd8a00
Mar 26 21:39:30 ROUTER-75 0000000e
Mar 26 21:39:30 ROUTER-75 0000001c
Mar 26 21:39:30 ROUTER-75 f2093ccc
Mar 26 21:39:30 ROUTER-75 00010000
Mar 26 21:39:30 ROUTER-75 f2dd8a00
Mar 26 21:39:30 ROUTER-75 ffffffed
Mar 26 21:39:30 ROUTER-75 00010253
Mar 26 21:39:30 ROUTER-75 00000000
Mar 26 21:39:30 ROUTER-75 00000000
Mar 26 21:39:30 ROUTER-75
Mar 26 21:39:30 ROUTER-75 [  429.704311]  [<c011ab71>]
Mar 26 21:39:30 ROUTER-75 tasklet_action+0x4b/0xa4
Mar 26 21:39:30 ROUTER-75 qdisc_tree_decrease_qlen+0x39/0x4f
Mar 26 21:39:30 ROUTER-75 [  429.704506]  [<f8a11ef6>]
Mar 26 21:39:30 ROUTER-75 [  429.705347]  [<c0220a90>]
Mar 26 21:39:30 ROUTER-75 netlink_sendmsg+0x23b/0x247
Mar 26 21:39:30 ROUTER-75 sock_sendmsg+0xbc/0xd4
Mar 26 21:39:30 ROUTER-75 [  429.705567]  [<c0126545>]
Mar 26 21:39:30 ROUTER-75 [  429.705665]  [<c0126545>]
Mar 26 21:39:30 ROUTER-75 autoremove_wake_function+0x0/0x35
Mar 26 21:39:30 ROUTER-75 [  429.705776]  [<c0126545>]
Mar 26 21:39:30 ROUTER-75 autoremove_wake_function+0x0/0x35
Mar 26 21:39:30 ROUTER-75 verify_iovec+0x3e/0x70
Mar 26 21:39:30 ROUTER-75 [  429.705958]  [<c02050b8>]
Mar 26 21:39:30 ROUTER-75 sys_sendmsg+0x194/0x1f9
Mar 26 21:39:30 ROUTER-75 [  429.706056]  [<c020585d>]
Mar 26 21:39:30 ROUTER-75 [  429.706149]  [<c0137d13>]
Mar 26 21:39:30 ROUTER-75 get_page_from_freelist+0x253/0x2d3
Mar 26 21:39:30 ROUTER-75 [  429.706264]  [<c0137de5>]
Mar 26 21:39:30 ROUTER-75 __alloc_pages+0x52/0x286
Mar 26 21:39:30 ROUTER-75 __handle_mm_fault+0x409/0x60a
Mar 26 21:39:30 ROUTER-75 [  429.706494]  [<c0205f58>]
Mar 26 21:39:30 ROUTER-75 sys_socketcall+0x223/0x242
Mar 26 21:39:30 ROUTER-75 [  429.706596]  [<c010f378>]
Mar 26 21:39:30 ROUTER-75 [  429.706681]  [<c0102c8c>]
Mar 26 21:39:30 ROUTER-75 sysenter_past_esp+0x5d/0x81
Mar 26 21:39:30 ROUTER-75 [  429.706794]  =======================
Mar 26 21:39:30 ROUTER-75 ff
Mar 26 21:39:30 ROUTER-75 c7
Mar 26 21:39:30 ROUTER-75 44
Mar 26 21:39:30 ROUTER-75 00
Mar 26 21:39:30 ROUTER-75 00
Mar 26 21:39:30 ROUTER-75 24
Mar 26 21:39:30 ROUTER-75 1c
Mar 26 21:39:30 ROUTER-75 20
Mar 26 21:39:30 ROUTER-75 5b
Mar 26 21:39:30 ROUTER-75 5d
Mar 26 21:39:30 ROUTER-75 c3
Mar 26 21:39:30 ROUTER-75 c6
Mar 26 21:39:30 ROUTER-75 53
Mar 26 21:39:30 ROUTER-75 83
Mar 26 21:39:30 ROUTER-75 ec
Mar 26 21:39:30 ROUTER-75 42
Mar 26 21:39:30 ROUTER-75 74
Mar 26 21:39:30 ROUTER-75 00
Mar 26 21:39:30 ROUTER-75 75
Mar 26 21:39:30 ROUTER-75 83
Mar 26 21:39:30 ROUTER-75 ba
Mar 26 21:39:30 ROUTER-75 00
Mar 26 21:39:30 ROUTER-75 00
Mar 26 21:39:30 ROUTER-75 24
Mar 26 21:39:30 ROUTER-75 c7
Mar 26 21:39:30 ROUTER-75
Mar 26 21:39:30 ROUTER-75 [  429.709043] EIP: [<f8a11df1>]
Mar 26 21:39:30 ROUTER-75 SS:ESP 0068:f2093c40

I am trying to remove command, that executed at interface removal, and moving 
it to ip-up stage (so when it init interface, it will try to delete old 
classes first).

--
Virtual ISP S.A.L.

