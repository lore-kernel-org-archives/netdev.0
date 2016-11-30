From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next] bpf, xdp: drop rcu_read_lock from
 bpf_prog_run_xdp and move to caller
Date: Wed, 30 Nov 2016 22:50:07 +0000
Message-ID: <20161130225007.18c63f95@jkicinski-Precision-T1700>
References: <b70c47e0284823e6a5db600ae75c01eac4cf7922.1480538565.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        saeedm@mellanox.com, Yuval.Mintz@cavium.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:24761 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751673AbcK3WuN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 17:50:13 -0500
In-Reply-To: <b70c47e0284823e6a5db600ae75c01eac4cf7922.1480538565.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2016 22:16:06 +0100, Daniel Borkmann wrote:
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

FWIW:

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks!
