From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 4/6] ipv6: Only create RTF_CACHE routes after
 encountering pmtu exception
Date: Wed, 29 Apr 2015 11:31:59 -0700
Message-ID: <20150429183158.GA3428281@devbig242.prn2.facebook.com>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com>
 <1430255273-3045254-5-git-send-email-kafai@fb.com>
 <20150429113918.GN8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:62510 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751131AbbD2ScR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:32:17 -0400
Content-Disposition: inline
In-Reply-To: <20150429113918.GN8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 01:39:18PM +0200, Steffen Klassert wrote:
> On Tue, Apr 28, 2015 at 02:07:51PM -0700, Martin KaFai Lau wrote:
> > +		if (ip6_ins_rt(nrt6)) {
> > +			dst_destroy(&nrt6->dst);
> 
> fib6_add() does a dst_free() on error, so calling dst_destroy()
> here might result in a use after free.
Good catch.

> 
> 
> > +			return;
> > +		}
> > +
> > +		rt6 = nrt6;
> > +		dst = &nrt6->dst;
> >  	}
> > +
> > +	net = dev_net(dst->dev);
> > +	rt6->rt6i_flags |= RTF_MODIFIED;
> > +	rt6->rt6i_pmtu = mtu;
> > +	rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
> 
> The update of expires and the setting of rt6i_pmtu should
> happen before the route is inserted with ip6_ins_rt().
>
> This is because fib6_add_rt2node() tries to reuse old
> expired routes if still in the fib tree, the necessary
> informations are copied from the new route before it
> returnes -EEXIST on the new route. If your new route
> has no expires value set, fib6_add_rt2node() cleans
> expires of the old route before it resues it.
>
> Also rt6i_pmtu should be copied to the reused route in
> fib6_add_rt2node(), this should be done already in your
> first patchset. Otherwise we might use stale pmtu informations.
Good catch.

A similar race may also happen in the current ip6_pol_route()
where it may clear the RTF_EXPIRES of the existing pmtu clone.

Hence, copying rt6i_pmtu (at fib6_add_rt2node()) in the last patchset will
not be right.

I will do the copying and early-set-expire in this patchset instead.

Thanks,
---Martin
