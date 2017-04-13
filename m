From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: eBPF - little-endian load instructions?
Date: Wed, 12 Apr 2017 20:08:20 -0700
Message-ID: <20170413030818.GA42879@ast-mbp.thefacebook.com>
References: <1491907114.31620.18.camel@sipsolutions.net>
 <58ECB8CF.8040409@iogearbox.net>
 <1492002120.2855.3.camel@sipsolutions.net>
 <20170412165804.GA75807@ast-mbp.thefacebook.com>
 <1492025919.2855.20.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34519 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdDMDIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:08:25 -0400
Received: by mail-pg0-f52.google.com with SMTP id 21so23801762pgg.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 20:08:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492025919.2855.20.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 09:38:39PM +0200, Johannes Berg wrote:
> On Wed, 2017-04-12 at 09:58 -0700, Alexei Starovoitov wrote:
> > 
> > > Are these hooked up to llvm intrinsics or so? If not, can I do that
> > > through some kind of inline asm statement?
> > 
> > llvm doesn't support bpf inline asm yet.
> 
> Ok.
> 
> > > In the samples, I only see people doing
> > > 
> > > #define _htonl __builtin_bswap32
> > > 
> > > but I'm not even completely convinced that's correct, since it
> > > assumes
> > > a little-endian host?
> > 
> > oh well, time to face the music.
> > 
> > In llvm backend I did:
> > // bswap16, bswap32, bswap64
> > class BSWAP<bits<32> SizeOp, string OpcodeStr, list<dag> Pattern>
> > ...
> >   let op = 0xd;     // BPF_END
> >   let BPFSrc = 1;   // BPF_TO_BE (TODO: use BPF_TO_LE for big-endian
> > target)
> >   let BPFClass = 4; // BPF_ALU
> > 
> > so __builtin_bswap32() is not a normal bswap. It's only doing bswap
> > if the compiled program running on little endian arch.
> > The plan was to fix it up for -march=bpfeb target (hence the comment
> > above), but it turned out that such __builtin_bswap32 matches
> > perfectly to _htonl() semantics, so I left it as-is even for
> > -march=bpfeb.
> > 
> > On little endian:
> > ld_abs_W = *(u32*) + real bswap32
> > __builtin_bswap32() == bpf_to_be insn = real bswap32
> > 
> > On big endian:
> > ld_abs_W = *(u32*)
> > __builtin_bswap32() == bpf_to_be insn = nop
> > 
> > so in samples/bpf/*.c:
> > load_word() + _htonl()(__builtin_bswap32) has the same semantics
> > for both little and big endian archs, hence all networking sample
> > code in
> > samples/bpf/*_kern.c works fine.
> > 
> > imo the whole thing is crazy ugly. llvm doesn't have 'htonl'
> > equivalent builtin, so builtin_bswap was the closest I could use to
> > generate bpf_to_[bl]e insn.
> > 
> 
> Awkward. How can this even be fixed without breaking all the existing
> code?

it's really llvm bug that i need fix. It's plain broken
to generate what effectively is nop insn for march=bpfeb
My only excuse that when that code was written llvm had only march=bpfel.
bpfeb was added much later.

> I assume the BPF machine is intended to be endian-independent, which is
> really the problem - normally you'd either
> 	#define be32_to_cpu bswap32
> or
> 	#define be32_to_cpu(x) (x)
> depending on the build architecture, I guess.

yeah. that's what we should have in bpf_helpers.h

> > To solve this properly I think we need two things:
> > . proper bswap32 insn in BPF
> 
> Not sure you need that - what for? Normally this doesn't really get used directly, I think? At least I don't really see a good reason for using it directly. And reimplementing that now would break existing C code.

I think bswap is only used in crypto and things like crypto.
In the kernel it's 802.15.4 mac.
ntoh is enough for any networking code,
so I guess we can live without real bswap insn.

> > . extend llvm with bpf_to_be/le builtins
> > Both are not trivial amount of work.
> 
> It seems that perhaps the best way to solve this would be to actually
> implement inline assembly. Then, existing C code that relies on the
> (broken) bswap32 semantics can actually continue to work, if that
> built-in isn't touched, and one could then implement the various
> cpu_to_be32 and friends as inline assembly?
> 
> That would make it invisible to the LLVM optimiser though, so perhaps
> not the best idea either.

In llvm the inline asm is actually visible to optimizer (unlike gcc),
so it can be ok-ish.
Inline asm needs to be done anyway.
