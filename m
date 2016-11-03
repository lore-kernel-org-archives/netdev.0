From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 09:42:39 +0200
Message-ID: <20161103094239.13ac8ac2@pixies>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com,
        hannes@stressinduktion.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33809 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753039AbcKCHmq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 03:42:46 -0400
Received: by mail-wm0-f68.google.com with SMTP id p190so6597707wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 00:42:45 -0700 (PDT)
In-Reply-To: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Nov 2016 16:36:17 -0400
Lance Richardson <lrichard@redhat.com> wrote:

> -	/* common case: fragmentation of segments is not allowed,
> -	 * or seglen is <= mtu
> +	/* common case: seglen is <= mtu
>  	 */
> -	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
> -	      skb_gso_validate_mtu(skb, mtu))
> +	if (skb_gso_validate_mtu(skb, mtu))
>  		return ip_finish_output2(net, sk, skb);

OK.
Resembles https://patchwork.ozlabs.org/patch/644724/ ;)

> -	if (skb_iif && !(df & htons(IP_DF))) {
> -		/* Arrived from an ingress interface, got encapsulated, with
> -		 * fragmentation of encapulating frames allowed.
> -		 * If skb is gso, the resulting encapsulated network segments
> -		 * may exceed dst mtu.
> -		 * Allow IP Fragmentation of segments.
> -		 */
> -		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
> -	}

The only potential issue I see removing this, is that the KNOWLEDGE of
the forwarding/tunnel-bridging usecases (that require a
skb_gso_validate_mtu check) is lost.

Meaning, if one decides (as claimed in the past) that locally generated
traffic must NOT go through fragmentation validation, then no one
remembers those other valid usecases (which are very specific and not
trivial to imagine) that MUST go through it; Therefore it can easily get
broken.

Maybe we can elaborate in the comment above the call to
skb_gso_validate_mtu in ip_finish_output_gso?

Best,
Shmulik
