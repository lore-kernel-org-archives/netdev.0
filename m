From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 5/5] Add sample for adding simple drop program to
 link
Date: Wed, 06 Apr 2016 22:03:22 +0200
Message-ID: <57056B8A.6010909@iogearbox.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>	<1459560118-5582-6-git-send-email-bblanco@plumgrid.com> <20160406214848.7568235b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, Or Gerlitz <ogerlitz@mellanox.com>,
	john.fastabend@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52045 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbcDFUD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:03:29 -0400
In-Reply-To: <20160406214848.7568235b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2016 09:48 PM, Jesper Dangaard Brouer wrote:
>
> I'm testing with this program and these patches, after getting past the
> challenge of compiling the samples/bpf files ;-)
>
> On Fri,  1 Apr 2016 18:21:58 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:
>
>> Add a sample program that only drops packets at the
>> BPF_PROG_TYPE_PHYS_DEV hook of a link. With the drop-only program,
>> observed single core rate is ~14.6Mpps.
>
> On my i7-4790K CPU @ 4.00GHz I'm seeing 9.7Mpps (single flow/cpu).
> (generator: pktgen_sample03_burst_single_flow.sh)
>
>   # ./netdrvx1 $(</sys/class/net/mlx4p1/ifindex)
>   sh: /sys/kernel/debug/tracing/kprobe_events: No such file or directory
>   Success: Loaded file ./netdrvx1_kern.o
>   proto 17:    9776320 drops/s
>
> These numbers are quite impressive. Compared to: sending it to local
> socket that drop packets 1.7Mpps. Compared to: dropping with iptables
> in "raw" table 3.7Mpps.
>
> If I do multiple flows, via ./pktgen_sample05_flow_per_thread.sh
> then I hit this strange 14.5Mpps limit (proto 17:   14505558 drops/s).
> And the RX 4x CPUs are starting to NOT use 100% in softirq, they have
> some cycles attributed to %idle. (I verified generator is sending at
> 24Mpps).
>
>> Other tests were run, for instance without the dropcnt increment or
>> without reading from the packet header, the packet rate was mostly
>> unchanged.
>
> If I change the program to not touch packet data (don't call
> load_byte()) then the performance increase to 14.6Mpps (single
> flow/cpu).  And the RX CPU is mostly idle... mlx4_en_process_rx_cq()
> and page alloc/free functions taking the time.
>
>> $ perf record -a samples/bpf/netdrvx1 $(</sys/class/net/eth0/ifindex)
>> proto 17:   14597724 drops/s
>>
>> ./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
>> Running... ctrl^C to stop
>> Device: eth4@0
>> Result: OK: 6486875(c6485849+d1026) usec, 23689465 (60byte,0frags)
>>    3651906pps 1752Mb/sec (1752914880bps) errors: 0
>> Device: eth4@1
>> Result: OK: 6486874(c6485656+d1217) usec, 23689489 (60byte,0frags)
>>    3651911pps 1752Mb/sec (1752917280bps) errors: 0
>> Device: eth4@2
>> Result: OK: 6486851(c6485730+d1120) usec, 23687853 (60byte,0frags)
>>    3651672pps 1752Mb/sec (1752802560bps) errors: 0
>> Device: eth4@3
>> Result: OK: 6486879(c6485807+d1071) usec, 23688954 (60byte,0frags)
>>    3651825pps 1752Mb/sec (1752876000bps) errors: 0
>>
>> perf report --no-children:
>>    18.36%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_process_rx_cq
>>    15.98%  swapper        [kernel.vmlinux]  [k] poll_idle
>>    12.71%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_alloc_frags
>>     6.87%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_free_frag
>>     4.20%  ksoftirqd/1    [kernel.vmlinux]  [k] get_page_from_freelist
>>     4.09%  swapper        [mlx4_en]         [k] mlx4_en_process_rx_cq
>>     3.32%  ksoftirqd/1    [kernel.vmlinux]  [k] sk_load_byte_positive_offset
>>     2.39%  ksoftirqd/1    [mdio]            [k] 0x00000000000074cd
>>     2.23%  swapper        [mlx4_en]         [k] mlx4_en_alloc_frags
>>     2.20%  ksoftirqd/1    [kernel.vmlinux]  [k] free_pages_prepare
>>     2.08%  ksoftirqd/1    [mlx4_en]         [k] mlx4_call_bpf
>>     1.57%  ksoftirqd/1    [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
>>     1.35%  ksoftirqd/1    [mdio]            [k] 0x00000000000074fa
>>     1.09%  ksoftirqd/1    [kernel.vmlinux]  [k] free_one_page
>>     1.02%  ksoftirqd/1    [kernel.vmlinux]  [k] bpf_map_lookup_elem
>>     0.90%  ksoftirqd/1    [kernel.vmlinux]  [k] __alloc_pages_nodemask
>>     0.88%  swapper        [kernel.vmlinux]  [k] intel_idle
>>     0.82%  ksoftirqd/1    [mdio]            [k] 0x00000000000074be
>>     0.80%  swapper        [mlx4_en]         [k] mlx4_en_free_frag
>
> My picture (single flow/cpu) looks a little bit different:
>
>   +   64.33%  ksoftirqd/7    [kernel.vmlinux]  [k] __bpf_prog_run

Looks like 'echo 1 > /proc/sys/net/core/bpf_jit_enable' is missing?

>   +    9.60%  ksoftirqd/7    [mlx4_en]         [k] mlx4_en_alloc_frags
>   +    7.71%  ksoftirqd/7    [mlx4_en]         [k] mlx4_en_process_rx_cq
>   +    5.47%  ksoftirqd/7    [mlx4_en]         [k] mlx4_en_free_frag
>   +    1.68%  ksoftirqd/7    [kernel.vmlinux]  [k] get_page_from_freelist
>   +    1.52%  ksoftirqd/7    [mlx4_en]         [k] mlx4_call_bpf
>   +    1.02%  ksoftirqd/7    [kernel.vmlinux]  [k] free_pages_prepare
>   +    0.72%  ksoftirqd/7    [mlx4_en]         [k] mlx4_alloc_pages.isra.20
>   +    0.70%  ksoftirqd/7    [kernel.vmlinux]  [k] __rcu_read_unlock
>   +    0.65%  ksoftirqd/7    [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
>
> On my i7-4790K CPU, I don't have DDIO, thus I assume this high cost in
> __bpf_prog_run is due to a cache-miss on the packet data.
>
>> machine specs:
>>   receiver - Intel E5-1630 v3 @ 3.70GHz
>>   sender - Intel E5645 @ 2.40GHz
>>   Mellanox ConnectX-3 @40G
>
