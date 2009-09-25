From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Fri, 25 Sep 2009 16:19:58 +0200
Message-ID: <4ABCD18E.2010501@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com> <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1> <4AAF263E.9010405@gmail.com> <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1> <4AAFCE3A.8060102@gmail.com> <alpine.DEB.1.10.0909151550200.3340@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51553 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbZIYOU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 10:20:29 -0400
In-Reply-To: <alpine.DEB.1.10.0909151550200.3340@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :

> We sacrificed 2 - 3 microseconds per message to kernel features, bloa=
t and
> 64 bitness?

Update :

With my current kernel on receiver (linux-2.6 32bit + some networking p=
atches + SLUB_STATS)
mcast -n1 -b eth3 -r 2000 on the sender (2.6.29 unfortunatly, I cannot =
change it at this moment)


I took a look at ftrace(function) to check paths :
(tg3 instead of bnx2 on this snapshot, it should not be a big concern)

- tg3 interrupts on CPU-0, copybreak disabled.

Hardware interrupt
------------------
          <idle>-0     [000] 13580.504033: do_IRQ <-common_interrupt
          <idle>-0     [000] 13580.504034: irq_enter <-do_IRQ
          <idle>-0     [000] 13580.504034: rcu_irq_enter <-irq_enter
          <idle>-0     [000] 13580.504034: idle_cpu <-irq_enter
          <idle>-0     [000] 13580.504034: tick_check_idle <-irq_enter
          <idle>-0     [000] 13580.504034: tick_check_oneshot_broadcast=
 <-tick_check_idle
          <idle>-0     [000] 13580.504034: tick_nohz_stop_idle <-tick_c=
heck_idle
          <idle>-0     [000] 13580.504034: ktime_get <-tick_nohz_stop_i=
dle
          <idle>-0     [000] 13580.504035: ktime_get <-sched_clock_tick
          <idle>-0     [000] 13580.504035: touch_softlockup_watchdog <-=
sched_clock_idle_wakeup_event
          <idle>-0     [000] 13580.504035: ktime_get <-tick_check_idle
          <idle>-0     [000] 13580.504035: tick_do_update_jiffies64 <-t=
ick_check_idle
          <idle>-0     [000] 13580.504035: _spin_lock <-tick_do_update_=
jiffies64
          <idle>-0     [000] 13580.504036: do_timer <-tick_do_update_ji=
ffies64
          <idle>-0     [000] 13580.504036: update_wall_time <-do_timer
          <idle>-0     [000] 13580.504036: calc_global_load <-do_timer
          <idle>-0     [000] 13580.504036: touch_softlockup_watchdog <-=
tick_check_idle
          <idle>-0     [000] 13580.504036: handle_irq <-do_IRQ
          <idle>-0     [000] 13580.504036: irq_to_desc <-handle_irq
          <idle>-0     [000] 13580.504036: handle_edge_irq <-handle_irq
          <idle>-0     [000] 13580.504037: _spin_lock <-handle_edge_irq
          <idle>-0     [000] 13580.504037: ack_apic_edge <-handle_edge_=
irq
          <idle>-0     [000] 13580.504037: irq_to_desc <-ack_apic_edge
          <idle>-0     [000] 13580.504037: irq_complete_move <-ack_apic=
_edge
          <idle>-0     [000] 13580.504037: move_native_irq <-ack_apic_e=
dge
          <idle>-0     [000] 13580.504037: irq_to_desc <-move_native_ir=
q
          <idle>-0     [000] 13580.504038: native_apic_mem_write <-ack_=
apic_edge
          <idle>-0     [000] 13580.504038: handle_IRQ_event <-handle_ed=
ge_irq

2) Handled by tg3
          <idle>-0     [000] 13580.504038: tg3_msi <-handle_IRQ_event
          <idle>-0     [000] 13580.504038: tg3_write32 <-tg3_msi
          <idle>-0     [000] 13580.504038: __napi_schedule <-tg3_msi
          <idle>-0     [000] 13580.504038: note_interrupt <-handle_edge=
_irq
          <idle>-0     [000] 13580.504039: _spin_lock <-handle_edge_irq
          <idle>-0     [000] 13580.504039: irq_exit <-do_IRQ

