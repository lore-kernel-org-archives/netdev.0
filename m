From: David Stevens <dlstevens@us.ibm.com>
Subject: IGMP multicast source filter limits via sysctl [PATCH]
Date: Thu, 4 Mar 2004 22:04:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF214E53DE.6174BA9F-ON88256E4E.001B2CE9-88256E4E.001B9715@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79
Content-type: multipart/alternative;
	Boundary="1__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79"

--1__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79
Content-type: text/plain; charset=US-ASCII





The following patch adds a sysctl variable for administrators to set
limits on the number of per-socket multicast source filters for IPv4.
The in-line patch for review is for 2.4.25. Attached is the 2.4.25 version
and the 2.6.x version.

multiprotocol socket API version to follow soon.

                              +-DLS

diff -ruN linux-2.4.25F2/include/linux/sysctl.h linux-2.4.25F4/include/linux/sysctl.h
--- linux-2.4.25F2/include/linux/sysctl.h 2004-02-20 15:13:01.000000000 -0800
+++ linux-2.4.25F4/include/linux/sysctl.h 2004-03-04 17:02:54.000000000 -0800
@@ -312,6 +312,7 @@
      NET_TCP_FRTO=92,
      NET_TCP_LOW_LATENCY=93,
      NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
+     NET_IPV4_IGMP_MAX_MSF=96,
 };

 enum {
diff -ruN linux-2.4.25F2/net/ipv4/igmp.c linux-2.4.25F4/net/ipv4/igmp.c
--- linux-2.4.25F2/net/ipv4/igmp.c  2004-02-18 05:36:32.000000000 -0800
+++ linux-2.4.25F4/net/ipv4/igmp.c  2004-03-04 15:47:09.000000000 -0800
@@ -101,7 +101,8 @@
 #endif


-#define IP_MAX_MEMBERSHIPS 20
+#define IP_MAX_MEMBERSHIPS   20
+#define IP_MAX_MSF           10

 #ifdef CONFIG_IP_MULTICAST
 /* Parameter names and values are taken from igmp-v2-06 draft */
@@ -1311,6 +1312,7 @@
  *   Join a socket to a group
  */
 int sysctl_igmp_max_memberships = IP_MAX_MEMBERSHIPS;
+int sysctl_igmp_max_msf = IP_MAX_MSF;


 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
@@ -1772,6 +1774,10 @@
      }
      /* else, add a new source to the filter */

