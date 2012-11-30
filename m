From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 04/17] pppoatm: take ATM socket lock in pppoatm_send()
Date: Fri, 30 Nov 2012 00:35:23 +0000
Message-ID: <1354235736-26833-5-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37533 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

The pppoatm_send() does not take any lock that will prevent concurrent
vcc_sendmsg(). This causes two problems:

	- there is no locking between checking the send queue size
	  with atm_may_send() and incrementing sk_wmem_alloc,
	  and the real queue size can be a little higher than sk_sndbuf

	- the vcc->sendmsg() can be called concurrently. I'm not sure
	  if it's allowed. Some drivers (eni, nicstar, ...) seem
	  to assume it will never happen.

Now pppoatm_send() takes ATM socket lock, the same that is used
in vcc_sendmsg() and other ATM socket functions. The pppoatm_send()
is called with BH disabled, so bh_lock_sock() is used instead
of lock_sock().

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Cc: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 net/atm/pppoatm.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index b23c672..c4a57bc 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -272,10 +272,19 @@ static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
 static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
+	struct atm_vcc *vcc;
+	int ret;
+
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
 	pr_debug("(skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
 	if (skb->data[0] == '\0' && (pvcc->flags & SC_COMP_PROT))
 		(void) skb_pull(skb, 1);
+
+	vcc = ATM_SKB(skb)->vcc;
+	bh_lock_sock(sk_atm(vcc));
+	if (sock_owned_by_user(sk_atm(vcc)))
+		goto nospace;
+
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
 	case e_llc:
 		if (skb_headroom(skb) < LLC_LEN) {
@@ -288,8 +297,10 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
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
@@ -299,6 +310,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 			goto nospace;
 		break;
 	case e_autodetect:
+		bh_unlock_sock(sk_atm(vcc));
 		pr_debug("Trying to send without setting encaps!\n");
 		kfree_skb(skb);
 		return 1;
@@ -308,9 +320,12 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
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
1.8.0
