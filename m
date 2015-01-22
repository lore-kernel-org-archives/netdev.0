From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] ipv4: try to cache dst_entries which would cause
 a redirect
Date: Thu, 22 Jan 2015 13:34:58 +0100
Message-ID: <1421930098.14431.8.camel@stressinduktion.org>
References: <c758eb2d861f2eeb981615c3297b19443d4061d6.1421837207.git.hannes@stressinduktion.org>
	 <alpine.LFD.2.11.1501212144530.2701@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53820 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbbAVMfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:35:01 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id EA0EA20A36
	for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:35:00 -0500 (EST)
In-Reply-To: <alpine.LFD.2.11.1501212144530.2701@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mi, 2015-01-21 at 23:26 +0200, Julian Anastasov wrote:
> On Wed, 21 Jan 2015, Hannes Frederic Sowa wrote:
> 
> > Not caching dst_entries which cause redirects could be exploited by hosts
> > on the same subnet, causing a severe DoS attack. This effect aggravated
> > since commit f88649721268999 ("ipv4: fix dst race in sk_dst_get()").
> > 
> > Lookups causing redirects will be allocated with DST_NOCACHE set which
> > will force dst_release to free them via RCU.  Unfortunately waiting for
> > RCU grace period just takes too long, we can end up with >1M dst_entries
> > waiting to be released and the system will run OOM. rcuos threads cannot
> > catch up under high softirq load.
> > 
> > Attaching the flag to emit a redirect later on to the specific skb allows
> > us to cache those dst_entries thus reducing the pressure on allocation
> > and deallocation.
> > 
> > This issue was discovered by Marcelo Leitner.
> 
> 	After more thinking and after checking all
> ip_route_input places other issues popup :(
> 
> 	Another place with non-trivial handling is
> icmp_route_lookup(), only called by icmp_send(). We do
> lookup and then revert it. ip_options_rcv_srr() too.
> In this case we even can replace initial route (which
> should be to local host, without redirect flag) with
> new route (which can be with  IPSKB_DOREDIRECT).
> So, for this case we do not wrongly leave some
> IPSKB_DOREDIRECT flag.
> 
> 	But in icmp_route_lookup() should we restore the
> original IPSKB_DOREDIRECT bit when_skb_refdst is restored?
> I.e. I'm not sure if some icmp_send() caller continues to
> use the skb. For now I see only one place where we continue
> to use skb after icmp_send: ip_rt_send_redirect(). But
> it is after our check for RTCF_DOREDIRECT. Other places
> free the skb.
> 
> 	If we want to be pedantic, should we create some
> helper functions and structure to save old state? For now
> we are ok but using IPCB looks risky. For example:

I would try to not introduce this complexity. I am currently researching
if this change does improve things:

        do_cache = res->fi && !itag;
-       if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
-           (IN_DEV_SHARED_MEDIA(out_dev) ||
-            inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res)))) {
-               flags |= RTCF_DOREDIRECT;
-               do_cache = false;
+       if (skb->protocol == htons(ETH_P_IP)) {
+               if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
+                   skb->protocol == htons(ETH_P_IP) &&
+                   (IN_DEV_SHARED_MEDIA(out_dev) ||
+                    inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
+                       IPCB(skb)->flags |= IPSKB_DOREDIRECT;
+               else if (IPCB(skb)->flags & IPSKB_DOREDIRECT)
+                       IPCB(skb)->flags &= ~IPSKB_DOREDIRECT;
        }

So we do reset the IPSKB_DOREDIRECT flag on every lookup. This would
keep the ip_options_rcv_srr() lookup happy, as we only use the flag as
we would do before when keeping the last dst_entry.

icmp_route_lookup actually looks fine to me just because the skb will
never end up in ip_forward, thus the state of the flag does not matter.

What do you think?

The problem with NEIGHCB and IPCB is solved by the snippet above, too.

Thanks for the review,
Hannes
