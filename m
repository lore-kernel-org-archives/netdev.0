From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: [PATCH 3/4] ACCT billing
Date: Fri, 13 Aug 2004 02:48:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411C0FD6.9010401@crocetta.org>
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

3) the third patch is not my own work but Harald Welte's one. i just
send the same patch but against the kernel as it results after applying
(1) and (2) so that it applies cleanly. that patch is intended to bill
connections and datagram flows for the amount of traffic they have
actually been served.

Alessandro Salvatori
--
the _NOSPAM_ account is the one i am subscribed with, please remove 
_NOSPAM_ for personal replies

diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/include/linux/netfilter_ipv4/ip_conntrack.h 
linux-2.6.8-rc4-apichanged-ACCT/include/linux/netfilter_ipv4/ip_conntrack.h
--- 
linux-2.6.8-rc4-apichanged/include/linux/netfilter_ipv4/ip_conntrack.h    
2004-08-10 12:27:34.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/include/linux/netfilter_ipv4/ip_conntrack.h    
2004-08-12 17:43:06.994097592 +0200
@@ -156,6 +156,12 @@
     union ip_conntrack_expect_help help;
 };
 
+struct ip_conntrack_counter
+{
+    u_int64_t packets;
+    u_int64_t bytes;
+};
+
 struct ip_conntrack_helper;
 
 struct ip_conntrack
@@ -173,6 +179,11 @@
     /* Timer function; drops refcnt when it goes off. */
     struct timer_list timeout;
 
+#ifdef CONFIG_IP_NF_CT_ACCT
+    /* Accounting Information (same cache line as other written members) */
+    struct ip_conntrack_counter counters[IP_CT_DIR_MAX];
+#endif
+
     /* If we're expecting another related connection, this will be
            in expected linked list */
     struct list_head sibling_list;
@@ -245,8 +256,10 @@
               const struct ip_conntrack_tuple *orig);
 
 /* Refresh conntrack for this many jiffies */
-extern void ip_ct_refresh(struct ip_conntrack *ct,
-              unsigned long extra_jiffies);
+extern void ip_ct_refresh_acct(struct ip_conntrack *ct,
+                   enum ip_conntrack_info ctinfo,
+                   const struct sk_buff *skb,
+                   unsigned long extra_jiffies);
 
 /* These are for NAT.  Icky. */
 /* Call me when a conntrack is destroyed. */
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_amanda.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_amanda.c
--- 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_amanda.c    
2004-08-10 12:27:35.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_amanda.c    
2004-08-12 17:43:07.043090144 +0200
@@ -58,7 +58,7 @@
 
     /* increase the UDP timeout of the master connection as replies from
      * Amanda clients to the server can be quite delayed */
-    ip_ct_refresh(ct, master_timeout * HZ);
+    ip_ct_refresh_acct(ct, ctinfo, NULL, master_timeout * HZ);
 
     /* No data? */
     dataoff = skb->nh.iph->ihl*4 + sizeof(struct udphdr);
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_core.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_core.c
--- linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_core.c    
2004-08-10 12:27:35.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_core.c    
2004-08-12 17:43:07.049089232 +0200
@@ -1164,21 +1164,39 @@
     synchronize_net();
 }
 
-/* Refresh conntrack for this many jiffies. */
-void ip_ct_refresh(struct ip_conntrack *ct, unsigned long extra_jiffies)
+static inline void ct_add_counters(struct ip_conntrack *ct,
+                   enum ip_conntrack_info ctinfo,
+                   const struct sk_buff *skb)
+{
+#ifdef CONFIG_IP_NF_CT_ACCT
+    if (skb) {
+        ct->counters[CTINFO2DIR(ctinfo)].packets++;
+        ct->counters[CTINFO2DIR(ctinfo)].bytes +=
+                    ntohs(skb->nh.iph->tot_len);
+    }
+#endif
+}
+
+/* Refresh conntrack for this many jiffies and do accounting (if skb != 
NULL) */
+void ip_ct_refresh_acct(struct ip_conntrack *ct,
+                enum ip_conntrack_info ctinfo,
+            const struct sk_buff *skb,
+            unsigned long extra_jiffies)
 {
     IP_NF_ASSERT(ct->timeout.data == (unsigned long)ct);
 
     /* If not in hash table, timer will not be active yet */
-    if (!is_confirmed(ct))
+    if (!is_confirmed(ct)) {
         ct->timeout.expires = extra_jiffies;
-    else {
+        ct_add_counters(ct, ctinfo, skb);
+    } else {
         WRITE_LOCK(&ip_conntrack_lock);
         /* Need del_timer for race avoidance (may already be dying). */
         if (del_timer(&ct->timeout)) {
             ct->timeout.expires = jiffies + extra_jiffies;
             add_timer(&ct->timeout);
         }
+        ct_add_counters(ct, ctinfo, skb);
         WRITE_UNLOCK(&ip_conntrack_lock);
     }
 }
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_generic.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_generic.c
--- 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_generic.c    
2004-06-16 07:19:13.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_generic.c    
2004-08-12 17:43:07.079084672 +0200
@@ -50,9 +50,9 @@
 /* Returns verdict for packet, or -1 for invalid. */
 static int packet(struct ip_conntrack *conntrack,
           const struct sk_buff *skb,
-          enum ip_conntrack_info conntrackinfo)
+          enum ip_conntrack_info ctinfo)
 {
-    ip_ct_refresh(conntrack, ip_ct_generic_timeout);
+    ip_ct_refresh_acct(conntrack, ctinfo, skb, ip_ct_generic_timeout);
     return NF_ACCEPT;
 }
 
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_icmp.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
--- 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_icmp.c    
2004-06-16 07:18:52.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_icmp.c    
2004-08-12 17:43:07.082084216 +0200
@@ -94,7 +94,7 @@
             ct->timeout.function((unsigned long)ct);
     } else {
         atomic_inc(&ct->proto.icmp.count);
-        ip_ct_refresh(ct, ip_ct_icmp_timeout);
+        ip_ct_refresh_acct(ct, ctinfo, skb, ip_ct_icmp_timeout);
     }
 
     return NF_ACCEPT;
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_tcp.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
--- 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_tcp.c    
2004-08-10 12:27:35.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_tcp.c    
2004-08-12 17:43:07.087083456 +0200
@@ -225,7 +225,7 @@
         set_bit(IPS_ASSURED_BIT, &conntrack->status);
 
 out:    WRITE_UNLOCK(&tcp_lock);
