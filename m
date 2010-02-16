From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 53/62: get rid of the grossness in netfilter.h
Date: Tue, 16 Feb 2010 15:56:31 +0100 (MET)
Message-ID: <20100216145629.2796.4755.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2249065f4b22b493bae2caf549b86f175f33188e
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jun 13 04:13:26 2009 +0200

    netfilter: get rid of the grossness in netfilter.h
    
    GCC is now smart enough to follow the inline trail correctly.
    vmlinux size remain the same.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 2f22816..7007945 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -196,25 +196,36 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
    coders :)
 */
 
-/* This is gross, but inline doesn't cut it for avoiding the function
-   call in fast path: gcc doesn't inline (needs value tracking?). --RR */
-
-/* HX: It's slightly less gross now. */
-
-#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
-({int __ret;								       \
-if ((__ret=nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, thresh)) == 1)\
-	__ret = (okfn)(skb);						       \
-__ret;})
+static inline int
+NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sk_buff *skb,
+	       struct net_device *in, struct net_device *out,
+	       int (*okfn)(struct sk_buff *), int thresh)
+{
+	int ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, thresh);
+	if (ret == 1)
+		ret = okfn(skb);
+	return ret;
+}
 
-#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		       \
-({int __ret;								       \
-if ((cond) || (__ret = nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, INT_MIN)) == 1)\
-	__ret = (okfn)(skb);						       \
-__ret;})
+static inline int
+NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sk_buff *skb,
+	     struct net_device *in, struct net_device *out,
+	     int (*okfn)(struct sk_buff *), bool cond)
+{
+	int ret = 1;
+	if (cond ||
+	    (ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MIN) == 1))
+		ret = okfn(skb);
+	return ret;
+}
 
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn) \
-	NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, INT_MIN)
+static inline int
+NF_HOOK(uint8_t pf, unsigned int hook, struct sk_buff *skb,
+	struct net_device *in, struct net_device *out,
+	int (*okfn)(struct sk_buff *))
+{
+	return NF_HOOK_THRESH(pf, hook, skb, in, out, okfn, INT_MIN);
+}
 
 /* Call setsockopt() */
 int nf_setsockopt(struct sock *sk, u_int8_t pf, int optval, char __user *opt,
