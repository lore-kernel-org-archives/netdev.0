From: Arjun V <arjun@chelsio.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Mon, 27 Jun 2016 12:47:51 +0530
Message-ID: <20160627071750.GA13304@v4.asicdesigners.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:44435 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750870AbcF0HTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 03:19:18 -0400
Content-Disposition: inline
In-Reply-To: <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, June 06/24/16, 2016 at 21:55:07 +0530, Eric Dumazet wrote:
> On Fri, 2016-06-24 at 07:25 -0700, Eric Dumazet wrote:
> > Please do not top post on netdev mailing list
> > 
> > On Fri, Jun 24, 2016 at 4:38 AM, Arjun V. <arjun@chelsio.com> wrote:
> > > Eric,
> > > We are seeing skb's with length(skb->len) greater than 65536 coming into our ndo_start_xmit() callback routine.
> > > We can add a check in our eth_xmit() routine to skip those packets, but it will be better if you fix this in kernel.
> > >
> > >
> > > I have attached pcap file obtained from tcpdump. In the pcap file there are 2 such packets(I used tcpdump filter to extract out those packets).
> > >
> > > Let us know if you need anything else.
> > >
> > 
> > Beats me really.
> > 
> > At retransmit time, we only can eventually reduce packet sizes
> > (assuming GSO is used, because we might coalesce sub-mss packets in
> > tcp_retrans_try_collapse())
> > 
> > So why are you seeing too big packets at retransmit, I really have no idea.
> > 
> > MIght be some bug related to MSS computation, overflowing somehow ?
> 
> Could you try this ?
> 
> Thanks !
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index d39e9e47a26e55ad2b8f775bf9ea9dfb5b12aee5..27013056bcfb9aa49601806bb3aa55a1ac664873 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1177,6 +1177,7 @@ int inet_sk_rebuild_header(struct sock *sk)
>  
>  		/* Routing failed... */
>  		sk->sk_route_caps = 0;
> +		sk->sk_gso_max_segs = 1;
>  		/*
>  		 * Other protocols have to map its equivalent state to TCP_SYN_SENT.
>  		 * DCCP maps its DCCP_REQUESTING state to TCP_SYN_SENT. -acme
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 2076c21107d07e4e78a0a29f1d374c3414b8e1bd..ecc0281acfb702b138c68ac51e3a0518052785b0 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -685,6 +685,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
>  		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
>  		if (IS_ERR(dst)) {
>  			sk->sk_route_caps = 0;
> +			sk->sk_gso_max_segs = 1;
>  			sk->sk_err_soft = -PTR_ERR(dst);
>  			return PTR_ERR(dst);
>  		}
> 
> 
> 
> 
Eric,

Thanks for the quick patch. It didn't help much. We still see packets larger than 65536 with the patch.

Below is the dump_stack() trace I am seeing for packets larger than 65536 in our xmit routine:

[  619.094366] CPU: 5 PID: 19322 Comm: netperf Not tainted 4.7.0-rc2+ #85
[  619.094373] Hardware name: Supermicro Super Server/X10SRi-F, BIOS 1.0b 04/21/2015
[  619.094379]  0000000000000001 ffff88067fd42c58 ffffffff81534635 ffff88065b59c2e0
[  619.094393]  ffff88065b520000 ffff8806570e1ae0 ffff88065b520000 ffff88067fd42d68
[  619.094404]  ffffffffa001cbee 000005f27fd42ca8 ffff880600000005 ffff880600000300
[  619.094417] Call Trace:
[  619.094421]  <IRQ>  [<ffffffff81534635>] dump_stack+0xa5/0xe0
[  619.094445]  [<ffffffffa001cbee>] t4_eth_xmit+0x43e/0xd90 [cxgb4]
[  619.094455]  [<ffffffff81187fa9>] ? trace_clock_local+0x9/0x10
[  619.094461]  [<ffffffff81198672>] ? rb_reserve_next_event+0x642/0x750
[  619.094469]  [<ffffffff81aee5ed>] dev_hard_start_xmit+0x15d/0x460
[  619.094475]  [<ffffffff81aedb80>] ? __netdev_pick_tx+0x170/0x1f0
[  619.094482]  [<ffffffff81af58ff>] ? validate_xmit_skb_list+0x4f/0xc0
[  619.094489]  [<ffffffff81b2b861>] sch_direct_xmit+0x221/0x2b0
[  619.094497]  [<ffffffff81af602c>] __dev_queue_xmit+0x6bc/0x9a0
[  619.094504]  [<ffffffff81bf79bf>] ? ipt_do_table+0x30f/0x620
[  619.094512]  [<ffffffff81af6330>] dev_queue_xmit+0x10/0x20
[  619.094518]  [<ffffffff81b774f9>] ip_finish_output2+0x459/0x570
[  619.094525]  [<ffffffff81b426c4>] ? nf_iterate+0xa4/0x110
[  619.094531]  [<ffffffff81b426c4>] ? nf_iterate+0xa4/0x110
[  619.094538]  [<ffffffff81b7973b>] ip_finish_output+0x1eb/0x330
[  619.094545]  [<ffffffff81b798f4>] ip_output+0x74/0x110
[  619.094552]  [<ffffffff81b78802>] ? __ip_local_out+0xb2/0x100
[  619.094557]  [<ffffffff81b79550>] ? ip_queue_xmit+0x4f0/0x4f0
[  619.094564]  [<ffffffff81b788d1>] ip_local_out+0x81/0xa0
[  619.094571]  [<ffffffff81b792b1>] ip_queue_xmit+0x251/0x4f0
[  619.094579]  [<ffffffff81b9bf19>] ? tcp_options_write+0x279/0x350
[  619.094585]  [<ffffffff81b9c7bb>] tcp_transmit_skb+0x7cb/0xe70
[  619.094592]  [<ffffffff81b9ef03>] ? tcp_current_mss+0x53/0xc0
[  619.094599]  [<ffffffff81b9f815>] __tcp_retransmit_skb+0x2e5/0x9c0
[  619.094607]  [<ffffffff810cb4a6>] ? get_nohz_timer_target+0x26/0x140
[  619.094613]  [<ffffffff81b9ff07>] tcp_retransmit_skb+0x17/0x100
[  619.094620]  [<ffffffff81ba046e>] tcp_xmit_retransmit_queue+0x47e/0x670
[  619.094626]  [<ffffffff81b8e753>] tcp_xmit_recovery+0xa3/0xb0
[  619.094631]  [<ffffffff81b98897>] tcp_ack+0xd67/0x1e70
[  619.094639]  [<ffffffff81b9634f>] ? tcp_validate_incoming+0x7f/0x560
[  619.094646]  [<ffffffff81b99af2>] tcp_rcv_established+0x152/0x780
[  619.094654]  [<ffffffff81baa13e>] tcp_v4_do_rcv+0x10e/0x3a0
[  619.094661]  [<ffffffff81bab24d>] tcp_v4_rcv+0xe7d/0xf20
[  619.094667]  [<ffffffff81bf4f93>] ? ipv4_confirm+0x133/0x1d0
[  619.094673]  [<ffffffff81b426c4>] ? nf_iterate+0xa4/0x110
[  619.094680]  [<ffffffff81b70138>] ip_local_deliver_finish+0xc8/0x2c0
[  619.094686]  [<ffffffff81b703f8>] ip_local_deliver+0xc8/0x140
[  619.094692]  [<ffffffff81ba9f02>] ? tcp_v4_early_demux+0x162/0x290
[  619.094697]  [<ffffffff81b70070>] ? ip_call_ra_chain+0x220/0x220
[  619.094703]  [<ffffffff81b6fc5f>] ip_rcv_finish+0x3ef/0x5e0
[  619.094709]  [<ffffffff81b4294a>] ? nf_hook_slow+0x4a/0x1b0
[  619.094714]  [<ffffffff81b70abb>] ip_rcv+0x64b/0x750
[  619.094721]  [<ffffffff81b6f870>] ? inet_add_protocol+0x60/0x60
[  619.094727]  [<ffffffff81af1e93>] __netif_receive_skb_core+0xd53/0x13e0
[  619.094735]  [<ffffffff81bb325f>] ? tcp4_gro_receive+0xef/0x2d0
[  619.094743]  [<ffffffff81bcd256>] ? inet_gro_receive+0x3b6/0x4e0
[  619.094749]  [<ffffffff81ae794a>] ? gro_pull_from_frag0+0x16a/0x190
[  619.094755]  [<ffffffff81af25a5>] __netif_receive_skb+0x85/0xe0
[  619.094762]  [<ffffffff81af2928>] netif_receive_skb_internal+0xf8/0x160
[  619.094768]  [<ffffffff81ae789d>] ? gro_pull_from_frag0+0xbd/0x190
[  619.094774]  [<ffffffff81b29f6c>] ? eth_type_trans+0x14c/0x280
[  619.094780]  [<ffffffff81af44d5>] napi_gro_frags+0x3e5/0x400
[  619.094792]  [<ffffffffa001bd85>] t4_ethrx_handler+0x8e5/0x9f0 [cxgb4]
[  619.094799]  [<ffffffff81b796c9>] ? ip_finish_output+0x179/0x330
[  619.094809]  [<ffffffffa001af55>] process_responses+0x735/0x8b0 [cxgb4]
[  619.094815]  [<ffffffff81b798f4>] ? ip_output+0x74/0x110
[  619.094822]  [<ffffffff81b788d1>] ? ip_local_out+0x81/0xa0
[  619.094828]  [<ffffffff8103e532>] ? native_sched_clock+0x82/0x1a0
[  619.094834]  [<ffffffff81187fa9>] ? trace_clock_local+0x9/0x10
[  619.094840]  [<ffffffff81198672>] ? rb_reserve_next_event+0x642/0x750
[  619.094849]  [<ffffffff81193e82>] ? rb_set_commit_to_write+0x212/0x350
[  619.094861]  [<ffffffffa001b186>] napi_rx_handler+0xb6/0x260 [cxgb4]
[  619.094868]  [<ffffffff81af3b4c>] napi_poll+0x1fc/0x3d0
[  619.094873]  [<ffffffff81198985>] ? ring_buffer_lock_reserve+0x205/0x260
[  619.094881]  [<ffffffff811933b3>] ? rb_event_data+0x53/0xa0
[  619.094886]  [<ffffffff81af3e1e>] net_rx_action+0xfe/0x2f0
[  619.094893]  [<ffffffff811b88e9>] ? trace_event_buffer_commit+0x179/0x2b0
[  619.094901]  [<ffffffff8109b225>] ? trace_event_raw_event_softirq+0x115/0x150
[  619.094909]  [<ffffffff81deed4d>] __do_softirq+0x1cd/0x4e1
[  619.094916]  [<ffffffff8109a868>] ? irq_exit+0x58/0x110
[  619.094925]  [<ffffffff81dedf1c>] do_softirq_own_stack+0x1c/0x30
[  619.094929]  <EOI>  [<ffffffff8109a458>] do_softirq+0x68/0x70
[  619.094940]  [<ffffffff8109a629>] __local_bh_enable_ip+0xf9/0x160
[  619.094946]  [<ffffffff81bf79bf>] ipt_do_table+0x30f/0x620
[  619.094954]  [<ffffffff81bfae3f>] iptable_mangle_hook+0xef/0x1d0
[  619.094960]  [<ffffffff81b426c4>] nf_iterate+0xa4/0x110
[  619.094966]  [<ffffffff81b4294a>] nf_hook_slow+0x4a/0x1b0
[  619.094972]  [<ffffffff81b7884b>] __ip_local_out+0xfb/0x100
[  619.094978]  [<ffffffff81b74f00>] ? neigh_key_eq32+0x20/0x20
[  619.094984]  [<ffffffff81b78882>] ip_local_out+0x32/0xa0
[  619.094990]  [<ffffffff81b792b1>] ip_queue_xmit+0x251/0x4f0
[  619.094997]  [<ffffffff81b9bf19>] ? tcp_options_write+0x279/0x350
[  619.095003]  [<ffffffff81b9c7bb>] tcp_transmit_skb+0x7cb/0xe70
[  619.095010]  [<ffffffff81b9e942>] tcp_send_ack+0x182/0x1c0
[  619.095016]  [<ffffffff81b96093>] __tcp_ack_snd_check+0x63/0x100
[  619.095023]  [<ffffffff81b99d9f>] tcp_rcv_established+0x3ff/0x780
[  619.095029]  [<ffffffff81baa13e>] tcp_v4_do_rcv+0x10e/0x3a0
[  619.095035]  [<ffffffff81b86969>] tcp_prequeue_process+0x169/0x190
[  619.095042]  [<ffffffff81b84e32>] ? tcp_cleanup_rbuf+0x72/0x280
[  619.095049]  [<ffffffff81b8b6ed>] tcp_recvmsg+0xfed/0x12d0
[  619.095057]  [<ffffffff812bb776>] ? __fget_light+0x96/0x100
[  619.095064]  [<ffffffff81bcc4b9>] inet_recvmsg+0xa9/0xe0
[  619.095071]  [<ffffffff81ac13da>] sock_recvmsg+0x4a/0x60
[  619.095078]  [<ffffffff81ac343d>] SYSC_recvfrom+0x13d/0x1d0
[  619.095085]  [<ffffffff8100276e>] ? do_audit_syscall_entry+0xae/0xe0
[  619.095093]  [<ffffffff81002a1e>] ? syscall_trace_enter_phase2+0x27e/0x2f0
[  619.095100]  [<ffffffff81ac34de>] SyS_recvfrom+0xe/0x10
[  619.095105]  [<ffffffff81003426>] do_syscall_64+0xa6/0x170
[  619.095111]  [<ffffffff81002479>] ? prepare_exit_to_usermode+0x49/0x80
[  619.095118]  [<ffffffff81dec4fc>] entry_SYSCALL64_slow_path+0x25/0x25

Thanks,
Arjun.
