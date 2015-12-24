From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 3/4] soreuseport: setsockopt
 SO_ATTACH_REUSEPORT_[CE]BPF
Date: Thu, 24 Dec 2015 09:36:40 -0700
Message-ID: <20151224163639.GA90724@ast-mbp.thefacebook.com>
References: <1450814710-17850-1-git-send-email-kraigatgoog@gmail.com>
 <1450814710-17850-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34308 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933562AbbLXQgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 11:36:42 -0500
Received: by mail-pf0-f177.google.com with SMTP id e65so17852475pfe.1
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 08:36:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450814710-17850-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 03:05:09PM -0500, Craig Gallek wrote:
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

interesting stuff.

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

what is the typical case here skb_shared or not?

> +	/* temporarily advance data past protocol header */
> +	if (skb_headlen(skb) < hdr_len || !skb_pull_inline(skb, hdr_len)) {

though bpf core will read just fine past linear part of the packet,
here we're limiting this feature only to packets where udp header is
part of headlen. Will it make it somewhat unreliable?
May be we can avoid doing this pull/push and use negative load
instructions with SKF_NET_OFF ? Something like:
load_word(skb, SKF_NET_OFF + sizeof(struct udphdr)));

>  /**
>   *  reuseport_select_sock - Select a socket from an SO_REUSEPORT group.
>   *  @sk: First socket in the group.
> - *  @hash: Use this hash to select.
> + *  @hash: When no BPF filter is available, use this hash to select.
> + *  @skb: skb to run through BPF filter.
> + *  @hdr_len: BPF filter expects skb data pointer at payload data.  If
> + *    the skb does not yet point at the payload, this parameter represents
> + *    how far the pointer needs to advance to reach the payload.

what is the use case of this?
Do you expect programs to be stateful?

> +				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
...
> +				sk2 = reuseport_select_sock(sk, hash, skb,
> +							sizeof(struct udphdr));

these are the cases that comment is trying to explain?
Meaning the bpf program needs to understand well enough when udp stack
is calling it ?

Will do more careful review of bpf bits once I'm back from PTO.
