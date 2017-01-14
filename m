From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Sat, 14 Jan 2017 01:14:22 +0100
Message-ID: <20170114001422.GA6874@electric-eye.fr.zoreil.com>
References: <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42556 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdANAOb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:14:31 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> :
[...]
> If you can justify API is not broken by doing that, I am more than happy
> to do it, as I already stated in the latter patch:
> 
> "Of course, the logic itself is suspicious, other sendmsg()
> could handle skb allocation failure very well, not sure
> why ATM has to wait for a successful one here. But probably
> it is too late to change since the errno and behavior is
> visible to user-space. So just leave the logic as it is."
> 
> For some reason, no one reads that patch. :-/

Believe it or not but I actually read it.

It changes the logic : the original code would have been unable to
escape the while loop on memory failure. Fine, I don't mind the change.
Actually I believe that these two patches are too shy (and backport
unefficient). Instead of trying to reformulate why, here's what I have
in mind. Uncompiled, caveat emptor, etc.

I'll do a (slow) build and test on saturday's night with a pair of
iphase 5575.

diff --git a/net/atm/common.c b/net/atm/common.c
index a3ca922..67f76f3 100644
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
@@ -628,6 +623,13 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	finish_wait(sk_sleep(sk), &wait);
 	if (error)
 		goto out;
+
+	skb = alloc_skb(eff, GFP_KERNEL);
+	if (!skb)
+		goto out;
+	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	if (!copy_from_iter_full(skb_put(skb, size), size, &m->msg_iter)) {

-- 
Ueimor
