From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: sysctl variable to force IGMP version [PATCH]
Date: Fri, 30 Jan 2004 13:49:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF34FD3286.9A3C5534-ON88256E2B.007200D9@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649
Content-type: multipart/alternative;
	Boundary="1__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649"

--1__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649
Content-type: text/plain; charset=US-ASCII






Dave,
      Here's the 2.4.x version of the "force IGMP version" sysctl patch.

                        +-DLS

diff -ruN linux-2.4.25-pre8/include/linux/inetdevice.h linux-2.4.25-pre8F1/include/linux/inetdevice.h
--- linux-2.4.25-pre8/include/linux/inetdevice.h      2003-08-25 04:44:44.000000000 -0700
+++ linux-2.4.25-pre8F1/include/linux/inetdevice.h    2004-01-29 16:24:53.000000000 -0800
@@ -19,6 +19,7 @@
      int   tag;
      int     arp_filter;
      int   medium_id;
+     int   force_igmp_version;
      void  *sysctl;
 };

diff -ruN linux-2.4.25-pre8/include/linux/sysctl.h linux-2.4.25-pre8F1/include/linux/sysctl.h
--- linux-2.4.25-pre8/include/linux/sysctl.h    2004-01-29 16:21:28.000000000 -0800
+++ linux-2.4.25-pre8F1/include/linux/sysctl.h  2004-01-29 16:39:42.000000000 -0800
@@ -359,6 +359,7 @@
      NET_IPV4_CONF_TAG=12,
      NET_IPV4_CONF_ARPFILTER=13,
      NET_IPV4_CONF_MEDIUM_ID=14,
+     NET_IPV4_CONF_FORCE_IGMP_VERSION=15,
 };

 /* /proc/sys/net/ipv4/netfilter */
diff -ruN linux-2.4.25-pre8/net/ipv4/devinet.c linux-2.4.25-pre8F1/net/ipv4/devinet.c
--- linux-2.4.25-pre8/net/ipv4/devinet.c  2003-11-28 10:26:21.000000000 -0800
+++ linux-2.4.25-pre8F1/net/ipv4/devinet.c      2004-01-29 16:33:23.000000000 -0800
@@ -1057,7 +1057,7 @@
 static struct devinet_sysctl_table
 {
      struct ctl_table_header *sysctl_header;
-     ctl_table devinet_vars[15];
+     ctl_table devinet_vars[16];
      ctl_table devinet_dev[2];
      ctl_table devinet_conf_dir[2];
      ctl_table devinet_proto_dir[2];
@@ -1106,6 +1106,9 @@
      {NET_IPV4_CONF_ARPFILTER, "arp_filter",
       &ipv4_devconf.arp_filter, sizeof(int), 0644, NULL,
       &proc_dointvec},
+     {NET_IPV4_CONF_FORCE_IGMP_VERSION, "force_igmp_version",
+      &ipv4_devconf.force_igmp_version, sizeof(int), 0644, NULL,
+      &proc_dointvec},
       {0}},

      {{NET_PROTO_CONF_ALL, "all", NULL, 0, 0555, devinet_sysctl.devinet_vars},{0}},
diff -ruN linux-2.4.25-pre8/net/ipv4/igmp.c linux-2.4.25-pre8F1/net/ipv4/igmp.c
--- linux-2.4.25-pre8/net/ipv4/igmp.c     2004-01-29 16:21:28.000000000 -0800
+++ linux-2.4.25-pre8F1/net/ipv4/igmp.c   2004-01-29 16:22:55.000000000 -0800
@@ -122,10 +122,14 @@
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

(See attached file: 2.4igmpsysctl.patch)
--1__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Dave,<br>
	Here's the 2.4.x version of the &quot;force IGMP version&quot; sysctl patch.<br>
<br>
				+-DLS<br>
<br>
diff -ruN linux-2.4.25-pre8/include/linux/inetdevice.h linux-2.4.25-pre8F1/include/linux/inetdevice.h<br>
--- linux-2.4.25-pre8/include/linux/inetdevice.h	2003-08-25 04:44:44.000000000 -0700<br>
+++ linux-2.4.25-pre8F1/include/linux/inetdevice.h	2004-01-29 16:24:53.000000000 -0800<br>
@@ -19,6 +19,7 @@<br>
 	int	tag;<br>
 	int     arp_filter;<br>
 	int	medium_id;<br>
