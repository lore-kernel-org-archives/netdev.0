From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v6 05/12] Add sample for adding simple drop program to link
Date: Sat, 9 Jul 2016 23:21:33 +0300
Message-ID: <CALzJLG8nSOvX-cH979MhGY1q+7+68aOv1rBoWZhKVD09xtL55w@mail.gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-6-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33459 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbcGIUVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 16:21:53 -0400
Received: by mail-yw0-f193.google.com with SMTP id i12so10657531ywa.0
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 13:21:53 -0700 (PDT)
In-Reply-To: <1467944124-14891-6-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 5:15 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
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

This just proves my point on the previous patch, reusing the rx_desc
buffers we are going to drop will save us here ~23% CPU wasted on
(alloc_frags & free_frags ) ! and this can improve some benchmarks
results where the CPU is the bottleneck.
