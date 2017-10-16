From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] bpf: disallow arithmetic operations on context
 pointer
Date: Mon, 16 Oct 2017 09:30:43 -0700
Message-ID: <20171016093043.36fcfedc@cakuba.netronome.com>
References: <20171016154552.30640-1-jakub.kicinski@netronome.com>
        <44a8fb95-298b-8715-ce4e-60df60c86343@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <oss-drivers@netronome.com>,
        <alexei.starovoitov@gmail.com>, <daniel@iogearbox.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:44264 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754984AbdJPQar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:30:47 -0400
Received: by mail-qk0-f179.google.com with SMTP id r64so13563925qkc.1
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:30:47 -0700 (PDT)
In-Reply-To: <44a8fb95-298b-8715-ce4e-60df60c86343@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Oct 2017 17:16:24 +0100, Edward Cree wrote:
> On 16/10/17 16:45, Jakub Kicinski wrote:
> > Commit f1174f77b50c ("bpf/verifier: rework value tracking")
> > removed the crafty selection of which pointer types are
> > allowed to be modified.  This is OK for most pointer types
> > since adjust_ptr_min_max_vals() will catch operations on
> > immutable pointers.  One exception is PTR_TO_CTX which is
> > now allowed to be offseted freely.
> >
> > The intent of aforementioned commit was to allow context
> > access via modified registers.  The offset passed to  
> > ->is_valid_access() verifier callback has been adjusted  
> > by the value of the variable offset.
> >
> > What is missing, however, is taking the variable offset
> > into account when the context register is used.  Or in terms
> > of the code adding the offset to the value passed to the  
> > ->convert_ctx_access() callback.  This leads to the following  
> Good catch.
> So the problem is just that convert_ctx_access() can't deal
>  with it, yes?  Assuming that the offset is constant, because
>  otherwise we'd reject it anyway, we _could_ stash that offset
>  in insn_aux_data, and reject any paths that tried to change it
>  subsequently; and then convert_ctx_access() could be given the
>  total (off + reg->off) and then the reg->off could be subtracted
>  from the result, giving the right 'converted' insn offset.
> That would then mean that your example,
> > eBPF user code:
> >
> >      r1 += 68
> >      r0 = *(u32 *)(r1 + 8)
> >      exit
> >
> > being translated to this in kernel space:
> >
> >    0: (07) r1 += 68
> >    1: (61) r0 = *(u32 *)(r1 +180)
> >    2: (95) exit  
> would instead convert offset 76 to something else, let's say
>  200 just for the sake of argument, and produce
>    1: (61) r0 = *(u32 *)(r1 + 132)
>  which would then do the right thing at run time.
> 
> However, I don't know whether anyone would actually want this
>  to be supported for their programs, and so I'm happy to
>  disallow this for net and then maybe we can follow up in
>  net-next with the change I describe above if it's useful.

That was my thinking too.  We would have to stash the offset and make
sure that it doesn't change on different paths, but it's probably not
suitable for -net, and nobody uses that today (although Alexei
mentioned there may be valid use cases, especially in tracing).

> > Offset 8 is corresponding to 180 in the kernel, but offset
> > 76 is valid too.  Verifier will "accept" access to offset
> > 68+8=76 but then "convert" access to offset 8 as 180.
> > Effective access to offset 248 is beyond the kernel context.
> > (This is a __sk_buff example on a debug-heavy kernel -
> > packet mark is 8 -> 180, 76 would be data.)
> >
> > Dereferencing the modified context pointer is not as easy
> > as dereferencing other types, because we have to translate
> > the access to reading a field in kernel structures which is
> > usually at a different offset and often of a different size.
> > To allow modifying the pointer we would have to make sure
> > that given eBPF instruction will always access the same
> > field or the fields accessed are "compatible" in terms of
> > offset and size...
> >
> > Disallow dereferencing modified context pointers and add
> > to selftests the test case described here.
> >
> > Fixes: f1174f77b50c ("bpf/verifier: rework value tracking")
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > ---
> > Dave, a merge note - in net-next this will need env to be passed 
> > to verbose().
> >
> >  kernel/bpf/verifier.c                       |  8 ++++++--
> >  tools/testing/selftests/bpf/test_verifier.c | 14 ++++++++++++++
> >  2 files changed, 20 insertions(+), 2 deletions(-)
> >
> > diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> > index 8b8d6ba39e23..8499759d0c7a 100644
> > --- a/kernel/bpf/verifier.c
> > +++ b/kernel/bpf/verifier.c
> > @@ -1116,7 +1116,12 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
> >  		/* ctx accesses must be at a fixed offset, so that we can
> >  		 * determine what type of data were returned.
> >  		 */
> > -		if (!tnum_is_const(reg->var_off)) {
> > +		if (reg->off) {
> > +			verbose("derefence of modified ctx ptr R%d off=%d+%d, ctx+const is allowed, ctx+const+const is not\n",  
> This is slightly unclear, it's not that two adds is bad (e.g. r1 += 8;
>  r0 = *(u32 *)r1 is bad too), it's that the offset must be in the load,
>  not the register; your message might be accurate for some compilers but
>  not in full generality (especially for assemblers without compiling).

I'm happy to hear better suggestions :)  I've spent quite a bit of time
scratching my head thinking how to phrase this best.  The first
part of the message is general enough IMHO, the second is targeted
mostly at C developers.

> Also, sp. "dereference".

Argh.  aspell doesn't know that word, added to local dict now.
