From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000002c0
  / IP: [<c04c70f2>] in6_dev_finish_destroy+0x35/0x8c
Date: Fri, 15 Apr 2011 17:18:45 +0100
Message-ID: <4DA86FE5.8080507@simon.arlott.org.uk>
References: <4DA77AE5.9060501@simon.arlott.org.uk>	 <0b5f315dd0f6e8eefabbd8b38b1d43e181fdd728@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>	 <1302872983.3613.10.camel@edumazet-laptop> <1302873876.3613.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302873876.3613.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/04/11 14:24, Eric Dumazet wrote:
> Hmm.. a more complete patch :
> 
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
> index 0857272..6f0bed0 100644

I applied the patch by recompiling and then reloading the nf_conntrack_ipv6
module (temporarily flushing and then restoring all ip6tables rules).
Then this happened 10 minutes later:

[33876.950100] BUG: unable to handle kernel NULL pointer dereference at 00000014
[33876.951060] IP: [<f9b012bb>] nf_ct_frag6_gather+0x864/0x881 [nf_conntrack_ipv6]
[33876.951060] *pdpt = 0000000033491001 *pde = 0000000000000000 
[33876.951060] Oops: 0002 [#1] PREEMPT SMP 
[33876.951060] last sysfs file: /sys/devices/platform/it87.552/cpu0_vid
[33876.951060] Modules linked in: nf_conntrack_ipv6 xt_tcpmss xt_length xt_TCPMSS ppp_synctty sch_sfq xt_u32 xt_CLASSIFY sch_htb ppp_async nfsd lockd sunrpc bnep exportfs rfcomm l2cap crc16 xt_state ip6t_LOG ip]
[33876.951060] 
[33876.951060] Pid: 7, comm: ksoftirqd/1 Not tainted 2.6.35.4-git+ #git+ GA-MA69VM-S2/GA-MA69VM-S2
[33876.951060] EIP: 0060:[<f9b012bb>] EFLAGS: 00010246 CPU: 1
[33876.951060] EIP is at nf_ct_frag6_gather+0x864/0x881 [nf_conntrack_ipv6]
[33877.071165] EAX: f68e1800 EBX: 00000000 ECX: f560f3c0 EDX: f74921a0
[33877.071165] ESI: 00000000 EDI: f636f200 EBP: f7495e34 ESP: f7495ddc
[33877.071165]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[33877.071165] Process ksoftirqd/1 (pid: 7, ti=f7494000 task=f74921a0 task.ti=f7494000)
[33877.071165] Stack:
[33877.071165]  00000001 f5d6c8c0 f636f218 726b4c79 f68e1800 062c1158 f226d06c f560f3c0
[33877.071165] <0> f560f3d4 000005a8 00000000 f74921a0 00000001 00000000 00000000 726b4c79
[33877.071165] <0> 00000001 f226d04c f226d05c f5d6c8c0 00000000 f68e1800 f7495e48 f9b0043e
[33877.071165] Call Trace:
[33877.071165]  [<f9b0043e>] ? ipv6_defrag+0x69/0x9f [nf_conntrack_ipv6]
[33877.071165]  [<c046ee87>] ? nf_iterate+0x2f/0x62
[33877.071165]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[33877.071165]  [<c046f088>] ? nf_hook_slow+0x63/0xeb
[33877.071165]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[33877.071165]  [<c04c4aff>] ? ipv6_rcv+0x387/0x47c
[33877.071165]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[33877.071165]  [<c0455065>] ? __netif_receive_skb+0x367/0x3b6
[33877.071165]  [<c0455142>] ? process_backlog+0x8e/0x146
[33877.071165]  [<c0455c3b>] ? net_rx_action+0x62/0x119
[33877.071165]  [<c0232750>] ? __do_softirq+0x8b/0x10a
[33877.071165]  [<c02327fa>] ? do_softirq+0x2b/0x43
[33877.071165]  [<c0232885>] ? run_ksoftirqd+0x73/0x155
[33877.071165]  [<c0232812>] ? run_ksoftirqd+0x0/0x155
[33877.071165]  [<c023fdbd>] ? kthread+0x61/0x66
[33877.071165]  [<c023fd5c>] ? kthread+0x0/0x66
[33877.071165]  [<c0202c7a>] ? kernel_thread_helper+0x6/0x1a
[33877.071165] Code: 02 31 db 8b 45 c8 e8 8f 2c a1 c6 8b 4d c4 f0 ff 49 30 0f 94 c0 84 c0 74 0f 8b 45 c4 31 c9 ba 78 1a b0 f9 e8 38 fe 99 c6 8b 45 b8 <89> 43 14 89 5d ac eb 07 89 f8 e8 11 e3 94 c6 8b 45 ac 8d 6 
[33877.071165] EIP: [<f9b012bb>] nf_ct_frag6_gather+0x864/0x881 [nf_conntrack_ipv6] SS:ESP 0068:f7495ddc
[33877.071165] CR2: 0000000000000014
[33877.253064] ---[ end trace 91cffe982fd021cc ]---
[33877.257847] Kernel panic - not syncing: Fatal exception in interrupt
[33877.264339] Pid: 7, comm: ksoftirqd/1 Tainted: G      D     2.6.35.4-git+ #git+
[33877.271842] Call Trace:
[33877.274420]  [<c0511194>] ? printk+0xf/0x13
[33877.278743]  [<c0511116>] panic+0x55/0xc4
[33877.282860]  [<c02050ed>] oops_end+0x6e/0x7c
[33877.287239]  [<c021a514>] no_context+0x13f/0x149
[33877.291988]  [<c021a657>] __bad_area_nosemaphore+0x139/0x141
[33877.297802]  [<c0224fb6>] ? task_rq_lock+0x36/0x60
[33877.302760]  [<c021a66c>] bad_area_nosemaphore+0xd/0x10
[33877.308107]  [<c021a910>] do_page_fault+0x14e/0x302
[33877.313119]  [<c0513a46>] ? _raw_spin_lock_irqsave+0x35/0x3e
[33877.318985]  [<c0513fe0>] ? _raw_spin_unlock_irqrestore+0x42/0x58
[33877.325261]  [<c021a7c2>] ? do_page_fault+0x0/0x302
[33877.330306]  [<c051499b>] error_code+0x6b/0x70
[33877.334854]  [<c021a7c2>] ? do_page_fault+0x0/0x302
[33877.339926]  [<f9b012bb>] ? nf_ct_frag6_gather+0x864/0x881 [nf_conntrack_ipv6]
[33877.347451]  [<f9b0043e>] ipv6_defrag+0x69/0x9f [nf_conntrack_ipv6]
[33877.353958]  [<c046ee87>] nf_iterate+0x2f/0x62
[33877.358560]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[33877.363588]  [<c046f088>] nf_hook_slow+0x63/0xeb
[33877.368322]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[33877.373388]  [<c04c4aff>] ipv6_rcv+0x387/0x47c
[33877.377965]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[33877.383022]  [<c0455065>] __netif_receive_skb+0x367/0x3b6
[33877.388558]  [<c0455142>] process_backlog+0x8e/0x146
[33877.393715]  [<c0455c3b>] net_rx_action+0x62/0x119
[33877.398664]  [<c0232750>] __do_softirq+0x8b/0x10a
[33877.403554]  [<c02327fa>] do_softirq+0x2b/0x43
[33877.408154]  [<c0232885>] run_ksoftirqd+0x73/0x155
[33877.413051]  [<c0232812>] ? run_ksoftirqd+0x0/0x155
[33877.418053]  [<c023fdbd>] kthread+0x61/0x66
[33877.422360]  [<c023fd5c>] ? kthread+0x0/0x66
[33877.426735]  [<c0202c7a>] kernel_thread_helper+0x6/0x1a

-- 
Simon Arlott
