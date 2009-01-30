From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Fri, 30 Jan 2009 17:12:50 +1100
Message-ID: <20090130061250.GA4031@gondor.apana.org.au>
References: <1233046369.4984.5.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, mmokrejs@ribosome.natur.cuni.cz,
	vegard.nossum@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42106 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751618AbZA3GNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 01:13:08 -0500
Content-Disposition: inline
In-Reply-To: <1233046369.4984.5.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Can't you simply do the copy_from_user() before you take the sk_lock?

Well, doing the copy under sk_lock is pretty common through all
protocols.  So I think it'd be safer to change the other path,
which is doing the odd thing here, i.e., ->mmap() grabbing the
socket lock while holding mmap_sem.

In fact, it would appear that we don't really need the socket lock
in ->mmap() since it only needs to ensure that pg_vec* doesn't
get yanked or changed.  So this patch should work:

packet: Avoid lock_sock in mmap handler

As the mmap handler gets called under mmap_sem, and we may grab
mmap_sem elsewhere under the socket lock to access user data, we
should avoid grabbing the socket lock in the mmap handler.

Since the only thing we care about in the mmap handler is for
pg_vec* to be invariant, i.e., to exclude packet_set_ring, we
can achieve this by simply using sk_receive_queue.lock.

I resisted the temptation to create a new spin lock because the
mmap path isn't exactly common.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5f94db2..cac0a2b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1874,13 +1874,14 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
 		po->frame_max = (req->tp_frame_nr - 1);
 		po->head = 0;
 		po->frame_size = req->tp_frame_size;
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
 
-		order = XC(po->pg_vec_order, order);
 		req->tp_block_nr = XC(po->pg_vec_len, req->tp_block_nr);
-
 		po->pg_vec_pages = req->tp_block_size/PAGE_SIZE;
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+		order = XC(po->pg_vec_order, order);
 		po->prot_hook.func = po->pg_vec ? tpacket_rcv : packet_rcv;
+
 		skb_queue_purge(&sk->sk_receive_queue);
 #undef XC
 		if (atomic_read(&po->mapped))
@@ -1918,7 +1919,7 @@ static int packet_mmap(struct file *file, struct socket *sock, struct vm_area_st
 
 	size = vma->vm_end - vma->vm_start;
 
-	lock_sock(sk);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->pg_vec == NULL)
 		goto out;
 	if (size != po->pg_vec_len*po->pg_vec_pages*PAGE_SIZE)
@@ -1941,7 +1942,7 @@ static int packet_mmap(struct file *file, struct socket *sock, struct vm_area_st
 	err = 0;
 
 out:
-	release_sock(sk);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	return err;
 }
 #endif

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
