From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH/RFC] Reduce call chain length in netfilter (was: Re:
	do_IRQ: stack overflow: 872..)
Date: Sat, 22 Jan 2005 23:30:59 +0100
Message-ID: <1106433059.4486.11.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
	 <1105133241.3375.16.camel@localhost.localdomain>
	 <20050118135735.4b77d38d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, dwmw2@infradead.org, ak@suse.de, snort2004@mail.ru,
        bridge@osdl.org, netdev@oss.sgi.com, rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050118135735.4b77d38d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Op di, 18-01-2005 te 13:57 -0800, schreef David S. Miller:
> On Fri, 07 Jan 2005 22:27:21 +0100
> Bart De Schuymer <bdschuym@pandora.be> wrote:
> 
> > How about something like the patch below (untested but compiles)?
> > The current netfilter scheme adds one function call to the call chain
> > for each NF_HOOK and NF_HOOK_THRESH. This can be prevented by executing
> > the okfn in the calling function instead of in nf_hook_slow().
> > I didn't check if there's any code that actually uses the return value
> > from NF_HOOK. If so, this patch won't work well in its current form as -
> > EPERM is now also returned for NF_QUEUE and NF_STOLEN.
> > 
> > Another 2 calls of okfn can be postponed in br_netfilter.c by adding
> > NF_STOP, which would work like NF_STOLEN except that okfn is still
> > called.
> This NF_HOOK() change looks interesting.  Could we also do something like
> running the deeper ->hard_start_xmit() via a triggered tasklet or something
> similar?

Hi,

The patch below reduces the call chain length for netfilter hooks by
executing the okfn() inside the caller function instead of inside
nf_hook_slow(). It also reduces the size of netfilter.o from 129590 to
129550 on my system.
The return value for NF_HOOK stays the same as before: 0 except when the
verdict was NF_DROP (in that case the return value becomes -EPERM).
The target NF_STOP is added to postpone two executions of okfn() in
br_netfilter.c, it works like NF_STOLEN except that the okfn() will
still be called.
The downside is that all .o files using NF_HOOK will enlarge.
Comments are welcome.

cheers,
Bart

Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>

--- linux-2.6.1-rc1/include/linux/netfilter.h.old	2005-01-20 21:44:22.000000000 +0100
+++ linux-2.6.1-rc1/include/linux/netfilter.h	2005-01-22 22:06:14.000000000 +0100
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
+if (!nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN, &__ret);  \
+	__ret = (okfn)(skb);						    \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	    \
+({int __ret = 0;							    \
+if (!nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh, &__ret);   \
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
--- linux-2.6.1-rc1/net/core/netfilter.c.old	2005-01-20 21:38:59.000000000 +0100
+++ linux-2.6.1-rc1/net/core/netfilter.c	2005-01-22 22:08:41.000000000 +0100
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
+			if (verdict > NF_MAX_VERDICT) {
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
+	if ((*pskb)->nf_debug & (1 << hook)) {
 		printk("nf_hook: hook %i already set.\n", hook);
-		nf_dump_skb(pf, skb);
+		nf_dump_skb(pf, *pskb);
 	}
 	skb->nf_debug |= (1 << hook);
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
--- linux-2.6.1-rc1/net/bridge/br_netfilter.c.old	2005-01-20 21:43:08.000000000 +0100
+++ linux-2.6.1-rc1/net/bridge/br_netfilter.c	2005-01-22 21:20:06.000000000 +0100
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
