From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip_tunnel: disable preemption when updating per-cpu
 tstats
Date: Mon, 16 Nov 2015 14:17:37 -0500 (EST)
Message-ID: <20151116.141737.420755936779587001.davem@davemloft.net>
References: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
	<1447346158-19257-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, tom@herbertland.com, jbenc@redhat.com,
	kuznet@ms2.inr.ac.ru
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbKPTRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:17:43 -0500
In-Reply-To: <1447346158-19257-1-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 12 Nov 2015 17:35:58 +0100

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
> [  188.434537] BUG: using smp_processor_id() in preemptible [00000000] code: kworker/u8:0/6
> [  188.435579] caller is debug_smp_processor_id+0x17/0x20
> [  188.435583] CPU: 0 PID: 6 Comm: kworker/u8:0 Not tainted 4.2.6 #2
> [  188.435607] Call Trace:
> [  188.435611]  [<ffffffff8234e936>] dump_stack+0x4f/0x7b
> [  188.435615]  [<ffffffff81915f3d>] check_preemption_disabled+0x19d/0x1c0
> [  188.435619]  [<ffffffff81915f77>] debug_smp_processor_id+0x17/0x20
> 
> The solution would be to protect the whole
> this_cpu_ptr(dev->tstats)/u64_stats_update_begin/end blocks with
> disabling preemption and then reenabling it.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied and queued up for -stable, thanks Jason

Arguably, ip6tunnel_xmit() is primarily a ->ndo_start_xmit() and
therefore could assume that it only ran inside of a BH disabled code
sequence.  And as you noted, when this was turned into a general case
helper function that guarantee was no longer necessarily there.

So another fix could have been to do local_bh_disable() in the
udp_tunnel6_xmit_skb() helper.

Thanks again.
