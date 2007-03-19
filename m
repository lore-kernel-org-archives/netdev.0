From: "Yuriy N. Shkandybin" <jura@netams.com>
Subject: Re: [Bug 8132] New: pptp server lockup in   ppp_asynctty_receive()
Date: Mon, 19 Mar 2007 10:49:12 +0300
Message-ID: <03ac01c769fb$16bc5ea0$9b01a8c0@Jura>
References: <20070308084539.GA2423@ff.dom.local> <01a001c76226$c956b290$9b01a8c0@Empty> <20070309131031.GE1662@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>, <linux-ppp@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.netams.com ([212.192.245.10]:52166 "EHLO mail.netams.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965812AbXCSHtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 03:49:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've changed kernel to rc4 and completely changed hardware.
Now this is

I've got new trace, but this is another problem as i can see and connected 
with pppoe

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.21-rc4 #1
-------------------------------------------------------
pppd/8926 is trying to acquire lock:
 (&vlan_netdev_xmit_lock_key){-...}, at: [<c0265486>] 
dev_queue_xmit+0x247/0x2f1

but task is already holding lock:
 (&pch->downl){-+..}, at: [<c0230c72>] ppp_channel_push+0x19/0x9a

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (&pch->downl){-+..}:
       [<c013642b>] __lock_acquire+0xe62/0x1010
       [<c0136642>] lock_acquire+0x69/0x83
       [<c02afc13>] _spin_lock_bh+0x30/0x3d
       [<c022f715>] ppp_push+0x5a/0x9a
       [<c022fb40>] ppp_xmit_process+0x2e/0x511
       [<c0231a05>] ppp_write+0xb8/0xf2
       [<c015ec26>] vfs_write+0x7f/0xba
       [<c015f158>] sys_write+0x3d/0x64
       [<c01027de>] sysenter_past_esp+0x5f/0x99
       [<ffffffff>] 0xffffffff

-> #2 (&ppp->wlock){-+..}:
       [<c013642b>] __lock_acquire+0xe62/0x1010
       [<c0136642>] lock_acquire+0x69/0x83
       [<c02afc13>] _spin_lock_bh+0x30/0x3d
       [<c022fb2b>] ppp_xmit_process+0x19/0x511
       [<c02318d3>] ppp_start_xmit+0x18a/0x204
       [<c0263a6f>] dev_hard_start_xmit+0x1f6/0x2c4
       [<c026ded3>] __qdisc_run+0x81/0x1bc
       [<c026549e>] dev_queue_xmit+0x25f/0x2f1
       [<c027c75f>] ip_output+0x1be/0x25f
       [<c02788ce>] ip_forward+0x159/0x22b
       [<c027745c>] ip_rcv+0x297/0x4dd
       [<c0263698>] netif_receive_skb+0x164/0x1f2
       [<c022199d>] e1000_clean_rx_irq+0x12a/0x4b7
       [<c02209bc>] e1000_clean+0x3ff/0x5dd
       [<c0265084>] net_rx_action+0x7d/0x12b
       [<c011e442>] __do_softirq+0x82/0xf2
       [<c011e509>] do_softirq+0x57/0x59
       [<c011e877>] irq_exit+0x7f/0x81
       [<c0105011>] do_IRQ+0x45/0x84
       [<c0103252>] common_interrupt+0x2e/0x34
       [<c0100b66>] mwait_idle+0x12/0x14
       [<c0100c60>] cpu_idle+0x6c/0x86
       [<c01001cd>] rest_init+0x23/0x36
       [<c0377d89>] start_kernel+0x3ca/0x461
       [<00000000>] 0x0
       [<ffffffff>] 0xffffffff

-> #1 (&dev->_xmit_lock){-+..}:
       [<c013642b>] __lock_acquire+0xe62/0x1010
       [<c0136642>] lock_acquire+0x69/0x83
       [<c02afc13>] _spin_lock_bh+0x30/0x3d
       [<c0266861>] dev_mc_add+0x34/0x16a
       [<c02ab5c7>] vlan_dev_set_multicast_list+0x88/0x25c
       [<c0266592>] __dev_mc_upload+0x22/0x24
       [<c0266914>] dev_mc_add+0xe7/0x16a
       [<c029f323>] igmp_group_added+0xe6/0xeb
       [<c029f50b>] ip_mc_inc_group+0x13f/0x210
       [<c029f5fa>] ip_mc_up+0x1e/0x61
       [<c029ab81>] inetdev_event+0x154/0x2c7
       [<c0125a46>] notifier_call_chain+0x2c/0x39
       [<c0125a7c>] raw_notifier_call_chain+0x8/0xa
       [<c026477a>] dev_open+0x6d/0x71
       [<c0263028>] dev_change_flags+0x51/0x101
       [<c029b7ca>] devinet_ioctl+0x4df/0x644
       [<c029bc03>] inet_ioctl+0x5c/0x6f
       [<c02596e0>] sock_ioctl+0x4f/0x1e8
       [<c0168c32>] do_ioctl+0x22/0x71
       [<c0168cd6>] vfs_ioctl+0x55/0x27e
       [<c0168f32>] sys_ioctl+0x33/0x51
       [<c01027de>] sysenter_past_esp+0x5f/0x99
       [<ffffffff>] 0xffffffff

-> #0 (&vlan_netdev_xmit_lock_key){-...}:
       [<c0136289>] __lock_acquire+0xcc0/0x1010
       [<c0136642>] lock_acquire+0x69/0x83
       [<c02afbd6>] _spin_lock+0x2b/0x38
       [<c0265486>] dev_queue_xmit+0x247/0x2f1
       [<c02334f6>] __pppoe_xmit+0x1a9/0x215
       [<c023356c>] pppoe_xmit+0xa/0xc
       [<c0230c9a>] ppp_channel_push+0x41/0x9a
       [<c0231a13>] ppp_write+0xc6/0xf2
       [<c015ec26>] vfs_write+0x7f/0xba
       [<c015f158>] sys_write+0x3d/0x64
       [<c01027de>] sysenter_past_esp+0x5f/0x99
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by pppd/8926:
 #0:  (&pch->downl){-+..}, at: [<c0230c72>] ppp_channel_push+0x19/0x9a

stack backtrace:
 [<c0103834>] show_trace_log_lvl+0x1a/0x30
 [<c0103f16>] show_trace+0x12/0x14
 [<c0103f9d>] dump_stack+0x16/0x18
 [<c01343cd>] print_circular_bug_tail+0x68/0x71
 [<c0136289>] __lock_acquire+0xcc0/0x1010
 [<c0136642>] lock_acquire+0x69/0x83
 [<c02afbd6>] _spin_lock+0x2b/0x38
 [<c0265486>] dev_queue_xmit+0x247/0x2f1
 [<c02334f6>] __pppoe_xmit+0x1a9/0x215
 [<c023356c>] pppoe_xmit+0xa/0xc
 [<c0230c9a>] ppp_channel_push+0x41/0x9a
 [<c0231a13>] ppp_write+0xc6/0xf2
 [<c015ec26>] vfs_write+0x7f/0xba
 [<c015f158>] sys_write+0x3d/0x64
 [<c01027de>] sysenter_past_esp+0x5f/0x99
 =======================
Clocksource tsc unstable (delta = 4686844667 ns)
Time: acpi_pm clocksource has been installed.

> On Fri, Mar 09, 2007 at 11:40:04AM +0300, Yuriy N. Shkandybin wrote:
> ...
>> .config is at
>> http://bugzilla.kernel.org/attachment.cgi?id=10660&action=view
>> Also all information i've provied was recieved by serial console and it's
>> not hand writing.
>>
>> I've checked logs and right before lockup there is oops in syslog
>> Mar  5 21:50:44 vpn2 skb_under_panic: text:c02248a2 len:207 put:1
>> head:db96e22c data:db96e22b tail:db96e2fa end:db96e82c dev:<NULL>
>
> This looks like a real problem with skb and maybe with
> dev->hard_header_len. I see you are using vlan module,
> so maybe there is some interaction? I don't know ppp
> enough, so I CC this message to the ppp list.
> I'm not sure HZ change will cure this forever (maybe
> some packets are going to the wrong dev?).
>
> If you're willing to experiment, you can try to edit
> "include/linux/ppp_defs.h" and change it like this:
>
> #define PPP_HDRLEN 8
> #define PPP_MRU 1496
>
> and "include/linux/if_ppp.h":
>
> #define PPP_MTU 1496
>
> plus mru/mtu in your pppd config (and recompile).
>
> But I hope ppp people will propose something better.
>
> Cheers,
> Jarek P.
>
>> Mar  5 21:50:44 vpn2 ------------[ cut here ]------------
>> Mar  5 21:50:44 vpn2 kernel BUG at net/core/skbuff.c:112!
>> Mar  5 21:50:44 vpn2 invalid opcode: 0000 [#1]
>> Mar  5 21:50:44 vpn2 SMP
>> Mar  5 21:50:44 vpn2 Modules linked in: 8021q ipt_TCPMSS xt_tcpudp
>> xt_pkttype iptable_filter ip_tables x_tables i2c_i801 i2c_core
>> Mar  5 21:50:44 vpn2 CPU:    1
>> Mar  5 21:50:44 vpn2 EIP:    0060:[<c024d1e4>]    Not tainted VLI
>> Mar  5 21:50:44 vpn2 EFLAGS: 00010092   (2.6.20-gentoo #10)
>> Mar  5 21:50:44 vpn2 EIP is at skb_under_panic+0x59/0x5d
>> Mar  5 21:50:44 vpn2 eax: 00000072   ebx: db96e22c   ecx: 00000001   edx:
>> de20d4d0
>> Mar  5 21:50:44 vpn2 esi: 00000000   edi: db96e2fc   ebp: dc5ab2e8   esp:
>> dcaf5e84
>> Mar  5 21:50:44 vpn2 ds: 007b   es: 007b   ss: 0068
>> Mar  5 21:50:44 vpn2 Process pptpctrl (pid: 5203, ti=dcaf4000 
>> task=de20d4d0
>> task.ti=dcaf4000)
>> Mar  5 21:50:44 vpn2 Stack: c0315e34 c02248a2 000000cf 00000001 db96e22c
>> db96e22b db96e2fa db96e82c
>> Mar  5 21:50:44 vpn2 c0301eef 00000004 00000000 c02248b0 de20d4d0 
>> de20da04
>> de20d4d0 00000000
>> Mar  5 21:50:44 vpn2 db96e22b 000000cf de3e28f0 de3e2884 00000000 
>> ddae82ac
>> de3e2854 00000296
>> Mar  5 21:50:44 vpn2 Call Trace:
>> Mar  5 21:50:44 vpn2 [<c02248a2>] ppp_asynctty_receive+0x6d2/0x710
>> Mar  5 21:50:44 vpn2 [<c02248b0>] ppp_asynctty_receive+0x6e0/0x710
>> Mar  5 21:50:44 vpn2 [<c01d5a09>] pty_write+0x39/0x41
>> Mar  5 21:50:44 vpn2 [<c01d37e1>] write_chan+0x212/0x320
>> Mar  5 21:50:44 vpn2 [<c0116209>] default_wake_function+0x0/0xc
>> Mar  5 21:50:44 vpn2 [<c01d1028>] tty_write+0x11c/0x1d0
>> Mar  5 21:50:44 vpn2 [<c01d35cf>] write_chan+0x0/0x320
>> Mar  5 21:50:44 vpn2 [<c015d502>] vfs_write+0x87/0xf0
>> Mar  5 21:50:44 vpn2 [<c01d0f0c>] tty_write+0x0/0x1d0
>> Mar  5 21:50:44 vpn2 [<c015daa9>] sys_write+0x41/0x6a
>> Mar  5 21:50:44 vpn2 [<c0102dae>] sysenter_past_esp+0x5f/0x99
>> Mar  5 21:50:44 vpn2 =======================
>> Mar  5 21:50:44 vpn2 Code: 00 00 89 5c 24 14 8b 98 8c 00 00 00 89 5c 24 
>> 10
>> 89 54 24 0c 8b 40 60 89 44 24 08 89 4c 24 04 c7 04 24 34 5e 31 c0 e8 8e 
>> e4
>> ec ff <0
>> f> 0b eb fe 56 53 83 ec 24 8b 70 14 bb ef 1e 30 c0 85 f6 0f 45
>> Mar  5 21:50:44 vpn2 EIP: [<c024d1e4>] skb_under_panic+0x59/0x5d SS:ESP
>> 0068:dcaf5e84
>>
>> Another thing - when i`ve changed HZ from 100 too 300 there is no such
>> lockups for few days.
>>
>> Jura
>>
> 

