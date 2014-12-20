From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: Detect drivers that reschedule NAPI and exhaust budget
Date: Sat, 20 Dec 2014 17:55:29 +1100
Message-ID: <20141220065529.GA2033@gondor.apana.org.au>
References: <20141220002327.GA31975@gondor.apana.org.au>
 <20141220003636.GA32187@gondor.apana.org.au>
 <1419039288.11185.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141219.214000.819506179607476836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52285 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaLTGzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 01:55:43 -0500
Content-Disposition: inline
In-Reply-To: <20141219.214000.819506179607476836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2014 at 09:40:00PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 19 Dec 2014 17:34:48 -0800
> 
> >> @@ -4620,7 +4620,11 @@ static void net_rx_action(struct softirq_action *h)
> >>  					 */
> >>  					napi_gro_flush(n, HZ >= 1000);
> >>  				}
> >> -				list_add_tail(&n->poll_list, &repoll);
> >> +				/* Some drivers may have called napi_schedule
> >> +				 * prior to exhausting their budget.
> >> +				 */
> >> +				if (!WARN_ON_ONCE(!list_empty(&n->poll_list)))
> >> +					list_add_tail(&n->poll_list, &repoll);
> >>  			}
> >>  		}
> >>  
> > 
> > I do not think stack trace will point to the buggy driver ?
> > 
> > IMO it would be better to print a single line with the netdev name ?
> 
> Right, we are already back from the poll routine and will just end
> up seeing the call trace leading to the software interrupt.

Good point Eric.

-- >8 --
The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
interrupt masking in NAPI) required drivers to leave poll_list
empty if the entire budget is consumed.

We have already had two broken drivers so let's add a check for
this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28..47fdc5c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4620,7 +4620,13 @@ static void net_rx_action(struct softirq_action *h)
 					 */
 					napi_gro_flush(n, HZ >= 1000);
 				}
-				list_add_tail(&n->poll_list, &repoll);
+				/* Some drivers may have called napi_schedule
+				 * prior to exhausting their budget.
+				 */
+				if (unlikely(!list_empty(&n->poll_list)))
+					pr_warn("%s: Budget exhausted after napi rescheduled\n", n->dev ? n->dev->name : "backlog");
+				else
+					list_add_tail(&n->poll_list, &repoll);
 			}
 		}
 
Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
