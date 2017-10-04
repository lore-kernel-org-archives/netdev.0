From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC] bpf: remove global verifier state
Date: Tue, 3 Oct 2017 19:52:29 -0700
Message-ID: <20171004025226.wutfwm6hcsj4zuph@ast-mbp>
References: <20171003201452.elth55atpquesjjk@ast-mbp.dhcp.thefacebook.com>
 <20171004002025.28521-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, dsahern@gmail.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, david.beckett@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38465 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdJDCwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 22:52:36 -0400
Received: by mail-pf0-f194.google.com with SMTP id a7so10988386pfj.5
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 19:52:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171004002025.28521-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 05:20:25PM -0700, Jakub Kicinski wrote:
> The only global state protected by the verifier lock is
> the verifier log.  Move that log to struct bpf_verifier_env
> and allow verification of multiple programs in parallel.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> Like this? :)
> 
> Compile-tested, I'm rebasing things and will test shortly.
> 
>  include/linux/bpf_verifier.h |   5 +
>  kernel/bpf/verifier.c        | 520 ++++++++++++++++++++++---------------------
>  2 files changed, 276 insertions(+), 249 deletions(-)
> 
> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
> index b8d200f60a40..598802dd1897 100644
> --- a/include/linux/bpf_verifier.h
> +++ b/include/linux/bpf_verifier.h
> @@ -139,6 +139,11 @@ struct bpf_verifier_env {
>  	bool allow_ptr_leaks;
>  	bool seen_direct_write;
>  	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
> +
> +	u32 log_level;
> +	u32 log_size;
> +	u32 log_len;
> +	char *log_buf;
>  };
>  
>  int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 4cf9b72c59a0..450f60e6229d 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -153,27 +153,21 @@ struct bpf_call_arg_meta {
>  	int access_size;
>  };
>  
> -/* verbose verifier prints what it's seeing
> - * bpf_check() is called under lock, so no race to access these global vars
> - */
> -static u32 log_level, log_size, log_len;
> -static char *log_buf;
> -
> -static DEFINE_MUTEX(bpf_verifier_lock);

yep. looks great.
Please test it and submit officially :)
The commit aafe6ae9cee3 ("bpf: dynamically allocate digest scratch buffer")
fixed the other case where we were relying on the above mutex.
The only other spot to be adjusted is to add spin_lock/mutex or DO_ONCE() to
bpf_get_skb_set_tunnel_proto() to protect md_dst init.
imo that would be it.
Daniel, anything else comes to mind?
