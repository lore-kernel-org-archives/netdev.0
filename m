From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Wed, 12 Apr 2017 21:38:39 +0200
Message-ID: <1492025919.2855.20.camel@sipsolutions.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
         <58ECB8CF.8040409@iogearbox.net> <1492002120.2855.3.camel@sipsolutions.net>
         <20170412165804.GA75807@ast-mbp.thefacebook.com>
         (sfid-20170412_185811_142047_71F34A05)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42160 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753929AbdDLTin (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 15:38:43 -0400
In-Reply-To: <20170412165804.GA75807@ast-mbp.thefacebook.com> (sfid-20170412_185811_142047_71F34A05)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 09:58 -0700, Alexei Starovoitov wrote:
> 
> > Are these hooked up to llvm intrinsics or so? If not, can I do that
> > through some kind of inline asm statement?
> 
> llvm doesn't support bpf inline asm yet.

Ok.

> > In the samples, I only see people doing
> > 
> > #define _htonl __builtin_bswap32
> > 
> > but I'm not even completely convinced that's correct, since it
> > assumes
> > a little-endian host?
> 
> oh well, time to face the music.
> 
> In llvm backend I did:
> // bswap16, bswap32, bswap64
> class BSWAP<bits<32> SizeOp, string OpcodeStr, list<dag> Pattern>
> ...
>   let op = 0xd;     // BPF_END
>   let BPFSrc = 1;   // BPF_TO_BE (TODO: use BPF_TO_LE for big-endian
> target)
>   let BPFClass = 4; // BPF_ALU
> 
> so __builtin_bswap32() is not a normal bswap. It's only doing bswap
> if the compiled program running on little endian arch.
> The plan was to fix it up for -march=bpfeb target (hence the comment
> above), but it turned out that such __builtin_bswap32 matches
> perfectly to _htonl() semantics, so I left it as-is even for
> -march=bpfeb.
> 
> On little endian:
> ld_abs_W = *(u32*) + real bswap32
> __builtin_bswap32() == bpf_to_be insn = real bswap32
> 
> On big endian:
> ld_abs_W = *(u32*)
> __builtin_bswap32() == bpf_to_be insn = nop
> 
> so in samples/bpf/*.c:
> load_word() + _htonl()(__builtin_bswap32) has the same semantics
> for both little and big endian archs, hence all networking sample
> code in
> samples/bpf/*_kern.c works fine.
> 
> imo the whole thing is crazy ugly. llvm doesn't have 'htonl'
> equivalent builtin, so builtin_bswap was the closest I could use to
> generate bpf_to_[bl]e insn.
> 

Awkward. How can this even be fixed without breaking all the existing
code?

I assume the BPF machine is intended to be endian-independent, which is
really the problem - normally you'd either
	#define be32_to_cpu bswap32
or
	#define be32_to_cpu(x) (x)
depending on the build architecture, I guess.

> To solve this properly I think we need two things:
> . proper bswap32 insn in BPF

Not sure you need that - what for? Normally this doesn't really get used directly, I think? At least I don't really see a good reason for using it directly. And reimplementing that now would break existing C code.

> . extend llvm with bpf_to_be/le builtins
> Both are not trivial amount of work.

It seems that perhaps the best way to solve this would be to actually
implement inline assembly. Then, existing C code that relies on the
(broken) bswap32 semantics can actually continue to work, if that
built-in isn't touched, and one could then implement the various
cpu_to_be32 and friends as inline assembly?

That would make it invisible to the LLVM optimiser though, so perhaps
not the best idea either.

johannes
