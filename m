From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] ipv6:  Allow accepting RA from local IP addresses.
Date: Mon, 23 Jun 2014 10:29:08 +0200
Message-ID: <1403512148.2368.17.camel@localhost>
References: <1403113806-13004-1-git-send-email-greearb@candelatech.com>
	  <1403113806-13004-2-git-send-email-greearb@candelatech.com>
	 <1403278836.22173.21.camel@localhost> <53A461C4.6000503@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46013 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751159AbaFWI3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 04:29:12 -0400
In-Reply-To: <53A461C4.6000503@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-06-20 at 09:31 -0700, Ben Greear wrote:
> On 06/20/2014 08:40 AM, Hannes Frederic Sowa wrote:
> > On Mi, 2014-06-18 at 10:50 -0700, greearb@candelatech.com wrote:
> >> From: Ben Greear <greearb@candelatech.com>
> >>
> >> This can be used in virtual networking applications, and
> >> may have other uses as well.  The option is disabled by
> >> default, so no change to current operating behaviour
> >> without the user explicitly changing the behaviour.
> > 
> > Can you give a specific example for its use case? I currently don't see
> > the need for such an option.
> 
> I put radvd on one veth endpoint, and use other veth endpoint to act
> as normal-ish endpoint with IPv6.
> 
> The one with radvd enables routing, using specific rules so that it
> can only route to a few other interfaces.
>
> Basically, I can emulate multi-hop routed and bridged networks, including with
> OSPF and such on a single machine without the use of network
> namespaces or virtual machines.
> 
> We use this to make network testing products, but I figure someone somewhere
> will find a different reason to want this.  As far as I know, this used to
> work w/out any kernel hacks, though I have not specifically verified
> this.  It did show up as a regression in our testing, but possibly we
> failed to test it properly years ago...

Ok, I see your point.

The forwarding knob is not always handled on a per-interface basis
because in some situations we don't know which interface we need to
process the packet on beforehand.

I don't know... In the end, it doesn't seem to cause any problems to me,
even if enabled, and you actually seem to use this feature, so should be
fine by me. Also, we already have some strange sysctls to play with.

> >> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> >> +	if (!(in6_dev->cnf.accept_ra_from_local ||
> >> +	      dev_net(in6_dev->dev)->ipv6.devconf_all->accept_ra_from_local) &&
> >> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> >>  			  NULL, 0)) {
> >>  		ND_PRINTK(2, info,
> >>  			  "RA: %s, chk_addr failed for dev: %s\n",
> >> @@ -1293,7 +1295,9 @@ skip_linkparms:
> >>  	}
> >>  
> >>  #ifdef CONFIG_IPV6_ROUTE_INFO
> >> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> >> +	if (!(in6_dev->cnf.accept_ra_from_local ||
> >> +	      dev_net(in6_dev->dev)->ipv6.devconf_all->accept_ra_from_local) &&
> >> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> >>  			  NULL, 0)) {
> >>  		ND_PRINTK(2, info,
> >>  			  "RA: %s, chk-addr (route info) is false for dev: %s\n",
> > 
> > Maybe ipv6_accept_ra_local() like ipv6_accept_ra() static local to the
> > file?
> 
> I don't have a preference either way, but will make the change if it helps
> upstream acceptance.

Just thought it would make the code a bit more readable.

> > Also I am not sure if we want to provide an devconf_all for this setting
> > at all, like we don't evaluate it for accept_ra, too. At least I
> > wouldn't do so with the current state of ipv6/conf/{all,default}.
> 
> We often have thousands of interfaces on a system, it saves effort to
> set this globally.  Note that it will not over-ride any other restraints,
> so a routed interface will still not accept RA unless additional
> existing procfs config changes are made, etc.
> 
> Both global and per-interface default to disabling this new feature,
> so I think it is safe as I have written it.

How do you handle the forwarding flag? You enable forwarding globally
and afterwards you disable it again on some interfaces? Otherwise you
won't get correct forwarding behavior.

Hm, I still don't like it to be a possible global setting (I am in favor
that it gets handled like ipv6_accept_ra). It looks much clearer to me
if it would behave like the accept_ra knob. Is it a problem to enable it
only on a per interface basis regarding races when the interfaces get
instantiated?

Bye,
Hannes
