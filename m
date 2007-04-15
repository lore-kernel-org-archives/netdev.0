From: Paul Mackerras <paulus@samba.org>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Sun, 15 Apr 2007 10:50:37 +1000
Message-ID: <17953.30429.220756.818283@cargo.ozlabs.ibm.com>
References: <461DC70B.4000500@trash.net>
	<20070413.161635.26523891.davem@davemloft.net>
	<17953.1560.855914.274514@cargo.ozlabs.ibm.com>
	<20070414.100441.15000708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50331 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbXDOAuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2007 20:50:35 -0400
In-Reply-To: <20070414.100441.15000708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:

> Here is Patrick McHardy's patch:

So this doesn't change process_input_packet(), which treats the case
where the first byte is 0xff (PPP_ALLSTATIONS) but the second byte is
0x03 (PPP_UI) as indicating a packet with a PPP protocol number of
0xff.  Arguably that's wrong since PPP protocol 0xff is reserved, and
the RFC does envision the possibility of receiving frames where the
control field has values other than 0x03.

Therefore I think this patch is probably better.  Could people try it
out and let me know if it fixes the problem?

Paul.

diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 933e2f3..caabbc4 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -802,9 +802,9 @@ process_input_packet(struct asyncppp *ap)
 
 	/* check for address/control and protocol compression */
 	p = skb->data;
-	if (p[0] == PPP_ALLSTATIONS && p[1] == PPP_UI) {
+	if (p[0] == PPP_ALLSTATIONS) {
 		/* chop off address/control */
-		if (skb->len < 3)
+		if (p[1] != PPP_UI || skb->len < 3)
 			goto err;
 		p = skb_pull(skb, 2);
 	}
