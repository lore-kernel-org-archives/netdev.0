From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] drop_monitor: Make updating data->skb smp safe
Date: Mon, 04 Jun 2012 09:45:10 +0200
Message-ID: <1338795910.2760.1739.camel@edumazet-glaptop>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	 <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
	 <1335557509-32726-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49412 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab2FDHpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 03:45:16 -0400
Received: by eeit10 with SMTP id t10so1406040eei.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 00:45:14 -0700 (PDT)
In-Reply-To: <1335557509-32726-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 16:11 -0400, Neil Horman wrote:
> Eric Dumazet pointed out to me that the drop_monitor protocol has some holes in
> its smp protections.  Specifically, its possible to replace data->skb while its
> being written.  This patch corrects that by making data->skb and rcu protected
> variable.  That will prevent it from being overwritten while a tracepoint is
> modifying it.
> 

>  static void send_dm_alert(struct work_struct *unused)
>  {
>  	struct sk_buff *skb;
> -	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> +	struct per_cpu_dm_data *data = &get_cpu_var(dm_cpu_data);
>  
>  	/*
>  	 * Grab the skb we're about to send
>  	 */
> -	skb = data->skb;
> +	skb = rcu_dereference_protected(data->skb, 1);
>  
>  	/*
>  	 * Replace it with a new one
> @@ -111,8 +134,10 @@ static void send_dm_alert(struct work_struct *unused)
>  	/*
>  	 * Ship it!
>  	 */
> -	genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
> +	if (skb)
> +		genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
>  
> +	put_cpu_var(dm_cpu_data);
>  }
>  

Oh well, drop_monitor can still trigger alerts :


Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161774] BUG: sleeping function called from invalid context at mm/slub.c:943
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161779] in_atomic(): 1, irqs_disabled(): 0, pid: 2103, name: kworker/0:2
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161782] Pid: 2103, comm: kworker/0:2 Not tainted 3.5.0-rc1+ #55
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161784] Call Trace:
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161793]  [<ffffffff810697ca>] __might_sleep+0xca/0xf0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161798]  [<ffffffff811345a3>] kmem_cache_alloc_node+0x1b3/0x1c0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161804]  [<ffffffff8105578c>] ? queue_delayed_work_on+0x11c/0x130
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161808]  [<ffffffff815343fb>] __alloc_skb+0x4b/0x230
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161813]  [<ffffffffa00b0360>] ? reset_per_cpu_data+0x160/0x160 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161817]  [<ffffffffa00b022f>] reset_per_cpu_data+0x2f/0x160 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161820]  [<ffffffffa00b03ab>] send_dm_alert+0x4b/0xb0 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161824]  [<ffffffff810568e0>] process_one_work+0x130/0x4c0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161827]  [<ffffffff81058249>] worker_thread+0x159/0x360
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161830]  [<ffffffff810580f0>] ? manage_workers.isra.27+0x240/0x240
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161834]  [<ffffffff8105d403>] kthread+0x93/0xa0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161839]  [<ffffffff816be6d4>] kernel_thread_helper+0x4/0x10
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161843]  [<ffffffff8105d370>] ? kthread_freezable_should_stop+0x80/0x80
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161846]  [<ffffffff816be6d0>] ? gs_change+0xb/0xb

Also synchronize_rcu() cant be called in reset_per_cpu_data() for the same reason.

Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161865] BUG: scheduling while atomic: kworker/0:2/2103/0x00000002
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161881] Modules linked in: drop_monitor ip6table_filter ip6_tables ebtable_nat ebtables fuse ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT iptable_filter bridge stp rt61pci crc_itu_t rt2x00pci rt2x00lib eeprom_93cx6 igb ixgbe mdio
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161884] Pid: 2103, comm: kworker/0:2 Not tainted 3.5.0-rc1+ #55
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161885] Call Trace:
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161890]  [<ffffffff816ab9c3>] __schedule_bug+0x48/0x54
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161895]  [<ffffffff816b42d3>] __schedule+0x793/0x7e0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161898]  [<ffffffff811314b2>] ? set_track+0x62/0x1a0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161901]  [<ffffffff816b43d9>] schedule+0x29/0x70
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161904]  [<ffffffff816b2a15>] schedule_timeout+0x2c5/0x340
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161907]  [<ffffffffa00b022f>] ? reset_per_cpu_data+0x2f/0x160 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161910]  [<ffffffff815343fb>] ? __alloc_skb+0x4b/0x230
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161914]  [<ffffffff816b3a1a>] wait_for_common+0x13a/0x180
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161917]  [<ffffffff8106f1f0>] ? try_to_wake_up+0x2e0/0x2e0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161920]  [<ffffffffa00b022f>] ? reset_per_cpu_data+0x2f/0x160 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161925]  [<ffffffff810be860>] ? call_rcu_bh+0x20/0x20
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161928]  [<ffffffffa00b0360>] ? reset_per_cpu_data+0x160/0x160 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161931]  [<ffffffff816b3b3d>] wait_for_completion+0x1d/0x20
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161934]  [<ffffffff8105a47d>] wait_rcu_gp+0x4d/0x60
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161937]  [<ffffffff8105a490>] ? wait_rcu_gp+0x60/0x60
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161941]  [<ffffffff812a0101>] ? uuid_le_gen+0x1/0x30
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161944]  [<ffffffff810bf364>] synchronize_sched+0x44/0x50
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161948]  [<ffffffffa00b02b5>] reset_per_cpu_data+0xb5/0x160 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161951]  [<ffffffffa00b03ab>] send_dm_alert+0x4b/0xb0 [drop_monitor]
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161955]  [<ffffffff810568e0>] process_one_work+0x130/0x4c0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161957]  [<ffffffff81058249>] worker_thread+0x159/0x360
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161960]  [<ffffffff810580f0>] ? manage_workers.isra.27+0x240/0x240
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161963]  [<ffffffff8105d403>] kthread+0x93/0xa0
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161966]  [<ffffffff816be6d4>] kernel_thread_helper+0x4/0x10
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161970]  [<ffffffff8105d370>] ? kthread_freezable_should_stop+0x80/0x80
Jun  4 09:03:46 edumazet-laptop kernel: [ 2999.161973]  [<ffffffff816be6d0>] ? gs_change+0xb/0xb
