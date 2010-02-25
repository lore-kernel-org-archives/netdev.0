From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Thu, 25 Feb 2010 08:19:50 -0500
Message-ID: <1267103990.3973.942.camel@bigi>
References: <1267017564.3973.790.camel@bigi>
	 <20100225104029.GB3927@gauss.dd.secunet.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:49430 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932469Ab0BYNT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 08:19:57 -0500
Received: by pwj8 with SMTP id 8so5646376pwj.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 05:19:56 -0800 (PST)
In-Reply-To: <20100225104029.GB3927@gauss.dd.secunet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

On Thu, 2010-02-25 at 11:40 +0100, Steffen Klassert wrote:

> 
> Do you have CONFIG_XFRM_SUB_POLICY enabled?

I tried with and without. If in xfrm_bundle_create()
after the call to xfrm_fill_dst() somewhere i "fixed" the
xdst->u.rt.fl.fl4_src, as in:
---
                err = xfrm_fill_dst(xdst, dev);
                if (err)
                        goto free_dst;
 

+               if (!xdst->u.rt.fl.fl4_src) {
+                       xdst->u.rt.fl.fl4_src = fl->fl4_src;
+		}
----

Then this worked as long as i turned off CONFIG_XFRM_SUB_POLICY.
If i use the simple patch i posted - it worked with or without
CONFIG_XFRM_SUB_POLICY turned on.

> I observed the same behaviour recently when I had CONFIG_XFRM_SUB_POLICY
> enabled. The problem in my case is, that we do a route lookup based on a flow
> with a source address of 0.0.0.0 in ip_route_output_flow() if we send a ping
> packet. Then we update the flow's source address based on the routing
> informations we got from __ip_route_output_key(). Now the actual flow does
> not match the the flow information in the routing table anymore. As a result,
> we generate a new xfrm bundle entry with every ping packet, as you pointed out.
> 

nod.

> I solved this by rerunning __ip_route_output_key() if we change the source or
> destination address of the flow (patch below). I have not send the patch so
> far because I'm not that familiar with the routing code and I'm still not sure
> whether this is the right way to fix it, so I wanted to do some further
> analysis first.
> 
> Interestingly this does not happen if CONFIG_XFRM_SUB_POLICY is disabled.
>
> When ping is started, it opens a udp socket. This triggers a xfrm_lookup()
> and a xfrm bundle entry is generated. In the standard case, the flow of the
> ping packets matching the flow informations from the bundle entry generated 
> by the opening of the udp socket, because we don't care for the upper layer
> flow information here. Unlike the standard case, if CONFIG_XFRM_SUB_POLICY is
> enabled we do upper layer information matching with flow_cache_uli_match().

Precisely - i actually was failing at exactly the same spot with
CONFIG_XFRM_SUB_POLICY with the "fix" i described above. 
"Fixing it" at that path level you have below may have bigger effect - i
cant think of one right now; but that path is hit by all outgoing
packets...

Lets hear what other people have to say - but iam beginning to feel
probably the change i posted is not so unreasonable since 0.0.0.0
is INADDR_ANY.

cheers,
jamal

