From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 16:13:42 +0100
Message-ID: <1415978022.15154.31.camel@localhost>
References: <4086c7bc9f7f9e8e2de9656c9e27ef1e71bb6423.1415973706.git.hannes@stressinduktion.org>
	 <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36833 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965374AbaKNPNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 10:13:44 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 4523020965
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 10:13:44 -0500 (EST)
In-Reply-To: <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-11-14 at 06:50 -0800, Eric Dumazet wrote:
> On Fri, 2014-11-14 at 15:06 +0100, Hannes Frederic Sowa wrote:
> > In case the arch_fast_hash call gets inlined we need to tell gcc which
> > registers are clobbered with. Most callers where fine, as rhashtable
> > used arch_fast_hash via function pointer and thus the compiler took care
> > of that. In case of openvswitch the call got inlined and arch_fast_hash
> > touched registeres which gcc didn't know about.
> > 
> > Also don't use conditional compilation inside arguments, as this confuses
> > sparse.
> > 
> 
> Please add a 
> Fixes: 12-sha1 ("patch title")

I forgot, will send new version with tag added.

> 
> > Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> > Cc: Pravin Shelar <pshelar@nicira.com>
> > Cc: Jesse Gross <jesse@nicira.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  arch/x86/include/asm/hash.h | 18 ++++++++++++------
> >  1 file changed, 12 insertions(+), 6 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
> > index a881d78..771cee0 100644
> > --- a/arch/x86/include/asm/hash.h
> > +++ b/arch/x86/include/asm/hash.h
> > @@ -23,11 +23,14 @@ static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
> >  {
> >  	u32 hash;
> >  
> > -	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
> >  #ifdef CONFIG_X86_64
> > -			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
> > +	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
> > +			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
> > +			 : "rcx", "r8", "r9", "r10", "r11", "cc", "memory");
> >  #else
> 
> 
> 
> 
> > -			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
> > +	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
> > +			 "=a" (hash), "a" (data), "d" (len), "c" (seed)
> > +			 : "cc", "memory");
> >  #endif
> >  	return hash;
> >  }
> > @@ -36,11 +39,14 @@ static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
> >  {
> >  	u32 hash;
> >  
> > -	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
> >  #ifdef CONFIG_X86_64
> > -			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
> > +	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
> > +			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
> > +			 : "rcx", "r8", "r9", "r10", "r11", "cc", "memory");
> 
> 
> Thats a lot of clobbers.

Yes, those are basically all callee-clobbered registers for the
particular architecture. I didn't look at the generated code for jhash
and crc_hash because I want this code to always be safe, independent of
the version and optimization levels of gcc.

> Alternative would be to use an assembly trampoline to save/restore them
> before calling __jhash2

This version provides the best hints on how to allocate registers to the
optimizers. E.g. it could avoid using callee-clobbered registers but use
callee-saved ones. If we build a trampoline, we need to save and reload
all registers all the time. This version just lets gcc decide how to do
that.

> __intel_crc4_2_hash2 can probably be written in assembly, it is quite
> simple.

Sure, but all the pre and postconditions must hold for both, jhash and
intel_crc4_2_hash and I don't want to rewrite jhash in assembler.

Thanks,
Hannes
