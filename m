From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix checksum validation
Date: Wed, 13 Jun 2012 16:10:05 +0200
Message-ID: <1339596605.22704.363.camel@edumazet-glaptop>
References: <1339581004.22704.340.camel@edumazet-glaptop>
	 <1339594957.13000.7.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Robert Evans <evansr@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52991 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2FMOKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 10:10:12 -0400
Received: by eaak11 with SMTP id k11so221265eaa.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 07:10:10 -0700 (PDT)
In-Reply-To: <1339594957.13000.7.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 16:42 +0300, Eilon Greenstein wrote:

> So what you are saying is that the indication that the checksum is valid
> is interpreted as the encapsulated checksum and not just the IP
> header... This was not the intention of this code, it was meant to
> indicate that the IP header is valid.
> 

IP header is always checked by our stack.

Its so fast that there is no point spending a bit in skb, and testing
this bit.

Yes, CHECKSUM_UNNECESSARY really means everything was checked up to L4

> I must admit that the code looks much better with this change. The only
> down side is that there is no longer IP checksum offload for pure IP
> packets, but that's negligible. The only thing that bothers me is that
> there is no way to indicate anything about the encapsulated packet
> separately from the outer header. Is that the way we want to keep it?

Some NIC allow for csum L3 offloading, providing the 16bit csum.

We then can :

skb->csum = csum;
skb->ip_summed = CHECKSUM_COMPLETE;

Check drivers/net/ethernet/ibm/ehea/ehea_main.c,
drivers/net/ethernet/marvell/skge.c ,
drivers/net/ethernet/marvell/sky2.c , ... for examples.


When a layer is removed(pulled), we can use skb_postpull_rcsum() and
friends (check net/ipv4/ip_gre.c for example) to keep skb->csum up2date.


If bnx2x provides this csum (for non TCP/UCP packets or fragments), you
could fallback to this CHECKSUM_COMPLETE stuff.
