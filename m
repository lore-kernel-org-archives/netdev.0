From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Mon, 30 Aug 2004 02:50:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413279C2.8020400@trash.net>
References: <412A8FB5.4080700@trash.net>	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>	<20040828231529.051a73cc.davem@davemloft.net>	<4132303C.2060807@trash.net>	<20040829125708.5aa70469.davem@davemloft.net>	<4132516E.7080805@trash.net> <20040829163821.2a4239df.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060709030904060409000704"
Cc: dlstevens@us.ibm.com, davem@redhat.com, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040829163821.2a4239df.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060709030904060409000704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>On Sun, 29 Aug 2004 23:58:06 +0200
>Patrick McHardy <kaber@trash.net> wrote:
>  
>
>>Before I post the patch, 2.4 seems to be
>>missing this patch, do you already have it queued or should I send
>>a 2.4 version first ?
>>
>>ChangeSet@1.1853, 2004-08-18 14:28:05-07:00, davem@nuts.davemloft.net
>>  [IPV4]: Fix theoretical loop on SMP in ip_evictor().
>>    
>>
>
>I pushed this off to Marcelo, he just didn't pull from my
>tree yet, which is at:
>
>	bk://kernel.bkbits.net/davem/net-2.4
>
>Where you'll find those fixes as:
>
>ChangeSet@1.1498.1.2, 2004-08-18 14:26:09-07:00, davem@nuts.davemloft.net
>  [IPV4]: Fix theoretical loop on SMP in ip_evictor().
>  
>

Great, here is the patch for 2.4 for the conntrack problem.



--------------060709030904060409000704
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/30 02:22:35+02:00 kaber@coreworks.de 
#   [NETFILTER]: Flush fragment queue on conntrack unload
#   
#   Based on patch from Olaf Kirch <okir@suse.de>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/netsyms.c
#   2004/08/30 02:22:30+02:00 kaber@coreworks.de +1 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# net/ipv4/netfilter/ip_conntrack_standalone.c
#   2004/08/30 02:22:30+02:00 kaber@coreworks.de +7 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# net/ipv4/netfilter/ip_conntrack_core.c
#   2004/08/30 02:22:30+02:00 kaber@coreworks.de +8 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# net/ipv4/ip_fragment.c
#   2004/08/30 02:22:30+02:00 kaber@coreworks.de +13 -3
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# include/net/ip.h
#   2004/08/30 02:22:30+02:00 kaber@coreworks.de +1 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
# include/linux/netfilter_ipv4/ip_conntrack.h
#   2004/08/30 02:22:30+02:00 kaber@coreworks.de +1 -0
#   [NETFILTER]: Flush fragment queue on conntrack unload
# 
diff -Nru a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/netfilter_ipv4/ip_conntrack.h
--- a/include/linux/netfilter_ipv4/ip_conntrack.h	2004-08-30 02:24:47 +02:00
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h	2004-08-30 02:24:47 +02:00
@@ -249,6 +249,7 @@
 /* Call me when a conntrack is destroyed. */
 extern void (*ip_conntrack_destroyed)(struct ip_conntrack *conntrack);
 
+extern int ip_ct_no_defrag;
 /* Returns new sk_buff, or NULL */
 struct sk_buff *
 ip_ct_gather_frags(struct sk_buff *skb);
diff -Nru a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h	2004-08-30 02:24:47 +02:00
+++ b/include/net/ip.h	2004-08-30 02:24:47 +02:00
@@ -228,6 +228,7 @@
  */
  
 struct sk_buff *ip_defrag(struct sk_buff *skb);
+extern void ipfrag_flush(void);
 extern int ip_frag_nqueues;
 extern atomic_t ip_frag_mem;
 
diff -Nru a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
--- a/net/ipv4/ip_fragment.c	2004-08-30 02:24:47 +02:00
+++ b/net/ipv4/ip_fragment.c	2004-08-30 02:24:47 +02:00
@@ -240,15 +240,15 @@
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
 
@@ -273,6 +273,11 @@
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
@@ -681,4 +686,9 @@
 	ipfrag_secret_timer.function = ipfrag_secret_rebuild;
 	ipfrag_secret_timer.expires = jiffies + sysctl_ipfrag_secret_interval;
 	add_timer(&ipfrag_secret_timer);
+}
+
+void ipfrag_flush(void)
+{
+	__ip_evictor(0);
 }
diff -Nru a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c	2004-08-30 02:24:47 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_core.c	2004-08-30 02:24:47 +02:00
@@ -1183,6 +1183,8 @@
 	WRITE_UNLOCK(&ip_conntrack_lock);
 }
 
+int ip_ct_no_defrag;
+
 /* Returns new sk_buff, or NULL */
 struct sk_buff *
 ip_ct_gather_frags(struct sk_buff *skb)
@@ -1191,6 +1193,12 @@
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
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-30 02:24:47 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-30 02:24:47 +02:00
@@ -393,6 +393,13 @@
  cleanup_inandlocalops:
 	nf_unregister_hook(&ip_conntrack_local_out_ops);
  cleanup_inops:
+	/* Frag queues may hold fragments with skb->dst == NULL */
+	ip_ct_no_defrag = 1;
+	local_bh_disable();
+	br_write_lock(BR_NETPROTO_LOCK);
+	br_write_unlock(BR_NETPROTO_LOCK);
+	ipfrag_flush();
+	local_bh_enable();
 	nf_unregister_hook(&ip_conntrack_in_ops);
  cleanup_proc:
 	proc_net_remove("ip_conntrack");
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	2004-08-30 02:24:47 +02:00
+++ b/net/netsyms.c	2004-08-30 02:24:47 +02:00
@@ -283,6 +283,7 @@
 EXPORT_SYMBOL(inetdev_by_index);
 EXPORT_SYMBOL(in_dev_finish_destroy);
 EXPORT_SYMBOL(ip_defrag);
+EXPORT_SYMBOL(ipfrag_flush);
 
 /* Route manipulation */
 EXPORT_SYMBOL(ip_rt_ioctl);

--------------060709030904060409000704--
