From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH v2 5/5] Add sample for adding simple drop program to
 link
Date: Sat, 9 Apr 2016 09:43:09 -0700
Message-ID: <20160409164308.GA5750@gmail.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
 <57091625.1010206@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, brouer@redhat.com, eric.dumazet@gmail.com,
	ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch,
	johannes@sipsolutions.net, eranlinuxmellanox@gmail.com,
	lorenzo@google.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33306 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbcDIQnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 12:43:13 -0400
Received: by mail-pf0-f175.google.com with SMTP id 184so95049946pff.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 09:43:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57091625.1010206@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 09, 2016 at 10:48:05AM -0400, Jamal Hadi Salim wrote:
> On 16-04-08 12:48 AM, Brenden Blanco wrote:
> >Add a sample program that only drops packets at the
> >BPF_PROG_TYPE_PHYS_DEV hook of a link. With the drop-only program,
> >observed single core rate is ~19.5Mpps.
> >
> >Other tests were run, for instance without the dropcnt increment or
> >without reading from the packet header, the packet rate was mostly
> >unchanged.
> >
> >$ perf record -a samples/bpf/netdrvx1 $(</sys/class/net/eth0/ifindex)
> >proto 17:   19596362 drops/s
> >
> >./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
> >Running... ctrl^C to stop
> >Device: eth4@0
> >Result: OK: 7873817(c7872245+d1572) usec, 38801823 (60byte,0frags)
> >   4927955pps 2365Mb/sec (2365418400bps) errors: 0
> >Device: eth4@1
> >Result: OK: 7873817(c7872123+d1693) usec, 38587342 (60byte,0frags)
> >   4900715pps 2352Mb/sec (2352343200bps) errors: 0
> >Device: eth4@2
> >Result: OK: 7873817(c7870929+d2888) usec, 38718848 (60byte,0frags)
> >   4917417pps 2360Mb/sec (2360360160bps) errors: 0
> >Device: eth4@3
> >Result: OK: 7873818(c7872193+d1625) usec, 38796346 (60byte,0frags)
> >   4927259pps 2365Mb/sec (2365084320bps) errors: 0
> >
> >perf report --no-children:
> >  29.48%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_process_rx_cq
> >  18.17%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_alloc_frags
> >   8.19%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_free_frag
> >   5.35%  ksoftirqd/6  [kernel.vmlinux]  [k] get_page_from_freelist
> >   2.92%  ksoftirqd/6  [kernel.vmlinux]  [k] free_pages_prepare
> >   2.90%  ksoftirqd/6  [mlx4_en]         [k] mlx4_call_bpf
> >   2.72%  ksoftirqd/6  [fjes]            [k] 0x000000000000af66
> >   2.37%  ksoftirqd/6  [kernel.vmlinux]  [k] swiotlb_sync_single_for_cpu
> >   1.92%  ksoftirqd/6  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
> >   1.83%  ksoftirqd/6  [kernel.vmlinux]  [k] free_one_page
> >   1.70%  ksoftirqd/6  [kernel.vmlinux]  [k] swiotlb_sync_single
> >   1.69%  ksoftirqd/6  [kernel.vmlinux]  [k] bpf_map_lookup_elem
> >   1.33%  swapper      [kernel.vmlinux]  [k] intel_idle
> >   1.32%  ksoftirqd/6  [fjes]            [k] 0x000000000000af90
> >   1.21%  ksoftirqd/6  [kernel.vmlinux]  [k] sk_load_byte_positive_offset
> >   1.07%  ksoftirqd/6  [kernel.vmlinux]  [k] __alloc_pages_nodemask
> >   0.89%  ksoftirqd/6  [kernel.vmlinux]  [k] __rmqueue
> >   0.84%  ksoftirqd/6  [mlx4_en]         [k] mlx4_alloc_pages.isra.23
> >   0.79%  ksoftirqd/6  [kernel.vmlinux]  [k] net_rx_action
> >
> >machine specs:
> >  receiver - Intel E5-1630 v3 @ 3.70GHz
> >  sender - Intel E5645 @ 2.40GHz
> >  Mellanox ConnectX-3 @40G
> >
> 
> 
> Ok, sorry - should have looked this far before sending earlier email.
> So when you run concurently you see about 5Mpps per core but if you
> shoot all traffic at a single core you see 20Mpps?
No, only sender is multiple, receiver is still single core. The flow is
the same in all 4 of the send threads. Note that only ksoftirqd/6 is
active.
> 
> Devil's advocate question:
> If the bottleneck is the driver - is there an advantage in adding the
> bpf code at all in the driver?
Only by adding this hook into the driver has it become the bottleneck.
Prior to this, the bottleneck was later in the codepath, primarily in
allocations.

If a packet is to be dropped, and a determination can be made with fewer
cpu cycles spent, then there is more time for the goodput.

Beyond that, even if the skb allocation gets 10x or 100x or whatever
improvement, there is still a non-zero cost associated, and dropping bad
packets with minimal time spent has value. The same argument holds for
physical nic forwarding decisions.

