From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Deadlock problem with dev->refcnt somewhere in netlink/multicast... [PATCH]
Date: Mon, 2 Feb 2004 16:41:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F"
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, Alexandre.Cassen@wanadoo.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F
Content-type: multipart/alternative;
	Boundary="1__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F"

--1__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F
Content-type: text/plain; charset=US-ASCII





Below is a patch for the reference count problem you ran into.

The problem is that the IGMP code was using "IFF_UP" to determine
if a report should be sent or a timer should be started. But it is not
necessarily cleared during a destroy_dev.

The IPv4 code was also missing an ip_mc_down() call added in the
IPv6 code for a similar case by Jan Oravec.

The patch is for 2.4.x but also applies to 2.6.x. In-line for
whitespace-mangled
viewing and attached for applying.

Thanks for reporting the problem, Willy, and let me know if you have any
problems with the patch.
                              +-DLS

diff -ruN linux-2.4.25-pre8/net/ipv4/igmp.c linux-2.4.25-pre8F2/net/ipv4/igmp.c
--- linux-2.4.25-pre8/net/ipv4/igmp.c     2004-01-29 16:21:28.000000000 -0800
+++ linux-2.4.25-pre8F2/net/ipv4/igmp.c   2004-02-02 14:43:40.000000000 -0800
@@ -1051,7 +1051,7 @@
      reporter = im->reporter;
      igmp_stop_timer(im);

