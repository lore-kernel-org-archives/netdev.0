From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH perf/core REBASE 3/5] tools lib bpf: Add bpf_prog_{attach,detach}
Date: Tue, 20 Dec 2016 10:50:22 -0800
Message-ID: <CAPWQB7HyzaAck1LEX_ec7gRpoKjyaZPZ+dco3Ca=sR4qQ403BQ@mail.gmail.com>
References: <20161214224342.12858-1-joe@ovn.org> <20161214224342.12858-4-joe@ovn.org>
 <20161220141851.GB32756@kernel.org> <20161220143217.GC32756@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Wang Nan <wangnan0@huawei.com>,
        ast@fb.com, Daniel Borkmann <daniel@iogearbox.net>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:42426 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764815AbcLTSur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 13:50:47 -0500
In-Reply-To: <20161220143217.GC32756@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 December 2016 at 06:32, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> Em Tue, Dec 20, 2016 at 11:18:51AM -0300, Arnaldo Carvalho de Melo escreveu:
>> Em Wed, Dec 14, 2016 at 02:43:40PM -0800, Joe Stringer escreveu:
>> > Commit d8c5b17f2bc0 ("samples: bpf: add userspace example for attaching
>> > eBPF programs to cgroups") added these functions to samples/libbpf, but
>> > during this merge all of the samples libbpf functionality is shifting to
>> > tools/lib/bpf. Shift these functions there.
>> >
>> > Signed-off-by: Joe Stringer <joe@ovn.org>
>> > ---
>> > Arnaldo, this is a new patch you didn't previously review which I've
>> > prepared due to the conflict with net-next. I figured it's better to try
>> > to get samples/bpf properly switched over this window rather than defer the
>> > problem and end up having to deal with another merge problem next time
>> > around. I hope that is fine for you. If not, this patch onwards will need
>> > to be dropped
>> >
>> > It's a simple copy/paste/delete with a minor change for sys_bpf() vs
>> > syscall().
>> > ---
>> >  samples/bpf/libbpf.c | 21 ---------------------
>> >  samples/bpf/libbpf.h |  3 ---
>> >  tools/lib/bpf/bpf.c  | 21 +++++++++++++++++++++
>> >  tools/lib/bpf/bpf.h  |  3 +++
>> >  4 files changed, 24 insertions(+), 24 deletions(-)
>> >
>> > diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
>> > index 3391225ad7e9..d9af876b4a2c 100644
>> > --- a/samples/bpf/libbpf.c
>> > +++ b/samples/bpf/libbpf.c
>> > @@ -11,27 +11,6 @@
>> >  #include <arpa/inet.h>
>> >  #include "libbpf.h"
>> >
>> > -int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
>> > -{
>> > -   union bpf_attr attr = {
>> > -           .target_fd = target_fd,
>> > -           .attach_bpf_fd = prog_fd,
>> > -           .attach_type = type,
>> > -   };
>> > -
>> > -   return syscall(__NR_bpf, BPF_PROG_ATTACH, &attr, sizeof(attr));
>>
>> This one makes it fail for CentOS 5 and 6, others may fail as well,
>> still building, investigating...
>
> Ok, fixed it by making it follow the model of the other sys_bpf wrappers
> setting up that bpf_attr union wrt initializing unamed struct members:
>
>  int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
>  {
> -       union bpf_attr attr = {
> -               .target_fd = target_fd,
> -               .attach_bpf_fd = prog_fd,
> -               .attach_type = type,
> -       };
> +       union bpf_attr attr;
> +
> +       bzero(&attr, sizeof(attr));
> +       attr.target_fd     = target_fd;
> +       attr.attach_bpf_fd = prog_fd;
> +       attr.attach_type   = type;
>
>         return sys_bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
>  }

Ah, I just shifted these across originally so the delta would be
minimal but now I know why this code is like this. Thanks.
