From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: iptables: lock free counters, PREEMPT_RCU=y
 fix
Date: Thu, 2 Apr 2009 13:38:57 -0700
Message-ID: <20090402133857.1e3421b0@nehalam>
References: <20090402200128.GA21805@elte.hu>
	<20090402201245.GA29904@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, "Paul E. McKenney" <paulmck@us.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>, coreteam@netfilter.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47517 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbZDBUjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 16:39:06 -0400
In-Reply-To: <20090402201245.GA29904@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Apr 2009 22:12:45 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> Impact: fix log spam under CONFIG_DEBUG_PREEMPT=y
> 
> This recent commit:
> 
>    7845447: netfilter: iptables: lock free counters
> 
> Converted a couple of netfilter codepaths from read_lock() critical 
> sections to lockless rcu_read_lock(). What it forgot about is that 
> under CONFIG_PREEMPT=y and CONFIG_PREEMPT_RCU=y these sections can 
> be preempted.
> 
> Under CONFIG_DEBUG_PREEMPT=y this produces such warnings:
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: ssh/9115
> caller is ipt_do_table+0xc8/0x559
> Pid: 9115, comm: ssh Tainted: G        W  2.6.29-tip-08646-g45ef7c3-dirty #26231
> Call Trace:
>  [<c0c0dacf>] ? printk+0x14/0x16
>  [<c048c2e6>] debug_smp_processor_id+0xa6/0xbc
>  [<c0adbd03>] ipt_do_table+0xc8/0x559
>  [<c0c10277>] ? _read_unlock+0x3d/0x49
>  [<c0ad68c0>] ? fn_hash_lookup+0x94/0xa0
>  [<c0ad330e>] ? __inet_dev_addr_type+0x56/0x8d
>  [<c0a87b02>] ? neigh_lookup+0xe5/0x108
>  [<c0adc2bc>] ipt_local_hook+0x40/0x50
>  [<c0a93e57>] nf_iterate+0x34/0x80
>  [<c0aad4b8>] ? dst_output+0x0/0x10
>  [<c0a93eea>] nf_hook_slow+0x47/0xa4
>  [<c0aad4b8>] ? dst_output+0x0/0x10
>  [<c0aaec04>] __ip_local_out+0x78/0x7f
>  [<c0aad4b8>] ? dst_output+0x0/0x10
>  [<c0aaec1b>] ip_local_out+0x10/0x20
>  [<c0aaf416>] ip_queue_xmit+0x2bc/0x332
>  [<c0aa8fdf>] ? __ip_route_output_key+0x112/0x77b
>  [<c01397fe>] ? local_bh_enable+0x10/0x12
>  [<c0abf0e5>] ? tcp_connect+0x32a/0x3bb
>  [<c0ab15a7>] ? __inet_hash_nolisten+0x97/0xaf
>  [<c0a78dde>] ? __copy_skb_header+0xe/0x13a
>  [<c0abf0e5>] ? tcp_connect+0x32a/0x3bb
>  [<c0abe955>] ? tcp_transmit_skb+0x5a5/0x61c
>  [<c0abe995>] tcp_transmit_skb+0x5e5/0x61c
>  [<c0a7b6c0>] ? __alloc_skb+0x54/0x120
>  [<c0abefca>] ? tcp_connect+0x20f/0x3bb
>  [<c0abf0e5>] tcp_connect+0x32a/0x3bb
>  [<c0ac4b68>] tcp_v4_connect+0x466/0x4be
>  [<c0acf380>] inet_stream_connect+0x8f/0x212
>  [<c018f4e6>] ? might_fault+0x75/0x77
>  [<c047f198>] ? copy_from_user+0x2f/0x117
> BUG: using smp_processor_id() in preemptible [00000000] code: ssh/9114
> 
> Since it appears that the tables are RCU freed, and there are no 
> non-preempt assumptions in the code, the using of 
> raw_smp_processor_id() is safe.
> 
> [ I also audited all of net/netfilter/*.c for smp_processor_id() use,
>   and fixed all places that used them unsafely. ]
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  net/ipv4/netfilter/arp_tables.c |    2 +-
>  net/ipv4/netfilter/ip_tables.c  |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
> index 35c5f6a..30baf3e 100644
> --- a/net/ipv4/netfilter/arp_tables.c
> +++ b/net/ipv4/netfilter/arp_tables.c
> @@ -255,7 +255,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
>  
>  	rcu_read_lock();
>  	private = rcu_dereference(table->private);
> -	table_base = rcu_dereference(private->entries[smp_processor_id()]);
> +	table_base = rcu_dereference(private->entries[raw_smp_processor_id()]);
>  
>  	e = get_entry(table_base, private->hook_entry[hook]);
>  	back = get_entry(table_base, private->underflow[hook]);
> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
> index 82ee7c9..eff124e 100644
> --- a/net/ipv4/netfilter/ip_tables.c
> +++ b/net/ipv4/netfilter/ip_tables.c
> @@ -280,7 +280,7 @@ static void trace_packet(struct sk_buff *skb,
>  	char *hookname, *chainname, *comment;
>  	unsigned int rulenum = 0;
>  
> -	table_base = (void *)private->entries[smp_processor_id()];
> +	table_base = (void *)private->entries[raw_smp_processor_id()];
>  	root = get_entry(table_base, private->hook_entry[hook]);
>  
>  	hookname = chainname = (char *)hooknames[hook];
> @@ -341,7 +341,7 @@ ipt_do_table(struct sk_buff *skb,
>  
>  	rcu_read_lock();
>  	private = rcu_dereference(table->private);
> -	table_base = rcu_dereference(private->entries[smp_processor_id()]);
> +	table_base = rcu_dereference(private->entries[raw_smp_processor_id()]);
>  
>  	e = get_entry(table_base, private->hook_entry[hook]);
>  

NAK. The rcu_read_lock() needs to be rcu_read_lock_bh() otherwise RCU
could corrupt the referenceses.
