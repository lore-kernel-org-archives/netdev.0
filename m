From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] pppoatm: don't send frames to destroyed vcc
Date: Sat, 6 Oct 2012 17:38:04 +0200
Message-ID: <20121006153804.GA13564@shrek.podlesie.net>
References: <1349525991-21462-1-git-send-email-krzysiek@podlesie.net>
 <1349530370.6524.2.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mitch@sfgoth.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1349530370.6524.2.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 06, 2012 at 02:32:50PM +0100, David Woodhouse wrote:
> On Sat, 2012-10-06 at 14:19 +0200, Krzysztof Mazur wrote:
> > Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
> > indicate that vcc is not ready.
> 
> And what locking prevents the flag from being set immediately after we
> check it?
> 

nothing, this patch should fix this. 

The vcc_sendmsg() uses lock_sock(sk). This lock is used by
vcc_release(), so vcc_destroy_socket() will not be called between
check and during ->send(). The vcc_release_async() sets ATM_VF_CLOSE,
but it should be safe to call ->send() after it, because
vcc->dev->ops->close() is not called.

The pppoatm_send() is called with bottom halfs disabled, so
bh_lock_sock() should be used instead of lock_sock().

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 0dcb5dc..29afc68 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -270,6 +270,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
 	struct atm_vcc *vcc;
+	int ret;
 
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
 	pr_debug("(skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
@@ -304,17 +305,22 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 	}
 
 	vcc = ATM_SKB(skb)->vcc;
+	bh_lock_sock(sk_atm(vcc));
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
 			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
-			|| !test_bit(ATM_VF_READY, &vcc->flags))
+			|| !test_bit(ATM_VF_READY, &vcc->flags)) {
+		bh_unlock_sock(sk_atm(vcc));
 		goto nospace;
+	}
 
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
 	/*
 	 * We don't have space to send this SKB now, but we might have

-- 
Krzysiek
