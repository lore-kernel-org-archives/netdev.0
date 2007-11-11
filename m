From: Chazarain Guillaume <guichaz@yahoo.fr>
Subject: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571 tcp_remove_reno_sacks()
Date: Sun, 11 Nov 2007 01:39:03 +0000 (GMT)
Message-ID: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?utf-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26211.mail.ukl.yahoo.com ([217.12.10.207]:20236 "HELO
	web26211.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751356AbXKKBpr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 20:45:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ilpo, thanks a lot for your investigation

> Do you have GSO enabled?

According to ethtool -k, no.

> Is this reproducable?

Unfortunately not, I saw it only once.

> You can try to provoke it by setting tcp_sack
 sysctl=20
>  to 0 as this seems to be non-SACK related... If so, you could try th=
e=20
> debug patch below

> # CONFIG_DEBUG_LIST is not set

I'm currently running bittorrent with all of this, I just saw this (for=
 the first time ever),
but otherwise it works fine:

WARNING: at net/ipv4/tcp_output.c:1807 tcp_simple_retransmit()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f6a79>] tcp_simple_retransmit+0xfa/0x185
 [<c02fa072>] tcp_v4_err+0x35d/0x4cb
 [<c0301f7d>] icmp_unreach+0x327/0x352
 [<c030159d>] icmp_rcv+0xe0/0xf7
 [<c02e2d75>] ip_local_deliver_finish+0x124/0x1ba
 [<c02e3178>] ip_local_deliver+0x72/0x7e
 [<c02e2c31>] ip_rcv_finish+0x299/0x2b9
 [<c02e30e8>] ip_rcv+0x1e1/0x1ff
 [<c02c755c>] netif_receive_skb+0x37d/0x401
 [<c02c9372>] process_backlog+0x5b/0x96
 [<c02c9037>] net_rx_action+0x87/0x152
 [<c0121c9f>] __do_softirq+0x38/0x7a
 [<c0105975>] do_softirq+0x41/0x92

> Have you run memtest recently?

Just ran it with no errors for 6 minutes 30. The box is otherwise stabl=
e though.

I forgot to say that I have a kdump image of the crash (I had to recomp=
ile this

2.6.24-rc2 kernel as I deleted its vmlinux), so I could check that you =
are
right on track with your assertions at the time of the crash.

> +    if (WARN_ON(tcp_write_queue_head(sk) =3D=3D NULL))
> +        return;

(gdb) p sk->sk_write_queue.next
$11 =3D (struct sk_buff *) 0xe43a04b0
(gdb) p &sk->sk_write_queue
$12 =3D (struct sk_buff_head *) 0xe43a04b0


> +    if (WARN_ON(!tp->packets_out))
> +        return;

(gdb) p ((struct tcp_sock *) sk)->packets_out
$13 =3D 0

> +    if (tp->lost_out > tp->packets_out)
> +        printk(KERN_ERR "Lost underflowed to %u\n", tp->lost_out);

(gdb) p ((struct tcp_sock *) sk)->lost_out
$14 =3D 4294967295

Some more gdb output for information:

#0  tcp_xmit_retransmit_queue (sk=3D0xe43a0440) at net/ipv4/tcp_output.=
c:1962
1962                            __u8 sacked =3D TCP_SKB_CB(skb)->sacked=
;

