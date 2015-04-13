From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next 10/10] ipv6: Create percpu rt6_info
Date: Mon, 13 Apr 2015 23:46:25 +0200
Message-ID: <1428961585.3872951.253274201.0C14EC83@webmail.messagingengine.com>
References: <1428717576-1040383-1-git-send-email-kafai@fb.com>
 <1428717576-1040383-11-git-send-email-kafai@fb.com>
 <20150413105944.GE8928@secunet.com>
 <20150413201617.GA2211108@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36607 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbbDMVq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 17:46:26 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 241F120F94
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 17:46:25 -0400 (EDT)
In-Reply-To: <20150413201617.GA2211108@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015, at 22:16, Martin KaFai Lau wrote:
> On Mon, Apr 13, 2015 at 12:59:44PM +0200, Steffen Klassert wrote:
> > On Fri, Apr 10, 2015 at 06:59:36PM -0700, Martin KaFai Lau wrote:
> > 
> > > diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
> > > index 2be7bd1..f6598d1 100644
> > > --- a/include/uapi/linux/ipv6_route.h
> > > +++ b/include/uapi/linux/ipv6_route.h
> > > @@ -34,6 +34,7 @@
> > >  #define RTF_PREF(pref)	((pref) << 27)
> > >  #define RTF_PREF_MASK	0x18000000
> > >  
> > > +#define RTF_PCPU	0x40000000
> > 
> > This percpu flag is something internal, should IMO not be added
> > to the uapi.
> Make sense.  Where may be the right place for it?
> 
> It seems 'uapi/linux/ipv6_route.h' is the one which has all IPv6 flags
> laid out.
> It makes modification easier since it tells us which bit is still
> available.

Actually, we expose those flags via /proc/net/ipv6_route. I would be
fine keeping it in uapi.

> How about we add a comment to 'uapi/linux/ipv6_route.h' and move the
> '#define'
> to 'linux/ipv6_route.h'?
> 
> > 
> > > @@ -1978,8 +2100,13 @@ static void ip6_rt_copy_init(struct rt6_info *rt,
> > >  static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
> > >  					   const struct in6_addr *dest)
> > >  {
> > > -	struct rt6_info *rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
> > > -					    0, ort->rt6i_table);
> > > +	struct rt6_info *rt;
> > > +
> > > +	if (ort->rt6i_flags & RTF_PCPU)
> > > +		ort = (struct rt6_info *)ort->dst.from;
> > > +
> > > +	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
> > > +			     0, ort->rt6i_table);
> > 
> > Why don't you allocate the percpu resources for cached routes?
> > I think using ip6_dst_alloc() would be better here, cached routes
> > could benefit from this too.
> Not sure if we want to open up percpu cache opportunity for RTF_CACHE
> route after receiving ICMPv6 too-big from remote peers and some of our
> machines
> have a lot of CPU (like 40), so I opt not to do it.
> If we do this, we probably need to modify the gc and its related counting
> also.

I agree that we should handle those exceptions as a kind of "slow" path.

Bye,
Hannes
