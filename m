From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Wed, 12 Mar 2014 10:15:00 +0100
Message-ID: <20140312091500.GA4638@localhost>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
 <531EE5A2.7090501@redhat.com>
 <CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>, kaber@trash.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I'm going to reply to Daniel and you in the same email, see below.

On Tue, Mar 11, 2014 at 10:59:42AM -0700, Alexei Starovoitov wrote:
> On Tue, Mar 11, 2014 at 3:29 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> > On 03/11/2014 10:19 AM, Pablo Neira Ayuso wrote:
> >>
> >> Hi!
> >>
> >> The following patchset provides a socket filtering alternative to BPF
> >> which allows you to define your filter using the nf_tables expressions.
> >>
> >> Similarly to BPF, you can attach filters via setsockopt()
> >> SO_ATTACH_NFT_FILTER. The filter that is passed to the kernel is
> >> expressed in netlink TLV format which looks like:
> >>
> >>   expression list (nested attribute)
> >>    expression element (nested attribute)
> >>     expression name (string)
> >>     expression data (nested attribute)
> >>      ... specific attribute for this expression go here
> >>
> >> This is similar to the netlink format of the nf_tables rules, so we
> >> can re-use most of the infrastructure that we already have in userspace.
> >> The kernel takes the TLV representation and translates it to the native
> >> nf_tables representation.
> >>
> >> The patches 1-3 have helped to generalize the existing socket filtering
> >> infrastructure to allow pluging new socket filtering frameworks. Then,
> >> patches 4-8 generalize the nf_tables code by move the neccessary nf_tables
> >> expression and data initialization core infrastructure. Then, patch 9
> >> provides the nf_tables socket filtering capabilities.
> >>
> >> Patrick and I have been discussing for a while that part of this
> >> generalisation works should also help to add support for providing a
> >> replacement to the tc framework, so with the necessary work, nf_tables
> >> may provide in the near future packet a single packet classification
> >> framework for Linux.
> >
> >
> > I'm being curious here ;) as there's currently an ongoing effort on
> > netdev for Alexei's eBPF engine (part 1 at [1,2,3]), which addresses
> > shortcomings of current BPF and shall long term entirely replace the
> > current BPF engine code to let filters entirely run in eBPF resp.
> > eBPF's JIT engine, as I understand, which is also transparently usable
> > in cls_bpf for classification in tc w/o rewriting on a different filter
> > language. Performance figures have been posted/provided in [1] as well.
> >
> > So the plan on your side would be to have an alternative to eBPF, or
> > build on top of it to reuse its in-kernel JIT compiler?
> >
> >  [1] http://patchwork.ozlabs.org/patch/328927/

 struct sk_filter
 {
        atomic_t                refcnt;
-       unsigned int            len;    /* Number of filter blocks */
+       /* len - number of insns in sock_filter program
+        * len_ext - number of insns in socket_filter_ext program
+        * jited - true if either original or extended program was
JITed
+        * orig_prog - original sock_filter program if not NULL
+        */
+       unsigned int            len;
+       unsigned int            len_ext;
+       unsigned int            jited:1;
+       struct sock_filter      *orig_prog;
        struct rcu_head         rcu;
-       unsigned int            (*bpf_func)(const struct sk_buff *skb,
-                                           const struct sock_filter
                                            *filter);
+       union {
+               unsigned int (*bpf_func)(const struct sk_buff *skb,
+                                        const struct sock_filter *fp);
+               unsigned int (*bpf_func_ext)(const struct sk_buff *skb,
+                                            const struct sock_filter_ext *fp);
+       };
        union {
                struct sock_filter      insns[0];
+               struct sock_filter_ext  insns_ext[0];
                struct work_struct      work;
        };
 };

I think we have to generalise this to make it flexible to accomodate
any socket filtering infrastructure. For example, instead of having
bpf_func and bpf_func_ext, I think it would be good to generalise it
that so we pass some void *filter. I also think that other private
information to the filtering approach should be put after the
filtering code, in some variable length area.

This change looks quite ad-hoc. My 1-3 patches were more going to the
direction of making this in some generic way to accomodate any socket
filtering infrastructure.

> >  [2] http://patchwork.ozlabs.org/patch/328926/
> >  [3] http://patchwork.ozlabs.org/patch/328928/
> >
> >> There is an example of the userspace code available at:
> >>
> >>   http://people.netfilter.org/pablo/nft-sock-filter-test.c
> >>
> >> I'm currently reusing the existing libnftnl interfaces, my plan is to
> >> new interfaces in that library for easier and more simple filter
> >> definition for socket filtering.
> >>
> >> Note that the current nf_tables expression-set is also limited with
> >> regards to BPF, but the infrastructure that we have can be easily
> >> extended with new expressions.
> >>
> >> Comments welcome!
> 
> Hi Pablo,
> 
> Could you share what performance you're getting when doing nft
> filter equivalent to 'tcpdump port 22' ?
> Meaning your filter needs to parse eth->proto, ip or ipv6 header and
> check both ports. How will it compare with JITed bpf/ebpf ?

