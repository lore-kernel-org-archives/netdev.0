From: David Stevens <dlstevens@us.ibm.com>
Subject: sysctl variable to force MLD version [PATCH]
Date: Mon, 16 Feb 2004 22:14:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2AD6D710.B1604DA1-ON88256E3D.001C2A6D-88256E3D.001C8122@us.ibm.com>
References: <m3wu6p6c3f.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD"
Cc: davem@redhat.com, Takashi Hibi <hibi665@oki.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <m3wu6p6c3f.wl@sfc.wide.ad.jp>
To: Yuji Sekiya <sekiya@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD
Content-type: multipart/alternative;
	Boundary="1__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD"

--1__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD
Content-type: text/plain; charset=US-ASCII





Dave,
      Below is a patch for 2.6.2 that adds a sysctl variable
to force the MLD version to version 1, for MLD-snooping switches
that don't understand version 2 packet formats.
      I'll do a 2.4 version of the patch soon.

                              +-DLS

diff -ruN linux-2.6.2/include/linux/ipv6.h linux-2.6.2F3/include/linux/ipv6.h
--- linux-2.6.2/include/linux/ipv6.h      2004-02-03 19:44:05.000000000 -0800
+++ linux-2.6.2F3/include/linux/ipv6.h    2004-02-16 17:35:44.000000000 -0800
@@ -136,6 +136,7 @@
      __s32       rtr_solicits;
      __s32       rtr_solicit_interval;
      __s32       rtr_solicit_delay;
+     __s32       force_mld_version;
 #ifdef CONFIG_IPV6_PRIVACY
      __s32       use_tempaddr;
      __s32       temp_valid_lft;
@@ -165,6 +166,7 @@
      DEVCONF_REGEN_MAX_RETRY,
      DEVCONF_MAX_DESYNC_FACTOR,
      DEVCONF_MAX_ADDRESSES,
+     DEVCONF_FORCE_MLD_VERSION,
      DEVCONF_MAX
 };

diff -ruN linux-2.6.2/include/linux/sysctl.h linux-2.6.2F3/include/linux/sysctl.h
--- linux-2.6.2/include/linux/sysctl.h    2004-02-03 19:43:56.000000000 -0800
+++ linux-2.6.2F3/include/linux/sysctl.h  2004-02-16 17:14:30.000000000 -0800
@@ -421,7 +421,8 @@
      NET_IPV6_TEMP_PREFERED_LFT=13,
      NET_IPV6_REGEN_MAX_RETRY=14,
      NET_IPV6_MAX_DESYNC_FACTOR=15,
-     NET_IPV6_MAX_ADDRESSES=16
+     NET_IPV6_MAX_ADDRESSES=16,
+     NET_IPV6_FORCE_MLD_VERSION=17
 };

 /* /proc/sys/net/ipv6/icmp */
diff -ruN linux-2.6.2/net/ipv6/addrconf.c linux-2.6.2F3/net/ipv6/addrconf.c
--- linux-2.6.2/net/ipv6/addrconf.c 2004-02-03 19:44:43.000000000 -0800
+++ linux-2.6.2F3/net/ipv6/addrconf.c     2004-02-16 19:51:08.000000000 -0800
@@ -149,6 +149,7 @@
      .accept_ra        = 1,
      .accept_redirects = 1,
      .autoconf         = 1,
+     .force_mld_version      = 0,
      .dad_transmits          = 1,
      .rtr_solicits           = MAX_RTR_SOLICITATIONS,
      .rtr_solicit_interval   = RTR_SOLICITATION_INTERVAL,
@@ -2739,6 +2740,7 @@
      array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
      array[DEVCONF_RTR_SOLICIT_INTERVAL] = cnf->rtr_solicit_interval;
      array[DEVCONF_RTR_SOLICIT_DELAY] = cnf->rtr_solicit_delay;
