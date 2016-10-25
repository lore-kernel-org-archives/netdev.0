From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] bpf: Refactor cgroups code in prep for new
 type
Date: Wed, 26 Oct 2016 01:01:35 +0200
Message-ID: <580FE44F.2030403@iogearbox.net>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com> <1477434613-3169-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43026 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753107AbcJYXCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 19:02:24 -0400
In-Reply-To: <1477434613-3169-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2016 12:30 AM, David Ahern wrote:
> Code move only; no functional change intended.

Not quite, see below.

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   kernel/bpf/cgroup.c  | 27 ++++++++++++++++++++++-----
>   kernel/bpf/syscall.c | 28 +++++++++++++++-------------
>   2 files changed, 37 insertions(+), 18 deletions(-)
>
> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> index a0ab43f264b0..918c01a6f129 100644
> --- a/kernel/bpf/cgroup.c
> +++ b/kernel/bpf/cgroup.c
> @@ -117,6 +117,19 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
>   	}
>   }
>
> +static int __cgroup_bpf_run_filter_skb(struct sk_buff *skb,
> +				       struct bpf_prog *prog)
> +{
> +	unsigned int offset = skb->data - skb_network_header(skb);
> +	int ret;
> +
> +	__skb_push(skb, offset);
> +	ret = bpf_prog_run_clear_cb(prog, skb) == 1 ? 0 : -EPERM;

Original code save skb->cb[], this one clears it.

> +	__skb_pull(skb, offset);
> +
> +	return ret;
> +}
> +
>   /**
>    * __cgroup_bpf_run_filter() - Run a program for packet filtering
>    * @sk: The socken sending or receiving traffic
> @@ -153,11 +166,15 @@ int __cgroup_bpf_run_filter(struct sock *sk,
>
>   	prog = rcu_dereference(cgrp->bpf.effective[type]);
>   	if (prog) {
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
> +		/* make gcc happy else complains about missing enum value */
> +		default:
> +			return 0;
> +		}
>   	}
