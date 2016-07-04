From: nuclearcat@nuclearcat.com
Subject: Re: 4.6.3 kernel panic on ppp interface termination
 (__tcf_hash_release / spinlock )
Date: Mon, 04 Jul 2016 22:07:04 +0300
Message-ID: <31e51065f1531b4fa819dac37dc0ba11@nuclearcat.com>
References: <9b35b4153ec398e17cfb7c2739eee1de@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:54772 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435AbcGDTHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 15:07:07 -0400
In-Reply-To: <9b35b4153ec398e17cfb7c2739eee1de@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A little bit more details:

  ~ # tc -s -d filter show dev ppp0 parent ffff:
filter protocol ip pref 100 u32
filter protocol ip pref 100 u32 fh 800: ht divisor 1
filter protocol ip pref 100 u32 fh 800::1 order 1 key ht 800 bkt 0 
flowid :1  (rule hit 156 success 156)
   match 00000000/00000000 at 12 (success 156 )
	action order 1:  police 0x1 rate 4024Kbit burst 503000b mtu 2Kb action 
drop overhead 0b linklayer unspec
ref 1 bind 1
	Action statistics:
	Sent 10564 bytes 156 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0


Panic occurs when i delete ingress qdisc

tc qdisc del dev ppp0 ingress

After reversing commits (and some related commits)
	1d4150c02c5709fdfd80f10368a31867de35e72e
         ddf97ccdd7cb7e00daba465a5c947b8d941dc2a4

Problem is not occurring.

I'm not certainly sure this commits are causing issue, it is very hard 
to reverse patches on this particular system.




