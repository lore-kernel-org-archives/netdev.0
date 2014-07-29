From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] net: filter: cleanup sk_* and bpf_* names
Date: Tue, 29 Jul 2014 10:25:25 -0700
Message-ID: <CAMEtUuxsFdmWM5DFXNRMnDKzqfgsaEashsMvDsKcjnF=T8pbpA@mail.gmail.com>
References: <1406615380-3488-1-git-send-email-ast@plumgrid.com>
	<20140729153124.GA3231@salvia>
	<CAMEtUuwO0nGox4Mfj8Gs2fVudBpYtZ_NSwyFQCFz5NeYKgAdpA@mail.gmail.com>
	<20140729164226.GA6069@salvia>
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
In-Reply-To: <20140729164226.GA6069@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 29, 2014 at 9:42 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Tue, Jul 29, 2014 at 08:55:04AM -0700, Alexei Starovoitov wrote:
>> > I don't think this is the right moment to add this, but we have to
>> > keep in mind that something similar to this will need to be
>> > accomodated in struct sk_filter at some point to avoid sloppy changes
>> > that may result in reintroducing code later on.
>>
>> I thought in v1 series you were arguing exactly about introducing them now...
>> ok, I will drop callbacks and keep refcnt,rcu,filter_size and bpf_prog pointer
>> in there. Sounds good?
>
> Agreed.
>
>> > Next step should be to wrap the specific bpf fields in struct
>> > bpf_prog in some clean way IMO, which was partially the aim of this
>> > patch.
>>
>> it seems your only objection is 'rcu_head' still being there and rebasing
>> on top of yours will fix it...
>
> Almost. I just wanted to leave in place struct sk_filter for the
> coming up generalization, that structure should contain the refcnt,
> rcu_head and the struct bpf_prog after some of your follow up patches.

Yes. something like:
struct sk_filter {
        atomic_t refcnt;
        struct rcu_head rcu;
        u32 filter_size;
        struct bpf_prog *prog;
};
filter_size also makes sense to add right now to cleanup charging.

> Please, also leave sk_filter_charge/uncharge/get_filter whatever will
> provide the room the generalization under net/core/filter.c, not need
> to move these to kernel/bpf/

of course, that was never the intent.
all socket related stuff should keep sk_* prefix and stay in net/
only net-independent things makes sense to move.

> After my patch (and your follow up), we don't have sloppy usage of
> rcu_head for unattached filter anymore and I guess Willem is going to
> same save bytes in his iptables/bpf rules given that he can directly
> use bpf_prog instead of sk_filter.

yes. exactly.

btw, Dave may request to do a fresh repost of both of your
patches with v2 tag... Alternatively I can do rebase + fix what we
discussed above + split and repost yours and mine as single
series, since they're addressing one area...
Also I want to do some more testing of your #2 patch for seccomp
to make sure all is clean.
