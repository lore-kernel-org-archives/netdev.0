From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Sat, 14 Jan 2017 01:24:20 +0100
Message-ID: <20170114002420.GA7036@electric-eye.fr.zoreil.com>
References: <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
 <20170114001422.GA6874@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42579 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdANAY3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:24:29 -0500
Content-Disposition: inline
In-Reply-To: <20170114001422.GA6874@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]

Now with a proper error code. Have a nice night.

diff --git a/net/atm/common.c b/net/atm/common.c
index a3ca922..e20d040 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -62,21 +62,16 @@ static void vcc_remove_socket(struct sock *sk)
 	write_unlock_irq(&vcc_sklist_lock);
 }
 
-static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
+static bool vcc_tx_ready(struct atm_vcc *vcc, unsigned int size)
 {
-	struct sk_buff *skb;
 	struct sock *sk = sk_atm(vcc);
 
 	if (sk_wmem_alloc_get(sk) && !atm_may_send(vcc, size)) {
 		pr_debug("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
 			 sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
-		return NULL;
+		return false;
 	}
-	while (!(skb = alloc_skb(size, GFP_KERNEL)))
-		schedule();
-	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
-	return skb;
+	return true;
 }
 
 static void vcc_sock_destruct(struct sock *sk)
@@ -606,7 +601,7 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	eff = (size+3) & ~3; /* align to word boundary */
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	error = 0;
-	while (!(skb = alloc_tx(vcc, eff))) {
+	while (!vcc_tx_ready(vcc, eff)) {
 		if (m->msg_flags & MSG_DONTWAIT) {
 			error = -EAGAIN;
 			break;
@@ -628,6 +623,15 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	finish_wait(sk_sleep(sk), &wait);
 	if (error)
 		goto out;
+
+	skb = alloc_skb(eff, GFP_KERNEL);
+	if (!skb) {
+		error = -ENOMEM;
+		goto out;
+	}
+	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	if (!copy_from_iter_full(skb_put(skb, size), size, &m->msg_iter)) {
