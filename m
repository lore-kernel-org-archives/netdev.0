From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net v2] ipv4: try to cache dst_entries which would cause
 a redirect
Date: Thu, 22 Jan 2015 21:57:14 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501222135140.2572@ja.home.ssi.bg>
References: <c758eb2d861f2eeb981615c3297b19443d4061d6.1421837207.git.hannes@stressinduktion.org>  <alpine.LFD.2.11.1501212144530.2701@ja.home.ssi.bg> <1421930098.14431.8.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46779 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751777AbbAVT5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 14:57:39 -0500
In-Reply-To: <1421930098.14431.8.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 22 Jan 2015, Hannes Frederic Sowa wrote:

> I would try to not introduce this complexity. I am currently researching
> if this change does improve things:
> 
>         do_cache = res->fi && !itag;
> -       if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
> -           (IN_DEV_SHARED_MEDIA(out_dev) ||
> -            inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res)))) {
> -               flags |= RTCF_DOREDIRECT;
> -               do_cache = false;
> +       if (skb->protocol == htons(ETH_P_IP)) {
> +               if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
> +                   skb->protocol == htons(ETH_P_IP) &&

	Above is duplicate. Or better to remove first
and to keep this second check if flag is not cleared below...

> +                   (IN_DEV_SHARED_MEDIA(out_dev) ||
> +                    inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
> +                       IPCB(skb)->flags |= IPSKB_DOREDIRECT;
> +               else if (IPCB(skb)->flags & IPSKB_DOREDIRECT)
> +                       IPCB(skb)->flags &= ~IPSKB_DOREDIRECT;

	It seems we do not need to clear the flag for
ip_options_rcv_srr purposes because ip_route_input is called
only if initial rt_type is RTN_LOCAL, so the flag should be
unset. ip_mkroute_input/__mkroute_input is called only for
forwarding.

	In ip_options_rcv_srr we have RTN_LOCAL ... [RTN_LOCAL]
and may be final RTN_UNICAST. The flag can be set and used
only for RTN_UNICAST and that is the final ip_route_input
called there. Lets keep it just with the 2nd ETH_P_IP check?

Regards

--
Julian Anastasov <ja@ssi.bg>
