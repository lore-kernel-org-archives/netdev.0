From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: MLD problems (again) [PATCH]
Date: Sun, 11 Jan 2004 22:49:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5F20AEAF.88A82C91-ON88256E19.001F1E69@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9"
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9
Content-type: multipart/alternative;
	Boundary="1__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9"

--1__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9
Content-type: text/plain; charset=US-ASCII





Takashi,
      I believe the patch below will fix the problem you
had with MCAST_JOIN_SOURCE_GROUP not sending a
report. There was a typo in the source filter switching that did
two deletes, rather than an delete and an add.

Dave,
      Although IGMPv3 didn't have any problems, this patch
also re-arranges the order of the filter changes. I think it's cleaner
to add the new one first and then delete the old one, rather than
having a small window with no filter set. So, this is a bug fix for MLD
and a code clean-up for IGMPv3.
      This bug and patch should also apply to the 2.4 line.

                        +-DLS

[included in-line for viewing and as an attachment for unmangled
      whitespace]

--- linux-2.6.1/net/ipv6/mcast.c    2004-01-08 22:59:56.000000000 -0800
+++ linux-2.6.1F1/net/ipv6/mcast.c  2004-01-11 21:06:05.000000000 -0800
@@ -372,9 +372,9 @@
                  goto done;
      } else if (pmc->sfmode != omode) {
            /* allow mode switches for empty-set filters */
+           ip6_mc_add_src(idev, group, omode, 0, 0, 0);
            ip6_mc_del_src(idev, group, pmc->sfmode, 0, 0, 0);
            pmc->sfmode = omode;
-           ip6_mc_del_src(idev, group, pmc->sfmode, 0, 0, 0);
      }

      psl = pmc->sflist;
--- linux-2.6.1/net/ipv4/igmp.c     2004-01-08 23:00:12.000000000 -0800
+++ linux-2.6.1F1/net/ipv4/igmp.c   2004-01-11 21:27:41.000000000 -0800
@@ -1749,11 +1749,10 @@
                  goto done;
      } else if (pmc->sfmode != omode) {
            /* allow mode switches for empty-set filters */
+           ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 0, 0, 0);
            ip_mc_del_src(in_dev, &mreqs->imr_multiaddr, pmc->sfmode, 0,
                  0, 0);
            pmc->sfmode = omode;
-           ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, pmc->sfmode, 0,
-                 0, 0);
      }

      psl = pmc->sflist;

(See attached file: 2.6.1MLD.patch)
--1__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
	I believe the patch below will fix the problem you <br>
had with MCAST_JOIN_SOURCE_GROUP not sending a<br>
report. There was a typo in the source filter switching that did<br>
two deletes, rather than an delete and an add.<br>
<br>
Dave,<br>
	Although IGMPv3 didn't have any problems, this patch<br>
also re-arranges the order of the filter changes. I think it's cleaner<br>
to add the new one first and then delete the old one, rather than<br>
having a small window with no filter set. So, this is a bug fix for MLD<br>
and a code clean-up for IGMPv3.<br>
	This bug and patch should also apply to the 2.4 line.<br>
<br>
				+-DLS<br>
<br>
[included in-line for viewing and as an attachment for unmangled<br>
	whitespace]<br>
<br>
--- linux-2.6.1/net/ipv6/mcast.c	2004-01-08 22:59:56.000000000 -0800<br>
+++ linux-2.6.1F1/net/ipv6/mcast.c	2004-01-11 21:06:05.000000000 -0800<br>
@@ -372,9 +372,9 @@<br>
 			goto done;<br>
 	} else if (pmc-&gt;sfmode != omode) {<br>
 		/* allow mode switches for empty-set filters */<br>
+		ip6_mc_add_src(idev, group, omode, 0, 0, 0);<br>
 		ip6_mc_del_src(idev, group, pmc-&gt;sfmode, 0, 0, 0);<br>
 		pmc-&gt;sfmode = omode;<br>
-		ip6_mc_del_src(idev, group, pmc-&gt;sfmode, 0, 0, 0);<br>
 	}<br>
 <br>
 	psl = pmc-&gt;sflist;<br>
