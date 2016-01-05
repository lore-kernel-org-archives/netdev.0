From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Tue, 05 Jan 2016 10:38:32 +0100
Message-ID: <568B8F18.2050706@iogearbox.net>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com> <1451947308-7867-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Craig Gallek <kraigatgoog@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56844 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbcAEJif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 04:38:35 -0500
In-Reply-To: <1451947308-7867-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2016 11:41 PM, Craig Gallek wrote:
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
[...]
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
> +	if (!pskb_pull(skb, hdr_len)) {
> +		consume_skb(nskb);

Btw, this one could still be made kfree_skb() to indicate error condition here.

> +		return NULL;
> +	}
> +	index = bpf_prog_run_save_cb(prog, skb);
> +	__skb_push(skb, hdr_len);
> +
> +	consume_skb(nskb);
> +
> +	if (index >= socks)
> +		return NULL;
> +
> +	return reuse->socks[index];
> +}
