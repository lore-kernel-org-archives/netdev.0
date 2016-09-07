From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC 04/11] net/mlx5e: Build RX SKB on demand
Date: Wed, 7 Sep 2016 10:34:51 -0700
Message-ID: <20160907173449.GB64688@ast-mbp.thefacebook.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: iovisor-dev <iovisor-dev@lists.iovisor.org>,
        netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34652 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753019AbcIGRe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 13:34:56 -0400
Received: by mail-pf0-f170.google.com with SMTP id p64so8778866pfb.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 10:34:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473252152-11379-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 03:42:25PM +0300, Saeed Mahameed wrote:
> For non-striding RQ configuration before this patch we had a ring
> with pre-allocated SKBs and mapped the SKB->data buffers for
> device.
> 
> For robustness and better RX data buffers management, we allocate a
> page per packet and build_skb around it.
> 
> This patch (which is a prerequisite for XDP) will actually reduce
> performance for normal stack usage, because we are now hitting a bottleneck
> in the page allocator. A later patch of page reuse mechanism will be
> needed to restore or even improve performance in comparison to the old
> RX scheme.
> 
> Packet rate performance testing was done with pktgen 64B packets on xmit
> side and TC drop action on RX side.
> 
> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
> 
> Comparison is done between:
>  1.Baseline, before 'net/mlx5e: Build RX SKB on demand'
>  2.Build SKB with RX page cache (This patch)
> 
> Streams    Baseline    Build SKB+page-cache    Improvement
> -----------------------------------------------------------
> 1          4.33Mpps      5.51Mpps                27%
> 2          7.35Mpps      11.5Mpps                52%
> 4          14.0Mpps      16.3Mpps                16%
> 8          22.2Mpps      29.6Mpps                20%
> 16         24.8Mpps      34.0Mpps                17%

Impressive gains for build_skb. I think it should help ip forwarding too
and likely tcp_rr. tcp_stream shouldn't see any difference.
If you can benchmark that along with pktgen+tc_drop it would
help to better understand the impact of the changes.
