From: Daniel Mack <daniel@zonque.org>
Subject: Re: cgroup matches in INPUT chain
Date: Fri, 20 Mar 2015 23:07:15 +0100
Message-ID: <550C9A13.5080508@zonque.org>
References: <550B1852.2020209@zonque.org>	<20150319185807.GA3845@breakpoint.cc>	<550C2753.9020608@zonque.org>	<20150320161111.GA11498@breakpoint.cc>	<550C4901.4070001@zonque.org> <CAHA+R7MrL4kW5W=1LZFzXzkb1zWUxHRXHwjjnksScWF1ZMHswQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexey Perevalov <a.perevalov@samsung.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:45621 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbbCTWHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 18:07:18 -0400
In-Reply-To: <CAHA+R7MrL4kW5W=1LZFzXzkb1zWUxHRXHwjjnksScWF1ZMHswQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 09:55 PM, Cong Wang wrote:
> On Fri, Mar 20, 2015 at 9:21 AM, Daniel Mack <daniel@zonque.org> wrote:
>> I'm testing this on the lookback device, but I've seen similar behavior
>> on external interfaces too. However, I fail to see a pattern in that.
> 
> Loopback is special because the skb->dst is kept across TX and RX.

Ok, but that alone means we need special treatment in netfilter modules
that want to make a verdict on incoming packets based on information
stored in skb->sk, at least in case the packet happens to arrive on the
loopback device. Daniel Borkmann gave me a heads-up that xt_owner is
only for OUTPUT, so it's not affected by this issue. And xt_socket
implements its own socket lookup, so AFAICS the only module that's left
is xt_cgroup.

> How possible is your external interface sets dst for the packets?

That's what I don't know either, but my knowledge on the network core
details is admittedly limited.

> Are you using a tunnel device or you have some other setup you didn't mention?

Nope. I'm running my test with VirtualBox and do port forwarding from
the host into the VM. No tunnel devices or otherwise unusual network
setup is in place.

Inside the VM, I'm starting a very simple server that listens to a TCP
socket and I install a dummy netfilter rule for a cgroup into the INPUT
chain, just to make the match callback fire.

When I connect to that port from the host (via port forwarding), in the
netfilter callbacks skb->sk is NULL, skb->_skb_refdst is non-NULL, and a
stack trace produced by a WARN_ON(!skb->sk) in cgroup_mt() looks like this:

  <IRQ>  [<ffffffff8170fb51>] dump_stack+0x45/0x57
  [<ffffffff8109820a>] warn_slowpath_common+0x8a/0xc0
  [<ffffffff8109833a>] warn_slowpath_null+0x1a/0x20
  [<ffffffffa01b90b3>] cgroup_mt+0x93/0x95 [xt_cgroup]
  [<ffffffff81696965>] ipt_do_table+0x2a5/0x730
  [<ffffffff8163f6a0>] ? ip_rcv_finish+0x320/0x320
  [<ffffffff81698e54>] iptable_filter_hook+0x34/0x70
  [<ffffffff8163614a>] nf_iterate+0xaa/0xc0
  [<ffffffff8163f6a0>] ? ip_rcv_finish+0x320/0x320
  [<ffffffff816361e4>] nf_hook_slow+0x84/0x130
  [<ffffffff8163f6a0>] ? ip_rcv_finish+0x320/0x320
  [<ffffffff8163fa57>] ip_local_deliver+0x77/0x90
  [<ffffffff8163f3fa>] ip_rcv_finish+0x7a/0x320
  [<ffffffff8163fd08>] ip_rcv+0x298/0x390
  [<ffffffff8160050c>] __netif_receive_skb_core+0x1bc/0x9e0
  [<ffffffff81105274>] ? run_posix_cpu_timers+0x54/0x590
  [<ffffffff81600d48>] __netif_receive_skb+0x18/0x60
  [<ffffffff81600dd0>] netif_receive_skb_internal+0x40/0xc0
  [<ffffffff81601a48>] napi_gro_receive+0xc8/0x100
  [<ffffffffa0012144>] e1000_clean_rx_irq+0x164/0x520 [e1000]
  [<ffffffffa0013fa8>] e1000_clean+0x288/0x910 [e1000]
  [<ffffffff8104b92d>] ? lapic_next_event+0x1d/0x30
  [<ffffffff81718b56>] ? smp_apic_timer_interrupt+0x46/0x60
  [<ffffffff816012da>] net_rx_action+0x1ca/0x2f0
  [<ffffffff8109c5ab>] __do_softirq+0x10b/0x2d0
  [<ffffffff8109c9b5>] irq_exit+0x145/0x150
  [<ffffffff81718a78>] do_IRQ+0x58/0xf0
  [<ffffffff817169ad>] common_interrupt+0x6d/0x6d
  <EOI>  [<ffffffff811105e0>] ? tick_nohz_idle_exit+0xc0/0x140
  [<ffffffff811105d9>] ? tick_nohz_idle_exit+0xb9/0x140
  [<ffffffff810da160>] cpu_startup_entry+0x180/0x430
  [<ffffffff81706957>] rest_init+0x77/0x80
  [<ffffffff81d22025>] start_kernel+0x486/0x4a7
  [<ffffffff81d21120>] ? early_idt_handlers+0x120/0x120
  [<ffffffff81d21339>] x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d2149c>] x86_64_start_kernel+0x161/0x184
 ---[ end trace b96fff2079da6cf9 ]---


Thanks for looking into this,
Daniel
