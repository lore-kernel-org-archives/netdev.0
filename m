From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Sat, 12 Aug 2017 14:23:58 +0200
Message-ID: <20170812142358.08291888@redhat.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: brouer@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751567AbdHLMYF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:24:05 -0400
In-Reply-To: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 11 Aug 2017 19:51:10 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:

> Hi
> 
> I made some tests for performance comparison.

Thanks for doing this. Feel free to Cc me, if you do more of these
tests (so I don't miss them on the mailing list).

I don't understand stand if you are reporting a potential problem?

It would be good if you can provide a short summary section (of the
issue) in the _start_ of the email, and then provide all this nice data
afterwards, to back your case.

My understanding is, you report:

1. VLANs on ixgbe show a 30-40% slowdown
2. System stopped scaling after 7+ CPUs


> Tested HW (FORWARDING HOST):
> 
> Intel(R) Xeon(R) Gold 6132 CPU @ 2.60GHz

Interesting, I've not heard about a Intel CPU called "Gold" before now,
but it does exist:
 https://ark.intel.com/products/123541/Intel-Xeon-Gold-6132-Processor-19_25M-Cache-2_60-GHz


> Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)

This is one of my all time favorite NICs!
 
> Test diagram:
> 
> 
> TRAFFIC GENERATOR (ethX) -> (enp216s0f0 - RX Traffic) FORWARDING HOST 
> (enp216s0f1(vlan1000) - TX Traffic) -> (ethY) SINK
> 
> Forwarder traffic: UDP random ports from 9 to 19 with random hosts from 
> 172.16.0.1 to 172.16.0.255
> 
> TRAFFIC GENERATOR TX is stable 9.9Mpps (in kernel pktgen)

What kind of traffic flow?  E.g. distribution, many/few source IPs...

 
> Settings used for FORWARDING HOST (changed param. was only number of RSS 
> combined queues + set affinity assignment for them to fit with first 
> numa node where 2x10G port card is installed)
> 
> ixgbe driver used from kernel (in-kernel build - not a module)
> 

Nice with a script showing you setup, thanks. I would be good if it had
comments, telling why you think this is a needed setup adjustment.

> #!/bin/sh
> ifc='enp216s0f0 enp216s0f1'
> for i in $ifc
>          do
>          ip link set up dev $i
>          ethtool -A $i autoneg off rx off tx off

Good:
 Turning off Ethernet flow control, to avoid receiver being the
 bottleneck via pause-frames.

>          ethtool -G $i rx 4096 tx 1024

You adjust the RX and TX ring queue sizes, this have effects that you
don't realize.  Especially for the ixgbe driver, which have a page
recycle trick tied to the RX ring queue size.

>          ip link set $i txqueuelen 1000

Setting tx queue len to the default 1000 seems redundant.

>          ethtool -C $i rx-usecs 10

Adjusting this also have effects you might not realize.  This actually
also affect the page recycle scheme of ixgbe.  And can sometimes be
used to solve stalling on DMA TX completions, which could be you issue
here.


>          ethtool -L $i combined 16
>          ethtool -K $i gro on tso on gso off sg on l2-fwd-offload off 
> tx-nocache-copy on ntuple on

Here are many setting above.

GRO/GSO/TSO for _forwarding_ is actually bad... in my tests, enabling
this result in approx 10% slowdown.

AFAIK "tx-nocache-copy on" was also determined to be a bad option.

The "ntuple on" AFAIK disables the flow-director in the NIC.  I though
this would actually help VLAN traffic, but I guess not.


>          ethtool -N $i rx-flow-hash udp4 sdfn

Why do you change the NICs flow-hash?

>          done
> 
> ip link set up dev enp216s0f0
> ip link set up dev enp216s0f1
> 
> ip a a 10.0.0.1/30 dev enp216s0f0
> 
> ip link add link enp216s0f1 name vlan1000 type vlan id 1000
> ip link set up dev vlan1000
> ip a a 10.0.0.5/30 dev vlan1000
> 
> 
> ip route add 172.16.0.0/12 via 10.0.0.6
> 
> ./set_irq_affinity.sh -x 14-27,42-43 enp216s0f0
> ./set_irq_affinity.sh -x 14-27,42-43 enp216s0f1
> #cat  /sys/devices/system/node/node1/cpulist
> #14-27,42-55
> #cat  /sys/devices/system/node/node0/cpulist
> #0-13,28-41

