From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: RPS and forwarding
Date: Mon, 26 Apr 2010 10:24:15 +0800
Message-ID: <20100426022415.GA20323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51644 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753387Ab0DZCYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 22:24:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

I'm sorry I didn't have time to jump into the RPS discussions
earlier, so in a way I'm just getting what I deserved :)

Anyway, I am specifically concerned about the possibility of
reordering of forwarded traffic.

As RPS is doing fuzzy matching, it is possible (and quite likely
if rps_sock_flow_table is small) for a forwarded flow to be hashed
to the same index as a local flow.

In that case we may end up redirecting a forwarded flow.  That
in itself is undesirable because for forwarded flows the best
solution is to stay on the ingress CPU.

What's worse is that if the local flow bounces around different
CPUs, the forwarded flow will follow it.

For a local flow RPS can guarantee original ordering (assuming
we're not doing anything weird like netfilter queueing), but
this doesn't work for forwarded flows.

Even if netif_receive_skb has completed, the forwarded packet
may still be sitting in a hardware TX queue, selected based
on the processing CPU.  If you then bounce the forwarded flow
then packets may be placed in a different hardware TX queue,
causing reordering.

BTW, selecting hardware TX queues for forwarded flows based
on the rxhash is not a good solution, as that causes cache-line
bouncing between CPUs.

Apart from not using RPS on routers, I suppose people doing
forwarding will simply have to maintain a constant RPS table,
and forgo its local redirection capabilities.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
