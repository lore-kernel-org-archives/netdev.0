From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] linkwatch: Handle jiffies wrap-around
Date: Tue, 9 May 2006 21:26:26 +1000
Message-ID: <20060509112626.GA29361@gondor.apana.org.au>
References: <200605071213.56877.stefan@loplof.de> <20060507.230727.67882043.davem@davemloft.net> <200605082028.57328.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:27152 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932277AbWEIL0d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 07:26:33 -0400
To: Stefan Rompf <stefan@loplof.de>
Content-Disposition: inline
In-Reply-To: <200605082028.57328.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 08, 2006 at 06:28:56PM +0000, Stefan Rompf wrote:
> 
> time_after() and friends can handle jiffies wrapping, however they require the 
> difference between compared times to be less than 0x80000000 jiffies (about 
> 24 days on HZ=1000) to work reliably on 32bit architectures. So if the 
> network is stable for 24 days, events generated within days 25-49 will suffer 
> a *huge* false delay.

How about something like this?

[NET] linkwatch: Handle jiffies wrap-around

The test used in the linkwatch does not handle wrap-arounds correctly.
Since the intention of the code is to eliminate bursts of messages we
can afford to delay things up to a second.  Using that fact we can
easily handle wrap-arounds by making sure that we don't delay things
by more than one second.

This is based on diagnosis and a patch by Stefan Rompf.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linkwatch-wrap.patch"

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 341de44..646937c 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -170,13 +170,13 @@
 		spin_unlock_irqrestore(&lweventlist_lock, flags);
 
 		if (!test_and_set_bit(LW_RUNNING, &linkwatch_flags)) {
-			unsigned long thisevent = jiffies;
+			unsigned long delay = linkwatch_nextevent - jiffies;
 
-			if (thisevent >= linkwatch_nextevent) {
+			/* If we wrap around we'll delay it by at most HZ. */
+			if (!delay || delay > HZ)
 				schedule_work(&linkwatch_work);
-			} else {
-				schedule_delayed_work(&linkwatch_work, linkwatch_nextevent - thisevent);
-			}
+			else
+				schedule_delayed_work(&linkwatch_work, delay);
 		}
 	}
 }

--bg08WKrSYDhXBjb5--
