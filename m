From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] fix IGMPv3 timer initialization when device not "upped"
Date: Wed, 31 Mar 2004 23:10:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF6BC12EE1.9BBDEC37-ON88256E69.0021C0E6-88256E69.0021F10B@us.ibm.com>
References: <20040330192558.1d9c8eb2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040330192558.1d9c8eb2.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676
Content-type: multipart/alternative;
	Boundary="1__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676"

--1__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676
Content-type: text/plain; charset=US-ASCII







netdev-bounce@oss.sgi.com wrote on 03/30/2004 07:25:58 PM:

> Applied, thanks David.  Can I have a 2.4.x variant under seperate
> cover please?  I did the "mc_initted" thing there too.

Dave,
      Here's a 2.4.x version of the patch.

                        +-DLS

diff -ruN linux-2.4.26-rc1/include/linux/inetdevice.h
linux-2.4.26-rc1F1/include/linux/inetdevice.h
--- linux-2.4.26-rc1/include/linux/inetdevice.h 2004-03-30
16:28:38.000000000 -0800
+++ linux-2.4.26-rc1F1/include/linux/inetdevice.h     2004-03-31
19:33:34.000000000 -0800
@@ -34,8 +34,6 @@
      rwlock_t          lock;
      int               dead;
      struct in_ifaddr  *ifa_list;  /* IP ifaddr chain            */
-     int               mc_initted;
-
      struct ip_mc_list *mc_list;   /* IP multicast filter chain    */
      rwlock_t          mc_lock;    /* for mc_tomb */
      struct ip_mc_list *mc_tomb;
diff -ruN linux-2.4.26-rc1/net/ipv4/devinet.c
linux-2.4.26-rc1F1/net/ipv4/devinet.c
--- linux-2.4.26-rc1/net/ipv4/devinet.c   2004-03-30 16:28:39.000000000
-0800
+++ linux-2.4.26-rc1F1/net/ipv4/devinet.c 2004-03-31 19:35:38.000000000
-0800
@@ -151,7 +151,8 @@
 #ifdef CONFIG_SYSCTL
      devinet_sysctl_register(in_dev, &in_dev->cnf);
 #endif
-     if (dev->flags&IFF_UP)
+     ip_mc_init_dev(in_dev);
+     if (dev->flags & IFF_UP)
            ip_mc_up(in_dev);
      return in_dev;
 }
diff -ruN linux-2.4.26-rc1/net/ipv4/igmp.c
linux-2.4.26-rc1F1/net/ipv4/igmp.c
--- linux-2.4.26-rc1/net/ipv4/igmp.c      2004-03-30 16:28:39.000000000 -0800
+++ linux-2.4.26-rc1F1/net/ipv4/igmp.c    2004-03-31 19:33:34.000000000 -0800
@@ -1205,8 +1205,8 @@

      ASSERT_RTNL();

-     if (!in_dev->mc_initted)
-           return;
+     for (i=in_dev->mc_list; i; i=i->next)
+           igmp_group_dropped(i);

 #ifdef CONFIG_IP_MULTICAST
      in_dev->mr_ifc_count = 0;
@@ -1215,24 +1215,14 @@
      in_dev->mr_gq_running = 0;
      if (del_timer(&in_dev->mr_gq_timer))
            __in_dev_put(in_dev);
-#endif
-
-     for (i=in_dev->mc_list; i; i=i->next)
-           igmp_group_dropped(i);
-
-#ifdef CONFIG_IP_MULTICAST
      igmpv3_clear_delrec(in_dev);
 #endif

      ip_mc_dec_group(in_dev, IGMP_ALL_HOSTS);
 }

-/* Device going up */
-
-void ip_mc_up(struct in_device *in_dev)
+void ip_mc_init_dev(struct in_device *in_dev)
 {
-     struct ip_mc_list *i;
-
      ASSERT_RTNL();

      in_dev->mc_tomb = 0;
@@ -1249,12 +1239,20 @@
 #endif

      in_dev->mc_lock = RW_LOCK_UNLOCKED;
+}
+
+/* Device going up */
+
+void ip_mc_up(struct in_device *in_dev)
+{
+     struct ip_mc_list *i;
+
+     ASSERT_RTNL();
+
      ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);

      for (i=in_dev->mc_list; i; i=i->next)
            igmp_group_added(i);
