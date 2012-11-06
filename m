From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v3 5/7] pppoatm: take ATM socket lock in pppoatm_send()
Date: Tue,  6 Nov 2012 23:17:00 +0100
Message-ID: <1352240222-363-6-git-send-email-krzysiek@podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Cc: linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Woodhouse <David.Woodhouse@intel.com>,
	davem@davemloft.net, Krzysztof Mazur <krzysiek@podlesie.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
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
1.8.0.233.g54991f2
