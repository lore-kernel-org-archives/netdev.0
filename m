From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] soreuseport: setsockopt
 SO_ATTACH_REUSEPORT_[CE]BPF
Date: Tue, 29 Dec 2015 15:50:58 -0800
Message-ID: <20151229235057.GA5396@ast-mbp.thefacebook.com>
References: <1451410150-15466-1-git-send-email-kraigatgoog@gmail.com>
 <1451410150-15466-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35803 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbL2XvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 18:51:01 -0500
Received: by mail-pa0-f52.google.com with SMTP id do7so3481737pab.2
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 15:51:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1451410150-15466-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 12:29:09PM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Expose socket options for setting a classic or extended BPF program
> for use when selecting sockets in an SO_REUSEPORT group.  These options
> can be used on the first socket to belong to a group before bind or
> on any socket in the group after bind.
> 
> This change includes refactoring of the existing sk_filter code to
> allow reuse of the existing BPF filter validation checks.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
...
> @@ -75,6 +79,10 @@ static struct sock_reuseport *reuseport_grow(struct sock_reuseport *reuse)
>  		rcu_assign_pointer(reuse->socks[i]->sk_reuseport_cb,
>  				   more_reuse);
>  
> +	/* Note: we use kfree_rcu here instead of reuseport_free_rcu so
> +	 * that reuse and more_reuse can temporarily share a reference
> +	 * to prog.
> +	 */
>  	kfree_rcu(reuse, rcu);
>  	return more_reuse;

thanks for the comment. that bit definitely is tricky, but looks fine.

> +static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
> +			    struct bpf_prog *prog, struct sk_buff *skb,
> +			    int hdr_len)
> +{
> +	struct sk_buff *nskb = NULL;
> +	u32 index;
> +
> +	if (skb_shared(skb)) {
> +		nskb = skb_clone(skb, GFP_ATOMIC);
> +		if (!nskb)
> +			return NULL;
> +		skb = nskb;
> +	}
> +
> +	/* temporarily advance data past protocol header */
> +	if (!pskb_may_pull(skb, hdr_len) || !skb_pull_inline(skb, hdr_len)) {

pskb_pull() would be cleaner.

> +		consume_skb(nskb);
> +		return NULL;
> +	}
> +	index = bpf_prog_run_save_cb(prog, skb);
> +	__skb_push(skb, hdr_len);

This indeed matches what normal bpf filters see with udp sockets, so
I guess that's fine.
Acked-by: Alexei Starovoitov <ast@kernel.org>