On 2016-07-04 20:38, nuclearcat@nuclearcat.com wrote:
> Hi!
> 
> On vanilla 4.6.0 and 4.6.3 i am getting reproducible kernel panic when
> i terminate user in accel-pppd. Here is kernel panic message received
> over netconsole:
> 
> 
>  [  465.469514] BUG: unable to handle kernel
> Jul  4 20:33:36 NULL pointer dereference   at 000000000000000c
>  [  465.469671] IP:  [<ffffffff818ca3fe>] _raw_spin_lock_bh+0x12/0x27
>  [  465.469755] PGD 0
>  [  465.469829] Oops: 0002 [#1] Jul  4 20:33:36 SMP
> 
>  [  465.469928] Modules linked in:
>   netconsole
>   configfs
>   sch_sfq
>   cls_fw
>   sch_htb
>   act_police
>   cls_u32
>   sch_ingress
>   sch_tbf
>   pppoe
>   pppox
>   ppp_generic
>   slhc
>   nf_nat_pptp
>   nf_nat_proto_gre
>   nf_conntrack_pptp
>   nf_conntrack_proto_gre
>   ts_bm
>   xt_string
>   xt_connmark
>   xt_TCPMSS
>   xt_tcpudp
>   xt_mark
>   iptable_filter
>   iptable_mangle
>   iptable_nat
>   nf_conntrack_ipv4
>   nf_defrag_ipv4
>   nf_nat_ipv4
>   nf_nat
>   nf_conntrack
>   ip_tables
>   x_tables
>   [last unloaded: netconsole]
> 
>  [  465.470912] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 
> 4.6.3-build-0103 #8
>  [  465.470974] Hardware name: Hewlett-Packard HP Compaq 8200 Elite
> CMT PC/1494, BIOS J01 v02.06 06/09/2011
>  [  465.471068] task: ffff88080a618bc0 ti: ffff88080a620000 task.ti:
> ffff88080a620000
>  [  465.471158] RIP: 0010:[<ffffffff818ca3fe>]
>   [<ffffffff818ca3fe>] _raw_spin_lock_bh+0x12/0x27
>  [  465.471270] RSP: 0018:ffff88082e283e28  EFLAGS: 00010246
>  [  465.471329] RAX: 0000000000000000 RBX: ffff880805d3f600 RCX:
> ffff880805d3f600
>  [  465.471391] RDX: 0000000000000001 RSI: 0000000000000001 RDI:
> 000000000000000c
>  [  465.471452] RBP: ffff88082e283e40 R08: 0000000000000001 R09:
> ffffea002025d000
>  [  465.471514] R10: ffff88082e283ea8 R11: 0001e1410001e131 R12:
> 000000000000000c
>  [  465.471575] R13: 0000000000000000 R14: ffff880805de7da0 R15:
> 0000000000000001
>  [  465.471637] FS:  0000000000000000(0000) GS:ffff88082e280000(0000)
> knlGS:0000000000000000
>  [  465.471728] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  [  465.471788] CR2: 000000000000000c CR3: 0000000002006000 CR4:
> 00000000000406e0
>  [  465.471849] Stack:
>  [  465.471903]  ffffffff81872ca4
>   ffff880805d30980
>   ffff880805de7d88
>   ffff88082e283e78
> 
>  [  465.472077]  ffffffff81873102
>   ffff880805de7d98
>   ffff880805de7da0
>   0000000000000021
> 
>  [  465.472250]  ffff880805d305a0
>   ffff88082e294e80
>   ffff88082e283e98
>   ffffffff81871668
> 
>  [  465.472421] Call Trace:
>  [  465.472476]  <IRQ>
> 
>  [  465.472501]  [<ffffffff81872ca4>] ? __tcf_hash_release+0x72/0xc9
>  [  465.472612]  [<ffffffff81873102>] tcf_action_destroy+0x43/0xa7
>  [  465.472672]  [<ffffffff81871668>] tcf_exts_destroy+0x1b/0x28
>  [  465.472734]  [<ffffffffa00b663d>] u32_destroy_key+0x16/0x48 
> [cls_u32]
>  [  465.472796]  [<ffffffffa00b6685>]
> u32_delete_key_freepf_rcu+0x16/0x18 [cls_u32]
>  [  465.472887]  [<ffffffff810f8bdb>] rcu_process_callbacks+0x393/0x4a6
>  [  465.472951]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
>  [  465.473010]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
>  [  465.473071]  [<ffffffff8102b8f7>] 
> smp_apic_timer_interrupt+0x3d/0x48
>  [  465.473132]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
>  [  465.473192]  <EOI>
> 
>  [  465.473216]  [<ffffffff8101be12>] ? mwait_idle+0x68/0x7e
>  [  465.473327]  [<ffffffff8101c212>] arch_cpu_idle+0xa/0xc
>  [  465.473387]  [<ffffffff810ea333>] default_idle_call+0x27/0x29
>  [  465.473447]  [<ffffffff810ea44a>] cpu_startup_entry+0x115/0x1bf
>  [  465.473508]  [<ffffffff8102a289>] start_secondary+0xf1/0xf4
>  [  465.473568] Code:
> Jul  4 20:33:36 01
> Jul  4 20:33:36 00
> Jul  4 20:33:36 00  message repeated 2 times: []
> Jul  4 20:33:36 f0
> Jul  4 20:33:36 0f
> Jul  4 20:33:36 b1
> Jul  4 20:33:36 17
> Jul  4 20:33:36 85
> Jul  4 20:33:36 c0
> Jul  4 20:33:36 74
> Jul  4 20:33:36 0c
> Jul  4 20:33:36 55
> Jul  4 20:33:36 89
> Jul  4 20:33:36 c6
> Jul  4 20:33:36 48
> Jul  4 20:33:36 89
> Jul  4 20:33:36 e5
> Jul  4 20:33:36 e8
> Jul  4 20:33:36 82
> Jul  4 20:33:36 11
> Jul  4 20:33:36 82
> Jul  4 20:33:36 ff
> Jul  4 20:33:36 5d
> Jul  4 20:33:36 c3
> Jul  4 20:33:36 65
> Jul  4 20:33:36 81
> Jul  4 20:33:36 05
> Jul  4 20:33:36 91
> Jul  4 20:33:36 1e
> Jul  4 20:33:36 74
> Jul  4 20:33:36 7e
> Jul  4 20:33:36 00
> Jul  4 20:33:36 02
> Jul  4 20:33:36 00
> Jul  4 20:33:36 00
> Jul  4 20:33:36 31
> Jul  4 20:33:36 c0
> Jul  4 20:33:36 ba
> Jul  4 20:33:36 01
> Jul  4 20:33:36 00
> Jul  4 20:33:36 00  message repeated 2 times: []
>  f0>
> Jul  4 20:33:36 0f
> Jul  4 20:33:36 b1
> Jul  4 20:33:36 17
> Jul  4 20:33:36 85
> Jul  4 20:33:36 c0
> Jul  4 20:33:36 74
> Jul  4 20:33:36 0c
> Jul  4 20:33:36 55
> Jul  4 20:33:36 89
> Jul  4 20:33:36 c6
> Jul  4 20:33:36 48
> Jul  4 20:33:36 89
> Jul  4 20:33:36 e5
> Jul  4 20:33:36 e8
> Jul  4 20:33:36 5b
> Jul  4 20:33:36 11
> Jul  4 20:33:36 82
> Jul  4 20:33:36 ff
> Jul  4 20:33:36 5d
> Jul  4 20:33:36 c3
> 
>  [  465.475045] RIP
>   [<ffffffff818ca3fe>] _raw_spin_lock_bh+0x12/0x27
>  [  465.475126]  RSP <ffff88082e283e28>
>  [  465.475182] CR2: 000000000000000c
>  [  465.475237] ---[ end trace 9062cce41479ad6a ]---
>  [  465.475296] Kernel panic - not syncing: Fatal exception in 
> interrupt
>  [  465.475359] Kernel Offset: disabled
>  [  465.475413] Rebooting in 5 seconds..
