From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Mon, 25 Sep 2017 18:33:00 -0700
Message-ID: <20170926013259.cwnpnshay4rxnmyr@ast-mbp>
References: <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
 <CAH3MdRVK-=pL8YCz44BPCmHhuZE_CRfih0QdZPLa=mpE_uoA_Q@mail.gmail.com>
 <ec7d0485-11f4-4fdb-0b87-1fb0afdb4f11@solarflare.com>
 <CAH3MdRVCf_wLoC7WOfaL2L2px3aYVWUhWxarMsyJdD7_E9fv_Q@mail.gmail.com>
 <CAH3MdRXgVtVjhYQkRopPKvL+4+NaTRRJoJq6XD_S-Dra69j0hA@mail.gmail.com>
 <20170922151614.bg4ovrp6m27cppr7@ast-mbp>
 <7c1ab2b8-e65d-3b09-f9f0-9fd13c1ceccf@solarflare.com>
 <CAH3MdRUCPNzXHQRQtVp7-p9XLDbJrkhxYEe=c0Fkt4+D9Tk9sw@mail.gmail.com>
 <20170924055016.w6x5tj6kjxjbocpl@ast-mbp>
 <59C978A2.6070405@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Y Song <ys114321@gmail.com>, Edward Cree <ecree@solarflare.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jiong Wang <jiong.wang@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:52538 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965729AbdIZBdE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 21:33:04 -0400
Received: by mail-pg0-f41.google.com with SMTP id i195so5047462pgd.9
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 18:33:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59C978A2.6070405@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 11:44:02PM +0200, Daniel Borkmann wrote:
> On 09/24/2017 07:50 AM, Alexei Starovoitov wrote:
> > On Fri, Sep 22, 2017 at 09:49:10PM -0700, Y Song wrote:
> > > On Fri, Sep 22, 2017 at 9:23 AM, Edward Cree <ecree@solarflare.com> wrote:
> > > > On 22/09/17 16:16, Alexei Starovoitov wrote:
> > > > > looks like we're converging on
> > > > > "be16/be32/be64/le16/le32/le64 #register" for BPF_END.
> > > > > I guess it can live with that. I would prefer more C like syntax
> > > > > to match the rest, but llvm parsing point is a strong one.
> > > > Yep, agreed.  I'll post a v2 once we've settled BPF_NEG.
> > > > > For BPG_NEG I prefer to do it in C syntax like interpreter does:
> > > > >          ALU_NEG:
> > > > >                  DST = (u32) -DST;
> > > > >          ALU64_NEG:
> > > > >                  DST = -DST;
> > > > > Yonghong, does it mean that asmparser will equally suffer?
> > > > Correction to my earlier statements: verifier will currently disassemble
> > > >   neg as:
> > > > (87) r0 neg 0
> > > > (84) (u32) r0 neg (u32) 0
> > > >   because it pretends 'neg' is a compound-assignment operator like +=.
> > > > The analogy with be16 and friends would be to use
> > > >      neg64 r0
> > > >      neg32 r0
> > > >   whereas the analogy with everything else would be
> > > >      r0 = -r0
> > > >      r0 = (u32) -r0
> > > >   as Alexei says.
> > > > I'm happy to go with Alexei's version if it doesn't cause problems for llvm.
> > > 
> > > I got some time to do some prototyping in llvm and it looks like that
> > > I am able to
> > > resolve the issue and we are able to use more C-like syntax. That is:
> > > for bswap:
> > >       r1 = (be16) (u16) r1
> > >       or
> > >       r1 = (be16) r1
> > >       or
> > >       r1 = be16 r1
> > > for neg:
> > >       r0 = -r0
> > >       (for 32bit support, llvm may output "w0 = -w0" in the future. But
> > > since it is not
> > >        enabled yet, you can continue to output "r0 = (u32) -r0".)
> > > 
> > > Not sure which syntax is best for bswap. The "r1 = (be16) (u16) r1" is most
> > > explicit in its intention.
> > > 
> > > Attaching my llvm patch as well and cc'ing Jiong and Jakub so they can see my
> > > implementation and the relative discussion here. (In this patch, I did
> > > not implement
> > > bswap for little endian yet.) Maybe they can provide additional comments.
> > 
> > This is awesome. In such case I'd like to swing back to the C syntax for bpf_end :)
> > Any of these
> >    r1 = (be16) (u16) r1
> >    or
> >    r1 = (be16) r1
> >    or
> >    r1 = be16 r1
> > are better than just
> >    be16 r1
> > I like 1st the most, since it's explicit in terms of what happens with upper bits,
> > but 2nd is also ok. 3rd is not quite C-like.
> 
> But above cast to be16 also doesn't seem quite C-like in terms
> of what we're actually doing... 3rd option would be my personal
> preference even if it doesn't look C-like, but otoh we also have
> 'call' etc which is neither.

well, we have not quite C, but C-like syntax already
(u32) r0 += (u32) r1;
Clearly first cast isn't quite C, but it shows that src reg is only
using 32-bit in the alu and imo that's better than using
w0 += w1; syntax. It's not quite C, but it's intent is way more clear
for folks that know C and don't know assembler than 'w0 = w1'.
And imo it's better than r0 = (u32) r0 + (u32) r1;
that why I did this format long ago and not because of laziness.
The 'endian' part, have to confess, was me being lazy,
but I'd rather fix it to match the rest of the 'not quite C, but C-like' style.
In that sense (be16) cast is pretty much self explanatory.
So I'd like to continue bikesheding in hopes to convince you
to accept either 1 or 2 above ;)