--- linux-2.6.1/net/ipv4/igmp.c	2004-01-08 23:00:12.000000000 -0800<br>
+++ linux-2.6.1F1/net/ipv4/igmp.c	2004-01-11 21:27:41.000000000 -0800<br>
@@ -1749,11 +1749,10 @@<br>
 			goto done;<br>
 	} else if (pmc-&gt;sfmode != omode) {<br>
 		/* allow mode switches for empty-set filters */<br>
+		ip_mc_add_src(in_dev, &amp;mreqs-&gt;imr_multiaddr, omode, 0, 0, 0);<br>
 		ip_mc_del_src(in_dev, &amp;mreqs-&gt;imr_multiaddr, pmc-&gt;sfmode, 0, <br>
 			0, 0);<br>
 		pmc-&gt;sfmode = omode;<br>
-		ip_mc_add_src(in_dev, &amp;mreqs-&gt;imr_multiaddr, pmc-&gt;sfmode, 0, <br>
-			0, 0);<br>
 	}<br>
 <br>
 	psl = pmc-&gt;sflist;<br>
<br>
<i>(See attached file: 2.6.1MLD.patch)</i><br>
</body></html>

--1__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9--


--0__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9
Content-type: application/octet-stream;
	name="2.6.1MLD.patch"
Content-Disposition: attachment; filename="2.6.1MLD.patch"
Content-ID: <10__=07BBE48ADF8C98F98f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4xL25ldC9pcHY2L21jYXN0LmMJMjAwNC0wMS0wOCAyMjo1OTo1Ni4wMDAw
MDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4xRjEvbmV0L2lwdjYvbWNhc3QuYwkyMDA0LTAxLTEx
IDIxOjA2OjA1LjAwMDAwMDAwMCAtMDgwMApAQCAtMzcyLDkgKzM3Miw5IEBACiAJCQlnb3RvIGRv
bmU7CiAJfSBlbHNlIGlmIChwbWMtPnNmbW9kZSAhPSBvbW9kZSkgewogCQkvKiBhbGxvdyBtb2Rl
IHN3aXRjaGVzIGZvciBlbXB0eS1zZXQgZmlsdGVycyAqLworCQlpcDZfbWNfYWRkX3NyYyhpZGV2
LCBncm91cCwgb21vZGUsIDAsIDAsIDApOwogCQlpcDZfbWNfZGVsX3NyYyhpZGV2LCBncm91cCwg
cG1jLT5zZm1vZGUsIDAsIDAsIDApOwogCQlwbWMtPnNmbW9kZSA9IG9tb2RlOwotCQlpcDZfbWNf
ZGVsX3NyYyhpZGV2LCBncm91cCwgcG1jLT5zZm1vZGUsIDAsIDAsIDApOwogCX0KIAogCXBzbCA9
IHBtYy0+c2ZsaXN0OwotLS0gbGludXgtMi42LjEvbmV0L2lwdjQvaWdtcC5jCTIwMDQtMDEtMDgg
MjM6MDA6MTIuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMUYxL25ldC9pcHY0L2lnbXAu
YwkyMDA0LTAxLTExIDIxOjI3OjQxLjAwMDAwMDAwMCAtMDgwMApAQCAtMTc0OSwxMSArMTc0OSwx
MCBAQAogCQkJZ290byBkb25lOwogCX0gZWxzZSBpZiAocG1jLT5zZm1vZGUgIT0gb21vZGUpIHsK
IAkJLyogYWxsb3cgbW9kZSBzd2l0Y2hlcyBmb3IgZW1wdHktc2V0IGZpbHRlcnMgKi8KKwkJaXBf
bWNfYWRkX3NyYyhpbl9kZXYsICZtcmVxcy0+aW1yX211bHRpYWRkciwgb21vZGUsIDAsIDAsIDAp
OwogCQlpcF9tY19kZWxfc3JjKGluX2RldiwgJm1yZXFzLT5pbXJfbXVsdGlhZGRyLCBwbWMtPnNm
bW9kZSwgMCwgCiAJCQkwLCAwKTsKIAkJcG1jLT5zZm1vZGUgPSBvbW9kZTsKLQkJaXBfbWNfYWRk
X3NyYyhpbl9kZXYsICZtcmVxcy0+aW1yX211bHRpYWRkciwgcG1jLT5zZm1vZGUsIDAsIAotCQkJ
MCwgMCk7CiAJfQogCiAJcHNsID0gcG1jLT5zZmxpc3Q7Cg==

--0__=07BBE48ADF8C98F98f9e8a93df938690918c07BBE48ADF8C98F9--
