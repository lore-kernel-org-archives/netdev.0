From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] ipv6: addrconf: validate new MTU before applying it
Date: Sun, 22 Feb 2015 00:40:08 -0300
Message-ID: <20150222034008.GB6605@localhost.localdomain>
References: <60cde83b718e88aa7fcae7239a3aac704e048efc.1424456163.git.mleitner@redhat.com>
 <20150221155407.GA16874@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57974 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707AbbBVDkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2015 22:40:14 -0500
Content-Disposition: inline
In-Reply-To: <20150221155407.GA16874@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2015 at 04:54:07PM +0100, Sabrina Dubroca wrote:
> Hi,
> 
> 2015-02-20, 16:24:06 -0200, Marcelo Ricardo Leitner wrote:
> 
> > [...]
> 
> > ---
> >  net/ipv6/addrconf.c | 32 +++++++++++++++++++++++++++++++-
> >  1 file changed, 31 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index f7c8bbeb27b704c0106f714d5a0677c27d3346e0..38892228ccacfe8b67b182784723cc0b67ce572b 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -4863,6 +4863,36 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
> >  	return ret;
> >  }
> >  
> > +static
> > +int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
> > +			void __user *buffer, size_t *lenp, loff_t *ppos)
> > +{
> > +	int *valp = ctl->data;
> > +	int val = *valp;
> > +	loff_t pos = *ppos;
> > +	struct ctl_table lctl;
> > +	int ret;
> > +
> > +	/* ctl->data points to idev->cnf.mtu6
> > +	 */
> > +	lctl = *ctl;
> > +	lctl.data = &val;
> > +
> > +	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);
> > +
> > +	if (write) {
> > +		struct inet6_dev *idev = ctl->extra1;
> > +
> > +		if (val >= IPV6_MIN_MTU && val <= idev->dev->mtu)
> 
> "all" and "default" don't have an idev, so you need a check here:
> 
>     if (val >= IPV6_MIN_MTU && (!idev || val <= idev->dev->mtu))

Oh, indeed.

> > +			*valp = val;
> > +		else
> > +			ret = -EINVAL;
> > +	}
> > +	if (ret)
> > +		*ppos = pos;
> > +	return ret;
> > +}
> > +
> 
> 
> You could call proc_dointvec_minmax to do the checks.  Something like:
> 
> static
> int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
> 			void __user *buffer, size_t *lenp, loff_t *ppos)
> {
> 	struct inet6_dev *idev = ctl->extra1;
> 	int min_mtu = IPV6_MIN_MTU;
> 	struct ctl_table lctl;
> 
> 	lctl = *ctl;
> 	lctl.extra1 = &min_mtu;
> 	lctl.extra2 = idev ? &idev->dev->mtu : NULL;
> 
> 	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
> }

That's much better! Weird that I did look for a _minmax helper and
missed it :/
Thanks Sabrina, I'll send a v2 soon.

  Marcelo
