From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/2] macvlan: Handle broadcasts in work queue
Date: Mon, 7 Apr 2014 15:53:47 +0800
Message-ID: <20140407075347.GA26461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41663 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbaDGHy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 03:54:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

These two patches fix a problem where the macvlan driver tries
to do too much work in netif_receive_skb.  In particular, for
broadcasts it'll send one skb to each macvlan interface all
within a single netif_receive_skb call.  This is way too much
for netif_rx to handle once the number of macvlans exceeds a
certain level (low thousands).  Even if netif_rx could handle
it, doing this amount of work in a single netif_receive_skb
call seriously skews the balance of the network stack.

These patches fix this by moving broadcasts to process context
so that the scheduler can deal with the fairness issue.  The
immediate problem of the netif_rx limit is handled by using
netif_rx_ni.

Similar issues exist elsewhere in our stack regarding broadcasts,
e.g., the bridge driver.  Luckily, with the bridge driver at
least we happen to have a limit of 256 ports per bridge.  Still,
doing 256 actions in one netif_receive_skb is less than ideal.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
