From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Tue, 12 Jul 2016 08:56:56 +0300
Message-ID: <20160712085656.79f1c5fc@halley>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
	<20160705170541.3f210675@pixies>
	<20160709090020.GB2067@breakpoint.cc>
	<20160709153017.791f2607@halley>
	<20160709132230.GD2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35876 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcGLF5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 01:57:09 -0400
Received: by mail-wm0-f45.google.com with SMTP id f126so114597522wma.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 22:57:08 -0700 (PDT)
In-Reply-To: <20160709132230.GD2067@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2016 15:22:30 +0200 Florian Westphal <fw@strlen.de> wrote:
> Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> > I'd appreciate any suggestion how to determine traffic is local OTHER
> > THAN testing IPSKB_FORWARDED; If we have such a way, there wouldn't be an
> > impact on local traffic.
> >   
> > > What about setting IPCB FORWARD flag in iptunnel_xmit if
> > > skb->skb_iif != 0... instead?  

I've came up with a suggestion that does not abuse IPSKB_FORWARDED,
while properly addressing the use case (and similar ones), without
introducing the cost of entering 'skb_gso_validate_mtu' in the local
case.

How about:

@@ -220,12 +220,15 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 				struct sk_buff *skb, unsigned int mtu)
 {
 	netdev_features_t features;
+	int local_trusted_gso;
 	struct sk_buff *segs;
 	int ret = 0;
 
-	/* common case: locally created skb or seglen is <= mtu */
-	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-	      skb_gso_validate_mtu(skb, mtu))
+	local_trusted_gso = (IPCB(skb)->flags & IPSKB_FORWARDED) == 0 &&
+			    !(skb_shinfo(skb)->gso_type & SKB_GSO_DODGY);
+	/* common case: locally created skb from a trusted gso source or
+	 * seglen is <= mtu */
+	if (local_trusted_gso || skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.

This well addresses the usecase where we have gso-skb arriving from an
untrusted source, thus its gso_size is out of our control (e.g. tun/tap,
macvtap, af_packet, xen-netfront...).

Locally "gso trusted" skbs (the common case) will NOT suffer the
additional (possibly costy) call to 'skb_gso_validate_mtu'.

Also, if IPSKB_FORWARDED is true, behavior stays exactly the same.

Regards,
Shmulik
