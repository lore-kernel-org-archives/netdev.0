From: Phil Sutter <phil@nwl.cc>
Subject: Re: NULL pointer dereference in rt6_get_cookie()
Date: Tue, 13 Oct 2015 21:26:41 +0200
Message-ID: <20151013192543.06B5021398@mail.nwl.cc>
References: <20151010132437.GB25926@orbit.nwl.cc>
 <20151013181443.GB68583@kafai-mba.local>
 <20151013191039.GA3070@base.sg13b.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48742 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbbJMTZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 15:25:45 -0400
Content-Disposition: inline
In-Reply-To: <20151013191039.GA3070@base.sg13b.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 09:10:39PM +0200, Phil Sutter wrote:
> Hi Martin,
> 
> On Tue, Oct 13, 2015 at 11:14:43AM -0700, Martin KaFai Lau wrote:
> > On Sat, Oct 10, 2015 at 03:24:37PM +0200, Phil Sutter wrote:
> > > The conditional at the start of the function evaluates true, since
> > > 'rt->rt6i_flags & RTF_PCPU' is non-zero.
> > Hi Phil, can you try the following patch and capture the dmesg output
> > to confirm the value of rt->rt6i_flags and the rt->dst.flags.
> > 
> > Thanks,
> > Martin
> > 
> > --- a/include/net/ip6_fib.h
> > +++ b/include/net/ip6_fib.h
> > @@ -167,8 +167,15 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
> > 
> >  static inline u32 rt6_get_cookie(const struct rt6_info *rt)
> >  {
> > -	if (rt->rt6i_flags & RTF_PCPU || unlikely(rt->dst.flags & DST_NOCACHE))
> > +	if (rt->rt6i_flags & RTF_PCPU || unlikely(rt->dst.flags & DST_NOCACHE)) {
> >  		rt = (struct rt6_info *)(rt->dst.from);
> > +		if (!rt)
> > +			pr_err("rt6i_dst:%pI6c/%d rt6i_gateway:%pI6c "
> > +			       "rt6i_flags:%08X dst.flags:%08X\n",
> > +			       &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
> > +			       &rt->rt6i_gateway, rt->rt6i_flags,
> > +			       rt->dst.flags);
> > +	}
> > 
> >  	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
> >  }
> 
> This code is not sane. Your pr_err() statement tries to dereference the
> NULL pointer in question. Are you interested in the originally passed
> rt6_info?

I have backed up the rt pointer at top of the function and restored it
before pr_err, this is the output:

| rt6i_dst:2001:4dd0:ff3b:13::/64 rt6i_gateway::: rt6i_flags:40000001 dst.flags:00000000

HTH, Phil
