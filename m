From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Tue, 11 Mar 2014 10:59:42 -0700
Message-ID: <CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
	<531EE5A2.7090501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>, kaber@trash.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <531EE5A2.7090501@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 3:29 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 03/11/2014 10:19 AM, Pablo Neira Ayuso wrote:
>>
>> Hi!
>>
>> The following patchset provides a socket filtering alternative to BPF
>> which allows you to define your filter using the nf_tables expressions.
>>
>> Similarly to BPF, you can attach filters via setsockopt()
>> SO_ATTACH_NFT_FILTER. The filter that is passed to the kernel is
>> expressed in netlink TLV format which looks like:
>>
>>   expression list (nested attribute)
>>    expression element (nested attribute)
>>     expression name (string)
>>     expression data (nested attribute)
>>      ... specific attribute for this expression go here
>>
>> This is similar to the netlink format of the nf_tables rules, so we
>> can re-use most of the infrastructure that we already have in userspace.
>> The kernel takes the TLV representation and translates it to the native
>> nf_tables representation.
>>
>> The patches 1-3 have helped to generalize the existing socket filtering
>> infrastructure to allow pluging new socket filtering frameworks. Then,
>> patches 4-8 generalize the nf_tables code by move the neccessary nf_tables
>> expression and data initialization core infrastructure. Then, patch 9
>> provides the nf_tables socket filtering capabilities.
>>
>> Patrick and I have been discussing for a while that part of this
>> generalisation works should also help to add support for providing a
>> replacement to the tc framework, so with the necessary work, nf_tables
>> may provide in the near future packet a single packet classification
>> framework for Linux.
>
>
> I'm being curious here ;) as there's currently an ongoing effort on
> netdev for Alexei's eBPF engine (part 1 at [1,2,3]), which addresses
> shortcomings of current BPF and shall long term entirely replace the
> current BPF engine code to let filters entirely run in eBPF resp.
> eBPF's JIT engine, as I understand, which is also transparently usable
> in cls_bpf for classification in tc w/o rewriting on a different filter
> language. Performance figures have been posted/provided in [1] as well.
>
> So the plan on your side would be to have an alternative to eBPF, or
> build on top of it to reuse its in-kernel JIT compiler?
>
>  [1] http://patchwork.ozlabs.org/patch/328927/
>  [2] http://patchwork.ozlabs.org/patch/328926/
>  [3] http://patchwork.ozlabs.org/patch/328928/
>
>
>> There is an example of the userspace code available at:
>>
>>   http://people.netfilter.org/pablo/nft-sock-filter-test.c
>>
>> I'm currently reusing the existing libnftnl interfaces, my plan is to
>> new interfaces in that library for easier and more simple filter
>> definition for socket filtering.
>>
>> Note that the current nf_tables expression-set is also limited with
>> regards to BPF, but the infrastructure that we have can be easily
>> extended with new expressions.
>>
>> Comments welcome!

Hi Pablo,

Could you share what performance you're getting when doing nft
filter equivalent to 'tcpdump port 22' ?
Meaning your filter needs to parse eth->proto, ip or ipv6 header and
check both ports. How will it compare with JITed bpf/ebpf ?

I was trying to go the other way: improve nft performance with ebpf.
10/40G links are way to fast for interpreters. imo JIT is the only way.

here are some comments about patches:
1/9:
-       if (fp->bpf_func != sk_run_filter)
-               module_free(NULL, fp->bpf_func);
+       if (fp->run_filter != sk_run_filter)
+               module_free(NULL, fp->run_filter);

David suggested that these comparisons in all jits are ugly.
I've fixed it in my patches. When they're in, you wouldn't need to
mess with this.

2/9:
-       atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+       atomic_sub(fp->size, &sk->sk_omem_alloc);

that's a big change in socket memory accounting.
We used to account for the whole sk_filter... now you're counting
filter size only.
Is it valid?

7/9:
whole nft_expr_autoload() looks scary from security point of view.
If I'm reading it correctly, the code will do request_module() based on
userspace request to attach filter?

9/9:
+       case SO_NFT_GET_FILTER:
+               len = sk_nft_get_filter(sk, (struct sock_filter __user
*)optval, len);
with my patches there was a concern regarding socket checkpoint/restore
and I had to preserve existing filter image to make sure it's not broken.
Could you please coordinate with Pavel and co to test this piece?

What will happen if nft_filter attached, but so_get_filter is called? crash?

