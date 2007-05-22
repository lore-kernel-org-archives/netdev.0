From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 22 May 2007 07:34:32 -0700
Message-ID: <20070522143432.GA1938@us.ibm.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com> <20070515104453.f901e91f.akpm@linux-foundation.org> <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com> <20070516153703.GA26912@kryten> <1179363553.16195.10.camel@dyn9047017100.beaverton.ibm.com> <1179843397.3124.109.camel@drfickle.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badari Pulavarty <pbadari@us.ibm.com>,
	Anton Blanchard <anton@samba.org>,
	Hugh Dickins <hugh@veritas.com>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	sfr@canb.auug.org.au, ak@suse.de, Andy Whitcroft <andyw@uk.ibm.com>
To: Steve Fox <drfickle@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:40216 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504AbXEVOeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 10:34:36 -0400
Content-Disposition: inline
In-Reply-To: <1179843397.3124.109.camel@drfickle.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.05.2007 [09:16:37 -0500], Steve Fox wrote:
> On Wed, 2007-05-16 at 17:59 -0700, Badari Pulavarty wrote:
> 
> > Here it is ..
> > 
> > Should I do one for poll() also ?
> > 
> > Thanks,
> > Badari
> > 
> > Optimize select by a using stack space for small fd sets.
> > core_sys_select() already has this optimization. This is
> > for compat version. 
> > 
> > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > ---
> >  fs/compat.c |   17 +++++++++++------
> >  1 file changed, 11 insertions(+), 6 deletions(-)
> > 
> > Index: linux-2.6.22-rc1/fs/compat.c
> > ===================================================================
> > --- linux-2.6.22-rc1.orig/fs/compat.c	2007-05-12 18:45:56.000000000 -0700
> > +++ linux-2.6.22-rc1/fs/compat.c	2007-05-16 17:50:39.000000000 -0700
> > @@ -1544,9 +1544,10 @@ int compat_core_sys_select(int n, compat
> >  	compat_ulong_t __user *outp, compat_ulong_t __user *exp, s64 *timeout)
> >  {
> >  	fd_set_bits fds;
> > -	char *bits;
> > +	void *bits;
> >  	int size, max_fds, ret = -EINVAL;
> >  	struct fdtable *fdt;
> > +	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
> > 
> >  	if (n < 0)
> >  		goto out_nofds;
> > @@ -1564,11 +1565,14 @@ int compat_core_sys_select(int n, compat
> >  	 * since we used fdset we need to allocate memory in units of
> >  	 * long-words.
> >  	 */
> > -	ret = -ENOMEM;
> >  	size = FDS_BYTES(n);
> > -	bits = kmalloc(6 * size, GFP_KERNEL);
> > -	if (!bits)
> > -		goto out_nofds;
> > +	bits = stack_fds;
> > +	if (size > sizeof(stack_fds) / 6) {
> > +		bits = kmalloc(6 * size, GFP_KERNEL);
> > +		ret = -ENOMEM;
> > +		if (!bits)
> > +			goto out_nofds;
> > +	}
> >  	fds.in      = (unsigned long *)  bits;
> >  	fds.out     = (unsigned long *) (bits +   size);
> >  	fds.ex      = (unsigned long *) (bits + 2*size);
> > @@ -1600,7 +1604,8 @@ int compat_core_sys_select(int n, compat
> >  	    compat_set_fd_set(n, exp, fds.res_ex))
> >  		ret = -EFAULT;
> >  out:
> > -	kfree(bits);
> > +	if (bits != stack_fds)
> > +		kfree(bits);
> >  out_nofds:
> >  	return ret;
> >  }
> 
> Andy put this through a couple machines on test.kernel.org and elm3b6
> was fixed, however elm3b239 still had a boot error.
> 
> BUG: at mm/slab.c:777 __find_general_cachep()
> 
> Call Trace:
>  [<ffffffff802729c6>] __kmalloc+0xa6/0xe0
>  [<ffffffff8021d21b>] cache_k8_northbridges+0x9b/0x120

I believe this is fixed by:

http://lkml.org/lkml/2007/5/18/19

Care to stack it on top and retest?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