-     if (in_dev->dev->flags & IFF_UP) {
+     if (!in_dev->dead) {
            if (IGMP_V1_SEEN(in_dev))
                  goto done;
            if (IGMP_V2_SEEN(in_dev)) {
@@ -1082,6 +1082,8 @@
      if (im->multiaddr == IGMP_ALL_HOSTS)
            return;

+     if (in_dev->dead)
+           return;
      if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
            spin_lock_bh(&im->lock);
            igmp_start_timer(im, IGMP_Initial_Report_Delay);
@@ -1155,7 +1157,7 @@
      igmpv3_del_delrec(in_dev, im->multiaddr);
 #endif
      igmp_group_added(im);
-     if (in_dev->dev->flags & IFF_UP)
+     if (!in_dev->dead)
            ip_rt_multicast_event(in_dev);
 out:
      return;
@@ -1179,7 +1181,7 @@
                        write_unlock_bh(&in_dev->lock);
                        igmp_group_dropped(i);

-                       if (in_dev->dev->flags & IFF_UP)
+                       if (!in_dev->dead)
                              ip_rt_multicast_event(in_dev);

                        ip_ma_put(i);
@@ -1255,6 +1257,9 @@

      ASSERT_RTNL();

+     /* Deactivate timers */
+     ip_mc_down(in_dev);
+
      write_lock_bh(&in_dev->lock);
      while ((i = in_dev->mc_list) != NULL) {
            in_dev->mc_list = i->next;

(See attached file: 2.4igmpref.patch)
--1__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Below is a patch for the reference count problem you ran into.<br>
<br>
The problem is that the IGMP code was using &quot;IFF_UP&quot; to determine<br>
if a report should be sent or a timer should be started. But it is not<br>
necessarily cleared during a destroy_dev.<br>
<br>
The IPv4 code was also missing an ip_mc_down() call added in the<br>
IPv6 code for a similar case by Jan Oravec.<br>
<br>
The patch is for 2.4.x but also applies to 2.6.x. In-line for whitespace-mangled<br>
viewing and attached for applying.<br>
<br>
Thanks for reporting the problem, Willy, and let me know if you have any<br>
problems with the patch.<br>
					+-DLS<br>
<br>
diff -ruN linux-2.4.25-pre8/net/ipv4/igmp.c linux-2.4.25-pre8F2/net/ipv4/igmp.c<br>
--- linux-2.4.25-pre8/net/ipv4/igmp.c	2004-01-29 16:21:28.000000000 -0800<br>
+++ linux-2.4.25-pre8F2/net/ipv4/igmp.c	2004-02-02 14:43:40.000000000 -0800<br>
@@ -1051,7 +1051,7 @@<br>
 	reporter = im-&gt;reporter;<br>
 	igmp_stop_timer(im);<br>
 <br>
-	if (in_dev-&gt;dev-&gt;flags &amp; IFF_UP) {<br>
+	if (!in_dev-&gt;dead) {<br>
 		if (IGMP_V1_SEEN(in_dev))<br>
 			goto done;<br>
 		if (IGMP_V2_SEEN(in_dev)) {<br>
@@ -1082,6 +1082,8 @@<br>
 	if (im-&gt;multiaddr == IGMP_ALL_HOSTS)<br>
 		return;<br>
 <br>
+	if (in_dev-&gt;dead)<br>
+		return;<br>
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {<br>
 		spin_lock_bh(&amp;im-&gt;lock);<br>
 		igmp_start_timer(im, IGMP_Initial_Report_Delay);<br>
@@ -1155,7 +1157,7 @@<br>
 	igmpv3_del_delrec(in_dev, im-&gt;multiaddr);<br>
 #endif<br>
 	igmp_group_added(im);<br>
-	if (in_dev-&gt;dev-&gt;flags &amp; IFF_UP)<br>
+	if (!in_dev-&gt;dead)<br>
 		ip_rt_multicast_event(in_dev);<br>
 out:<br>
 	return;<br>
@@ -1179,7 +1181,7 @@<br>
 				write_unlock_bh(&amp;in_dev-&gt;lock);<br>
 				igmp_group_dropped(i);<br>
 <br>
-				if (in_dev-&gt;dev-&gt;flags &amp; IFF_UP)<br>
+				if (!in_dev-&gt;dead)<br>
 					ip_rt_multicast_event(in_dev);<br>
 <br>
 				ip_ma_put(i);<br>
@@ -1255,6 +1257,9 @@<br>
 <br>
 	ASSERT_RTNL();<br>
 <br>
+	/* Deactivate timers */<br>
+	ip_mc_down(in_dev);<br>
+<br>
 	write_lock_bh(&amp;in_dev-&gt;lock);<br>
 	while ((i = in_dev-&gt;mc_list) != NULL) {<br>
 		in_dev-&gt;mc_list = i-&gt;next;<br>
<br>
<i>(See attached file: 2.4igmpref.patch)</i><br>
</body></html>

--1__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F--


--0__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F
Content-type: application/octet-stream;
	name="2.4igmpref.patch"
Content-Disposition: attachment; filename="2.4igmpref.patch"
Content-ID: <10__=07BBE4BDDF13732F8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNS1wcmU4L25ldC9pcHY0L2lnbXAuYyBsaW51eC0yLjQuMjUt
cHJlOEYyL25ldC9pcHY0L2lnbXAuYwotLS0gbGludXgtMi40LjI1LXByZTgvbmV0L2lwdjQvaWdt
cC5jCTIwMDQtMDEtMjkgMTY6MjE6MjguMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjUt
cHJlOEYyL25ldC9pcHY0L2lnbXAuYwkyMDA0LTAyLTAyIDE0OjQzOjQwLjAwMDAwMDAwMCAtMDgw
MApAQCAtMTA1MSw3ICsxMDUxLDcgQEAKIAlyZXBvcnRlciA9IGltLT5yZXBvcnRlcjsKIAlpZ21w
X3N0b3BfdGltZXIoaW0pOwogCi0JaWYgKGluX2Rldi0+ZGV2LT5mbGFncyAmIElGRl9VUCkgewor
CWlmICghaW5fZGV2LT5kZWFkKSB7CiAJCWlmIChJR01QX1YxX1NFRU4oaW5fZGV2KSkKIAkJCWdv
dG8gZG9uZTsKIAkJaWYgKElHTVBfVjJfU0VFTihpbl9kZXYpKSB7CkBAIC0xMDgyLDYgKzEwODIs
OCBAQAogCWlmIChpbS0+bXVsdGlhZGRyID09IElHTVBfQUxMX0hPU1RTKQogCQlyZXR1cm47CiAK
KwlpZiAoaW5fZGV2LT5kZWFkKQorCQlyZXR1cm47CiAJaWYgKElHTVBfVjFfU0VFTihpbl9kZXYp
IHx8IElHTVBfVjJfU0VFTihpbl9kZXYpKSB7CiAJCXNwaW5fbG9ja19iaCgmaW0tPmxvY2spOwog
CQlpZ21wX3N0YXJ0X3RpbWVyKGltLCBJR01QX0luaXRpYWxfUmVwb3J0X0RlbGF5KTsKQEAgLTEx
NTUsNyArMTE1Nyw3IEBACiAJaWdtcHYzX2RlbF9kZWxyZWMoaW5fZGV2LCBpbS0+bXVsdGlhZGRy
KTsKICNlbmRpZgogCWlnbXBfZ3JvdXBfYWRkZWQoaW0pOwotCWlmIChpbl9kZXYtPmRldi0+Zmxh
Z3MgJiBJRkZfVVApCisJaWYgKCFpbl9kZXYtPmRlYWQpCiAJCWlwX3J0X211bHRpY2FzdF9ldmVu
dChpbl9kZXYpOwogb3V0OgogCXJldHVybjsKQEAgLTExNzksNyArMTE4MSw3IEBACiAJCQkJd3Jp
dGVfdW5sb2NrX2JoKCZpbl9kZXYtPmxvY2spOwogCQkJCWlnbXBfZ3JvdXBfZHJvcHBlZChpKTsK
IAotCQkJCWlmIChpbl9kZXYtPmRldi0+ZmxhZ3MgJiBJRkZfVVApCisJCQkJaWYgKCFpbl9kZXYt
PmRlYWQpCiAJCQkJCWlwX3J0X211bHRpY2FzdF9ldmVudChpbl9kZXYpOwogCiAJCQkJaXBfbWFf
cHV0KGkpOwpAQCAtMTI1NSw2ICsxMjU3LDkgQEAKIAogCUFTU0VSVF9SVE5MKCk7CiAKKwkvKiBE
ZWFjdGl2YXRlIHRpbWVycyAqLworCWlwX21jX2Rvd24oaW5fZGV2KTsKKwogCXdyaXRlX2xvY2tf
YmgoJmluX2Rldi0+bG9jayk7CiAJd2hpbGUgKChpID0gaW5fZGV2LT5tY19saXN0KSAhPSBOVUxM
KSB7CiAJCWluX2Rldi0+bWNfbGlzdCA9IGktPm5leHQ7Cg==

--0__=07BBE4BDDF13732F8f9e8a93df938690918c07BBE4BDDF13732F--