-
-     in_dev->mc_initted = 1;
 }

 /*
(See attached file: 2.4.26-rc1-igmpinit.patch)
--1__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>netdev-bounce@oss.sgi.com wrote on 03/30/2004 07:25:58 PM:<br>
<br>
&gt; Applied, thanks David. &nbsp;Can I have a 2.4.x variant under seperate<br>
&gt; cover please? &nbsp;I did the &quot;mc_initted&quot; thing there too.<br>
</tt><br>
<tt>Dave,</tt><br>
<tt>	Here's a 2.4.x version of the patch.</tt><br>
<br>
<tt>				+-DLS</tt><br>
<br>
<tt>diff -ruN linux-2.4.26-rc1/include/linux/inetdevice.h linux-2.4.26-rc1F1/include/linux/inetdevice.h<br>
--- linux-2.4.26-rc1/include/linux/inetdevice.h	2004-03-30 16:28:38.000000000 -0800<br>
+++ linux-2.4.26-rc1F1/include/linux/inetdevice.h	2004-03-31 19:33:34.000000000 -0800<br>
@@ -34,8 +34,6 @@<br>
 	rwlock_t		lock;<br>
 	int			dead;<br>
 	struct in_ifaddr	*ifa_list;	/* IP ifaddr chain		*/<br>
-	int			mc_initted;<br>
-<br>
 	struct ip_mc_list	*mc_list;	/* IP multicast filter chain &nbsp; &nbsp;*/<br>
 	rwlock_t		mc_lock;	/* for mc_tomb */<br>
 	struct ip_mc_list	*mc_tomb;<br>
diff -ruN linux-2.4.26-rc1/net/ipv4/devinet.c linux-2.4.26-rc1F1/net/ipv4/devinet.c<br>
--- linux-2.4.26-rc1/net/ipv4/devinet.c	2004-03-30 16:28:39.000000000 -0800<br>
+++ linux-2.4.26-rc1F1/net/ipv4/devinet.c	2004-03-31 19:35:38.000000000 -0800<br>
@@ -151,7 +151,8 @@<br>
 #ifdef CONFIG_SYSCTL<br>
 	devinet_sysctl_register(in_dev, &amp;in_dev-&gt;cnf);<br>
 #endif<br>
-	if (dev-&gt;flags&amp;IFF_UP)<br>
+	ip_mc_init_dev(in_dev);<br>
+	if (dev-&gt;flags &amp; IFF_UP)<br>
 		ip_mc_up(in_dev);<br>
 	return in_dev;<br>
 }<br>
diff -ruN linux-2.4.26-rc1/net/ipv4/igmp.c linux-2.4.26-rc1F1/net/ipv4/igmp.c</tt><br>
<tt>--- linux-2.4.26-rc1/net/ipv4/igmp.c	2004-03-30 16:28:39.000000000 -0800<br>
+++ linux-2.4.26-rc1F1/net/ipv4/igmp.c	2004-03-31 19:33:34.000000000 -0800<br>
@@ -1205,8 +1205,8 @@<br>
 <br>
 	ASSERT_RTNL();<br>
 <br>
-	if (!in_dev-&gt;mc_initted)<br>
-		return;<br>
+	for (i=in_dev-&gt;mc_list; i; i=i-&gt;next)<br>
+		igmp_group_dropped(i);<br>
 <br>
 #ifdef CONFIG_IP_MULTICAST<br>
 	in_dev-&gt;mr_ifc_count = 0;<br>
@@ -1215,24 +1215,14 @@<br>
 	in_dev-&gt;mr_gq_running = 0;<br>
 	if (del_timer(&amp;in_dev-&gt;mr_gq_timer))<br>
 		__in_dev_put(in_dev);<br>
-#endif<br>
-<br>
-	for (i=in_dev-&gt;mc_list; i; i=i-&gt;next)<br>
-		igmp_group_dropped(i);<br>
-<br>
-#ifdef CONFIG_IP_MULTICAST<br>
 	igmpv3_clear_delrec(in_dev);<br>
 #endif<br>
 <br>
 	ip_mc_dec_group(in_dev, IGMP_ALL_HOSTS);<br>
 }<br>
 <br>
