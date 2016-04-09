From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v2 5/5] Add sample for adding simple drop program to
 link
Date: Sat, 9 Apr 2016 10:48:05 -0400
Message-ID: <57091625.1010206@mojatatu.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, brouer@redhat.com, eric.dumazet@gmail.com,
	ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch,
	johannes@sipsolutions.net, eranlinuxmellanox@gmail.com,
	lorenzo@google.com
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36476 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbcDIOsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 10:48:09 -0400
Received: by mail-io0-f195.google.com with SMTP id s2so19978848iod.3
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 07:48:08 -0700 (PDT)
In-Reply-To: <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-08 12:48 AM, Brenden Blanco wrote:
> Add a sample program that only drops packets at the
> BPF_PROG_TYPE_PHYS_DEV hook of a link. With the drop-only program,
> observed single core rate is ~19.5Mpps.
>
> Other tests were run, for instance without the dropcnt increment or
> without reading from the packet header, the packet rate was mostly
> unchanged.
>
> $ perf record -a samples/bpf/netdrvx1 $(</sys/class/net/eth0/ifindex)
> proto 17:   19596362 drops/s
>
> ./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
> Running... ctrl^C to stop
> Device: eth4@0
> Result: OK: 7873817(c7872245+d1572) usec, 38801823 (60byte,0frags)
>    4927955pps 2365Mb/sec (2365418400bps) errors: 0
> Device: eth4@1
> Result: OK: 7873817(c7872123+d1693) usec, 38587342 (60byte,0frags)
>    4900715pps 2352Mb/sec (2352343200bps) errors: 0
> Device: eth4@2
> Result: OK: 7873817(c7870929+d2888) usec, 38718848 (60byte,0frags)
>    4917417pps 2360Mb/sec (2360360160bps) errors: 0
> Device: eth4@3
> Result: OK: 7873818(c7872193+d1625) usec, 38796346 (60byte,0frags)
>    4927259pps 2365Mb/sec (2365084320bps) errors: 0
>
> perf report --no-children:
>   29.48%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_process_rx_cq
>   18.17%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_alloc_frags
>    8.19%  ksoftirqd/6  [mlx4_en]         [k] mlx4_en_free_frag
>    5.35%  ksoftirqd/6  [kernel.vmlinux]  [k] get_page_from_freelist
>    2.92%  ksoftirqd/6  [kernel.vmlinux]  [k] free_pages_prepare
>    2.90%  ksoftirqd/6  [mlx4_en]         [k] mlx4_call_bpf
>    2.72%  ksoftirqd/6  [fjes]            [k] 0x000000000000af66
>    2.37%  ksoftirqd/6  [kernel.vmlinux]  [k] swiotlb_sync_single_for_cpu
>    1.92%  ksoftirqd/6  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
>    1.83%  ksoftirqd/6  [kernel.vmlinux]  [k] free_one_page
>    1.70%  ksoftirqd/6  [kernel.vmlinux]  [k] swiotlb_sync_single
>    1.69%  ksoftirqd/6  [kernel.vmlinux]  [k] bpf_map_lookup_elem
>    1.33%  swapper      [kernel.vmlinux]  [k] intel_idle
>    1.32%  ksoftirqd/6  [fjes]            [k] 0x000000000000af90
>    1.21%  ksoftirqd/6  [kernel.vmlinux]  [k] sk_load_byte_positive_offset
>    1.07%  ksoftirqd/6  [kernel.vmlinux]  [k] __alloc_pages_nodemask
>    0.89%  ksoftirqd/6  [kernel.vmlinux]  [k] __rmqueue
>    0.84%  ksoftirqd/6  [mlx4_en]         [k] mlx4_alloc_pages.isra.23
>    0.79%  ksoftirqd/6  [kernel.vmlinux]  [k] net_rx_action
>
> machine specs:
>   receiver - Intel E5-1630 v3 @ 3.70GHz
>   sender - Intel E5645 @ 2.40GHz
>   Mellanox ConnectX-3 @40G
>


Ok, sorry - should have looked this far before sending earlier email.
So when you run concurently you see about 5Mpps per core but if you
shoot all traffic at a single core you see 20Mpps?

Devil's advocate question:
If the bottleneck is the driver - is there an advantage in adding the
bpf code at all in the driver?
I am curious than before to see the comparison for the same bpf code
running at tc level vs in the driver..

cheers,
jamal