+static int nft_sock_expr_autoload(const struct nft_ctx *ctx,
+                                 const struct nlattr *nla)
+{
+#ifdef CONFIG_MODULES
+       mutex_unlock(&nft_expr_info_mutex);
+       request_module("nft-expr-%.*s", nla_len(nla), (char *)nla_data(nla));
+       mutex_lock(&nft_expr_info_mutex);

same security concern here...

+int sk_nft_attach_filter(char __user *optval, struct sock *sk)
+{

what about sk_clone_lock()? since filter program is in nft, do you need to do
special steps during copy of socket?

+       fp = sock_kmalloc(sk, sizeof(struct sk_filter) + size, GFP_KERNEL);

this may allocate more memory then you need.
Currently sk_filter_size() computes it in an accurate way.

Also the same issue of optmem accounting as I mentioned in 2/9

+err4:
+       sock_kfree_s(sk, fp, size);

a small bug: allocated sizeof(sk_filter)+size, but freeing 'size' only...

Overall I think it's very interesting work.
Not sure what's the use case for it though.

I'll cook up a patch for the opposite approach (use ebpf inside nft)
and will send you for review.
I would prefer to work together to satisfy your and our user requests.

Thanks
Alexei

>> Pablo Neira Ayuso (9):
>>    net: rename fp->bpf_func to fp->run_filter
>>    net: filter: account filter length in bytes
>>    net: filter: generalise sk_filter_release
>>    netfilter: nf_tables: move fast operations to header
>>    netfilter: nf_tables: add nft_value_init
>>    netfilter: nf_tables: rename nf_tables_core.c to nf_tables_nf.c
>>    netfilter: nf_tables: move expression infrastructure to built-in core
>>    netfilter: nf_tables: generalize verdict handling and introduce scopes
>>    netfilter: nf_tables: add support for socket filtering
>>
>>   arch/arm/net/bpf_jit_32.c              |   25 +-
>>   arch/powerpc/net/bpf_jit_comp.c        |   10 +-
>>   arch/s390/net/bpf_jit_comp.c           |   16 +-
>>   arch/sparc/net/bpf_jit_comp.c          |    8 +-
>>   arch/x86/net/bpf_jit_comp.c            |    8 +-
>>   include/linux/filter.h                 |   28 +-
>>   include/net/netfilter/nf_tables.h      |   27 +-
>>   include/net/netfilter/nf_tables_core.h |   84 +++++
>>   include/net/netfilter/nft_reject.h     |    3 +-
>>   include/net/sock.h                     |    8 +-
>>   include/uapi/asm-generic/socket.h      |    4 +
>>   net/core/filter.c                      |   28 +-
>>   net/core/sock.c                        |   19 ++
>>   net/core/sock_diag.c                   |    4 +-
>>   net/netfilter/Kconfig                  |   13 +
>>   net/netfilter/Makefile                 |    9 +-
>>   net/netfilter/nf_tables_api.c          |  440 ++++---------------------
>>   net/netfilter/nf_tables_core.c         |  564
>> +++++++++++++++++++++-----------
>>   net/netfilter/nf_tables_nf.c           |  189 +++++++++++
>>   net/netfilter/nf_tables_sock.c         |  327 ++++++++++++++++++
>>   net/netfilter/nft_bitwise.c            |   35 +-
>>   net/netfilter/nft_byteorder.c          |   28 +-
>>   net/netfilter/nft_cmp.c                |   43 ++-
>>   net/netfilter/nft_compat.c             |    6 +-
>>   net/netfilter/nft_counter.c            |    3 +-
>>   net/netfilter/nft_ct.c                 |    9 +-
>>   net/netfilter/nft_exthdr.c             |    3 +-
>>   net/netfilter/nft_hash.c               |   12 +-
>>   net/netfilter/nft_immediate.c          |   35 +-
>>   net/netfilter/nft_limit.c              |    3 +-
>>   net/netfilter/nft_log.c                |    3 +-
>>   net/netfilter/nft_lookup.c             |    3 +-
>>   net/netfilter/nft_meta.c               |   51 ++-
>>   net/netfilter/nft_nat.c                |    3 +-
>>   net/netfilter/nft_payload.c            |   29 +-
>>   net/netfilter/nft_queue.c              |    3 +-
>>   net/netfilter/nft_rbtree.c             |   12 +-
>>   net/netfilter/nft_reject.c             |    3 +-
>>   38 files changed, 1416 insertions(+), 682 deletions(-)
>>   create mode 100644 net/netfilter/nf_tables_nf.c
>>   create mode 100644 net/netfilter/nf_tables_sock.c
>>
>
