From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Sun, 16 Jan 2005 00:31:46 +1100
Message-ID: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au>
References: <41E44476.20303@tpack.net>
Cc: simon.roscic@chello.at, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: tommy.christensen@tpack.net (Tommy Christensen)
In-Reply-To: <41E44476.20303@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen <tommy.christensen@tpack.net> wrote:
> 
> netlink has messed up the send buffer accounting, when trimming a skb.

You are spot on.  Dave, you were right too about checking for charged
skb's in netlink_trim.

Since the skb will be orphaned on its way to the destination anyway,
let's simply do that before the trimming.  This shouldn't lead to
skb leakage since the skb will either be charged to the destination
socket or freed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Simon, please check if this fixes your problem or not.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/netlink/af_netlink.c 1.66 vs edited =====
--- 1.66/net/netlink/af_netlink.c	2005-01-14 15:41:06 +11:00
+++ edited/net/netlink/af_netlink.c	2005-01-16 00:24:20 +11:00
@@ -629,7 +629,6 @@
 		}
 		return 1;
 	}
-	skb_orphan(skb);
 	skb_set_owner_r(skb, sk);
 	return 0;
 }
@@ -663,14 +662,11 @@
 
 static inline void netlink_trim(struct sk_buff *skb, int allocation)
 {
-	int delta = skb->end - skb->tail;
+	int delta;
 
-	/* If the packet is charged to a socket, the modification
-	 * of truesize below is illegal and will corrupt socket
-	 * buffer accounting state.
-	 */
-	BUG_ON(skb->list != NULL);
+	skb_orphan(skb);
 
+	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
 		return;
 	if (pskb_expand_head(skb, 0, -delta, allocation))
@@ -707,14 +703,12 @@
 	struct netlink_opt *nlk = nlk_sk(sk);
 #ifdef NL_EMULATE_DEV
 	if (nlk->handler) {
-		skb_orphan(skb);
 		nlk->handler(sk->sk_protocol, skb);
 		return 0;
 	} else
 #endif
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(0, &nlk->state)) {
-                skb_orphan(skb);
 		skb_set_owner_r(skb, sk);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