(gdb) bt
#0  tcp_xmit_retransmit_queue (sk=3D0xe43a0440) at net/ipv4/tcp_output.=
c:1962
#1  0xc02f298a in tcp_ack (sk=3D0xe43a0440, skb=3D0xc75720c0, flag=3D10=
38) at net/ipv4/tcp_input.c:2524
#2  0xc02f5208 in tcp_rcv_established (sk=3D0xe43a0440, skb=3D0xc75720c=
0, th=3D0xeac35058, len=3D32) at net/ipv4/tcp_input.c:4502
#3  0xc02fa711 in tcp_v4_do_rcv (sk=3D0xe43a0440, skb=3D0xc75720c0) at =
net/ipv4/tcp_ipv4.c:1572
#4  0xc02fc557 in tcp_v4_rcv (skb=3D0xc75720c0) at net/ipv4/tcp_ipv4.c:=
1696
#5  0xc02e4961 in ip_local_deliver_finish (skb=3D0xc75720c0) at net/ipv=
4/ip_input.c:233
#6  0xc02e4d64 in ip_local_deliver (skb=3D0xc75720c0) at net/ipv4/ip_in=
put.c:271
#7  0xc02e481d in ip_rcv_finish (skb=3D0xc75720c0) at include/net/dst.h=
:241
#8  0xc02e4cd4 in ip_rcv (skb=3D<value optimized out>, dev=3D0xc717c000=
, pt=3D<value optimized out>, orig_dev=3D0xc717c000) at net/ipv4/ip_inp=
ut.c:445
#9  0xc02c9062 in netif_receive_skb (skb=3D0xc75720c0) at net/core/dev.=
c:2088
#10 0xc02cae8e in process_backlog (napi=3D0xc04b651c, quota=3D64) at ne=
t/core/dev.c:2125
#11 0xc02cab3f in net_rx_action (h=3D<value optimized out>) at net/core=
/dev.c:2195
#12 0xc0121d17 in __do_softirq () at kernel/softirq.c:232
#13 0xc0105975 in do_softirq () at arch/x86/kernel/irq_32.c:216
Backtrace stopped: previous frame inner to this frame (corrupt stack?)

(gdb) bt full
#0  tcp_xmit_retransmit_queue (sk=3D0xe43a0440) at net/ipv4/tcp_output.=
c:1962
        sacked =3D 176 '=EF=BF=BD'
        skb =3D (struct sk_buff *) 0xe43a04b0
        packet_cnt =3D 0
#1  0xc02f298a in tcp_ack (sk=3D0xe43a0440, skb=3D0xc75720c0, flag=3D10=
38) at net/ipv4/tcp_input.c:2524
        packets_acked =3D 1
        sacked =3D 134 '\206'
        tp =3D <value optimized out>
        prior_snd_una =3D 2015065950
        ack_seq =3D 4044906321
        ack =3D 2015065959
        prior_in_flight =3D 2
        seq_rtt =3D -1
        frto_cwnd =3D <value optimized out>
#2  0xc02f5208 in tcp_rcv_established (sk=3D0xe43a0440, skb=3D0xc75720c=
0, th=3D0xeac35058, len=3D32) at net/ipv4/tcp_input.c:4502
        tcp_header_len =3D <value optimized out>
        tp =3D <value optimized out>
#3  0xc02fa711 in tcp_v4_do_rcv (sk=3D0xe43a0440, skb=3D0xc75720c0) at =
net/ipv4/tcp_ipv4.c:1572
        rsk =3D <value optimized out>
#4  0xc02fc557 in tcp_v4_rcv (skb=3D0xc75720c0) at net/ipv4/tcp_ipv4.c:=
1696
        err =3D -950591296
        filter =3D <value optimized out>
        iph =3D (const struct iphdr *) 0xeac35044
        th =3D (struct tcphdr *) 0xeac35058
        sk =3D (struct sock *) 0xe43a0440
        ret =3D <value optimized out>
#5  0xc02e4961 in ip_local_deliver_finish (skb=3D0xc75720c0) at net/ipv=
4/ip_input.c:233
        ret =3D <value optimized out>
        protocol =3D <value optimized out>
        hash =3D 0
        raw_sk =3D (struct sock *) 0x0
#6  0xc02e4d64 in ip_local_deliver (skb=3D0xc75720c0) at net/ipv4/ip_in=
put.c:271
        __ret =3D -465959760
#7  0xc02e481d in ip_rcv_finish (skb=3D0xc75720c0) at include/net/dst.h=
:241
        iph =3D (const struct iphdr *) 0xeac35044
        rt =3D <value optimized out>