+     array[DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
 #ifdef CONFIG_IPV6_PRIVACY
      array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
      array[DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
@@ -3042,7 +3044,7 @@
 static struct addrconf_sysctl_table
 {
      struct ctl_table_header *sysctl_header;
-     ctl_table addrconf_vars[17];
+     ctl_table addrconf_vars[18];
      ctl_table addrconf_dev[2];
      ctl_table addrconf_conf_dir[2];
      ctl_table addrconf_proto_dir[2];
@@ -3133,6 +3135,14 @@
                  .proc_handler     =     &proc_dointvec_jiffies,
                  .strategy   =     &sysctl_jiffies,
            },
+           {
+                 .ctl_name   =     NET_IPV6_FORCE_MLD_VERSION,
+                 .procname   =     "force_mld_version",
+                 .data       =     &ipv6_devconf.force_mld_version,
+                 .maxlen           =     sizeof(int),
+                 .mode       =     0644,
+                 .proc_handler     =     &proc_dointvec,
+           },
 #ifdef CONFIG_IPV6_PRIVACY
            {
                  .ctl_name   =     NET_IPV6_USE_TEMPADDR,
diff -ruN linux-2.6.2/net/ipv6/mcast.c linux-2.6.2F3/net/ipv6/mcast.c
--- linux-2.6.2/net/ipv6/mcast.c    2004-02-03 19:44:28.000000000 -0800
+++ linux-2.6.2F3/net/ipv6/mcast.c  2004-02-16 20:11:30.000000000 -0800
@@ -152,8 +152,10 @@
 #define IGMP6_UNSOLICITED_IVAL     (10*HZ)
 #define MLD_QRV_DEFAULT            2

-#define MLD_V1_SEEN(idev) ((idev)->mc_v1_seen && \
-           time_before(jiffies, (idev)->mc_v1_seen))
+#define MLD_V1_SEEN(idev) (ipv6_devconf.force_mld_version == 1 || \
+           (idev)->cnf.force_mld_version == 1 || \
+           ((idev)->mc_v1_seen && \
+           time_before(jiffies, (idev)->mc_v1_seen)))

 #define MLDV2_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & (value))
 #define MLDV2_EXP(thresh, nbmant, nbexp, value) \

(See attached file: mldsysctl.patch)
--1__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>Dave,</tt><br>
<tt>	Below is a patch for 2.6.2 that adds a sysctl variable</tt><br>
<tt>to force the MLD version to version 1, for MLD-snooping switches</tt><br>
<tt>that don't understand version 2 packet formats.</tt><br>
<tt>	I'll do a 2.4 version of the patch soon.</tt><br>
<br>
<tt>					+-DLS</tt><br>
<br>
<tt>diff -ruN linux-2.6.2/include/linux/ipv6.h linux-2.6.2F3/include/linux/ipv6.h<br>
--- linux-2.6.2/include/linux/ipv6.h	2004-02-03 19:44:05.000000000 -0800<br>
+++ linux-2.6.2F3/include/linux/ipv6.h	2004-02-16 17:35:44.000000000 -0800<br>
@@ -136,6 +136,7 @@<br>
 	__s32		rtr_solicits;<br>
 	__s32		rtr_solicit_interval;<br>
 	__s32		rtr_solicit_delay;<br>
+	__s32		force_mld_version;<br>
 #ifdef CONFIG_IPV6_PRIVACY<br>
 	__s32		use_tempaddr;<br>
 	__s32		temp_valid_lft;<br>
@@ -165,6 +166,7 @@<br>
 	DEVCONF_REGEN_MAX_RETRY,<br>
 	DEVCONF_MAX_DESYNC_FACTOR,<br>
 	DEVCONF_MAX_ADDRESSES,<br>
+	DEVCONF_FORCE_MLD_VERSION,<br>
 	DEVCONF_MAX<br>
 };<br>
 <br>
