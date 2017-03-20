From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: convert sk_filter.refcnt from atomic_t to refcount_t
Date: Mon, 20 Mar 2017 18:13:33 +0100
Message-ID: <58D00DBD.5080702@iogearbox.net>
References: <1490002641-10498-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, linux-kernel@vger.kernel.org, peterz@infradead.org,
        netdev@vger.kernel.org, Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        David Windsor <dwindsor@gmail.com>
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490002641-10498-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2017 10:37 AM, Elena Reshetova wrote:
[...]
> diff --git a/net/core/filter.c b/net/core/filter.c
> index ebaeaf2..389cb8d 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -928,7 +928,7 @@ static void sk_filter_release_rcu(struct rcu_head *rcu)
>    */
>   static void sk_filter_release(struct sk_filter *fp)
>   {
> -	if (atomic_dec_and_test(&fp->refcnt))
> +	if (refcount_dec_and_test(&fp->refcnt))
>   		call_rcu(&fp->rcu, sk_filter_release_rcu);
>   }
>
> @@ -943,20 +943,27 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
>   /* try to charge the socket memory if there is space available
>    * return true on success
>    */
> -bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
> +bool __sk_filter_charge(struct sock *sk, struct sk_filter *fp)

And this then becomes: static bool __sk_filter_charge(...)

>   {
>   	u32 filter_size = bpf_prog_size(fp->prog->len);
>
>   	/* same check as in sock_kmalloc() */
>   	if (filter_size <= sysctl_optmem_max &&
>   	    atomic_read(&sk->sk_omem_alloc) + filter_size < sysctl_optmem_max) {
> -		atomic_inc(&fp->refcnt);
>   		atomic_add(filter_size, &sk->sk_omem_alloc);
>   		return true;
>   	}
>   	return false;
>   }

Since here is just all in slow-path, looks fine to me if the above
is addressed as well in v3:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Please make sure you add [PATCH net-next] in your subject in future
so that it's clear which tree this goes to.

Thanks,
Daniel
