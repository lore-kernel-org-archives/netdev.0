From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH/RFC] Reduce call chain length in netfilter (take 2)
Date: Sun, 13 Feb 2005 18:16:21 +0100
Message-ID: <1108314982.4662.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        Rusty Russell <rusty@rustcorp.com.au>,
        Patrick McHardy <kaber@trash.net>, snort2004@mail.ru, ak@suse.de,
        bridge@osdl.org, gandalf@wlug.westbo.se, dwmw2@infradead.org,
        shemminger@osdl.org
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This is a second try to fix the long chain call lengths in netfilter.
The difference with the previous patch is that I got rid of the extra
argument. I somehow didn't see it could be done without using the 'int
*ret2' argument.

A comment on the number of arguments to nf_hook_slow: I don't think the
number of arguments should be decreased. For the bridge-nf code, f.e.,
the indev argument does not equal (*pskb)->dev (this is an answer to a
question of Rusty in the old thread).

A comment on the argument change of nf_hook_slow (sk_buff * to sk_buff
**) and the bad influence on tail call optimization possibilities. From
the discussion in the old thread it became clear that no tail call is
generated for the current code. So, I don't see why this is a reason not
to accept the patch. Furthermore, if gcc ever would become able of doing
the current code with a tail call, it should be very easy to change the
code back to the original. In the meantime, I think this patch is the
best known solution.

cheers,
Bart


--- linux-2.6.11-rc3/include/linux/netfilter.h.old	2005-02-12 13:48:13.000000000 +0100
+++ linux-2.6.11-rc3/include/linux/netfilter.h	2005-02-12 17:02:48.000000000 +0100
@@ -18,7 +18,8 @@
 #define NF_STOLEN 2
 #define NF_QUEUE 3
 #define NF_REPEAT 4
-#define NF_MAX_VERDICT NF_REPEAT
+#define NF_STOP 5
+#define NF_MAX_VERDICT NF_STOP
 
 /* Generic cache responses from hook functions.
    <= 0x2000 is used for protocol-flags. */
