From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Tue, 30 Oct 2012 20:52:24 +0100
Message-ID: <20121030195224.GA2153@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <1351589868.17077.34.camel@shinybook.infradead.org>
 <20121030190725.GA14044@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shrek-modem1.podlesie.net ([83.18.25.171]:48944 "EHLO
	shrek.podlesie.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755564Ab2J3Tw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 15:52:26 -0400
Content-Disposition: inline
In-Reply-To: <20121030190725.GA14044@shrek.podlesie.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 30, 2012 at 08:07:25PM +0100, Krzysztof Mazur wrote:
> On Tue, Oct 30, 2012 at 09:37:48AM +0000, David Woodhouse wrote:
> > 
> > Should we be locking it earlier, so that the atm_may_send() call is also
> > covered by the lock?
> 
> Yes, but only to protect against concurent vcc_sendmsg().
> 
> > 
> > Either way, it's an obvious improvement on what we had before ??? and even
> > if the answer to my question above is 'yes', exceeding the configured
> > size by one packet is both harmless and almost never going to happen
> > since we now limit ourselves to two packets anyway. So:
> > 
> > Acked-By: David Woodhouse <David.Woodhouse@intel.com>
> > 
> 

David, I think we should also fix the issue with sk_sndbuf < MTU,
which is described in comment in pppoatm_may_send() added by
your "pppoatm: Fix excessive queue bloat" patch.

The vcc_sendmsg() already does that.

Krzysiek

-- >8 --
Subject: [PATCH] pppoatm: fix sending packets when sk_sndbuf < MTU

Now pppoatm_send() works, when sk_sndbuf is smaller than MTU. This
issue was already pointed in comment:

	/*
	 * It's not clear that we need to bother with using atm_may_send()
	 * to check we don't exceed sk->sk_sndbuf. If userspace sets a
	 * value of sk_sndbuf which is lower than the MTU, we're going to
	 * block for ever. But the code always did that before we introduced
	 * the packet count limit, so...
	 */

The test is copied from alloc_tx() which is used by vcc_sendmsg().

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 4cc81b5..f25536b 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -306,12 +306,9 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 
 	/*
 	 * It's not clear that we need to bother with using atm_may_send()
-	 * to check we don't exceed sk->sk_sndbuf. If userspace sets a
-	 * value of sk_sndbuf which is lower than the MTU, we're going to
-	 * block for ever. But the code always did that before we introduced
-	 * the packet count limit, so...
+	 * to check we don't exceed sk->sk_sndbuf.
 	 */
-	if (!atm_may_send(vcc, skb->truesize))
+	if (sk_wmem_alloc_get(sk_atm(vcc)) && !atm_may_send(vcc, skb->truesize))
 		goto nospace_unlock_sock;
 
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
-- 
1.8.0.172.g62af90c