Is this a NUMA system?

 
> #################################################
> 
> 
> Looks like forwarding performance when using vlans on ixgbe is less that 
> without vlans for about 30-40% (wondering if this is some vlan 
> offloading problem and ixgbe)

I would see this as a problem/bug that enabling VLANs cost this much.
 
> settings below:
> 
> ethtool -k enp216s0f0
> Features for enp216s0f0:
> Cannot get device udp-fragmentation-offload settings: Operation not 
> supported
> rx-checksumming: on
> tx-checksumming: on
>          tx-checksum-ipv4: off [fixed]
>          tx-checksum-ip-generic: on
>          tx-checksum-ipv6: off [fixed]
>          tx-checksum-fcoe-crc: off [fixed]
>          tx-checksum-sctp: on
> scatter-gather: on
>          tx-scatter-gather: on
>          tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>          tx-tcp-segmentation: on
>          tx-tcp-ecn-segmentation: off [fixed]
>          tx-tcp-mangleid-segmentation: on
>          tx-tcp6-segmentation: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: on
> receive-hashing: on
> highdma: on [fixed]
> rx-vlan-filter: on
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: on
> tx-gre-csum-segmentation: on
> tx-ipxip4-segmentation: on
> tx-ipxip6-segmentation: on
> tx-udp_tnl-segmentation: on
> tx-udp_tnl-csum-segmentation: on
> tx-gso-partial: on
> tx-sctp-segmentation: off [fixed]
> tx-esp-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: on
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off
> hw-tc-offload: off
> esp-hw-offload: off [fixed]
> esp-tx-csum-hw-offload: off [fixed]
> rx-udp_tunnel-port-offload: on
> 
> 
> Another thing is that forwarding performance does not scale with number 
> of cores when 7+ cores are reached

I've seen problems with using Hyper-Threading CPUs.  Could it be that
above 7 CPUs you are starting to use sibling-cores ? 
 

> perf top:
> 
>   PerfTop:   77835 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz 
> cycles],  (all, 56 CPUs)
> ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> 
>      16.32%  [kernel]       [k] skb_dst_force
>      16.30%  [kernel]       [k] dst_release
>      15.11%  [kernel]       [k] rt_cache_valid
>      12.62%  [kernel]       [k] ipv4_mtu

It seems a little strange that these 4 functions are on the top

>       5.60%  [kernel]       [k] do_raw_spin_lock

Why is calling/taking this lock? (Use perf call-graph recording).

>       3.03%  [kernel]       [k] fib_table_lookup
>       2.70%  [kernel]       [k] ip_finish_output2
>       2.10%  [kernel]       [k] dev_gro_receive
>       1.89%  [kernel]       [k] eth_type_trans
>       1.81%  [kernel]       [k] ixgbe_poll
>       1.15%  [kernel]       [k] ixgbe_xmit_frame_ring
>       1.06%  [kernel]       [k] __build_skb
>       1.04%  [kernel]       [k] __dev_queue_xmit
>       0.97%  [kernel]       [k] ip_rcv
>       0.78%  [kernel]       [k] netif_skb_features
>       0.74%  [kernel]       [k] ipt_do_table

Unloading netfilter modules, will give more performance, but it
semifake to do so.

