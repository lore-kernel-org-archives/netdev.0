From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Wed, 22 Aug 2012 16:29:53 +0200
Message-ID: <CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
	<CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	<1345640757.5158.1321.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:48011 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab2HVO3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:29:54 -0400
Received: by vbbff1 with SMTP id ff1so1089717vbb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 07:29:54 -0700 (PDT)
In-Reply-To: <1345640757.5158.1321.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> my patch was incomplete, sorry :
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 346b1eb..ddc453b 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -335,8 +335,13 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
>         /* don't get messages out of order, and no recursion */
>         if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
>                 struct netdev_queue *txq;
> +               int queue_index = skb_get_queue_mapping(skb);
>
> -               txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> +               if (queue_index >= dev->real_num_tx_queues) {
> +                       queue_index = 0;
> +                       skb_set_queue_mapping(skb, 0);
> +               }
> +               txq = netdev_get_tx_queue(dev, queue_index);
>
>                 /* try until next clock tick */
>                 for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;

Ok, I tried this.

The machine with the intel card still hard freeze (no output / no nothing ...)
The machine with the bnx2 don't crash anymore and no NULL deref, but
the modprobe still hangs and I get this every 180 sec or so :

[  775.956926] INFO: rcu_preempt self-detected stall on CPU { 14}
(t=600009 jiffies)
[  775.956927] Pid: 3154, comm: modprobe Not tainted
3.6.0-rc2-00092-g9040592-dirty #8
[  775.956928] Call Trace:
[  775.956931]  <IRQ>  [<ffffffff81094a58>] ? rcu_pending+0xee/0x490
[  775.956933]  [<ffffffff810571da>] ?
irqtime_account_process_tick.isra.73+0x134/0x23a
[  775.956934]  [<ffffffff81095406>] ? rcu_check_callbacks+0x79/0x85
[  775.956936]  [<ffffffff81041609>] ? update_process_times+0x30/0x62
[  775.956938]  [<ffffffff8106f204>] ? tick_sched_timer+0x75/0x9e
[  775.956939]  [<ffffffff8106f18f>] ? tick_nohz_handler+0xd0/0xd0
[  775.956941]  [<ffffffff810501cf>] ? __run_hrtimer.isra.26+0x75/0xcd
[  775.956943]  [<ffffffff81050873>] ? hrtimer_interrupt+0xe2/0x1f0
[  775.956948]  [<ffffffffa000941d>] ? bnx2_poll_work+0x2d3/0xa52 [bnx2]
[  775.956950]  [<ffffffff8100fa5c>] ? sched_clock+0x5/0x8
[  775.956952]  [<ffffffff81023d93>] ? smp_apic_timer_interrupt+0x6d/0x7f
[  775.956954]  [<ffffffff8133244a>] ? apic_timer_interrupt+0x6a/0x70
[  775.956956]  [<ffffffff8126d407>] ? __napi_complete+0x1c/0x23
[  775.956958]  [<ffffffff81074249>] ? do_raw_spin_lock+0x18/0x1b
[  775.956960]  [<ffffffff8126e596>] ? net_rx_action+0x7f/0x185
[  775.956962]  [<ffffffff8100f80e>] ? __cycles_2_ns+0x9/0x45
[  775.956964]  [<ffffffff8103caae>] ? __do_softirq+0x9c/0x14b
[  775.956966]  [<ffffffff81332b3c>] ? call_softirq+0x1c/0x30
[  775.956968]  <EOI>  [<ffffffff8100aea6>] ? do_softirq+0x3c/0x7a
[  775.956970]  [<ffffffff8103c9db>] ? _local_bh_enable_ip.isra.7+0x76/0xa3
[  775.956972]  [<ffffffff812804b7>] ? netpoll_poll_dev+0xfe/0x4bc
[  775.956974]  [<ffffffff81280b02>] ? netpoll_send_skb_on_dev+0x28d/0x33b
[  775.956978]  [<ffffffffa0ff2c4c>] ? bond_dev_queue_xmit+0x62/0x7f [bonding]
[  775.956982]  [<ffffffffa0ff7588>] ? bond_3ad_xmit_xor+0xe7/0x10c [bonding]
[  775.956984]  [<ffffffffa0ff2ffd>] ? bond_start_xmit+0x394/0x3ff [bonding]
[  775.956987]  [<ffffffff81280ac1>] ? netpoll_send_skb_on_dev+0x24c/0x33b
[  775.956990]  [<ffffffffa0079fd5>] ?
vlan_dev_hard_start_xmit+0xab/0xf6 [8021q]
[  775.956992]  [<ffffffff81280ac1>] ? netpoll_send_skb_on_dev+0x24c/0x33b
[  775.956996]  [<ffffffffa01998e8>] ? __br_deliver+0x93/0xbe [bridge]
[  775.956998]  [<ffffffffa019837d>] ? br_dev_xmit+0x14a/0x16b [bridge]
[  775.957001]  [<ffffffff81280ac1>] ? netpoll_send_skb_on_dev+0x24c/0x33b
[  775.957003]  [<ffffffff81280372>] ? find_skb.isra.24+0x31/0x78
[  775.957005]  [<ffffffff81280bdc>] ? netpoll_send_skb+0x2c/0x39
[  775.957007]  [<ffffffffa00c422a>] ? write_msg+0x98/0xf3 [netconsole]
[  775.957009]  [<ffffffff81037db2>] ?
call_console_drivers.constprop.17+0x6e/0x7d
[  775.957011]  [<ffffffff81038248>] ? console_unlock+0x2ab/0x351
[  775.957012]  [<ffffffff81039112>] ? register_console+0x273/0x303
[  775.957014]  [<ffffffffa0103182>] ? init_netconsole+0x182/0x210 [netconsole]
[  775.957016]  [<ffffffffa0103000>] ? 0xffffffffa0102fff
[  775.957018]  [<ffffffff81002085>] ? do_one_initcall+0x75/0x12c
[  775.957019]  [<ffffffff81077b35>] ? sys_init_module+0x80/0x1c5
[  775.957020]  [<ffffffff813319b9>] ? system_call_fastpath+0x16/0x1b


Cheers,

    Sylvain
