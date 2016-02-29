From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 11:43:46 -0800
Message-ID: <1456775026.648.98.camel@edumazet-ThinkPad-T530>
References: <56D1E8B6.6090003@hurleysoftware.com>
	 <1456638957.3676.12.camel@gmail.com>
	 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
	 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
	 <1456759643.648.65.camel@edumazet-ThinkPad-T530>
	 <56D49860.7040303@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34666 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbcB2Tot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 14:44:49 -0500
In-Reply-To: <56D49860.7040303@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On lun., 2016-02-29 at 11:13 -0800, Peter Hurley wrote:
> On 02/29/2016 07:27 AM, Eric Dumazet wrote:
> > On lun., 2016-02-29 at 07:03 -0800, Peter Hurley wrote:
> > 
> >> The reason why Eric's change is so effective for Eric's workload is
> >> that it fixes the problem where NET_RX keeps getting new network packets
> >> so it keeps looping, servicing more NET_RX softirq.
> > 
> > You have very little idea of what is happening in networking land.
> 
> While that is true, I can read a trace:
> 
>   ** already in NET_RX softirq **
> 
>   <idle>-0       0..s2   15us : kmem_cache_alloc: call_site=c08378e4 ptr=de55d7c0 bytes_req=192 bytes_alloc=192 gfp_flags=GFP_ATOMIC
>   <idle>-0       0..s2   23us : netif_receive_skb_entry: dev=eth0 napi_id=0x0 queue_mapping=0 skbaddr=dca04400 vlan_tagged=0 vlan_proto=0x0000 vlan_tci=0x000
> 0 protocol=0x0800 ip_summed=0 hash=0x00000000 l4_hash=0 len=88 data_len=0 truesize=1984 mac_header_valid=1 mac_header=-14 nr_frags=0 gso_size=0 gso_type=0x0
>   <idle>-0       0..s2   30us+: netif_receive_skb: dev=eth0 skbaddr=dca04400 len=88
>   <idle>-0       0d.s5   98us : sched_waking: comm=sshd pid=750 prio=120 target_cpu=000
>   <idle>-0       0d.s6  105us : sched_stat_sleep: comm=sshd pid=750 delay=3125230447 [ns]
>   <idle>-0       0dns6  110us+: sched_wakeup: comm=sshd pid=750 prio=120 target_cpu=000
>   <idle>-0       0dns4  123us+: timer_start: timer=dc940e9c function=tcp_delack_timer expires=9746 [timeout=10] flags=0x00000000
>   <idle>-0       0dnH3  150us : irq_handler_entry: irq=176 name=4a100000.ethernet
>   <idle>-0       0dnH3  153us : softirq_raise: vec=3 [action=NET_RX]
>   <idle>-0       0dnH3  155us : irq_handler_exit: irq=176 ret=handled
>   <idle>-0       0dnH3  160us : irq_handler_entry: irq=20 name=49000000.edma_ccint
>   <idle>-0       0dnH3  163us : irq_handler_exit: irq=20 ret=handled
>   <idle>-0       0.ns2  169us : napi_poll: napi poll on napi struct de465c30 for device eth0
>   <idle>-0       0.ns2  171us : softirq_exit: vec=3 [action=NET_RX]
> 
> 
> As you can see, NET_RX softirq is re-raised while in NET_RX softirq,
> as a result of receiving new packets. So NET_RX will keep looping,
> which is what I wrote.

Well, NET_RX can not be re-raised, it is a single bit flip.

It is 'raised' on this trace because the driver already rearmed the IRQ
so that hard irq handler could fire.

Anyway, it seems you know much better than me, so I will stop answering
your mails on this topic.
