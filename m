From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] ipv4: try to cache dst_entries which would cause a
 redirect
Date: Fri, 23 Jan 2015 11:54:59 +0100
Message-ID: <1422010499.505027.217827681.22B9051C@webmail.messagingengine.com>
References: <c758eb2d861f2eeb981615c3297b19443d4061d6.1421837207.git.hannes@stressinduktion.org>
 <alpine.LFD.2.11.1501212144530.2701@ja.home.ssi.bg>
 <1421930098.14431.8.camel@stressinduktion.org>
 <alpine.LFD.2.11.1501222135140.2572@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33297 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752031AbbAWKzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 05:55:03 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id C3E21207D0
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 05:54:59 -0500 (EST)
In-Reply-To: <alpine.LFD.2.11.1501222135140.2572@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Jan 22, 2015, at 20:57, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 22 Jan 2015, Hannes Frederic Sowa wrote:
> 
> > I would try to not introduce this complexity. I am currently researching
> > if this change does improve things:
> > 
> >         do_cache = res->fi && !itag;
> > -       if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
> > -           (IN_DEV_SHARED_MEDIA(out_dev) ||
> > -            inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res)))) {
> > -               flags |= RTCF_DOREDIRECT;
> > -               do_cache = false;
> > +       if (skb->protocol == htons(ETH_P_IP)) {
> > +               if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
> > +                   skb->protocol == htons(ETH_P_IP) &&
> 
> 	Above is duplicate. Or better to remove first
> and to keep this second check if flag is not cleared below...

Yes, noticed it too late.

> 
> > +                   (IN_DEV_SHARED_MEDIA(out_dev) ||
> > +                    inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
> > +                       IPCB(skb)->flags |= IPSKB_DOREDIRECT;
> > +               else if (IPCB(skb)->flags & IPSKB_DOREDIRECT)
> > +                       IPCB(skb)->flags &= ~IPSKB_DOREDIRECT;
> 
> 	It seems we do not need to clear the flag for
> ip_options_rcv_srr purposes because ip_route_input is called
> only if initial rt_type is RTN_LOCAL, so the flag should be
> unset. ip_mkroute_input/__mkroute_input is called only for
> forwarding.

Yes, that aligns pretty much with how source routing should work. :)

> 	In ip_options_rcv_srr we have RTN_LOCAL ... [RTN_LOCAL]
> and may be final RTN_UNICAST. The flag can be set and used
> only for RTN_UNICAST and that is the final ip_route_input
> called there. Lets keep it just with the 2nd ETH_P_IP check?

I agree, I don't see any other complications any more. Will send patch
soon. Thanks a lot! Also please feel free to add you SOB.

Bye,
Hannes