+     if (psl && psl->sl_count >= sysctl_igmp_max_msf) {
+           err = -ENOBUFS;
+           goto done;
+     }
      if (!psl || psl->sl_count == psl->sl_max) {
            struct ip_sf_socklist *newpsl;
            int count = IP_SFBLOCK;
diff -ruN linux-2.4.25F2/net/ipv4/ip_sockglue.c linux-2.4.25F4/net/ipv4/ip_sockglue.c
--- linux-2.4.25F2/net/ipv4/ip_sockglue.c 2004-02-23 17:03:10.000000000 -0800
+++ linux-2.4.25F4/net/ipv4/ip_sockglue.c 2004-03-04 19:29:33.000000000 -0800
@@ -609,6 +609,7 @@
            case IP_MSFILTER:
            {
                  extern int sysctl_optmem_max;
+                 extern int sysctl_igmp_max_msf;
                  struct ip_msfilter *msf;

                  if (optlen < IP_MSFILTER_SIZE(0))
@@ -627,9 +628,14 @@
                        kfree(msf);
                        break;
                  }
-                 if (IP_MSFILTER_SIZE(msf->imsf_numsrc) <
-                     IP_MSFILTER_SIZE(0) ||
-                     IP_MSFILTER_SIZE(msf->imsf_numsrc) > optlen) {
+                 /* numsrc >= (1G-4) overflow in 32 bits */
+                 if (msf->imsf_numsrc >= 0x3ffffffcU ||
+                     msf->imsf_numsrc > sysctl_igmp_max_msf) {
+                       kfree(msf);
+                       err = -ENOBUFS;
+                       break;
+                 }
+                 if (IP_MSFILTER_SIZE(msf->imsf_numsrc) > optlen) {
                        kfree(msf);
                        err = -EINVAL;
                        break;
diff -ruN linux-2.4.25F2/net/ipv4/sysctl_net_ipv4.c linux-2.4.25F4/net/ipv4/sysctl_net_ipv4.c
--- linux-2.4.25F2/net/ipv4/sysctl_net_ipv4.c   2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.25F4/net/ipv4/sysctl_net_ipv4.c   2004-03-04 14:47:31.000000000 -0800
@@ -38,6 +38,7 @@

 /* From igmp.c */
 extern int sysctl_igmp_max_memberships;
+extern int sysctl_igmp_max_msf;

 /* From inetpeer.c */
 extern int inet_peer_threshold;
@@ -182,6 +183,8 @@
      {NET_IPV4_IGMP_MAX_MEMBERSHIPS, "igmp_max_memberships",
       &sysctl_igmp_max_memberships, sizeof(int), 0644, NULL, &proc_dointvec},
 #endif
+     {NET_IPV4_IGMP_MAX_MSF, "igmp_max_msf",
+      &sysctl_igmp_max_msf, sizeof(int), 0644, NULL, &proc_dointvec},
      {NET_IPV4_INET_PEER_THRESHOLD, "inet_peer_threshold",
       &inet_peer_threshold, sizeof(int), 0644, NULL, &proc_dointvec},
      {NET_IPV4_INET_PEER_MINTTL, "inet_peer_minttl",

(See attached file: 2.4.25igmpmsflimit2.patch)
(See attached file: 2.6.4rc2igmpmsflimit2.patch)
--1__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>The following patch adds a sysctl variable for administrators to set<br>
limits on the number of per-socket multicast source filters for IPv4.<br>
The in-line patch for review is for 2.4.25. Attached is the 2.4.25 version<br>
and the 2.6.x version.<br>
<br>
multiprotocol socket API version to follow soon.<br>
<br>
					+-DLS<br>
<br>
diff -ruN linux-2.4.25F2/include/linux/sysctl.h linux-2.4.25F4/include/linux/sysctl.h<br>
--- linux-2.4.25F2/include/linux/sysctl.h	2004-02-20 15:13:01.000000000 -0800<br>
+++ linux-2.4.25F4/include/linux/sysctl.h	2004-03-04 17:02:54.000000000 -0800<br>
@@ -312,6 +312,7 @@<br>
 	NET_TCP_FRTO=92,<br>
 	NET_TCP_LOW_LATENCY=93,<br>
 	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,<br>
+	NET_IPV4_IGMP_MAX_MSF=96,<br>
 };<br>
 <br>
 enum {<br>
diff -ruN linux-2.4.25F2/net/ipv4/igmp.c linux-2.4.25F4/net/ipv4/igmp.c<br>
--- linux-2.4.25F2/net/ipv4/igmp.c	2004-02-18 05:36:32.000000000 -0800<br>
+++ linux-2.4.25F4/net/ipv4/igmp.c	2004-03-04 15:47:09.000000000 -0800<br>
@@ -101,7 +101,8 @@<br>
 #endif<br>
 <br>
 <br>
-#define IP_MAX_MEMBERSHIPS 20<br>
+#define IP_MAX_MEMBERSHIPS	20<br>
+#define IP_MAX_MSF		10<br>
 <br>
 #ifdef CONFIG_IP_MULTICAST<br>
 /* Parameter names and values are taken from igmp-v2-06 draft */<br>
@@ -1311,6 +1312,7 @@<br>
  *	Join a socket to a group<br>
  */<br>
 int sysctl_igmp_max_memberships = IP_MAX_MEMBERSHIPS;<br>
+int sysctl_igmp_max_msf = IP_MAX_MSF;<br>
 <br>
 <br>
 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,<br>
@@ -1772,6 +1774,10 @@<br>
 	}<br>
 	/* else, add a new source to the filter */<br>
 <br>
+	if (psl &amp;&amp; psl-&gt;sl_count &gt;= sysctl_igmp_max_msf) {<br>
+		err = -ENOBUFS;<br>
+		goto done;<br>
+	}<br>
 	if (!psl || psl-&gt;sl_count == psl-&gt;sl_max) {<br>
 		struct ip_sf_socklist *newpsl;<br>
 		int count = IP_SFBLOCK;<br>
diff -ruN linux-2.4.25F2/net/ipv4/ip_sockglue.c linux-2.4.25F4/net/ipv4/ip_sockglue.c<br>
--- linux-2.4.25F2/net/ipv4/ip_sockglue.c	2004-02-23 17:03:10.000000000 -0800<br>
+++ linux-2.4.25F4/net/ipv4/ip_sockglue.c	2004-03-04 19:29:33.000000000 -0800<br>
@@ -609,6 +609,7 @@<br>
 		case IP_MSFILTER:<br>
 		{<br>
 			extern int sysctl_optmem_max;<br>
+			extern int sysctl_igmp_max_msf;<br>
 			struct ip_msfilter *msf;<br>
 <br>
 			if (optlen &lt; IP_MSFILTER_SIZE(0))<br>
@@ -627,9 +628,14 @@<br>
 				kfree(msf);<br>
 				break;<br>
 			}<br>
-			if (IP_MSFILTER_SIZE(msf-&gt;imsf_numsrc) &lt; <br>
-			    IP_MSFILTER_SIZE(0) ||<br>
-			    IP_MSFILTER_SIZE(msf-&gt;imsf_numsrc) &gt; optlen) {<br>
+			/* numsrc &gt;= (1G-4) overflow in 32 bits */<br>
+			if (msf-&gt;imsf_numsrc &gt;= 0x3ffffffcU ||<br>
+			    msf-&gt;imsf_numsrc &gt; sysctl_igmp_max_msf) {<br>
+				kfree(msf);<br>
+				err = -ENOBUFS;<br>
+				break;<br>
+			}<br>
+			if (IP_MSFILTER_SIZE(msf-&gt;imsf_numsrc) &gt; optlen) {<br>
 				kfree(msf);<br>
 				err = -EINVAL;<br>
 				break;<br>
diff -ruN linux-2.4.25F2/net/ipv4/sysctl_net_ipv4.c linux-2.4.25F4/net/ipv4/sysctl_net_ipv4.c<br>
--- linux-2.4.25F2/net/ipv4/sysctl_net_ipv4.c	2003-06-13 07:51:39.000000000 -0700<br>
+++ linux-2.4.25F4/net/ipv4/sysctl_net_ipv4.c	2004-03-04 14:47:31.000000000 -0800<br>
@@ -38,6 +38,7 @@<br>
 <br>
 /* From igmp.c */<br>
 extern int sysctl_igmp_max_memberships;<br>
+extern int sysctl_igmp_max_msf;<br>
 <br>
 /* From inetpeer.c */<br>
 extern int inet_peer_threshold;<br>
@@ -182,6 +183,8 @@<br>
 	{NET_IPV4_IGMP_MAX_MEMBERSHIPS, &quot;igmp_max_memberships&quot;,<br>
 	 &amp;sysctl_igmp_max_memberships, sizeof(int), 0644, NULL, &amp;proc_dointvec},<br>
 #endif<br>
+	{NET_IPV4_IGMP_MAX_MSF, &quot;igmp_max_msf&quot;,<br>
+	 &amp;sysctl_igmp_max_msf, sizeof(int), 0644, NULL, &amp;proc_dointvec},<br>
 	{NET_IPV4_INET_PEER_THRESHOLD, &quot;inet_peer_threshold&quot;,<br>
 	 &amp;inet_peer_threshold, sizeof(int), 0644, NULL, &amp;proc_dointvec},<br>
 	{NET_IPV4_INET_PEER_MINTTL, &quot;inet_peer_minttl&quot;,<br>
<br>
<i>(See attached file: 2.4.25igmpmsflimit2.patch)</i><br>
<i>(See attached file: 2.6.4rc2igmpmsflimit2.patch)</i><br>
</body></html>

--1__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79--


--0__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79
Content-type: application/octet-stream;
	name="2.4.25igmpmsflimit2.patch"
Content-Disposition: attachment; filename="2.4.25igmpmsflimit2.patch"
Content-ID: <10__=07BBE4DDDF88AA798f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNUYyL2luY2x1ZGUvbGludXgvc3lzY3RsLmggbGludXgtMi40
LjI1RjQvaW5jbHVkZS9saW51eC9zeXNjdGwuaAotLS0gbGludXgtMi40LjI1RjIvaW5jbHVkZS9s
aW51eC9zeXNjdGwuaAkyMDA0LTAyLTIwIDE1OjEzOjAxLjAwMDAwMDAwMCAtMDgwMAorKysgbGlu
dXgtMi40LjI1RjQvaW5jbHVkZS9saW51eC9zeXNjdGwuaAkyMDA0LTAzLTA0IDE3OjAyOjU0LjAw
MDAwMDAwMCAtMDgwMApAQCAtMzEyLDYgKzMxMiw3IEBACiAJTkVUX1RDUF9GUlRPPTkyLAogCU5F
VF9UQ1BfTE9XX0xBVEVOQ1k9OTMsCiAJTkVUX0lQVjRfSVBGUkFHX1NFQ1JFVF9JTlRFUlZBTD05
NCwKKwlORVRfSVBWNF9JR01QX01BWF9NU0Y9OTYsCiB9OwogCiBlbnVtIHsKZGlmZiAtcnVOIGxp
bnV4LTIuNC4yNUYyL25ldC9pcHY0L2lnbXAuYyBsaW51eC0yLjQuMjVGNC9uZXQvaXB2NC9pZ21w
LmMKLS0tIGxpbnV4LTIuNC4yNUYyL25ldC9pcHY0L2lnbXAuYwkyMDA0LTAyLTE4IDA1OjM2OjMy
LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi40LjI1RjQvbmV0L2lwdjQvaWdtcC5jCTIwMDQt
MDMtMDQgMTU6NDc6MDkuMDAwMDAwMDAwIC0wODAwCkBAIC0xMDEsNyArMTAxLDggQEAKICNlbmRp
ZgogCiAKLSNkZWZpbmUgSVBfTUFYX01FTUJFUlNISVBTIDIwCisjZGVmaW5lIElQX01BWF9NRU1C
RVJTSElQUwkyMAorI2RlZmluZSBJUF9NQVhfTVNGCQkxMAogCiAjaWZkZWYgQ09ORklHX0lQX01V
TFRJQ0FTVAogLyogUGFyYW1ldGVyIG5hbWVzIGFuZCB2YWx1ZXMgYXJlIHRha2VuIGZyb20gaWdt
cC12Mi0wNiBkcmFmdCAqLwpAQCAtMTMxMSw2ICsxMzEyLDcgQEAKICAqCUpvaW4gYSBzb2NrZXQg
dG8gYSBncm91cAogICovCiBpbnQgc3lzY3RsX2lnbXBfbWF4X21lbWJlcnNoaXBzID0gSVBfTUFY
X01FTUJFUlNISVBTOworaW50IHN5c2N0bF9pZ21wX21heF9tc2YgPSBJUF9NQVhfTVNGOwogCiAK
IHN0YXRpYyBpbnQgaXBfbWNfZGVsMV9zcmMoc3RydWN0IGlwX21jX2xpc3QgKnBtYywgaW50IHNm
bW9kZSwKQEAgLTE3NzIsNiArMTc3NCwxMCBAQAogCX0KIAkvKiBlbHNlLCBhZGQgYSBuZXcgc291
cmNlIHRvIHRoZSBmaWx0ZXIgKi8KIAorCWlmIChwc2wgJiYgcHNsLT5zbF9jb3VudCA+PSBzeXNj
dGxfaWdtcF9tYXhfbXNmKSB7CisJCWVyciA9IC1FTk9CVUZTOworCQlnb3RvIGRvbmU7CisJfQog
CWlmICghcHNsIHx8IHBzbC0+c2xfY291bnQgPT0gcHNsLT5zbF9tYXgpIHsKIAkJc3RydWN0IGlw
X3NmX3NvY2tsaXN0ICpuZXdwc2w7CiAJCWludCBjb3VudCA9IElQX1NGQkxPQ0s7CmRpZmYgLXJ1
TiBsaW51eC0yLjQuMjVGMi9uZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jIGxpbnV4LTIuNC4yNUY0L25l
dC9pcHY0L2lwX3NvY2tnbHVlLmMKLS0tIGxpbnV4LTIuNC4yNUYyL25ldC9pcHY0L2lwX3NvY2tn
bHVlLmMJMjAwNC0wMi0yMyAxNzowMzoxMC4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNC4y
NUY0L25ldC9pcHY0L2lwX3NvY2tnbHVlLmMJMjAwNC0wMy0wNCAxOToyOTozMy4wMDAwMDAwMDAg
LTA4MDAKQEAgLTYwOSw2ICs2MDksNyBAQAogCQljYXNlIElQX01TRklMVEVSOgogCQl7CiAJCQll
eHRlcm4gaW50IHN5c2N0bF9vcHRtZW1fbWF4OworCQkJZXh0ZXJuIGludCBzeXNjdGxfaWdtcF9t
YXhfbXNmOwogCQkJc3RydWN0IGlwX21zZmlsdGVyICptc2Y7CiAKIAkJCWlmIChvcHRsZW4gPCBJ
UF9NU0ZJTFRFUl9TSVpFKDApKQpAQCAtNjI3LDkgKzYyOCwxNCBAQAogCQkJCWtmcmVlKG1zZik7
CiAJCQkJYnJlYWs7CiAJCQl9Ci0JCQlpZiAoSVBfTVNGSUxURVJfU0laRShtc2YtPmltc2ZfbnVt
c3JjKSA8IAotCQkJICAgIElQX01TRklMVEVSX1NJWkUoMCkgfHwKLQkJCSAgICBJUF9NU0ZJTFRF
Ul9TSVpFKG1zZi0+aW1zZl9udW1zcmMpID4gb3B0bGVuKSB7CisJCQkvKiBudW1zcmMgPj0gKDFH
LTQpIG92ZXJmbG93IGluIDMyIGJpdHMgKi8KKwkJCWlmIChtc2YtPmltc2ZfbnVtc3JjID49IDB4
M2ZmZmZmZmNVIHx8CisJCQkgICAgbXNmLT5pbXNmX251bXNyYyA+IHN5c2N0bF9pZ21wX21heF9t
c2YpIHsKKwkJCQlrZnJlZShtc2YpOworCQkJCWVyciA9IC1FTk9CVUZTOworCQkJCWJyZWFrOwor
CQkJfQorCQkJaWYgKElQX01TRklMVEVSX1NJWkUobXNmLT5pbXNmX251bXNyYykgPiBvcHRsZW4p
IHsKIAkJCQlrZnJlZShtc2YpOwogCQkJCWVyciA9IC1FSU5WQUw7CiAJCQkJYnJlYWs7CmRpZmYg
LXJ1TiBsaW51eC0yLjQuMjVGMi9uZXQvaXB2NC9zeXNjdGxfbmV0X2lwdjQuYyBsaW51eC0yLjQu
MjVGNC9uZXQvaXB2NC9zeXNjdGxfbmV0X2lwdjQuYwotLS0gbGludXgtMi40LjI1RjIvbmV0L2lw
djQvc3lzY3RsX25ldF9pcHY0LmMJMjAwMy0wNi0xMyAwNzo1MTozOS4wMDAwMDAwMDAgLTA3MDAK
KysrIGxpbnV4LTIuNC4yNUY0L25ldC9pcHY0L3N5c2N0bF9uZXRfaXB2NC5jCTIwMDQtMDMtMDQg
MTQ6NDc6MzEuMDAwMDAwMDAwIC0wODAwCkBAIC0zOCw2ICszOCw3IEBACiAKIC8qIEZyb20gaWdt
cC5jICovCiBleHRlcm4gaW50IHN5c2N0bF9pZ21wX21heF9tZW1iZXJzaGlwczsKK2V4dGVybiBp
bnQgc3lzY3RsX2lnbXBfbWF4X21zZjsKIAogLyogRnJvbSBpbmV0cGVlci5jICovCiBleHRlcm4g
aW50IGluZXRfcGVlcl90aHJlc2hvbGQ7CkBAIC0xODIsNiArMTgzLDggQEAKIAl7TkVUX0lQVjRf
SUdNUF9NQVhfTUVNQkVSU0hJUFMsICJpZ21wX21heF9tZW1iZXJzaGlwcyIsCiAJICZzeXNjdGxf
aWdtcF9tYXhfbWVtYmVyc2hpcHMsIHNpemVvZihpbnQpLCAwNjQ0LCBOVUxMLCAmcHJvY19kb2lu
dHZlY30sCiAjZW5kaWYKKwl7TkVUX0lQVjRfSUdNUF9NQVhfTVNGLCAiaWdtcF9tYXhfbXNmIiwK
KwkgJnN5c2N0bF9pZ21wX21heF9tc2YsIHNpemVvZihpbnQpLCAwNjQ0LCBOVUxMLCAmcHJvY19k
b2ludHZlY30sCiAJe05FVF9JUFY0X0lORVRfUEVFUl9USFJFU0hPTEQsICJpbmV0X3BlZXJfdGhy
ZXNob2xkIiwKIAkgJmluZXRfcGVlcl90aHJlc2hvbGQsIHNpemVvZihpbnQpLCAwNjQ0LCBOVUxM
LCAmcHJvY19kb2ludHZlY30sCiAJe05FVF9JUFY0X0lORVRfUEVFUl9NSU5UVEwsICJpbmV0X3Bl
ZXJfbWludHRsIiwK

--0__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79
Content-type: application/octet-stream;
	name="2.6.4rc2igmpmsflimit2.patch"
Content-Disposition: attachment; filename="2.6.4rc2igmpmsflimit2.patch"
Content-ID: <20__=07BBE4DDDF88AA798f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi40cmMyL2luY2x1ZGUvbGludXgvc3lzY3RsLmggbGludXgtMi42
LjRyYzJGMS9pbmNsdWRlL2xpbnV4L3N5c2N0bC5oCi0tLSBsaW51eC0yLjYuNHJjMi9pbmNsdWRl
L2xpbnV4L3N5c2N0bC5oCTIwMDQtMDMtMDQgMTk6MDU6MTcuMDAwMDAwMDAwIC0wODAwCisrKyBs
aW51eC0yLjYuNHJjMkYxL2luY2x1ZGUvbGludXgvc3lzY3RsLmgJMjAwNC0wMy0wNCAxNjo1Nzoy
Ni4wMDAwMDAwMDAgLTA4MDAKQEAgLTMyMSw2ICszMjEsNyBAQAogCU5FVF9UQ1BfTE9XX0xBVEVO
Q1k9OTMsCiAJTkVUX0lQVjRfSVBGUkFHX1NFQ1JFVF9JTlRFUlZBTD05NCwKIAlORVRfVENQX1dF
U1RXT09EPTk1LAorCU5FVF9JUFY0X0lHTVBfTUFYX01TRj05NiwKIH07CiAKIGVudW0gewpkaWZm
IC1ydU4gbGludXgtMi42LjRyYzIvbmV0L2lwdjQvaWdtcC5jIGxpbnV4LTIuNi40cmMyRjEvbmV0
L2lwdjQvaWdtcC5jCi0tLSBsaW51eC0yLjYuNHJjMi9uZXQvaXB2NC9pZ21wLmMJMjAwNC0wMi0x
NyAxOTo1OTo0OC4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi40cmMyRjEvbmV0L2lwdjQv
aWdtcC5jCTIwMDQtMDMtMDQgMTY6MTg6NDIuMDAwMDAwMDAwIC0wODAwCkBAIC0xMDUsNyArMTA1
LDggQEAKICNpbmNsdWRlIDxsaW51eC9zZXFfZmlsZS5oPgogI2VuZGlmCiAKLSNkZWZpbmUgSVBf
TUFYX01FTUJFUlNISVBTIDIwCisjZGVmaW5lIElQX01BWF9NRU1CRVJTSElQUwkyMAorI2RlZmlu
ZSBJUF9NQVhfTVNGCQkxMAogCiAjaWZkZWYgQ09ORklHX0lQX01VTFRJQ0FTVAogLyogUGFyYW1l
dGVyIG5hbWVzIGFuZCB2YWx1ZXMgYXJlIHRha2VuIGZyb20gaWdtcC12Mi0wNiBkcmFmdCAqLwpA
QCAtMTMyNSw2ICsxMzI2LDcgQEAKICAqCUpvaW4gYSBzb2NrZXQgdG8gYSBncm91cAogICovCiBp
bnQgc3lzY3RsX2lnbXBfbWF4X21lbWJlcnNoaXBzID0gSVBfTUFYX01FTUJFUlNISVBTOworaW50
IHN5c2N0bF9pZ21wX21heF9tc2YgPSBJUF9NQVhfTVNGOwogCiAKIHN0YXRpYyBpbnQgaXBfbWNf
ZGVsMV9zcmMoc3RydWN0IGlwX21jX2xpc3QgKnBtYywgaW50IHNmbW9kZSwKQEAgLTE3OTAsNiAr
MTc5MiwxMCBAQAogCX0KIAkvKiBlbHNlLCBhZGQgYSBuZXcgc291cmNlIHRvIHRoZSBmaWx0ZXIg
Ki8KIAorCWlmIChwc2wgJiYgcHNsLT5zbF9jb3VudCA+PSBzeXNjdGxfaWdtcF9tYXhfbXNmKSB7
CisJCWVyciA9IC1FTk9CVUZTOworCQlnb3RvIGRvbmU7CisJfQogCWlmICghcHNsIHx8IHBzbC0+
c2xfY291bnQgPT0gcHNsLT5zbF9tYXgpIHsKIAkJc3RydWN0IGlwX3NmX3NvY2tsaXN0ICpuZXdw
c2w7CiAJCWludCBjb3VudCA9IElQX1NGQkxPQ0s7CmRpZmYgLXJ1TiBsaW51eC0yLjYuNHJjMi9u
ZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jIGxpbnV4LTIuNi40cmMyRjEvbmV0L2lwdjQvaXBfc29ja2ds
dWUuYwotLS0gbGludXgtMi42LjRyYzIvbmV0L2lwdjQvaXBfc29ja2dsdWUuYwkyMDA0LTAzLTA0
IDE5OjA1OjE4LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjRyYzJGMS9uZXQvaXB2NC9p
cF9zb2NrZ2x1ZS5jCTIwMDQtMDMtMDQgMTk6MzA6MjYuMDAwMDAwMDAwIC0wODAwCkBAIC02MTgs
NiArNjE4LDcgQEAKIAkJY2FzZSBJUF9NU0ZJTFRFUjoKIAkJewogCQkJZXh0ZXJuIGludCBzeXNj
dGxfb3B0bWVtX21heDsKKwkJCWV4dGVybiBpbnQgc3lzY3RsX2lnbXBfbWF4X21zZjsKIAkJCXN0
cnVjdCBpcF9tc2ZpbHRlciAqbXNmOwogCiAJCQlpZiAob3B0bGVuIDwgSVBfTVNGSUxURVJfU0la
RSgwKSkKQEAgLTYzNiw5ICs2MzcsMTQgQEAKIAkJCQlrZnJlZShtc2YpOwogCQkJCWJyZWFrOwog
CQkJfQotCQkJaWYgKElQX01TRklMVEVSX1NJWkUobXNmLT5pbXNmX251bXNyYykgPCAKLQkJCSAg
ICBJUF9NU0ZJTFRFUl9TSVpFKDApIHx8Ci0JCQkgICAgSVBfTVNGSUxURVJfU0laRShtc2YtPmlt
c2ZfbnVtc3JjKSA+IG9wdGxlbikgeworCQkJLyogbnVtc3JjID49ICgxRy00KSBvdmVyZmxvdyBp
biAzMiBiaXRzICovCisJCQlpZiAobXNmLT5pbXNmX251bXNyYyA+PSAweDNmZmZmZmZjVSB8fAor
CQkJICAgIG1zZi0+aW1zZl9udW1zcmMgPiBzeXNjdGxfaWdtcF9tYXhfbXNmKSB7CisJCQkJa2Zy
ZWUobXNmKTsKKwkJCQllcnIgPSAtRU5PQlVGUzsKKwkJCQlicmVhazsKKwkJCX0KKwkJCWlmIChJ
UF9NU0ZJTFRFUl9TSVpFKG1zZi0+aW1zZl9udW1zcmMpID4gb3B0bGVuKSB7CiAJCQkJa2ZyZWUo
bXNmKTsKIAkJCQllcnIgPSAtRUlOVkFMOwogCQkJCWJyZWFrOwpkaWZmIC1ydU4gbGludXgtMi42
LjRyYzIvbmV0L2lwdjQvc3lzY3RsX25ldF9pcHY0LmMgbGludXgtMi42LjRyYzJGMS9uZXQvaXB2
NC9zeXNjdGxfbmV0X2lwdjQuYwotLS0gbGludXgtMi42LjRyYzIvbmV0L2lwdjQvc3lzY3RsX25l
dF9pcHY0LmMJMjAwNC0wMi0xNyAxOTo1ODo1MC4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIu
Ni40cmMyRjEvbmV0L2lwdjQvc3lzY3RsX25ldF9pcHY0LmMJMjAwNC0wMy0wNCAxNjoyMjowNS4w
MDAwMDAwMDAgLTA4MDAKQEAgLTM5LDYgKzM5LDcgQEAKIAogLyogRnJvbSBpZ21wLmMgKi8KIGV4
dGVybiBpbnQgc3lzY3RsX2lnbXBfbWF4X21lbWJlcnNoaXBzOworZXh0ZXJuIGludCBzeXNjdGxf
aWdtcF9tYXhfbXNmOwogCiAvKiBGcm9tIGluZXRwZWVyLmMgKi8KIGV4dGVybiBpbnQgaW5ldF9w
ZWVyX3RocmVzaG9sZDsKQEAgLTQxMiw2ICs0MTMsMTQgQEAKIAogI2VuZGlmCiAJeworCQkuY3Rs
X25hbWUJPSBORVRfSVBWNF9JR01QX01BWF9NU0YsCisJCS5wcm9jbmFtZQk9ICJpZ21wX21heF9t
c2YiLAorCQkuZGF0YQkJPSAmc3lzY3RsX2lnbXBfbWF4X21zZiwKKwkJLm1heGxlbgkJPSBzaXpl
b2YoaW50KSwKKwkJLm1vZGUJCT0gMDY0NCwKKwkJLnByb2NfaGFuZGxlcgk9ICZwcm9jX2RvaW50
dmVjCisJfSwKKwl7CiAJCS5jdGxfbmFtZQk9IE5FVF9JUFY0X0lORVRfUEVFUl9USFJFU0hPTEQs
CiAJCS5wcm9jbmFtZQk9ICJpbmV0X3BlZXJfdGhyZXNob2xkIiwKIAkJLmRhdGEJCT0gJmluZXRf
cGVlcl90aHJlc2hvbGQsCg==

--0__=07BBE4DDDF88AA798f9e8a93df938690918c07BBE4DDDF88AA79--
