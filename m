From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Wed, 31 Oct 2012 12:30:22 +0100
Message-ID: <20121031113021.GA24093@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <1351589868.17077.34.camel@shinybook.infradead.org>
 <20121030190725.GA14044@shrek.podlesie.net>
 <20121030195224.GA2153@shrek.podlesie.net>
 <1351678578.8774.8.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351678578.8774.8.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 10:16:18AM +0000, David Woodhouse wrote:
> 
> Does this break the pvcc->blocked handling that coordinates with
> pppoatm_pop()?
> 
> If we have one packet in flight, so pppoatm_may_send() permits a new one
> to be queued... but they're *large* packets to sk_wmem_alloc doesn't
> permit it. Immediately after the check, pppoatm_pop() runs and leaves
> the queue empty. We return zero, blocking the queue??? which never gets
> woken because we didn't set the BLOCKED flag and thus the tasklet never
> runs.
> 
> In fact, I think we need the BLOCKED handling for the
> sock_owned_by_user() case too? When the VCC is actually closed, I
> suppose that's not recoverable and we don't care about waking the queue
> anyway? But any time we end up returning zero from pppoatm_send(), we
> *need* to ensure that a wakeup will happen in future unless the socket
> is actually dead.
> 

Yes, original patch had also the same problem with sock_owned_by_user(),
so I just incorrectly assumed that we can do "goto nospace" after
pppoatm_may_send(), but ppooatm_may_send() must be the last test.

So I just moved all other tests earlier and and now pppoatm_may_send()
is also protected by ATM socket lock as you suggested earlier.

Krzysiek

-- >8 --
Subject: [PATCH] pppoatm: fix race condition with destroying of vcc

The pppoatm_send() calls vcc->send() and now also checks for
some vcc flags that indicate destroyed vcc without proper locking.

The vcc_sendmsg() uses lock_sock(sk). This lock is used by
vcc_release(), so vcc_destroy_socket() will not be called between
check and during ->send(). The vcc_release_async() sets ATM_VF_CLOSE,
but it should be safe to call ->send() after it, because
vcc->dev->ops->close() is not called.

The pppoatm_send() is called with BH disabled, so bh_lock_sock()
should be used instead of lock_sock().

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 0dcb5dc..eb76bd3 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -270,11 +270,22 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
 	struct atm_vcc *vcc;
+	int ret;
 
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
 	pr_debug("(skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
 	if (skb->data[0] == '\0' && (pvcc->flags & SC_COMP_PROT))
 		(void) skb_pull(skb, 1);
+
+	vcc = ATM_SKB(skb)->vcc;
+	bh_lock_sock(sk_atm(vcc));
+	if (sock_owned_by_user(sk_atm(vcc)))
+		goto nospace;
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
+			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
+			|| !test_bit(ATM_VF_READY, &vcc->flags))
+		goto nospace;
+
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
 	case e_llc:
 		if (skb_headroom(skb) < LLC_LEN) {
@@ -287,8 +298,10 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 			}
 			consume_skb(skb);
 			skb = n;
-			if (skb == NULL)
+			if (skb == NULL) {
+				bh_unlock_sock(sk_atm(vcc));
 				return DROP_PACKET;
+			}
 		} else if (!pppoatm_may_send(pvcc, skb->truesize))
 			goto nospace;
 		memcpy(skb_push(skb, LLC_LEN), pppllc, LLC_LEN);
@@ -298,24 +311,22 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 			goto nospace;
 		break;
 	case e_autodetect:
+		bh_unlock_sock(sk_atm(vcc));
 		pr_debug("Trying to send without setting encaps!\n");
 		kfree_skb(skb);
 		return 1;
 	}
 
-	vcc = ATM_SKB(skb)->vcc;
-	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
-			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
-			|| !test_bit(ATM_VF_READY, &vcc->flags))
-		goto nospace;
-
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
 		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
-	return ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
+	ret = ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
 	    ? DROP_PACKET : 1;
+	bh_unlock_sock(sk_atm(vcc));
+	return ret;
 nospace:
+	bh_unlock_sock(sk_atm(vcc));
 	/*
 	 * We don't have space to send this SKB now, but we might have
 	 * already applied SC_COMP_PROT compression, so may need to undo
-- 
1.8.0.172.g62af90c