+	int	force_igmp_version;<br>
 	void	*sysctl;<br>
 };<br>
 <br>
diff -ruN linux-2.4.25-pre8/include/linux/sysctl.h linux-2.4.25-pre8F1/include/linux/sysctl.h<br>
--- linux-2.4.25-pre8/include/linux/sysctl.h	2004-01-29 16:21:28.000000000 -0800<br>
+++ linux-2.4.25-pre8F1/include/linux/sysctl.h	2004-01-29 16:39:42.000000000 -0800<br>
@@ -359,6 +359,7 @@<br>
 	NET_IPV4_CONF_TAG=12,<br>
 	NET_IPV4_CONF_ARPFILTER=13,<br>
 	NET_IPV4_CONF_MEDIUM_ID=14,<br>
+	NET_IPV4_CONF_FORCE_IGMP_VERSION=15,<br>
 };<br>
 <br>
 /* /proc/sys/net/ipv4/netfilter */<br>
diff -ruN linux-2.4.25-pre8/net/ipv4/devinet.c linux-2.4.25-pre8F1/net/ipv4/devinet.c<br>
--- linux-2.4.25-pre8/net/ipv4/devinet.c	2003-11-28 10:26:21.000000000 -0800<br>
+++ linux-2.4.25-pre8F1/net/ipv4/devinet.c	2004-01-29 16:33:23.000000000 -0800<br>
@@ -1057,7 +1057,7 @@<br>
 static struct devinet_sysctl_table<br>
 {<br>
 	struct ctl_table_header *sysctl_header;<br>
-	ctl_table devinet_vars[15];<br>
+	ctl_table devinet_vars[16];<br>
 	ctl_table devinet_dev[2];<br>
 	ctl_table devinet_conf_dir[2];<br>
 	ctl_table devinet_proto_dir[2];<br>
@@ -1106,6 +1106,9 @@<br>
 	{NET_IPV4_CONF_ARPFILTER, &quot;arp_filter&quot;,<br>
 	 &amp;ipv4_devconf.arp_filter, sizeof(int), 0644, NULL,<br>
 	 &amp;proc_dointvec},<br>
+	{NET_IPV4_CONF_FORCE_IGMP_VERSION, &quot;force_igmp_version&quot;,<br>
+	 &amp;ipv4_devconf.force_igmp_version, sizeof(int), 0644, NULL,<br>
+	 &amp;proc_dointvec},<br>
 	 {0}},<br>
 <br>
 	{{NET_PROTO_CONF_ALL, &quot;all&quot;, NULL, 0, 0555, devinet_sysctl.devinet_vars},{0}},<br>
diff -ruN linux-2.4.25-pre8/net/ipv4/igmp.c linux-2.4.25-pre8F1/net/ipv4/igmp.c<br>
--- linux-2.4.25-pre8/net/ipv4/igmp.c	2004-01-29 16:21:28.000000000 -0800<br>
+++ linux-2.4.25-pre8F1/net/ipv4/igmp.c	2004-01-29 16:22:55.000000000 -0800<br>
@@ -122,10 +122,14 @@<br>
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
<i>(See attached file: 2.4igmpsysctl.patch)</i><br>
</body></html>

--1__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649--


--0__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649
Content-type: application/octet-stream;
	name="2.4igmpsysctl.patch"
