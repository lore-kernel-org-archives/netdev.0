From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ppc: Fix BPF JIT for ABIv2
Date: Wed, 22 Jun 2016 20:27:25 +0530
Message-ID: <20160622145725.GL8886@naverao1-tp.localdomain>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160617130042.GO3516@indiana.gru.redhat.com>
 <20160619174914.GC8886@naverao1-tp.localdomain>
 <20160620185620.GD3516@indiana.gru.redhat.com>
 <20160621085807.GE8886@naverao1-tp.localdomain>
 <1466507748.18876.3.camel@ellerman.id.au>
 <20160621144725.GH3516@indiana.gru.redhat.com>
 <20160622071225.GJ8886@naverao1-tp.localdomain>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160622071225.GJ8886@naverao1-tp.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/22 12:42PM, Naveen N Rao wrote:
> On 2016/06/21 11:47AM, Thadeu Lima de Souza Cascardo wrote:
> > On Tue, Jun 21, 2016 at 09:15:48PM +1000, Michael Ellerman wrote:
> > > On Tue, 2016-06-21 at 14:28 +0530, Naveen N. Rao wrote:
> > > > On 2016/06/20 03:56PM, Thadeu Lima de Souza Cascardo wrote:
> > > > > On Sun, Jun 19, 2016 at 11:19:14PM +0530, Naveen N. Rao wrote:
> > > > > > On 2016/06/17 10:00AM, Thadeu Lima de Souza Cascardo wrote:
> > > > > > > 
> > > > > > > Hi, Michael and Naveen.
> > > > > > > 
> > > > > > > I noticed independently that there is a problem with BPF JIT and ABIv2, and
> > > > > > > worked out the patch below before I noticed Naveen's patchset and the latest
> > > > > > > changes in ppc tree for a better way to check for ABI versions.
> > > > > > > 
> > > > > > > However, since the issue described below affect mainline and stable kernels,
> > > > > > > would you consider applying it before merging your two patchsets, so that we can
> > > > > > > more easily backport the fix?
> > > > > > 
> > > > > > Hi Cascardo,
> > > > > > Given that this has been broken on ABIv2 since forever, I didn't bother 
> > > > > > fixing it. But, I can see why this would be a good thing to have for 
> > > > > > -stable and existing distros. However, while your patch below may fix 
> > > > > > the crash you're seeing on ppc64le, it is not sufficient -- you'll need 
> > > > > > changes in bpf_jit_asm.S as well.
> > > > > 
> > > > > Hi, Naveen.
> > > > > 
> > > > > Any tips on how to exercise possible issues there? Or what changes you think
> > > > > would be sufficient?
> > > > 
> > > > The calling convention is different with ABIv2 and so we'll need changes 
> > > > in bpf_slow_path_common() and sk_negative_common().
> > > 
> > > How big would those changes be? Do we know?

So, this does need quite a few changes:
- the skb helpers need to emit code to setup TOC and the JIT code needs 
  to be updated to setup r12.
- the slow path code needs to be changed to store r3 elsewhere on ABIv2
- the above also means we need to change the stack macros with the 
  proper ABIv2 values
- the little endian support isn't complete as well -- some of the skb 
  helpers are not using byte swap instructions.

As such, I think we should just disable classic JIT on ppc64le.


- Naveen
 
