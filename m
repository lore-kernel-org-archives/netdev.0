From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: eBPF - little-endian load instructions?
Date: Wed, 12 Apr 2017 09:58:06 -0700
Message-ID: <20170412165804.GA75807@ast-mbp.thefacebook.com>
References: <1491907114.31620.18.camel@sipsolutions.net>
 <58ECB8CF.8040409@iogearbox.net>
 <1492002120.2855.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35743 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754257AbdDLQ6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:58:15 -0400
Received: by mail-pf0-f176.google.com with SMTP id i5so16463346pfc.2
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 09:58:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492002120.2855.3.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 03:02:00PM +0200, Johannes Berg wrote:
> On Tue, 2017-04-11 at 13:06 +0200, Daniel Borkmann wrote:
> > 
> > There are instructions to convert endianess, see __bpf_prog_run(),
> > the ALU_END_TO_BE, ALU_END_TO_LE labels for details. There's a
> > BPF_ENDIAN() macro used in the test suite and other places.
> 
> Are these hooked up to llvm intrinsics or so? If not, can I do that
> through some kind of inline asm statement?

llvm doesn't support bpf inline asm yet.

> In the samples, I only see people doing
> 
> #define _htonl __builtin_bswap32
> 
> but I'm not even completely convinced that's correct, since it assumes
> a little-endian host?

oh well, time to face the music.

In llvm backend I did:
// bswap16, bswap32, bswap64
class BSWAP<bits<32> SizeOp, string OpcodeStr, list<dag> Pattern>
...
  let op = 0xd;     // BPF_END
  let BPFSrc = 1;   // BPF_TO_BE (TODO: use BPF_TO_LE for big-endian target)
  let BPFClass = 4; // BPF_ALU

so __builtin_bswap32() is not a normal bswap. It's only doing bswap
if the compiled program running on little endian arch.
The plan was to fix it up for -march=bpfeb target (hence the comment above),
but it turned out that such __builtin_bswap32 matches perfectly to _htonl()
semantics, so I left it as-is even for -march=bpfeb.

On little endian:
ld_abs_W = *(u32*) + real bswap32
__builtin_bswap32() == bpf_to_be insn = real bswap32

On big endian:
ld_abs_W = *(u32*)
__builtin_bswap32() == bpf_to_be insn = nop

so in samples/bpf/*.c:
load_word() + _htonl()(__builtin_bswap32) has the same semantics
for both little and big endian archs, hence all networking sample code in
samples/bpf/*_kern.c works fine.

imo the whole thing is crazy ugly. llvm doesn't have 'htonl' equivalent builtin,
so builtin_bswap was the closest I could use to generate bpf_to_[bl]e insn.

To solve this properly I think we need two things:
. proper bswap32 insn in BPF
. extend llvm with bpf_to_be/le builtins
Both are not trivial amount of work.
