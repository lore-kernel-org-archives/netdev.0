From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 8 Apr 2010 19:47:38 +0800
Message-ID: <20100408114738.GA23329@gondor.apana.org.au>
References: <20100408.035049.177640912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:39577 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750768Ab0DHLrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:47:42 -0400
Content-Disposition: inline
In-Reply-To: <20100408.035049.177640912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 03:50:49AM -0700, David Miller wrote:
> 
> This is an old topic, but looking at traces tonight I was reminded
> about it.
> 
> dhcp clients sniff every packet in the system, the reason it does this
> and the things we can do to make it not have to do so have been
> discussed before.  Actually, I don't remember where we got with
> that and if we were able to make it such that the dhcp client
> doesn't have to do this any more.  Herbert?

The main problem is that it needs to be able to receive packets
destined to an address which is not yet a local address.  IOW,
it needs to be able to bypass the routing table and receive
non-local traffic.

> This means every packet in the machine gets sniffed.
> 
> The DHCP client at least installs a socket filter that only accepts
> the packets that the DHCP client is actually interested in.
> 
> The problem is that we clone the SKB and do some other operations
> before running the socket filter.
> 
> I was thinking, what if we simply move the sk_filter() call up to
> dev_queue_xmit_nit()?  And if sk_filter() rejects we don't even need
> to clone the packet.

Since you're talking about dev_queue_xmit_nit, I presume you're
mainly concerned about the TX direction?

FWIW the DHCP client does not need to see any packets in the TX
direction.  So if we could provide a way to only sniff RX traffic
then that would remove the need to clone for TX.  However, this
may require user-space modifications.

Another approach is to use skb_share.  At some point all protocols
were designed to handle shared skbs.

If we could tap into that then it would be an obvious way to
eliminate the clone.  To do this we'd need to audit all the
protocols to ensure that they can still handle shared packets
safely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
