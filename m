From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter (was: Re:
	do_IRQ: stack overflow: 872..)
Date: Sun, 23 Jan 2005 13:40:19 +0100
Message-ID: <1106484019.3376.5.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
	 <1105133241.3375.16.camel@localhost.localdomain>
	 <20050118135735.4b77d38d.davem@davemloft.net>
	 <1106433059.4486.11.camel@localhost.localdomain>
	 <1106436153.20995.42.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
        dwmw2@infradead.org, ak@suse.de, snort2004@mail.ru, bridge@osdl.org,
        netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1106436153.20995.42.camel@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Op zo, 23-01-2005 te 00:22 +0100, schreef Martin Josefsson:
> On Sat, 2005-01-22 at 23:30 +0100, Bart De Schuymer wrote:
> 
> Hi Bart

Hi Martin,

> I guess you never testcompiled with CONFIG_NETFILTER_DEBUG set :)

Oops, no. I was imagining I could code that without error...
There was another compile error with CONFIG_NETFILTER_DEBUG in the patch
(skb that should have been (*pskb)) :(

> > +			if (verdict > NF_MAX_VERDICT) {
> > +				NFDEBUG("Evil return from %p(%u).\n",
> > +				        elem->hook, hook);
> > +				continue;
> > +			}
> 
> Maybe add unlikely() around the test?

OK. I added another one around another debugging if-statement.

cheers,
Bart

--- linux-2.6.11-rc1/include/linux/netfilter.h.old	2005-01-23 13:31:58.895886808 +0100
+++ linux-2.6.11-rc1/include/linux/netfilter.h	2005-01-23 13:32:02.853285192 +0100
@@ -18,7 +18,8 @@
 #define NF_STOLEN 2
 #define NF_QUEUE 3
 #define NF_REPEAT 4
-#define NF_MAX_VERDICT NF_REPEAT
+#define NF_STOP 5
+#define NF_MAX_VERDICT NF_STOP
 
 /* Generic cache responses from hook functions.
    <= 0x2000 is used for protocol-flags. */
@@ -138,23 +139,34 @@ void nf_log_packet(int pf,
 /* This is gross, but inline doesn't cut it for avoiding the function
    call in fast path: gcc doesn't inline (needs value tracking?). --RR */
 #ifdef CONFIG_NETFILTER_DEBUG
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
- nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN)
-#define NF_HOOK_THRESH nf_hook_slow
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			    \
+({int __ret = 0;							    \
+if (!nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN, &__ret))  \
+	__ret = (okfn)(skb);						    \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	    \
+({int __ret = 0;							    \
+if (!nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh, &__ret))   \
+	__ret = (okfn)(skb);						    \
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
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			     \
+({int __ret = 0;							     \
+if (list_empty(&nf_hooks[pf][hook]) ||					     \
+    !nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN, &__ret))   \
+	__ret = (okfn)(skb);						     \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	     \
+({int __ret = 0;							     \
+if (list_empty(&nf_hooks[pf][hook]) ||					     \
+    !nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh, &__ret))    \
+	__ret = (okfn)(skb);						     \
+__ret;})
 #endif
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev, struct net_device *outdev,
-		 int (*okfn)(struct sk_buff *), int thresh);
+		 int (*okfn)(struct sk_buff *), int thresh, int *ret);
 
 /* Call setsockopt() */
 int nf_setsockopt(struct sock *sk, int pf, int optval, char __user *opt, 
--- linux-2.6.11-rc1/net/core/netfilter.c.old	2005-01-23 13:31:48.980394192 +0100
+++ linux-2.6.11-rc1/net/core/netfilter.c	2005-01-23 13:32:02.856284736 +0100
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
@@ -494,50 +486,47 @@ static int nf_queue(struct sk_buff *skb,
 	return 1;
 }
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
+/* Returns 0 if okfn() needs to be executed by the caller, -EPERM otherwise.
+ * Assumes *ret==0 when called. On return, *ret!=0 when verdict==NF_DROP */
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev,
 		 struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *),
-		 int hook_thresh)
+		 int hook_thresh, int *ret)
 {
 	struct list_head *elem;
 	unsigned int verdict;
-	int ret = 0;
+	int ret2 = 0;
 
 	/* We may already have this, but read-locks nest anyway */
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
  next_hook:
-	verdict = nf_iterate(&nf_hooks[pf][hook], &skb, hook, indev,
+	verdict = nf_iterate(&nf_hooks[pf][hook], pskb, hook, indev,
 			     outdev, &elem, okfn, hook_thresh);
-	if (verdict == NF_QUEUE) {
+	if (verdict == NF_ACCEPT || verdict == NF_STOP)
+		goto unlock;
+	else if (verdict == NF_DROP) {
+		kfree_skb(*pskb);
+		*ret = -EPERM;
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
+	ret2 = -EPERM;
+unlock:
 	rcu_read_unlock();
-	return ret;
+	return ret2;
 }
 
 void nf_reinject(struct sk_buff *skb, struct nf_info *info,
--- linux-2.6.11-rc1/net/bridge/br_netfilter.c.old	2005-01-23 13:31:39.080899144 +0100
+++ linux-2.6.11-rc1/net/bridge/br_netfilter.c	2005-01-23 13:32:02.861283976 +0100
@@ -829,8 +829,7 @@ static unsigned int ip_sabotage_in(unsig
 {
 	if ((*pskb)->nf_bridge &&
 	    !((*pskb)->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
-		okfn(*pskb);
-		return NF_STOLEN;
+		return NF_STOP;
 	}
 
 	return NF_ACCEPT;
@@ -888,8 +887,7 @@ static unsigned int ip_sabotage_out(unsi
 		if (out->priv_flags & IFF_802_1Q_VLAN)
 			nf_bridge->netoutdev = (struct net_device *)out;
 #endif
-		okfn(skb);
-		return NF_STOLEN;
+		return NF_STOP;
 	}
 
 	return NF_ACCEPT;
