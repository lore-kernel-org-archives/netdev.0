From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Thu, 19 Aug 2004 16:55:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4124BF7E.7090304@trash.net>
References: <20040818091352.GB6507@suse.de>	<20040819101159.GC3921@sunbeam.de.gnumonks.org> <20040819071846.2d0d6120.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040406000802080008010907"
Cc: Harald Welte <laforge@netfilter.org>, okir@suse.de, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040819071846.2d0d6120.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040406000802080008010907
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>On Thu, 19 Aug 2004 12:11:59 +0200
>Harald Welte <laforge@netfilter.org> wrote:
>
>  
>
>>Dave, is this fine with you?  What solution would you prefer?
>>    
>>
>
>I haven't been shown the patches so I can't generate an
>opinion. :-)
>  
>

These are Olaf's patches. I agree with Harald that the second
patch is better. I've fixed it up so it applies with the recent
ip_fragment.c changes.


--------------040406000802080008010907
Content-Type: text/plain;
 name="netfilter-unload-crash"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netfilter-unload-crash"

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

--------------040406000802080008010907
Content-Type: text/plain;
 name="conntrack-flush-fragments"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="conntrack-flush-fragments"


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

--------------040406000802080008010907
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/19 16:51:10+02:00 kaber@coreworks.de 
#   [NETFILTER]: Flush ip fragment queue on conntrack module unload
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/netfilter/ip_conntrack_standalone.c
#   2004/08/19 16:50:47+02:00 kaber@coreworks.de +2 -0
#   [NETFILTER]: Flush ip fragment queue on conntrack module unload
# 
# net/ipv4/ip_fragment.c
#   2004/08/19 16:50:47+02:00 kaber@coreworks.de +14 -3
#   [NETFILTER]: Flush ip fragment queue on conntrack module unload
# 
# include/net/ip.h
#   2004/08/19 16:50:47+02:00 kaber@coreworks.de +1 -0
#   [NETFILTER]: Flush ip fragment queue on conntrack module unload
# 
diff -Nru a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h	2004-08-19 16:53:39 +02:00
+++ b/include/net/ip.h	2004-08-19 16:53:39 +02:00
@@ -255,6 +255,7 @@
  */
  
 struct sk_buff *ip_defrag(struct sk_buff *skb);
+extern void ipfrag_flush(void);
 extern int ip_frag_nqueues;
 extern atomic_t ip_frag_mem;
 
diff -Nru a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
--- a/net/ipv4/ip_fragment.c	2004-08-19 16:53:38 +02:00
+++ b/net/ipv4/ip_fragment.c	2004-08-19 16:53:38 +02:00
@@ -241,15 +241,15 @@
 }
 
 /* Memory limiting on fragments.  Evictor trashes the oldest 
- * fragment queue until we are back under the low threshold.
+ * fragment queue until we are back under the threshold.
  */
-static void ip_evictor(void)
+static void __ip_evictor(int threshold)
 {
 	struct ipq *qp;
 	struct list_head *tmp;
 	int work;
 
-	work = atomic_read(&ip_frag_mem) - sysctl_ipfrag_low_thresh;
+	work = atomic_read(&ip_frag_mem) - threshold;
 	if (work <= 0)
 		return;
 
@@ -274,6 +274,11 @@
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
@@ -684,4 +689,10 @@
 	add_timer(&ipfrag_secret_timer);
 }
 
+void ipfrag_flush(void)
+{
+	__ip_evictor(0);
+}
+
 EXPORT_SYMBOL(ip_defrag);
+EXPORT_SYMBOL(ipfrag_flush);
diff -Nru a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-19 16:53:38 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-19 16:53:39 +02:00
@@ -806,6 +806,8 @@
 	nf_unregister_hook(&ip_conntrack_defrag_local_out_ops);
  cleanup_defragops:
 	nf_unregister_hook(&ip_conntrack_defrag_ops);
+	/* Frag queues may hold fragments with skb->dst == NULL */
+	ipfrag_flush();
  cleanup_proc_stat:
 	proc_net_remove("ip_conntrack_stat");
 cleanup_proc_exp:

--------------040406000802080008010907--
