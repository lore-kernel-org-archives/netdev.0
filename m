From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 29 Aug 2004 21:36:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4132303C.2060807@trash.net>
References: <412A8FB5.4080700@trash.net>	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com> <20040828231529.051a73cc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040503030308040903070004"
Cc: David Stevens <dlstevens@us.ibm.com>, davem@redhat.com,
        laforge@netfilter.org, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040828231529.051a73cc.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040503030308040903070004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>I think I agree with David now that I've read through this a few
>times.  Can someone send me a patch which does this?
>  
>
Attached. The first patch still crashed, we need to prevent new
fragments from getting queued after the queue is flushed until the
hook in unregistered.

>Does 2.4.x have this problem too?  I thought it didn't.
>  
>
I'll have a look, but I think it does.

Regards
Patrick


--------------040503030308040903070004
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/29 20:24:07+02:00 kaber@coreworks.de 
#   [NETFILTER]: Flush fragment queue on conntrack unload
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/netfilter/ip_conntrack_standalone.c
#   2004/08/29 20:22:57+02:00 kaber@coreworks.de +6 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# net/ipv4/netfilter/ip_conntrack_core.c
#   2004/08/29 20:22:57+02:00 kaber@coreworks.de +8 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# net/ipv4/ip_fragment.c
#   2004/08/29 20:22:57+02:00 kaber@coreworks.de +14 -3
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# include/net/ip.h
#   2004/08/29 20:22:57+02:00 kaber@coreworks.de +1 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# include/linux/netfilter_ipv4/ip_conntrack.h
#   2004/08/29 20:22:57+02:00 kaber@coreworks.de +1 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
diff -Nru a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/netfilter_ipv4/ip_conntrack.h
--- a/include/linux/netfilter_ipv4/ip_conntrack.h	2004-08-29 20:55:13 +02:00
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h	2004-08-29 20:55:13 +02:00
@@ -275,6 +275,7 @@
 /* Fake conntrack entry for untracked connections */
 extern struct ip_conntrack ip_conntrack_untracked;
 
+extern int ip_ct_no_defrag;
 /* Returns new sk_buff, or NULL */
 struct sk_buff *
 ip_ct_gather_frags(struct sk_buff *skb);
diff -Nru a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h	2004-08-29 20:55:13 +02:00
+++ b/include/net/ip.h	2004-08-29 20:55:13 +02:00
@@ -255,6 +255,7 @@
  */
  
 struct sk_buff *ip_defrag(struct sk_buff *skb);
+extern void ipfrag_flush(void);
 extern int ip_frag_nqueues;
 extern atomic_t ip_frag_mem;
 
diff -Nru a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
--- a/net/ipv4/ip_fragment.c	2004-08-29 20:55:13 +02:00
+++ b/net/ipv4/ip_fragment.c	2004-08-29 20:55:13 +02:00
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
diff -Nru a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c	2004-08-29 20:55:13 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_core.c	2004-08-29 20:55:13 +02:00
@@ -1173,6 +1173,8 @@
 	}
 }
 
+int ip_ct_no_defrag;
+
 /* Returns new sk_buff, or NULL */
 struct sk_buff *
 ip_ct_gather_frags(struct sk_buff *skb)
@@ -1181,6 +1183,12 @@
 #ifdef CONFIG_NETFILTER_DEBUG
 	unsigned int olddebug = skb->nf_debug;
 #endif
+
+	if (unlikely(ip_ct_no_defrag)) {
+		kfree_skb(skb);
+		return NULL;
+	}
+
 	if (sk) {
 		sock_hold(sk);
 		skb_orphan(skb);
diff -Nru a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-29 20:55:13 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-29 20:55:13 +02:00
@@ -805,6 +805,12 @@
  cleanup_defraglocalops:
 	nf_unregister_hook(&ip_conntrack_defrag_local_out_ops);
  cleanup_defragops:
+	/* Frag queues may hold fragments with skb->dst == NULL */
+	ip_ct_no_defrag = 1;
+	smp_wmb();
+	local_bh_disable();
+	ipfrag_flush();
+	local_bh_enable();
 	nf_unregister_hook(&ip_conntrack_defrag_ops);
  cleanup_proc_stat:
 	proc_net_remove("ip_conntrack_stat");

--------------040503030308040903070004--
