From: David Stevens <dlstevens@us.ibm.com>
Subject: sysctl variable to force IGMP version [PATCH]
Date: Tue, 27 Jan 2004 14:13:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF3A5A0537.DEF35E29-ON88256E28.0073EBFF@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F
Content-type: multipart/alternative;
	Boundary="1__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F"

--1__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F
Content-type: text/plain; charset=US-ASCII





Below is a patch that allows forcing of the IGMP version. The primary
use would be with an IGMP-snooping switch that doesn't grok IGMPv3
packet formats and when there are no IGMPv2 or IGMPv1 multicast
routers on the network. By forcing the IGMP reports to version 2 (or
version 1, for really old switches), Linux would send reports that the
switch can understand for multicast forwarding to the port.

                        +-DLS

in-line and attached, for whitespace issues.

diff -ruN linux-2.6.2-rc1/include/linux/inetdevice.h linux-2.6.2-rc1F2/include/linux/inetdevice.h
--- linux-2.6.2-rc1/include/linux/inetdevice.h  2004-01-08 22:59:45.000000000 -0800
+++ linux-2.6.2-rc1F2/include/linux/inetdevice.h      2004-01-23 14:55:52.000000000 -0800
@@ -21,6 +21,7 @@
      int   medium_id;
      int   no_xfrm;
      int   no_policy;
+     int   force_igmp_version;
      void  *sysctl;
 };

diff -ruN linux-2.6.2-rc1/include/linux/sysctl.h linux-2.6.2-rc1F2/include/linux/sysctl.h
--- linux-2.6.2-rc1/include/linux/sysctl.h      2004-01-21 14:03:34.000000000 -0800
+++ linux-2.6.2-rc1F2/include/linux/sysctl.h    2004-01-23 14:55:52.000000000 -0800
@@ -360,6 +360,7 @@
      NET_IPV4_CONF_MEDIUM_ID=14,
      NET_IPV4_CONF_NOXFRM=15,
      NET_IPV4_CONF_NOPOLICY=16,
+     NET_IPV4_CONF_FORCE_IGMP_VERSION=17,
 };

 /* /proc/sys/net/ipv4/netfilter */
diff -ruN linux-2.6.2-rc1/net/ipv4/devinet.c linux-2.6.2-rc1F2/net/ipv4/devinet.c
--- linux-2.6.2-rc1/net/ipv4/devinet.c    2004-01-21 14:03:35.000000000 -0800
+++ linux-2.6.2-rc1F2/net/ipv4/devinet.c  2004-01-26 16:34:31.000000000 -0800
@@ -1132,7 +1132,7 @@

 static struct devinet_sysctl_table {
      struct ctl_table_header *sysctl_header;
-     ctl_table         devinet_vars[17];
+     ctl_table         devinet_vars[18];
      ctl_table         devinet_dev[2];
      ctl_table         devinet_conf_dir[2];
      ctl_table         devinet_proto_dir[2];
@@ -1269,6 +1269,15 @@
                  .proc_handler     = &ipv4_doint_and_flush,
                  .strategy   = &ipv4_doint_and_flush_strategy,
            },