#8  0xc02e4cd4 in ip_rcv (skb=3D<value optimized out>, dev=3D0xc717c000=
, pt=3D<value optimized out>, orig_dev=3D0xc717c000) at net/ipv4/ip_inp=
ut.c:445
        __ret =3D <value optimized out>
        iph =3D (struct iphdr *) 0xeac35044
        len =3D 3829007536
#9  0xc02c9062 in netif_receive_skb (skb=3D0xc75720c0) at net/core/dev.=
c:2088
        ptype =3D (struct packet_type *) 0xc0437a08
        pt_prev =3D <value optimized out>
        orig_dev =3D (struct net_device *) 0xc717c000
        ret =3D 1
        type =3D 8
#10 0xc02cae8e in process_backlog (napi=3D0xc04b651c, quota=3D64) at ne=
t/core/dev.c:2125
        skb =3D (struct sk_buff *) 0xe43a04b0
        dev =3D (struct net_device *) 0xc717c000
        work =3D 0
        start_time =3D 35819170
#11 0xc02cab3f in net_rx_action (h=3D<value optimized out>) at net/core=
/dev.c:2195
        n =3D (struct napi_struct *) 0xc04b651c
        work =3D 0
        weight =3D 64
        start_time =3D 35819170
        budget =3D 300
        have =3D (void *) 0x0
        __func__ =3D "net_rx_action"
        __warned =3D 0
#12 0xc0121d17 in __do_softirq () at kernel/softirq.c:232
        h =3D (struct softirq_action *) 0xc049e6b8
        pending =3D 1
        max_restart =3D 9
#13 0xc0105975 in do_softirq () at arch/x86/kernel/irq_32.c:216
        flags =3D 70
        irqctx =3D <value optimized out>
        isp =3D (u32 *) 0xc0439f14
        __func__ =3D "do_softirq"
        __warned =3D 0
Backtrace stopped: previous frame inner to this frame (corrupt stack?)

