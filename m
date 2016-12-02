From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] bpf, xdp: drop rcu_read_lock from
 bpf_prog_run_xdp and move to caller
Date: Fri, 02 Dec 2016 11:09:31 -0500 (EST)
Message-ID: <20161202.110931.1187796431289743394.davem@redhat.com>
References: <b70c47e0284823e6a5db600ae75c01eac4cf7922.1480538565.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, saeedm@mellanox.com, kubakici@wp.pl,
        Yuval.Mintz@cavium.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55998 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750888AbcLBQJe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 11:09:34 -0500
In-Reply-To: <b70c47e0284823e6a5db600ae75c01eac4cf7922.1480538565.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 30 Nov 2016 22:16:06 +0100

> After 326fe02d1ed6 ("net/mlx4_en: protect ring->xdp_prog with rcu_read_lock"),
> the rcu_read_lock() in bpf_prog_run_xdp() is superfluous, since callers
> need to hold rcu_read_lock() already to make sure BPF program doesn't
> get released in the background.
> 
> Thus, drop it from bpf_prog_run_xdp(), as it can otherwise be misleading.
> Still keeping the bpf_prog_run_xdp() is useful as it allows for grepping
> in XDP supported drivers and to keep the typecheck on the context intact.
> For mlx4, this means we don't have a double rcu_read_lock() anymore. nfp can
> just make use of bpf_prog_run_xdp(), too. For qede, just move rcu_read_lock()
> out of the helper. When the driver gets atomic replace support, this will
> move to call-sites eventually.
> 
> mlx5 needs actual fixing as it has the same issue as described already in
> 326fe02d1ed6 ("net/mlx4_en: protect ring->xdp_prog with rcu_read_lock"),
> that is, we're under RCU bh at this time, BPF programs are released via
> call_rcu(), and call_rcu() != call_rcu_bh(), so we need to properly mark
> read side as programs can get xchg()'ed in mlx5e_xdp_set() without queue
> reset.
> 
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  ( Also here net-next is just fine, imho. )

Applied, thanks.