-/* Device going up */<br>
-<br>
-void ip_mc_up(struct in_device *in_dev)<br>
+void ip_mc_init_dev(struct in_device *in_dev)<br>
 {<br>
-	struct ip_mc_list *i;<br>
-<br>
 	ASSERT_RTNL();<br>
 <br>
 	in_dev-&gt;mc_tomb = 0;<br>
@@ -1249,12 +1239,20 @@<br>
 #endif<br>
 <br>
 	in_dev-&gt;mc_lock = RW_LOCK_UNLOCKED;<br>
+}<br>
+<br>
+/* Device going up */<br>
+<br>
+void ip_mc_up(struct in_device *in_dev)<br>
+{<br>
+	struct ip_mc_list *i;<br>
+<br>
+	ASSERT_RTNL();</tt><br>
<tt>+<br>
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);<br>
 <br>
 	for (i=in_dev-&gt;mc_list; i; i=i-&gt;next)<br>
 		igmp_group_added(i);<br>
-<br>
-	in_dev-&gt;mc_initted = 1;<br>
 }<br>
 <br>
 /*</tt><br>
<i>(See attached file: 2.4.26-rc1-igmpinit.patch)</i><tt><br>
</tt></body></html>

--1__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676--


--0__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676
Content-type: application/octet-stream;
	name="2.4.26-rc1-igmpinit.patch"
Content-Disposition: attachment; filename="2.4.26-rc1-igmpinit.patch"
Content-ID: <10__=07BBE4FADFB246768f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNi1yYzEvaW5jbHVkZS9saW51eC9pbmV0ZGV2aWNlLmggbGlu
dXgtMi40LjI2LXJjMUYxL2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oCi0tLSBsaW51eC0yLjQu
MjYtcmMxL2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oCTIwMDQtMDMtMzAgMTY6Mjg6MzguMDAw
MDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjYtcmMxRjEvaW5jbHVkZS9saW51eC9pbmV0ZGV2
aWNlLmgJMjAwNC0wMy0zMSAxOTozMzozNC4wMDAwMDAwMDAgLTA4MDAKQEAgLTM0LDggKzM0LDYg
QEAKIAlyd2xvY2tfdAkJbG9jazsKIAlpbnQJCQlkZWFkOwogCXN0cnVjdCBpbl9pZmFkZHIJKmlm
YV9saXN0OwkvKiBJUCBpZmFkZHIgY2hhaW4JCSovCi0JaW50CQkJbWNfaW5pdHRlZDsKLQogCXN0
cnVjdCBpcF9tY19saXN0CSptY19saXN0OwkvKiBJUCBtdWx0aWNhc3QgZmlsdGVyIGNoYWluICAg
ICovCiAJcndsb2NrX3QJCW1jX2xvY2s7CS8qIGZvciBtY190b21iICovCiAJc3RydWN0IGlwX21j
X2xpc3QJKm1jX3RvbWI7CmRpZmYgLXJ1TiBsaW51eC0yLjQuMjYtcmMxL25ldC9pcHY0L2Rldmlu
ZXQuYyBsaW51eC0yLjQuMjYtcmMxRjEvbmV0L2lwdjQvZGV2aW5ldC5jCi0tLSBsaW51eC0yLjQu
MjYtcmMxL25ldC9pcHY0L2RldmluZXQuYwkyMDA0LTAzLTMwIDE2OjI4OjM5LjAwMDAwMDAwMCAt
MDgwMAorKysgbGludXgtMi40LjI2LXJjMUYxL25ldC9pcHY0L2RldmluZXQuYwkyMDA0LTAzLTMx
IDE5OjM1OjM4LjAwMDAwMDAwMCAtMDgwMApAQCAtMTUxLDcgKzE1MSw4IEBACiAjaWZkZWYgQ09O
RklHX1NZU0NUTAogCWRldmluZXRfc3lzY3RsX3JlZ2lzdGVyKGluX2RldiwgJmluX2Rldi0+Y25m
KTsKICNlbmRpZgotCWlmIChkZXYtPmZsYWdzJklGRl9VUCkKKwlpcF9tY19pbml0X2Rldihpbl9k
ZXYpOworCWlmIChkZXYtPmZsYWdzICYgSUZGX1VQKQogCQlpcF9tY191cChpbl9kZXYpOwogCXJl
dHVybiBpbl9kZXY7CiB9CmRpZmYgLXJ1TiBsaW51eC0yLjQuMjYtcmMxL25ldC9pcHY0L2lnbXAu
YyBsaW51eC0yLjQuMjYtcmMxRjEvbmV0L2lwdjQvaWdtcC5jCi0tLSBsaW51eC0yLjQuMjYtcmMx
L25ldC9pcHY0L2lnbXAuYwkyMDA0LTAzLTMwIDE2OjI4OjM5LjAwMDAwMDAwMCAtMDgwMAorKysg
bGludXgtMi40LjI2LXJjMUYxL25ldC9pcHY0L2lnbXAuYwkyMDA0LTAzLTMxIDE5OjMzOjM0LjAw
MDAwMDAwMCAtMDgwMApAQCAtMTIwNSw4ICsxMjA1LDggQEAKIAogCUFTU0VSVF9SVE5MKCk7CiAK
LQlpZiAoIWluX2Rldi0+bWNfaW5pdHRlZCkKLQkJcmV0dXJuOworCWZvciAoaT1pbl9kZXYtPm1j
X2xpc3Q7IGk7IGk9aS0+bmV4dCkKKwkJaWdtcF9ncm91cF9kcm9wcGVkKGkpOwogCiAjaWZkZWYg
Q09ORklHX0lQX01VTFRJQ0FTVAogCWluX2Rldi0+bXJfaWZjX2NvdW50ID0gMDsKQEAgLTEyMTUs
MjQgKzEyMTUsMTQgQEAKIAlpbl9kZXYtPm1yX2dxX3J1bm5pbmcgPSAwOwogCWlmIChkZWxfdGlt
ZXIoJmluX2Rldi0+bXJfZ3FfdGltZXIpKQogCQlfX2luX2Rldl9wdXQoaW5fZGV2KTsKLSNlbmRp
ZgotCi0JZm9yIChpPWluX2Rldi0+bWNfbGlzdDsgaTsgaT1pLT5uZXh0KQotCQlpZ21wX2dyb3Vw
X2Ryb3BwZWQoaSk7Ci0KLSNpZmRlZiBDT05GSUdfSVBfTVVMVElDQVNUCiAJaWdtcHYzX2NsZWFy
X2RlbHJlYyhpbl9kZXYpOwogI2VuZGlmCiAKIAlpcF9tY19kZWNfZ3JvdXAoaW5fZGV2LCBJR01Q
X0FMTF9IT1NUUyk7CiB9CiAKLS8qIERldmljZSBnb2luZyB1cCAqLwotCi12b2lkIGlwX21jX3Vw
KHN0cnVjdCBpbl9kZXZpY2UgKmluX2RldikKK3ZvaWQgaXBfbWNfaW5pdF9kZXYoc3RydWN0IGlu
X2RldmljZSAqaW5fZGV2KQogewotCXN0cnVjdCBpcF9tY19saXN0ICppOwotCiAJQVNTRVJUX1JU
TkwoKTsKIAogCWluX2Rldi0+bWNfdG9tYiA9IDA7CkBAIC0xMjQ5LDEyICsxMjM5LDIwIEBACiAj
ZW5kaWYKIAogCWluX2Rldi0+bWNfbG9jayA9IFJXX0xPQ0tfVU5MT0NLRUQ7Cit9CisKKy8qIERl
dmljZSBnb2luZyB1cCAqLworCit2b2lkIGlwX21jX3VwKHN0cnVjdCBpbl9kZXZpY2UgKmluX2Rl
dikKK3sKKwlzdHJ1Y3QgaXBfbWNfbGlzdCAqaTsKKworCUFTU0VSVF9SVE5MKCk7CisKIAlpcF9t
Y19pbmNfZ3JvdXAoaW5fZGV2LCBJR01QX0FMTF9IT1NUUyk7CiAKIAlmb3IgKGk9aW5fZGV2LT5t
Y19saXN0OyBpOyBpPWktPm5leHQpCiAJCWlnbXBfZ3JvdXBfYWRkZWQoaSk7Ci0KLQlpbl9kZXYt
Pm1jX2luaXR0ZWQgPSAxOwogfQogCiAvKgo=

--0__=07BBE4FADFB246768f9e8a93df938690918c07BBE4FADFB24676--