(gdb) p *((struct tcp_sock *) sk)
$1 =3D {inet_conn =3D {icsk_inet =3D {sk =3D {__sk_common =3D {skc_fami=
ly =3D 2, skc_state =3D 1 '\001', skc_reuse =3D 1 '\001', skc_bound_dev=
_if =3D 0, skc_node =3D {next =3D 0x0, pprev =3D 0xc65e0f38}, skc_bind_=
node =3D {next =3D 0xe604acd0, pprev =3D 0xe42fa890}, skc_refcnt =3D {c=
ounter =3D 3}, skc_hash =3D 2132787687, skc_prot =3D 0xc042ef40, skc_ne=
t =3D 0xc04b64a0}, sk_shutdown =3D 0 '\0', sk_no_check =3D 0 '\0', sk_u=
serlocks =3D 0 '\0', sk_protocol =3D 6 '\006', sk_type =3D 1, sk_rcvbuf=
 =3D 87380, sk_lock =3D {slock =3D {raw_lock =3D {<No data fields>}}, o=
wned =3D 0, wq =3D {lock =3D {raw_lock =3D {<No data fields>}}, task_li=
st =3D {next =3D 0xe43a0474, prev =3D 0xe43a0474}}}, sk_backlog =3D {he=
ad =3D 0x0, tail =3D 0x0}, sk_sleep =3D 0xc9be8d98, sk_dst_cache =3D 0x=
c86eb200, sk_policy =3D {0x0, 0x0}, sk_dst_lock =3D {raw_lock =3D {<No =
data fields>}}, sk_rmem_alloc =3D {counter =3D 0}, sk_wmem_alloc =3D {c=
ounter =3D 0}, sk_omem_alloc =3D {counter =3D 0}, sk_sndbuf =3D 35520, =
sk_receive_queue =3D {next =3D 0xe43a04a4, prev =3D 0xe43a04a4, qlen =3D=
 0, lock =3D
 {raw_lock =3D {<No data fields>}}}, sk_write_queue =3D {next =3D 0xe43=
a04b0, prev =3D 0xe43a04b0, qlen =3D 0, lock =3D {raw_lock =3D {<No dat=
a fields>}}}, sk_async_wait_queue =3D {next =3D 0x0, prev =3D 0x0, qlen=
 =3D 0, lock =3D {raw_lock =3D {<No data fields>}}}, sk_wmem_queued =3D=
 0, sk_forward_alloc =3D 4096, sk_allocation =3D 208, sk_route_caps =3D=
 0, sk_gso_type =3D 1, sk_rcvlowat =3D 1, sk_flags =3D 17152, sk_linger=
time =3D 0, sk_error_queue =3D {next =3D 0xe43a04e8, prev =3D 0xe43a04e=
8, qlen =3D 0, lock =3D {raw_lock =3D {<No data fields>}}}, sk_prot_cre=
ator =3D 0xc042ef40, sk_callback_lock =3D {raw_lock =3D {<No data field=
s>}}, sk_err =3D 0, sk_err_soft =3D 0, sk_ack_backlog =3D 0, sk_max_ack=
_backlog =3D 50, sk_priority =3D 2, sk_peercred =3D {pid =3D 0, uid =3D=
 4294967295, gid =3D 4294967295}, sk_rcvtimeo =3D 2147483647, sk_sndtim=
eo =3D 2147483647, sk_filter =3D 0x0, sk_protinfo =3D 0x0, sk_timer =3D=
 {entry =3D {next =3D 0x0, prev =3D 0xc049ef80}, expires =3D 34855119, =
function =3D 0xc02f8e64 <tcp_keepalive_timer>, data =3D 3829007424, bas=
e =3D
 0xc049e900}, sk_stamp =3D {tv64 =3D 3294967295}, sk_socket =3D 0xc9be8=
d80, sk_user_data =3D 0x0, sk_sndmsg_page =3D 0x0, sk_send_head =3D 0x0=
, sk_sndmsg_off =3D 0, sk_write_pending =3D 0, sk_security =3D 0x0, sk_=
state_change =3D 0xc02c2378 <sock_def_wakeup>, sk_data_ready =3D 0xc02c=
2b7c <sock_def_readable>, sk_write_space =3D 0xc02c6817 <sk_stream_writ=
e_space>, sk_error_report =3D 0xc02c2b12 <sock_def_error_report>, sk_ba=
cklog_rcv =3D 0xc02fa6e6 <tcp_v4_do_rcv>, sk_destruct =3D 0xc0306a97 <i=
net_sock_destruct>}, pinet6 =3D 0x0, daddr =3D 2282963090, rcv_saddr =3D=
 50374848, dport =3D 41928, num =3D 6881, saddr =3D 50374848, uc_ttl =3D=
 -1, cmsg_flags =3D 0, opt =3D 0x0, sport =3D 57626, id =3D 11867, tos =
=3D 8 '\b', mc_ttl =3D 46 '.', pmtudisc =3D 1 '\001', recverr =3D 0 '\0=
', is_icsk =3D 1 '\001', freebind =3D 0 '\0', hdrincl =3D 0 '\0', mc_lo=
op =3D 1 '\001', mc_index =3D 2, mc_addr =3D 0, mc_list =3D 0x0, cork =3D=
 {flags =3D 0, fragsize =3D 0, opt =3D 0x0, rt =3D 0x0, length =3D 0, a=
ddr =3D 0, fl =3D {oif =3D 0, iif =3D 0, mark =3D 0, nl_u =3D {ip4_u
 =3D {daddr =3D 0, saddr =3D 0, tos =3D 0 '\0', scope =3D 0 '\0'}, ip6_=
u =3D {daddr =3D {in6_u =3D {u6_addr8 =3D {0 '\0' <repeats 16 times>}, =
u6_addr16 =3D {0, 0, 0, 0, 0, 0, 0, 0}, u6_addr32 =3D {0, 0, 0, 0}}}, s=
addr =3D {in6_u =3D {u6_addr8 =3D {0 '\0' <repeats 16 times>}, u6_addr1=
6 =3D {0, 0, 0, 0, 0, 0, 0, 0}, u6_addr32 =3D {0, 0, 0, 0}}}, flowlabel=
 =3D 0}, dn_u =3D {daddr =3D 0, saddr =3D 0, scope =3D 0 '\0'}}, proto =
=3D 0 '\0', flags =3D 0 '\0', uli_u =3D {ports =3D {sport =3D 0, dport =
=3D 0}, icmpt =3D {type =3D 0 '\0', code =3D 0 '\0'}, dnports =3D {spor=
t =3D 0, dport =3D 0}, spi =3D 0, mht =3D {type =3D 0 '\0'}}, secid =3D=
 0}}}, icsk_accept_queue =3D {rskq_accept_head =3D 0x0, rskq_accept_tai=
l =3D 0x0, syn_wait_lock =3D {raw_lock =3D {<No data fields>}}, rskq_de=
fer_accept =3D 0 '\0', listen_opt =3D 0x0}, icsk_bind_hash =3D 0xc7137b=
d0, icsk_timeout =3D 35822107, icsk_retransmit_timer =3D {entry =3D {ne=
xt =3D 0xe4302e94, prev =3D 0xc851c1d4}, expires =3D 35822107, function=
 =3D 0xc02f91a8 <tcp_write_timer>, data =3D 3829007424, base =3D 0xc049=
e900},
 icsk_delack_timer =3D {entry =3D {next =3D 0x0, prev =3D 0x200200}, ex=
pires =3D 35816596, function =3D 0xc02f9026 <tcp_delack_timer>, data =3D=
 3829007424, base =3D 0xc049e900}, icsk_rto =3D 1860, icsk_pmtu_cookie =
=3D 1500, icsk_ca_ops =3D 0xc0430c20, icsk_af_ops =3D 0xc042ef00, icsk_=
sync_mss =3D 0xc02f59a9 <tcp_sync_mss>, icsk_ca_state =3D 3 '\003', ics=
k_retransmits =3D 0 '\0', icsk_pending =3D 0 '\0', icsk_backoff =3D 0 '=
\0', icsk_syn_retries =3D 0 '\0', icsk_probes_out =3D 0 '\0', icsk_ext_=
hdr_len =3D 0, icsk_ack =3D {pending =3D 0 '\0', quick =3D 14 '\016', p=
ingpong =3D 0 '\0', blocked =3D 0 '\0', ato =3D 40, timeout =3D 3581659=
6, lrcvtime =3D 35816556, last_seg_size =3D 0, rcv_mss =3D 1368}, icsk_=
mtup =3D {enabled =3D 0, search_high =3D 1420, search_low =3D 564, prob=
e_size =3D 0}, icsk_ca_priv =3D {0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0=
, 0, 0, 0}}, tcp_header_len =3D 32, xmit_size_goal =3D 1368, pred_flags=
 =3D 2520649856, rcv_nxt =3D 4044906321, copied_seq =3D 4044906321, rcv=
_wup =3D 4044906321, snd_nxt =3D 2015065959, snd_una =3D
 2015065959, snd_sml =3D 2015065959, rcv_tstamp =3D 35819170, lsndtime =
=3D 35818339, ucopy =3D {prequeue =3D {next =3D 0xe43a06ec, prev =3D 0x=
e43a06ec, qlen =3D 0, lock =3D {raw_lock =3D {<No data fields>}}}, task=
 =3D 0x0, iov =3D 0x0, memory =3D 0, len =3D 0}, snd_wl1 =3D 4044906321=
, snd_wnd =3D 64088, max_window =3D 64088, mss_cache =3D 1368, window_c=
lamp =3D 64087, rcv_ssthresh =3D 64087, frto_highmark =3D 0, reordering=
 =3D 3 '\003', frto_counter =3D 0 '\0', nonagle =3D 0 '\0', keepalive_p=
robes =3D 0 '\0', srtt =3D 8775, mdev =3D 764, mdev_max =3D 200, rttvar=
 =3D 764, rtt_seq =3D 2015065959, packets_out =3D 0, retrans_out =3D 0,=
 rx_opt =3D {ts_recent_stamp =3D 1194667355, ts_recent =3D 106039901, r=
cv_tsval =3D 106039901, rcv_tsecr =3D 35818339, saw_tstamp =3D 1, tstam=
p_ok =3D 1, dsack =3D 0, wscale_ok =3D 1, sack_ok =3D 0, snd_wscale =3D=
 2, rcv_wscale =3D 7, eff_sacks =3D 0 '\0', num_sacks =3D 0 '\0', user_=
mss =3D 0, mss_clamp =3D 1380}, snd_ssthresh =3D 2, snd_cwnd =3D 2, snd=
_cwnd_cnt =3D 1, snd_cwnd_clamp =3D 4294967295, snd_cwnd_used =3D 0,
 snd_cwnd_stamp =3D 35819170, out_of_order_queue =3D {next =3D 0xe43a07=
74, prev =3D 0xe43a0774, qlen =3D 0, lock =3D {raw_lock =3D {<No data f=
ields>}}}, rcv_wnd =3D 64128, write_seq =3D 2015065959, pushed_seq =3D =
2015065959, duplicate_sack =3D {{start_seq =3D 0, end_seq =3D 0}}, sele=
ctive_acks =3D {{start_seq =3D 0, end_seq =3D 0}, {start_seq =3D 0, end=
_seq =3D 0}, {start_seq =3D 0, end_seq =3D 0}, {start_seq =3D 0, end_se=
q =3D 0}}, recv_sack_cache =3D {{start_seq =3D 0, end_seq =3D 0}, {star=
t_seq =3D 0, end_seq =3D 0}, {start_seq =3D 0, end_seq =3D 0}, {start_s=
eq =3D 0, end_seq =3D 0}}, highest_sack =3D 0, lost_skb_hint =3D 0x0, s=
coreboard_skb_hint =3D 0x0, retransmit_skb_hint =3D 0x0, forward_skb_hi=
nt =3D 0x0, fastpath_skb_hint =3D 0x0, fastpath_cnt_hint =3D 0, lost_cn=
t_hint =3D 1, retransmit_cnt_hint =3D 0, lost_retrans_low =3D 201506595=
9, advmss =3D 1448, prior_ssthresh =3D 3, lost_out =3D 4294967295, sack=
ed_out =3D 0, fackets_out =3D 0, high_seq =3D 2015065959, retrans_stamp=
 =3D 35794455, undo_marker =3D 2015065959, undo_retrans =3D 0, urg_seq =
=3D
 0, urg_data =3D 0, urg_mode =3D 0 '\0', ecn_flags =3D 0 '\0', snd_up =3D=
 0, total_retrans =3D 143, bytes_acked =3D 0, keepalive_time =3D 0, kee=
palive_intvl =3D 0, linger2 =3D 0, last_synq_overflow =3D 0, tso_deferr=
ed =3D 0, rcv_rtt_est =3D {rtt =3D 15645, seq =3D 4044968664, time =3D =
35713869}, rcvq_space =3D {space =3D 10944, seq =3D 4044906321, time =3D=
 35816556}, mtu_probe =3D {probe_seq_start =3D 0, probe_seq_end =3D 0}}

My naive attempt at understanding what's going on:

My oops starts with:
BUG: unable to handle kernel NULL pointer dereference at virtual addres=
s 00000045


gdb tells me the crash is in:
#0  tcp_xmit_retransmit_queue (sk=3D0xe43a0440) at net/ipv4/tcp_output.=
c:1962
1962                            __u8 sacked =3D TCP_SKB_CB(skb)->sacked=
;

(gdb) p ((struct tcp_skb_cb *)((struct sk_buff *)0)->cb)->sacked
Cannot access memory at address 0x45

A 0x45 offset is definitely a ->sacked on a null skb, but:

(gdb) p skb
$5 =3D (struct sk_buff *) 0xe43a04b0

which is sk->sk_write_queue so I don't understand why the tcp_for_write=
_queue_from made an iteration.

I don't know if gdb is playing tricks or if it's because I had to recom=
pile the crashing kernel.

Thanks.

--=20
Guillaume



      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail=20
