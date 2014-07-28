From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Mon, 28 Jul 2014 23:45:52 +0200
Message-ID: <20140728214552.GA4049@salvia>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
 <53D23EAF.4000001@redhat.com>
 <20140725115414.GA4770@salvia>
 <53D254D9.9030905@redhat.com>
 <CAMEtUux+dw_GoafXE3ukvmOK2JmZWWf-y0VMobe60TSTfZeNmw@mail.gmail.com>
 <20140725221512.GA3729@salvia>
 <CAMEtUux8F4xZ77_HQADfoeV-9sibaEWm=XJcAaY+cQyDWb2caA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46560 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbaG1Vpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 17:45:44 -0400
Content-Disposition: inline
In-Reply-To: <CAMEtUux8F4xZ77_HQADfoeV-9sibaEWm=XJcAaY+cQyDWb2caA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 26, 2014 at 10:41:04PM -0700, Alexei Starovoitov wrote:
> On Fri, Jul 25, 2014 at 3:17 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > The struct sk_filter is almost providing the generic framework, it
> > just needs to be generalized, a quick layout for it:
> >
> > struct sk_filter {
> >         struct sk_filter_cb     *cb;
> >         atomic_t                refcnt;
> >         struct rcu_head         head;
> >         char                    data[0]; /* here, you specific struct bpf_prog */
> > };
> >
> > The refcnt is required sk_filter_{charge,uncharge,release}. The struct
> > rcu_head is also need from sk_filter_release().
> >
> > struct sk_filter_cb {
> >         int type;
> >         struct module *me;
> >         void (*charge)(struct sock *sk, struct sk_filter *fp);
> >         void (*uncharge)(struct sock *sk, struct sk_filter *fp);
> >         unsigned int (*run_filter)(struct sk_filter *fp, struct sk_buff *skb);
> > };
>
> Pablo,
>
> I don't think you understand the scope of BPF.
> 'struct module *'? to attach nft to sockets? ouch.

The idea is that there will be one sk_filter_cb per socket filtering
approach. The structure module is just there in case one of the
approach is loadable as kernel module, it's the typical code pattern
in the kernel. You can git grep for similar code.

> if you need to do it, go ahead, but please don't present such mess
> as a 'generic' infra.

This is extracted from one of your recent patches:

 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
-       atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+       if (!fp->ebpf)
+               atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
        sk_filter_release(fp);
 }

 void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
        atomic_inc(&fp->refcnt);
-       atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+       if (!fp->ebpf)
+               atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 }

Basically, that looks to me like two different socket filtering
approach. You only have to define the struct sock_filter_cb, set the
fields to point to the functions and register the approach in the
socket filtering engine. That will allow a simple way to look up the
filtering approach when loading the filter from userspace.

[...]
> What you're proposing won't work even for classic bpf.
> 'struct sock *' and 'struct module *' are totally redundant and won't
> work for seccomp, tracing and pretty much everything, but pure
> socket filtering.
> Somehow you think that 'struct sk_filter' is only used in sockets.
[...]
> > If you straight forward rename the entire structure, you'll take
> > things that are not specific from bpf such as refcnt and rcu_head.
>
> sorry Pablo, I don't think you understand what you're talking about.
> refcnt and rcu_head are key parts of bpf/ebpf infra.
> Programs are refcnt'ed not only by charging sockets. BPF is relying
> on rcu for safe execution as well.
> For example see my tracing filter patch that does:
> void trace_filter_call_bpf(struct event_filter *filter, void *ctx)
> {
>         rcu_read_lock();
>         SK_RUN_FILTER(filter->prog, ctx);
>         rcu_read_unlock();
> }
> One eBPF program can be attached to multiple 'events' where event
> is kprobe, tracepoint, syscall, etc The act of attaching increments
> 'struct sk_filter/bpf_prog -> refcnt'.

By quick git grepping you already can find clients of this that do not
need rcu / refcount: cls_bpf.c, net_cls.c, xt_bpf.c and
ptp_classifier.  Moreover, I only see the refcnt bumped from
sk_filter_charge(), I didn't find it neither in git nor in your
patches. I don't think rcu_head and refcnt are really part of the
filter *in any case*, they just provide the way to link/unlink objects
in a safe way in some situations.

By renaming this, you're not fixing up things the semantics. It seems
to me you just want to find a quick path to solve inconsistencies in
your code.
