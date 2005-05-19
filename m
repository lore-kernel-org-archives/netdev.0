From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in
 ip*_push_pending_frames
Date: Thu, 19 May 2005 12:35:30 -0700 (PDT)
Message-ID: <20050519.123530.55508893.davem@davemloft.net>
References: <20050515235913.GA20242@gondor.apana.org.au>
	<20050515.173944.122590923.davem@davemloft.net>
	<20050516010058.GA20704@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050516010058.GA20704@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 May 2005 11:00:58 +1000

[ For other readers, Herbert and I are discussing ip_ct_gather_frags(). ]

> On Sun, May 15, 2005 at 05:39:44PM -0700, David S. Miller wrote:
> > 
> > This code should therefore just skb_orphan(), and nothing
> > more.  Right?
> 
> Ideally we should move the ownership to the head skb here as well.
> However, doing this would cause havoc when you have nasty users
> sending fragments from two different sockets :)
> 
> So let's stick with just the skb_orphan.

Ok, based upon this I am adding the following patch to my
tree.  Thanks.

--- 1/net/ipv4/netfilter/ip_conntrack_core.c.~1~	2005-05-18 22:45:26.000000000 -0700
+++ 2/net/ipv4/netfilter/ip_conntrack_core.c	2005-05-19 12:32:26.000000000 -0700
@@ -940,37 +940,25 @@
 struct sk_buff *
 ip_ct_gather_frags(struct sk_buff *skb, u_int32_t user)
 {
-	struct sock *sk = skb->sk;
 #ifdef CONFIG_NETFILTER_DEBUG
 	unsigned int olddebug = skb->nf_debug;
 #endif
 
-	if (sk) {
-		sock_hold(sk);
-		skb_orphan(skb);
-	}
+	skb_orphan(skb);
 
 	local_bh_disable(); 
 	skb = ip_defrag(skb, user);
 	local_bh_enable();
 
-	if (!skb) {
-		if (sk)
-			sock_put(sk);
-		return skb;
-	}
-
-	if (sk) {
-		skb_set_owner_w(skb, sk);
-		sock_put(sk);
-	}
-
-	ip_send_check(skb->nh.iph);
-	skb->nfcache |= NFC_ALTERED;
+	if (skb) {
+		ip_send_check(skb->nh.iph);
+		skb->nfcache |= NFC_ALTERED;
 #ifdef CONFIG_NETFILTER_DEBUG
-	/* Packet path as if nothing had happened. */
-	skb->nf_debug = olddebug;
+		/* Packet path as if nothing had happened. */
+		skb->nf_debug = olddebug;
 #endif
+	}
+
 	return skb;
 }
 
