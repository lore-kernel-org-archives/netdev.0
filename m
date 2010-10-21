From: Li Yu <raise.sail@gmail.com>
Subject: TCP always advertises zero window.
Date: Thu, 21 Oct 2010 15:17:56 +0800
Message-ID: <4CBFE924.2060103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38475 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab0JUHSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 03:18:07 -0400
Received: by gxk21 with SMTP id 21so2138547gxk.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 00:18:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	We found this on RHEL 5.4, the kernel is 2.6.18-164.11.1.el5, and also suspect that recent kernel also has similar problem. 

	First, we turned off both TCP window scaling option and MTU probe feature. On some servers, we found that some servers may always advertised another ends zero received window, below are some captured traffic (by tcpdump -S -nn -vv):

16:24:59.990545 IP (tos 0x0, ttl  64, id 37079, offset 0, flags [DF], proto: TCP (6), length: 52) 10.1.157.3.2904 > 10.1.157.4.2903: ., cksum 0x96df (correct), 3830348746:3830348746(0) ack 1951026211 win 65160 <nop,nop,timestamp 1040455485 1040632013>
16:25:00.054563 IP (tos 0x0, ttl  64, id 47424, offset 0, flags [DF], proto: TCP (6), length: 460) 10.1.157.4.2903 > 10.1.157.3.2904: P 1951026211:1951026619(408) ack 3830348746 win 0 <nop,nop,timestamp 1040632077 1040455485>
16:25:00.054579 IP (tos 0x0, ttl  64, id 37080, offset 0, flags [DF], proto: TCP (6), length: 52) 10.1.157.3.2904 > 10.1.157.4.2903: ., cksum 0x94c7 (correct), 3830348746:3830348746(0) ack 1951026619 win 65160 <nop,nop,timestamp 1040455549 1040632077>
16:25:01.451253 IP (tos 0x0, ttl  64, id 47425, offset 0, flags [DF], proto: TCP (6), length: 4148) 10.1.157.4.2903 > 10.1.157.3.2904: P 1951026619:1951030715(4096) ack 3830348746 win 0 <nop,nop,timestamp 1040633474 1040455549>

	As above example show, 10.1.157.4 always advertise zero window forever. I wrote a small toy kernel module to show TCP internal socket status as below:

tcp-snapshot:sock:
  sk->sk_family=2
  sk->sk_state=1
  sk->sk_reuse=1
  sk->sk_bound_dev_if=0
  atomic_read(&sk->sk_refcnt)=3
  sk->sk_hash=117920776
  sk->sk_shutdown=0
  sk->sk_no_check=0
  sk->sk_userlocks=7
  sk->sk_protocol=6
  sk->sk_type=1
  sk->sk_rcvbuf=131072
  list_empty(&sk->sk_sleep->task_list)=0
  atomic_read(&sk->sk_rmem_alloc)=0
  atomic_read(&sk->sk_wmem_alloc)=0
  atomic_read(&sk->sk_omem_alloc)=0
  sk->sk_receive_queue.qlen=0
  sk->sk_write_queue.qlen=0
  sk->sk_async_wait_queue.qlen=0
  sk->sk_error_queue.qlen=0
  sk->sk_wmem_queued=0
  sk->sk_forward_alloc=8192
  sk->sk_allocation=d0
  sk->sk_sndbuf=131072
  sk->sk_route_caps=1143a9
  sk->sk_gso_type=1
  sk->sk_rcvlowat=1
  sk->sk_flags=300
  sk->sk_lingertime=0
  sk->sk_err=0
  sk->sk_err_soft=0
  sk->sk_ack_backlog=0
  sk->sk_max_ack_backlog=128
  sk->sk_priority=0
  sk->sk_rcvtimeo=9223372036854775807
  sk->sk_sndtimeo=9223372036854775807
  sk->sk_protinfo=0000000000000000
  sk->sk_stamp.tv_sec=18446744073709551615
  sk->sk_stamp.tv_usec=18446744073709551615
  sk->sk_socket=ffff81053ee71080
  sk->sk_user_data=0000000000000000
  sk->sk_sndmsg_page=ffff8103761ab220
  sk->sk_sndmsg_off=475
  sk->sk_send_head=0000000000000000
  sk->sk_write_pending=0
