From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] tcp: Change txhash on some non-RTO retransmits
Date: Mon, 17 Oct 2016 21:28:58 -0700
Message-ID: <CALx6S351wdHF-wfcXhDDj1RjaxO9BTh-Uyew3aiQQ3Ref1dHbg@mail.gmail.com>
References: <20161011001841.1118150-1-brakmo@fb.com> <CAK6E8=eoK88K0APyO04LtefaaDg6qRtHgHcKgMjiDvdmNCkNng@mail.gmail.com>
 <D42294A7.1FB0A%brakmo@fb.com> <CAK6E8=c8yHaEsfqRW9O1z7Dj21iU96QqY6nkSCtUpTbKOOc8wQ@mail.gmail.com>
 <CAK6E8=cuuTY0u0xqSKmoVzAuCOMdCm2UhyFxAgpa=51bvh_u-A@mail.gmail.com> <D42AE34E.1FF9D%brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Neal Cardwell <ncardwell@google.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33492 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754841AbcJRE3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 00:29:00 -0400
Received: by mail-qk0-f193.google.com with SMTP id f128so15076672qkb.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 21:28:59 -0700 (PDT)
In-Reply-To: <D42AE34E.1FF9D%brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 8:35 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
> Yuchung and Eric, thank you for your comments.
>
> It looks like I need to think more about this patch. I was trying
> to reduce the likelihood of reordering (which seems even more
> important based on Eric=C2=B9s comment on pacing), but it seems like
> the only way to prevent reordering is to only re-hash after an RTO
> or when there are no packets in flight (which may not occur).
>
Sounds like that should be the same condition as when we set ooo_okay?

>
> On 10/11/16, 8:56 PM, "Yuchung Cheng" <ycheng@google.com> wrote:
>
>>On Tue, Oct 11, 2016 at 6:01 PM, Yuchung Cheng <ycheng@google.com> wrote:
>>> On Tue, Oct 11, 2016 at 2:08 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>>>> Yuchung, thank you for your comments. Responses inline.
>>>>
>>>> On 10/11/16, 12:49 PM, "Yuchung Cheng" <ycheng@google.com> wrote:
>>>>
>>>>>On Mon, Oct 10, 2016 at 5:18 PM, Lawrence Brakmo <brakmo@fb.com> wrote=
:
>>>>>>
>>>>>> The purpose of this patch is to help balance flows across paths. A
>>>>>>new
>>>>>> sysctl "tcp_retrans_txhash_prob" specifies the probability (0-100)
>>>>>>that
>>>>>> the txhash (IPv6 flowlabel) will be changed after a non-RTO
>>>>>>retransmit.
>>>>>> A probability is used in order to control how many flows are moved
>>>>>> during a congestion event and prevent the congested path from
>>>>>>becoming
>>>>>> under utilized (which could occur if too many flows leave the curren=
t
>>>>>> path). Txhash changes may be delayed in order to decrease the
>>>>>>likelihood
>>>>>> that it will trigger retransmists due to too much reordering.
>>>>>>
>>>>>> Another sysctl "tcp_retrans_txhash_mode" determines the behavior
>>>>>>after
>>>>>> RTOs. If the sysctl is 0, then after an RTO, only RTOs can trigger
>>>>>> txhash changes. The idea is to decrease the likelihood of going back
>>>>>> to a broken path. That is, we don't want flow balancing to trigger
>>>>>> changes to broken paths. The drawback is that flow balancing does
>>>>>> not work as well. If the sysctl is greater than 1, then we always
>>>>>> do flow balancing, even after RTOs.
>>>>>>
>>>>>> Tested with packedrill tests (for correctness) and performance
>>>>>> experiments with 2 and 3 paths. Performance experiments looked at
>>>>>> aggregate goodput and fairness. For each run, we looked at the ratio
>>>>>>of
>>>>>> the goodputs for the fastest and slowest flows. These were averaged
>>>>>>for
>>>>>> all the runs. A fairness of 1 means all flows had the same goodput, =
a
>>>>>> fairness of 2 means the fastest flow was twice as fast as the slowes=
t
>>>>>> flow.
>>>>>>
>>>>>> The setup for the performance experiments was 4 or 5 serves in a
>>>>>>rack,
>>>>>> 10G links. I tested various probabilities, but 20 seemed to have the
>>>>>> best tradeoff for my setup (small RTTs).
>>>>>>
>>>>>>                       --- node1 -----
>>>>>>     sender --- switch --- node2 ----- switch ---- receiver
>>>>>>                       --- node3 -----
>>>>>>
>>>>>> Scenario 1: One sender sends to one receiver through 2 routes (node1
>>>>>>or
>>>>>> node 2). The output from node1 and node2 is 1G (1gbit/sec). With
>>>>>>only 2
>>>>>> flows, without flow balancing (prob=3D0) the average goodput is 1.6G
>>>>>>vs.
>>>>>> 1.9G with flow balancing due to 2 flows ending up in one link and
>>>>>>either
>>>>>> not moving and taking some time to move. Fairness was 1 in all cases=
.
>>>>>> For 7 flows, goodput was 1.9G for all, but fairness was 1.5, 1.4 or
>>>>>>1.2
>>>>>> for prob=3D0, prob=3D20,mode=3D0 and prob=3D20,mode=3D1 respectively=
. That is,
>>>>>> flow balancing increased fairness.
>>>>>>
>>>>>> Scenario 2: One sender to one receiver, through 3 routes (node1,...
>>>>>> node2). With 6 or 16 flows the goodput was the same for all, but
>>>>>> fairness was 1.8, 1.5 and 1.2 respectively. Interestingly, the worst
>>>>>> case fairness out of 10 runs were 2.2, 1.8 and 1.4 repectively. That
>>>>>>is,
>>>>>> prob=3D20,mode=3D1 improved average and worst case fairness.
>>>>>I am wondering if we can build better API with routing layer to
>>>>>implement this type of feature, instead of creeping the tx_rehashing
>>>>>logic scatter in TCP. For example, we call dst_negative_advice on TCP
>>>>>write timeouts.
>>>>
>>>> Not sure. The route is not necessarily bad, may be temporarily
>>>>congested
>>>> or they may all be congested. If all we want to do is change the txhas=
h
>>>> (unlike dst_negative_advice), then calling a tx_rehashing function may
>>>> be the appropriate call.
>>>>
>>>>>
>>>>>On the patch itself, it seems aggressive to (attempt to) rehash every
>>>>>post-RTO retranmission. Also you can just use ca_state (=3D=3DCA_Loss)=
 to
