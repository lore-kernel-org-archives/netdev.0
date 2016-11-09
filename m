From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf, mlx4: fix prog refcount in
 mlx4_en_try_alloc_resources error path
Date: Wed, 9 Nov 2016 13:53:48 -0800
Message-ID: <20161109215346.GA54489@ast-mbp.thefacebook.com>
References: <9d5b1ed1b70a8a4db545c308bcb5b28280564798.1478724690.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, bblanco@plumgrid.com, tariqt@mellanox.com,
        zhiyisun@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35646 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753832AbcKIVxy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 16:53:54 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so1555696pfk.2
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 13:53:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <9d5b1ed1b70a8a4db545c308bcb5b28280564798.1478724690.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2016 at 10:02:34PM +0100, Daniel Borkmann wrote:
> Commit 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings
> scheme") added a bug in that the prog's reference count is not dropped
> in the error path when mlx4_en_try_alloc_resources() is failing from
> mlx4_xdp_set().
> 
> We previously took bpf_prog_add(prog, priv->rx_ring_num - 1), that we
> need to release again. Earlier in the call path, dev_change_xdp_fd()
> itself holds a reference to the prog as well (hence the '- 1' in the
> bpf_prog_add()), so a simple atomic_sub() is safe to use here. When
> an error is propagated, then bpf_prog_put() is called eventually from
> dev_change_xdp_fd()
> 
> Fixes: 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Good catch. Thanks for the quick fix.

> +void bpf_prog_sub(struct bpf_prog *prog, int i)
> +{
> +	/* Only to be used for undoing previous bpf_prog_add() in some
> +	 * error path. We still know that another entity in our call
> +	 * path holds a reference to the program, thus atomic_sub() can
> +	 * be safely used in such cases!
> +	 */
> +	WARN_ON(atomic_sub_return(i, &prog->aux->refcnt) == 0);
> +}
> +EXPORT_SYMBOL_GPL(bpf_prog_sub);

to elaborate on this little bit further...
if we did it as an extension to bpf_prog_put(), like
  if (atomic_sub_return(i, &prog->aux->refcnt) == 0)
    call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
it could be seen a 'safe' version and people would be tempted
to use without thinking,
but since right now bpf_prog_add() can be done only after bpf_prog_get(),
this bpf_prog_sub() matches bpf_prog_add() to clean up refcnt
in the error path, so having separate helper like this makes sense,
instead of overloading bpf_prog_sub into 'safe' bpf_prog_put variant.
So all looks correct to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