We already have plans to add jit to nf_tables.

> I was trying to go the other way: improve nft performance with ebpf.
> 10/40G links are way to fast for interpreters. imo JIT is the only way.
>
> here are some comments about patches:
> 1/9:
> -       if (fp->bpf_func != sk_run_filter)
> -               module_free(NULL, fp->bpf_func);
> +       if (fp->run_filter != sk_run_filter)
> +               module_free(NULL, fp->run_filter);
> 
> David suggested that these comparisons in all jits are ugly.
> I've fixed it in my patches. When they're in, you wouldn't need to
> mess with this.

I see you have added fp->jited for this. I think we can make this more
generic if we have some enum so fp->type will tell us what kind of
filter we have, ie. bpf, bpf-jitted, nft, etc.

> 2/9:
> -       atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
> +       atomic_sub(fp->size, &sk->sk_omem_alloc);
> 
> that's a big change in socket memory accounting.
> We used to account for the whole sk_filter... now you're counting
> filter size only.
> Is it valid?

We need this change for if nf_tables. We don't use a fixed layout for
each instruction of the filter like you do, I mean:

+struct sock_filter_ext {
+       __u8    code;    /* opcode */
+       __u8    a_reg:4; /* dest register */
+       __u8    x_reg:4; /* source register */
+       __s16   off;     /* signed offset */
+       __s32   imm;     /* signed immediate constant */
+};

If I didn't miss anything from your patchset, that structure is again
exposed to userspace, so we won't be able to change it ever unless we
add a new binary interface.

>From the user interface perspective, our nft approach is quite
different, from userspace you express the filter using TLVs (like in
the payload of the netlink message). Then, nf_tables core
infrastructure parses this and transforms it to the kernel
representation. It's very flexible since you don't expose the internal
representation to userspace, which means that we can change the
internal layout anytime, thus, highly extensible.

BTW, how do you make when you don't need the imm field? You just leave
it unset I guess. And how does the code to compare an IPv6 address
looks like?

> 7/9:
> whole nft_expr_autoload() looks scary from security point of view.
> If I'm reading it correctly, the code will do request_module() based on
> userspace request to attach filter?

Only root can invoke that code so far.

> 9/9:
> +       case SO_NFT_GET_FILTER:
> +               len = sk_nft_get_filter(sk, (struct sock_filter __user
> *)optval, len);
> with my patches there was a concern regarding socket checkpoint/restore
> and I had to preserve existing filter image to make sure it's not broken.
> Could you please coordinate with Pavel and co to test this piece?
> 
> What will happen if nft_filter attached, but so_get_filter is called? crash?

I was trying to avoid to add some enum to identify to sk_filter to
identify what kind of filter we have there, but this is needed
indeed. Thanks for spotting this.

> +static int nft_sock_expr_autoload(const struct nft_ctx *ctx,
> +                                 const struct nlattr *nla)
> +{
> +#ifdef CONFIG_MODULES
> +       mutex_unlock(&nft_expr_info_mutex);
> +       request_module("nft-expr-%.*s", nla_len(nla), (char *)nla_data(nla));
> +       mutex_lock(&nft_expr_info_mutex);
> 
> same security concern here...
> 
> +int sk_nft_attach_filter(char __user *optval, struct sock *sk)
> +{
> 
> what about sk_clone_lock()? since filter program is in nft, do you need to do
> special steps during copy of socket?
> 
> +       fp = sock_kmalloc(sk, sizeof(struct sk_filter) + size, GFP_KERNEL);
>
> this may allocate more memory then you need.
> Currently sk_filter_size() computes it in an accurate way.

That won't work for nf_tables, we don't necessarily have to stick to a
fixed layout per instruction like you do, so the real filter size is
obtained after parsing the TLVs that was passed from userspace.

> Also the same issue of optmem accounting as I mentioned in 2/9
> 
> +err4:
> +       sock_kfree_s(sk, fp, size);
> 
> a small bug: allocated sizeof(sk_filter)+size, but freeing 'size' only...

Good catch, I'll fix it, thanks.

> Overall I think it's very interesting work.
> Not sure what's the use case for it though.
> 
> I'll cook up a patch for the opposite approach (use ebpf inside nft)
> and will send you for review.

I don't like the idea of sticking to some fixed layout structure to
represent the filter, please hold on with it.

> I would prefer to work together to satisfy your and our user requests.

That would be nice, but so far I think that we have different
approaches from user interface perspective and, thus, the kernel
design for it.
