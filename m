From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
 causes kernel oops
Date: Wed, 19 Oct 2011 03:09:14 -0400 (EDT)
Message-ID: <20111019.030914.218521668377472155.davem@davemloft.net>
References: <20111018114945.GA16359@gondor.apana.org.au>
	<1318942560.2657.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111018134537.GA17055@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: herbert@gondor.hengli.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111018134537.GA17055@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Tue, 18 Oct 2011 15:45:37 +0200

> On Tue, Oct 18, 2011 at 02:56:00PM +0200, Eric Dumazet wrote:
>>
>> I am ok by this way, but we might hit another similar problem elsewhere.
>> 
>> (igmp.c ip6_output, ...)
>> 
>> We effectively want to remove LL_ALLOCATED_SPACE() usage and obfuscate
>> code...
> 
> Here's another idea, provide a helper to do the skb allocation
> and the skb_reserve in one go.  That way this ugliness would only
> need to be done once.

Someone please test this:

--------------------
net: Fix crashes on devices which dynamically change needed headroom.

One such device is IP_GRE.

The problem is that we evaluate the device characteristics twice, once
to determine the allocation size, and once to do the skb_reserve().

Combine these into one operation using a helper function.

With help from Eric Dumazet and Herbert Xu.

Reported-by: Reported-by: Elmar Vonlanthen <evonlanthen@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..d4abb400 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -276,12 +276,22 @@ struct hh_cache {
  * LL_ALLOCATED_SPACE also takes into account the tailroom the device
  * may need.
  */
+#define LL_ALIGN(__len) (((__len)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+
+#define __LL_RESERVED_SPACE(__hard_hdr_len, __needed_headroom) \
+	LL_ALIGN((__hard_hdr_len) + (__needed_headroom))
+
 #define LL_RESERVED_SPACE(dev) \
-	((((dev)->hard_header_len+(dev)->needed_headroom)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+	__LL_RESERVED_SPACE((dev)->hard_header_len, (dev)->needed_headroom))
+
 #define LL_RESERVED_SPACE_EXTRA(dev,extra) \
-	((((dev)->hard_header_len+(dev)->needed_headroom+(extra))&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+	LL_ALIGN((dev)->hard_header_len + (dev)->needed_headroom + (extra))
+
+#define __LL_ALLOCATED_SPACE(__hard_hdr_len, __needed_headroom, __needed_tailroom) \
+	LL_ALIGN((__hard_hdr_len) + (__needed_headroom) + (__needed_tailroom))
+
 #define LL_ALLOCATED_SPACE(dev) \
-	((((dev)->hard_header_len+(dev)->needed_headroom+(dev)->needed_tailroom)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+	__LL_ALLOCATED_SPACE((dev)->hard_header_len, (dev)->needed_headroom, (dev)->needed_tailroom)
 
 struct header_ops {
 	int	(*create) (struct sk_buff *skb, struct net_device *dev,
diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..9d96995 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1103,6 +1103,11 @@ extern struct sk_buff 		*sock_alloc_send_skb(struct sock *sk,
 						     unsigned long size,
 						     int noblock,
 						     int *errcode);
+extern struct sk_buff 		*sock_alloc_send_skb_reserve(struct sock *sk,
+							     struct net_device *dev,
+							     unsigned long base_size,
+							     int noblock,
+							     int *errcode);
 extern struct sk_buff 		*sock_alloc_send_pskb(struct sock *sk,
 						      unsigned long header_len,
 						      unsigned long data_len,
diff --git a/net/core/sock.c b/net/core/sock.c
index bc745d0..9cefb72 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1586,6 +1586,26 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
+struct sk_buff *sock_alloc_send_skb_reserve(struct sock *sk, struct net_device *dev,
+					    unsigned long base_size, int noblock,
+					    int *errcode)
+{
+	unsigned int hh_len = dev->hard_header_len;
+	unsigned int needed_hroom = dev->needed_headroom;
+	unsigned int needed_troom = dev->needed_tailroom;
+	unsigned int reserve, lls;
+	struct sk_buff *skb;
+
+	lls = __LL_ALLOCATED_SPACE(hh_len, needed_hroom, needed_troom);
+	skb = sock_alloc_send_skb(sk, (base_size + lls + 15), noblock, errcode);
+	if (skb) {
+		reserve = __LL_RESERVED_SPACE(hh_len, needed_hroom);
+		skb_reserve(skb, reserve);
+	}
+	return skb;
+}
+EXPORT_SYMBOL(sock_alloc_send_skb_reserve);
+
 static void __lock_sock(struct sock *sk)
 	__releases(&sk->sk_lock.slock)
 	__acquires(&sk->sk_lock.slock)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 61714bd..dcecb97 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -335,12 +335,11 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	if (flags&MSG_PROBE)
 		goto out;
 
-	skb = sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
-				  flags & MSG_DONTWAIT, &err);
+	skb = sock_alloc_send_skb_reserve(sk, rt->dst.dev, length,
+					  flags & MSG_DONTWAIT,
+					  &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 343852e..5a8e141 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -618,12 +618,11 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	if (flags&MSG_PROBE)
 		goto out;
 
-	skb = sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
-				  flags & MSG_DONTWAIT, &err);
+	skb = sock_alloc_send_skb_reserve(sk, rt->dst.dev, length,
+					  flags & MSG_DONTWAIT,
+					  &err);
 	if (skb == NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
