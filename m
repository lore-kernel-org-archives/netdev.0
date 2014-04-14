From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] seccomp: fix memory leak on filter attach
Date: Mon, 14 Apr 2014 10:35:50 -0700
Message-ID: <CAMEtUuyLLzcoiwLjpC=sOUMxDYL_2umLkuQQBa=8rk_JPC7FGA@mail.gmail.com>
References: <20140414171114.GA31384@www.outflux.net>
	<CAMEtUuzCBXROUE6Nf6B8+vmTaD2xOh5LjkmsVSGuwKo1gO-mNQ@mail.gmail.com>
	<CAGXu5jK6f2HHzLr9SOR3yzr8tCrDJatcT2csy+gRFpc-Lb46pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: James Morris <james.l.morris@oracle.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Masami Ichikawa <masami256@gmail.com>,
	Will Drewry <wad@chromium.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Paris <eparis@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jK6f2HHzLr9SOR3yzr8tCrDJatcT2csy+gRFpc-Lb46pQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2014 at 10:26 AM, Kees Cook <keescook@chromium.org> wrote:
> On Mon, Apr 14, 2014 at 10:17 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Mon, Apr 14, 2014 at 10:11 AM, Kees Cook <keescook@chromium.org> wrote:
>>> This sets the correct error code when final filter memory is unavailable,
>>> and frees the raw filter no matter what.
>>>
>>> unreferenced object 0xffff8800d6ea4000 (size 512):
>>>   comm "sshd", pid 278, jiffies 4294898315 (age 46.653s)
>>>   hex dump (first 32 bytes):
>>>     21 00 00 00 04 00 00 00 15 00 01 00 3e 00 00 c0  !...........>...
>>>     06 00 00 00 00 00 00 00 21 00 00 00 00 00 00 00  ........!.......
>>>   backtrace:
>>>     [<ffffffff8151414e>] kmemleak_alloc+0x4e/0xb0
>>>     [<ffffffff811a3a40>] __kmalloc+0x280/0x320
>>>     [<ffffffff8110842e>] prctl_set_seccomp+0x11e/0x3b0
>>>     [<ffffffff8107bb6b>] SyS_prctl+0x3bb/0x4a0
>>>     [<ffffffff8152ef2d>] system_call_fastpath+0x1a/0x1f
>>>     [<ffffffffffffffff>] 0xffffffffffffffff
>>>
>>> Reported-by: Masami Ichikawa <masami256@gmail.com>
>>> Signed-off-by: Kees Cook <keescook@chromium.org>
>>> Cc: stable@vger.kernel.org
>>
>> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>>
>>> ---
>>>  kernel/seccomp.c |    2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>>> index fd609bd9d6dd..2d7dcdfb7422 100644
>>> --- a/kernel/seccomp.c
>>> +++ b/kernel/seccomp.c
>>> @@ -256,6 +256,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
>>>                 goto free_prog;
>>>
>>>         /* Allocate a new seccomp_filter */
>>> +       ret = -ENOMEM;
>>>         filter = kzalloc(sizeof(struct seccomp_filter) +
>>>                          sizeof(struct sock_filter_int) * new_len,
>>>                          GFP_KERNEL|__GFP_NOWARN);
>>> @@ -265,6 +266,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
>>>         ret = sk_convert_filter(fp, fprog->len, filter->insnsi, &new_len);
>>>         if (ret)
>>>                 goto free_filter;
>>> +       kfree(fp);
>>>
>>>         atomic_set(&filter->usage, 1);
>>>         filter->len = new_len;
>>> --
>>> 1.7.9.5
>>>
>>>
>>> --
>>> Kees Cook
>>> Chrome OS Security
>
> James (or anyone), can you be sure to pull this soon? I'd like to get
> it into 3.14 stable ASAP. Under kernel memory pressure, it would be
> possible for the prctl to return 0 without having attached the seccomp
> filter.

I don't think it affects stable.
Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF
interpreter's instruction set")

> Thanks!
>
> -Kees
>
> --
> Kees Cook
> Chrome OS Security
