From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Do not netlink_unicast shared packet in kernel/audit.c
Date: Sun, 16 Jan 2005 19:02:54 +1100
Message-ID: <20050116080254.GA2997@gondor.apana.org.au>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au> <41E942AF.3030202@tpack.net> <20050115183023.GA31211@gondor.apana.org.au> <41E97B1A.30205@tpack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Cc: simon.roscic@chello.at, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <41E97B1A.30205@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jan 15, 2005 at 09:20:42PM +0100, Tommy Christensen wrote:
> 
> Well, pskb_expand_head was added recently and isn't even always called.
> 
> Have a look at audit_log_drain() in kernel/audit.c. This code does:
>   skb_get
>   netlink_unicast
>   ...
>   kfree_skb
> 
> This is working just fine - until one day an over-sized skb comes along
> and hits the BUG in pskb_expand_head ...

You're always right :)
 
> Still, regarding netlink, I think the safe approach is to either handle
> or disallow shared skb's. Anything in-between could appear to be working,
> and then suddenly blow up on your production system. </paranoia>

kernel/audit.c seems to be the only caller that does this.  Strictly
speaking shared skb's are always illegal in netlink_unicast/netlink_broadcast
since we call functions such as skb_orphan which modifies the sk_buff
structure.  However, for callers such as kernel/audit.c that don't care
about those fields, it actually turns out to be harmless.

I'm hesitant to put an outright ban on it since it will force callers
such as kernel/audit.c to always do an skb_clone.

So here is a patch to handle shared skb's by cloning them if we're
going to do a pskb_expand_head.  This patch depends on the previous
one that moves skb_orphan into netlink_trim.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- linux-2.6/net/netlink/af_netlink.c.orig	2005-01-16 17:46:49.000000000 +1100
+++ linux-2.6/net/netlink/af_netlink.c	2005-01-16 19:00:51.000000000 +1100
@@ -660,7 +660,7 @@
 	sock_put(sk);
 }
 
-static inline void netlink_trim(struct sk_buff *skb, int allocation)
+static inline struct sk_buff *netlink_trim(struct sk_buff *skb, int allocation)
 {
 	int delta;
 
@@ -668,10 +668,20 @@
 
 	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
-		return;
-	if (pskb_expand_head(skb, 0, -delta, allocation))
-		return;
-	skb->truesize -= delta;
+		return skb;
+
+	if (skb_shared(skb)) {
+		struct sk_buff *nskb = skb_clone(skb, allocation);
+		if (!nskb)
+			return skb;
+		kfree_skb(skb);
+		skb = nskb;
+	}
+
+	if (!pskb_expand_head(skb, 0, -delta, allocation))
+		skb->truesize -= delta;
+
+	return skb;
 }
 
 int netlink_unicast(struct sock *ssk, struct sk_buff *skb, u32 pid, int nonblock)
@@ -680,7 +690,7 @@
 	int err;
 	long timeo;
 
-	netlink_trim(skb, gfp_any());
+	skb = netlink_trim(skb, gfp_any());
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
@@ -788,7 +798,7 @@
 	info.skb = skb;
 	info.skb2 = NULL;
 
-	netlink_trim(skb, allocation);
+	skb = netlink_trim(skb, allocation);
 
 	/* While we sleep in clone, do not allow to change socket list */
 

--cNdxnHkX5QqsyA0e--
