From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sun, 10 May 2009 09:43:28 +0200
Message-ID: <4A0685A0.8020002@cosmosbay.com>
References: <20090508.144859.152310605.davem@davemloft.net>	<4A057387.4080308@cosmosbay.com>	<20090509.133454.111098477.davem@davemloft.net> <20090509.134002.258408495.davem@davemloft.net> <4A067D9E.7050706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54771 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbZEJHnj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 03:43:39 -0400
In-Reply-To: <4A067D9E.7050706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: David Miller <davem@davemloft.net>
>> Date: Sat, 09 May 2009 13:34:54 -0700 (PDT)
>>
>>> Consider the case where we always send some message on CPU A and
>>> then process the ACK on CPU B.  We'll always be cancelling the
>>> timer on a foreign cpu.
>> I should also mention that TCP has a peculiar optimization of timers
>> that is likely being thwarted by your workload.  It never deletes
>> timers under normal operation, it simply lets them still expire
>> and the handler notices that there is "nothing to do" and returns.
>=20
> Yes, you refer to INET_CSK_CLEAR_TIMERS condition, never set.
>=20
>> But when the connection does shut down, we have to purge all of
>> these timers.
>>
>> That could be another part of why you see timers in your profile.
>>
>>
>=20
> Well, in my workload they should never expire, since application exch=
ange
> enough data on both direction, and they are no losses (Gigabit LAN co=
ntext)
>=20
> On machine acting as a server (the one I am focusing to, of course),
> each incoming frame :
>=20
> - Contains ACK for the previous sent frame
> - Contains data provided by the client.
> - Starts a timer for delayed ACK
>=20
> Then server applications reacts and sends a new payload, and TCP stac=
k
> - Sends a frame including ACK for previous received frame
> - Contains data provided by server application
> - Starts a timer for retransmiting this frame if no ACK is received l=
ater.
>=20
> So yes, each incoming and each outgoing frame is going to call mod_ti=
mer()
>=20
> Problem is that incoming process is done by CPU 0 (the one that is de=
dicated
> to NAPI processing because of stress situation, cpu 100% in softirq l=
and),
> and outgoing processing done by other cpus in the machine.
>=20
> offsetof(struct inet_connection_sock, icsk_retransmit_timer)=3D0x208
> offsetof(struct inet_connection_sock, icsk_delack_timer)=3D0x238
>=20
> So there are cache line ping-pongs, but oprofile seems to point
> to a spinlock contention in lock_timer_base(), I dont know why...
> shouldnt (in my workload) delack_timer all belongs to cpu 0, and=20
> retransmit_timers to other cpus ?=20
>=20
> Or is mod_timer never migrates an already established timer ?
>=20
> That would explain the lock contention on timer_base, we should
> take care of it if possible.
>=20

ftrace is my friend :)

Problem is the application, when doing it recv() call
is calling tcp_send_delayed_ack() too.

So yes, cpus are fighting on icsk_delack_timer and their
timer_base pretty hard.


2631.936051: finish_task_switch <-schedule
2631.936051: perf_counter_task_sched_in <-finish_task_switch
2631.936051: __perf_counter_sched_in <-perf_counter_task_sched_in
2631.936051: _spin_lock <-__perf_counter_sched_in
2631.936052: lock_sock_nested <-sk_wait_data
2631.936052: _spin_lock_bh <-lock_sock_nested
2631.936052: local_bh_disable <-_spin_lock_bh
2631.936052: local_bh_enable <-lock_sock_nested
2631.936052: finish_wait <-sk_wait_data
2631.936053: tcp_prequeue_process <-tcp_recvmsg
2631.936053: local_bh_disable <-tcp_prequeue_process
2631.936053: tcp_v4_do_rcv <-tcp_prequeue_process
2631.936053: tcp_rcv_established <-tcp_v4_do_rcv
2631.936054: local_bh_enable <-tcp_rcv_established
2631.936054: skb_copy_datagram_iovec <-tcp_rcv_established
2631.936054: memcpy_toiovec <-skb_copy_datagram_iovec
2631.936054: copy_to_user <-memcpy_toiovec
2631.936054: tcp_rcv_space_adjust <-tcp_rcv_established
2631.936055: local_bh_disable <-tcp_rcv_established
2631.936055: tcp_event_data_recv <-tcp_rcv_established
2631.936055: tcp_ack <-tcp_rcv_established
2631.936056: __kfree_skb <-tcp_ack
2631.936056: skb_release_head_state <-__kfree_skb
2631.936056: dst_release <-skb_release_head_state
2631.936056: skb_release_data <-__kfree_skb
2631.936056: put_page <-skb_release_data
2631.936057: kfree <-skb_release_data
2631.936057: kmem_cache_free <-__kfree_skb
2631.936057: tcp_valid_rtt_meas <-tcp_ack
2631.936058: bictcp_acked <-tcp_ack
2631.936058: bictcp_cong_avoid <-tcp_ack
2631.936058: tcp_is_cwnd_limited <-bictcp_cong_avoid
2631.936058: tcp_current_mss <-tcp_rcv_established
2631.936058: tcp_established_options <-tcp_current_mss
2631.936058: __tcp_push_pending_frames <-tcp_rcv_established
2631.936059: __tcp_ack_snd_check <-tcp_rcv_established
2631.936059: tcp_send_delayed_ack <-__tcp_ack_snd_check
2631.936059: sk_reset_timer <-tcp_send_delayed_ack
2631.936059: mod_timer <-sk_reset_timer
2631.936059: lock_timer_base <-mod_timer
2631.936059: _spin_lock_irqsave <-lock_timer_base
2631.936059: _spin_lock <-mod_timer
2631.936060: internal_add_timer <-mod_timer
2631.936064: _spin_unlock_irqrestore <-mod_timer
2631.936064: __kfree_skb <-tcp_rcv_established
2631.936064: skb_release_head_state <-__kfree_skb
2631.936064: dst_release <-skb_release_head_state
2631.936065: skb_release_data <-__kfree_skb
2631.936065: kfree <-skb_release_data
2631.936065: __slab_free <-kfree
2631.936065: add_partial <-__slab_free
2631.936065: _spin_lock <-add_partial
2631.936066: kmem_cache_free <-__kfree_skb
2631.936066: __slab_free <-kmem_cache_free
2631.936066: add_partial <-__slab_free
2631.936067: _spin_lock <-add_partial
2631.936067: local_bh_enable <-tcp_prequeue_process
2631.936067: tcp_cleanup_rbuf <-tcp_recvmsg
2631.936067: __tcp_select_window <-tcp_cleanup_rbuf
2631.936067: release_sock <-tcp_recvmsg
2631.936068: _spin_lock_bh <-release_sock
2631.936068: local_bh_disable <-_spin_lock_bh
2631.936068: _spin_unlock_bh <-release_sock
2631.936068: local_bh_enable_ip <-_spin_unlock_bh
2631.936068: fput <-sys_recvfrom

