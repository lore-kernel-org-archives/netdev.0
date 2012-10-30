From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Tue, 30 Oct 2012 20:07:25 +0100
Message-ID: <20121030190725.GA14044@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <1351589868.17077.34.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351589868.17077.34.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 09:37:48AM +0000, David Woodhouse wrote:
> 
> Should we be locking it earlier, so that the atm_may_send() call is also
> covered by the lock?

Yes, but only to protect against concurent vcc_sendmsg().

> 
> Either way, it's an obvious improvement on what we had before ??? and even
> if the answer to my question above is 'yes', exceeding the configured
> size by one packet is both harmless and almost never going to happen
> since we now limit ourselves to two packets anyway. So:
> 
> Acked-By: David Woodhouse <David.Woodhouse@intel.com>
> 

I'm sending proposed patch (not tested).

Should I squash it into original patch or send it later because it's
not really important?

Thanks.

Krzysiek

-- >8 --
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index a766d96..3081834 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -214,15 +214,7 @@ error:
 
 static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
 {
-	/*
-	 * It's not clear that we need to bother with using atm_may_send()
-	 * to check we don't exceed sk->sk_sndbuf. If userspace sets a
-	 * value of sk_sndbuf which is lower than the MTU, we're going to
-	 * block for ever. But the code always did that before we introduced
-	 * the packet count limit, so...
-	 */
-	if (atm_may_send(pvcc->atmvcc, size) &&
-	    atomic_inc_not_zero_hint(&pvcc->inflight, NONE_INFLIGHT))
+	if (atomic_inc_not_zero_hint(&pvcc->inflight, NONE_INFLIGHT))
 		return 1;
 
 	/*
@@ -251,8 +243,7 @@ static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
 	 * code path that calls pppoatm_send(), and is thus going to
 	 * wait for us to finish.
 	 */
-	if (atm_may_send(pvcc->atmvcc, size) &&
-	    atomic_inc_not_zero(&pvcc->inflight))
+	if (atomic_inc_not_zero(&pvcc->inflight))
 		return 1;
 
 	return 0;
@@ -314,6 +305,16 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 			|| !test_bit(ATM_VF_READY, &vcc->flags))
 		goto nospace_unlock_sock;
 
+	/*
+	 * It's not clear that we need to bother with using atm_may_send()
+	 * to check we don't exceed sk->sk_sndbuf. If userspace sets a
+	 * value of sk_sndbuf which is lower than the MTU, we're going to
+	 * block for ever. But the code always did that before we introduced
+	 * the packet count limit, so...
+	 */
+	if (!atm_may_send(vcc, skb->truesize))
+		goto nospace_unlock_sock;
+
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