>       0.70%  [kernel]       [k] acpi_processor_ffh_cstate_enter
>       0.64%  [kernel]       [k] ip_forward
>       0.59%  [kernel]       [k] __netif_receive_skb_core
>       0.55%  [kernel]       [k] dev_hard_start_xmit
>       0.53%  [kernel]       [k] ip_route_input_rcu
>       0.53%  [kernel]       [k] ip_rcv_finish
>       0.51%  [kernel]       [k] page_frag_free
>       0.50%  [kernel]       [k] kmem_cache_alloc
>       0.50%  [kernel]       [k] udp_v4_early_demux
>       0.44%  [kernel]       [k] skb_release_data
>       0.42%  [kernel]       [k] inet_gro_receive
>       0.40%  [kernel]       [k] sch_direct_xmit
>       0.39%  [kernel]       [k] __local_bh_enable_ip
>       0.33%  [kernel]       [k] netdev_pick_tx
>       0.33%  [kernel]       [k] validate_xmit_skb
>       0.28%  [kernel]       [k] fib_validate_source
>       0.27%  [kernel]       [k] deliver_ptype_list_skb
>       0.25%  [kernel]       [k] eth_header
>       0.23%  [kernel]       [k] get_dma_ops
>       0.22%  [kernel]       [k] skb_network_protocol
>       0.21%  [kernel]       [k] ip_output
>       0.21%  [kernel]       [k] vlan_dev_hard_start_xmit
>       0.20%  [kernel]       [k] ixgbe_alloc_rx_buffers
>       0.18%  [kernel]       [k] nf_hook_slow
>       0.18%  [kernel]       [k] apic_timer_interrupt
>       0.18%  [kernel]       [k] virt_to_head_page
>       0.18%  [kernel]       [k] build_skb
>       0.16%  [kernel]       [k] swiotlb_map_page
>       0.16%  [kernel]       [k] ip_finish_output
>       0.16%  [kernel]       [k] udp4_gro_receive
> 
> 
> RESULTS:
> 
> CSV format - delimeter ";"
> 
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;1;64;1470912;88247040;1470720;85305530
> 1;1;64;1470912;88285440;1470977;85335110
> 2;1;64;1470464;88247040;1470402;85290508
> 3;1;64;1471424;88262400;1471230;85353728
> 4;1;64;1468736;88166400;1468672;85201652
> 5;1;64;1470016;88181760;1469949;85234944
> 6;1;64;1470720;88247040;1470466;85290624
> 7;1;64;1471232;88277760;1471167;85346246
> 8;1;64;1469184;88170240;1469249;85216326
> 9;1;64;1470592;88227840;1470847;85294394

Single core 1.47Mpps seems a little low, I would expect 2Mpps.

> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;2;64;2413120;144802560;2413245;139975924
> 1;2;64;2415296;144913920;2415356;140098188
> 2;2;64;2416768;144898560;2416573;140105670
> 3;2;64;2418176;145056000;2418110;140261806
> 4;2;64;2416512;144990720;2416509;140172950
> 5;2;64;2415168;144860160;2414466;140064780
> 6;2;64;2416960;144983040;2416833;140190930
> 7;2;64;2413632;144768000;2413568;140001734
> 8;2;64;2415296;144898560;2414589;140087168
> 9;2;64;2416576;144963840;2416892;140190930
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;3;64;3419008;205155840;3418882;198239244
> 1;3;64;3428032;205585920;3427971;198744234
> 2;3;64;3425472;205536000;3425344;198677260
> 3;3;64;3425088;205470720;3425156;198603136
> 4;3;64;3427648;205693440;3426883;198773888
> 5;3;64;3426880;205670400;3427392;198796044
> 6;3;64;3429120;205678080;3430140;198848186
> 7;3;64;3422976;205355520;3423490;198458136
> 8;3;64;3423168;205336320;3423486;198495372
> 9;3;64;3424384;205493760;3425538;198617868
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;4;64;4406464;264364800;4405244;255560296
> 1;4;64;4404672;264349440;4405122;255541504
> 2;4;64;4402368;264049920;4403326;255188864
> 3;4;64;4401344;264076800;4400702;255207134
> 4;4;64;4385536;263074560;4386620;254312716
> 5;4;64;4386560;263189760;4385404;254379532
> 6;4;64;4398784;263857920;4399031;255025288
> 7;4;64;4407232;264445440;4407998;255637900
> 8;4;64;4413184;264698880;4413758;255875816
> 9;4;64;4411328;264526080;4411906;255712372
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;5;64;5094464;305871360;5094464;295657262
> 1;5;64;5090816;305514240;5091201;295274810
> 2;5;64;5088384;305387520;5089792;295175108
> 3;5;64;5079296;304869120;5079484;294680368
> 4;5;64;5092992;305544960;5094207;295349166
> 5;5;64;5092416;305502720;5093372;295334260
> 6;5;64;5080896;304896000;5081090;294677004
> 7;5;64;5085376;305114880;5086401;294933058
> 8;5;64;5092544;305575680;5092036;295356938
> 9;5;64;5093056;305652480;5093832;295449506
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;6;64;5705088;342351360;5705784;330965110
> 1;6;64;5710272;342743040;5707591;331373952
> 2;6;64;5703424;342182400;5701826;330776552
> 3;6;64;5708736;342604800;5707963;331147462
> 4;6;64;5710144;342654720;5712067;331202910
> 5;6;64;5712064;342777600;5711361;331292288
> 6;6;64;5710144;342585600;5708607;331144272
> 7;6;64;5699840;342021120;5697853;330609222
> 8;6;64;5701184;342124800;5702909;330653592
> 9;6;64;5711360;342735360;5713283;331247686
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;7;64;6244416;374603520;6243591;362180072
> 1;7;64;6230912;374016000;6231490;361534126
> 2;7;64;6244800;374776320;6244866;362224326
> 3;7;64;6238720;374376960;6238261;361838510
> 4;7;64;6218816;373079040;6220413;360683962
> 5;7;64;6224320;373566720;6225086;361017404
> 6;7;64;6224000;373570560;6221370;360936088
> 7;7;64;6210048;372741120;6210627;360212654
> 8;7;64;6231616;374035200;6231537;361445502
> 9;7;64;6227840;373724160;6228802;361162752
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;8;64;6251840;375144960;6251849;362609678
> 1;8;64;6250816;375014400;6250881;362547038
> 2;8;64;6257728;375432960;6257160;362911104
> 3;8;64;6255552;375325440;6255622;362822074
> 4;8;64;6243776;374576640;6243270;362120622
> 5;8;64;6237184;374296320;6237690;361790080
> 6;8;64;6240960;374415360;6240714;361927366
> 7;8;64;6222784;373317120;6223746;360854424
> 8;8;64;6225920;373593600;6227014;361154980
> 9;8;64;6238528;374304000;6237701;361845238
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;14;64;6486144;389184000;6486135;376236488
> 1;14;64;6454912;387390720;6454222;374466734
> 2;14;64;6441152;386480640;6440431;373572780
> 3;14;64;6450240;386972160;6450870;374070014
> 4;14;64;6465600;387997440;6467221;375089654
> 5;14;64;6448384;386860800;6448000;373980230
> 6;14;64;6452352;387095040;6452148;374168904
> 7;14;64;6441984;386507520;6443203;373665058
> 8;14;64;6456704;387340800;6455744;374429092
> 9;14;64;6464640;387901440;6465218;374949004
> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
> 0;16;64;6939008;416325120;6938696;402411192
> 1;16;64;6941952;416444160;6941745;402558918
> 2;16;64;6960576;417584640;6960707;403698718
> 3;16;64;6940736;416486400;6941820;402503876
> 4;16;64;6927680;415741440;6927420;401853870
> 5;16;64;6929792;415687680;6929917;401839196
> 6;16;64;6950400;416989440;6950661;403026166
> 7;16;64;6953664;417216000;6953454;403260544
> 8;16;64;6948480;416851200;6948800;403023266
> 9;16;64;6924160;415422720;6924092;401542468

I've seen Linux scale beyond 6.9Mpps, thus I also see this as an
issue/bug.  You could be stalling on DMA TX completion being too slow,
but you already increased the interval and increased the TX ring queue
size.  You could play with those setting and see if it changes this?

Could you try my napi_monitor tool in:
 https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/samples/bpf

Also provide the output from:
 mpstat -P ALL -u -I SCPU -I SUM 2
  
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