3) Softirq
          <idle>-0     [000] 13580.504039: do_softirq <-irq_exit
          <idle>-0     [000] 13580.504039: __do_softirq <-do_softirq
          <idle>-0     [000] 13580.504039: net_rx_action <-__do_softirq
          <idle>-0     [000] 13580.504039: tg3_poll <-net_rx_action
          <idle>-0     [000] 13580.504040: tg3_alloc_rx_skb <-tg3_poll
          <idle>-0     [000] 13580.504040: __netdev_alloc_skb <-tg3_all=
oc_rx_skb
          <idle>-0     [000] 13580.504040: __alloc_skb <-__netdev_alloc=
_skb
          <idle>-0     [000] 13580.504040: kmem_cache_alloc <-__alloc_s=
kb
          <idle>-0     [000] 13580.504040: __kmalloc_track_caller <-__a=
lloc_skb
          <idle>-0     [000] 13580.504040: get_slab <-__kmalloc_track_c=
aller
          <idle>-0     [000] 13580.504040: __slab_alloc <-__kmalloc_tra=
ck_caller

hmm... is it normal we call deactivate_slab() ?
(I included at the end of this mail : grep . /sys/kernel/slab/:t-000409=
6/* )

          <idle>-0     [000] 13580.504041: deactivate_slab <-__slab_all=
oc
          <idle>-0     [000] 13580.504041: _spin_lock <-__slab_alloc
          <idle>-0     [000] 13580.504041: nommu_map_page <-tg3_alloc_r=
x_skb
          <idle>-0     [000] 13580.504041: skb_put <-tg3_poll
          <idle>-0     [000] 13580.504041: eth_type_trans <-tg3_poll
          <idle>-0     [000] 13580.504041: skb_pull <-eth_type_trans
          <idle>-0     [000] 13580.504042: napi_gro_receive <-tg3_poll
          <idle>-0     [000] 13580.504042: skb_gro_reset_offset <-napi_=
gro_receive
          <idle>-0     [000] 13580.504042: __napi_gro_receive <-napi_gr=
o_receive
          <idle>-0     [000] 13580.504042: dev_gro_receive <-__napi_gro=
_receive
          <idle>-0     [000] 13580.504042: napi_skb_finish <-napi_gro_r=
eceive
          <idle>-0     [000] 13580.504042: netif_receive_skb <-napi_skb=
_finish
          <idle>-0     [000] 13580.504043: ip_rcv <-netif_receive_skb

firewall (iptables) phase 1 (mangle prerouting)

          <idle>-0     [000] 13580.504043: nf_hook_slow <-ip_rcv
          <idle>-0     [000] 13580.504043: nf_iterate <-nf_hook_slow
          <idle>-0     [000] 13580.504043: ipt_pre_routing_hook <-nf_it=
erate
          <idle>-0     [000] 13580.504043: ipt_do_table <-ipt_pre_routi=
ng_hook
          <idle>-0     [000] 13580.504043: local_bh_disable <-ipt_do_ta=
ble
          <idle>-0     [000] 13580.504044: _spin_lock <-ipt_do_table
          <idle>-0     [000] 13580.504044: local_bh_enable <-ipt_do_tab=
le
          <idle>-0     [000] 13580.504044: ip_rcv_finish <-ip_rcv
          <idle>-0     [000] 13580.504044: ip_route_input <-ip_rcv_fini=
sh
          <idle>-0     [000] 13580.504044: ip_local_deliver <-ip_rcv_fi=
nish
firewall (iptables) phase 2  (mangle INPUT)
          <idle>-0     [000] 13580.504045: nf_hook_slow <-ip_local_deli=
ver
          <idle>-0     [000] 13580.504045: nf_iterate <-nf_hook_slow
          <idle>-0     [000] 13580.504045: ipt_local_in_hook <-nf_itera=
te
          <idle>-0     [000] 13580.504045: ipt_do_table <-ipt_local_in_=
hook
          <idle>-0     [000] 13580.504045: local_bh_disable <-ipt_do_ta=
ble
          <idle>-0     [000] 13580.504045: _spin_lock <-ipt_do_table
          <idle>-0     [000] 13580.504045: local_bh_enable <-ipt_do_tab=
le
firewall (iptables) phase 3  (filter INPUT)
          <idle>-0     [000] 13580.504046: ipt_local_in_hook <-nf_itera=
te
          <idle>-0     [000] 13580.504046: ipt_do_table <-ipt_local_in_=
hook
          <idle>-0     [000] 13580.504046: local_bh_disable <-ipt_do_ta=
ble
          <idle>-0     [000] 13580.504046: _spin_lock <-ipt_do_table
          <idle>-0     [000] 13580.504046: local_bh_enable <-ipt_do_tab=
le
          <idle>-0     [000] 13580.504046: ip_local_deliver_finish <-ip=
_local_deliver
          <idle>-0     [000] 13580.504046: raw_local_deliver <-ip_local=
_deliver_finish

OK , UDP handler...

          <idle>-0     [000] 13580.504047: udp_rcv <-ip_local_deliver_f=
inish
          <idle>-0     [000] 13580.504047: __udp4_lib_rcv <-udp_rcv
          <idle>-0     [000] 13580.504047: _spin_lock <-__udp4_lib_rcv
          <idle>-0     [000] 13580.504047: ip_mc_sf_allow <-__udp4_lib_=
rcv
          <idle>-0     [000] 13580.504047: udp_queue_rcv_skb <-__udp4_l=
ib_rcv
          <idle>-0     [000] 13580.504047: _spin_lock <-udp_queue_rcv_s=
kb
          <idle>-0     [000] 13580.504048: __udp_queue_rcv_skb <-udp_qu=
eue_rcv_skb
          <idle>-0     [000] 13580.504048: sock_queue_rcv_skb <-__udp_q=
ueue_rcv_skb

          <idle>-0     [000] 13580.504048: sk_filter <-sock_queue_rcv_s=
kb
          <idle>-0     [000] 13580.504048: local_bh_disable <-sk_filter
          <idle>-0     [000] 13580.504048: local_bh_enable <-sk_filter

          <idle>-0     [000] 13580.504048: skb_queue_tail <-sock_queue_=
rcv_skb
          <idle>-0     [000] 13580.504049: _spin_lock_irqsave <-skb_que=
ue_tail
          <idle>-0     [000] 13580.504049: _spin_unlock_irqrestore <-sk=
b_queue_tail
          <idle>-0     [000] 13580.504049: sock_def_readable <-sock_que=
ue_rcv_skb
          <idle>-0     [000] 13580.504049: _read_lock <-sock_def_readab=
le
          <idle>-0     [000] 13580.504049: __wake_up_sync_key <-sock_de=
f_readable
          <idle>-0     [000] 13580.504049: _spin_lock_irqsave <-__wake_=
up_sync_key
          <idle>-0     [000] 13580.504049: __wake_up_common <-__wake_up=
_sync_key
          <idle>-0     [000] 13580.504050: receiver_wake_function <-__w=
ake_up_common
          <idle>-0     [000] 13580.504050: autoremove_wake_function <-r=
eceiver_wake_function
          <idle>-0     [000] 13580.504050: default_wake_function <-auto=
remove_wake_function

wakeup mcast task

          <idle>-0     [000] 13580.504050: try_to_wake_up <-default_wak=
e_function
          <idle>-0     [000] 13580.504050: task_rq_lock <-try_to_wake_u=
p
          <idle>-0     [000] 13580.504050: _spin_lock <-task_rq_lock
          <idle>-0     [000] 13580.504051: _spin_unlock_irqrestore <-tr=
y_to_wake_up
          <idle>-0     [000] 13580.504051: select_task_rq_fair <-try_to=
_wake_up
          <idle>-0     [000] 13580.504051: task_rq_lock <-try_to_wake_u=
p
          <idle>-0     [000] 13580.504051: _spin_lock <-task_rq_lock
          <idle>-0     [000] 13580.504051: activate_task <-try_to_wake_=
up
          <idle>-0     [000] 13580.504051: enqueue_task <-activate_task
          <idle>-0     [000] 13580.504052: enqueue_task_fair <-enqueue_=
task
          <idle>-0     [000] 13580.504052: update_curr <-enqueue_task_f=
air
          <idle>-0     [000] 13580.504052: place_entity <-enqueue_task_=
fair
          <idle>-0     [000] 13580.504052: __enqueue_entity <-enqueue_t=
ask_fair
          <idle>-0     [000] 13580.504052: check_preempt_curr_idle <-tr=
y_to_wake_up
          <idle>-0     [000] 13580.504053: resched_task <-check_preempt=
_curr_idle
          <idle>-0     [000] 13580.504053: _spin_unlock_irqrestore <-tr=
y_to_wake_up
          <idle>-0     [000] 13580.504053: _spin_unlock_irqrestore <-__=
wake_up_sync_key

tg3 finished its rx handling

          <idle>-0     [000] 13580.504053: tg3_write32 <-tg3_poll
          <idle>-0     [000] 13580.504053: tg3_write32 <-tg3_poll
          <idle>-0     [000] 13580.504054: napi_complete <-tg3_poll
          <idle>-0     [000] 13580.504054: napi_gro_flush <-napi_comple=
te
          <idle>-0     [000] 13580.504054: __napi_complete <-napi_compl=
ete
          <idle>-0     [000] 13580.504054: tg3_write32 <-tg3_poll
          <idle>-0     [000] 13580.504054: rcu_bh_qs <-__do_softirq
          <idle>-0     [000] 13580.504054: _local_bh_enable <-__do_soft=
irq
          <idle>-0     [000] 13580.504055: rcu_irq_exit <-irq_exit
          <idle>-0     [000] 13580.504055: idle_cpu <-irq_exit
          <idle>-0     [000] 13580.504055: tick_nohz_restart_sched_tick=
 <-cpu_idle
          <idle>-0     [000] 13580.504055: tick_nohz_stop_idle <-tick_n=
ohz_restart_sched_tick
          <idle>-0     [000] 13580.504055: rcu_exit_nohz <-tick_nohz_re=
start_sched_tick
          <idle>-0     [000] 13580.504055: select_nohz_load_balancer <-=
tick_nohz_restart_sched_tick
          <idle>-0     [000] 13580.504056: ktime_get <-tick_nohz_restar=
t_sched_tick
          <idle>-0     [000] 13580.504056: tick_do_update_jiffies64 <-t=
ick_nohz_restart_sched_tick
          <idle>-0     [000] 13580.504056: account_idle_ticks <-tick_no=
hz_restart_sched_tick
          <idle>-0     [000] 13580.504056: account_idle_time <-account_=
idle_ticks
          <idle>-0     [000] 13580.504056: touch_softlockup_watchdog <-=
tick_nohz_restart_sched_tick
          <idle>-0     [000] 13580.504056: hrtimer_cancel <-tick_nohz_r=
estart_sched_tick
          <idle>-0     [000] 13580.504056: hrtimer_try_to_cancel <-hrti=
mer_cancel
          <idle>-0     [000] 13580.504057: lock_hrtimer_base <-hrtimer_=
try_to_cancel
          <idle>-0     [000] 13580.504057: _spin_lock_irqsave <-lock_hr=
timer_base
          <idle>-0     [000] 13580.504057: __remove_hrtimer <-hrtimer_t=
ry_to_cancel
          <idle>-0     [000] 13580.504057: hrtimer_force_reprogram <-__=
remove_hrtimer
          <idle>-0     [000] 13580.504057: tick_program_event <-hrtimer=
_force_reprogram
          <idle>-0     [000] 13580.504058: tick_dev_program_event <-tic=
k_program_event
          <idle>-0     [000] 13580.504058: ktime_get <-tick_dev_program=
_event
          <idle>-0     [000] 13580.504058: clockevents_program_event <-=
tick_dev_program_event
          <idle>-0     [000] 13580.504058: lapic_next_event <-clockeven=
ts_program_event
          <idle>-0     [000] 13580.504058: native_apic_mem_write <-lapi=
c_next_event
          <idle>-0     [000] 13580.504058: _spin_unlock_irqrestore <-hr=
timer_try_to_cancel
          <idle>-0     [000] 13580.504058: hrtimer_forward <-tick_nohz_=
restart_sched_tick
          <idle>-0     [000] 13580.504059: ktime_add_safe <-hrtimer_for=
ward
          <idle>-0     [000] 13580.504059: ktime_add_safe <-hrtimer_for=
ward
          <idle>-0     [000] 13580.504059: hrtimer_start_range_ns <-tic=
k_nohz_restart_sched_tick
          <idle>-0     [000] 13580.504059: __hrtimer_start_range_ns <-h=
rtimer_start_range_ns
          <idle>-0     [000] 13580.504059: lock_hrtimer_base <-__hrtime=
r_start_range_ns
          <idle>-0     [000] 13580.504059: _spin_lock_irqsave <-lock_hr=
timer_base
          <idle>-0     [000] 13580.504060: ktime_add_safe <-__hrtimer_s=
tart_range_ns
          <idle>-0     [000] 13580.504060: enqueue_hrtimer <-__hrtimer_=
start_range_ns
          <idle>-0     [000] 13580.504060: tick_program_event <-__hrtim=
er_start_range_ns
          <idle>-0     [000] 13580.504060: tick_dev_program_event <-tic=
k_program_event
          <idle>-0     [000] 13580.504060: ktime_get <-tick_dev_program=
_event
          <idle>-0     [000] 13580.504061: clockevents_program_event <-=
tick_dev_program_event
          <idle>-0     [000] 13580.504061: lapic_next_event <-clockeven=
ts_program_event
          <idle>-0     [000] 13580.504061: native_apic_mem_write <-lapi=
c_next_event
          <idle>-0     [000] 13580.504061: _spin_unlock_irqrestore <-__=
hrtimer_start_range_ns
          <idle>-0     [000] 13580.504061: schedule <-cpu_idle
          <idle>-0     [000] 13580.504061: rcu_sched_qs <-schedule
          <idle>-0     [000] 13580.504061: _spin_lock_irq <-schedule
          <idle>-0     [000] 13580.504062: put_prev_task_idle <-schedul=
e
          <idle>-0     [000] 13580.504062: pick_next_task_fair <-schedu=
le
          <idle>-0     [000] 13580.504062: set_next_entity <-pick_next_=
task_fair
          <idle>-0     [000] 13580.504062: update_stats_wait_end <-set_=
next_entity
          <idle>-0     [000] 13580.504062: __dequeue_entity <-set_next_=
entity
          <idle>-0     [000] 13580.504062: hrtick_start_fair <-pick_nex=
t_task_fair
          <idle>-0     [000] 13580.504063: perf_event_task_sched_out <-=
schedule
          <idle>-0     [000] 13580.504063: __switch_to <-schedule


mcast is scheduled, gets the frame

           mcast-21429 [000] 13580.504063: finish_task_switch <-schedul=
e
           mcast-21429 [000] 13580.504063: perf_event_task_sched_in <-f=
inish_task_switch
           mcast-21429 [000] 13580.504063: finish_wait <-__skb_recv_dat=
agram
           mcast-21429 [000] 13580.504064: _spin_lock_irqsave <-__skb_r=
ecv_datagram
           mcast-21429 [000] 13580.504064: _spin_unlock_irqrestore <-__=
skb_recv_datagram
           mcast-21429 [000] 13580.504064: skb_copy_datagram_iovec <-ud=
p_recvmsg
           mcast-21429 [000] 13580.504064: memcpy_toiovec <-skb_copy_da=
tagram_iovec
           mcast-21429 [000] 13580.504064: copy_to_user <-memcpy_toiove=
c
           mcast-21429 [000] 13580.504065: lock_sock_nested <-udp_recvm=
sg
           mcast-21429 [000] 13580.504065: _spin_lock_bh <-lock_sock_ne=
sted
           mcast-21429 [000] 13580.504065: local_bh_disable <-_spin_loc=
k_bh
           mcast-21429 [000] 13580.504065: local_bh_enable <-lock_sock_=
nested
           mcast-21429 [000] 13580.504065: skb_free_datagram <-udp_recv=
msg
           mcast-21429 [000] 13580.504065: consume_skb <-skb_free_datag=
ram
           mcast-21429 [000] 13580.504065: __kfree_skb <-consume_skb
           mcast-21429 [000] 13580.504066: skb_release_head_state <-__k=
free_skb
           mcast-21429 [000] 13580.504066: dst_release <-skb_release_he=
ad_state
           mcast-21429 [000] 13580.504066: sock_rfree <-skb_release_hea=
d_state
           mcast-21429 [000] 13580.504066: skb_release_data <-__kfree_s=
kb
           mcast-21429 [000] 13580.504066: kfree <-skb_release_data
           mcast-21429 [000] 13580.504066: __slab_free <-kfree

  is it normal we call add_partial() ?

           mcast-21429 [000] 13580.504067: add_partial <-__slab_free
           mcast-21429 [000] 13580.504067: _spin_lock <-add_partial
           mcast-21429 [000] 13580.504067: kmem_cache_free <-__kfree_sk=
b
           mcast-21429 [000] 13580.504067: __slab_free <-kmem_cache_fre=
e
           mcast-21429 [000] 13580.504067: release_sock <-udp_recvmsg
           mcast-21429 [000] 13580.504067: _spin_lock_bh <-release_sock
           mcast-21429 [000] 13580.504067: local_bh_disable <-_spin_loc=
k_bh
           mcast-21429 [000] 13580.504068: _spin_unlock_bh <-release_so=
ck
           mcast-21429 [000] 13580.504068: local_bh_enable_ip <-_spin_u=
nlock_bh
           mcast-21429 [000] 13580.504068: move_addr_to_user <-sys_recv=
from
           mcast-21429 [000] 13580.504068: copy_to_user <-move_addr_to_=
user
           mcast-21429 [000] 13580.504068: fput <-sys_recvfrom

           mcast-21429 [000] 13580.504069: sys_gettimeofday <-sysenter_=
do_call
           mcast-21429 [000] 13580.504069: do_gettimeofday <-sys_gettim=
eofday
           mcast-21429 [000] 13580.504069: getnstimeofday <-do_gettimeo=
fday
           mcast-21429 [000] 13580.504069: copy_to_user <-sys_gettimeof=
day

           mcast-21429 [000] 13580.504069: sys_socketcall <-sysenter_do=
_call
           mcast-21429 [000] 13580.504070: copy_from_user <-sys_socketc=
all

mcast wants next frame and is going to block

           mcast-21429 [000] 13580.504070: sys_recvfrom <-sys_socketcal=
l
           mcast-21429 [000] 13580.504070: sockfd_lookup_light <-sys_re=
cvfrom
           mcast-21429 [000] 13580.504070: fget_light <-sockfd_lookup_l=
ight
           mcast-21429 [000] 13580.504070: sock_recvmsg <-sys_recvfrom
           mcast-21429 [000] 13580.504070: sock_common_recvmsg <-sock_r=
ecvmsg
           mcast-21429 [000] 13580.504071: udp_recvmsg <-sock_common_re=
cvmsg
           mcast-21429 [000] 13580.504071: __skb_recv_datagram <-udp_re=
cvmsg
           mcast-21429 [000] 13580.504071: _spin_lock_irqsave <-__skb_r=
ecv_datagram
           mcast-21429 [000] 13580.504071: _spin_unlock_irqrestore <-__=
skb_recv_datagram
           mcast-21429 [000] 13580.504071: prepare_to_wait_exclusive <-=
__skb_recv_datagram
           mcast-21429 [000] 13580.504071: _spin_lock_irqsave <-prepare=
_to_wait_exclusive
           mcast-21429 [000] 13580.504071: _spin_unlock_irqrestore <-pr=
epare_to_wait_exclusive
           mcast-21429 [000] 13580.504072: schedule_timeout <-__skb_rec=
v_datagram
           mcast-21429 [000] 13580.504072: schedule <-schedule_timeout
           mcast-21429 [000] 13580.504072: rcu_sched_qs <-schedule
           mcast-21429 [000] 13580.504072: _spin_lock_irq <-schedule
           mcast-21429 [000] 13580.504072: deactivate_task <-schedule
           mcast-21429 [000] 13580.504072: dequeue_task <-deactivate_ta=
sk
           mcast-21429 [000] 13580.504073: dequeue_task_fair <-dequeue_=
task
           mcast-21429 [000] 13580.504073: update_curr <-dequeue_task_f=
air
           mcast-21429 [000] 13580.504073: hrtick_start_fair <-dequeue_=
task_fair
           mcast-21429 [000] 13580.504073: find_busiest_group <-schedul=
e
           mcast-21429 [000] 13580.504073: scale_rt_power <-find_busies=
t_group
           mcast-21429 [000] 13580.504073: sched_avg_update <-scale_rt_=
power
           mcast-21429 [000] 13580.504074: msecs_to_jiffies <-schedule
           mcast-21429 [000] 13580.504074: find_busiest_group <-schedul=
e
           mcast-21429 [000] 13580.504074: msecs_to_jiffies <-schedule
           mcast-21429 [000] 13580.504075: put_prev_task_fair <-schedul=
e
           mcast-21429 [000] 13580.504075: pick_next_task_fair <-schedu=
le
           mcast-21429 [000] 13580.504075: pick_next_task_rt <-schedule
           mcast-21429 [000] 13580.504075: pick_next_task_fair <-schedu=
le
           mcast-21429 [000] 13580.504075: pick_next_task_idle <-schedu=
le
           mcast-21429 [000] 13580.504075: perf_event_task_sched_out <-=
schedule
           mcast-21429 [000] 13580.504076: __switch_to <-schedule
          <idle>-0     [000] 13580.504076: finish_task_switch <-schedul=
e
          <idle>-0     [000] 13580.504076: perf_event_task_sched_in <-f=
inish_task_switch
          <idle>-0     [000] 13580.504076: tick_nohz_stop_sched_tick <-=
cpu_idle
          <idle>-0     [000] 13580.504076: ktime_get <-tick_nohz_stop_s=
ched_tick
          <idle>-0     [000] 13580.504076: get_next_timer_interrupt <-t=
ick_nohz_stop_sched_tick
          <idle>-0     [000] 13580.504077: _spin_lock <-get_next_timer_=
interrupt
          <idle>-0     [000] 13580.504077: hrtimer_get_next_event <-get=
_next_timer_interrupt
          <idle>-0     [000] 13580.504077: _spin_lock_irqsave <-hrtimer=
_get_next_event
          <idle>-0     [000] 13580.504077: _spin_unlock_irqrestore <-hr=
timer_get_next_event
          <idle>-0     [000] 13580.504077: rcu_needs_cpu <-tick_nohz_st=
op_sched_tick
          <idle>-0     [000] 13580.504077: printk_needs_cpu <-tick_nohz=
_stop_sched_tick
          <idle>-0     [000] 13580.504077: select_nohz_load_balancer <-=
tick_nohz_stop_sched_tick
          <idle>-0     [000] 13580.504078: rcu_enter_nohz <-tick_nohz_s=
top_sched_tick
          <idle>-0     [000] 13580.504078: hrtimer_start <-tick_nohz_st=
op_sched_tick
          <idle>-0     [000] 13580.504078: __hrtimer_start_range_ns <-h=
rtimer_start
          <idle>-0     [000] 13580.504078: lock_hrtimer_base <-__hrtime=
r_start_range_ns
          <idle>-0     [000] 13580.504078: _spin_lock_irqsave <-lock_hr=
timer_base
          <idle>-0     [000] 13580.504078: __remove_hrtimer <-__hrtimer=
_start_range_ns
          <idle>-0     [000] 13580.504079: hrtimer_force_reprogram <-__=
remove_hrtimer
          <idle>-0     [000] 13580.504079: tick_program_event <-hrtimer=
_force_reprogram
          <idle>-0     [000] 13580.504079: tick_dev_program_event <-tic=
k_program_event
          <idle>-0     [000] 13580.504079: ktime_get <-tick_dev_program=
_event
          <idle>-0     [000] 13580.504079: clockevents_program_event <-=
tick_dev_program_event
          <idle>-0     [000] 13580.504079: lapic_next_event <-clockeven=
ts_program_event
          <idle>-0     [000] 13580.504079: native_apic_mem_write <-lapi=
c_next_event
          <idle>-0     [000] 13580.504080: ktime_add_safe <-__hrtimer_s=
tart_range_ns
          <idle>-0     [000] 13580.504080: enqueue_hrtimer <-__hrtimer_=
start_range_ns
          <idle>-0     [000] 13580.504080: tick_program_event <-__hrtim=
er_start_range_ns
          <idle>-0     [000] 13580.504080: tick_dev_program_event <-tic=
k_program_event
          <idle>-0     [000] 13580.504080: ktime_get <-tick_dev_program=
_event
          <idle>-0     [000] 13580.504080: clockevents_program_event <-=
tick_dev_program_event
          <idle>-0     [000] 13580.504081: lapic_next_event <-clockeven=
ts_program_event
          <idle>-0     [000] 13580.504081: native_apic_mem_write <-lapi=
c_next_event
          <idle>-0     [000] 13580.504081: _spin_unlock_irqrestore <-__=
hrtimer_start_range_ns
          <idle>-0     [000] 13580.504081: poll_idle <-cpu_idle


Next interrupt...


          <idle>-0     [000] 13580.505032: do_IRQ <-common_interrupt
          <idle>-0     [000] 13580.505032: irq_enter <-do_IRQ
          <idle>-0     [000] 13580.505032: rcu_irq_enter <-irq_enter
          <idle>-0     [000] 13580.505032: idle_cpu <-irq_enter


Too many slowpaths for 4096 slabs ?

$ cd /sys/kernel/slab/:t-0004096
$ grep . *
aliases:1
align:8
grep: alloc_calls: Function not implemented
alloc_fastpath:416584 C0=3D234119 C1=3D52938 C2=3D18413 C3=3D4739 C4=3D=
49140 C5=3D14679 C6=3D39266 C7=3D3290
alloc_from_partial:459402 C0=3D459391 C1=3D8 C2=3D1 C5=3D2
alloc_refill:459619 C0=3D459460 C1=3D54 C2=3D1 C3=3D4 C4=3D52 C5=3D31 C=
6=3D2 C7=3D15
alloc_slab:103 C0=3D45 C1=3D28 C3=3D1 C4=3D26 C5=3D1 C6=3D1 C7=3D1
alloc_slowpath:459628 C0=3D459462 C1=3D55 C2=3D2 C3=3D5 C4=3D53 C5=3D32=
 C6=3D3 C7=3D16
cache_dma:0
cpuslab_flush:0
cpu_slabs:8
deactivate_empty:0
deactivate_full:459498 C0=3D459436 C1=3D35 C4=3D25 C5=3D2
deactivate_remote_frees:0
deactivate_to_head:0
deactivate_to_tail:0
destroy_by_rcu:0
free_add_partial:459448 C0=3D459324 C1=3D9 C2=3D39 C4=3D74 C5=3D2
grep: free_calls: Function not implemented
free_fastpath:218431 C0=3D36679 C1=3D52679 C2=3D18408 C3=3D4708 C4=3D48=
837 C5=3D14602 C6=3D39252 C7=3D3266
free_frozen:491 C0=3D161 C1=3D95 C2=3D14 C3=3D36 C4=3D77 C5=3D64 C6=3D1=
3 C7=3D31
free_remove_partial:40 C0=3D40
free_slab:40 C0=3D40
free_slowpath:657340 C0=3D656835 C1=3D119 C2=3D76 C3=3D36 C4=3D159 C5=3D=
69 C6=3D15 C7=3D31
hwcache_align:0
min_partial:10
objects:499
object_size:4096
objects_partial:35
objs_per_slab:8
order:3
order_fallback:0
partial:5
poison:0
reclaim_account:0
red_zone:0
sanity_checks:0
slabs:63
slab_size:4096
store_user:0
total_objects:504
trace:0



comments :=20
- lots of disable_bh()/enable_bh(), (enable_bh is slow), that could be =
avoided...
- many ktime_get() calls
- my HZ=3D1000 setup might be stupid on a CONFIG_NO_HZ=3Dy kernel :(
