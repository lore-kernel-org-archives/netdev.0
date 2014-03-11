From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Tue, 11 Mar 2014 11:29:54 +0100
Message-ID: <531EE5A2.7090501@redhat.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbaCKKaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 06:30:19 -0400
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2014 10:19 AM, Pablo Neira Ayuso wrote:
> Hi!
>
> The following patchset provides a socket filtering alternative to BPF
> which allows you to define your filter using the nf_tables expressions.
>
> Similarly to BPF, you can attach filters via setsockopt()
> SO_ATTACH_NFT_FILTER. The filter that is passed to the kernel is
> expressed in netlink TLV format which looks like:
>
>   expression list (nested attribute)
>    expression element (nested attribute)
>     expression name (string)
>     expression data (nested attribute)
>      ... specific attribute for this expression go here
>
> This is similar to the netlink format of the nf_tables rules, so we
> can re-use most of the infrastructure that we already have in userspace.
> The kernel takes the TLV representation and translates it to the native
> nf_tables representation.
>
> The patches 1-3 have helped to generalize the existing socket filtering
> infrastructure to allow pluging new socket filtering frameworks. Then,
> patches 4-8 generalize the nf_tables code by move the neccessary nf_tables
> expression and data initialization core infrastructure. Then, patch 9
> provides the nf_tables socket filtering capabilities.
>
> Patrick and I have been discussing for a while that part of this
> generalisation works should also help to add support for providing a
> replacement to the tc framework, so with the necessary work, nf_tables
> may provide in the near future packet a single packet classification
> framework for Linux.

I'm being curious here ;) as there's currently an ongoing effort on
netdev for Alexei's eBPF engine (part 1 at [1,2,3]), which addresses
shortcomings of current BPF and shall long term entirely replace the
current BPF engine code to let filters entirely run in eBPF resp.
eBPF's JIT engine, as I understand, which is also transparently usable
in cls_bpf for classification in tc w/o rewriting on a different filter
language. Performance figures have been posted/provided in [1] as well.

So the plan on your side would be to have an alternative to eBPF, or
build on top of it to reuse its in-kernel JIT compiler?

  [1] http://patchwork.ozlabs.org/patch/328927/
  [2] http://patchwork.ozlabs.org/patch/328926/
  [3] http://patchwork.ozlabs.org/patch/328928/

> There is an example of the userspace code available at:
>
>   http://people.netfilter.org/pablo/nft-sock-filter-test.c
>
> I'm currently reusing the existing libnftnl interfaces, my plan is to
> new interfaces in that library for easier and more simple filter
> definition for socket filtering.
>
> Note that the current nf_tables expression-set is also limited with
> regards to BPF, but the infrastructure that we have can be easily
> extended with new expressions.
>
> Comments welcome!
>
> Pablo Neira Ayuso (9):
>    net: rename fp->bpf_func to fp->run_filter
>    net: filter: account filter length in bytes
>    net: filter: generalise sk_filter_release
>    netfilter: nf_tables: move fast operations to header
>    netfilter: nf_tables: add nft_value_init
>    netfilter: nf_tables: rename nf_tables_core.c to nf_tables_nf.c
>    netfilter: nf_tables: move expression infrastructure to built-in core
>    netfilter: nf_tables: generalize verdict handling and introduce scopes
>    netfilter: nf_tables: add support for socket filtering
>
>   arch/arm/net/bpf_jit_32.c              |   25 +-
>   arch/powerpc/net/bpf_jit_comp.c        |   10 +-
>   arch/s390/net/bpf_jit_comp.c           |   16 +-
>   arch/sparc/net/bpf_jit_comp.c          |    8 +-
>   arch/x86/net/bpf_jit_comp.c            |    8 +-
>   include/linux/filter.h                 |   28 +-
>   include/net/netfilter/nf_tables.h      |   27 +-
>   include/net/netfilter/nf_tables_core.h |   84 +++++
>   include/net/netfilter/nft_reject.h     |    3 +-
>   include/net/sock.h                     |    8 +-
>   include/uapi/asm-generic/socket.h      |    4 +
>   net/core/filter.c                      |   28 +-
>   net/core/sock.c                        |   19 ++
>   net/core/sock_diag.c                   |    4 +-
>   net/netfilter/Kconfig                  |   13 +
>   net/netfilter/Makefile                 |    9 +-
>   net/netfilter/nf_tables_api.c          |  440 ++++---------------------
>   net/netfilter/nf_tables_core.c         |  564 +++++++++++++++++++++-----------
>   net/netfilter/nf_tables_nf.c           |  189 +++++++++++
>   net/netfilter/nf_tables_sock.c         |  327 ++++++++++++++++++
>   net/netfilter/nft_bitwise.c            |   35 +-
>   net/netfilter/nft_byteorder.c          |   28 +-
>   net/netfilter/nft_cmp.c                |   43 ++-
>   net/netfilter/nft_compat.c             |    6 +-
>   net/netfilter/nft_counter.c            |    3 +-
>   net/netfilter/nft_ct.c                 |    9 +-
>   net/netfilter/nft_exthdr.c             |    3 +-
>   net/netfilter/nft_hash.c               |   12 +-
>   net/netfilter/nft_immediate.c          |   35 +-
>   net/netfilter/nft_limit.c              |    3 +-
>   net/netfilter/nft_log.c                |    3 +-
>   net/netfilter/nft_lookup.c             |    3 +-
>   net/netfilter/nft_meta.c               |   51 ++-
>   net/netfilter/nft_nat.c                |    3 +-
>   net/netfilter/nft_payload.c            |   29 +-
>   net/netfilter/nft_queue.c              |    3 +-
>   net/netfilter/nft_rbtree.c             |   12 +-
>   net/netfilter/nft_reject.c             |    3 +-
>   38 files changed, 1416 insertions(+), 682 deletions(-)
>   create mode 100644 net/netfilter/nf_tables_nf.c
>   create mode 100644 net/netfilter/nf_tables_sock.c
>
