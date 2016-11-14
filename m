From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 2/3] bpf, mlx5: fix various refcount/prog issues in
 mlx5e_xdp_set
Date: Sun, 13 Nov 2016 18:49:09 -0800
Message-ID: <20161114024908.GB94347@ast-mbp.thefacebook.com>
References: <cover.1479080215.git.daniel@iogearbox.net>
 <03741f7075af64e83d23add379bdab41204396b0.1479080215.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, bblanco@plumgrid.com, tariqt@mellanox.com,
        zhiyisun@gmail.com, ranas@mellanox.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36739 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935050AbcKNCtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 21:49:14 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so7678995pgx.3
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 18:49:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <03741f7075af64e83d23add379bdab41204396b0.1479080215.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 01:43:41AM +0100, Daniel Borkmann wrote:
> There are multiple issues in mlx5e_xdp_set():
> 
> 1) prog can be NULL, so calling unconditionally into bpf_prog_add(prog,
>    priv->params.num_channels) can end badly.
> 
> 2) The batched bpf_prog_add() should be done at an earlier point in
>    time. This makes sure that we cannot fail anymore at the time we
>    want to set the program for each channel. This only means that we
>    have to undo the bpf_prog_add() in case we return early due to
>    reset or device not in MLX5E_STATE_OPENED yet. Note, err is 0 here.
> 
> 3) When swapping the priv->xdp_prog, then no extra reference count must
>    be taken since we got that from call path via dev_change_xdp_fd()
>    already. Otherwise, we'd never be able to free the program. Also,
>    bpf_prog_add() without checking the return code could fail.
> 
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
...
> +static inline void bpf_prog_sub(struct bpf_prog *prog, int i)
> +{
> +}
> +
>  static inline void bpf_prog_put(struct bpf_prog *prog)
>  {
>  }
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 751e806..a0fca9f 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -682,6 +682,17 @@ struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
>  }
>  EXPORT_SYMBOL_GPL(bpf_prog_add);
>  
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

the patches look good. I'm only worried about net/net-next merge
conflict here. (I would have to deal with it as well).
So instead of copying the above helper can we apply net-next's
'bpf, mlx4: fix prog refcount in mlx4_en_try_alloc_resources error path'
patch to net without mlx4_xdp_set hunk and then apply
the rest of this patch?
Even better is to send this patch 2/3 to net-next?
yes, it's an issue, but very small one. There is no security
concern here, so I would prefer to avoid merge conflict.
Did you do a test merge of net/net-next by any chance?
May be I'm overreacting.
