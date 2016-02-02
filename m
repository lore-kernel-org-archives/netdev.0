From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Mon, 1 Feb 2016 19:31:27 -0500
Message-ID: <20160202003127.GA25154@oracle.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19672 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcBBAbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 19:31:36 -0500
Content-Disposition: inline
In-Reply-To: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/31/16 13:37), Tom Herbert wrote:
> 
> Call get_unaligned_be32 when we access 32-bit fields in
> __skb_flow_dissect. At the beginning check for unlikely case of
> 1-byte aligned packet.
> 
> Note that flow_dissector may be asked to parse packet unaligned
> fields in two instances:

I tested this out with the following setup (hostnames in quotes,
network connectivity in the line above)

                                      gre-tunnel 
     (eth1) --- (eth1)      (eth0) ... {routed} ...  (eth0) 
   "sparc44"         "sparc45"                      "x86-1"


eth1 connections are point-to-point ethernets.
The GRE tunnel is configured with some non-zero gre key.

So sparc45 bridges sparc44 to x86-1 and has

  sparc45# brctl show br0
  bridge name     bridge id               STP enabled     interfaces
  br0             8000.0010e0570711       no              eth1
                                                          gretap2


I tried various pings etc across the nodes, and made sure that
(excluding the mpls change)  all of the changes in Tom's patch
worked fine. To do this, I had to enable rps and disable rxhash/ntuple
in my intel driver. 

And then I noticed that the iph->saddr access does indeed result in
an unaligned access (because this time it gets called with
flow_keys_dissector). The other thing that generated unaligned access
was the attempt to do this 
               if (proto == htons(ETH_P_TEB)) {
			:
                        eth = __skb_header_pointer(skb, nhoff,
                                                   sizeof(_eth),
                                                   data, hlen, &_eth);
			:
                        proto = eth->h_proto;
                }
which I fixed thus:

@@ -394,7 +407,7 @@ ip_proto_again:
                                                   data, hlen, &_eth);
                        if (!eth)
                                goto out_bad;
-                       proto = eth->h_proto;
+                       proto = get_unaligned_be16(&eth->h_proto);
                        nhoff += sizeof(*eth);
                }

Having said all this, the larger problem remains:

There are a number of unaligned access on the xmit path, I've listed
a few below. A lot of it is coming of gre_tap_xmit not setting up 
offsets properly, but there are others.
 
In general, since the actual path taken by the packet (i.e., 
what driver gets to process this next, what types/sizes of headers 
will get added, etc) is determined dynamically, it's not enough to just
do a one-time skb_reserve (or page_offset) for NET_IP_ALIGN.

Kernel unaligned access at TPC[9150dc] ipv4_neigh_lookup+0x38/0x170
CPU: 3 PID: 0 Comm: swapper/3 Tainted: G            E   4.4.0-dissect+ #19
Call Trace:
 [0000000000432f4c] kernel_unaligned_trap+0xfc/0x5ac
 [0000000000427ef8] sun4v_do_mna+0x58/0x9c
 [0000000000406d30] sun4v_mna+0x5c/0x68
 [00000000009150dc] ipv4_neigh_lookup+0x38/0x170
 [00000000008ead10] neigh_update+0x450/0x5cc
 [00000000008eb8b8] neigh_event_ns+0x84/0x94
 [00000000009518f8] arp_process+0x470/0x854
 [0000000000951e78] arp_rcv+0x19c/0x1dc
 [00000000008d647c] __netif_receive_skb_core+0xa24/0xa58
 [00000000008d6510] __netif_receive_skb+0x60/0x74
 [00000000008d65dc] process_backlog+0xb8/0x168
 [00000000008dc9f8] napi_poll+0x74/0x1c8
 [00000000008dcc20] net_rx_action+0xd4/0x1d4
 [00000000004633a4] __do_softirq+0x11c/0x28c
 [000000000042abb0] do_softirq_own_stack+0x34/0x48
 [0000000000463050] irq_exit+0x48/0x60


Kernel unaligned access at TPC[103e720c] build_header+0x64/0xc4 [ip_gre]
CPU: 44 PID: 0 Comm: swapper/44 Tainted: G            E   4.4.0-dissect+ #19
Call Trace:
 [0000000000432f4c] kernel_unaligned_trap+0xfc/0x5ac
 [0000000000427ef8] sun4v_do_mna+0x58/0x9c
 [0000000000406d30] sun4v_mna+0x5c/0x68
 [00000000103e720c] build_header+0x64/0xc4 [ip_gre]
 [00000000103e76a4] __gre_xmit+0x40/0x7c [ip_gre]
 [00000000103e79e8] gre_tap_xmit+0xfc/0x12c [ip_gre]
 [00000000008de6dc] dev_hard_start_xmit+0x304/0x3ec
 [0000000000904d30] sch_direct_xmit+0x74/0x1dc
 [00000000008df1a8] __dev_queue_xmit+0x568/0x7e8
 [00000000008df45c] dev_queue_xmit+0x10/0x24
 [0000000010207654] ip6_finish_output2+0x5b4/0x6b0 [ipv6]
 [0000000010207954] ip6_finish_output+0x204/0x218 [ipv6]
 [0000000010207afc] ip6_output+0x194/0x1a8 [ipv6]
 [000000001021f97c] ndisc_send_skb+0x390/0x438 [ipv6]
 [000000001021ff14] ndisc_send_rs+0xe0/0xfc [ipv6]
 [000000001020b190] addrconf_rs_timer+0xc4/0x124 [ipv6]


Kernel unaligned access at TPC[969ee0] iptunnel_xmit+0xcc/0x1c0
CPU: 0 PID: 0 Comm: swapper/0 Tainted: G            E   4.4.0-dissect+ #19
Call Trace:
 [0000000000432f4c] kernel_unaligned_trap+0xfc/0x5ac
 [0000000000427ef8] sun4v_do_mna+0x58/0x9c
 [0000000000406d30] sun4v_mna+0x5c/0x68
 [0000000000969ee0] iptunnel_xmit+0xcc/0x1c0
 [00000000103dc9dc] ip_tunnel_xmit+0xb78/0xc2c [ip_tunnel]
 [00000000103e76d0] __gre_xmit+0x6c/0x7c [ip_gre]
 [00000000103e79e8] gre_tap_xmit+0xfc/0x12c [ip_gre]
 [00000000008de6dc] dev_hard_start_xmit+0x304/0x3ec
 [0000000000904d30] sch_direct_xmit+0x74/0x1dc
 [00000000008df1a8] __dev_queue_xmit+0x568/0x7e8
 [00000000008df45c] dev_queue_xmit+0x10/0x24
 [00000000104034b8] br_dev_queue_push_xmit+0x1d8/0x1fc [bridge]
 [000000001040355c] br_forward_finish+0x80/0x94 [bridge]
 [0000000010403684] __br_forward+0x114/0x124 [bridge]
 [0000000010403700] br_forward+0x6c/0x94 [bridge]
