From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ppc: Fix BPF JIT for ABIv2
Date: Wed, 22 Jun 2016 12:42:25 +0530
Message-ID: <20160622071225.GJ8886@naverao1-tp.localdomain>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160617130042.GO3516@indiana.gru.redhat.com>
 <20160619174914.GC8886@naverao1-tp.localdomain>
 <20160620185620.GD3516@indiana.gru.redhat.com>
 <20160621085807.GE8886@naverao1-tp.localdomain>
 <1466507748.18876.3.camel@ellerman.id.au>
 <20160621144725.GH3516@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <mpe@ellerman.id.au>,
	Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>, netdev@vger.kernel.org,
	Denis Kirjanov <kda@linux-powerpc.org>,
	linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57616 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750970AbcFVHNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 03:13:47 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5M7CibQ011351
	for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 03:13:47 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23q6qmmvmd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 03:13:47 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Wed, 22 Jun 2016 17:13:44 +1000
Content-Disposition: inline
In-Reply-To: <20160621144725.GH3516@indiana.gru.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/06/21 11:47AM, Thadeu Lima de Souza Cascardo wrote:
> On Tue, Jun 21, 2016 at 09:15:48PM +1000, Michael Ellerman wrote:
> > On Tue, 2016-06-21 at 14:28 +0530, Naveen N. Rao wrote:
> > > On 2016/06/20 03:56PM, Thadeu Lima de Souza Cascardo wrote:
> > > > On Sun, Jun 19, 2016 at 11:19:14PM +0530, Naveen N. Rao wrote:
> > > > > On 2016/06/17 10:00AM, Thadeu Lima de Souza Cascardo wrote:
> > > > > > 
> > > > > > Hi, Michael and Naveen.
> > > > > > 
> > > > > > I noticed independently that there is a problem with BPF JIT and ABIv2, and
> > > > > > worked out the patch below before I noticed Naveen's patchset and the latest
> > > > > > changes in ppc tree for a better way to check for ABI versions.
> > > > > > 
> > > > > > However, since the issue described below affect mainline and stable kernels,
> > > > > > would you consider applying it before merging your two patchsets, so that we can
> > > > > > more easily backport the fix?
> > > > > 
> > > > > Hi Cascardo,
> > > > > Given that this has been broken on ABIv2 since forever, I didn't bother 
> > > > > fixing it. But, I can see why this would be a good thing to have for 
> > > > > -stable and existing distros. However, while your patch below may fix 
> > > > > the crash you're seeing on ppc64le, it is not sufficient -- you'll need 
> > > > > changes in bpf_jit_asm.S as well.
> > > > 
> > > > Hi, Naveen.
> > > > 
> > > > Any tips on how to exercise possible issues there? Or what changes you think
> > > > would be sufficient?
> > > 
> > > The calling convention is different with ABIv2 and so we'll need changes 
> > > in bpf_slow_path_common() and sk_negative_common().
> > 
> > How big would those changes be? Do we know?

I don't think it'd be that much -- I will take a stab at this today.

> > 
> > How come no one reported this was broken previously? This is the first I've
> > heard of it being broken.
> > 
> 
> I just heard of it less than two weeks ago, and only could investigate it last
> week, when I realized mainline was also affected.
> 
> It looks like the little-endian support for classic JIT were done before the
> conversion to ABIv2. And as JIT is disabled by default, no one seems to have
> exercised it.

Yes, my thoughts too. I didn't previously think much about this as JIT 
wouldn't be enabled by default. It's interesting though that no one else 
reported this as an issue before.

> 
> > > However, rather than enabling classic JIT for ppc64le, are we better off 
> > > just disabling it?
> > > 
> > > --- a/arch/powerpc/Kconfig
> > > +++ b/arch/powerpc/Kconfig
> > > @@ -128,7 +128,7 @@ config PPC
> > >         select IRQ_FORCED_THREADING
> > >         select HAVE_RCU_TABLE_FREE if SMP
> > >         select HAVE_SYSCALL_TRACEPOINTS
> > > -       select HAVE_CBPF_JIT
> > > +       select HAVE_CBPF_JIT if CPU_BIG_ENDIAN
> > >         select HAVE_ARCH_JUMP_LABEL
> > >         select ARCH_HAVE_NMI_SAFE_CMPXCHG
> > >         select ARCH_HAS_GCOV_PROFILE_ALL
> > > 
> > > 
> > > Michael,
> > > Let me know your thoughts on whether you intend to take this patch or 
> > > Cascardo's patch for -stable before the eBPF patches. I can redo my 
> > > patches accordingly.
> > 
> > This patch sounds like the best option at the moment for something we can
> > backport. Unless the changes to fix it are minimal.

Right -- I will take a look today to see what changes would be needed.

- Naveen
