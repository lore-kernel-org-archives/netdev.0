From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ip_tunnel: disable preemption when updating per-cpu
 tstats
Date: Mon, 16 Nov 2015 11:04:20 +0100
Message-ID: <1447668260.141421.440863153.156433F8@webmail.messagingengine.com>
References: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
 <1447346158-19257-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447346158-19257-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015, at 17:35, Jason A. Donenfeld wrote:
> Drivers like vxlan use the recently introduced
> udp_tunnel_xmit_skb/udp_tunnel6_xmit_skb APIs. udp_tunnel6_xmit_skb
> makes use of ip6tunnel_xmit, and ip6tunnel_xmit, after sending the
> packet, updates the struct stats using the usual
> u64_stats_update_begin/end calls on this_cpu_ptr(dev->tstats).
> udp_tunnel_xmit_skb makes use of iptunnel_xmit, which doesn't touch
> tstats, so drivers like vxlan, immediately after, call
> iptunnel_xmit_stats, which does the same thing - calls
> u64_stats_update_begin/end on this_cpu_ptr(dev->tstats).
> 
> While vxlan is probably fine (I don't know?), calling a similar function
> from, say, an unbound workqueue, on a fully preemptable kernel causes
> real issues:
> 
> [  188.434537] BUG: using smp_processor_id() in preemptible [00000000]
> code: kworker/u8:0/6
> [  188.435579] caller is debug_smp_processor_id+0x17/0x20
> [  188.435583] CPU: 0 PID: 6 Comm: kworker/u8:0 Not tainted 4.2.6 #2
> [  188.435607] Call Trace:
> [  188.435611]  [<ffffffff8234e936>] dump_stack+0x4f/0x7b
> [  188.435615]  [<ffffffff81915f3d>]
> check_preemption_disabled+0x19d/0x1c0
> [  188.435619]  [<ffffffff81915f77>] debug_smp_processor_id+0x17/0x20
> 
> The solution would be to protect the whole
> this_cpu_ptr(dev->tstats)/u64_stats_update_begin/end blocks with
> disabling preemption and then reenabling it.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
