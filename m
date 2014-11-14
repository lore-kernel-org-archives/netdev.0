From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 16:46:18 +0100
Message-ID: <1415979978.15154.41.camel@localhost>
References: <4086c7bc9f7f9e8e2de9656c9e27ef1e71bb6423.1415973706.git.hannes@stressinduktion.org>
	 <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415978022.15154.31.camel@localhost>
	 <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:60996 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965555AbaKNPqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 10:46:21 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id F1DDC20B42
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 10:46:20 -0500 (EST)
In-Reply-To: <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-11-14 at 07:33 -0800, Eric Dumazet wrote:
> On Fri, 2014-11-14 at 16:13 +0100, Hannes Frederic Sowa wrote:
> > > 
> > > 
> > > Thats a lot of clobbers.
> > 
> > Yes, those are basically all callee-clobbered registers for the
> > particular architecture. I didn't look at the generated code for jhash
> > and crc_hash because I want this code to always be safe, independent of
> > the version and optimization levels of gcc.
> > 
> > > Alternative would be to use an assembly trampoline to save/restore them
> > > before calling __jhash2
> > 
> > This version provides the best hints on how to allocate registers to the
> > optimizers. E.g. it could avoid using callee-clobbered registers but use
> > callee-saved ones. If we build a trampoline, we need to save and reload
> > all registers all the time. This version just lets gcc decide how to do
> > that.
> > 
> > > __intel_crc4_2_hash2 can probably be written in assembly, it is quite
> > > simple.
> > 
> > Sure, but all the pre and postconditions must hold for both, jhash and
> > intel_crc4_2_hash and I don't want to rewrite jhash in assembler.
> 
> We write optimized code for current cpus.
> 
> With current generation of cpus, we have crc32 support.

__intel_crc4_2_hash(2) does already make use of crc32 instruction. I'll
have a closer look at what gcc generates.

> The fallback having to save/restore few registers, we don't care, as the
> fallback has huge cost anyway.
> 
> You don't have to write jhash() in assembler, you misunderstood me.

Ok, understood, so we only clobber the registers needed in the
crc32_hash implementation and only if we branch to jhash we save all the
other ones in a trampoline directly before jhash.

> We only have to provide a trampoline in assembler, with maybe 10
> instructions.
> 
> Then gcc will know that we do not clobber registers for the optimized
> case.

Yes, makes sense.

I would still like to see the current proposed fix getting applied and
we can do this on-top. The inline call after this patch reassembles a
direct function call, so besides the long list of clobbers, it should
still be pretty fast.

Thanks,
Hannes
