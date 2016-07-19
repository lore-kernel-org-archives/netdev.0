From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v10 06/12] Add sample for adding simple drop program to
 link
Date: Tue, 19 Jul 2016 14:44:18 -0700
Message-ID: <20160719214417.GC64618@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-7-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35438 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbcGSVoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 17:44:23 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so1978815pad.2
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 14:44:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468955817-10604-7-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 12:16:51PM -0700, Brenden Blanco wrote:
> Add a sample program that only drops packets at the BPF_PROG_TYPE_XDP_RX
> hook of a link. With the drop-only program, observed single core rate is
> ~20Mpps.
> 
> Other tests were run, for instance without the dropcnt increment or
> without reading from the packet header, the packet rate was mostly
> unchanged.
> 
> $ perf record -a samples/bpf/xdp1 $(</sys/class/net/eth0/ifindex)
> proto 17:   20403027 drops/s
> 
> ./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
> Running... ctrl^C to stop
> Device: eth4@0
> Result: OK: 11791017(c11788327+d2689) usec, 59622913 (60byte,0frags)
>   5056638pps 2427Mb/sec (2427186240bps) errors: 0
> Device: eth4@1
> Result: OK: 11791012(c11787906+d3106) usec, 60526944 (60byte,0frags)
>   5133311pps 2463Mb/sec (2463989280bps) errors: 0
> Device: eth4@2
> Result: OK: 11791019(c11788249+d2769) usec, 59868091 (60byte,0frags)
>   5077431pps 2437Mb/sec (2437166880bps) errors: 0
> Device: eth4@3
> Result: OK: 11795039(c11792403+d2636) usec, 59483181 (60byte,0frags)
>   5043067pps 2420Mb/sec (2420672160bps) errors: 0
> 
> perf report --no-children:
>  26.05%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_process_rx_cq
>  17.84%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_alloc_frags
>   5.52%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_free_frag
>   4.90%  swapper      [kernel.vmlinux]  [k] poll_idle
>   4.14%  ksoftirqd/0  [kernel.vmlinux]  [k] get_page_from_freelist
>   2.78%  ksoftirqd/0  [kernel.vmlinux]  [k] __free_pages_ok
>   2.57%  ksoftirqd/0  [kernel.vmlinux]  [k] bpf_map_lookup_elem
>   2.51%  swapper      [mlx4_en]         [k] mlx4_en_process_rx_cq
>   1.94%  ksoftirqd/0  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
>   1.45%  swapper      [mlx4_en]         [k] mlx4_en_alloc_frags
>   1.35%  ksoftirqd/0  [kernel.vmlinux]  [k] free_one_page
>   1.33%  swapper      [kernel.vmlinux]  [k] intel_idle
>   1.04%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c5c5
>   0.96%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c58d
>   0.93%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c6ee
>   0.92%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c6b9
>   0.89%  ksoftirqd/0  [kernel.vmlinux]  [k] __alloc_pages_nodemask
>   0.83%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c686
>   0.83%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c5d5
>   0.78%  ksoftirqd/0  [mlx4_en]         [k] mlx4_alloc_pages.isra.23
>   0.77%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001c5b4
>   0.77%  ksoftirqd/0  [kernel.vmlinux]  [k] net_rx_action
> 
> machine specs:
>  receiver - Intel E5-1630 v3 @ 3.70GHz
>  sender - Intel E5645 @ 2.40GHz
>  Mellanox ConnectX-3 @40G
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
...
> +int main(int ac, char **argv)
> +{
> +	char filename[256];
> +
> +	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
> +
> +	if (ac != 2) {
> +		printf("usage: %s IFINDEX\n", argv[0]);
> +		return 1;
> +	}
> +
> +	ifindex = strtoul(argv[1], NULL, 0);

great test. some future extension could be to use dev name instead of id.

Acked-by: Alexei Starovoitov <ast@kernel.org>
