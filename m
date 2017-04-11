From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bpf: pass sk to helper functions
Date: Tue, 11 Apr 2017 09:51:04 -0700
Message-ID: <1491929464.10587.66.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170411162252.84985-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35243 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdDKQvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 12:51:07 -0400
Received: by mail-pf0-f194.google.com with SMTP id a188so450096pfa.2
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 09:51:07 -0700 (PDT)
In-Reply-To: <20170411162252.84985-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 12:22 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> BPF helper functions access socket fields through skb->sk. This is not
> set in ingress cgroup and socket filters. The association is only made
> in skb_set_owner_r once the filter has accepted the packet. Sk is
> available as socket lookup has taken place.
> 
> Temporarily set skb->sk to sk in these cases.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  kernel/bpf/cgroup.c | 4 +++-
>  net/core/filter.c   | 6 +++++-
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> index da0f53690295..a2c387e433a4 100644
> --- a/kernel/bpf/cgroup.c
> +++ b/kernel/bpf/cgroup.c
> @@ -154,7 +154,7 @@ int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
>  
>  /**
>   * __cgroup_bpf_run_filter_skb() - Run a program for packet filtering
> - * @sk: The socken sending or receiving traffic
> + * @sk: The socket sending or receiving traffic
>   * @skb: The skb that is being sent or received
>   * @type: The type of program to be exectuted
>   *
> @@ -190,9 +190,11 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
>  	if (prog) {
>  		unsigned int offset = skb->data - skb_network_header(skb);
>  

It would be nice to not touch sk. swap() is a bit overkill here I think.

	struct sock *save_sk = skb->sk;

	skb->sk = sk;


> +		swap(skb->sk, sk);
>  		__skb_push(skb, offset);
>  		ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
>  		__skb_pull(skb, offset);
> +		swap(skb->sk, sk);

	skb->sk = save_sk;

>  	}
>  
