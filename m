From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 6/7] ebpf: remove CONFIG_BPF_SYSCALL ifdefs in
 socket filter code
Date: Tue, 10 Feb 2015 17:51:14 -0800
Message-ID: <CAMEtUuzruMSO7zwhYLfVdO0=YN_dJ+pLAoEg_pCVT8FT=DRz_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:49158 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbbBKBvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 20:51:36 -0500
Received: by mail-qa0-f51.google.com with SMTP id i13so525271qae.10
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 17:51:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Socket filter code and other subsystems with upcoming eBPF support
> should not need to deal with the fact that we have CONFIG_BPF_SYSCALL
> defined or not. Having the bpf syscall as a config option is a nice
> thing and I'd expect it to stay that way for expert users (I presume
> one day the default setting of it might change, though), but code
> making use of it should not care if it's actually enabled or not.
> Instead, hide this via header files and let the rest deal with it.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  include/linux/bpf.h |  27 +++++++--
>  net/core/filter.c   | 166 ++++++++++++++++++++++++----------------------------
>  2 files changed, 100 insertions(+), 93 deletions(-)
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 4fe1bd3..def0103 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -114,9 +114,6 @@ struct bpf_prog_type_list {
>         enum bpf_prog_type type;
>  };
>
> -int bpf_register_prog_type(struct bpf_prog_type_list *tl);
> -void bpf_unregister_prog_type(struct bpf_prog_type_list *tl);
> -
>  struct bpf_prog;
>
>  struct bpf_prog_aux {
> @@ -130,11 +127,31 @@ struct bpf_prog_aux {
>  };
>
>  #ifdef CONFIG_BPF_SYSCALL
> +int bpf_register_prog_type(struct bpf_prog_type_list *tl);
> +void bpf_unregister_prog_type(struct bpf_prog_type_list *tl);
> +
>  void bpf_prog_put(struct bpf_prog *prog);
> +struct bpf_prog *bpf_prog_get(u32 ufd);
>  #else
> -static inline void bpf_prog_put(struct bpf_prog *prog) {}
> +static inline int bpf_register_prog_type(struct bpf_prog_type_list *tl)
> +{
> +       return 0;
> +}
> +
> +static inline void bpf_unregister_prog_type(struct bpf_prog_type_list *tl)
> +{
> +}
> +
> +static inline struct bpf_prog *bpf_prog_get(u32 ufd)
> +{
> +       return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static inline void bpf_prog_put(struct bpf_prog *prog)
> +{
> +}
>  #endif
> -struct bpf_prog *bpf_prog_get(u32 ufd);

makes sense. I have similar change for bpf+tracing.

> -#ifdef CONFIG_BPF_SYSCALL
> -int sk_attach_bpf(u32 ufd, struct sock *sk)
> -{
> -       struct sk_filter *fp, *old_fp;
> -       struct bpf_prog *prog;

why move the functions inside filter.c ?
couldn't we just remove two lines with #ifdef/endif ?