@@ -138,21 +139,32 @@ void nf_log_packet(int pf,
 /* This is gross, but inline doesn't cut it for avoiding the function
    call in fast path: gcc doesn't inline (needs value tracking?). --RR */
 #ifdef CONFIG_NETFILTER_DEBUG
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
- nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN)
-#define NF_HOOK_THRESH nf_hook_slow
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			       \
+({int __ret;								       \
+if ((__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
+	__ret = (okfn)(skb);						       \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
+({int __ret;								       \
+if ((__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh)) == 1)  \
+	__ret = (okfn)(skb);						       \
+__ret;})
 #else
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
-(list_empty(&nf_hooks[(pf)][(hook)])					\
- ? (okfn)(skb)								\
- : nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN))
-#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	\
-(list_empty(&nf_hooks[(pf)][(hook)])					\
- ? (okfn)(skb)								\
- : nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), (thresh)))
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			       \
+({int __ret;								       \
+if (list_empty(&nf_hooks[pf][hook]) ||					       \
+    (__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
+	__ret = (okfn)(skb);						       \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
+({int __ret;								       \
+if (list_empty(&nf_hooks[pf][hook]) ||					       \
+    (__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh)) == 1)  \
+	__ret = (okfn)(skb);						       \
+__ret;})
 #endif
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev, struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *), int thresh);
 
--- linux-2.6.11-rc3/net/core/netfilter.c.old	2005-02-12 13:48:06.000000000 +0100
+++ linux-2.6.11-rc3/net/core/netfilter.c	2005-02-12 16:16:03.000000000 +0100
@@ -349,6 +349,8 @@ static unsigned int nf_iterate(struct li
 			       int (*okfn)(struct sk_buff *),
 			       int hook_thresh)
 {
+	unsigned int verdict;
+
 	/*
 	 * The caller must not block between calls to this
 	 * function because of risk of continuing from deleted element.
@@ -361,28 +363,18 @@ static unsigned int nf_iterate(struct li
 
 		/* Optimization: we don't need to hold module
                    reference here, since function can't sleep. --RR */
-		switch (elem->hook(hook, skb, indev, outdev, okfn)) {
-		case NF_QUEUE:
-			return NF_QUEUE;
-
-		case NF_STOLEN:
-			return NF_STOLEN;
-
-		case NF_DROP:
-			return NF_DROP;
-
-		case NF_REPEAT:
-			*i = (*i)->prev;
-			break;
-
+		verdict = elem->hook(hook, skb, indev, outdev, okfn);
+		if (verdict != NF_ACCEPT) {
 #ifdef CONFIG_NETFILTER_DEBUG
-		case NF_ACCEPT:
-			break;
-
-		default:
-			NFDEBUG("Evil return from %p(%u).\n", 
-				elem->hook, hook);
+			if (unlikely(verdict > NF_MAX_VERDICT)) {
+				NFDEBUG("Evil return from %p(%u).\n",
+				        elem->hook, hook);
+				continue;
+			}
 #endif
+			if (verdict != NF_REPEAT)
+				return verdict;
+			*i = (*i)->prev;
 		}
 	}
 	return NF_ACCEPT;
@@ -494,7 +486,9 @@ static int nf_queue(struct sk_buff *skb,
 	return 1;
 }
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
+/* Returns 1 if okfn() needs to be executed by the caller,
+ * -EPERM for NF_DROP, 0 otherwise. */
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev,
 		 struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *),
@@ -508,34 +502,29 @@ int nf_hook_slow(int pf, unsigned int ho
 	rcu_read_lock();
 
 #ifdef CONFIG_NETFILTER_DEBUG
-	if (skb->nf_debug & (1 << hook)) {
+	if (unlikely((*pskb)->nf_debug & (1 << hook))) {
 		printk("nf_hook: hook %i already set.\n", hook);
-		nf_dump_skb(pf, skb);
+		nf_dump_skb(pf, *pskb);
 	}
-	skb->nf_debug |= (1 << hook);
+	(*pskb)->nf_debug |= (1 << hook);
 #endif
 
 	elem = &nf_hooks[pf][hook];
- next_hook:
-	verdict = nf_iterate(&nf_hooks[pf][hook], &skb, hook, indev,
+next_hook:
+	verdict = nf_iterate(&nf_hooks[pf][hook], pskb, hook, indev,
 			     outdev, &elem, okfn, hook_thresh);
-	if (verdict == NF_QUEUE) {
+	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
+		ret = 1;
+		goto unlock;
+	} else if (verdict == NF_DROP) {
+		kfree_skb(*pskb);
+		ret = -EPERM;
+	} else if (verdict == NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
-		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn))
+		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn))
 			goto next_hook;
 	}
-
-	switch (verdict) {
-	case NF_ACCEPT:
-		ret = okfn(skb);
-		break;
-
-	case NF_DROP:
-		kfree_skb(skb);
-		ret = -EPERM;
-		break;
-	}
-
+unlock:
 	rcu_read_unlock();
 	return ret;
 }
--- linux-2.6.11-rc3/net/bridge/br_netfilter.c.old	2005-02-12 13:48:22.000000000 +0100
+++ linux-2.6.11-rc3/net/bridge/br_netfilter.c	2005-02-12 17:04:45.000000000 +0100
@@ -829,8 +829,7 @@ static unsigned int ip_sabotage_in(unsig
 {
 	if ((*pskb)->nf_bridge &&
 	    !((*pskb)->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
-		okfn(*pskb);
-		return NF_STOLEN;
+		return NF_STOP;
 	}
 
 	return NF_ACCEPT;
@@ -891,8 +890,7 @@ static unsigned int ip_sabotage_out(unsi
 		if (out->priv_flags & IFF_802_1Q_VLAN)
 			nf_bridge->netoutdev = (struct net_device *)out;
 #endif
-		okfn(skb);
-		return NF_STOLEN;
+		return NF_STOP;
 	}
 
 	return NF_ACCEPT;
