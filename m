From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 15 Aug 2017 02:38:56 +0200
Message-ID: <1ff1b747-758e-afdd-9376-80ff3bd8a6d5@itcare.pl>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
 <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
 <20170814181957.5be27906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:50954 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752740AbdHOAkH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 20:40:07 -0400
In-Reply-To: <20170814181957.5be27906@redhat.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-08-14 o 18:19, Jesper Dangaard Brouer pisze:
> On Sun, 13 Aug 2017 18:58:58 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>
>> To show some difference below comparision vlan/no-vlan traffic
>>
>> 10Mpps forwarded traffic vith no-vlan vs 6.9Mpps with vlan
> I'm trying to reproduce in my testlab (with ixgbe).  I do see, a
> performance reduction of about 10-19% when I forward out a VLAN
> interface.  This is larger than I expected, but still lower than what
> you reported 30-40% slowdown.
>
> [...]
Ok mellanox afrrived (MT27700 - mlnx5 driver)
And to compare melannox with vlans and without: 33% performance 
degradation (less than with ixgbe where i reach ~40% with same settings)

Mellanox without TX traffix on vlan:
ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
0;16;64;11089305;709715520;8871553;567779392
1;16;64;11096292;710162688;11095566;710116224
2;16;64;11095770;710129280;11096799;710195136
3;16;64;11097199;710220736;11097702;710252928
4;16;64;11080984;567081856;11079662;709098368
5;16;64;11077696;708972544;11077039;708930496
6;16;64;11082991;709311424;8864802;567347328
7;16;64;11089596;709734144;8870927;709789184
8;16;64;11094043;710018752;11095391;710105024

Mellanox with TX traffic on vlan:
ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
0;16;64;7369914;471674496;7370281;471697980
1;16;64;7368896;471609408;7368043;471554752
2;16;64;7367577;471524864;7367759;471536576
3;16;64;7368744;377305344;7369391;471641024
4;16;64;7366824;471476736;7364330;471237120
5;16;64;7368352;471574528;7367239;471503296
6;16;64;7367459;471517376;7367806;471539584
7;16;64;7367190;471500160;7367988;471551232
8;16;64;7368023;471553472;7368076;471556864



ethtool settings for both tests:
ifc='enp175s0f0 enp175s0f1'
for i in $ifc
         do
         ip link set up dev $i
         ethtool -A $i autoneg off rx off tx off
         ethtool -G $i rx 128 tx 256
         ip link set $i txqueuelen 1000
         ethtool -C $i rx-usecs 25
         ethtool -L $i combined 16
         ethtool -K $i gro off tso off gso off sg on l2-fwd-offload off 
tx-nocache-copy off ntuple on
         ethtool -N $i rx-flow-hash udp4 sdfn
         done

and perf top:
    PerfTop:   83650 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     14.25%  [kernel]       [k] dst_release
     14.17%  [kernel]       [k] skb_dst_force
     13.41%  [kernel]       [k] rt_cache_valid
     11.47%  [kernel]       [k] ip_finish_output2
      7.01%  [kernel]       [k] do_raw_spin_lock
      5.07%  [kernel]       [k] page_frag_free
      3.47%  [mlx5_core]    [k] mlx5e_xmit
      2.88%  [kernel]       [k] fib_table_lookup
      2.43%  [mlx5_core]    [k] skb_from_cqe.isra.32
      1.97%  [kernel]       [k] virt_to_head_page
      1.81%  [mlx5_core]    [k] mlx5e_poll_tx_cq
      0.93%  [kernel]       [k] __dev_queue_xmit
      0.87%  [kernel]       [k] __build_skb
      0.84%  [kernel]       [k] ipt_do_table
      0.79%  [kernel]       [k] ip_rcv
      0.79%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      0.78%  [kernel]       [k] netif_skb_features
      0.73%  [kernel]       [k] __netif_receive_skb_core
      0.52%  [kernel]       [k] dev_hard_start_xmit
      0.52%  [kernel]       [k] build_skb
      0.51%  [kernel]       [k] ip_route_input_rcu
      0.50%  [kernel]       [k] skb_unref
      0.49%  [kernel]       [k] ip_forward
      0.48%  [mlx5_core]    [k] mlx5_cqwq_get_cqe
      0.44%  [kernel]       [k] udp_v4_early_demux
      0.41%  [kernel]       [k] napi_consume_skb
      0.40%  [kernel]       [k] __local_bh_enable_ip
      0.39%  [kernel]       [k] ip_rcv_finish
      0.39%  [kernel]       [k] kmem_cache_alloc
      0.38%  [kernel]       [k] sch_direct_xmit
      0.33%  [kernel]       [k] validate_xmit_skb
      0.32%  [mlx5_core]    [k] mlx5e_free_rx_wqe_reuse
      0.29%  [kernel]       [k] netdev_pick_tx
      0.28%  [mlx5_core]    [k] mlx5e_build_rx_skb
      0.27%  [kernel]       [k] deliver_ptype_list_skb
      0.26%  [kernel]       [k] fib_validate_source
      0.26%  [mlx5_core]    [k] mlx5e_napi_poll
      0.26%  [mlx5_core]    [k] mlx5e_handle_rx_cqe
      0.26%  [mlx5_core]    [k] mlx5e_rx_cache_get
      0.25%  [kernel]       [k] eth_header
      0.23%  [kernel]       [k] skb_network_protocol
      0.20%  [kernel]       [k] nf_hook_slow
      0.20%  [kernel]       [k] vlan_passthru_hard_header
      0.20%  [kernel]       [k] vlan_dev_hard_start_xmit
      0.19%  [kernel]       [k] swiotlb_map_page
      0.18%  [kernel]       [k] compound_head
      0.18%  [kernel]       [k] neigh_connected_output
      0.18%  [mlx5_core]    [k] mlx5e_alloc_rx_wqe
      0.18%  [kernel]       [k] ip_output
      0.17%  [kernel]       [k] prefetch_freepointer.isra.70
      0.17%  [kernel]       [k] __slab_free
      0.16%  [kernel]       [k] eth_type_vlan
      0.16%  [kernel]       [k] ip_finish_output
      0.15%  [kernel]       [k] kmem_cache_free_bulk
      0.14%  [kernel]       [k] netif_receive_skb_internal