>>>>>identify post-RTO retransmission directly.
>>>>
>>>> Thanks, I will add the test.
>>>>
>>>>>
>>>>>is this an implementation of the Flow Bender ?
>>>>>https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__dl.acm.org_citat=
ion
>>>>>.cf
>>>>>m-3Fid-3D2674985&d=3DDQIBaQ&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3Dpq_Mqvzfy-C=
8ltkgyx
>>>>>1u_
>>>>>g&m=3DQ4nONH7kQ5AvQguw9UxpcHd79jfdDdrXj1YSJs7Ezhk&s=3DMA4fWBLMTGgRS0eG=
vBjxf
>>>>>7BJ
>>>>>Ol3-oxAzZDEYUG4cE-s&e=3D
>>>>
>>>> Part of flow bender, although there are also some similarities to
>>>>flowlet
>>>> switching.
>>>>
>>>>>
>>>>>>
>>>>>> Scenario 3: One sender to one receiver, 2 routes, one route drops
>>>>>>50% of
>>>>>> the packets. With 7 flows, goodput was the same 1.1G, but fairness
>>>>>>was
>>>>>> 1.8, 2.0 and 2.1 respectively. That is, if there is a bad route, the=
n
>>>>>> balancing, which does more re-routes, is less fair.
>>>>>>
>>>>>> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
>>>>>> ---
>>>>>>  Documentation/networking/ip-sysctl.txt | 15 +++++++++++++++
>>>>>>  include/linux/tcp.h                    |  4 +++-
>>>>>>  include/net/tcp.h                      |  2 ++
>>>>>>  net/ipv4/sysctl_net_ipv4.c             | 18 ++++++++++++++++++
>>>>>>  net/ipv4/tcp_input.c                   | 10 ++++++++++
>>>>>>  net/ipv4/tcp_output.c                  | 23 ++++++++++++++++++++++-
>>>>>>  net/ipv4/tcp_timer.c                   |  4 ++++
>>>>>>  7 files changed, 74 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/Documentation/networking/ip-sysctl.txt
>>>>>>b/Documentation/networking/ip-sysctl.txt
>>>>>> index 3db8c67..87a984c 100644
>>>>>> --- a/Documentation/networking/ip-sysctl.txt
>>>>>> +++ b/Documentation/networking/ip-sysctl.txt
>>>>>> @@ -472,6 +472,21 @@ tcp_max_reordering - INTEGER
>>>>>>         if paths are using per packet load balancing (like bonding r=
r
>>>>>>mode)
>>>>>>         Default: 300
>>>>>>
>>>>>> +tcp_retrans_txhash_mode - INTEGER
>>>>>> +       If zero, disable txhash recalculation due to non-RTO
>>>>>>retransmissions
>>>>>> +       after an RTO. The idea is that broken paths will trigger an
>>>>>>RTO
>>>>>>and
>>>>>> +       we don't want going back to that path due to standard
>>>>>>retransmissons
>>>>>> +       (flow balancing). The drawback is that balancing is less
>>>>>>robust.
>>>>>> +       If greater than zero, can always (probabilistically)
>>>>>>recalculate
>>>>>> +       txhash after non-RTO retransmissions.
>>>>>> +
>>>>>> +tcp_retrans_txhash_prob - INTEGER
>>>>>> +       Probability [0 to 100] that we will recalculate txhash when =
a
>>>>>> +       packet is resent not due to RTO (for RTO txhash is always
>>>>>>recalculated).
>>>>>> +       The recalculation of the txhash may be delayed to decrease
>>>>>>the
>>>>>> +       likelihood that reordering will trigger retransmissons.
>>>>>> +       The purpose is to help balance the flows among the possible
>>>>>>paths.
>>>>>> +
>>>>>>  tcp_retrans_collapse - BOOLEAN
>>>>>>         Bug-to-bug compatibility with some broken printers.
>>>>>>         On retransmit try to send bigger packets to work around bugs
>>>>>>in
>>>>>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>>>>>> index a17ae7b..e0e3b7d 100644
>>>>>> --- a/include/linux/tcp.h
>>>>>> +++ b/include/linux/tcp.h
>>>>>> @@ -214,7 +214,9 @@ struct tcp_sock {
>>>>>>         } rack;
>>>>>>         u16     advmss;         /* Advertised MSS
>>>>>>*/
>>>>>>         u8      rate_app_limited:1,  /* rate_{delivered,interval_us}
>>>>>>limited? */
>>>>>> -               unused:7;
>>>>>> +               txhash_rto:1,   /* If set, don't do flow balancing
>>>>>>*/
>>>>>> +               txhash_want:1,  /* We want to change txhash when saf=
e
>>>>>>*/
>>>>>> +               unused:5;
>>>>>>         u8      nonagle     : 4,/* Disable Nagle algorithm?
>>>>>>*/
>>>>>>                 thin_lto    : 1,/* Use linear timeouts for thin
>>>>>>streams
>>>>>>*/
>>>>>>                 thin_dupack : 1,/* Fast retransmit on first dupack
>>>>>>*/
>>>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>>>> index f83b7f2..3abd304 100644
>>>>>> --- a/include/net/tcp.h
>>>>>> +++ b/include/net/tcp.h
>>>>>> @@ -271,6 +271,8 @@ extern int sysctl_tcp_autocorking;
>>>>>>  extern int sysctl_tcp_invalid_ratelimit;
>>>>>>  extern int sysctl_tcp_pacing_ss_ratio;
>>>>>>  extern int sysctl_tcp_pacing_ca_ratio;
>>>>>> +extern int sysctl_tcp_retrans_txhash_prob;
>>>>>> +extern int sysctl_tcp_retrans_txhash_mode;
>>>>>>
>>>>>>  extern atomic_long_t tcp_memory_allocated;
>>>>>>  extern struct percpu_counter tcp_sockets_allocated;
>>>>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>>>>>> index 1cb67de..00d6f26 100644
>>>>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>>>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>>>>> @@ -28,6 +28,7 @@
>>>>>>  static int zero;
>>>>>>  static int one =3D 1;
>>>>>>  static int four =3D 4;
>>>>>> +static int hundred =3D 100;
>>>>>>  static int thousand =3D 1000;
>>>>>>  static int gso_max_segs =3D GSO_MAX_SEGS;
>>>>>>  static int tcp_retr1_max =3D 255;
>>>>>> @@ -624,6 +625,23 @@ static struct ctl_table ipv4_table[] =3D {
>>>>>>                 .proc_handler   =3D proc_dointvec_ms_jiffies,
>>>>>>         },
>>>>>>         {
>>>>>> +               .procname       =3D "tcp_retrans_txhash_prob",
>>>>>> +               .data           =3D &sysctl_tcp_retrans_txhash_prob,
>>>>>> +               .maxlen         =3D sizeof(int),
>>>>>> +               .mode           =3D 0644,
>>>>>> +               .proc_handler   =3D proc_dointvec_minmax,
>>>>>> +               .extra1         =3D &zero,
>>>>>> +               .extra2         =3D &hundred,
>>>>>> +       },
>>>>>> +       {
>>>>>> +               .procname       =3D "tcp_retrans_txhash_mode",
>>>>>> +               .data           =3D &sysctl_tcp_retrans_txhash_mode,
>>>>>> +               .maxlen         =3D sizeof(int),
>>>>>> +               .mode           =3D 0644,
>>>>>> +               .proc_handler   =3D proc_dointvec_minmax,
>>>>>> +               .extra1         =3D &zero,
>>>>>> +       },
>>>>>> +       {
>>>>>>                 .procname       =3D "icmp_msgs_per_sec",
>>>>>>                 .data           =3D &sysctl_icmp_msgs_per_sec,
>>>>>>                 .maxlen         =3D sizeof(int),
>>>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>>>>> index a27b9c0..fed5366 100644
>>>>>> --- a/net/ipv4/tcp_input.c
>>>>>> +++ b/net/ipv4/tcp_input.c
>>>>>> @@ -101,6 +101,9 @@ int sysctl_tcp_moderate_rcvbuf __read_mostly =3D=
 1;
>>>>>>  int sysctl_tcp_early_retrans __read_mostly =3D 3;
>>>>>>  int sysctl_tcp_invalid_ratelimit __read_mostly =3D HZ/2;
>>>>>>
>>>>>> +int sysctl_tcp_retrans_txhash_prob __read_mostly;
>>>>>> +int sysctl_tcp_retrans_txhash_mode __read_mostly;
>>>>>> +
>>>>>>  #define FLAG_DATA              0x01 /* Incoming frame contained
>>>>>>data.
>>>>>>        */
>>>>>>  #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was a
>>>>>>window update.       */
>>>>>>  #define FLAG_DATA_ACKED                0x04 /* This ACK acknowledge=
d
>>>>>>new data.         */
>>>>>> @@ -3674,6 +3677,13 @@ static int tcp_ack(struct sock *sk, const
>>>>>>struct
>>>>>>sk_buff *skb, int flag)
>>>>>>         flag |=3D tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_u=
na,
>>>>>>&acked,
>>>>>>                                     &sack_state, &now);
>>>>>>
>>>>>> +       /* Check if we should set txhash (would not cause
>>>>>>reordering) */
>>>>>> +       if (tp->txhash_want &&
>>>>>> +           (tp->packets_out - tp->sacked_out) < tp->reordering) {
>>>>>> +               sk_set_txhash(sk);
>>>>>> +               tp->txhash_want =3D 0;
>>>>>> +       }
>>>>>> +
>>>>>>         if (tcp_ack_is_dubious(sk, flag)) {
>>>>>>                 is_dupack =3D !(flag & (FLAG_SND_UNA_ADVANCED |
>>>>>>FLAG_NOT_DUP));
>>>>>>                 tcp_fastretrans_alert(sk, acked, is_dupack, &flag,
>>>>>>&rexmit);
>>>>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>>>>> index 896e9df..58490ac 100644
>>>>>> --- a/net/ipv4/tcp_output.c
>>>>>> +++ b/net/ipv4/tcp_output.c
>>>>>> @@ -2738,9 +2738,30 @@ int tcp_retransmit_skb(struct sock *sk, struc=
t
>>>>>>sk_buff *skb, int segs)
>>>>>>                 tp->retrans_out +=3D tcp_skb_pcount(skb);
>>>>>>
>>>>>>                 /* Save stamp of the first retransmit. */
>>>>>> -               if (!tp->retrans_stamp)
>>>>>> +               if (!tp->retrans_stamp) {
>>>>>>                         tp->retrans_stamp =3D tcp_skb_timestamp(skb)=
;
>>>>>>
>>>>>> +                       /* Determine if we should reset hash, only
>>>>>>done
>>>>>>once
>>>>>> +                        * per recovery
>>>>>> +                        */
>>>>>> +                       if ((!tp->txhash_rto ||
>>>>>> +                            sysctl_tcp_retrans_txhash_mode > 0) &&
>>>>>> +                           sk->sk_txhash &&
>>>>>> +                           (prandom_u32_max(100) <
>>>>>> +                            sysctl_tcp_retrans_txhash_prob)) {
>>>>>> +                               /* If not too much reordering, or
>>>>>>RTT is
>>>>>> +                                * small enough that we don't care
>>>>>>about
>>>>>> +                                * reordering, then change it now.
>>>>>> +                                * Else, wait until it is safe.
>>>>>> +                                */
>>>>>> +                               if ((tp->packets_out -
>>>>>>tp->sacked_out) <
>>>>>> +                                   tp->reordering)
>>>>>I don't parse this logic ... suppose reordering is 100 (not uncommon
>>>>>today due to the last packet being delivered slightly earlier than the
>>>>>rest), and cwnd=3D=3Dpackets_out =3D~200,we only want to rehash until =
half
>>>>>of the packets are sacked, so we are still rehashing even when
>>>>>reordering is heavy?
>>>>
>>>> In your scenario, there would be no re-hashing until sacked_out is 101
>>>> ((packets_out - sacked_out) < 100). This code would mark txhash_want.
>>>> Then when an ACK is received and the conditional is true, txhash
>>>> would be changed.
>>>>
>>>> Now, the test does not prevent retransmissions due to reordering in al=
l
>>>> cases, but hopefully in most. I will also add the test you recommended=
,
>>>> checking for CA_Loss, to prevent too much re-hashing.
>>> If the whole point is to rehash at most once between recovery events,
>>> why do we need this complicated change at per packet level in
>>> tcp_retransmit_skb()? there are functions that start  and end recovery
>>> (tcp_enter_recovery, tcp_end_cwnd_reduction). our retransmission logic
>>> is already very complicated.
>>>
>>> I still don't understand the incentive of starting the rehashing
>>> half-way retransmitting depending on the sacking and reordering
>>> status, for temporarily congestion as you've mentioned.
>>>
>>> is this feature unique for intra-DC connections?
>>I thought more about this patch on my way home and have more
>>questions: why do we exclude RTO retransmission specifically? also
>>when we rehash, we'll introduce reordering either in recovery or after
>>recovery, as some TCP CC like bbr would continue sending regardlessly,
>>so starting in tcp_ack() with tp->txhash_want does not really prevent
>>causing more reordering.
>>
>>so if we want to rehash upon a recovery event (fast or timeout), then
>>we can make a helper function ie tcp_retry_alt_path, and just call it
>>in tcp_enter_loss and tcp_recovery (which are called once per
>>recovery). Since it'll cause reordering anyways, I doubt we need to
>>check tp->reordering at all. If packets already traverse different
>>paths, rehashing can make it better or worse. if packets weren't
>>traversing different paths, the rehashing itself can introduce
>>reordering. so in the end there is much benefit to make decision based
>>on current inflight and reordering IMO...
>>
>>
>>>
>>>>
>>>>>
>>>>>also where do we check RTT is small?
>>>>
>>>> The RTT comment is left over from a previous version, I will remove it=
.
>>>>
>>>>>
>>>>>> +                                       sk_set_txhash(sk);
>>>>>> +                               else
>>>>>> +                                       tp->txhash_want =3D 1;
>>>>>> +                       }
>>>>>> +               }
>>>>>> +
>>>>>>         } else if (err !=3D -EBUSY) {
>>>>>>                 NET_INC_STATS(sock_net(sk),
>>>>>>LINUX_MIB_TCPRETRANSFAIL);
>>>>>>         }
>>>>>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>>>>>> index 3ea1cf8..e66baad 100644
>>>>>> --- a/net/ipv4/tcp_timer.c
>>>>>> +++ b/net/ipv4/tcp_timer.c
>>>>>> @@ -186,6 +186,8 @@ static int tcp_write_timeout(struct sock *sk)
>>>>>>
>>>>>>         if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
>>>>>>                 if (icsk->icsk_retransmits) {
>>>>>> +                       tp->txhash_rto =3D 1;
>>>>>> +                       tp->txhash_want =3D 0;
>>>>>>                         dst_negative_advice(sk);
>>>>>>                         if (tp->syn_fastopen || tp->syn_data)
>>>>>>                                 tcp_fastopen_cache_set(sk, 0, NULL,
>>>>>>true, 0);
>>>>>> @@ -218,6 +220,8 @@ static int tcp_write_timeout(struct sock *sk)
>>>>>>                 } else {
>>>>>>                         sk_rethink_txhash(sk);
>>>>>>                 }
>>>>>> +               tp->txhash_rto =3D 1;
>>>>>> +               tp->txhash_want =3D 0;
>>>>>>
>>>>>>                 retry_until =3D net->ipv4.sysctl_tcp_retries2;
>>>>>>                 if (sock_flag(sk, SOCK_DEAD)) {
>>>>>> --
>>>>>> 2.9.3
>>>>>>
>>>>
>
