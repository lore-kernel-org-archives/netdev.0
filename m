From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] fix IGMPv3 timer initialization when device not "upped"
Date: Tue, 30 Mar 2004 17:13:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF6459178B.EB663927-ON88256E67.0083D5E5-88256E68.0000EE02@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375
Content-type: multipart/alternative;
	Boundary="1__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375"

--1__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375
Content-type: text/plain; charset=US-ASCII





The patch below creates a new "ip_mc_init_dev()" that has complementary
function to "ip_mc_destroy_dev()", and moves timer and lock initialization
to
it rather than trying to determine when a device is up, coming up, down or
going down based on idev->dead (not set before device up, but set on
device going down) or IFF_UP (not set on mc_down).

With this patch, multicast initialization is always done at device
initialization
and has nothing to do with up/down state. This should eliminate the timer
queue corruption and (I think) make the code easier to understand. This
patch also removes the "mc_initted" flag, which is no longer needed. Patch
is relative to 2.6.5-rc3 ; 2.4.x version to follow.

Thanks to Karlis Peisenieks, who original reported the problem and pointed
out flaws in the original fix.

                                    +-DLS

diff -ruN linux-2.6.5-rc3/include/linux/inetdevice.h linux-2.6.5-rc3F1/include/linux/inetdevice.h
--- linux-2.6.5-rc3/include/linux/inetdevice.h  2004-03-30 12:27:29.000000000 -0800
+++ linux-2.6.5-rc3F1/include/linux/inetdevice.h      2004-03-30 14:08:50.000000000 -0800
@@ -36,8 +36,6 @@
      rwlock_t          lock;
      int               dead;
      struct in_ifaddr  *ifa_list;  /* IP ifaddr chain            */
-     int               mc_initted;
-
      struct ip_mc_list *mc_list;   /* IP multicast filter chain    */
      rwlock_t          mc_lock;    /* for mc_tomb */
      struct ip_mc_list *mc_tomb;
diff -ruN linux-2.6.5-rc3/net/ipv4/devinet.c linux-2.6.5-rc3F1/net/ipv4/devinet.c
--- linux-2.6.5-rc3/net/ipv4/devinet.c    2004-03-10 18:55:23.000000000 -0800
+++ linux-2.6.5-rc3F1/net/ipv4/devinet.c  2004-03-30 14:09:46.000000000 -0800
@@ -165,6 +165,7 @@
 #ifdef CONFIG_SYSCTL
      devinet_sysctl_register(in_dev, &in_dev->cnf);
 #endif
+     ip_mc_init_dev(in_dev);
      if (dev->flags & IFF_UP)
            ip_mc_up(in_dev);
 out:
diff -ruN linux-2.6.5-rc3/net/ipv4/igmp.c linux-2.6.5-rc3F1/net/ipv4/igmp.c
--- linux-2.6.5-rc3/net/ipv4/igmp.c 2004-03-30 12:27:30.000000000 -0800
+++ linux-2.6.5-rc3F1/net/ipv4/igmp.c     2004-03-30 15:53:28.000000000 -0800
@@ -1217,8 +1217,8 @@

      ASSERT_RTNL();

-     if (!in_dev->mc_initted)
-           return;
+     for (i=in_dev->mc_list; i; i=i->next)
+           igmp_group_dropped(i);

 #ifdef CONFIG_IP_MULTICAST
      in_dev->mr_ifc_count = 0;
@@ -1227,24 +1227,14 @@
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
@@ -1261,12 +1251,20 @@
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

(See attached file: igmpinit.patch)
--1__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>The patch below creates a new &quot;ip_mc_init_dev()&quot; that has complementary<br>
function to &quot;ip_mc_destroy_dev()&quot;, and moves timer and lock initialization to<br>
it rather than trying to determine when a device is up, coming up, down or<br>
going down based on idev-&gt;dead (not set before device up, but set on<br>
device going down) or IFF_UP (not set on mc_down).<br>
<br>
With this patch, multicast initialization is always done at device initialization<br>
and has nothing to do with up/down state. This should eliminate the timer<br>
queue corruption and (I think) make the code easier to understand. This<br>
patch also removes the &quot;mc_initted&quot; flag, which is no longer needed. Patch<br>
is relative to 2.6.5-rc3 ; 2.4.x version to follow.<br>
<br>
Thanks to Karlis Peisenieks, who original reported the problem and pointed<br>
out flaws in the original fix.<br>
<br>
						+-DLS<br>
<br>
diff -ruN linux-2.6.5-rc3/include/linux/inetdevice.h linux-2.6.5-rc3F1/include/linux/inetdevice.h<br>
--- linux-2.6.5-rc3/include/linux/inetdevice.h	2004-03-30 12:27:29.000000000 -0800<br>
+++ linux-2.6.5-rc3F1/include/linux/inetdevice.h	2004-03-30 14:08:50.000000000 -0800<br>
@@ -36,8 +36,6 @@<br>
 	rwlock_t		lock;<br>
 	int			dead;<br>
 	struct in_ifaddr	*ifa_list;	/* IP ifaddr chain		*/<br>