tcp-snapshot:inet_sock:
  inetsk->daddr=39d010a
  inetsk->rcv_saddr=49d010a
  inetsk->dport=580b
  inetsk->num=b57
  inetsk->saddr=49d010a
  inetsk->uc_ttl=4294967295
  inetsk->cmsg_flags=0
  inetsk->opt=0000000000000000
  inetsk->sport=570b
  inetsk->id=5843
  inetsk->tos=0
  inetsk->mc_ttl=64
  inetsk->pmtudisc=1
  inetsk->recverr=0
  inetsk->is_icsk=1
  inetsk->freebind=0
  inetsk->hdrincl=0
  inetsk->mc_loop=1
  inetsk->mc_index=2
  inetsk->mc_addr=0
  inetsk->mc_list=0000000000000000
tcp-snapshot:inet_connection_sk
  icsk->icsk_accept_queue.rskq_defer_accept=0
  icsk->icsk_accept_queue.listen_opt=0000000000000000
  icsk->icsk_timeout=5336784156
  icsk->icsk_rto=218
  icsk->icsk_pmtu_cookie=1500
  icsk->icsk_ca_state=0
  icsk->icsk_retransmits=0
  icsk->icsk_pending=0
  icsk->icsk_backoff=0
  icsk->icsk_syn_retries=0
  icsk->icsk_probes_out=0
  icsk->icsk_ext_hdr_len=0
  icsk->icsk_ack.pending=0
  icsk->icsk_ack.quick=0
  icsk->icsk_ack.pingpong=1
  icsk->icsk_ack.blocked=0
  icsk->icsk_ack.ato=40
  icsk->icsk_ack.timeout=5303454287
  icsk->icsk_ack.lrcvtime=1008486952
  icsk->icsk_ack.last_seg_size=6814
  icsk->icsk_ack.rcv_mss=8688
  icsk->icsk_mtup.enabled=0
  icsk->icsk_mtup.search_high=1500
  icsk->icsk_mtup.search_low=564
  icsk->icsk_mtup.probe_size=0
