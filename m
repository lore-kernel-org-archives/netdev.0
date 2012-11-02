From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Fri, 2 Nov 2012 10:40:19 +0100
Message-ID: <20121102094018.GA14960@shrek.podlesie.net>
References: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
 <20121030182001.GA30373@shrek.podlesie.net>
 <20121031094147.GA1004@shrek.podlesie.net>
 <20121031160352.68353ecc@thirdoffive.cmf.nrl.navy.mil>
 <20121031220435.GA25157@shrek.podlesie.net>
 <20121101102628.6e3d3cae@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121101102628.6e3d3cae@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2012 at 10:26:28AM -0400, chas williams - CONTRACTOR wrote:
> On Wed, 31 Oct 2012 23:04:35 +0100
> Krzysztof Mazur <krzysiek@podlesie.net> wrote:
> 
> > There are also some minor potential issues in pppoatm driver:
> > 
> > 	- locking issues, but now only between pppoatm_send() and
> > 	  vcc_sendmsg() and maybe some other functions,
> 
> these have been around for a while.  i agree that something should be
> done about it.  just not sure what should be synchronizing this mess.

I think the ATM socket lock should be used. I'm sending the latest
patch that adds this locking after David Woodhouse's comments. The vcc->flags
check is now probably unnecessary.

> 
> > 	- missing check for SS_CONNECTED in pppoatm_ioctl,
> 
> in practice you will never run into this because a pvc is immediately
> put into SS_CONNECTED mode (right before the userspace open()
> returns).  however, should it check?  yes.  i dont see anything
> preventing you from running ppp on svc's.

I can confirm that the problem really exists, without connect() in pppoatm
plugin in pppd, I have seen an Oops and panic. I will send appropriate
patch.

Thanks.

Krzysiek

-- >8 --
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index f27a07a..ef19436 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -269,10 +269,23 @@ static inline int pppoatm_may_send(struct pppoatm_vcc *pvcc, int size)
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
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
+			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
+			|| !test_bit(ATM_VF_READY, &vcc->flags))
+		goto nospace;
+
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
 	case e_llc:
 		if (skb_headroom(skb) < LLC_LEN) {
@@ -285,8 +298,10 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
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
@@ -296,6 +311,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 			goto nospace;
 		break;
 	case e_autodetect:
+		bh_unlock_sock(sk_atm(vcc));
 		pr_debug("Trying to send without setting encaps!\n");
 		kfree_skb(skb);
 		return 1;
@@ -305,9 +321,12 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
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
