From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: release skb->dst in sock_queue_rcv_skb()
Date: Wed, 26 Nov 2008 08:39:30 +0100
Message-ID: <492CFD32.7020109@cosmosbay.com>
References: <492B8274.6080609@cosmosbay.com>	<20081124.210038.90767194.davem@davemloft.net>	<492C919E.3050108@cosmosbay.com> <20081125.180404.157859705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50939 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbYKZHjf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 02:39:35 -0500
In-Reply-To: <20081125.180404.157859705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 26 Nov 2008 01:00:30 +0100
>=20
>> In the meantime, what do you think of the following patch ?
>>
>> [PATCH] net: release skb->dst in sock_queue_rcv_skb()
>>
>> When queuing a skb to sk->sk_receive_queue, we can release its dst, =
not
>> anymore needed.
>> Since current cpu did the dst_hold(), refcount is probably still hot
>> int this cpu caches.
>>
>> This avoids readers to access the original dst to decrement its refc=
ount,
>> possibly a long time after packet reception. This should speedup UDP
>> and RAW receive path.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> I guess the idea is that if we release quickly we'll not have
> to reget the cacheline in owned state.

Yes, this is the idea.

>=20
> I wonder if this might actually slightly hurt loads like tbench where
> we are banging on the refcnt constantly on every cpu anyways.

Yes, the only way to reduce the load on this case is not moving the
increments/decrements : It could help on some machines, and hurt on oth=
ers.
In the long term, only reducing the number of dirtying can help the ave=
rage.

>=20
> Can you do a quick check?
>=20
>=20

Sure I can do a check :)

No impact at all on tbench, unless this bench can run in UDP mode :)


CPU: Core 2, speed 3000.1 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit
mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
599983   599983        11.2948  11.2948    copy_from_user
549349   1149332       10.3416  21.6364    ipt_do_table
245697   1395029        4.6253  26.2617    copy_to_user
221663   1616692        4.1729  30.4346    schedule
144888   1761580        2.7275  33.1621    tcp_sendmsg
136967   1898547        2.5784  35.7406    tcp_ack
115513   2014060        2.1746  37.9151    tcp_transmit_skb
99517    2113577        1.8734  39.7885    sysenter_past_esp
99438    2213015        1.8719  41.6605    ip_queue_xmit
98171    2311186        1.8481  43.5086    tcp_recvmsg
80763    2391949        1.5204  45.0290    __switch_to
79621    2471570        1.4989  46.5278    tcp_v4_rcv
77210    2548780        1.4535  47.9813    dst_release
69387    2618167        1.3062  49.2876    tcp_rcv_established
64709    2682876        1.2182  50.5057    __tcp_push_pending_frames
55223    2738099        1.0396  51.5453    lock_sock_nested
53754    2791853        1.0119  52.5572    sys_socketcall
50092    2841945        0.9430  53.5002    netif_receive_skb
49499    2891444        0.9318  54.4321    release_sock
47796    2939240        0.8998  55.3318    __inet_lookup_established
45162    2984402        0.8502  56.1820    update_curr
44895    3029297        0.8452  57.0272    ip_rcv
42945    3072242        0.8084  57.8356    dev_queue_xmit
42892    3115134        0.8075  58.6431    tcp_event_data_recv
42768    3157902        0.8051  59.4482    local_bh_enable
41555    3199457        0.7823  60.2305    netif_rx
38613    3238070        0.7269  60.9574    __alloc_skb
38016    3276086        0.7157  61.6730    ip_finish_output
36867    3312953        0.6940  62.3671    tcp_current_mss
36759    3349712        0.6920  63.0591    skb_release_data
35560    3385272        0.6694  63.7285    local_bh_enable_ip
34100    3419372        0.6419  64.3704    sock_recvmsg
33829    3453201        0.6368  65.0073    __kfree_skb
32949    3486150        0.6203  65.6275    sched_clock_cpu