+           {
+                 .ctl_name   = NET_IPV4_CONF_FORCE_IGMP_VERSION,
+                 .procname   = "force_igmp_version",
+                 .data       = &ipv4_devconf.force_igmp_version,
+                 .maxlen           = sizeof(int),
+                 .mode       = 0644,
+                 .proc_handler     = &ipv4_doint_and_flush,
+                 .strategy   = &ipv4_doint_and_flush_strategy,
+           },
      },
      .devinet_dev = {
            {
diff -ruN linux-2.6.2-rc1/net/ipv4/igmp.c linux-2.6.2-rc1F2/net/ipv4/igmp.c
--- linux-2.6.2-rc1/net/ipv4/igmp.c 2004-01-21 14:03:35.000000000 -0800
+++ linux-2.6.2-rc1F2/net/ipv4/igmp.c     2004-01-26 17:18:28.000000000 -0800
@@ -126,10 +126,14 @@
  * contradict to specs provided this delay is small enough.
  */

-#define IGMP_V1_SEEN(in_dev) ((in_dev)->mr_v1_seen && \
-           time_before(jiffies, (in_dev)->mr_v1_seen))
-#define IGMP_V2_SEEN(in_dev) ((in_dev)->mr_v2_seen && \
-           time_before(jiffies, (in_dev)->mr_v2_seen))
+#define IGMP_V1_SEEN(in_dev) (ipv4_devconf.force_igmp_version == 1 || \
+           (in_dev)->cnf.force_igmp_version == 1 || \
+           ((in_dev)->mr_v1_seen && \
+           time_before(jiffies, (in_dev)->mr_v1_seen)))
+#define IGMP_V2_SEEN(in_dev) (ipv4_devconf.force_igmp_version == 2 || \
+           (in_dev)->cnf.force_igmp_version == 2 || \
+           ((in_dev)->mr_v2_seen && \
+           time_before(jiffies, (in_dev)->mr_v2_seen)))

 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);
 static void igmpv3_del_delrec(struct in_device *in_dev, __u32 multiaddr);

(See attached file: igmpsysctl.patch)
--1__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Below is a patch that allows forcing of the IGMP version. The primary<br>
use would be with an IGMP-snooping switch that doesn't grok IGMPv3<br>
packet formats and when there are no IGMPv2 or IGMPv1 multicast<br>
routers on the network. By forcing the IGMP reports to version 2 (or<br>
version 1, for really old switches), Linux would send reports that the<br>
switch can understand for multicast forwarding to the port.<br>
<br>
				+-DLS<br>
<br>
in-line and attached, for whitespace issues.<br>
<br>
diff -ruN linux-2.6.2-rc1/include/linux/inetdevice.h linux-2.6.2-rc1F2/include/linux/inetdevice.h<br>
--- linux-2.6.2-rc1/include/linux/inetdevice.h	2004-01-08 22:59:45.000000000 -0800<br>
+++ linux-2.6.2-rc1F2/include/linux/inetdevice.h	2004-01-23 14:55:52.000000000 -0800<br>
@@ -21,6 +21,7 @@<br>
 	int	medium_id;<br>
 	int	no_xfrm;<br>
 	int	no_policy;<br>
+	int	force_igmp_version;<br>
 	void	*sysctl;<br>
 };<br>
 <br>
diff -ruN linux-2.6.2-rc1/include/linux/sysctl.h linux-2.6.2-rc1F2/include/linux/sysctl.h<br>
--- linux-2.6.2-rc1/include/linux/sysctl.h	2004-01-21 14:03:34.000000000 -0800<br>
+++ linux-2.6.2-rc1F2/include/linux/sysctl.h	2004-01-23 14:55:52.000000000 -0800<br>
@@ -360,6 +360,7 @@<br>
 	NET_IPV4_CONF_MEDIUM_ID=14,<br>
 	NET_IPV4_CONF_NOXFRM=15,<br>
 	NET_IPV4_CONF_NOPOLICY=16,<br>
+	NET_IPV4_CONF_FORCE_IGMP_VERSION=17,<br>
 };<br>
 <br>
 /* /proc/sys/net/ipv4/netfilter */<br>
diff -ruN linux-2.6.2-rc1/net/ipv4/devinet.c linux-2.6.2-rc1F2/net/ipv4/devinet.c<br>
--- linux-2.6.2-rc1/net/ipv4/devinet.c	2004-01-21 14:03:35.000000000 -0800<br>
+++ linux-2.6.2-rc1F2/net/ipv4/devinet.c	2004-01-26 16:34:31.000000000 -0800<br>
@@ -1132,7 +1132,7 @@<br>
 <br>
 static struct devinet_sysctl_table {<br>
 	struct ctl_table_header *sysctl_header;<br>
-	ctl_table		devinet_vars[17];<br>
+	ctl_table		devinet_vars[18];<br>
 	ctl_table		devinet_dev[2];<br>
 	ctl_table		devinet_conf_dir[2];<br>
 	ctl_table		devinet_proto_dir[2];<br>
@@ -1269,6 +1269,15 @@<br>
 			.proc_handler	= &amp;ipv4_doint_and_flush,<br>
 			.strategy	= &amp;ipv4_doint_and_flush_strategy,<br>
 		},<br>
