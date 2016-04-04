From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 4 Apr 2016 13:00:34 -0700
Message-ID: <20160404200032.GA69842@ast-mbp.thefacebook.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
 <57022A85.6040002@iogearbox.net>
 <20160404150700.1456ae80@redhat.com>
 <57026DFA.3090201@iogearbox.net>
 <CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
 <20160404171227.1f862cb1@redhat.com>
 <20160404152948.GA495@gmail.com>
 <57029127.3040303@gmail.com>
 <20160404161720.GB495@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ogerlitz@mellanox.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34139 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328AbcDDUAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 16:00:39 -0400
Received: by mail-pa0-f47.google.com with SMTP id fe3so150571963pab.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 13:00:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160404161720.GB495@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 09:17:22AM -0700, Brenden Blanco wrote:
> > >>
> > >> As Tom also points out, making the BPF interface independent of the SKB
> > >> meta-data structure, would also make the eBPF program more generally
> > >> applicable.
> > > The initial approach that I tried went down this path. Alexei advised
> > > that I use the pseudo skb, and in the future the API between drivers and
> > > bpf can change to adopt non-skb context. The only user facing ABIs in
> > > this patchset are the IFLA, the xdp_metadata struct, and the name of the
> > > new enum.

Exactly. That the most important part of this rfc.
Right now redirect to different queue, batching, prefetch and tons of
other code are mising. We have to plan the whole project, so we can
incrementally add features without breaking abi.
So new IFLA, xdp_metadata struct and enum for bpf return codes are
the main things to agree on.

> > > The reason to use a pseudo skb for now is that there will be a fair
> > > amount of churn to get bpf jit and interpreter to understand non-skb
> > > context in the bpf_load_pointer() code. I don't see the need for
> > > requiring that for this patchset, as it will be internal-only change
> > > if/when we use something else.
> > 
> > Another option would be to have per driver JIT code to patch up the
> > skb read/loads with descriptor reads and metadata. From a strictly
> > performance stand point it should be better than pseudo skbs.

Per-driver pre/post JIT-like phase is actually on the table. It may
still be needed. If we can avoid it while keeping high performance, great.
 
> I considered (and implemented) this as well, but there my problem was
> that I needed to inform the bpf() syscall at BPF_PROG_LOAD time which
> ifindex to look at for fixups, so I had to add a new ifindex field to
> bpf_attr. Then during verification I had to use a new ndo to get the
> driver-specific offsets for its particular descriptor format. It seemed
> kludgy.

Another reason for going with 'pseudo skb' structure was to reuse
load_byte/half/word instructions in bpf interpreter as-is.
Right now these instructions have to see in-kernel
'struct sk_buff' as context (note we have mirror __sk_buff
for user space), so to use load_byte for bpf_prog_type_phys_dev
we have to give real 'struct sk_buff' to interpter with
data, head, len, data_len fields initialized, so that
interpreter 'just works'.
The potential fix would be to add phys_dev specific load_byte/word
instructions. Then we can drop all the legacy negative offset
stuff that <1% uses, but it slows down everyone.
We can also drop byteswap that load_word does (which turned out
to be confusing and often programs do 2nd byteswap to go
back to cpu endiannes).
And if we do it smart, we can drop length check as well,
then new_load_byte will actually be single load byte cpu instruction.
We can drop length check when offset is constant in the verfier
and that constant is less than 64, since all packets are larger.
As seen in 'perf report' from patch 5:
  3.32%  ksoftirqd/1    [kernel.vmlinux]  [k] sk_load_byte_positive_offset
this is 14Mpps and 4 assembler instructions in the above function
are consuming 3% of the cpu. Making new_load_byte to be single
x86 insn would be really cool.

Of course, there are other pieces to accelerate:
 12.71%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_alloc_frags
  6.87%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_free_frag
  4.20%  ksoftirqd/1    [kernel.vmlinux]  [k] get_page_from_freelist
  4.09%  swapper        [mlx4_en]         [k] mlx4_en_process_rx_cq
and I think Jesper's work on batch allocation is going help that a lot.
