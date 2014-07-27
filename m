From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Sat, 26 Jul 2014 22:41:04 -0700
Message-ID: <CAMEtUux8F4xZ77_HQADfoeV-9sibaEWm=XJcAaY+cQyDWb2caA@mail.gmail.com>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
	<53D23EAF.4000001@redhat.com>
	<20140725115414.GA4770@salvia>
	<53D254D9.9030905@redhat.com>
	<CAMEtUux+dw_GoafXE3ukvmOK2JmZWWf-y0VMobe60TSTfZeNmw@mail.gmail.com>
	<20140725221512.GA3729@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140725221512.GA3729@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 3:17 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Jul 25, 2014 at 10:24:29AM -0700, Alexei Starovoitov wrote:
>> On Fri, Jul 25, 2014 at 6:00 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> > On 07/25/2014 01:54 PM, Pablo Neira Ayuso wrote:
>> >>
>> >> On Fri, Jul 25, 2014 at 01:25:35PM +0200, Daniel Borkmann wrote:
>> >>>
>> >>> [ also Cc'ing Willem, Pablo ]
>> >>>
>> >>> On 07/25/2014 10:04 AM, Alexei Starovoitov wrote:
>> >>>>
>> >>>> 'sk_filter' name is used as 'struct sk_filter', function sk_filter() and
>> >>>> as variable 'sk_filter', which makes code hard to read.
>> >>>> Also it's easily confused with 'struct sock_filter'
>> >>>> Rename 'struct sk_filter' to 'struct bpf_prog' to clarify semantics and
>> >>>> align the name with generic BPF use model.
>> >>>
>> >>>
>> >>> Agreed, as we went for kernel/bpf/, renaming makes absolutely sense.
>> >>
>> >>
>> >> My nft socket filtering changes are accomodated into struct sk_filter,
>> >> and will still be, so I still need some generic name there...
>> >
>> >
>> > All the parts from filter.c which is BPF's core engine have been moved
>> > into kernel/bpf/ to get it ready for tracing et al, since there is not
>> > always a socket context anymore. The *whole* infrastructure around struct
>> > sk_filter is [e]BPF and used in non-net related contexts as well, whereas
>> > nft socket filtering is *only* for sockets. Due to the socket-only specific
>> > use case why doesn't it make more sense to have a union in struct sock
>> > around sk_filter (or however we name it) and only allow one of the two
>> > being loaded on a socket?
>>
>> yep.
>> Adding nft specific things to struct sk_filter/bpf_prog is not correct,
>> since this struct is already part of seccomp and will be used
>> in net-less configurations. SK_RUN_FILTER() macro will also be
>> renamed into something like RUN_BPF_RPOG(). It's one and only
>> way to invoke eBPF programs. Adding nft selector cannot work,
>> since eBPF is used with generic context whereas nft is skb specific.
>> If you want to add nft filtering capabilities to sockets, you'd need
>> to add union around 'struct bpf_prog' inside 'struct sock', which will be
>> much cleaner way.
>
> The struct sk_filter is almost providing the generic framework, it
> just needs to be generalized, a quick layout for it:
>
> struct sk_filter {
>         struct sk_filter_cb     *cb;
>         atomic_t                refcnt;
>         struct rcu_head         head;
>         char                    data[0]; /* here, you specific struct bpf_prog */
> };
>
> The refcnt is required sk_filter_{charge,uncharge,release}. The struct
> rcu_head is also need from sk_filter_release().
>
> struct sk_filter_cb {
>         int type;
>         struct module *me;
>         void (*charge)(struct sock *sk, struct sk_filter *fp);
>         void (*uncharge)(struct sock *sk, struct sk_filter *fp);
>         unsigned int (*run_filter)(struct sk_filter *fp, struct sk_buff *skb);
> };

Pablo,

I don't think you understand the scope of BPF.
'struct module *'? to attach nft to sockets? ouch.
if you need to do it, go ahead, but please don't present such mess
as a 'generic' infra.
What you're proposing won't work even for classic bpf.
'struct sock *' and 'struct module *' are totally redundant and won't
work for seccomp, tracing and pretty much everything, but pure
socket filtering.
Somehow you think that 'struct sk_filter' is only used in sockets.
That is not the case. Just grep the git.
and arguing that 'struct sk_filter' needs to be generalized for nft
is shortsighted as minimum.
Every piece of code that is using 'struct sk_filter' knows that it's
dealing with bpf/ebpf, so renaming is not changing the facts,
but rather stating the obvious and making code easier to
understand.

> We have to provide the register/unregister functions for the specific
> callbacks depending on the socket filtering approach. But I'll have to
> introduce this myself when I come up with the nft patches again.

yes, please do introduce modules for nft only, since it doesn't
make sense for sockets and for bpf.

> So meanwhile, you should just encapsulate what really belongs to
> struct bpf_prog, ie. size, bytecode, jitted, etc. and leave struct
> sk_filter in place.
>
> struct sk_filter {
>         atomic_t                refcnt;
>         struct rcu_head         head;
>         u32                     len;
>         struct bpf_prog         bpf_prog;
> };
>
> The len will go into struct bpf_prog once the generic infrastructure
> above is introduced since the semantics (number of blocks) is
> different from nft.
>
> If you straight forward rename the entire structure, you'll take
> things that are not specific from bpf such as refcnt and rcu_head.

sorry Pablo, I don't think you understand what you're talking about.
refcnt and rcu_head are key parts of bpf/ebpf infra.
Programs are refcnt'ed not only by charging sockets. BPF is relying
on rcu for safe execution as well.
For example see my tracing filter patch that does:
void trace_filter_call_bpf(struct event_filter *filter, void *ctx)
{
        rcu_read_lock();
        SK_RUN_FILTER(filter->prog, ctx);
        rcu_read_unlock();
}
One eBPF program can be attached to multiple 'events' where event
is kprobe, tracepoint, syscall, etc The act of attaching increments
'struct sk_filter/bpf_prog -> refcnt'.
Every field of 'struct sk_filter' is used by BPF infra (including 'len'
and 'work') This struct is a definition of bpf program.
Seriously if you want to understand, just ask, but objecting due to
lack of understanding just silly.
