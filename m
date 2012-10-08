From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] pppoatm: don't send frames to destroyed vcc
Date: Mon, 8 Oct 2012 08:23:43 +0200
Message-ID: <20121008062343.GA28685@shrek.podlesie.net>
References: <1349525991-21462-1-git-send-email-krzysiek@podlesie.net>
 <1349530370.6524.2.camel@shinybook.infradead.org>
 <20121006153804.GA13564@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mitch@sfgoth.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121006153804.GA13564@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 06, 2012 at 05:38:04PM +0200, Krzysztof Mazur wrote:
> On Sat, Oct 06, 2012 at 02:32:50PM +0100, David Woodhouse wrote:
> > On Sat, 2012-10-06 at 14:19 +0200, Krzysztof Mazur wrote:
> > > Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
> > > indicate that vcc is not ready.
> > 
> > And what locking prevents the flag from being set immediately after we
> > check it?
> > 
> 
> nothing, this patch should fix this. 
> 
>  
>  	vcc = ATM_SKB(skb)->vcc;
> +	bh_lock_sock(sk_atm(vcc));

After bh_lock_sock() sock_owned_by_user(sk_atm(vcc)) should be checked
here. I'm sending fixed patch.

>  	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
>  			|| test_bit(ATM_VF_CLOSE, &vcc->flags)

Krzysiek
-- 
>From 3ae93335423ed0ba526dc80163ff6dfeba9bbea1 Mon Sep 17 00:00:00 2001
From: Krzysztof Mazur <krzysiek@podlesie.net>
Date: Mon, 8 Oct 2012 08:10:22 +0200
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
 net/atm/pppoatm.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 0dcb5dc..e3b2d69 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -270,6 +270,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
 	struct atm_vcc *vcc;
+	int ret;
 
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
 	pr_debug("(skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
@@ -304,17 +305,24 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 	}
 
 	vcc = ATM_SKB(skb)->vcc;
+	bh_lock_sock(sk_atm(vcc));
+	if (sock_owned_by_user(sk_atm(vcc)))
+		goto nospace_unlock_sock;
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
 			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
 			|| !test_bit(ATM_VF_READY, &vcc->flags))
-		goto nospace;
+		goto nospace_unlock_sock;
 
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
 		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
-	return ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
+	ret = ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
 	    ? DROP_PACKET : 1;
+	bh_unlock_sock(sk_atm(vcc));
+	return ret;
+nospace_unlock_sock:
+	bh_unlock_sock(sk_atm(vcc));
 nospace:
 	/*
 	 * We don't have space to send this SKB now, but we might have
-- 
1.7.12.2.2.g1c3c581