+		{<br>
+			.ctl_name	= NET_IPV4_CONF_FORCE_IGMP_VERSION,<br>
+			.procname	= &quot;force_igmp_version&quot;,<br>
+			.data		= &amp;ipv4_devconf.force_igmp_version,<br>
+			.maxlen		= sizeof(int),<br>
+			.mode		= 0644,<br>
+			.proc_handler	= &amp;ipv4_doint_and_flush,<br>
+			.strategy	= &amp;ipv4_doint_and_flush_strategy,<br>
+		},<br>
 	},<br>
 	.devinet_dev = {<br>
 		{<br>
diff -ruN linux-2.6.2-rc1/net/ipv4/igmp.c linux-2.6.2-rc1F2/net/ipv4/igmp.c<br>
--- linux-2.6.2-rc1/net/ipv4/igmp.c	2004-01-21 14:03:35.000000000 -0800<br>
+++ linux-2.6.2-rc1F2/net/ipv4/igmp.c	2004-01-26 17:18:28.000000000 -0800<br>
@@ -126,10 +126,14 @@<br>
  * contradict to specs provided this delay is small enough.<br>
  */<br>
 <br>
-#define IGMP_V1_SEEN(in_dev) ((in_dev)-&gt;mr_v1_seen &amp;&amp; \<br>
-		time_before(jiffies, (in_dev)-&gt;mr_v1_seen))<br>
-#define IGMP_V2_SEEN(in_dev) ((in_dev)-&gt;mr_v2_seen &amp;&amp; \<br>
-		time_before(jiffies, (in_dev)-&gt;mr_v2_seen))<br>
+#define IGMP_V1_SEEN(in_dev) (ipv4_devconf.force_igmp_version == 1 || \<br>
+		(in_dev)-&gt;cnf.force_igmp_version == 1 || \<br>
+		((in_dev)-&gt;mr_v1_seen &amp;&amp; \<br>
+		time_before(jiffies, (in_dev)-&gt;mr_v1_seen)))<br>
+#define IGMP_V2_SEEN(in_dev) (ipv4_devconf.force_igmp_version == 2 || \<br>
+		(in_dev)-&gt;cnf.force_igmp_version == 2 || \<br>
+		((in_dev)-&gt;mr_v2_seen &amp;&amp; \<br>
+		time_before(jiffies, (in_dev)-&gt;mr_v2_seen)))<br>
 <br>
 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);<br>
 static void igmpv3_del_delrec(struct in_device *in_dev, __u32 multiaddr);<br>
<br>
<i>(See attached file: igmpsysctl.patch)</i><br>
</body></html>

--1__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F--


--0__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F
Content-type: application/octet-stream;
	name="igmpsysctl.patch"
