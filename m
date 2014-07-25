From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Sat, 26 Jul 2014 00:17:16 +0200
Message-ID: <20140725221512.GA3729@salvia>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
 <53D23EAF.4000001@redhat.com>
 <20140725115414.GA4770@salvia>
 <53D254D9.9030905@redhat.com>
 <CAMEtUux+dw_GoafXE3ukvmOK2JmZWWf-y0VMobe60TSTfZeNmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, willemb@google.com,
	netfilter-devel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUux+dw_GoafXE3ukvmOK2JmZWWf-y0VMobe60TSTfZeNmw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 10:24:29AM -0700, Alexei Starovoitov wrote:
> On Fri, Jul 25, 2014 at 6:00 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> > On 07/25/2014 01:54 PM, Pablo Neira Ayuso wrote:
> >>
> >> On Fri, Jul 25, 2014 at 01:25:35PM +0200, Daniel Borkmann wrote:
> >>>
> >>> [ also Cc'ing Willem, Pablo ]
> >>>
> >>> On 07/25/2014 10:04 AM, Alexei Starovoitov wrote:
> >>>>
> >>>> 'sk_filter' name is used as 'struct sk_filter', function sk_filter() and
> >>>> as variable 'sk_filter', which makes code hard to read.
> >>>> Also it's easily confused with 'struct sock_filter'
> >>>> Rename 'struct sk_filter' to 'struct bpf_prog' to clarify semantics and
> >>>> align the name with generic BPF use model.
> >>>
> >>>
> >>> Agreed, as we went for kernel/bpf/, renaming makes absolutely sense.
> >>
> >>
> >> My nft socket filtering changes are accomodated into struct sk_filter,
> >> and will still be, so I still need some generic name there...
> >
> >
> > All the parts from filter.c which is BPF's core engine have been moved
> > into kernel/bpf/ to get it ready for tracing et al, since there is not
> > always a socket context anymore. The *whole* infrastructure around struct
> > sk_filter is [e]BPF and used in non-net related contexts as well, whereas
> > nft socket filtering is *only* for sockets. Due to the socket-only specific
> > use case why doesn't it make more sense to have a union in struct sock
> > around sk_filter (or however we name it) and only allow one of the two
> > being loaded on a socket?
> 
> yep.
> Adding nft specific things to struct sk_filter/bpf_prog is not correct,
> since this struct is already part of seccomp and will be used
> in net-less configurations. SK_RUN_FILTER() macro will also be
> renamed into something like RUN_BPF_RPOG(). It's one and only
> way to invoke eBPF programs. Adding nft selector cannot work,
> since eBPF is used with generic context whereas nft is skb specific.
> If you want to add nft filtering capabilities to sockets, you'd need
> to add union around 'struct bpf_prog' inside 'struct sock', which will be
> much cleaner way.

The struct sk_filter is almost providing the generic framework, it
just needs to be generalized, a quick layout for it:

struct sk_filter {
        struct sk_filter_cb     *cb;
        atomic_t                refcnt;
        struct rcu_head         head;
        char                    data[0]; /* here, you specific struct bpf_prog */
};

The refcnt is required sk_filter_{charge,uncharge,release}. The struct
rcu_head is also need from sk_filter_release().

struct sk_filter_cb {
        int type;
        struct module *me;
        void (*charge)(struct sock *sk, struct sk_filter *fp);
        void (*uncharge)(struct sock *sk, struct sk_filter *fp);
        unsigned int (*run_filter)(struct sk_filter *fp, struct sk_buff *skb);
};

We have to provide the register/unregister functions for the specific
callbacks depending on the socket filtering approach. But I'll have to
introduce this myself when I come up with the nft patches again.

So meanwhile, you should just encapsulate what really belongs to
struct bpf_prog, ie. size, bytecode, jitted, etc. and leave struct
sk_filter in place.

struct sk_filter {
        atomic_t                refcnt;
        struct rcu_head         head;
        u32                     len;
        struct bpf_prog         bpf_prog;
};

The len will go into struct bpf_prog once the generic infrastructure
above is introduced since the semantics (number of blocks) is
different from nft.

If you straight forward rename the entire structure, you'll take
things that are not specific from bpf such as refcnt and rcu_head.