diff -ruN linux-2.6.2/include/linux/sysctl.h linux-2.6.2F3/include/linux/sysctl.h<br>
--- linux-2.6.2/include/linux/sysctl.h	2004-02-03 19:43:56.000000000 -0800<br>
+++ linux-2.6.2F3/include/linux/sysctl.h	2004-02-16 17:14:30.000000000 -0800<br>
@@ -421,7 +421,8 @@<br>
 	NET_IPV6_TEMP_PREFERED_LFT=13,<br>
 	NET_IPV6_REGEN_MAX_RETRY=14,<br>
 	NET_IPV6_MAX_DESYNC_FACTOR=15,<br>
-	NET_IPV6_MAX_ADDRESSES=16<br>
+	NET_IPV6_MAX_ADDRESSES=16,<br>
+	NET_IPV6_FORCE_MLD_VERSION=17<br>
 };</tt><br>
<tt> <br>
 /* /proc/sys/net/ipv6/icmp */<br>
diff -ruN linux-2.6.2/net/ipv6/addrconf.c linux-2.6.2F3/net/ipv6/addrconf.c<br>
--- linux-2.6.2/net/ipv6/addrconf.c	2004-02-03 19:44:43.000000000 -0800<br>
+++ linux-2.6.2F3/net/ipv6/addrconf.c	2004-02-16 19:51:08.000000000 -0800<br>
@@ -149,6 +149,7 @@<br>
 	.accept_ra		= 1,<br>
 	.accept_redirects	= 1,<br>
 	.autoconf		= 1,<br>
+	.force_mld_version	= 0,<br>
 	.dad_transmits		= 1,<br>
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,<br>
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,<br>
@@ -2739,6 +2740,7 @@<br>
 	array[DEVCONF_RTR_SOLICITS] = cnf-&gt;rtr_solicits;<br>
 	array[DEVCONF_RTR_SOLICIT_INTERVAL] = cnf-&gt;rtr_solicit_interval;<br>
 	array[DEVCONF_RTR_SOLICIT_DELAY] = cnf-&gt;rtr_solicit_delay;<br>
+	array[DEVCONF_FORCE_MLD_VERSION] = cnf-&gt;force_mld_version;<br>
 #ifdef CONFIG_IPV6_PRIVACY<br>
 	array[DEVCONF_USE_TEMPADDR] = cnf-&gt;use_tempaddr;<br>
 	array[DEVCONF_TEMP_VALID_LFT] = cnf-&gt;temp_valid_lft;<br>
@@ -3042,7 +3044,7 @@<br>
 static struct addrconf_sysctl_table<br>
 {<br>
 	struct ctl_table_header *sysctl_header;<br>
-	ctl_table addrconf_vars[17];<br>
+	ctl_table addrconf_vars[18];</tt><br>
<tt> 	ctl_table addrconf_dev[2];<br>
 	ctl_table addrconf_conf_dir[2];<br>
 	ctl_table addrconf_proto_dir[2];<br>
@@ -3133,6 +3135,14 @@<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;		.proc_handler	=	&amp;proc_dointvec_jiffies,<br>
 			.strategy	=	&amp;sysctl_jiffies,<br>
 		},<br>
+		{<br>
+			.ctl_name	=	NET_IPV6_FORCE_MLD_VERSION,<br>
+			.procname	=	&quot;force_mld_version&quot;,<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; 		.data		=	&amp;ipv6_devconf.force_mld_version,<br>
+			.maxlen		=	sizeof(int),<br>
+			.mode		=	0644,<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; 		.proc_handler	=	&amp;proc_dointvec,<br>
+		},<br>
 #ifdef CONFIG_IPV6_PRIVACY<br>
 		{<br>
 			.ctl_name	=	NET_IPV6_USE_TEMPADDR,<br>
diff -ruN linux-2.6.2/net/ipv6/mcast.c linux-2.6.2F3/net/ipv6/mcast.c<br>
--- linux-2.6.2/net/ipv6/mcast.c	2004-02-03 19:44:28.000000000 -0800<br>
+++ linux-2.6.2F3/net/ipv6/mcast.c	2004-02-16 20:11:30.000000000 -0800<br>
@@ -152,8 +152,10 @@<br>
 #define IGMP6_UNSOLICITED_IVAL	(10*HZ)<br>
 #define MLD_QRV_DEFAULT		2<br>
 <br>
-#define MLD_V1_SEEN(idev) ((idev)-&gt;mc_v1_seen &amp;&amp; \<br>
-		time_before(jiffies, (idev)-&gt;mc_v1_seen))<br>
+#define MLD_V1_SEEN(idev) (ipv6_devconf.force_mld_version == 1 || \<br>
+		(idev)-&gt;cnf.force_mld_version == 1 || \</tt><br>
<tt>+		((idev)-&gt;mc_v1_seen &amp;&amp; \<br>
+		time_before(jiffies, (idev)-&gt;mc_v1_seen)))<br>
 <br>
 #define MLDV2_MASK(value, nb) ((nb)&gt;=32 ? (value) : ((1&lt;&lt;(nb))-1) &amp; (value))<br>
 #define MLDV2_EXP(thresh, nbmant, nbexp, value) \</tt><br>
