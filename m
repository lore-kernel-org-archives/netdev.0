From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] multi-protocol MSF API sysctl limit support
Date: Sat, 6 Mar 2004 02:37:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF98DA688D.A9E1181F-ON88256E4F.00342F53-88256E4F.00349E68@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3
Content-type: multipart/alternative;
	Boundary="1__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3"

--1__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3
Content-type: text/plain; charset=US-ASCII





This patch adds support for administrator-controlled multicast source
filter limits for the multiprotocol multicast source filter API. The v4
portion
uses the same sysctl variable as the previous v4-only API patch, and
the v6 portion uses a new v6 sysctl variable, "mld_max_msf".

In-line 2.4.x and attached 2.4.x and 2.6.x versions.

                        +-DLS

diff -ruN linux-2.4.25F4/include/linux/sysctl.h linux-2.4.25F5/include/linux/sysctl.h
--- linux-2.4.25F4/include/linux/sysctl.h 2004-03-04 17:02:54.000000000 -0800
+++ linux-2.4.25F5/include/linux/sysctl.h 2004-03-05 00:02:57.000000000 -0800
@@ -388,7 +388,8 @@
      NET_IPV6_NEIGH=17,
      NET_IPV6_ROUTE=18,
      NET_IPV6_ICMP=19,
-     NET_IPV6_BINDV6ONLY=20
+     NET_IPV6_BINDV6ONLY=20,
+     NET_IPV6_MLD_MAX_MSF=25,
 };

 enum {
diff -ruN linux-2.4.25F4/include/net/ipv6.h linux-2.4.25F5/include/net/ipv6.h
--- linux-2.4.25F4/include/net/ipv6.h     2004-03-04 17:15:19.000000000 -0800
+++ linux-2.4.25F5/include/net/ipv6.h     2004-03-05 00:19:31.000000000 -0800
@@ -104,6 +104,7 @@

 /* sysctls */
 extern int sysctl_ipv6_bindv6only;
+extern int sysctl_mld_max_msf;

 extern struct ipv6_mib       ipv6_statistics[NR_CPUS*2];
 #define IP6_INC_STATS(field)       SNMP_INC_STATS(ipv6_statistics, field)
diff -ruN linux-2.4.25F4/net/ipv4/ip_sockglue.c linux-2.4.25F5/net/ipv4/ip_sockglue.c
--- linux-2.4.25F4/net/ipv4/ip_sockglue.c 2004-03-04 19:29:33.000000000 -0800
+++ linux-2.4.25F5/net/ipv4/ip_sockglue.c 2004-03-05 16:21:06.000000000 -0800
@@ -762,6 +762,8 @@
            }
            case MCAST_MSFILTER:
            {
+                 extern int sysctl_optmem_max;
+                 extern int sysctl_igmp_max_msf;
                  struct sockaddr_in *psin;
                  struct ip_msfilter *msf = 0;
                  struct group_filter *gsf = 0;
@@ -769,6 +771,10 @@

                  if (optlen < GROUP_FILTER_SIZE(0))
                        goto e_inval;
+                 if (optlen > sysctl_optmem_max) {
+                       err = -ENOBUFS;
+                       break;
+                 }
                  gsf = (struct group_filter *)kmalloc(optlen,GFP_KERNEL);
                  if (gsf == 0) {
                        err = -ENOBUFS;
@@ -778,7 +784,13 @@
                  if (copy_from_user(gsf, optval, optlen)) {
                        goto mc_msf_out;
                  }
-                 if (GROUP_FILTER_SIZE(gsf->gf_numsrc) < optlen) {
+                 /* numsrc >= (4G-140)/128 overflow in 32 bits */
+                 if (gsf->gf_numsrc >= 0x1ffffff ||
+                     gsf->gf_numsrc > sysctl_igmp_max_msf) {
+                       err = -ENOBUFS;
+                       goto mc_msf_out;
+                 }
+                 if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
                        err = EINVAL;
                        goto mc_msf_out;
                  }
diff -ruN linux-2.4.25F4/net/ipv6/ipv6_sockglue.c linux-2.4.25F5/net/ipv6/ipv6_sockglue.c
--- linux-2.4.25F4/net/ipv6/ipv6_sockglue.c     2004-02-23 16:35:09.000000000 -0800
+++ linux-2.4.25F5/net/ipv6/ipv6_sockglue.c     2004-03-05 01:57:30.000000000 -0800
@@ -453,6 +453,7 @@
      case MCAST_MSFILTER:
      {
            extern int sysctl_optmem_max;
+           extern int sysctl_mld_max_msf;
            struct group_filter *gsf;

            if (optlen < GROUP_FILTER_SIZE(0))
@@ -471,8 +472,14 @@
                  kfree(gsf);
                  break;
            }
-           if (GROUP_FILTER_SIZE(gsf->gf_numsrc) < GROUP_FILTER_SIZE(0) ||
-               GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
+           /* numsrc >= (4G-140)/128 overflow in 32 bits */
+           if (gsf->gf_numsrc >= 0x1ffffffU ||
+               gsf->gf_numsrc > sysctl_mld_max_msf) {
+                 kfree(gsf);
+                 retv = -ENOBUFS;
+                 break;
+           }
+           if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
                  kfree(gsf);
                  retv = -EINVAL;
                  break;
diff -ruN linux-2.4.25F4/net/ipv6/mcast.c linux-2.4.25F5/net/ipv6/mcast.c
--- linux-2.4.25F4/net/ipv6/mcast.c 2004-02-18 05:36:32.000000000 -0800
+++ linux-2.4.25F5/net/ipv6/mcast.c 2004-03-04 22:37:31.000000000 -0800
@@ -163,6 +163,10 @@
 #define MLDV2_QQIC(value) MLDV2_EXP(0x80, 4, 3, value)
 #define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)

+#define IPV6_MLD_MAX_MSF     10
+
+int sysctl_mld_max_msf = IPV6_MLD_MAX_MSF;
+
 /*
  *   socket join on multicast group
  */
@@ -401,6 +405,10 @@
      }
      /* else, add a new source to the filter */

+     if (psl && psl->sl_count >= sysctl_mld_max_msf) {
+           err = -ENOBUFS;
+           goto done;
+     }
      if (!psl || psl->sl_count == psl->sl_max) {
            struct ip6_sf_socklist *newpsl;
            int count = IP6_SFBLOCK;
diff -ruN linux-2.4.25F4/net/ipv6/sysctl_net_ipv6.c linux-2.4.25F5/net/ipv6/sysctl_net_ipv6.c
--- linux-2.4.25F4/net/ipv6/sysctl_net_ipv6.c   2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.25F5/net/ipv6/sysctl_net_ipv6.c   2004-03-05 00:01:05.000000000 -0800
@@ -24,6 +24,8 @@
      {NET_IPV6_ICMP, "icmp", NULL, 0, 0500, ipv6_icmp_table},
      {NET_IPV6_BINDV6ONLY, "bindv6only",
       &sysctl_ipv6_bindv6only, sizeof(int), 0644, NULL, &proc_dointvec},
+     {NET_IPV6_MLD_MAX_MSF, "mld_max_msf",
+      &sysctl_mld_max_msf, sizeof(int), 0644, NULL, &proc_dointvec},
      {0}
 };

(See attached file: 2.4.25mpmsflimit.patch)
(See attached file: 2.6.4rc2mpmsflimit.patch)
--1__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>This patch adds support for administrator-controlled multicast source<br>
filter limits for the multiprotocol multicast source filter API. The v4 portion<br>
uses the same sysctl variable as the previous v4-only API patch, and<br>
the v6 portion uses a new v6 sysctl variable, &quot;mld_max_msf&quot;.<br>
<br>
In-line 2.4.x and attached 2.4.x and 2.6.x versions.<br>
<br>
				+-DLS<br>
<br>
diff -ruN linux-2.4.25F4/include/linux/sysctl.h linux-2.4.25F5/include/linux/sysctl.h<br>
--- linux-2.4.25F4/include/linux/sysctl.h	2004-03-04 17:02:54.000000000 -0800<br>
+++ linux-2.4.25F5/include/linux/sysctl.h	2004-03-05 00:02:57.000000000 -0800<br>
@@ -388,7 +388,8 @@<br>
 	NET_IPV6_NEIGH=17,<br>
 	NET_IPV6_ROUTE=18,<br>
 	NET_IPV6_ICMP=19,<br>
-	NET_IPV6_BINDV6ONLY=20<br>
+	NET_IPV6_BINDV6ONLY=20,<br>
+	NET_IPV6_MLD_MAX_MSF=25,<br>
 };<br>
 <br>
 enum {<br>
diff -ruN linux-2.4.25F4/include/net/ipv6.h linux-2.4.25F5/include/net/ipv6.h<br>
--- linux-2.4.25F4/include/net/ipv6.h	2004-03-04 17:15:19.000000000 -0800<br>
+++ linux-2.4.25F5/include/net/ipv6.h	2004-03-05 00:19:31.000000000 -0800<br>
@@ -104,6 +104,7 @@<br>
 <br>
 /* sysctls */<br>
 extern int sysctl_ipv6_bindv6only;<br>
+extern int sysctl_mld_max_msf;<br>
 <br>
 extern struct ipv6_mib		ipv6_statistics[NR_CPUS*2];<br>
 #define IP6_INC_STATS(field)		SNMP_INC_STATS(ipv6_statistics, field)<br>
diff -ruN linux-2.4.25F4/net/ipv4/ip_sockglue.c linux-2.4.25F5/net/ipv4/ip_sockglue.c<br>
--- linux-2.4.25F4/net/ipv4/ip_sockglue.c	2004-03-04 19:29:33.000000000 -0800<br>
+++ linux-2.4.25F5/net/ipv4/ip_sockglue.c	2004-03-05 16:21:06.000000000 -0800<br>
@@ -762,6 +762,8 @@<br>
 		}<br>
 		case MCAST_MSFILTER:<br>
 		{<br>
+			extern int sysctl_optmem_max;<br>
+			extern int sysctl_igmp_max_msf;<br>
 			struct sockaddr_in *psin;<br>
 			struct ip_msfilter *msf = 0;<br>
 			struct group_filter *gsf = 0;<br>
@@ -769,6 +771,10 @@<br>
 <br>
 			if (optlen &lt; GROUP_FILTER_SIZE(0))<br>
 				goto e_inval;<br>
+			if (optlen &gt; sysctl_optmem_max) {<br>
+				err = -ENOBUFS;<br>
+				break;<br>
+			}<br>
 			gsf = (struct group_filter *)kmalloc(optlen,GFP_KERNEL);<br>
 			if (gsf == 0) {<br>
 				err = -ENOBUFS;<br>
@@ -778,7 +784,13 @@<br>
 			if (copy_from_user(gsf, optval, optlen)) {<br>
 				goto mc_msf_out;<br>
 			}<br>
-			if (GROUP_FILTER_SIZE(gsf-&gt;gf_numsrc) &lt; optlen) {<br>
+			/* numsrc &gt;= (4G-140)/128 overflow in 32 bits */<br>
+			if (gsf-&gt;gf_numsrc &gt;= 0x1ffffff ||<br>
+			    gsf-&gt;gf_numsrc &gt; sysctl_igmp_max_msf) {<br>
+				err = -ENOBUFS;<br>
+				goto mc_msf_out;<br>
+			}<br>
+			if (GROUP_FILTER_SIZE(gsf-&gt;gf_numsrc) &gt; optlen) {<br>
 				err = EINVAL;<br>
 				goto mc_msf_out;<br>
 			}<br>
diff -ruN linux-2.4.25F4/net/ipv6/ipv6_sockglue.c linux-2.4.25F5/net/ipv6/ipv6_sockglue.c<br>
--- linux-2.4.25F4/net/ipv6/ipv6_sockglue.c	2004-02-23 16:35:09.000000000 -0800<br>
+++ linux-2.4.25F5/net/ipv6/ipv6_sockglue.c	2004-03-05 01:57:30.000000000 -0800<br>
@@ -453,6 +453,7 @@<br>
 	case MCAST_MSFILTER:<br>
 	{<br>
 		extern int sysctl_optmem_max;<br>
+		extern int sysctl_mld_max_msf;<br>
 		struct group_filter *gsf;<br>
 <br>
 		if (optlen &lt; GROUP_FILTER_SIZE(0))<br>
@@ -471,8 +472,14 @@<br>
 			kfree(gsf);<br>
 			break;<br>
 		}<br>
-		if (GROUP_FILTER_SIZE(gsf-&gt;gf_numsrc) &lt; GROUP_FILTER_SIZE(0) ||<br>
-		    GROUP_FILTER_SIZE(gsf-&gt;gf_numsrc) &gt; optlen) {<br>
+		/* numsrc &gt;= (4G-140)/128 overflow in 32 bits */<br>
+		if (gsf-&gt;gf_numsrc &gt;= 0x1ffffffU ||<br>
+		    gsf-&gt;gf_numsrc &gt; sysctl_mld_max_msf) {<br>
+			kfree(gsf);<br>
+			retv = -ENOBUFS;<br>
+			break;<br>
+		}<br>
+		if (GROUP_FILTER_SIZE(gsf-&gt;gf_numsrc) &gt; optlen) {<br>
 			kfree(gsf);<br>
 			retv = -EINVAL;<br>
 			break;<br>
diff -ruN linux-2.4.25F4/net/ipv6/mcast.c linux-2.4.25F5/net/ipv6/mcast.c<br>
--- linux-2.4.25F4/net/ipv6/mcast.c	2004-02-18 05:36:32.000000000 -0800<br>
+++ linux-2.4.25F5/net/ipv6/mcast.c	2004-03-04 22:37:31.000000000 -0800<br>
@@ -163,6 +163,10 @@<br>
 #define MLDV2_QQIC(value) MLDV2_EXP(0x80, 4, 3, value)<br>
 #define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)<br>
 <br>
+#define IPV6_MLD_MAX_MSF	10<br>
+<br>
+int sysctl_mld_max_msf = IPV6_MLD_MAX_MSF;<br>
+<br>
 /*<br>
  *	socket join on multicast group<br>
  */<br>
@@ -401,6 +405,10 @@<br>
 	}<br>
 	/* else, add a new source to the filter */<br>
 <br>
+	if (psl &amp;&amp; psl-&gt;sl_count &gt;= sysctl_mld_max_msf) {<br>
+		err = -ENOBUFS;<br>
+		goto done;<br>
+	}<br>
 	if (!psl || psl-&gt;sl_count == psl-&gt;sl_max) {<br>
 		struct ip6_sf_socklist *newpsl;<br>
 		int count = IP6_SFBLOCK;<br>
diff -ruN linux-2.4.25F4/net/ipv6/sysctl_net_ipv6.c linux-2.4.25F5/net/ipv6/sysctl_net_ipv6.c<br>
--- linux-2.4.25F4/net/ipv6/sysctl_net_ipv6.c	2003-06-13 07:51:39.000000000 -0700<br>
+++ linux-2.4.25F5/net/ipv6/sysctl_net_ipv6.c	2004-03-05 00:01:05.000000000 -0800<br>
@@ -24,6 +24,8 @@<br>
 	{NET_IPV6_ICMP, &quot;icmp&quot;, NULL, 0, 0500, ipv6_icmp_table},<br>
 	{NET_IPV6_BINDV6ONLY, &quot;bindv6only&quot;,<br>
 	 &amp;sysctl_ipv6_bindv6only, sizeof(int), 0644, NULL, &amp;proc_dointvec},<br>
+	{NET_IPV6_MLD_MAX_MSF, &quot;mld_max_msf&quot;,<br>
+	 &amp;sysctl_mld_max_msf, sizeof(int), 0644, NULL, &amp;proc_dointvec},<br>
 	{0}<br>
 };<br>
 <br>
<i>(See attached file: 2.4.25mpmsflimit.patch)</i><br>
<i>(See attached file: 2.6.4rc2mpmsflimit.patch)</i></body></html>

--1__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3--


--0__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3
Content-type: application/octet-stream;
	name="2.4.25mpmsflimit.patch"
Content-Disposition: attachment; filename="2.4.25mpmsflimit.patch"
Content-ID: <10__=07BBE4DCDFA7A9C38f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNUY0L2luY2x1ZGUvbGludXgvc3lzY3RsLmggbGludXgtMi40
LjI1RjUvaW5jbHVkZS9saW51eC9zeXNjdGwuaAotLS0gbGludXgtMi40LjI1RjQvaW5jbHVkZS9s
aW51eC9zeXNjdGwuaAkyMDA0LTAzLTA0IDE3OjAyOjU0LjAwMDAwMDAwMCAtMDgwMAorKysgbGlu
dXgtMi40LjI1RjUvaW5jbHVkZS9saW51eC9zeXNjdGwuaAkyMDA0LTAzLTA1IDAwOjAyOjU3LjAw
MDAwMDAwMCAtMDgwMApAQCAtMzg4LDcgKzM4OCw4IEBACiAJTkVUX0lQVjZfTkVJR0g9MTcsCiAJ
TkVUX0lQVjZfUk9VVEU9MTgsCiAJTkVUX0lQVjZfSUNNUD0xOSwKLQlORVRfSVBWNl9CSU5EVjZP
TkxZPTIwCisJTkVUX0lQVjZfQklORFY2T05MWT0yMCwKKwlORVRfSVBWNl9NTERfTUFYX01TRj0y
NSwKIH07CiAKIGVudW0gewpkaWZmIC1ydU4gbGludXgtMi40LjI1RjQvaW5jbHVkZS9uZXQvaXB2
Ni5oIGxpbnV4LTIuNC4yNUY1L2luY2x1ZGUvbmV0L2lwdjYuaAotLS0gbGludXgtMi40LjI1RjQv
aW5jbHVkZS9uZXQvaXB2Ni5oCTIwMDQtMDMtMDQgMTc6MTU6MTkuMDAwMDAwMDAwIC0wODAwCisr
KyBsaW51eC0yLjQuMjVGNS9pbmNsdWRlL25ldC9pcHY2LmgJMjAwNC0wMy0wNSAwMDoxOTozMS4w
MDAwMDAwMDAgLTA4MDAKQEAgLTEwNCw2ICsxMDQsNyBAQAogCiAvKiBzeXNjdGxzICovCiBleHRl
cm4gaW50IHN5c2N0bF9pcHY2X2JpbmR2Nm9ubHk7CitleHRlcm4gaW50IHN5c2N0bF9tbGRfbWF4
X21zZjsKIAogZXh0ZXJuIHN0cnVjdCBpcHY2X21pYgkJaXB2Nl9zdGF0aXN0aWNzW05SX0NQVVMq
Ml07CiAjZGVmaW5lIElQNl9JTkNfU1RBVFMoZmllbGQpCQlTTk1QX0lOQ19TVEFUUyhpcHY2X3N0
YXRpc3RpY3MsIGZpZWxkKQpkaWZmIC1ydU4gbGludXgtMi40LjI1RjQvbmV0L2lwdjQvaXBfc29j
a2dsdWUuYyBsaW51eC0yLjQuMjVGNS9uZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jCi0tLSBsaW51eC0y
LjQuMjVGNC9uZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jCTIwMDQtMDMtMDQgMTk6Mjk6MzMuMDAwMDAw
MDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjVGNS9uZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jCTIwMDQt
MDMtMDUgMTY6MjE6MDYuMDAwMDAwMDAwIC0wODAwCkBAIC03NjIsNiArNzYyLDggQEAKIAkJfQog
CQljYXNlIE1DQVNUX01TRklMVEVSOgogCQl7CisJCQlleHRlcm4gaW50IHN5c2N0bF9vcHRtZW1f
bWF4OworCQkJZXh0ZXJuIGludCBzeXNjdGxfaWdtcF9tYXhfbXNmOwogCQkJc3RydWN0IHNvY2th
ZGRyX2luICpwc2luOwogCQkJc3RydWN0IGlwX21zZmlsdGVyICptc2YgPSAwOwogCQkJc3RydWN0
IGdyb3VwX2ZpbHRlciAqZ3NmID0gMDsKQEAgLTc2OSw2ICs3NzEsMTAgQEAKIAogCQkJaWYgKG9w
dGxlbiA8IEdST1VQX0ZJTFRFUl9TSVpFKDApKQogCQkJCWdvdG8gZV9pbnZhbDsKKwkJCWlmIChv
cHRsZW4gPiBzeXNjdGxfb3B0bWVtX21heCkgeworCQkJCWVyciA9IC1FTk9CVUZTOworCQkJCWJy
ZWFrOworCQkJfQogCQkJZ3NmID0gKHN0cnVjdCBncm91cF9maWx0ZXIgKilrbWFsbG9jKG9wdGxl
bixHRlBfS0VSTkVMKTsKIAkJCWlmIChnc2YgPT0gMCkgewogCQkJCWVyciA9IC1FTk9CVUZTOwpA
QCAtNzc4LDcgKzc4NCwxMyBAQAogCQkJaWYgKGNvcHlfZnJvbV91c2VyKGdzZiwgb3B0dmFsLCBv
cHRsZW4pKSB7CiAJCQkJZ290byBtY19tc2Zfb3V0OwogCQkJfQotCQkJaWYgKEdST1VQX0ZJTFRF
Ul9TSVpFKGdzZi0+Z2ZfbnVtc3JjKSA8IG9wdGxlbikgeworCQkJLyogbnVtc3JjID49ICg0Ry0x
NDApLzEyOCBvdmVyZmxvdyBpbiAzMiBiaXRzICovCisJCQlpZiAoZ3NmLT5nZl9udW1zcmMgPj0g
MHgxZmZmZmZmIHx8CisJCQkgICAgZ3NmLT5nZl9udW1zcmMgPiBzeXNjdGxfaWdtcF9tYXhfbXNm
KSB7CisJCQkJZXJyID0gLUVOT0JVRlM7CisJCQkJZ290byBtY19tc2Zfb3V0OworCQkJfQorCQkJ
aWYgKEdST1VQX0ZJTFRFUl9TSVpFKGdzZi0+Z2ZfbnVtc3JjKSA+IG9wdGxlbikgewogCQkJCWVy
ciA9IEVJTlZBTDsKIAkJCQlnb3RvIG1jX21zZl9vdXQ7CiAJCQl9CmRpZmYgLXJ1TiBsaW51eC0y
LjQuMjVGNC9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMgbGludXgtMi40LjI1RjUvbmV0L2lwdjYv
aXB2Nl9zb2NrZ2x1ZS5jCi0tLSBsaW51eC0yLjQuMjVGNC9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVl
LmMJMjAwNC0wMi0yMyAxNjozNTowOS4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNC4yNUY1
L25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYwkyMDA0LTAzLTA1IDAxOjU3OjMwLjAwMDAwMDAwMCAt
MDgwMApAQCAtNDUzLDYgKzQ1Myw3IEBACiAJY2FzZSBNQ0FTVF9NU0ZJTFRFUjoKIAl7CiAJCWV4
dGVybiBpbnQgc3lzY3RsX29wdG1lbV9tYXg7CisJCWV4dGVybiBpbnQgc3lzY3RsX21sZF9tYXhf
bXNmOwogCQlzdHJ1Y3QgZ3JvdXBfZmlsdGVyICpnc2Y7CiAKIAkJaWYgKG9wdGxlbiA8IEdST1VQ
X0ZJTFRFUl9TSVpFKDApKQpAQCAtNDcxLDggKzQ3MiwxNCBAQAogCQkJa2ZyZWUoZ3NmKTsKIAkJ
CWJyZWFrOwogCQl9Ci0JCWlmIChHUk9VUF9GSUxURVJfU0laRShnc2YtPmdmX251bXNyYykgPCBH
Uk9VUF9GSUxURVJfU0laRSgwKSB8fAotCQkgICAgR1JPVVBfRklMVEVSX1NJWkUoZ3NmLT5nZl9u
dW1zcmMpID4gb3B0bGVuKSB7CisJCS8qIG51bXNyYyA+PSAoNEctMTQwKS8xMjggb3ZlcmZsb3cg
aW4gMzIgYml0cyAqLworCQlpZiAoZ3NmLT5nZl9udW1zcmMgPj0gMHgxZmZmZmZmVSB8fAorCQkg
ICAgZ3NmLT5nZl9udW1zcmMgPiBzeXNjdGxfbWxkX21heF9tc2YpIHsKKwkJCWtmcmVlKGdzZik7
CisJCQlyZXR2ID0gLUVOT0JVRlM7CisJCQlicmVhazsKKwkJfQorCQlpZiAoR1JPVVBfRklMVEVS
X1NJWkUoZ3NmLT5nZl9udW1zcmMpID4gb3B0bGVuKSB7CiAJCQlrZnJlZShnc2YpOwogCQkJcmV0
diA9IC1FSU5WQUw7CiAJCQlicmVhazsKZGlmZiAtcnVOIGxpbnV4LTIuNC4yNUY0L25ldC9pcHY2
L21jYXN0LmMgbGludXgtMi40LjI1RjUvbmV0L2lwdjYvbWNhc3QuYwotLS0gbGludXgtMi40LjI1
RjQvbmV0L2lwdjYvbWNhc3QuYwkyMDA0LTAyLTE4IDA1OjM2OjMyLjAwMDAwMDAwMCAtMDgwMAor
KysgbGludXgtMi40LjI1RjUvbmV0L2lwdjYvbWNhc3QuYwkyMDA0LTAzLTA0IDIyOjM3OjMxLjAw
MDAwMDAwMCAtMDgwMApAQCAtMTYzLDYgKzE2MywxMCBAQAogI2RlZmluZSBNTERWMl9RUUlDKHZh
bHVlKSBNTERWMl9FWFAoMHg4MCwgNCwgMywgdmFsdWUpCiAjZGVmaW5lIE1MRFYyX01SQyh2YWx1
ZSkgTUxEVjJfRVhQKDB4ODAwMCwgMTIsIDMsIHZhbHVlKQogCisjZGVmaW5lIElQVjZfTUxEX01B
WF9NU0YJMTAKKworaW50IHN5c2N0bF9tbGRfbWF4X21zZiA9IElQVjZfTUxEX01BWF9NU0Y7CisK
IC8qCiAgKglzb2NrZXQgam9pbiBvbiBtdWx0aWNhc3QgZ3JvdXAKICAqLwpAQCAtNDAxLDYgKzQw
NSwxMCBAQAogCX0KIAkvKiBlbHNlLCBhZGQgYSBuZXcgc291cmNlIHRvIHRoZSBmaWx0ZXIgKi8K
IAorCWlmIChwc2wgJiYgcHNsLT5zbF9jb3VudCA+PSBzeXNjdGxfbWxkX21heF9tc2YpIHsKKwkJ
ZXJyID0gLUVOT0JVRlM7CisJCWdvdG8gZG9uZTsKKwl9CiAJaWYgKCFwc2wgfHwgcHNsLT5zbF9j
b3VudCA9PSBwc2wtPnNsX21heCkgewogCQlzdHJ1Y3QgaXA2X3NmX3NvY2tsaXN0ICpuZXdwc2w7
CiAJCWludCBjb3VudCA9IElQNl9TRkJMT0NLOwpkaWZmIC1ydU4gbGludXgtMi40LjI1RjQvbmV0
L2lwdjYvc3lzY3RsX25ldF9pcHY2LmMgbGludXgtMi40LjI1RjUvbmV0L2lwdjYvc3lzY3RsX25l
dF9pcHY2LmMKLS0tIGxpbnV4LTIuNC4yNUY0L25ldC9pcHY2L3N5c2N0bF9uZXRfaXB2Ni5jCTIw
MDMtMDYtMTMgMDc6NTE6MzkuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjQuMjVGNS9uZXQv
aXB2Ni9zeXNjdGxfbmV0X2lwdjYuYwkyMDA0LTAzLTA1IDAwOjAxOjA1LjAwMDAwMDAwMCAtMDgw
MApAQCAtMjQsNiArMjQsOCBAQAogCXtORVRfSVBWNl9JQ01QLCAiaWNtcCIsIE5VTEwsIDAsIDA1
MDAsIGlwdjZfaWNtcF90YWJsZX0sCiAJe05FVF9JUFY2X0JJTkRWNk9OTFksICJiaW5kdjZvbmx5
IiwKIAkgJnN5c2N0bF9pcHY2X2JpbmR2Nm9ubHksIHNpemVvZihpbnQpLCAwNjQ0LCBOVUxMLCAm
cHJvY19kb2ludHZlY30sCisJe05FVF9JUFY2X01MRF9NQVhfTVNGLCAibWxkX21heF9tc2YiLAor
CSAmc3lzY3RsX21sZF9tYXhfbXNmLCBzaXplb2YoaW50KSwgMDY0NCwgTlVMTCwgJnByb2NfZG9p
bnR2ZWN9LAogCXswfQogfTsKIAo=

--0__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3
Content-type: application/octet-stream;
	name="2.6.4rc2mpmsflimit.patch"
Content-Disposition: attachment; filename="2.6.4rc2mpmsflimit.patch"
Content-ID: <20__=07BBE4DCDFA7A9C38f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi40cmMyRjEvaW5jbHVkZS9saW51eC9zeXNjdGwuaCBsaW51eC0y
LjYuNHJjMkYyL2luY2x1ZGUvbGludXgvc3lzY3RsLmgKLS0tIGxpbnV4LTIuNi40cmMyRjEvaW5j
bHVkZS9saW51eC9zeXNjdGwuaAkyMDA0LTAzLTA0IDE2OjU3OjI2LjAwMDAwMDAwMCAtMDgwMAor
KysgbGludXgtMi42LjRyYzJGMi9pbmNsdWRlL2xpbnV4L3N5c2N0bC5oCTIwMDQtMDMtMDYgMDA6
MTg6MTcuMDAwMDAwMDAwIC0wODAwCkBAIC00MDUsNyArNDA1LDggQEAKIAlORVRfSVBWNl9JUDZG
UkFHX0hJR0hfVEhSRVNIPTIxLAogCU5FVF9JUFY2X0lQNkZSQUdfTE9XX1RIUkVTSD0yMiwKIAlO
RVRfSVBWNl9JUDZGUkFHX1RJTUU9MjMsCi0JTkVUX0lQVjZfSVA2RlJBR19TRUNSRVRfSU5URVJW
QUw9MjQKKwlORVRfSVBWNl9JUDZGUkFHX1NFQ1JFVF9JTlRFUlZBTD0yNCwKKwlORVRfSVBWNl9N
TERfTUFYX01TRj0yNSwKIH07CiAKIGVudW0gewpkaWZmIC1ydU4gbGludXgtMi42LjRyYzJGMS9p
bmNsdWRlL25ldC9pcHY2LmggbGludXgtMi42LjRyYzJGMi9pbmNsdWRlL25ldC9pcHY2LmgKLS0t
IGxpbnV4LTIuNi40cmMyRjEvaW5jbHVkZS9uZXQvaXB2Ni5oCTIwMDQtMDMtMDQgMTY6MTg6MjMu
MDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuNHJjMkYyL2luY2x1ZGUvbmV0L2lwdjYuaAky
MDA0LTAzLTA2IDAwOjEwOjIxLjAwMDAwMDAwMCAtMDgwMApAQCAtMTA4LDYgKzEwOCw3IEBACiAK
IC8qIHN5c2N0bHMgKi8KIGV4dGVybiBpbnQgc3lzY3RsX2lwdjZfYmluZHY2b25seTsKK2V4dGVy
biBpbnQgc3lzY3RsX21sZF9tYXhfbXNmOwogCiAvKiBNSUJzICovCiBERUNMQVJFX1NOTVBfU1RB
VChzdHJ1Y3QgaXB2Nl9taWIsIGlwdjZfc3RhdGlzdGljcyk7CmRpZmYgLXJ1TiBsaW51eC0yLjYu
NHJjMkYxL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMgbGludXgtMi42LjRyYzJGMi9uZXQvaXB2NC9p
cF9zb2NrZ2x1ZS5jCi0tLSBsaW51eC0yLjYuNHJjMkYxL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMJ
MjAwNC0wMy0wNCAxOTozMDoyNi4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi40cmMyRjIv
bmV0L2lwdjQvaXBfc29ja2dsdWUuYwkyMDA0LTAzLTA2IDAwOjEwOjIxLjAwMDAwMDAwMCAtMDgw
MApAQCAtNzcxLDYgKzc3MSw4IEBACiAJCX0KIAkJY2FzZSBNQ0FTVF9NU0ZJTFRFUjoKIAkJewor
CQkJZXh0ZXJuIGludCBzeXNjdGxfb3B0bWVtX21heDsKKwkJCWV4dGVybiBpbnQgc3lzY3RsX2ln
bXBfbWF4X21zZjsKIAkJCXN0cnVjdCBzb2NrYWRkcl9pbiAqcHNpbjsKIAkJCXN0cnVjdCBpcF9t
c2ZpbHRlciAqbXNmID0gMDsKIAkJCXN0cnVjdCBncm91cF9maWx0ZXIgKmdzZiA9IDA7CkBAIC03
NzgsNiArNzgwLDEwIEBACiAKIAkJCWlmIChvcHRsZW4gPCBHUk9VUF9GSUxURVJfU0laRSgwKSkK
IAkJCQlnb3RvIGVfaW52YWw7CisJCQlpZiAob3B0bGVuID4gc3lzY3RsX29wdG1lbV9tYXgpIHsK
KwkJCQllcnIgPSAtRU5PQlVGUzsKKwkJCQlicmVhazsKKwkJCX0KIAkJCWdzZiA9IChzdHJ1Y3Qg
Z3JvdXBfZmlsdGVyICopa21hbGxvYyhvcHRsZW4sR0ZQX0tFUk5FTCk7CiAJCQlpZiAoZ3NmID09
IDApIHsKIAkJCQllcnIgPSAtRU5PQlVGUzsKQEAgLTc4Nyw3ICs3OTMsMTMgQEAKIAkJCWlmIChj
b3B5X2Zyb21fdXNlcihnc2YsIG9wdHZhbCwgb3B0bGVuKSkgewogCQkJCWdvdG8gbWNfbXNmX291
dDsKIAkJCX0KLQkJCWlmIChHUk9VUF9GSUxURVJfU0laRShnc2YtPmdmX251bXNyYykgPCBvcHRs
ZW4pIHsKKwkJCS8qIG51bXNyYyA+PSAoNEctMTQwKS8xMjggb3ZlcmZsb3cgaW4gMzIgYml0cyAq
LworCQkJaWYgKGdzZi0+Z2ZfbnVtc3JjID49IDB4MWZmZmZmZiB8fAorCQkJICAgIGdzZi0+Z2Zf
bnVtc3JjID4gc3lzY3RsX2lnbXBfbWF4X21zZikgeworCQkJCWVyciA9IC1FTk9CVUZTOworCQkJ
CWdvdG8gbWNfbXNmX291dDsKKwkJCX0KKwkJCWlmIChHUk9VUF9GSUxURVJfU0laRShnc2YtPmdm
X251bXNyYykgPiBvcHRsZW4pIHsKIAkJCQllcnIgPSBFSU5WQUw7CiAJCQkJZ290byBtY19tc2Zf
b3V0OwogCQkJfQpkaWZmIC1ydU4gbGludXgtMi42LjRyYzJGMS9uZXQvaXB2Ni9pcHY2X3NvY2tn
bHVlLmMgbGludXgtMi42LjRyYzJGMi9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMKLS0tIGxpbnV4
LTIuNi40cmMyRjEvbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jCTIwMDQtMDMtMDQgMTY6MTg6MjQu
MDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuNHJjMkYyL25ldC9pcHY2L2lwdjZfc29ja2ds
dWUuYwkyMDA0LTAzLTA2IDAwOjEwOjIxLjAwMDAwMDAwMCAtMDgwMApAQCAtNDM3LDYgKzQzNyw3
IEBACiAJY2FzZSBNQ0FTVF9NU0ZJTFRFUjoKIAl7CiAJCWV4dGVybiBpbnQgc3lzY3RsX29wdG1l
bV9tYXg7CisJCWV4dGVybiBpbnQgc3lzY3RsX21sZF9tYXhfbXNmOwogCQlzdHJ1Y3QgZ3JvdXBf
ZmlsdGVyICpnc2Y7CiAKIAkJaWYgKG9wdGxlbiA8IEdST1VQX0ZJTFRFUl9TSVpFKDApKQpAQCAt
NDU1LDggKzQ1NiwxNCBAQAogCQkJa2ZyZWUoZ3NmKTsKIAkJCWJyZWFrOwogCQl9Ci0JCWlmIChH
Uk9VUF9GSUxURVJfU0laRShnc2YtPmdmX251bXNyYykgPCBHUk9VUF9GSUxURVJfU0laRSgwKSB8
fAotCQkgICAgR1JPVVBfRklMVEVSX1NJWkUoZ3NmLT5nZl9udW1zcmMpID4gb3B0bGVuKSB7CisJ
CS8qIG51bXNyYyA+PSAoNEctMTQwKS8xMjggb3ZlcmZsb3cgaW4gMzIgYml0cyAqLworCQlpZiAo
Z3NmLT5nZl9udW1zcmMgPj0gMHgxZmZmZmZmVSB8fAorCQkgICAgZ3NmLT5nZl9udW1zcmMgPiBz
eXNjdGxfbWxkX21heF9tc2YpIHsKKwkJCWtmcmVlKGdzZik7CisJCQlyZXR2ID0gLUVOT0JVRlM7
CisJCQlicmVhazsKKwkJfQorCQlpZiAoR1JPVVBfRklMVEVSX1NJWkUoZ3NmLT5nZl9udW1zcmMp
ID4gb3B0bGVuKSB7CiAJCQlrZnJlZShnc2YpOwogCQkJcmV0diA9IC1FSU5WQUw7CiAJCQlicmVh
azsKZGlmZiAtcnVOIGxpbnV4LTIuNi40cmMyRjEvbmV0L2lwdjYvbWNhc3QuYyBsaW51eC0yLjYu
NHJjMkYyL25ldC9pcHY2L21jYXN0LmMKLS0tIGxpbnV4LTIuNi40cmMyRjEvbmV0L2lwdjYvbWNh
c3QuYwkyMDA0LTAzLTA0IDE2OjE4OjI0LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjRy
YzJGMi9uZXQvaXB2Ni9tY2FzdC5jCTIwMDQtMDMtMDYgMDA6MTA6MjEuMDAwMDAwMDAwIC0wODAw
CkBAIC0xNjYsNiArMTY2LDEwIEBACiAjZGVmaW5lIE1MRFYyX1FRSUModmFsdWUpIE1MRFYyX0VY
UCgweDgwLCA0LCAzLCB2YWx1ZSkKICNkZWZpbmUgTUxEVjJfTVJDKHZhbHVlKSBNTERWMl9FWFAo
MHg4MDAwLCAxMiwgMywgdmFsdWUpCiAKKyNkZWZpbmUgSVBWNl9NTERfTUFYX01TRgkxMAorCitp
bnQgc3lzY3RsX21sZF9tYXhfbXNmID0gSVBWNl9NTERfTUFYX01TRjsKKwogLyoKICAqCXNvY2tl
dCBqb2luIG9uIG11bHRpY2FzdCBncm91cAogICovCkBAIC00MDQsNiArNDA4LDEwIEBACiAJfQog
CS8qIGVsc2UsIGFkZCBhIG5ldyBzb3VyY2UgdG8gdGhlIGZpbHRlciAqLwogCisJaWYgKHBzbCAm
JiBwc2wtPnNsX2NvdW50ID49IHN5c2N0bF9tbGRfbWF4X21zZikgeworCQllcnIgPSAtRU5PQlVG
UzsKKwkJZ290byBkb25lOworCX0KIAlpZiAoIXBzbCB8fCBwc2wtPnNsX2NvdW50ID09IHBzbC0+
c2xfbWF4KSB7CiAJCXN0cnVjdCBpcDZfc2Zfc29ja2xpc3QgKm5ld3BzbDsKIAkJaW50IGNvdW50
ID0gSVA2X1NGQkxPQ0s7CmRpZmYgLXJ1TiBsaW51eC0yLjYuNHJjMkYxL25ldC9pcHY2L3N5c2N0
bF9uZXRfaXB2Ni5jIGxpbnV4LTIuNi40cmMyRjIvbmV0L2lwdjYvc3lzY3RsX25ldF9pcHY2LmMK
LS0tIGxpbnV4LTIuNi40cmMyRjEvbmV0L2lwdjYvc3lzY3RsX25ldF9pcHY2LmMJMjAwNC0wMy0w
NCAxNjoxODoyNC4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi40cmMyRjIvbmV0L2lwdjYv
c3lzY3RsX25ldF9pcHY2LmMJMjAwNC0wMy0wNiAwMDoxNjozMi4wMDAwMDAwMDAgLTA4MDAKQEAg
LTc2LDYgKzc2LDE0IEBACiAJCS5wcm9jX2hhbmRsZXIJPSAmcHJvY19kb2ludHZlY19qaWZmaWVz
LAogCQkuc3RyYXRlZ3kJPSAmc3lzY3RsX2ppZmZpZXMKIAl9LAorCXsKKwkJLmN0bF9uYW1lCT0g
TkVUX0lQVjZfTUxEX01BWF9NU0YsCisJCS5wcm9jbmFtZQk9ICJtbGRfbWF4X21zZiIsCisJCS5k
YXRhCQk9ICZzeXNjdGxfbWxkX21heF9tc2YsCisJCS5tYXhsZW4JCT0gc2l6ZW9mKGludCksCisJ
CS5tb2RlCQk9IDA2NDQsCisJCS5wcm9jX2hhbmRsZXIJPSAmcHJvY19kb2ludHZlYworCX0sCiAJ
eyAuY3RsX25hbWUgPSAwIH0KIH07CiAK

--0__=07BBE4DCDFA7A9C38f9e8a93df938690918c07BBE4DCDFA7A9C3--
