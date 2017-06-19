From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC net-next 2/8] xdp: add HW offload mode flag for installing
 programs
Date: Mon, 19 Jun 2017 16:24:55 -0700
Message-ID: <20170619162455.466ca63e@cakuba.netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
        <20170616235746.16337-3-jakub.kicinski@netronome.com>
        <5948566D.40803@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kafai@fb.com,
        oss-drivers@netronome.com, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:18710 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750903AbdFSXZE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 19:25:04 -0400
In-Reply-To: <5948566D.40803@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jun 2017 00:55:41 +0200, Daniel Borkmann wrote:
> On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> > Add an installation-time flag for requesting that the program
> > be installed only if it can be offloaded to HW.
> >
> > Internally new command for ndo_xdp is added, this way we avoid
> > putting checks into drivers since they all return -EINVAL on
> > an unknown command.
> >
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>  
> [...]
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index a04db264aa1c..05cec8e2cd82 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -6959,7 +6959,10 @@ static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
> >   	struct netdev_xdp xdp;
> >
> >   	memset(&xdp, 0, sizeof(xdp));
> > -	xdp.command = XDP_SETUP_PROG;
> > +	if (flags & XDP_FLAGS_HW_MODE)
> > +		xdp.command = XDP_SETUP_PROG_HW;
> > +	else
> > +		xdp.command = XDP_SETUP_PROG;
> >   	xdp.extack = extack;
> >   	xdp.flags = flags;
> >   	xdp.prog = prog;  
> 
> One thing I'm not sure I follow is that while you pass flags to the ndo
> in patch 1, add a new XDP_SETUP_PROG_HW command here in patch 2 based on
> the flags, and later on in patch 6, you don't really make use of it, but
> look at the flags anyway? Then, why adding separate XDP_SETUP_PROG_HW
> in the first place?
> 
> [patch 6:]
> @@ -3338,6 +3341,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
> 
>   	switch (xdp->command) {
>   	case XDP_SETUP_PROG:
> +	case XDP_SETUP_PROG_HW:
>   		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
>   					 xdp->extack);

We still need the flags to be able to differentiate between default/no
flags case where we load to the driver and the HW ("both"), and when
the DRV_MODE flag is set, in which case we disable the HW offload and
only load to the driver.  We have three cases:

           drv     offload
 no flag   yes    attempted
DRV_MODE   yes        no
 HW_MODE    no       yes

The XDP_SETUP_PROG_HW command is purely for convenience of drivers
without an offload.  I felt it's not appropriate to burden all drivers
with:

if (xdp->flags & XDP_FLAGS_HW_MODE)
	return -EOPNOTSUPP;

But, I do have a patch which does it, so I'm happy to drop the new
command if it's preferred.
