From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: [PATCH 4/4] ACCT unbilling
Date: Fri, 13 Aug 2004 02:48:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411C0FDF.2040200@crocetta.org>
Reply-To: sandr8_NOSPAM_@crocetta.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, kuznet@ms2.inr.ac.ru, davem@redhat.com, devik@cdi.cz,
        shemminger@osdl.org, kaber@trash.net, rusty@rustcorp.com.au,
        laforge@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

4) the fourth patch is again my work and unbills flows that undergo a 
loss. in other words it aims at enforcing the _actually been served_ 
above. in fact patch (3) doesn't unbill connections for packets that are 
dropped, since this was not trivial at all to do before the changes in 
patch (2). the error made could be huge with respect to open loop 
streams (such as UDP), while with closed loop ones we could imagine that 
there will be not that much difference between the goodput seen before 
the enqueuing and the goodput seen after the deuqueuing. (well 
throughput and goodput are over time... but they are the most immediate 
words to convey the idea)

thanks to patch (4), when a packet is dropped, we call the unbilling 
function ct_sub_counters() from inside the before_explicit_drop().

the body of ct_sub_counters() is executed if and only if the connection 
tracking module is loaded (and, of course, if ACCT was enabled at 
compile time).

here, if some further development needs it, we could place
a new HOOK that gets packets right before they are dropped...
you would then be able to register packet filters functions
that wanna gather informations from dropped packets...

That way netfilter could also catch packets dropped _after_ they were 
enqueued.
 
RFC: personally i don't like having ip_ct_get and ip_conntrack_lockp in 
core/net.c, as logically they should not be there. where would they fit 
better? some place more appropriate? otherwise i should really take into 
consideration the hook stuff and have the ct_sub_counters() registered 
to the hook as well, so that there's no more need for those pointers.

Alessandro Salvatori
--
the _NOSPAM_ account is the one i am subscribed with, please remove 
_NOSPAM_ for personal replies

diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged-ACCT/include/net/pkt_sched.h 
linux-2.6.8-rc4-apichanged-ACCT-unbill/include/net/pkt_sched.h
--- linux-2.6.8-rc4-apichanged-ACCT/include/net/pkt_sched.h    
2004-08-12 16:01:09.000000000 +0200
+++ linux-2.6.8-rc4-apichanged-ACCT-unbill/include/net/pkt_sched.h    
2004-08-12 21:09:57.732378592 +0200
@@ -10,6 +10,21 @@
 #include <linux/module.h>
 #include <linux/rtnetlink.h>
 
+#ifdef CONFIG_IP_NF_CT_ACCT
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_conntrack_core.h>
+#include <linux/ip.h>
+extern struct ip_conntrack *
+(*ip_ct_get)(struct sk_buff *skb, enum ip_conntrack_info *ctinfo);
+
+#ifdef CONFIG_NETFILTER_DEBUG
+extern struct rwlock_debug * ip_conntrack_lockp;
+#else
+extern rwlock_t * ip_conntrack_lockp;
+#endif
+
+#endif
+
 struct rtattr;
 struct Qdisc;
 
@@ -94,9 +109,53 @@
 
 #define IMPLICIT_DROP() do; while (0) /* readability: just to be aware 
of what you are doing!!! */
 
+static inline void ct_sub_counters(const struct sk_buff *skb)
+{
+    /* skb must not be NULL */
+#ifdef CONFIG_IP_NF_CT_ACCT
+    if(ip_ct_get){
+        enum ip_conntrack_info ctinfo;
+        struct ip_conntrack *ct;
+
+        struct ip_conntrack *
+        (*the_connection_tracking_is_loaded)(struct sk_buff *skb,
+                    enum ip_conntrack_info *ctinfo);
+
+        if(skb->nfct && (the_connection_tracking_is_loaded=ip_ct_get)){
+            mb();
+            ct=the_connection_tracking_is_loaded(
+                (struct sk_buff *)skb,
+                &ctinfo);
+            if(ct){
+                WRITE_LOCK(ip_conntrack_lockp);
+
+                ct->counters[CTINFO2DIR(ctinfo)].packets--;
+                ct->counters[CTINFO2DIR(ctinfo)].bytes -=
+                    ntohs(skb->nh.iph->tot_len); //no need to check 
against wraparound
+                    //unless there's a bug it should not be possible to 
unbill more than we have billed!
+                WRITE_UNLOCK(ip_conntrack_lockp);
+            }
+        }
+    }
+#endif
+}
+
 static inline void before_explicit_drop(const struct sk_buff * skb)
 {
-    /* for the moment there's nothing to do. see next patch!!! */
+    ct_sub_counters(skb);
+
+    /* here, if some further development needs it, we could place
+     * a new HOOK that gets packets right before they are dropped...
+     * you would then be able to register packet filters functions
+     * that wanna gather informations from dropped packets...
+     *
+     * it would also be somehow dirty but technically feasible to
+     * use the kfree_skb() as the okfn: it has the right prototype
+     * to be used in that way and it could also make some sense,
+     * though the meaning of the value of filter functions would
+     * be pretty counterintuitive... */
+
+    skb_free(skb);
 }
 
 #define    QDISC_ALIGN        32
