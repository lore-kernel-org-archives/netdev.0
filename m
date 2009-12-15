From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Tue, 15 Dec 2009 17:32:01 +1100
Message-ID: <20091215063201.GA24634@verge.net.au>
References: <20090930131109.2b3f71b8@infradead.org>
 <20091214221704.24c2665f@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754677AbZLOGcN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091214221704.24c2665f@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 14, 2009 at 10:17:04PM -0800, Arjan van de Ven wrote:
> On Wed, 30 Sep 2009 13:11:09 +0200
> Arjan van de Ven <arjan@infradead.org> wrote:
> 
> ping on the patch below.... the warning is now triggered in mainline

Hi Arjan,

could you address the comments Julian made about this?
http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/00852.html

	OK, you can add my signed-off line after changing
	'cmd > ...MAX + 1' to 'cmd > ...MAX' at both
	places, nf_sockopt_ops ranges are [optmin ... optmax)

	May be comments should be changed because:

	- i'm not the author but after ispection we do not see any holes,
	we do not want users to upgrade just for this change
	- the cmd checks are just to help code checking tools
	- the len checks should help programmers (may be BUG_ON is
	better, user does not deserve EINVAL for wrong set_arglen/get_arglen).
	Checks for *len and len are not needed.

	For example, for len checks this should be enough, before
	copy_from_user():

	in do_ip_vs_get_ctl check can be
	BUG_ON(get_arglen[GET_CMDID(cmd)] > sizeof(arg));

	in do_ip_vs_set_ctl check can be
	BUG_ON(set_arglen[SET_CMDID(cmd)] > sizeof(arg));

	Acked-by: Julian Anastasov <ja@ssi.bg>

> > >From 761a182f96b3707e1fee44e1079ba227e48745d1 Mon Sep 17 00:00:00
> > >2001
> > From: Arjan van de Ven <arjan@linux.intel.com>
> > Date: Wed, 30 Sep 2009 13:05:51 +0200
> > Subject: [PATCH] ipvs: Add boundary check on ioctl arguments
> > 
> > The ipvs code has a nifty system for doing the size of ioctl command
> > copies; it defines an array with values into which it indexes the cmd
> > to find the right length.
> > 
> > Unfortunately, the ipvs code forgot to check if the cmd was in the
> > range that the array provides, allowing for an index outside of the
> > array, which then gives a "garbage" result into the length, which
> > then gets used for copying into a stack buffer.
> > 
> > Fix this by adding sanity checks on these as well as the copy size.
> > 
> > Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c |   14 +++++++++++++-
> >  1 files changed, 13 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c
> > b/net/netfilter/ipvs/ip_vs_ctl.c index ac624e5..3c52796 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -2077,6 +2077,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd,
> > void __user *user, unsigned int len) if (!capable(CAP_NET_ADMIN))
> >  		return -EPERM;
> >  
> > +	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX + 1)
> > +		return -EINVAL;
> > +	if (len < 0 || len >  MAX_ARG_LEN)
> > +		return -EINVAL;
> >  	if (len != set_arglen[SET_CMDID(cmd)]) {
> >  		pr_err("set_ctl: len %u != %u\n",
> >  		       len, set_arglen[SET_CMDID(cmd)]);
> > @@ -2353,17 +2357,25 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd,
> > void __user *user, int *len) {
> >  	unsigned char arg[128];
> >  	int ret = 0;
> > +	unsigned int copylen;
> >  
> >  	if (!capable(CAP_NET_ADMIN))
> >  		return -EPERM;
> >  
> > +	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX + 1)
> > +		return -EINVAL;
> > +
> >  	if (*len < get_arglen[GET_CMDID(cmd)]) {
> >  		pr_err("get_ctl: len %u < %u\n",
> >  		       *len, get_arglen[GET_CMDID(cmd)]);
> >  		return -EINVAL;
> >  	}
> >  
> > -	if (copy_from_user(arg, user, get_arglen[GET_CMDID(cmd)]) !=
> > 0)
> > +	copylen = get_arglen[GET_CMDID(cmd)];
> > +	if (copylen > 128)
> > +		return -EINVAL;
> > +
> > +	if (copy_from_user(arg, user, copylen) != 0)
> >  		return -EFAULT;
> >  
> >  	if (mutex_lock_interruptible(&__ip_vs_mutex))
> 
> 
> -- 
> Arjan van de Ven 	Intel Open Source Technology Centre
> For development, discussion and tips for power savings, 
> visit http://www.lesswatts.org
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
