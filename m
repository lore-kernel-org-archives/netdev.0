From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH]snmp6 64-bit counter support in proc.c
Date: Fri, 5 Dec 2003 12:14:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312051214.48076.mashirle@us.ibm.com>
References: <200312021240.PAA01536@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_NWUFQ050M8TIMNC8CGFE"
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200312021240.PAA01536@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_NWUFQ050M8TIMNC8CGFE
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I add this because there are some 64-bit counters in the new IPv6 MIBs.=20
This patch has been tested agaist linux-2.6.0-test9, and cleanly applied =
to=20
linux-2.6.0-test11.

Thanks
Shirley Ma
IBM Linux Technology Center
--------------Boundary-00=_NWUFQ050M8TIMNC8CGFE
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.0-test11-ipv6mib2-64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.0-test11-ipv6mib2-64.patch"

diff -urN linux-2.6.0-test11/net/ipv6/proc.c linux-2.6.0-test11-ipv6mib2-64/net/ipv6/proc.c
--- linux-2.6.0-test11/net/ipv6/proc.c	2003-11-26 12:43:38.000000000 -0800
+++ linux-2.6.0-test11-ipv6mib2-64/net/ipv6/proc.c	2003-12-05 12:04:19.000000000 -0800
@@ -60,13 +60,14 @@
 struct snmp6_item
 {
 	char *name;
+	int   size;
 	int   offset;
 };
-#define SNMP6_SENTINEL	{ .name = NULL, .offset = 0 }
+#define SNMP6_SENTINEL	{ .name = NULL, .size = 0, .offset = 0 }
 
 static struct snmp6_item snmp6_ipv6_list[] = {
 /* ipv6 mib according to RFC 2465 */
-#define SNMP6_GEN(x) { .name = #x , .offset = offsetof(struct ipv6_mib, x) }
+#define SNMP6_GEN(x) { .name = #x , .size = sizeof(((struct ipv6_mib *)0)->x), .offset = offsetof(struct ipv6_mib, x) }
 	SNMP6_GEN(Ip6InReceives),
 	SNMP6_GEN(Ip6InHdrErrors),
 	SNMP6_GEN(Ip6InTooBigErrors),
@@ -104,7 +105,7 @@
 		OutRouterAdvertisements too.
 		OutGroupMembQueries too.
  */
-#define SNMP6_GEN(x) { .name = #x , .offset = offsetof(struct icmpv6_mib, x) }
+#define SNMP6_GEN(x) { .name = #x , .size = sizeof(((struct icmpv6_mib *)0)->x), .offset = offsetof(struct icmpv6_mib, x) }
 	SNMP6_GEN(Icmp6InMsgs),
 	SNMP6_GEN(Icmp6InErrors),
 	SNMP6_GEN(Icmp6InDestUnreachs),
@@ -138,7 +139,7 @@
 };
 
 static struct snmp6_item snmp6_udp6_list[] = {
-#define SNMP6_GEN(x) { .name = "Udp6" #x , .offset = offsetof(struct udp_mib, Udp##x) }
+#define SNMP6_GEN(x) { .name = "Udp6" #x , .size = sizeof(((struct udp_mib *)0)->Udp##x), .offset = offsetof(struct udp_mib, Udp##x) }
 	SNMP6_GEN(InDatagrams),
 	SNMP6_GEN(NoPorts),
 	SNMP6_GEN(InErrors),
@@ -147,22 +148,27 @@
 	SNMP6_SENTINEL
 };
 
-static unsigned long
-fold_field(void *mib[], int offt)
+static unsigned long long
+fold_field(void *mib[], int size, int offt)
 {
-        unsigned long res = 0;
+        unsigned long long res = 0;
         int i;
  
         for (i = 0; i < NR_CPUS; i++) {
                 if (!cpu_possible(i))
                         continue;
-                res +=
-                    *((unsigned long *) (((void *)per_cpu_ptr(mib[0], i)) +
-                                         offt));
-                res +=
-                    *((unsigned long *) (((void *)per_cpu_ptr(mib[1], i)) +
-                                         offt));
-        }
+		if (size == 4) {
+			res += *((unsigned long *) 
+				(((void *)per_cpu_ptr(mib[0], i)) + offt));
+			res += *((unsigned long *)
+				(((void *)per_cpu_ptr(mib[1], i)) + offt));
+		} else if (size == 8) {
+			res += *((unsigned long long *) 
+				(((void *)per_cpu_ptr(mib[0], i)) + offt));
+			res += *((unsigned long long *)
+				(((void *)per_cpu_ptr(mib[1], i)) + offt));
+		}
+	}
         return res;
 }
 
@@ -170,9 +176,9 @@
 snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp6_item *itemlist)
 {
 	int i;
-	for (i=0; itemlist[i].name; i++)
-		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name, 
-				fold_field(mib, itemlist[i].offset));
+	for (i=0; itemlist[i].name; i++) 
+		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name, 
+			fold_field(mib, itemlist[i].size, itemlist[i].offset));
 }
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)

--------------Boundary-00=_NWUFQ050M8TIMNC8CGFE--
