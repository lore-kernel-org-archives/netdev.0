From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 4/4] bpf: Add tests and samples for LWT-BPF
Date: Wed, 30 Nov 2016 15:46:50 -0800
Message-ID: <20161130234636.GB37423@ast-mbp.thefacebook.com>
References: <cover.1480522144.git.tgraf@suug.ch>
 <81603830e3684a9a48d5c18687e47a9a0df6b1bf.1480522144.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36640 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933268AbcK3Xq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 18:46:57 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so2674776pgx.3
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 15:46:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <81603830e3684a9a48d5c18687e47a9a0df6b1bf.1480522144.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 05:10:11PM +0100, Thomas Graf wrote:
> Adds a series of tests to verify the functionality of attaching
> BPF programs at LWT hooks.
> 
> Also adds a sample which collects a histogram of packet sizes which
> pass through an LWT hook.
> 
> $ ./lwt_len_hist.sh
> Starting netserver with host 'IN(6)ADDR_ANY' port '12865' and family AF_UNSPEC
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.253.2 () port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    39857.69
>        1 -> 1        : 0        |                                      |
>        2 -> 3        : 0        |                                      |
>        4 -> 7        : 0        |                                      |
>        8 -> 15       : 0        |                                      |
>       16 -> 31       : 0        |                                      |
>       32 -> 63       : 22       |                                      |
>       64 -> 127      : 98       |                                      |
>      128 -> 255      : 213      |                                      |
>      256 -> 511      : 1444251  |********                              |
>      512 -> 1023     : 660610   |***                                   |
>     1024 -> 2047     : 535241   |**                                    |
>     2048 -> 4095     : 19       |                                      |
>     4096 -> 8191     : 180      |                                      |
>     8192 -> 16383    : 5578023  |************************************* |
>    16384 -> 32767    : 632099   |***                                   |
>    32768 -> 65535    : 6575     |                                      |
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  samples/bpf/Makefile            |   4 +
>  samples/bpf/bpf_helpers.h       |   4 +
>  samples/bpf/lwt_len_hist.sh     |  37 ++++
>  samples/bpf/lwt_len_hist_kern.c |  82 +++++++++
>  samples/bpf/lwt_len_hist_user.c |  76 ++++++++
>  samples/bpf/test_lwt_bpf.c      | 253 +++++++++++++++++++++++++
>  samples/bpf/test_lwt_bpf.sh     | 399 ++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 855 insertions(+)
>  create mode 100755 samples/bpf/lwt_len_hist.sh
>  create mode 100644 samples/bpf/lwt_len_hist_kern.c
>  create mode 100644 samples/bpf/lwt_len_hist_user.c
>  create mode 100644 samples/bpf/test_lwt_bpf.c
>  create mode 100755 samples/bpf/test_lwt_bpf.sh
...
> +static inline void __fill_garbage(struct __sk_buff *skb)
> +{
> +	uint64_t f = 0xFFFFFFFFFFFFFFFF;
> +
> +	bpf_skb_store_bytes(skb, 0, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 8, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 16, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 24, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 32, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 40, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 48, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 56, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 64, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 72, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 80, &f, sizeof(f), 0);
> +	bpf_skb_store_bytes(skb, 88, &f, sizeof(f), 0);
> +}
> +
> +SEC("fill_garbage")
> +int do_fill_garbage(struct __sk_buff *skb)
> +{
> +	__fill_garbage(skb);
> +	printk("Set initial 96 bytes of header to FF\n");
> +	return BPF_OK;
> +}
> +
> +SEC("fill_garbage_and_redirect")
> +int do_fill_garbage_and_redirect(struct __sk_buff *skb)
> +{
> +	int ifindex = DST_IFINDEX;
> +	__fill_garbage(skb);
> +	printk("redirected to %d\n", ifindex);
> +	return bpf_redirect(ifindex, 0);
> +}

Two 'garbage' tests! Pure garbage ;)

Acked-by: Alexei Starovoitov <ast@kernel.org>
