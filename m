From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: do_IRQ: stack overflow: 872..
Date: Fri, 07 Jan 2005 22:27:21 +0100
Message-ID: <1105133241.3375.16.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <ak@suse.de>,
        Crazy AMD K7 <snort2004@mail.ru>, bridge@osdl.org, netdev@oss.sgi.com,
        Rusty Russell <rusty@rustcorp.com.au>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050107100017.454ddadc@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Op vr, 07-01-2005 te 10:00 -0800, schreef Stephen Hemminger:
> On Fri, 07 Jan 2005 17:05:59 +0000
> David Woodhouse <dwmw2@infradead.org> wrote:
> > I don't think it's recursing -- I think the stack trace is just a bit
> > noisy. The problem is that the bridge code, especially with br_netfilter
> > in the equation, is implicated in code paths which are just _too_ deep.
> > This happens when you're bridging packets received in an interrupt while
> > you were deep in journalling code, and it's also been seen with a call
> > trace something like nfs->sunrpc->ip->bridge->br_netfilter.
> 
> Sounds like an argument for interrupt stacks.
> 
> > One option might be to make br_dev_xmit() just queue the packet rather
> > than trying to deliver it to all the slave devices immediately. Then the
> > actual retransmission can be handled from a context where we're _not_
> > short of stack; perhaps from a dedicated kernel thread. 
> 
> Probably the solution would be to handle it in the filter code
> that way if we are not filtering, we can use the interrupt path,
> but if filtering just defer to a safer context (like soft irq).

How about something like the patch below (untested but compiles)?
The current netfilter scheme adds one function call to the call chain
for each NF_HOOK and NF_HOOK_THRESH. This can be prevented by executing
the okfn in the calling function instead of in nf_hook_slow().
I didn't check if there's any code that actually uses the return value
from NF_HOOK. If so, this patch won't work well in its current form as -
EPERM is now also returned for NF_QUEUE and NF_STOLEN.

Another 2 calls of okfn can be postponed in br_netfilter.c by adding
NF_STOP, which would work like NF_STOLEN except that okfn is still
called. But I'd first like to get the IPv4/IPv6 fix for br_netfilter.c
accepted (see another thread on netdev).

cheers,
Bart

--- linux-2.6.10/include/linux/netfilter.h.old	2005-01-07 20:41:30.000000000 +0100
+++ linux-2.6.10/include/linux/netfilter.h	2005-01-07 22:04:57.096626176 +0100
@@ -138,21 +138,32 @@ void nf_log_packet(int pf,
 /* This is gross, but inline doesn't cut it for avoiding the function
    call in fast path: gcc doesn't inline (needs value tracking?). --RR */
 #ifdef CONFIG_NETFILTER_DEBUG
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
- nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN)
-#define NF_HOOK_THRESH nf_hook_slow
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			    \
+({int __ret = nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN); \
+if (!__ret)								    \
+	__ret = (okfn)(skb);						    \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	    \
+({int __ret = nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh);  \
+if (!__ret)								    \
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
+    !(__ret = nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN))) \
+	__ret = (okfn)(skb);						     \
+__ret;})
+#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	     \
+({int __ret = 0;							     \
+if (list_empty(&nf_hooks[pf][hook]) ||					     \
+    !(__ret = nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh)))  \
+	__ret = (okfn)(skb);						     \
+__ret;})
 #endif
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev, struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *), int thresh);
 
--- linux-2.6.10/net/core/netfilter.c.old	2005-01-07 20:41:47.000000000 +0100
+++ linux-2.6.10/net/core/netfilter.c	2005-01-07 21:52:13.659686232 +0100
@@ -494,7 +494,7 @@ static int nf_queue(struct sk_buff *skb,
 	return 1;
 }
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev,
 		 struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *),
@@ -508,30 +508,28 @@ int nf_hook_slow(int pf, unsigned int ho
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
 	if (verdict == NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
-		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn))
+		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn))
 			goto next_hook;
 	}
 
 	switch (verdict) {
-	case NF_ACCEPT:
-		ret = okfn(skb);
-		break;
-
 	case NF_DROP:
-		kfree_skb(skb);
+		kfree_skb(*pskb);
+	case NF_STOLEN:
+	case NF_QUEUE:
 		ret = -EPERM;
 		break;
 	}
