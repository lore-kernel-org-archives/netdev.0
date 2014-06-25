From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 2/2] ipv6:  Allow accepting RA from local IP
 addresses.
Date: Wed, 25 Jun 2014 10:48:39 +0200
Message-ID: <1403686119.29802.9.camel@localhost>
References: <1403644488-21709-1-git-send-email-greearb@candelatech.com>
	 <1403644488-21709-2-git-send-email-greearb@candelatech.com>
	 <53A9FA0A.70902@yoshifuji.org> <53AA3FB2.3080204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	hideaki.yoshifuji@miraclelinux.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49083 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753118AbaFYIsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 04:48:42 -0400
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 3A85F211BF
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 04:48:41 -0400 (EDT)
In-Reply-To: <53AA3FB2.3080204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-06-24 at 20:19 -0700, Ben Greear wrote:
> 
> On 06/24/2014 03:22 PM, YOSHIFUJI Hideaki wrote:
> > Hello.
> > 
> > (2014/06/25 6:14), greearb@candelatech.com wrote:
> >> From: Ben Greear <greearb@candelatech.com>
> >>
> >> This can be used in virtual networking applications, and
> >> may have other uses as well.  The option is disabled by
> >> default, so no change to current operating behaviour
> > 
> >                                    standard compliant behavior?
> 
> I've no idea.  Can you point me to the proper standard (and
> pertinent section)?
>
> >> without the user explicitly changing the behaviour.
> >>
> > 
> > Would you include your specific example?
> 
> I gave one in a response to comments on v1 of this patch.

It would be nice if you could include this into the changelog.

> Basically, I make a single OS instance look like a bunch of
> routers, bridges, and hosts.  Without use of network namespaces,
> virtual machines, or other such virtualization.  Just clever use
> of ip rules and routes.  So, I need interfaces to be able to accept
> RA from other interfaces on the same system.
> 
> http://www.spinics.net/lists/netdev/msg286764.html
> 
> 
> >> +static bool ipv6_accept_ra_local(struct inet6_dev *in6_dev, struct sk_buf *skb)
> >> +{
> >> +	/* Do not accept RA with source-addr found on local machine unless
> >> +	 * accept_ra_from_local is set to true.
> >> +	 */
> >> +	if (!in6_dev->cnf.accept_ra_from_local &&
> >> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> >> +			  NULL, 0))
> >> +		return false;
> >> +	return true;
> >> +}
> >> +
> >> +
> >>    static void ndisc_router_discovery(struct sk_buff *skb)
> >>    {
> >>    	struct ra_msg *ra_msg = (struct ra_msg *)skb_transport_header(skb);
> >> @@ -1151,10 +1164,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
> >>    		goto skip_defrtr;
> >>    	}
> >>    
> >> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> >> -			  NULL, 0)) {
> >> +	if (!ipv6_accept_ra_local(in6_dev, skb)) {
> >>    		ND_PRINTK(2, info,
> >> -			  "RA: %s, chk_addr failed for dev: %s\n",
> >> +			  "RA: %s, accept_ra_local failed for dev: %s\n",
> >>    			  __func__, skb->dev->name);
> >>    		goto skip_defrtr;
> >>    	}
> > 
> > Hmm, without global knob, I see little benefit by
> > having new helper.
> 
> A previous reviewer requested it.  I don't care either
> way, seems fine to open-code it to me.

Hmm, sorry to revert my opinion here. Passing a whole skb reference to
the helper function disqualifies this as a small helper function. ;)

I first thought about something like:

static bool ipv6_accept_ra_local(idev) {
        return in6_dev->cnf.accept_ra_from_local ||
               dev_net(idev->dev)->devconf_all.accept_ra_from_local;
}

...but without devconf_all->... test or alike it doesn't seem to make
much sense if you only process one flag, sorry.

Sorry,
Hannes
