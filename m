From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 5/5] bpf: write back the verifier log buffer
 as it gets filled
Date: Thu, 05 Oct 2017 23:10:03 +0200
Message-ID: <59D69FAB.1020605@iogearbox.net>
References: <20171005153422.8947-1-jakub.kicinski@netronome.com> <20171005153422.8947-6-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52338 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751486AbdJEVKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 17:10:05 -0400
In-Reply-To: <20171005153422.8947-6-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2017 05:34 PM, Jakub Kicinski wrote:
> Verifier log buffer can be quite large (up to 16MB currently).
> As Eric Dumazet points out if we allow multiple verification
> requests to proceed simultaneously, malicious user may use the
> verifier as a way of allocating large amounts of unswappable
> memory to OOM the host.
>
> Switch to a strategy of allocating a smaller buffer (a page)
> and writing it out into the user buffer whenever it fills up.
> To simplify the code assume that prints will never be longer
> than 1024 bytes.
>
> This is in preparation of the global verifier lock removal.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Set looks good in general, thanks for working on this! Just two
comments further below.

> ---
>   include/linux/bpf_verifier.h |  7 +++--
>   kernel/bpf/verifier.c        | 64 +++++++++++++++++++++++++++++++-------------
>   2 files changed, 50 insertions(+), 21 deletions(-)
>
> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
> index 598802dd1897..c0f0e210c3f8 100644
> --- a/include/linux/bpf_verifier.h
> +++ b/include/linux/bpf_verifier.h
> @@ -140,10 +140,13 @@ struct bpf_verifier_env {
>   	bool seen_direct_write;
>   	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
>
> -	u32 log_level;
> +	char __user *log_ubuf;
> +	u32 log_usize;
> +	u32 log_ulen;
> +	char *log_buf;
>   	u32 log_size;
>   	u32 log_len;
> -	char *log_buf;
> +	u32 log_level;

Small request: given we'd now have log_{level,ubuf,usize,ulen,buf,size,len}
in struct bpf_verifier_env, could we abstract that a bit e.g. into something
like struct bpf_verifier_log, which has level and kbuf and ubuf as members
of which {k,u}buf would be something like struct bpf_verifier_buf with three
members (mem or buf, len_total, len_used) or such. I think most of patch 1
is on passing env into verbose, so likely wouldn't be too much change required
for this, but would be nice to make that a bit more structured if we need to
touch it anyway.

>   };
>
[...]
>
>   		ret = -ENOMEM;
> -		env->log_buf = vmalloc(env->log_size);
> +		env->log_buf = page_address(alloc_page(GFP_USER));

alloc_page() can return NULL, if I spot this correctly, then page_address()
cannot handle NULL and would try to deref it, no? Am I missing something?

>   		if (!env->log_buf)
>   			goto err_unlock;
> +		env->log_size = PAGE_SIZE;
>   	}
[...]

Thanks,
Daniel
