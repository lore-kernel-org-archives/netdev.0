From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ipv6: skip __ipv6_select_ident when there is no
 skb_dst
Date: Wed, 18 Mar 2015 15:36:44 +0100
Message-ID: <20150318143644.GE1743@kria>
References: <1426686735-6129-1-git-send-email-sd@queasysnail.net>
 <550985DA.3070703@redhat.com>
 <20150318141529.GD1743@kria>
 <55098AE7.2020404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, matt@mattgrant.net.nz
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:42562 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932677AbbCROgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:36:50 -0400
Content-Disposition: inline
In-Reply-To: <55098AE7.2020404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-18, 10:25:43 -0400, Vlad Yasevich wrote:
> On 03/18/2015 10:15 AM, Sabrina Dubroca wrote:
> > 2015-03-18, 10:04:10 -0400, Vlad Yasevich wrote:
> >> On 03/18/2015 09:52 AM, Sabrina Dubroca wrote:
> >>> Matt Grant reported frequent crashes in ipv6_select_ident when
> >>> udp6_ufo_fragment is called from openvswitch on a skb that doesn't
> >>> have a dst_entry set.
> >>>
> >>> Skip __ipv6_select_ident in case of a NULL rt.
> >>>
> >>> Fixes: 0508c07f5e0c ("ipv6: Select fragment id during UFO segmentation if not set.")
> >>> Cc: Vladislav Yasevich <vyasevic@redhat.com>
> >>> Reported-by: Matt Grant <matt@mattgrant.net.nz>
> >>> Tested-by: Matt Grant <matt@mattgrant.net.nz>
> >>> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> >>> ---
> >> [...]
> >>
> >> Hi Sabrina
> >>
> >> This would result in us using id 0 which is not what we want to do.
> >>
> >> In this case, udp6_ufo_fragment() should be calling ipv6_proxy_select_ident() so that
> >> the fragment id is properly generated.
> > 
> > Hi Vlad,
> > 
> > So, instead, something like this?  Or do you want to use
> > ipv6_proxy_select_ident even when we have a skb_dst?
> > 
> 
> Yes, this is what I was thinking...
> 
> -vlad

Okay, so:

diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index ab889bb16b3c..be2c0ba82c85 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -112,11 +112,9 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
 		fptr->nexthdr = nexthdr;
 		fptr->reserved = 0;
-		if (skb_shinfo(skb)->ip6_frag_id)
-			fptr->identification = skb_shinfo(skb)->ip6_frag_id;
-		else
-			ipv6_select_ident(fptr,
-					  (struct rt6_info *)skb_dst(skb));
+		if (!skb_shinfo(skb)->ip6_frag_id)
+			ipv6_proxy_select_ident(skb);
+		fptr->identification = skb_shinfo(skb)->ip6_frag_id;
 
 		/* Fragment the skb. ipv6 header and the remaining fields of the
 		 * fragment header are updated in ipv6_gso_segment()


-- 
Sabrina
