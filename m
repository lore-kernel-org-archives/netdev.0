From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: ip multicast bug
Date: Tue, 17 Feb 2004 14:50:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC1AEC752.205B8A87-ON88256E3D.007744DC-88256E3D.0077B405@us.ibm.com>
References: <20040217155516.GA20477@mt.lv>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C"
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040217155516.GA20477@mt.lv>
To: Karlis Peisenieks <karlis@mt.lv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C
Content-type: multipart/alternative;
	Boundary="1__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C"

--1__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C
Content-type: text/plain; charset=US-ASCII





Karlis,
      I was able to reproduce your problem, finally. Your patch does have
a couple problems, though. First, the igmpv3_del_delrec() call should be
there
whether or not the interface is IFF_UP (to prevent a memory leak) and
second,
portions of igmp_group_added should still be run when the interface is
down,
so that the group will properly be joined when the interface is brought up.
      I think the patch below fixes the problem. Thanks for reporting it!

                              +-DLS

--- linux-2.6.3-rc4/net/ipv4/igmp.c 2004-02-17 12:19:51.000000000 -0800
+++ linux-2.6.3-rc4F1/net/ipv4/igmp.c     2004-02-17 13:25:39.334792760 -0800
@@ -1067,7 +1067,7 @@
      reporter = im->reporter;
      igmp_stop_timer(im);

-     if (!in_dev->dead) {
+     if (!in_dev->dead && (in_dev->dev->flags & IFF_UP)) {
            if (IGMP_V1_SEEN(in_dev))
                  goto done;
            if (IGMP_V2_SEEN(in_dev)) {
@@ -1098,7 +1098,7 @@
      if (im->multiaddr == IGMP_ALL_HOSTS)
            return;

-     if (in_dev->dead)
+     if (in_dev->dead || !(in_dev->dev->flags & IFF_UP))
            return;
      if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
            spin_lock_bh(&im->lock);
(See attached file: igmpf1.patch)
--1__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Karlis,<br>
	I was able to reproduce your problem, finally. Your patch does have<br>
a couple problems, though. First, the igmpv3_del_delrec() call should be there<br>
whether or not the interface is IFF_UP (to prevent a memory leak) and second,<br>
portions of igmp_group_added should still be run when the interface is down,<br>
so that the group will properly be joined when the interface is brought up.<br>
	I think the patch below fixes the problem. Thanks for reporting it!<br>
<br>
					+-DLS<br>
<br>
<tt>--- linux-2.6.3-rc4/net/ipv4/igmp.c	2004-02-17 12:19:51.000000000 -0800<br>
+++ linux-2.6.3-rc4F1/net/ipv4/igmp.c	2004-02-17 13:25:39.334792760 -0800<br>
@@ -1067,7 +1067,7 @@<br>
 	reporter = im-&gt;reporter;<br>
 	igmp_stop_timer(im);<br>
 <br>
-	if (!in_dev-&gt;dead) {<br>
+	if (!in_dev-&gt;dead &amp;&amp; (in_dev-&gt;dev-&gt;flags &amp; IFF_UP)) {<br>
 		if (IGMP_V1_SEEN(in_dev))<br>
 			goto done;<br>
 		if (IGMP_V2_SEEN(in_dev)) {<br>
@@ -1098,7 +1098,7 @@<br>
 	if (im-&gt;multiaddr == IGMP_ALL_HOSTS)<br>
 		return;<br>
 <br>
-	if (in_dev-&gt;dead)<br>
+	if (in_dev-&gt;dead || !(in_dev-&gt;dev-&gt;flags &amp; IFF_UP))<br>
 		return;<br>
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {<br>
 		spin_lock_bh(&amp;im-&gt;lock);</tt><br>
<i>(See attached file: igmpf1.patch)</i></body></html>

--1__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C--


--0__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C
Content-type: application/octet-stream;
	name="igmpf1.patch"
Content-Disposition: attachment; filename="igmpf1.patch"
Content-ID: <10__=07BBE4AEDFE4C24C8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4zLXJjNC9uZXQvaXB2NC9pZ21wLmMJMjAwNC0wMi0xNyAxMjoxOTo1MS4w
MDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4zLXJjNEYxL25ldC9pcHY0L2lnbXAuYwkyMDA0
LTAyLTE3IDEzOjI1OjM5LjMzNDc5Mjc2MCAtMDgwMApAQCAtMTA2Nyw3ICsxMDY3LDcgQEAKIAly
ZXBvcnRlciA9IGltLT5yZXBvcnRlcjsKIAlpZ21wX3N0b3BfdGltZXIoaW0pOwogCi0JaWYgKCFp
bl9kZXYtPmRlYWQpIHsKKwlpZiAoIWluX2Rldi0+ZGVhZCAmJiAoaW5fZGV2LT5kZXYtPmZsYWdz
ICYgSUZGX1VQKSkgewogCQlpZiAoSUdNUF9WMV9TRUVOKGluX2RldikpCiAJCQlnb3RvIGRvbmU7
CiAJCWlmIChJR01QX1YyX1NFRU4oaW5fZGV2KSkgewpAQCAtMTA5OCw3ICsxMDk4LDcgQEAKIAlp
ZiAoaW0tPm11bHRpYWRkciA9PSBJR01QX0FMTF9IT1NUUykKIAkJcmV0dXJuOwogCi0JaWYgKGlu
X2Rldi0+ZGVhZCkKKwlpZiAoaW5fZGV2LT5kZWFkIHx8ICEoaW5fZGV2LT5kZXYtPmZsYWdzICYg
SUZGX1VQKSkKIAkJcmV0dXJuOwogCWlmIChJR01QX1YxX1NFRU4oaW5fZGV2KSB8fCBJR01QX1Yy
X1NFRU4oaW5fZGV2KSkgewogCQlzcGluX2xvY2tfYmgoJmltLT5sb2NrKTsK

--0__=07BBE4AEDFE4C24C8f9e8a93df938690918c07BBE4AEDFE4C24C--