wondering why this:
      1.97%  [kernel]       [k] virt_to_head_page

is in top...


>>>>> perf top:
>>>>>
>>>>>     PerfTop:   77835 irqs/sec  kernel:99.7%
>>>>> ---------------------------------------------
>>>>>
>>>>>        16.32%  [kernel]       [k] skb_dst_force
>>>>>        16.30%  [kernel]       [k] dst_release
>>>>>        15.11%  [kernel]       [k] rt_cache_valid
>>>>>        12.62%  [kernel]       [k] ipv4_mtu
>>>> It seems a little strange that these 4 functions are on the top
> I don't see these in my test.
>
>>>>   
>>>>>         5.60%  [kernel]       [k] do_raw_spin_lock
>>>> Why is calling/taking this lock? (Use perf call-graph recording).
>>> can be hard to paste it here:)
>>> attached file
> The attached was very big. Please don't attach so big file on mailing
> lists.  Next time plase share them via e.g. pastebin. The output was a
> capture from your terminal, which made the output more difficult to
> read.  Hint: You can/could use perf --stdio and place it in a file
> instead.
>
> The output (extracted below) didn't show who called 'do_raw_spin_lock',
> BUT it showed another interesting thing.  The kernel code
> __dev_queue_xmit() in might create route dst-cache problem for itself(?),
> as it will first call skb_dst_force() and then skb_dst_drop() when the
> packet is transmitted on a VLAN.
>
>   static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>   {
>   [...]
> 	/* If device/qdisc don't need skb->dst, release it right now while
> 	 * its hot in this cpu cache.
> 	 */
> 	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> 		skb_dst_drop(skb);
> 	else
> 		skb_dst_force(skb);
>
>
> - -
> Best regards,
>    Jesper Dangaard Brouer
>    MSc.CS, Principal Kernel Engineer at Red Hat
>    LinkedIn: http://www.linkedin.com/in/brouer
>
> Extracted part of attached perf output:
>
>   --5.37%--ip_rcv_finish
>     |
>     |--4.02%--ip_forward
>     |   |
>     |    --3.92%--ip_forward_finish
>     |       |
>     |        --3.91%--ip_output
>     |          |
>     |           --3.90%--ip_finish_output
>     |              |
>     |               --3.88%--ip_finish_output2
>     |                  |
>     |                   --2.77%--neigh_connected_output
>     |                     |
>     |                      --2.74%--dev_queue_xmit
>     |                         |
>     |                          --2.73%--__dev_queue_xmit
>     |                             |
>     |                             |--1.66%--dev_hard_start_xmit
>     |                             |   |
>     |                             |    --1.64%--vlan_dev_hard_start_xmit
>     |                             |       |
>     |                             |        --1.63%--dev_queue_xmit
>     |                             |           |
>     |                             |            --1.62%--__dev_queue_xmit
>     |                             |               |
>     |                             |               |--0.99%--skb_dst_drop.isra.77
>     |                             |               |   |
>     |                             |               |   --0.99%--dst_release
>     |                             |               |
>     |                             |                --0.55%--sch_direct_xmit
>     |                             |
>     |                              --0.99%--skb_dst_force
>     |
>      --1.29%--ip_route_input_noref
>          |
>           --1.29%--ip_route_input_rcu
>               |
>                --1.05%--rt_cache_valid
>