-    ip_ct_refresh(conntrack, *tcp_timeouts[newconntrack]);
+    ip_ct_refresh_acct(conntrack, ctinfo, skb, 
*tcp_timeouts[newconntrack]);
 
     return NF_ACCEPT;
 }
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_udp.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_udp.c
--- 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_proto_udp.c    
2004-06-16 07:18:37.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_proto_udp.c    
2004-08-12 17:43:07.090083000 +0200
@@ -60,16 +60,17 @@
 /* Returns verdict for packet, and may modify conntracktype */
 static int udp_packet(struct ip_conntrack *conntrack,
               const struct sk_buff *skb,
-              enum ip_conntrack_info conntrackinfo)
+              enum ip_conntrack_info ctinfo)
 {
     /* If we've seen traffic both ways, this is some kind of UDP
        stream.  Extend timeout. */
     if (test_bit(IPS_SEEN_REPLY_BIT, &conntrack->status)) {
-        ip_ct_refresh(conntrack, ip_ct_udp_timeout_stream);
+        ip_ct_refresh_acct(conntrack, ctinfo, skb,
+                   ip_ct_udp_timeout_stream);
         /* Also, more likely to be important, and not a probe */
         set_bit(IPS_ASSURED_BIT, &conntrack->status);
     } else
-        ip_ct_refresh(conntrack, ip_ct_udp_timeout);
+        ip_ct_refresh_acct(conntrack, ctinfo, skb, ip_ct_udp_timeout);
 
     return NF_ACCEPT;
 }
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_standalone.c 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_standalone.c
--- 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/ip_conntrack_standalone.c    
2004-08-10 12:27:35.000000000 +0200
+++ 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/ip_conntrack_standalone.c    
2004-08-12 17:43:07.111079808 +0200
@@ -83,6 +83,17 @@
     return len;
 }
 
+#ifdef CONFIG_IP_NF_CT_ACCT
+static unsigned int
+print_counters(char *buffer, struct ip_conntrack_counter *counter)
+{
+    return sprintf(buffer, "packets=%llu bytes=%llu ",
+            counter->packets, counter->bytes);
+}
+#else
+#define print_counters(x, y)    0
+#endif
+
 static unsigned int
 print_conntrack(char *buffer, struct ip_conntrack *conntrack)
 {
@@ -102,11 +113,15 @@
     len += print_tuple(buffer + len,
                &conntrack->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
                proto);
+    len += print_counters(buffer + len,
+                  &conntrack->counters[IP_CT_DIR_ORIGINAL]);
     if (!(test_bit(IPS_SEEN_REPLY_BIT, &conntrack->status)))
         len += sprintf(buffer + len, "[UNREPLIED] ");
     len += print_tuple(buffer + len,
                &conntrack->tuplehash[IP_CT_DIR_REPLY].tuple,
                proto);
+    len += print_counters(buffer + len,
+                  &conntrack->counters[IP_CT_DIR_REPLY]);
     if (test_bit(IPS_ASSURED_BIT, &conntrack->status))
         len += sprintf(buffer + len, "[ASSURED] ");
     len += sprintf(buffer + len, "use=%u ",
@@ -638,7 +653,7 @@
 EXPORT_SYMBOL(ip_conntrack_helper_register);
 EXPORT_SYMBOL(ip_conntrack_helper_unregister);
 EXPORT_SYMBOL(ip_ct_selective_cleanup);
-EXPORT_SYMBOL(ip_ct_refresh);
+EXPORT_SYMBOL(ip_ct_refresh_acct);
 EXPORT_SYMBOL(ip_ct_find_proto);
 EXPORT_SYMBOL(__ip_ct_find_proto);
 EXPORT_SYMBOL(ip_ct_find_helper);
diff -NaurX dontdiff 
linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/Kconfig 
linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/Kconfig
--- linux-2.6.8-rc4-apichanged/net/ipv4/netfilter/Kconfig    2004-08-10 
12:27:35.000000000 +0200
+++ linux-2.6.8-rc4-apichanged-ACCT/net/ipv4/netfilter/Kconfig    
2004-08-12 17:45:47.330722720 +0200
@@ -19,6 +19,10 @@
 
       To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_CT_ACCT
+    bool "Connection tracking flow accounting"
+    depends on IP_NF_CONNTRACK
+
 config IP_NF_FTP
     tristate "FTP protocol support"
     depends on IP_NF_CONNTRACK
