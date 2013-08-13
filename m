From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/3 v2] ipv6: do not disable temp_address when reaching max_address
Date: Tue, 13 Aug 2013 13:53:18 +0200
Message-ID: <20130813115318.GG27385@order.stressinduktion.org>
References: <5209E6DA.9060805@huawei.com> <20130813110521.GE27385@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48562 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757046Ab3HMLxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 07:53:19 -0400
Content-Disposition: inline
In-Reply-To: <20130813110521.GE27385@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 01:05:21PM +0200, Hannes Frederic Sowa wrote:
> On Tue, Aug 13, 2013 at 03:57:14PM +0800, Ding Tianhong wrote:
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index da4241c..72911fd 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -1134,10 +1134,27 @@ retry:
> >  	if (IS_ERR_OR_NULL(ift)) {
> >  		in6_ifa_put(ifp);
> >  		in6_dev_put(idev);
> > -		pr_info("%s: retry temporary address regeneration\n", __func__);
> > -		tmpaddr = &addr;
> > -		write_lock(&idev->lock);
> > -		goto retry;
> > +
> > +		/* According RFC4941 3.3.7:
> > +		 * If DAD indicates the address is already in use,
> > +		 * the node must generate a new randomized interface
> > +		 * identifier as described in section 3.2 above, and
> > +		 * repeat the previous steps as appropriate up to
> > +		 * TEMP_IDGEN_RETRIES times.
> > +		 * If after TEMP_IDGEN_RETRIES consecutive attempts no
> > +		 * non-unique address was generated, the node must log
> > +		 * a system error and must not attempt to generate
> > +		 * temporary address for that interface.
> > +		 * So we have to check the return err and distinguish
> > +		 * the correct retry path.
> > +		 */
> > +		if (PTR_ERR(ift) == -EEXIST) {
> > +			pr_info("%s: retry temporary address regeneration\n", __func__);
> > +			tmpaddr = &addr;
> > +			write_lock(&idev->lock);
> > +			goto retry;
> > +		} else
> > +			goto out;
> 
> Correct me if I am wrong, but the RFC referes by mentioning "in use" to
> allocated on the subnet and not in use by this host. I don't see how this
> fixes the CVE then. dad is triggered by ipv6_add_addr.

Eric already posted a proposal. It seems it lacked testing. Maybe you could
start from this?

http://permalink.gmane.org/gmane.linux.network/253518

Thanks for looking into this,

  Hannes