Content-Disposition: attachment; filename="igmpsysctl.patch"
Content-ID: <10__=07BBE4BBDFE06D6F8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yLXJjMS9pbmNsdWRlL2xpbnV4L2luZXRkZXZpY2UuaCBsaW51
eC0yLjYuMi1yYzFGMi9pbmNsdWRlL2xpbnV4L2luZXRkZXZpY2UuaAotLS0gbGludXgtMi42LjIt
cmMxL2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oCTIwMDQtMDEtMDggMjI6NTk6NDUuMDAwMDAw
MDAwIC0wODAwCisrKyBsaW51eC0yLjYuMi1yYzFGMi9pbmNsdWRlL2xpbnV4L2luZXRkZXZpY2Uu
aAkyMDA0LTAxLTIzIDE0OjU1OjUyLjAwMDAwMDAwMCAtMDgwMApAQCAtMjEsNiArMjEsNyBAQAog
CWludAltZWRpdW1faWQ7CiAJaW50CW5vX3hmcm07CiAJaW50CW5vX3BvbGljeTsKKwlpbnQJZm9y
Y2VfaWdtcF92ZXJzaW9uOwogCXZvaWQJKnN5c2N0bDsKIH07CiAKZGlmZiAtcnVOIGxpbnV4LTIu
Ni4yLXJjMS9pbmNsdWRlL2xpbnV4L3N5c2N0bC5oIGxpbnV4LTIuNi4yLXJjMUYyL2luY2x1ZGUv
bGludXgvc3lzY3RsLmgKLS0tIGxpbnV4LTIuNi4yLXJjMS9pbmNsdWRlL2xpbnV4L3N5c2N0bC5o
CTIwMDQtMDEtMjEgMTQ6MDM6MzQuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMi1yYzFG
Mi9pbmNsdWRlL2xpbnV4L3N5c2N0bC5oCTIwMDQtMDEtMjMgMTQ6NTU6NTIuMDAwMDAwMDAwIC0w
ODAwCkBAIC0zNjAsNiArMzYwLDcgQEAKIAlORVRfSVBWNF9DT05GX01FRElVTV9JRD0xNCwKIAlO
RVRfSVBWNF9DT05GX05PWEZSTT0xNSwKIAlORVRfSVBWNF9DT05GX05PUE9MSUNZPTE2LAorCU5F
VF9JUFY0X0NPTkZfRk9SQ0VfSUdNUF9WRVJTSU9OPTE3LAogfTsKIAogLyogL3Byb2Mvc3lzL25l
dC9pcHY0L25ldGZpbHRlciAqLwpkaWZmIC1ydU4gbGludXgtMi42LjItcmMxL25ldC9pcHY0L2Rl
dmluZXQuYyBsaW51eC0yLjYuMi1yYzFGMi9uZXQvaXB2NC9kZXZpbmV0LmMKLS0tIGxpbnV4LTIu
Ni4yLXJjMS9uZXQvaXB2NC9kZXZpbmV0LmMJMjAwNC0wMS0yMSAxNDowMzozNS4wMDAwMDAwMDAg
LTA4MDAKKysrIGxpbnV4LTIuNi4yLXJjMUYyL25ldC9pcHY0L2RldmluZXQuYwkyMDA0LTAxLTI2
IDE2OjM0OjMxLjAwMDAwMDAwMCAtMDgwMApAQCAtMTEzMiw3ICsxMTMyLDcgQEAKIAogc3RhdGlj
IHN0cnVjdCBkZXZpbmV0X3N5c2N0bF90YWJsZSB7CiAJc3RydWN0IGN0bF90YWJsZV9oZWFkZXIg
KnN5c2N0bF9oZWFkZXI7Ci0JY3RsX3RhYmxlCQlkZXZpbmV0X3ZhcnNbMTddOworCWN0bF90YWJs
ZQkJZGV2aW5ldF92YXJzWzE4XTsKIAljdGxfdGFibGUJCWRldmluZXRfZGV2WzJdOwogCWN0bF90
YWJsZQkJZGV2aW5ldF9jb25mX2RpclsyXTsKIAljdGxfdGFibGUJCWRldmluZXRfcHJvdG9fZGly
WzJdOwpAQCAtMTI2OSw2ICsxMjY5LDE1IEBACiAJCQkucHJvY19oYW5kbGVyCT0gJmlwdjRfZG9p
bnRfYW5kX2ZsdXNoLAogCQkJLnN0cmF0ZWd5CT0gJmlwdjRfZG9pbnRfYW5kX2ZsdXNoX3N0cmF0
ZWd5LAogCQl9LAorCQl7CisJCQkuY3RsX25hbWUJPSBORVRfSVBWNF9DT05GX0ZPUkNFX0lHTVBf
VkVSU0lPTiwKKwkJCS5wcm9jbmFtZQk9ICJmb3JjZV9pZ21wX3ZlcnNpb24iLAorCQkJLmRhdGEJ
CT0gJmlwdjRfZGV2Y29uZi5mb3JjZV9pZ21wX3ZlcnNpb24sCisJCQkubWF4bGVuCQk9IHNpemVv
ZihpbnQpLAorCQkJLm1vZGUJCT0gMDY0NCwKKwkJCS5wcm9jX2hhbmRsZXIJPSAmaXB2NF9kb2lu
dF9hbmRfZmx1c2gsCisJCQkuc3RyYXRlZ3kJPSAmaXB2NF9kb2ludF9hbmRfZmx1c2hfc3RyYXRl
Z3ksCisJCX0sCiAJfSwKIAkuZGV2aW5ldF9kZXYgPSB7CiAJCXsKZGlmZiAtcnVOIGxpbnV4LTIu
Ni4yLXJjMS9uZXQvaXB2NC9pZ21wLmMgbGludXgtMi42LjItcmMxRjIvbmV0L2lwdjQvaWdtcC5j
Ci0tLSBsaW51eC0yLjYuMi1yYzEvbmV0L2lwdjQvaWdtcC5jCTIwMDQtMDEtMjEgMTQ6MDM6MzUu
MDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMi1yYzFGMi9uZXQvaXB2NC9pZ21wLmMJMjAw
NC0wMS0yNiAxNzoxODoyOC4wMDAwMDAwMDAgLTA4MDAKQEAgLTEyNiwxMCArMTI2LDE0IEBACiAg
KiBjb250cmFkaWN0IHRvIHNwZWNzIHByb3ZpZGVkIHRoaXMgZGVsYXkgaXMgc21hbGwgZW5vdWdo
LgogICovCiAKLSNkZWZpbmUgSUdNUF9WMV9TRUVOKGluX2RldikgKChpbl9kZXYpLT5tcl92MV9z
ZWVuICYmIFwKLQkJdGltZV9iZWZvcmUoamlmZmllcywgKGluX2RldiktPm1yX3YxX3NlZW4pKQot
I2RlZmluZSBJR01QX1YyX1NFRU4oaW5fZGV2KSAoKGluX2RldiktPm1yX3YyX3NlZW4gJiYgXAot
CQl0aW1lX2JlZm9yZShqaWZmaWVzLCAoaW5fZGV2KS0+bXJfdjJfc2VlbikpCisjZGVmaW5lIElH
TVBfVjFfU0VFTihpbl9kZXYpIChpcHY0X2RldmNvbmYuZm9yY2VfaWdtcF92ZXJzaW9uID09IDEg
fHwgXAorCQkoaW5fZGV2KS0+Y25mLmZvcmNlX2lnbXBfdmVyc2lvbiA9PSAxIHx8IFwKKwkJKChp
bl9kZXYpLT5tcl92MV9zZWVuICYmIFwKKwkJdGltZV9iZWZvcmUoamlmZmllcywgKGluX2Rldikt
Pm1yX3YxX3NlZW4pKSkKKyNkZWZpbmUgSUdNUF9WMl9TRUVOKGluX2RldikgKGlwdjRfZGV2Y29u
Zi5mb3JjZV9pZ21wX3ZlcnNpb24gPT0gMiB8fCBcCisJCShpbl9kZXYpLT5jbmYuZm9yY2VfaWdt
cF92ZXJzaW9uID09IDIgfHwgXAorCQkoKGluX2RldiktPm1yX3YyX3NlZW4gJiYgXAorCQl0aW1l
X2JlZm9yZShqaWZmaWVzLCAoaW5fZGV2KS0+bXJfdjJfc2VlbikpKQogCiBzdGF0aWMgdm9pZCBp
Z21wdjNfYWRkX2RlbHJlYyhzdHJ1Y3QgaW5fZGV2aWNlICppbl9kZXYsIHN0cnVjdCBpcF9tY19s
aXN0ICppbSk7CiBzdGF0aWMgdm9pZCBpZ21wdjNfZGVsX2RlbHJlYyhzdHJ1Y3QgaW5fZGV2aWNl
ICppbl9kZXYsIF9fdTMyIG11bHRpYWRkcik7Cg==

--0__=07BBE4BBDFE06D6F8f9e8a93df938690918c07BBE4BBDFE06D6F--