-	int			mc_initted;<br>
-<br>
 	struct ip_mc_list	*mc_list;	/* IP multicast filter chain    */<br>
 	rwlock_t		mc_lock;	/* for mc_tomb */<br>
 	struct ip_mc_list	*mc_tomb;<br>
diff -ruN linux-2.6.5-rc3/net/ipv4/devinet.c linux-2.6.5-rc3F1/net/ipv4/devinet.c<br>
--- linux-2.6.5-rc3/net/ipv4/devinet.c	2004-03-10 18:55:23.000000000 -0800<br>
+++ linux-2.6.5-rc3F1/net/ipv4/devinet.c	2004-03-30 14:09:46.000000000 -0800<br>
@@ -165,6 +165,7 @@<br>
 #ifdef CONFIG_SYSCTL<br>
 	devinet_sysctl_register(in_dev, &amp;in_dev-&gt;cnf);<br>
 #endif<br>
+	ip_mc_init_dev(in_dev);<br>
 	if (dev-&gt;flags &amp; IFF_UP)<br>
 		ip_mc_up(in_dev);<br>
 out:<br>
diff -ruN linux-2.6.5-rc3/net/ipv4/igmp.c linux-2.6.5-rc3F1/net/ipv4/igmp.c<br>
--- linux-2.6.5-rc3/net/ipv4/igmp.c	2004-03-30 12:27:30.000000000 -0800<br>
+++ linux-2.6.5-rc3F1/net/ipv4/igmp.c	2004-03-30 15:53:28.000000000 -0800<br>
@@ -1217,8 +1217,8 @@<br>
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
@@ -1227,24 +1227,14 @@<br>
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
@@ -1261,12 +1251,20 @@<br>
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
+	ASSERT_RTNL();<br>
+<br>
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);<br>
 <br>
 	for (i=in_dev-&gt;mc_list; i; i=i-&gt;next)<br>
 		igmp_group_added(i);<br>