diff -NaurX dontdiff linux-2.6.8-rc4-apichanged-ACCT/net/core/dev.c 
linux-2.6.8-rc4-apichanged-ACCT-unbill/net/core/dev.c
--- linux-2.6.8-rc4-apichanged-ACCT/net/core/dev.c    2004-08-12 
17:23:43.000000000 +0200
+++ linux-2.6.8-rc4-apichanged-ACCT-unbill/net/core/dev.c    2004-08-12 
18:30:24.561721744 +0200
@@ -113,6 +113,23 @@
 #include <net/iw_handler.h>
 #endif    /* CONFIG_NET_RADIO */
 #include <asm/current.h>
+#include <linux/ip.h>
+#ifdef CONFIG_IP_NF_CT_ACCT
+struct ip_conntrack *
+(* ip_ct_get)(struct sk_buff *skb,
+    enum ip_conntrack_info *ctinfo)=NULL;
+DECLARE_RWLOCK(ct_load);
+#ifdef CONFIG_NETFILTER_DEBUG
+struct rwlock_debug * ip_conntrack_lockp=NULL;
+#else
+rwlock_t * ip_conntrack_lockp=NULL;
+#endif
+
+EXPORT_SYMBOL(ip_ct_get);
+EXPORT_SYMBOL(ip_conntrack_lockp);
+
+#endif
+
 
 /* This define, if set, will randomly drop a packet when congestion
  * is more than moderate.  It helps fairness in the multi-interface
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_core.c 
linux-2.6.8-rc4-apichanged-ACCT-unbill/net/ipv4/netfilter/ip_conntrack_core.c
--- 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_core.c    
2004-08-12 17:43:07.049089232 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT-unbill/net/ipv4/netfilter/ip_conntrack_core.c    
2004-08-12 18:30:24.614713688 +0200
@@ -56,6 +56,21 @@
 #define DEBUGP(format, args...)
 #endif
 
+#ifdef CONFIG_IP_NF_CT_ACCT
+extern struct ip_conntrack *
+(*ip_ct_get)(struct sk_buff *skb, enum ip_conntrack_info *ctinfo);
+
+
+
+#ifdef CONFIG_NETFILTER_DEBUG 
+extern struct rwlock_debug * ip_conntrack_lockp;
+#else 
+extern rwlock_t * ip_conntrack_lockp;
+#endif 
+
+#endif
+
+
 DECLARE_RWLOCK(ip_conntrack_lock);
 DECLARE_RWLOCK(ip_conntrack_expect_tuple_lock);
 
@@ -1373,6 +1388,10 @@
 void ip_conntrack_cleanup(void)
 {
     ip_ct_attach = NULL;
+#ifdef CONFIG_IP_NF_CT_ACCT
+    ip_ct_get = NULL;
+#endif   
+   
     /* This makes sure all current packets have passed through
            netfilter framework.  Roll on, two-stage module
            delete... */
@@ -1451,6 +1470,12 @@
 
     /* For use by ipt_REJECT */
     ip_ct_attach = ip_conntrack_attach;
+   
+#ifdef CONFIG_IP_NF_CT_ACCT
+    /* For the core kernel, in net/core/dev.c */
+    ip_conntrack_lockp=&ip_conntrack_lock;
+    ip_ct_get = ip_conntrack_get;
+#endif
 
     /* Set up fake conntrack:
         - to never be deleted, not in any hashes */
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/Kconfig 
linux-2.6.8-rc4-apichanged-ACCT-unbill/net/ipv4/netfilter/Kconfig
--- linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/Kconfig    
2004-08-12 17:45:47.330722720 +0200
+++ linux-2.6.8-rc4-apichanged-ACCT-unbill/net/ipv4/netfilter/Kconfig    
2004-08-12 18:30:24.651708064 +0200
@@ -22,6 +22,14 @@
 config IP_NF_CT_ACCT
     bool "Connection tracking flow accounting"
     depends on IP_NF_CONNTRACK
+    ---help---
+      If you enable this option, the connection tracking code will keep
+      per-flow packet and byte counters.
+
+      Those counters can be used for flow-based accounting or the
+      `connbytes' match.
+
+      If unsure, say N.
 
 config IP_NF_FTP
     tristate "FTP protocol support"
