From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in
 ip*_push_pending_frames
Date: Sun, 15 May 2005 15:24:41 -0700 (PDT)
Message-ID: <20050515.152441.106262257.davem@davemloft.net>
References: <E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
	<20050515104016.GA24344@gondor.apana.org.au>
	<20050515114121.GA4830@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050515114121.GA4830@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Sun, 15 May 2005 21:41:21 +1000

> So let's go the other way and make this an invariant:
> 
> 	For any skb on a frag_list, skb->sk must be NULL.
> 
> That is, the socket ownership always belongs to the head skb.
> It turns out that the implementation is actually pretty simple.

Yes, I was just about to inform you that when SKBs are
free'd up, only the head SKB's sk gets the destructor run
on it.

Please refer to this patch from July of 2004:

[IPV4]: Fix multicast socket hangs.

If a multicast packet gets looped back, the sending
socket can hang if a local read just sits and does
not empty its receive queue.

The problem is that when an SKB clone is freed up,
the destructor is only invoked for the head SKB when
there is a fraglist (which is created for fragmentation).

The solution is to account the fragment list SKB lengths
in the top-level head SKB, then it all works out.

Signed-off-by: David S. Miller <davem@redhat.com>

--- 1/net/ipv4/ip_output.c	2005-05-15 15:23:19 -07:00
+++ 2/net/ipv4/ip_output.c	2005-05-15 15:23:19 -07:00
@@ -498,10 +498,6 @@
 			    skb_headroom(frag) < hlen)
 			    goto slow_path;
 
-			/* Correct socket ownership. */
-			if (frag->sk == NULL && skb->sk)
-				goto slow_path;
-
 			/* Partially cloned skb? */
 			if (skb_shared(frag))
 				goto slow_path;
@@ -1113,12 +1109,10 @@
 		tail_skb = &(tmp_skb->next);
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
-#if 0 /* Logically correct, but useless work, ip_fragment() will have to undo */
 		skb->truesize += tmp_skb->truesize;
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
-#endif
 	}
 
 	/* Unless user demanded real pmtu discovery (IP_PMTUDISC_DO), we allow
