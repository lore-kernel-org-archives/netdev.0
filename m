From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 4/6] kcm: Kernel Connection Multiplexor module
Date: Fri, 20 Nov 2015 15:10:54 -0800
Message-ID: <20151120231053.GA46238@ast-mbp.thefacebook.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448054520-1464587-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	davewatson@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32868 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbbKTXK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 18:10:57 -0500
Received: by pabfh17 with SMTP id fh17so133621985pab.0
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 15:10:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448054520-1464587-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 01:21:58PM -0800, Tom Herbert wrote:
> +
> +	while (eaten < orig_len) {
> +		/* Always clone since we will consume something */
> +		skb = skb_clone(orig_skb, GFP_ATOMIC);
> +		if (!skb) {
> +			desc->error = -ENOMEM;
> +			break;
> +		}
...
> +		if (!pskb_pull(skb, offset + eaten)) {

pskb_pull after clone == pskb_expand_head
meaning that we'll be linearizing things all the time.
can we try skb_share_check() first ?
the packet shouldn't be shared at this point, so it might save a lot.

> +			kfree_skb(skb);
> +			desc->error = -ENOMEM;
> +			break;
> +		}
...
> +		/* Need to trim, should be rare? */
> +		err = pskb_trim(skb, orig_len - eaten);
...
> +		if (!rxm->full_len) {
> +			ssize_t len;
> +
> +			len = KCM_RUN_FILTER(psock->bpf_prog, head);

bpf can read packet beyond linear header just fine.
It's slower than reads from header, since extra calls invovled,
but if that becomes a bottle neck we can optimize the way we do JIT there.
