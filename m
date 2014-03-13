From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Wed, 12 Mar 2014 20:29:07 -0700
Message-ID: <CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
	<531EE5A2.7090501@redhat.com>
	<CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
	<20140312091500.GA4638@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>, kaber@trash.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140312091500.GA4638@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 2:15 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> Hi!
>
> I'm going to reply to Daniel and you in the same email, see below.
>
>  struct sk_filter
>  {
>         atomic_t                refcnt;
> -       unsigned int            len;    /* Number of filter blocks */
> +       /* len - number of insns in sock_filter program
> +        * len_ext - number of insns in socket_filter_ext program
> +        * jited - true if either original or extended program was
> JITed
> +        * orig_prog - original sock_filter program if not NULL
> +        */
> +       unsigned int            len;
> +       unsigned int            len_ext;
> +       unsigned int            jited:1;
> +       struct sock_filter      *orig_prog;
>         struct rcu_head         rcu;
> -       unsigned int            (*bpf_func)(const struct sk_buff *skb,
> -                                           const struct sock_filter
>                                             *filter);
> +       union {
> +               unsigned int (*bpf_func)(const struct sk_buff *skb,
> +                                        const struct sock_filter *fp);
> +               unsigned int (*bpf_func_ext)(const struct sk_buff *skb,
> +                                            const struct sock_filter_ext *fp);
> +       };
>         union {
>                 struct sock_filter      insns[0];
> +               struct sock_filter_ext  insns_ext[0];
>                 struct work_struct      work;
>         };
>  };
>
> I think we have to generalise this to make it flexible to accomodate
> any socket filtering infrastructure. For example, instead of having
> bpf_func and bpf_func_ext, I think it would be good to generalise it
> that so we pass some void *filter. I also think that other private

well, David indicated that using 'void*' for such cases is undesirable,
since we want to rely on compiler to do type verification as much
as we can. My patches are preserving type safety.
'void * filter' would mean - open the door for anything.
I don't think we want that type of 'generality'.

> information to the filtering approach should be put after the
> filtering code, in some variable length area.
>
> This change looks quite ad-hoc. My 1-3 patches were more going to the
> direction of making this in some generic way to accomodate any socket
> filtering infrastructure.

They may look ad-hoc, but they're preserving type checking.

>> Could you share what performance you're getting when doing nft
>> filter equivalent to 'tcpdump port 22' ?
>> Meaning your filter needs to parse eth->proto, ip or ipv6 header and
>> check both ports. How will it compare with JITed bpf/ebpf ?
>
> We already have plans to add jit to nf_tables.

The patches don't explain the reasons to do nft socket filtering.
I can only guess and my guess that this is to show
that nft sort of can do what bpf can.
tc can be made to do socket filtering too.
The differentiation is speed and ease of use.
Both have big question marks in sock_filter+nft approach.

I think to consider nft to be one and only classifier, some
benchmarking needs to be done first:
nft vs bpf, nft vs tc, nft vs ovs, ...

It can be done the other way too. nft can run on top of tc.
ovs can run on top of tc and so on.
I'm not advocating any of that.

Having one interpreter underneath doesn't mean that all
components will be easier to maintain or have less code around.
Code that converts from one to another counts as well.
Simplicity and performance should be the deciding factor.
imo nft+sock_filter example is not simple.

I've posted patches to compile restricted C into ebpf.
Theoretically I can make 'universal kernel module' out of ebpf.
Like, compile any C code into ebpf and jit it.
Such 'universal kernel module' will be runnable on all architectures.
One compiler to rule them all... one ebpf to run them all... NO!
That may be cool thing for university research, but no good
reason to do it in practice.
Same way nft for socket filtering is a cool research, but what
is the strong reason to have it in kernel and maintain forever?

>> here are some comments about patches:
>> 1/9:
>> -       if (fp->bpf_func != sk_run_filter)
>> -               module_free(NULL, fp->bpf_func);
>> +       if (fp->run_filter != sk_run_filter)
>> +               module_free(NULL, fp->run_filter);
>>
>> David suggested that these comparisons in all jits are ugly.
>> I've fixed it in my patches. When they're in, you wouldn't need to
>> mess with this.
>
> I see you have added fp->jited for this. I think we can make this more
> generic if we have some enum so fp->type will tell us what kind of
> filter we have, ie. bpf, bpf-jitted, nft, etc.

Such enum will have a problem of explosion when flags
start to cross-multiply.
fp->jited flag just says jitted or not. Easier to check.

>> 2/9:
>> -       atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
>> +       atomic_sub(fp->size, &sk->sk_omem_alloc);
>>
>> that's a big change in socket memory accounting.
>> We used to account for the whole sk_filter... now you're counting
>> filter size only.
>> Is it valid?
>
> We need this change for if nf_tables. We don't use a fixed layout for

