From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/7] ebpf: check first for MAXINSNS in bpf_prog_load
Date: Tue, 10 Feb 2015 17:21:51 -0800
Message-ID: <CAMEtUuxatiqWCGeNmKEXHRFR=68L9=SnpYrnzQm-+WnRzGvtzg@mail.gmail.com>
References: <cover.1423610452.git.daniel@iogearbox.net> <a1a9810494aebf0c0be8660e996b84c1cdb06444.1423610452.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:60901 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbbBKBWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 20:22:12 -0500
Received: by mail-qc0-f171.google.com with SMTP id l6so541110qcy.2
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 17:22:12 -0800 (PST)
In-Reply-To: <a1a9810494aebf0c0be8660e996b84c1cdb06444.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Just minor ... before doing all the copying work, we may want
> to check for instruction count earlier. Also, we may want to
> warn the user in case we would otherwise need to truncate the
> license information.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/syscall.c | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 536edc2..73b105c 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -473,25 +473,26 @@ static int bpf_prog_load(union bpf_attr *attr)
>  {
>         enum bpf_prog_type type = attr->prog_type;
>         struct bpf_prog *prog;
> -       int err;
>         char license[128];
>         bool is_gpl;
> +       int err;
>
>         if (CHECK_ATTR(BPF_PROG_LOAD))
>                 return -EINVAL;
> +       if (attr->insn_cnt >= BPF_MAXINSNS)
> +               return -EINVAL;
>
>         /* copy eBPF program license from user space */
> -       if (strncpy_from_user(license, u64_to_ptr(attr->license),
> -                             sizeof(license) - 1) < 0)
> -               return -EFAULT;
> -       license[sizeof(license) - 1] = 0;
> +       err = strncpy_from_user(license, u64_to_ptr(attr->license),
> +                               sizeof(license));
> +       if (err == sizeof(license))
> +               err = -ERANGE;

I think this error is misleading.
In case of license we care whether it's gpl or not.
This boolean indicator we remember for the life of the program.
We don't keep the license.
So if user specified 'my_ultra_long_proprietery_license'
that should be fine. The program should still be accepted
and marked as non-gpl.

> +       if (err < 0)
> +               return err;
>
>         /* eBPF programs must be GPL compatible to use GPL-ed functions */
>         is_gpl = license_is_gpl_compatible(license);
>
> -       if (attr->insn_cnt >= BPF_MAXINSNS)
> -               return -EINVAL;

moving this check, I guess, is fine. No one should depend
on order of errors.
