From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Detect drivers that reschedule NAPI and exhaust budget
Date: Sat, 20 Dec 2014 11:36:36 +1100
Message-ID: <20141220003636.GA32187@gondor.apana.org.au>
References: <1418756386-6940-1-git-send-email-david.vrabel@citrix.com>
 <20141220002327.GA31975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com, "David S. Miller" <davem@davemloft.net>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36341 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbaLTAgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 19:36:42 -0500
Content-Disposition: inline
In-Reply-To: <20141220002327.GA31975@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 20, 2014 at 11:23:27AM +1100, Herbert Xu wrote:
>
> A similar bug exists in virtio_net.

In order to detect other drivers doing this we should add something
like this.

-- >8 --
The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
interrupt masking in NAPI) required drivers to leave poll_list
empty if the entire budget is consumed.

We have already had two broken drivers so let's add a check for
this.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28..88f9725 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4620,7 +4620,11 @@ static void net_rx_action(struct softirq_action *h)
 					 */
 					napi_gro_flush(n, HZ >= 1000);
 				}
-				list_add_tail(&n->poll_list, &repoll);
+				/* Some drivers may have called napi_schedule
+				 * prior to exhausting their budget.
+				 */
+				if (!WARN_ON_ONCE(!list_empty(&n->poll_list)))
+					list_add_tail(&n->poll_list, &repoll);
 			}
 		}
 
Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
