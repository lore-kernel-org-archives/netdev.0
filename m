From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Prevent crash on ip_conntrack removal
Date: Wed, 18 Aug 2004 11:13:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818091352.GB6507@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

here's a patch that keeps us from crashing on removal of ip_conntrack.
This problem came up during IBM's testing of SLES.
I'm not sure if this issue has been submitted already.

Problem description courtesy of David Stevens:

	It appears that conntrack, when loaded, is queueing the fragments
	for reassembly pre-routing (ie, when skb->dst is 0) and giving
	the fully reassembled packet to the pre-routing code which will
	set skb->dst before using it.

	IP without conntrack does the queueing of fragments and reassembly
	post-routing, so skb->dst in that case is set for all fragments
	and the reassembled packet.

	In the failure scenario, it appears that conntrack has queued
	some of the fragments (w/ skb->dst=0, esp. in the offset=0 first
	fragment) and then the conntrack module is removed. Arrival
	of a fragment afterward will queue and reassemble the entire
	packet post-routing, but the first frag still has skb->dst 0,
	so it'll blow up

To fix this, the patch below simply drops such skbs. A different fix
could be to change the conntrack module to flush out all unassembled
fragments when unloaded; an alternative patch for this is attached as
well (this one is completely untested).

Cheers
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=netfilter-unload-crash

Index: v2.6.8/net/ipv4/ip_input.c
===================================================================
--- v2.6.8.orig/net/ipv4/ip_input.c
+++ v2.6.8/net/ipv4/ip_input.c
@@ -177,6 +177,13 @@ int ip_call_ra_chain(struct sk_buff *skb
 					read_unlock(&ip_ra_lock);
 					return 1;
 				}
+				/* When ip_conntrack gets unloaded, we may be
+				 * left with fragment chains where the first
+				 * fragment has skb->dst = NULL. */
+				if (skb->dst == NULL) {
+					 kfree_skb(skb);
+					 return 1;
+				 }
 			}
 			if (last) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -277,6 +284,13 @@ int ip_local_deliver(struct sk_buff *skb
 		skb = ip_defrag(skb);
 		if (!skb)
 			return 0;
+		/* When ip_conntrack gets unloaded, we may be
+		 * left with fragment chains where the first
+		 * fragment has skb->dst = NULL. */
+		if (skb->dst == NULL) {
+			 kfree_skb(skb);
+			 return 0;
+		 }
 	}
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_IN, skb, skb->dev, NULL,

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=conntrack-flush-fragments


Alternative fix for the crash on conntrack unload. Simply flush all
fragment queues when unloading conntrack_standalone so that there are
no partially assembled fragments left with skb->dst == NULL.

Index: v2.6.8/include/net/ip.h
===================================================================
--- v2.6.8.orig/include/net/ip.h
+++ v2.6.8/include/net/ip.h
@@ -255,6 +255,7 @@ extern int	ip_call_ra_chain(struct sk_bu
  */
  
 struct sk_buff *ip_defrag(struct sk_buff *skb);
+extern void ipfrag_flush(void);
 extern int ip_frag_nqueues;
 extern atomic_t ip_frag_mem;
 
Index: v2.6.8/net/ipv4/ip_fragment.c
===================================================================
--- v2.6.8.orig/net/ipv4/ip_fragment.c
+++ v2.6.8/net/ipv4/ip_fragment.c
@@ -239,13 +239,13 @@ static void ipq_kill(struct ipq *ipq)
 /* Memory limiting on fragments.  Evictor trashes the oldest 
  * fragment queue until we are back under the low threshold.
  */
-static void ip_evictor(void)
+static void __ip_evictor(int threshold)
 {
 	struct ipq *qp;
 	struct list_head *tmp;
 
 	for(;;) {
-		if (atomic_read(&ip_frag_mem) <= sysctl_ipfrag_low_thresh)
+		if (atomic_read(&ip_frag_mem) <= threshold)
 			return;
 		read_lock(&ipfrag_lock);
 		if (list_empty(&ipq_lru_list)) {
@@ -267,6 +267,11 @@ static void ip_evictor(void)
 	}
 }
 
+static inline void ip_evictor(void)
+{
+	__ip_evictor(sysctl_ipfrag_low_thresh);
+}
+
 /*
  * Oops, a fragment queue timed out.  Kill it and send an ICMP reply.
  */
@@ -677,4 +682,10 @@ void ipfrag_init(void)
 	add_timer(&ipfrag_secret_timer);
 }
 
+void ipfrag_flush(void)
+{
+	__ip_evictor(0);
+}
+
 EXPORT_SYMBOL(ip_defrag);
+EXPORT_SYMBOL(ipfrag_flush);
Index: v2.6.8/net/ipv4/netfilter/ip_conntrack_standalone.c
===================================================================
--- v2.6.8.orig/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ v2.6.8/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -562,6 +562,8 @@ static int init_or_cleanup(int init)
 	nf_unregister_hook(&ip_conntrack_defrag_local_out_ops);
  cleanup_defragops:
 	nf_unregister_hook(&ip_conntrack_defrag_ops);
+	/* Frag queues may hold fragments with skb->dst == NULL */
+	ipfrag_flush();
  cleanup_proc:
 	proc_net_remove("ip_conntrack");
  cleanup_init:

--3V7upXqbjpZ4EhLz--
