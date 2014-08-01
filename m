From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 net-next 5/5] net: filter: split 'struct sk_filter'
 into socket and bpf parts
Date: Fri, 1 Aug 2014 18:06:12 +0200
Message-ID: <20140801160612.GA4679@salvia>
References: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
 <1406777656-27755-6-git-send-email-ast@plumgrid.com>
 <20140731194059.GA8681@salvia>
 <CAMEtUuy+iABzHagoono+CPB=Ex4Ew4vQBK65x1jDRC9_W9L7Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuy+iABzHagoono+CPB=Ex4Ew4vQBK65x1jDRC9_W9L7Dw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 31, 2014 at 02:02:19PM -0700, Alexei Starovoitov wrote:
> On Thu, Jul 31, 2014 at 12:40 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Wed, Jul 30, 2014 at 08:34:16PM -0700, Alexei Starovoitov wrote:
> >> clean up names related to socket filtering and bpf in the following way:
> >> - everything that deals with sockets keeps 'sk_*' prefix
> >> - everything that is pure BPF is changed to 'bpf_*' prefix
> >>
> >> split 'struct sk_filter' into
> >> struct sk_filter {
> >>       atomic_t        refcnt;
> >>       struct rcu_head rcu;
> >>       struct bpf_prog *prog;
> >> };
> >
> > I think you can use 'struct bpf_prog prog' instead so the entire
> > sk_filter remains in the same memory blob (as it is before this
> > patch).
> >
> > You can add an inline function to retrieve the bpg prog from the
> > filter:
> >
> > static inline struct bpf_prog *sk_filter_bpf(struct sk_filter *)
> >
> > and use it whenever possible to fetch the bpf program. I'm suggesting
> > this because we can use the zero array size in the socket filtering
> > abstraction later on, if the function above is used, this just needs
> > one line in that function to be updated to fetch the program from the
> > placeholder.
> 
> correct. It would speed up SK_RUN_FILTER macro a little and I've
> considered it, but decided to go with the pointer for two reasons:
> 1.In sk_attach_filter() the bpf_prog is allocated, then reallocated
> as part of bpf_prepare_filter(). My patch #1 cleans up that part to
> avoid 'struct sock *' dependency, so all bpf_* functions work
> purely with bpf_prog... If bpf_prog is embedded inside sk_filter,
> bpf_prepare_filter would need to have a callback to reallocate
> the container struct and pass this callback through the chain
> of calls, which is ugly

I think you can allocate the sk_filter once you get the final bpf
program, then you can memcpy() it. This adds some extra overhead in
the sk_attach_filter(), but that path is executed from user context
and it's also a rare operation (only once to attach the filter). It's
still not going to be a beauty, but IMO it's worth to focus on getting
that little speed up in the packet path at the cost of adding some
overhead on the socket attach path.

> 2. having it as a pointer helps nft in the long run, since whole of
> bpf_prog doesn't stay around inside sk_filter when it's not used.

If you put into place the inline wrapper function that I'm proposing
above and you use it instead of fp->bpf_prog, I think there should be
not interference:

static inline struct bpf_prog *sk_filter_bpf(struct sk_filter *sk)
{
-       return &sk->bpf_prog;
+       return (struct bpf_prog *)sk->data;
}