> I am curious than before to see the comparison for the same bpf code
> running at tc level vs in the driver..
Here is a perf report for drop in the clsact qdisc with direct-action,
which Daniel earlier showed to have the best performance to-date. On my
machine, this gets about 6.5Mpps drop single core. Drop due to failed
IP lookup (not shown here) is worse @4.5Mpps.

  9.24%  ksoftirqd/3  [mlx4_en]          [k] mlx4_en_process_rx_cq
  8.50%  ksoftirqd/3  [kernel.vmlinux]   [k] dev_gro_receive
  7.24%  ksoftirqd/3  [kernel.vmlinux]   [k] __netif_receive_skb_core
  5.47%  ksoftirqd/3  [mlx4_en]          [k] mlx4_en_complete_rx_desc
  4.74%  ksoftirqd/3  [kernel.vmlinux]   [k] kmem_cache_free
  3.94%  ksoftirqd/3  [mlx4_en]          [k] mlx4_en_alloc_frags
  3.42%  ksoftirqd/3  [kernel.vmlinux]   [k] napi_gro_frags
  3.34%  ksoftirqd/3  [kernel.vmlinux]   [k] inet_gro_receive
  3.32%  ksoftirqd/3  [kernel.vmlinux]   [k] __build_skb
  3.28%  ksoftirqd/3  [kernel.vmlinux]   [k] __napi_alloc_skb
  2.94%  ksoftirqd/3  [cls_bpf]          [k] cls_bpf_classify
  2.88%  ksoftirqd/3  [kernel.vmlinux]   [k] ktime_get_with_offset
  2.50%  ksoftirqd/3  [kernel.vmlinux]   [k] eth_type_trans
  2.40%  ksoftirqd/3  [kernel.vmlinux]   [k] kmem_cache_alloc
  2.29%  ksoftirqd/3  [kernel.vmlinux]   [k] skb_release_data
  2.25%  ksoftirqd/3  [kernel.vmlinux]   [k] gro_pull_from_frag0
  2.09%  ksoftirqd/3  [kernel.vmlinux]   [k] netif_receive_skb_internal
  1.99%  ksoftirqd/3  [kernel.vmlinux]   [k] memcpy_erms
  1.73%  ksoftirqd/3  [kernel.vmlinux]   [k] napi_get_frags
  1.66%  ksoftirqd/3  [kernel.vmlinux]   [k] __udp4_lib_lookup
  1.60%  ksoftirqd/3  [kernel.vmlinux]   [k] tc_classify
  1.25%  ksoftirqd/3  [kernel.vmlinux]   [k] kfree_skb
  1.24%  ksoftirqd/3  [kernel.vmlinux]   [k] get_page_from_freelist
  1.24%  ksoftirqd/3  [kernel.vmlinux]   [k] skb_gro_reset_offset
  1.16%  ksoftirqd/3  [kernel.vmlinux]   [k] udp4_gro_receive
  1.12%  ksoftirqd/3  [kernel.vmlinux]   [k] udp_gro_receive
  0.93%  ksoftirqd/3  [kernel.vmlinux]   [k] __free_page_frag
  0.91%  ksoftirqd/3  [kernel.vmlinux]   [k] skb_release_head_state
  0.89%  ksoftirqd/3  [kernel.vmlinux]   [k] __alloc_page_frag
  0.88%  ksoftirqd/3  [kernel.vmlinux]   [k] udp4_lib_lookup_skb
  0.83%  swapper      [kernel.vmlinux]   [k] intel_idle
  0.81%  ksoftirqd/3  [kernel.vmlinux]   [k] kfree_skbmem
  0.77%  ksoftirqd/3  [kernel.vmlinux]   [k] skb_release_all
  0.76%  ksoftirqd/3  [mlx4_en]          [k] mlx4_en_free_frag
  0.68%  ksoftirqd/3  [kernel.vmlinux]   [k] __netif_receive_skb
  0.64%  ksoftirqd/3  [kernel.vmlinux]   [k] free_pages_prepare
  0.53%  ksoftirqd/3  [kernel.vmlinux]   [k] read_tsc
  0.43%  ksoftirqd/3  [kernel.vmlinux]   [k] swiotlb_sync_single
  0.38%  ksoftirqd/3  [kernel.vmlinux]   [k] __memcpy
  0.37%  ksoftirqd/3  [kernel.vmlinux]   [k] bpf_map_lookup_elem
  0.35%  ksoftirqd/3  [kernel.vmlinux]   [k] __memcg_kmem_put_cache
  0.32%  ksoftirqd/3  [kernel.vmlinux]   [k] swiotlb_sync_single_for_cpu
  0.32%  ksoftirqd/3  [kernel.vmlinux]   [k] free_one_page
  0.25%  ksoftirqd/3  [kernel.vmlinux]   [k] __alloc_pages_nodemask
  0.23%  ksoftirqd/3  [kernel.vmlinux]   [k] net_rx_action
  0.22%  ksoftirqd/3  [kernel.vmlinux]   [k] __free_pages_ok
  0.21%  ksoftirqd/3  [mlx4_en]          [k] mlx4_alloc_pages.isra.23
  0.17%  ksoftirqd/3  [kernel.vmlinux]   [k] percpu_array_map_lookup_elem
  0.17%  ksoftirqd/3  [kernel.vmlinux]   [k] PageHuge
  0.15%  ksoftirqd/3  [wmi]              [k] 0x0000000000005d49
  0.15%  ksoftirqd/3  [kernel.vmlinux]   [k] __rmqueue
  0.13%  ksoftirqd/3  [wmi]              [k] 0x0000000000005d60

> 
> cheers,
> jamal
