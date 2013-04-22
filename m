From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v5 4/5] vxlan: add ipv6 support
Date: Mon, 22 Apr 2013 08:43:48 -0400
Message-ID: <OF17DE15D2.A00F3652-ON85257B55.00422ADC-85257B55.0045EC98@us.ibm.com>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com> <1366554192-27887-5-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:38646 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab3DVMuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 08:50:50 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 22 Apr 2013 06:50:39 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 4EC9B3E4006A
	for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 06:43:50 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3MChrY3127082
	for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 06:43:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3MCho4S028030
	for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 06:43:52 -0600
In-Reply-To: <1366554192-27887-5-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> wrote on 04/21/2013 10:23:11 AM:
          vxlan_encap_bypass(skb, vxlan, vxlan);
> @@ -975,60 +1141,115 @@ static netdev_tx_t vxlan_xmit_one(struct 
> sk_buff *skb, struct net_device *dev,
>        skb->encapsulation = 1;
>     }
> 
> -   /* Need space for new headers (invalidates iph ptr) */
> -   if (skb_cow_head(skb, VXLAN_HEADROOM))
> -      goto drop;
> +   ttl = vxlan->ttl;
> +   tos = vxlan->tos;
> +   if (dst->sa.sa_family == AF_INET) {
> +      /* Need space for new headers (invalidates iph ptr) */
> +      if (skb_cow_head(skb, VXLAN_HEADROOM))
> +         goto drop;
> 
> -   old_iph = ip_hdr(skb);
> +      old_iph = ip_hdr(skb);
> +      if (!ttl && IN_MULTICAST(ntohl(dst->sin.sin_addr.s_addr)))
> +         ttl = 1;

        Why not use vxlan_addr_multicast() and place above as common
code for both v4 and v6?

        This has other deficiencies:
1) No L3 miss support for v6
2) No link-local handling for v6
3) No neighbor-discovery reduction (like arp_reduce()) for v6
4) code simplifications/cleanup as described by Bjorn Mork

        But I think those can be done in future patches. It might
be appropriate to prohibit link-local addresses with EADDRNOTAVAIL
until LL support is there, since I expect you'll get silent drops
with the existing code and an LL addr destination.
        So, I'll go ahead and say:

Acked-by: David L Stevens <dlstevens@us.ibm.com>

and do some follow-up patches for the above if nobody else does first.

                                                                +-DLS
