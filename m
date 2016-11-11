From: Jann Horn <jannh@google.com>
Subject: Re: [PATCH] bpf: fix range arithmetic for bpf map access
Date: Fri, 11 Nov 2016 17:36:13 +0100
Message-ID: <CAG48ez1c_s-S8dh=37Pj5XOCUbQ1C3SyJGWd7dXhEA2D2+ps9g@mail.gmail.com>
References: <CAG48ez0DyDoySPEkNqYnSEZpTXuuP2xheSuc_EQ+ZzmSwOGy6Q@mail.gmail.com>
 <1478823492-7335-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:34842 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbcKKQgg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 11:36:36 -0500
Received: by mail-it0-f44.google.com with SMTP id e187so336276710itc.0
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 08:36:36 -0800 (PST)
In-Reply-To: <1478823492-7335-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 1:18 AM, Josef Bacik <jbacik@fb.com> wrote:
> ---
> Sorry Jann, I saw your response last night and then promptly forgot about it,
> here's the git-send-email version.
> ---

A note: This doesn't seem to apply cleanly to current net-next (or I'm
too stupid to
use "git am"), so I'm applying it on f41cd11d64b2b21012eb4abffbe579bc0b90467f,
which is net-next from a few days ago.


> I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
> invalid accesses to bpf map entries.  Fix this up by doing a few things
>
> 1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
> life and just adds extra complexity.

Yay! As a security person, I am very much in favor of killing unused features.


> 2) Fix the logic for BPF_AND.  If the min value is negative then that is the new
> minimum, otherwise it is unconditionally 0.
>
> 3) Don't do operations on the ranges if they are set to the limits, as they are
> by definition undefined, and allowing arithmetic operations on those values
> could make them appear valid when they really aren't.
>
> This fixes the testcase provided by Jann as well as a few other theoretical
> problems.
>
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

A nit: check_mem_access() still has an explicit cast of reg->min_value to s64, I
think that's not necessary anymore?

>         case BPF_AND:
> -               /* & is special since it could end up with 0 bits set. */
> -               dst_reg->min_value &= min_val;
> +               /* & is special since it's could be any value within our range,
> +                * including 0.  But if the thing we're AND'ing against is
> +                * negative and we're negative then that's the minimum value,
> +                * otherwise the minimum will always be 0.
> +                */
> +               if (min_val < 0 && dst_reg->min_value < 0)
> +                       dst_reg->min_value = min_t(s64, dst_reg->min_value,
> +                                                  min_val);
> +               else
> +                       dst_reg->min_value = 0;
>                 dst_reg->max_value = max_val;

I'm not sure whether this is correct when dealing with signed numbers.
Let's say I have -2 and -3 (as u32: 0xfffffffe and 0xfffffffd) and AND them
together. The result is 0xfffffffc, or -4, right? So if I just compute
the AND of
constant numbers -2 and -3 (known to the verifier), the verifier would
compute minimum -3 while the actual value is -4, right?

If I am correct about this, I think it might make sense to just reset
the state to
unknown in the `min_val < 0 && dst_reg->min_value < 0` case. That shouldn't
occur in legitimate programs, right?
