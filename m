From: Jann Horn <jannh@google.com>
Subject: Re: [PATCH net 2/3] bpf: fix check_map_func_compatibility logic
Date: Thu, 28 Apr 2016 11:31:31 +0200
Message-ID: <CAG48ez2auDRZxN5o0q+x0RTG0bKhZWOuGee9f-80Rd8bKpCEVw@mail.gmail.com>
References: <1461808582-1452466-1-git-send-email-ast@fb.com> <1461808582-1452466-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38388 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbcD1Jbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 05:31:52 -0400
Received: by mail-ig0-f180.google.com with SMTP id m9so61811457ige.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 02:31:52 -0700 (PDT)
In-Reply-To: <1461808582-1452466-3-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 3:56 AM, Alexei Starovoitov <ast@fb.com> wrote:
> The commit 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
> introduced clever way to check bpf_helper<->map_type compatibility.
> Later on commit a43eec304259 ("bpf: introduce bpf_perf_event_output() helper") adjusted
> the logic and inadvertently broke it.
> Get rid of the clever bool compare and go back to two-way check
> from map and from helper perspective.
>
> Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/verifier.c | 65 +++++++++++++++++++++++++++++++--------------------
>  1 file changed, 40 insertions(+), 25 deletions(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 89bcaa0966da..c5c17a62f509 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
[...]
> +       case BPF_MAP_TYPE_PROG_ARRAY:
> +               if (func_id != BPF_FUNC_tail_call)
> +                       goto error;
> +               break;
> +       case BPF_MAP_TYPE_PERF_EVENT_ARRAY:
> +               if (func_id != BPF_FUNC_perf_event_read &&
> +                   func_id != BPF_FUNC_perf_event_output)
> +                       goto error;
> +               break;
> +       case BPF_MAP_TYPE_STACK_TRACE:
> +               if (func_id != BPF_FUNC_get_stackid)
> +                       goto error;
> +               break;
> +       default:
> +               break;
> +       }
> +
> +       /* ... and second from the function itself. */
> +       switch (func_id) {
> +       case BPF_FUNC_tail_call:
> +               if (map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
> +                       goto error;
> +               break;
> +       case BPF_FUNC_perf_event_read:
> +       case BPF_FUNC_perf_event_output:
> +               if (map->map_type != BPF_MAP_TYPE_PERF_EVENT_ARRAY)
> +                       goto error;
> +               break;
> +       case BPF_FUNC_get_stackid:
> +               if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
> +                       goto error;
> +               break;
> +       default:
> +               break;
>         }

Looks good to me.