I think you missed the point.
Allocated sockopt memory is not counted properly.
It's not fixed vs non-fixed. sizeof(struct sk_filter) needs to
be accounted too, since it was allocated.

> each instruction of the filter like you do, I mean:
>
> +struct sock_filter_ext {
> +       __u8    code;    /* opcode */
> +       __u8    a_reg:4; /* dest register */
> +       __u8    x_reg:4; /* source register */
> +       __s16   off;     /* signed offset */
> +       __s32   imm;     /* signed immediate constant */
> +};
>
> If I didn't miss anything from your patchset, that structure is again
> exposed to userspace, so we won't be able to change it ever unless we
> add a new binary interface.
>
> From the user interface perspective, our nft approach is quite
> different, from userspace you express the filter using TLVs (like in
> the payload of the netlink message). Then, nf_tables core
> infrastructure parses this and transforms it to the kernel
> representation. It's very flexible since you don't expose the internal
> representation to userspace, which means that we can change the
> internal layout anytime, thus, highly extensible.

bpf/ebpf is an instruction set. Arguing about fixed vs non-fixed
insn size is like arguing x86 variable encoding vs sparc fixed.
Both are infinitely flexible.
ebpf is a low level insn set with defined calling convention, so
ebpf program can call fixed set of kernel functions if ebpf checker
allows that.
In sockfilters+ebpf, seccomp+ebpf, ovs+ebpf and tracing+ebpf
I've already demonstrated that ebpf instruction set, its
interpreter and its JIT are staying the same, while all are doing
very different things. Cannot think of better extensibility.

Extensibility is not with new instructions. We don't add new
instructions to x86 just to do a new feature.
New instructions are added to CPUs to make feature faster.
Like aes crypto can be done with normal x86 insns and it can
be done with aseni intel extensions. Same way aes can be done
with ebpf and ebpf doesn't need new instructions to do that.

> BTW, how do you make when you don't need the imm field? You just leave
> it unset I guess. And how does the code to compare an IPv6 address
> looks like?

how x86 or sparc instruction set handles ipv6 addresses
without 128-bit registers? ebpf does the same.

nft design picked 128 bit registers because of ipv6 addresses?
That makes it difficult to jit.

>> 7/9:
>> whole nft_expr_autoload() looks scary from security point of view.
>> If I'm reading it correctly, the code will do request_module() based on
>> userspace request to attach filter?
>
> Only root can invoke that code so far.

If we want to allow non-root access the whole nft needs to
be scrutinized.

>> +       fp = sock_kmalloc(sk, sizeof(struct sk_filter) + size, GFP_KERNEL);
>>
>> this may allocate more memory then you need.
>> Currently sk_filter_size() computes it in an accurate way.
>
> That won't work for nf_tables, we don't necessarily have to stick to a
> fixed layout per instruction like you do, so the real filter size is
> obtained after parsing the TLVs that was passed from userspace.

That sock_malloc is allocating sizeof(sk_filter) + size.
Meaning that it allocated unnecessary sizeof(work_struct) bytes
and not accounting for them and for sk_filter itself in filter charge/uncharge

>> Also the same issue of optmem accounting as I mentioned in 2/9
>>
>> +err4:
>> +       sock_kfree_s(sk, fp, size);
>>
>> a small bug: allocated sizeof(sk_filter)+size, but freeing 'size' only...
>
> Good catch, I'll fix it, thanks.
>
>> Overall I think it's very interesting work.
>> Not sure what's the use case for it though.
>>
>> I'll cook up a patch for the opposite approach (use ebpf inside nft)
>> and will send you for review.
>
> I don't like the idea of sticking to some fixed layout structure to
> represent the filter, please hold on with it.
>
>> I would prefer to work together to satisfy your and our user requests.
>
> That would be nice, but so far I think that we have different
> approaches from user interface perspective and, thus, the kernel
> design for it.

Since you're planning to do nft-jit, you'd need to generate bits and
bytes for different architectures with their own quirks.
Don't you want to offload this work to somebody who already did this
and who understand quirks of different architectures?
Now imagine that you can generate some intermediate representation
that maps one to one to x86 and other architectures.
Intermediate representation is a pseudo assembler code.
Say you want to translate nft-cmp instruction into sequence of native
comparisons. You'd need to use load from memory, compare and
branch operations. That's ebpf!
Design of ebpf is such that every ebpf insn maps to one native insn.
You can view ebpf as a tool to achieve jiting of nft.
It will save you a lot of time.

Thanks
Alexei