-<br>
-	in_dev-&gt;mc_initted = 1;<br>
 }<br>
 <br>
 /*<br>
<br>
<i>(See attached file: igmpinit.patch)</i></body></html>

--1__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375--


--0__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375
Content-type: application/octet-stream;
	name="igmpinit.patch"
Content-Disposition: attachment; filename="igmpinit.patch"
Content-ID: <10__=07BBE4F4DF1053758f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi41LXJjMy9pbmNsdWRlL2xpbnV4L2luZXRkZXZpY2UuaCBsaW51
eC0yLjYuNS1yYzNGMS9pbmNsdWRlL2xpbnV4L2luZXRkZXZpY2UuaAotLS0gbGludXgtMi42LjUt
cmMzL2luY2x1ZGUvbGludXgvaW5ldGRldmljZS5oCTIwMDQtMDMtMzAgMTI6Mjc6MjkuMDAwMDAw
MDAwIC0wODAwCisrKyBsaW51eC0yLjYuNS1yYzNGMS9pbmNsdWRlL2xpbnV4L2luZXRkZXZpY2Uu
aAkyMDA0LTAzLTMwIDE0OjA4OjUwLjAwMDAwMDAwMCAtMDgwMApAQCAtMzYsOCArMzYsNiBAQAog
CXJ3bG9ja190CQlsb2NrOwogCWludAkJCWRlYWQ7CiAJc3RydWN0IGluX2lmYWRkcgkqaWZhX2xp
c3Q7CS8qIElQIGlmYWRkciBjaGFpbgkJKi8KLQlpbnQJCQltY19pbml0dGVkOwotCiAJc3RydWN0
IGlwX21jX2xpc3QJKm1jX2xpc3Q7CS8qIElQIG11bHRpY2FzdCBmaWx0ZXIgY2hhaW4gICAgKi8K
IAlyd2xvY2tfdAkJbWNfbG9jazsJLyogZm9yIG1jX3RvbWIgKi8KIAlzdHJ1Y3QgaXBfbWNfbGlz
dAkqbWNfdG9tYjsKZGlmZiAtcnVOIGxpbnV4LTIuNi41LXJjMy9uZXQvaXB2NC9kZXZpbmV0LmMg
bGludXgtMi42LjUtcmMzRjEvbmV0L2lwdjQvZGV2aW5ldC5jCi0tLSBsaW51eC0yLjYuNS1yYzMv
bmV0L2lwdjQvZGV2aW5ldC5jCTIwMDQtMDMtMTAgMTg6NTU6MjMuMDAwMDAwMDAwIC0wODAwCisr
KyBsaW51eC0yLjYuNS1yYzNGMS9uZXQvaXB2NC9kZXZpbmV0LmMJMjAwNC0wMy0zMCAxNDowOTo0
Ni4wMDAwMDAwMDAgLTA4MDAKQEAgLTE2NSw2ICsxNjUsNyBAQAogI2lmZGVmIENPTkZJR19TWVND
VEwKIAlkZXZpbmV0X3N5c2N0bF9yZWdpc3Rlcihpbl9kZXYsICZpbl9kZXYtPmNuZik7CiAjZW5k
aWYKKwlpcF9tY19pbml0X2Rldihpbl9kZXYpOwogCWlmIChkZXYtPmZsYWdzICYgSUZGX1VQKQog
CQlpcF9tY191cChpbl9kZXYpOwogb3V0OgpkaWZmIC1ydU4gbGludXgtMi42LjUtcmMzL25ldC9p
cHY0L2lnbXAuYyBsaW51eC0yLjYuNS1yYzNGMS9uZXQvaXB2NC9pZ21wLmMKLS0tIGxpbnV4LTIu
Ni41LXJjMy9uZXQvaXB2NC9pZ21wLmMJMjAwNC0wMy0zMCAxMjoyNzozMC4wMDAwMDAwMDAgLTA4
MDAKKysrIGxpbnV4LTIuNi41LXJjM0YxL25ldC9pcHY0L2lnbXAuYwkyMDA0LTAzLTMwIDE1OjUz
OjI4LjAwMDAwMDAwMCAtMDgwMApAQCAtMTIxNyw4ICsxMjE3LDggQEAKIAogCUFTU0VSVF9SVE5M
KCk7CiAKLQlpZiAoIWluX2Rldi0+bWNfaW5pdHRlZCkKLQkJcmV0dXJuOworCWZvciAoaT1pbl9k
ZXYtPm1jX2xpc3Q7IGk7IGk9aS0+bmV4dCkKKwkJaWdtcF9ncm91cF9kcm9wcGVkKGkpOwogCiAj
aWZkZWYgQ09ORklHX0lQX01VTFRJQ0FTVAogCWluX2Rldi0+bXJfaWZjX2NvdW50ID0gMDsKQEAg
LTEyMjcsMjQgKzEyMjcsMTQgQEAKIAlpbl9kZXYtPm1yX2dxX3J1bm5pbmcgPSAwOwogCWlmIChk
ZWxfdGltZXIoJmluX2Rldi0+bXJfZ3FfdGltZXIpKQogCQlfX2luX2Rldl9wdXQoaW5fZGV2KTsK
LSNlbmRpZgotCi0JZm9yIChpPWluX2Rldi0+bWNfbGlzdDsgaTsgaT1pLT5uZXh0KQotCQlpZ21w
X2dyb3VwX2Ryb3BwZWQoaSk7Ci0KLSNpZmRlZiBDT05GSUdfSVBfTVVMVElDQVNUCiAJaWdtcHYz
X2NsZWFyX2RlbHJlYyhpbl9kZXYpOwogI2VuZGlmCiAKIAlpcF9tY19kZWNfZ3JvdXAoaW5fZGV2
LCBJR01QX0FMTF9IT1NUUyk7CiB9CiAKLS8qIERldmljZSBnb2luZyB1cCAqLwotCi12b2lkIGlw
X21jX3VwKHN0cnVjdCBpbl9kZXZpY2UgKmluX2RldikKK3ZvaWQgaXBfbWNfaW5pdF9kZXYoc3Ry
dWN0IGluX2RldmljZSAqaW5fZGV2KQogewotCXN0cnVjdCBpcF9tY19saXN0ICppOwotCiAJQVNT
RVJUX1JUTkwoKTsKIAogCWluX2Rldi0+bWNfdG9tYiA9IDA7CkBAIC0xMjYxLDEyICsxMjUxLDIw
IEBACiAjZW5kaWYKIAogCWluX2Rldi0+bWNfbG9jayA9IFJXX0xPQ0tfVU5MT0NLRUQ7Cit9CisK
Ky8qIERldmljZSBnb2luZyB1cCAqLworCit2b2lkIGlwX21jX3VwKHN0cnVjdCBpbl9kZXZpY2Ug
KmluX2RldikKK3sKKwlzdHJ1Y3QgaXBfbWNfbGlzdCAqaTsKKworCUFTU0VSVF9SVE5MKCk7CisK
IAlpcF9tY19pbmNfZ3JvdXAoaW5fZGV2LCBJR01QX0FMTF9IT1NUUyk7CiAKIAlmb3IgKGk9aW5f
ZGV2LT5tY19saXN0OyBpOyBpPWktPm5leHQpCiAJCWlnbXBfZ3JvdXBfYWRkZWQoaSk7Ci0KLQlp
bl9kZXYtPm1jX2luaXR0ZWQgPSAxOwogfQogCiAvKgo=

--0__=07BBE4F4DF1053758f9e8a93df938690918c07BBE4F4DF105375--