<br>
<i>(See attached file: mldsysctl.patch)</i></body></html>

--1__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD--


--0__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD
Content-type: application/octet-stream;
	name="mldsysctl.patch"
Content-Disposition: attachment; filename="mldsysctl.patch"
Content-ID: <10__=07BBE4AEDF8FACFD8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbGludXgvaXB2Ni5oIGxpbnV4LTIuNi4yRjMv
aW5jbHVkZS9saW51eC9pcHY2LmgKLS0tIGxpbnV4LTIuNi4yL2luY2x1ZGUvbGludXgvaXB2Ni5o
CTIwMDQtMDItMDMgMTk6NDQ6MDUuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMkYzL2lu
Y2x1ZGUvbGludXgvaXB2Ni5oCTIwMDQtMDItMTYgMTc6MzU6NDQuMDAwMDAwMDAwIC0wODAwCkBA
IC0xMzYsNiArMTM2LDcgQEAKIAlfX3MzMgkJcnRyX3NvbGljaXRzOwogCV9fczMyCQlydHJfc29s
aWNpdF9pbnRlcnZhbDsKIAlfX3MzMgkJcnRyX3NvbGljaXRfZGVsYXk7CisJX19zMzIJCWZvcmNl
X21sZF92ZXJzaW9uOwogI2lmZGVmIENPTkZJR19JUFY2X1BSSVZBQ1kKIAlfX3MzMgkJdXNlX3Rl
bXBhZGRyOwogCV9fczMyCQl0ZW1wX3ZhbGlkX2xmdDsKQEAgLTE2NSw2ICsxNjYsNyBAQAogCURF
VkNPTkZfUkVHRU5fTUFYX1JFVFJZLAogCURFVkNPTkZfTUFYX0RFU1lOQ19GQUNUT1IsCiAJREVW
Q09ORl9NQVhfQUREUkVTU0VTLAorCURFVkNPTkZfRk9SQ0VfTUxEX1ZFUlNJT04sCiAJREVWQ09O
Rl9NQVgKIH07CiAKZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbGludXgvc3lzY3RsLmgg
bGludXgtMi42LjJGMy9pbmNsdWRlL2xpbnV4L3N5c2N0bC5oCi0tLSBsaW51eC0yLjYuMi9pbmNs
dWRlL2xpbnV4L3N5c2N0bC5oCTIwMDQtMDItMDMgMTk6NDM6NTYuMDAwMDAwMDAwIC0wODAwCisr
KyBsaW51eC0yLjYuMkYzL2luY2x1ZGUvbGludXgvc3lzY3RsLmgJMjAwNC0wMi0xNiAxNzoxNDoz
MC4wMDAwMDAwMDAgLTA4MDAKQEAgLTQyMSw3ICs0MjEsOCBAQAogCU5FVF9JUFY2X1RFTVBfUFJF
RkVSRURfTEZUPTEzLAogCU5FVF9JUFY2X1JFR0VOX01BWF9SRVRSWT0xNCwKIAlORVRfSVBWNl9N
QVhfREVTWU5DX0ZBQ1RPUj0xNSwKLQlORVRfSVBWNl9NQVhfQUREUkVTU0VTPTE2CisJTkVUX0lQ
VjZfTUFYX0FERFJFU1NFUz0xNiwKKwlORVRfSVBWNl9GT1JDRV9NTERfVkVSU0lPTj0xNwogfTsK
IAogLyogL3Byb2Mvc3lzL25ldC9pcHY2L2ljbXAgKi8KZGlmZiAtcnVOIGxpbnV4LTIuNi4yL25l
dC9pcHY2L2FkZHJjb25mLmMgbGludXgtMi42LjJGMy9uZXQvaXB2Ni9hZGRyY29uZi5jCi0tLSBs
aW51eC0yLjYuMi9uZXQvaXB2Ni9hZGRyY29uZi5jCTIwMDQtMDItMDMgMTk6NDQ6NDMuMDAwMDAw
MDAwIC0wODAwCisrKyBsaW51eC0yLjYuMkYzL25ldC9pcHY2L2FkZHJjb25mLmMJMjAwNC0wMi0x
NiAxOTo1MTowOC4wMDAwMDAwMDAgLTA4MDAKQEAgLTE0OSw2ICsxNDksNyBAQAogCS5hY2NlcHRf
cmEJCT0gMSwKIAkuYWNjZXB0X3JlZGlyZWN0cwk9IDEsCiAJLmF1dG9jb25mCQk9IDEsCisJLmZv
cmNlX21sZF92ZXJzaW9uCT0gMCwKIAkuZGFkX3RyYW5zbWl0cwkJPSAxLAogCS5ydHJfc29saWNp
dHMJCT0gTUFYX1JUUl9TT0xJQ0lUQVRJT05TLAogCS5ydHJfc29saWNpdF9pbnRlcnZhbAk9IFJU
Ul9TT0xJQ0lUQVRJT05fSU5URVJWQUwsCkBAIC0yNzM5LDYgKzI3NDAsNyBAQAogCWFycmF5W0RF
VkNPTkZfUlRSX1NPTElDSVRTXSA9IGNuZi0+cnRyX3NvbGljaXRzOwogCWFycmF5W0RFVkNPTkZf
UlRSX1NPTElDSVRfSU5URVJWQUxdID0gY25mLT5ydHJfc29saWNpdF9pbnRlcnZhbDsKIAlhcnJh
eVtERVZDT05GX1JUUl9TT0xJQ0lUX0RFTEFZXSA9IGNuZi0+cnRyX3NvbGljaXRfZGVsYXk7CisJ
YXJyYXlbREVWQ09ORl9GT1JDRV9NTERfVkVSU0lPTl0gPSBjbmYtPmZvcmNlX21sZF92ZXJzaW9u
OwogI2lmZGVmIENPTkZJR19JUFY2X1BSSVZBQ1kKIAlhcnJheVtERVZDT05GX1VTRV9URU1QQURE
Ul0gPSBjbmYtPnVzZV90ZW1wYWRkcjsKIAlhcnJheVtERVZDT05GX1RFTVBfVkFMSURfTEZUXSA9
IGNuZi0+dGVtcF92YWxpZF9sZnQ7CkBAIC0zMDQyLDcgKzMwNDQsNyBAQAogc3RhdGljIHN0cnVj
dCBhZGRyY29uZl9zeXNjdGxfdGFibGUKIHsKIAlzdHJ1Y3QgY3RsX3RhYmxlX2hlYWRlciAqc3lz
Y3RsX2hlYWRlcjsKLQljdGxfdGFibGUgYWRkcmNvbmZfdmFyc1sxN107CisJY3RsX3RhYmxlIGFk
ZHJjb25mX3ZhcnNbMThdOwogCWN0bF90YWJsZSBhZGRyY29uZl9kZXZbMl07CiAJY3RsX3RhYmxl
IGFkZHJjb25mX2NvbmZfZGlyWzJdOwogCWN0bF90YWJsZSBhZGRyY29uZl9wcm90b19kaXJbMl07
CkBAIC0zMTMzLDYgKzMxMzUsMTQgQEAKICAgICAgICAgIAkJLnByb2NfaGFuZGxlcgk9CSZwcm9j
X2RvaW50dmVjX2ppZmZpZXMsCiAJCQkuc3RyYXRlZ3kJPQkmc3lzY3RsX2ppZmZpZXMsCiAJCX0s
CisJCXsKKwkJCS5jdGxfbmFtZQk9CU5FVF9JUFY2X0ZPUkNFX01MRF9WRVJTSU9OLAorCQkJLnBy
b2NuYW1lCT0JImZvcmNlX21sZF92ZXJzaW9uIiwKKyAgICAgICAgIAkJLmRhdGEJCT0JJmlwdjZf
ZGV2Y29uZi5mb3JjZV9tbGRfdmVyc2lvbiwKKwkJCS5tYXhsZW4JCT0Jc2l6ZW9mKGludCksCisJ
CQkubW9kZQkJPQkwNjQ0LAorICAgICAgICAgCQkucHJvY19oYW5kbGVyCT0JJnByb2NfZG9pbnR2
ZWMsCisJCX0sCiAjaWZkZWYgQ09ORklHX0lQVjZfUFJJVkFDWQogCQl7CiAJCQkuY3RsX25hbWUJ
PQlORVRfSVBWNl9VU0VfVEVNUEFERFIsCmRpZmYgLXJ1TiBsaW51eC0yLjYuMi9uZXQvaXB2Ni9t
Y2FzdC5jIGxpbnV4LTIuNi4yRjMvbmV0L2lwdjYvbWNhc3QuYwotLS0gbGludXgtMi42LjIvbmV0
L2lwdjYvbWNhc3QuYwkyMDA0LTAyLTAzIDE5OjQ0OjI4LjAwMDAwMDAwMCAtMDgwMAorKysgbGlu
dXgtMi42LjJGMy9uZXQvaXB2Ni9tY2FzdC5jCTIwMDQtMDItMTYgMjA6MTE6MzAuMDAwMDAwMDAw
IC0wODAwCkBAIC0xNTIsOCArMTUyLDEwIEBACiAjZGVmaW5lIElHTVA2X1VOU09MSUNJVEVEX0lW
QUwJKDEwKkhaKQogI2RlZmluZSBNTERfUVJWX0RFRkFVTFQJCTIKIAotI2RlZmluZSBNTERfVjFf
U0VFTihpZGV2KSAoKGlkZXYpLT5tY192MV9zZWVuICYmIFwKLQkJdGltZV9iZWZvcmUoamlmZmll
cywgKGlkZXYpLT5tY192MV9zZWVuKSkKKyNkZWZpbmUgTUxEX1YxX1NFRU4oaWRldikgKGlwdjZf
ZGV2Y29uZi5mb3JjZV9tbGRfdmVyc2lvbiA9PSAxIHx8IFwKKwkJKGlkZXYpLT5jbmYuZm9yY2Vf
bWxkX3ZlcnNpb24gPT0gMSB8fCBcCisJCSgoaWRldiktPm1jX3YxX3NlZW4gJiYgXAorCQl0aW1l
X2JlZm9yZShqaWZmaWVzLCAoaWRldiktPm1jX3YxX3NlZW4pKSkKIAogI2RlZmluZSBNTERWMl9N
QVNLKHZhbHVlLCBuYikgKChuYik+PTMyID8gKHZhbHVlKSA6ICgoMTw8KG5iKSktMSkgJiAodmFs
dWUpKQogI2RlZmluZSBNTERWMl9FWFAodGhyZXNoLCBuYm1hbnQsIG5iZXhwLCB2YWx1ZSkgXAo=

--0__=07BBE4AEDF8FACFD8f9e8a93df938690918c07BBE4AEDF8FACFD--