tcp-snapshot:tcp_sock
  tcpsk->tcp_header_len=32
  tcpsk->pred_flags=0
  tcpsk->rcv_nxt=3830348746
  tcpsk->snd_nxt=1984376345
  tcpsk->snd_una=1984376345
  tcpsk->snd_sml=1984376345
  tcpsk->rcv_tstamp=1041816640
  tcpsk->lsndtime=1041816640
  tcpsk->ucopy.prequeue.qlen=0
  tcpsk->ucopy.task=0000000000000000
  tcpsk->ucopy.iov=0000000000000000
  tcpsk->ucopy.memory=0
  tcpsk->ucopy.len=0
  tcpsk->snd_wl1=3830348746
  tcpsk->snd_wnd=65160
  tcpsk->max_window=65524
  tcpsk->mss_cache=1448
  tcpsk->xmit_size_goal=31856
  tcpsk->window_clamp=65535
  tcpsk->rcv_ssthresh=5792
  tcpsk->frto_highmark=0
  tcpsk->reordering=3
  tcpsk->frto_counter=0
  tcpsk->nonagle=1
  tcpsk->keepalive_probes=0
  tcpsk->srtt=121
  tcpsk->mdev=76
  tcpsk->mdev_max=200
  tcpsk->rttvar=203
  tcpsk->rtt_seq=1984376345
  tcpsk->packets_out=0
  tcpsk->left_out=0
  tcpsk->retrans_out=0
  tcpsk->rx_opt.ts_recent_stamp=1287564284
  tcpsk->rx_opt.ts_recent=1041640111
  tcpsk->rx_opt.rcv_tsval=1041640111
  tcpsk->rx_opt.rcv_tsecr=1041816640
  tcpsk->rx_opt.saw_tstamp=1
  tcpsk->rx_opt.tstamp_ok=1
  tcpsk->rx_opt.dsack=0
  tcpsk->rx_opt.wscale_ok=0
  tcpsk->rx_opt.sack_ok=5
  tcpsk->rx_opt.snd_wscale=0
  tcpsk->rx_opt.rcv_wscale=0
  tcpsk->rx_opt.eff_sacks=0
  tcpsk->rx_opt.num_sacks=0
  tcpsk->rx_opt.user_mss=0
  tcpsk->rx_opt.mss_clamp=1460
  tcpsk->snd_ssthresh=4
  tcpsk->snd_cwnd=4
  tcpsk->snd_cwnd_cnt=4
  tcpsk->snd_cwnd_clamp=65535
  tcpsk->snd_cwnd_used=2
  tcpsk->snd_cwnd_stamp=1041816640
  tcpsk->out_of_order_queue.qlen=0
  tcpsk->rcv_wnd=0
  tcpsk->rcv_wup=3830348746
  tcpsk->write_seq=1984376345
  tcpsk->pushed_seq=1984376345
  tcpsk->copied_seq=3830348746
  tcpsk->duplicate_sack[0].start_seq=3613713418
  tcpsk->duplicate_sack[0].end_seq=3613714866
  tcpsk->selective_acks[i].start_seq=3648234364
  tcpsk->selective_acks[i].end_seq=3648247396
  tcpsk->selective_acks[i].start_seq=3647855528
  tcpsk->selective_acks[i].end_seq=3647856976
  tcpsk->selective_acks[i].start_seq=3640487648
  tcpsk->selective_acks[i].end_seq=3640496336
  tcpsk->selective_acks[i].start_seq=3498843984
  tcpsk->selective_acks[i].end_seq=3498845432
  tcpsk->recv_sack_cache[i].start_seq=1226527628
  tcpsk->recv_sack_cache[i].end_seq=1226549030
  tcpsk->recv_sack_cache[i].start_seq=179088461
  tcpsk->recv_sack_cache[i].end_seq=179091357
  tcpsk->recv_sack_cache[i].start_seq=4042009662
  tcpsk->recv_sack_cache[i].end_seq=4042011110
  tcpsk->recv_sack_cache[i].start_seq=0
  tcpsk->recv_sack_cache[i].end_seq=0
  tcpsk->lost_skb_hint=0000000000000000
  tcpsk->scoreboard_skb_hint=0000000000000000
  tcpsk->retransmit_skb_hint=0000000000000000
  tcpsk->forward_skb_hint=0000000000000000
  tcpsk->fastpath_skb_hint=0000000000000000
  tcpsk->fastpath_cnt_hint=15
  tcpsk->lost_cnt_hint=6
  tcpsk->retransmit_cnt_hint=0
  tcpsk->forward_cnt_hint=9
  tcpsk->advmss=1448
  tcpsk->prior_ssthresh=5
  tcpsk->lost_out=0
  tcpsk->sacked_out=0
  tcpsk->fackets_out=0
  tcpsk->high_seq=1226549030
  tcpsk->retrans_stamp=0
  tcpsk->undo_marker=0
  tcpsk->undo_retrans=1
  tcpsk->urg_seq=0
  tcpsk->urg_data=0
  tcpsk->urg_mode=0
  tcpsk->ecn_flags=0
  tcpsk->snd_up=0
  tcpsk->total_retrans=2110
  tcpsk->bytes_acked=0
  tcpsk->keepalive_time=0
  tcpsk->keepalive_intvl=0
  tcpsk->linger2=0
  tcpsk->last_synq_overflow=0
  tcpsk->rcv_rtt_est.rtt=15
  tcpsk->rcv_rtt_est.seq=3830352454
  tcpsk->rcv_rtt_est.time=1008486951
  tcpsk->rcvq_space.space=468244
  tcpsk->rcvq_space.seq=3830258350
  tcpsk->rcvq_space.time=1008486952
  tcpsk->mtu_probe.probe_seq_start=0
  tcpsk->mtu_probe.probe_seq_end=0

	We noticed that the tcpsk->rcv_wnd indeed is 0, but tcpsk->copied_seq equals with tcpsk->rcv_nxt, and sk->sk_rmem_alloc is 0, both latters mean that there has not any pending data in receive queue.

	After some digging against source code, I found that __tcp_select_window() actually returns zero in such case. In my words, the function should resume window into non-zero value in this time (we have full free space on receive queue), is it right?

	In such case, I think that tcpsk->rcv_ssthresh has an exceptional value, it is too small, which triggers skiping rest processing in __tcp_select_window(), leave zero window forever.

	According to source code, only MTU probing success and receive some non-zero length of L7 payload could grow tcp_sock->rcv_ssthresh. Because of we turn off MTU probing and TCP only received some zero-window probe from another end, so it seem that we have not any chance to update tcp_sock->rcv_ssthresh at all, so a dead loop come here.

	It seem that we lost some processing in skb_data_queue() to keep consistent between free space of receive queue and tcpsk->rcv_ssthresh, is it right? or I missed something or some wrongs in my understanding...


	Thank you~

Yu




