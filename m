From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Wed, 31 Oct 2012 11:22:10 +0100
Message-ID: <20121031102210.GA15077@shrek.podlesie.net>
References: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
 <20121030182001.GA30373@shrek.podlesie.net>
 <20121031094147.GA1004@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121031094147.GA1004@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 10:41:47AM +0100, Krzysztof Mazur wrote:
> 
> I think that we should add a wrapper to vcc->send(), based on
> fixed pppoatm_send(), that performs required checks and takes the ATM socket
> lock.
> 

I'm sending initial version of such wrapper and update to pppoatm.
Untested but the code is just copied from pppoatm_send.

In final series I will fix some old &sk_atm(ATM_SKB(skb)->vcc)-like
code from original version, before moving to vcc_send_bh(), but
it's just an initial idea for some comments.

Krzysiek

diff --git a/net/atm/common.c b/net/atm/common.c
index 0c0ad93..e0602d2 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -558,6 +558,32 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	return copied;
 }
 
+int vcc_send_bh(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	int ret;
+
+	bh_lock_sock(sk_atm(vcc));
+	ret = -EAGAIN;
+	if (sock_owned_by_user(sk_atm(vcc)))
+		goto out;
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
+			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
+			|| !test_bit(ATM_VF_READY, &vcc->flags))
+		goto out;
+
+	if (sk_wmem_alloc_get(sk_atm(vcc)) && !atm_may_send(vcc, skb->truesize))
+		goto out;
+
+	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
+	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
+	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
+		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
+	ret = ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb);
+out:
+	bh_unlock_sock(sk_atm(vcc));
+	return ret;
+}
+
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		size_t total_len)
 {
diff --git a/net/atm/common.h b/net/atm/common.h
index cc3c2da..3a1c340 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -15,6 +15,7 @@ int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		size_t size, int flags);
+int vcc_send_bh(struct atm_vcc *vcc, struct sk_buff *skb);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		size_t total_len);
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 5fc335a..7612f18 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -296,31 +296,10 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 	}
 
 	vcc = ATM_SKB(skb)->vcc;
-	bh_lock_sock(sk_atm(vcc));
-	if (sock_owned_by_user(sk_atm(vcc)))
-		goto nospace_unlock_sock;
-	if (test_bit(ATM_VF_RELEASED, &vcc->flags)
-			|| test_bit(ATM_VF_CLOSE, &vcc->flags)
-			|| !test_bit(ATM_VF_READY, &vcc->flags))
-		goto nospace_unlock_sock;
-
-	/*
-	 * It's not clear that we need to bother with using atm_may_send()
-	 * to check we don't exceed sk->sk_sndbuf.
-	 */
-	if (sk_wmem_alloc_get(sk_atm(vcc)) && !atm_may_send(vcc, skb->truesize))
-		goto nospace_unlock_sock;
-
-	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
-	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
-	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
-		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
-	ret = ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
-	    ? DROP_PACKET : 1;
-	bh_unlock_sock(sk_atm(vcc));
-	return ret;
-nospace_unlock_sock:
-	bh_unlock_sock(sk_atm(vcc));
+	ret = vcc_send_bh(vcc, skb);
+	if (ret == -EAGAIN)
+		goto nospace;
+	return ret ? DROP_PACKET : 1;
 nospace:
 	/*
 	 * We don't have space to send this SKB now, but we might have
