From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] net: filter: cleanup sk_* and bpf_* names
Date: Tue, 29 Jul 2014 08:55:04 -0700
Message-ID: <CAMEtUuwO0nGox4Mfj8Gs2fVudBpYtZ_NSwyFQCFz5NeYKgAdpA@mail.gmail.com>
References: <1406615380-3488-1-git-send-email-ast@plumgrid.com>
	<20140729153124.GA3231@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140729153124.GA3231@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 29, 2014 at 8:31 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Jul 28, 2014 at 11:29:40PM -0700, Alexei Starovoitov wrote:
>> Socket charging logic was complicated, since we had to charge/uncharge a socket
>> multiple times while preparing a filter. Simplify it by fully preparing bpf
>> program (through classic->ebpf conversion and JITing) and then charge
>> the socket memory once.
>
> This includes many changes in one single shot. This needs to be
> splitted in smaller patches that can be reviewed separately, that
> makes it easier to others to follow track and spot things.  On top of

That was the goal of v1 patch.. to deal with 'struct sk_filter' only...
Sure. I'll split it into multiple.

> that, we should also take the time to make sure what is already in
> place is correct, this is a good chance to go over the existing code,
> review it and make small changes to accomodate the generic
> infrastructure that should follow up.

I've simplified charging as commit log says. That part always felt
unclean. I'll split charging cleanup as separate patch.
Nothing else comes to mind. Pls suggest.

>> -struct sk_filter {
>> -     atomic_t                refcnt;
>> +struct bpf_prog {
>>       u32                     jited:1,        /* Is our filter JIT'ed? */
>>                               len:31;         /* Number of filter blocks */
>>       struct sock_fprog_kern  *orig_prog;     /* Original BPF program */
>> -     struct rcu_head         rcu;
>> +     struct rcu_head         rcu;            /* used by 'unattached' progs */
>
> This rcu_head for unattached filters can be avoided, I'll send a
> follow up patch for this. After that patch, refcnt and rcu_head can go
> out from bpf_prog.

See the hunk you quoted above. refcnt is already removed.
I see your prep patch for rcu_head removal...
I can rebase on top of it and drop rcu_head out of bpf_prog.

>> -#define sk_filter_proglen(fprog)                     \
>> -             (fprog->len * sizeof(fprog->filter[0]))
>> +struct sk_filter {
>> +     atomic_t refcnt;
>> +     struct rcu_head rcu;
>> +     u32 filter_size;
>> +     union {
>> +             struct bpf_prog *prog;
>> +     };
>> +     void (*release)(struct sk_filter *fp);
>> +     int (*get_filter)(struct sk_filter *fp, void **prog, unsigned int *len);
>> +     unsigned int (*run)(const struct sk_buff *skb, struct sk_filter *fp);
>
> I don't think this is the right moment to add this, but we have to
> keep in mind that something similar to this will need to be
> accomodated in struct sk_filter at some point to avoid sloppy changes
> that may result in reintroducing code later on.

I thought in v1 series you were arguing exactly about introducing them now...
ok, I will drop callbacks and keep refcnt,rcu,filter_size and bpf_prog pointer
in there. Sounds good?

> Next step should be to wrap the specific bpf fields in struct
> bpf_prog in some clean way IMO, which was partially the aim of this
> patch.

it seems your only objection is 'rcu_head' still being there and rebasing
on top of yours will fix it...
