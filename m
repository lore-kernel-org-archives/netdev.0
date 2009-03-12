From: Dave Jones <davej@redhat.com>
Subject: Re: VIA velocity skb leak.
Date: Thu, 12 Mar 2009 00:56:57 -0400
Message-ID: <20090312045657.GB7132@redhat.com>
References: <20090312041352.GA6035@redhat.com> <20090311.211706.68465072.davem@davemloft.net> <20090311.212009.51140677.davem@davemloft.net> <20090312043954.GA7132@redhat.com> <49B89385.4090005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41516 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbZCLE5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 00:57:10 -0400
Content-Disposition: inline
In-Reply-To: <49B89385.4090005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 05:45:57AM +0100, Eric Dumazet wrote:

 > > @@ -1845,10 +1846,11 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 > >  	if (tdinfo->skb_dma) {
 > >  
 > > +		pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
 > 
 > I personally find better to use max(skb->len, ETH_ZLEN) macro, but YMMV ;)
 > 
 > It actually can avoid you a bug ;)
 
I prefer that too, but it makes a warning.

drivers/net/via-velocity.c:2093: warning: comparison of distinct pointer types lacks a cast

We can fix this by either casting ETH_ZLEN to an unsigned int,
or we could just do the diff below..

Or did I overlook something?

(if this looks ok, perhaps the other defines could use the same treatment?)

	Dave

The minimum frame length is never signed, define it as
such so we don't need excessive casts in comparisons.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7f3c735..c41183e 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -30,7 +30,7 @@
 
 #define ETH_ALEN	6		/* Octets in one ethernet addr	 */
 #define ETH_HLEN	14		/* Total octets in header.	 */
-#define ETH_ZLEN	60		/* Min. octets in frame sans FCS */
+#define ETH_ZLEN	60U		/* Min. octets in frame sans FCS */
 #define ETH_DATA_LEN	1500		/* Max. octets in payload	 */
 #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
 #define ETH_FCS_LEN	4		/* Octets in the FCS		 */

-- 
http://www.codemonkey.org.uk