Content-Disposition: attachment; filename="2.4igmpsysctl.patch"
Content-ID: <10__=07BBE4B8DFE186498f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNS1wcmU4L2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oIGxp
bnV4LTIuNC4yNS1wcmU4RjEvaW5jbHVkZS9saW51eC9pbmV0ZGV2aWNlLmgKLS0tIGxpbnV4LTIu
NC4yNS1wcmU4L2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oCTIwMDMtMDgtMjUgMDQ6NDQ6NDQu
MDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjQuMjUtcHJlOEYxL2luY2x1ZGUvbGludXgvaW5l
dGRldmljZS5oCTIwMDQtMDEtMjkgMTY6MjQ6NTMuMDAwMDAwMDAwIC0wODAwCkBAIC0xOSw2ICsx
OSw3IEBACiAJaW50CXRhZzsKIAlpbnQgICAgIGFycF9maWx0ZXI7CiAJaW50CW1lZGl1bV9pZDsK
KwlpbnQJZm9yY2VfaWdtcF92ZXJzaW9uOwogCXZvaWQJKnN5c2N0bDsKIH07CiAKZGlmZiAtcnVO
IGxpbnV4LTIuNC4yNS1wcmU4L2luY2x1ZGUvbGludXgvc3lzY3RsLmggbGludXgtMi40LjI1LXBy
ZThGMS9pbmNsdWRlL2xpbnV4L3N5c2N0bC5oCi0tLSBsaW51eC0yLjQuMjUtcHJlOC9pbmNsdWRl
L2xpbnV4L3N5c2N0bC5oCTIwMDQtMDEtMjkgMTY6MjE6MjguMDAwMDAwMDAwIC0wODAwCisrKyBs
aW51eC0yLjQuMjUtcHJlOEYxL2luY2x1ZGUvbGludXgvc3lzY3RsLmgJMjAwNC0wMS0yOSAxNjoz
OTo0Mi4wMDAwMDAwMDAgLTA4MDAKQEAgLTM1OSw2ICszNTksNyBAQAogCU5FVF9JUFY0X0NPTkZf
VEFHPTEyLAogCU5FVF9JUFY0X0NPTkZfQVJQRklMVEVSPTEzLAogCU5FVF9JUFY0X0NPTkZfTUVE
SVVNX0lEPTE0LAorCU5FVF9JUFY0X0NPTkZfRk9SQ0VfSUdNUF9WRVJTSU9OPTE1LAogfTsKIAog
LyogL3Byb2Mvc3lzL25ldC9pcHY0L25ldGZpbHRlciAqLwpkaWZmIC1ydU4gbGludXgtMi40LjI1
LXByZTgvbmV0L2lwdjQvZGV2aW5ldC5jIGxpbnV4LTIuNC4yNS1wcmU4RjEvbmV0L2lwdjQvZGV2
aW5ldC5jCi0tLSBsaW51eC0yLjQuMjUtcHJlOC9uZXQvaXB2NC9kZXZpbmV0LmMJMjAwMy0xMS0y
OCAxMDoyNjoyMS4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNC4yNS1wcmU4RjEvbmV0L2lw
djQvZGV2aW5ldC5jCTIwMDQtMDEtMjkgMTY6MzM6MjMuMDAwMDAwMDAwIC0wODAwCkBAIC0xMDU3
LDcgKzEwNTcsNyBAQAogc3RhdGljIHN0cnVjdCBkZXZpbmV0X3N5c2N0bF90YWJsZQogewogCXN0
cnVjdCBjdGxfdGFibGVfaGVhZGVyICpzeXNjdGxfaGVhZGVyOwotCWN0bF90YWJsZSBkZXZpbmV0
X3ZhcnNbMTVdOworCWN0bF90YWJsZSBkZXZpbmV0X3ZhcnNbMTZdOwogCWN0bF90YWJsZSBkZXZp
bmV0X2RldlsyXTsKIAljdGxfdGFibGUgZGV2aW5ldF9jb25mX2RpclsyXTsKIAljdGxfdGFibGUg
ZGV2aW5ldF9wcm90b19kaXJbMl07CkBAIC0xMTA2LDYgKzExMDYsOSBAQAogCXtORVRfSVBWNF9D
T05GX0FSUEZJTFRFUiwgImFycF9maWx0ZXIiLAogCSAmaXB2NF9kZXZjb25mLmFycF9maWx0ZXIs
IHNpemVvZihpbnQpLCAwNjQ0LCBOVUxMLAogCSAmcHJvY19kb2ludHZlY30sCisJe05FVF9JUFY0
X0NPTkZfRk9SQ0VfSUdNUF9WRVJTSU9OLCAiZm9yY2VfaWdtcF92ZXJzaW9uIiwKKwkgJmlwdjRf
ZGV2Y29uZi5mb3JjZV9pZ21wX3ZlcnNpb24sIHNpemVvZihpbnQpLCAwNjQ0LCBOVUxMLAorCSAm
cHJvY19kb2ludHZlY30sCiAJIHswfX0sCiAKIAl7e05FVF9QUk9UT19DT05GX0FMTCwgImFsbCIs
IE5VTEwsIDAsIDA1NTUsIGRldmluZXRfc3lzY3RsLmRldmluZXRfdmFyc30sezB9fSwKZGlmZiAt
cnVOIGxpbnV4LTIuNC4yNS1wcmU4L25ldC9pcHY0L2lnbXAuYyBsaW51eC0yLjQuMjUtcHJlOEYx
L25ldC9pcHY0L2lnbXAuYwotLS0gbGludXgtMi40LjI1LXByZTgvbmV0L2lwdjQvaWdtcC5jCTIw
MDQtMDEtMjkgMTY6MjE6MjguMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjUtcHJlOEYx
L25ldC9pcHY0L2lnbXAuYwkyMDA0LTAxLTI5IDE2OjIyOjU1LjAwMDAwMDAwMCAtMDgwMApAQCAt
MTIyLDEwICsxMjIsMTQgQEAKICAqIGNvbnRyYWRpY3QgdG8gc3BlY3MgcHJvdmlkZWQgdGhpcyBk
ZWxheSBpcyBzbWFsbCBlbm91Z2guCiAgKi8KIAotI2RlZmluZSBJR01QX1YxX1NFRU4oaW5fZGV2
KSAoKGluX2RldiktPm1yX3YxX3NlZW4gJiYgXAotCQl0aW1lX2JlZm9yZShqaWZmaWVzLCAoaW5f
ZGV2KS0+bXJfdjFfc2VlbikpCi0jZGVmaW5lIElHTVBfVjJfU0VFTihpbl9kZXYpICgoaW5fZGV2
KS0+bXJfdjJfc2VlbiAmJiBcCi0JCXRpbWVfYmVmb3JlKGppZmZpZXMsIChpbl9kZXYpLT5tcl92
Ml9zZWVuKSkKKyNkZWZpbmUgSUdNUF9WMV9TRUVOKGluX2RldikgKGlwdjRfZGV2Y29uZi5mb3Jj
ZV9pZ21wX3ZlcnNpb24gPT0gMSB8fCBcCisJCShpbl9kZXYpLT5jbmYuZm9yY2VfaWdtcF92ZXJz
aW9uID09IDEgfHwgXAorCQkoKGluX2RldiktPm1yX3YxX3NlZW4gJiYgXAorCQl0aW1lX2JlZm9y
ZShqaWZmaWVzLCAoaW5fZGV2KS0+bXJfdjFfc2VlbikpKQorI2RlZmluZSBJR01QX1YyX1NFRU4o
aW5fZGV2KSAoaXB2NF9kZXZjb25mLmZvcmNlX2lnbXBfdmVyc2lvbiA9PSAyIHx8IFwKKwkJKGlu
X2RldiktPmNuZi5mb3JjZV9pZ21wX3ZlcnNpb24gPT0gMiB8fCBcCisJCSgoaW5fZGV2KS0+bXJf
djJfc2VlbiAmJiBcCisJCXRpbWVfYmVmb3JlKGppZmZpZXMsIChpbl9kZXYpLT5tcl92Ml9zZWVu
KSkpCiAKIHN0YXRpYyB2b2lkIGlnbXB2M19hZGRfZGVscmVjKHN0cnVjdCBpbl9kZXZpY2UgKmlu
X2Rldiwgc3RydWN0IGlwX21jX2xpc3QgKmltKTsKIHN0YXRpYyB2b2lkIGlnbXB2M19kZWxfZGVs
cmVjKHN0cnVjdCBpbl9kZXZpY2UgKmluX2RldiwgX191MzIgbXVsdGlhZGRyKTsK

--0__=07BBE4B8DFE186498f9e8a93df938690918c07BBE4B8DFE18649--
