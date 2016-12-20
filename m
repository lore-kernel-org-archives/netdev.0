From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 21:27:18 -0800
Message-ID: <CALCETrVxkdZA3SsRv0KKhBz9YvNMsnmHSjS8HN1GHrgWRYNM1g@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com> <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <80574175-3692-0278-a74e-23b752d44f73@gmail.com> <CALCETrVKu63BFVQFAJcLcd6ovPtq-WDdTh-BwyAPSprw8UarNQ@mail.gmail.com>
 <20161220044440.GB86803@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161220044440.GB86803-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 8:44 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, Dec 19, 2016 at 07:12:48PM -0800, Andy Lutomirski wrote:
>>
>> struct cgroup_bpf {
>>         /*
>>          * Store two sets of bpf_prog pointers, one for programs that are
>>          * pinned directly to this cgroup, and one for those that are effective
>>          * when this cgroup is accessed.
>>          */
>>         struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
>>         struct bpf_prog *effective[MAX_BPF_ATTACH_TYPE];
>> };
>>
>> in struct cgroup, there's a 'struct cgroup_bpf bpf;'.
>>
>> This would change to something like:
>>
>> struct cgroup_filter_slot {
>>   struct bpf_prog *effective;
>>   struct cgroup_filter_slot *next;
>>   struct bpf_prog *local;
>> }
>>
>> local is NULL unless *this* cgroup has a filter.  effective points to
>> the bpf_prog that's active in this cgroup or the nearest ancestor that
>> has a filter.  next is NULL if there are no filters higher in the
>> chain or points to the next slot that has a filter.  struct cgroup
>> has:
>>
>> struct cgroup_filter_slot filters[MAX_BPF_ATTACH_TYPE];
>>
>> To evaluate it, you do:
>>
>> struct cgroup_filter_slot *slot = &cgroup->slot[the index];
>>
>> if (!slot->effective)
>>   return;
>>
>> do {
>>   evaluate(slot->effective);
>>   slot = slot->next;
>> } while (unlikely(slot));
>
> yes. something like this can work as a future extension
> to support multiple programs for security use case.
> Please propose a patch.
> Again, it's not needed today and there is no rush to implement it.
>

If this happens after 4.10 and 4.10 is released as is, then this
change would be an ABI break.

--Andy
