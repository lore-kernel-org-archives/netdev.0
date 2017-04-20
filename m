From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Fix values type used in test_maps
Date: Thu, 20 Apr 2017 15:53:49 -0700
Message-ID: <20170420225347.GA17554@ast-mbp.thefacebook.com>
References: <20170420.152016.2219427430519868937.davem@davemloft.net>
 <58F92725.5050304@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ast@fb.com,
        borkmann@iogearbox.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32788 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947917AbdDTWxy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 18:53:54 -0400
Received: by mail-io0-f193.google.com with SMTP id k87so21780006ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 15:53:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58F92725.5050304@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 11:24:53PM +0200, Daniel Borkmann wrote:
> On 04/20/2017 09:20 PM, David Miller wrote:
> >
> >Maps of per-cpu type have their value element size adjusted to 8 if it
> >is specified smaller during various map operations.
> >
> >This makes test_maps as a 32-bit binary fail, in fact the kernel
> >writes past the end of the value's array on the user's stack.
> >
> >To be quite honest, I think the kernel should reject creation of a
> >per-cpu map that doesn't have a value size of at least 8 if that's
> >what the kernel is going to silently adjust to later.
> 
> It's unintuitive, agree, and it's in fact a round_up(value_size, 8),
> so rejecting a value size smaller than 8 doesn't really help; commit
> 15a07b33814d ("bpf: add lookup/update support for per-cpu hash and
> array maps") explained the rationale a bit. Hmm, we should probably
> move at least the bpf_num_possible_cpus() and round_up(val_size, 8)
> calculation as a single wrapper function to be used for determining
> the array size into bpf_util.h, so that it's slightly easier to deal
> with.

yes.
The reason even non-percpu array does round_up(value_size, 8) is
to make sure that all elements are aligned, so when bpf prog does
struct foo *value = bpf_map_lookup(key)
..value->field.. // here the verifier can check alignment of ld/st properly

The reason we don't reject array value_size < 8 is to allow less
than 64-bit counters. Like this set:
struct array_value {
  __u32 cnt1;
  __u32 cnt2;
  __u32 cnt3;
};

is valid and from bpf program only these 3 counters are accessible.
The kernel will allocate 16-byte for it and will copy it to user space
via bpf_long_memcpy(), since kernel doesn't know the contents of
the hash/array values.
I agree that is non intuitive and we need a helper in bpf_util.h
to let user space do 'char buf[round_up(value_size, 8)][nr_cpus]' cleanly.

> >If the user passed something smaller, it is a sizeof() calcualtion
> >based upon the type they will actually use (just like in this testcase
> >code) in later calls to the map operations.
> 
> Fixes: df570f577231 ("samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_ARRAY")
> 
> >Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

For this test it's indeed a good fix.
Acked-by: Alexei Starovoitov <ast@kernel.org>
