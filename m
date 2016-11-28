From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 1/3] bpf: Refactor cgroups code in prep for
 new type
Date: Mon, 28 Nov 2016 12:06:43 -0800
Message-ID: <20161128200641.GA7634@ast-mbp.thefacebook.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
 <1480348130-31354-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35579 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754873AbcK1UGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:06:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so13992889pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 12:06:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480348130-31354-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 07:48:48AM -0800, David Ahern wrote:
> Code move only; no functional change intended.

not quite...

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
...
>   * @sk: The socken sending or receiving traffic
> @@ -153,11 +166,15 @@ int __cgroup_bpf_run_filter(struct sock *sk,
>  
>  	prog = rcu_dereference(cgrp->bpf.effective[type]);
>  	if (prog) {
> -		unsigned int offset = skb->data - skb_network_header(skb);
> -
> -		__skb_push(skb, offset);
> -		ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
> -		__skb_pull(skb, offset);
> +		switch (type) {
> +		case BPF_CGROUP_INET_INGRESS:
> +		case BPF_CGROUP_INET_EGRESS:
> +			ret = __cgroup_bpf_run_filter_skb(skb, prog);
> +			break;

hmm. what's a point of double jump table? It's only burning cycles
in the fast path. We already have
prog = rcu_dereference(cgrp->bpf.effective[type]); if (prog) {...}
Could you do a variant of __cgroup_bpf_run_filter() instead ?
That doesnt't take 'skb' as an argument.
It will also solve scary looking NULL skb from patch 2:
__cgroup_bpf_run_filter(sk, NULL, ...

and to avoid copy-pasting first dozen lines of current
__cgroup_bpf_run_filter can be moved into a helper that
__cgroup_bpf_run_filter_skb and
__cgroup_bpf_run_filter_sk will call.
Or some other way to rearrange that code.
