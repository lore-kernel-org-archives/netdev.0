From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK] Do not netlink_unicast shared packet in kernel/audit.c
Date: Tue, 18 Jan 2005 10:11:28 +1100
Message-ID: <20050117231128.GA21204@gondor.apana.org.au>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au> <41E942AF.3030202@tpack.net> <20050115183023.GA31211@gondor.apana.org.au> <41E97B1A.30205@tpack.net> <20050116080254.GA2997@gondor.apana.org.au> <20050117133640.0405d791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Cc: tommy.christensen@tpack.net, simon.roscic@chello.at, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050117133640.0405d791.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 17, 2005 at 01:36:40PM -0800, David S. Miller wrote:
> 
> I think this patch is buggy.  At least in the final hunk, we
> do this:
> 
> 	info.skb = skb;
> 	...
> 	skb = netlink_trim( ... );
> 
> Now info.skb can be pointing to a freed up skb.

Doh! Here is the corrected version.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Dave.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- /home/gondolin/herbert/src/bk/linux-2.6/net/netlink/af_netlink.c.orig	2005-01-18 10:06:45.000000000 +1100
+++ /home/gondolin/herbert/src/bk/linux-2.6/net/netlink/af_netlink.c	2005-01-18 10:09:54.000000000 +1100
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
@@ -778,6 +788,8 @@
 	struct hlist_node *node;
 	struct sock *sk;
 
+	skb = netlink_trim(skb, allocation);
+
 	info.exclude_sk = ssk;
 	info.pid = pid;
 	info.group = group;
@@ -788,8 +800,6 @@
 	info.skb = skb;
 	info.skb2 = NULL;
 
-	netlink_trim(skb, allocation);
-
 	/* While we sleep in clone, do not allow to change socket list */
 
 	netlink_lock_table();

--UlVJffcvxoiEqYs2--
