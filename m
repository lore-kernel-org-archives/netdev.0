From: David Stevens <dlstevens@us.ibm.com>
Subject: multicast loop with include filters fix [PATCH]
Date: Thu, 22 Jan 2004 19:02:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF56B39506.D81AEE48-ON88256E24.000A2D7B@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB"
Cc: stevenh@xsmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB
Content-type: multipart/alternative;
	Boundary="1__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB"

--1__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB
Content-type: text/plain; charset=US-ASCII





When sending a multicast and using looping back a copy to the
local machine, the interface filter checks can be done before the
source address is specified. For an INCLUDE filter, this won't match
the allowed sources and the packets won't be delivered locally,
even when the ultimate source address chosen is in the allowed list.

The patch below fixes the filter checks for both IGMPv3 and MLDv2
to only apply when a source address is available.

Thanks to Steven Hessing for reporting the problem and providing
a test case for reproducing it.

                              +-DLS

[not-whitespace-mangled patch attached]

diff -ruN linux-2.6.2-rc1/net/ipv4/igmp.c linux-2.6.2-rc1F1/net/ipv4/igmp.c
--- linux-2.6.2-rc1/net/ipv4/igmp.c 2004-01-21 14:03:35.000000000 -0800
+++ linux-2.6.2-rc1F1/net/ipv4/igmp.c     2004-01-22 17:11:38.000000000 -0800
@@ -2084,16 +2084,19 @@
      if (im && proto == IPPROTO_IGMP) {
            rv = 1;
      } else if (im) {
-           for (psf=im->sources; psf; psf=psf->sf_next) {
-                 if (psf->sf_inaddr == src_addr)
-                       break;
-           }
-           if (psf)
-                 rv = psf->sf_count[MCAST_INCLUDE] ||
-                       psf->sf_count[MCAST_EXCLUDE] !=
-                       im->sfcount[MCAST_EXCLUDE];
-           else
-                 rv = im->sfcount[MCAST_EXCLUDE] != 0;
+           if (src_addr) {
+                 for (psf=im->sources; psf; psf=psf->sf_next) {
+                       if (psf->sf_inaddr == src_addr)
+                             break;
+                 }
+                 if (psf)
+                       rv = psf->sf_count[MCAST_INCLUDE] ||
+                             psf->sf_count[MCAST_EXCLUDE] !=
+                             im->sfcount[MCAST_EXCLUDE];
+                 else
+                       rv = im->sfcount[MCAST_EXCLUDE] != 0;
+           } else
+                 rv = 1; /* unspecified source; tentatively allow */
      }
      read_unlock(&in_dev->lock);
      return rv;
diff -ruN linux-2.6.2-rc1/net/ipv6/mcast.c linux-2.6.2-rc1F1/net/ipv6/mcast.c
--- linux-2.6.2-rc1/net/ipv6/mcast.c      2004-01-21 14:03:35.000000000 -0800
+++ linux-2.6.2-rc1F1/net/ipv6/mcast.c    2004-01-22 17:29:29.000000000 -0800
@@ -918,20 +918,24 @@
                        break;
            }
            if (mc) {
-                 struct ip6_sf_list *psf;
+                 if (ipv6_addr_any(src_addr)) {
+                       struct ip6_sf_list *psf;

-                 spin_lock_bh(&mc->mca_lock);
-                 for (psf=mc->mca_sources; psf; psf=psf->sf_next) {
-                       if (ipv6_addr_cmp(&psf->sf_addr, src_addr) == 0)
-                             break;
-                 }
-                 if (psf)
-                       rv = psf->sf_count[MCAST_INCLUDE] ||
-                             psf->sf_count[MCAST_EXCLUDE] !=
-                             mc->mca_sfcount[MCAST_EXCLUDE];
-                 else
-                       rv = mc->mca_sfcount[MCAST_EXCLUDE] != 0;
-                 spin_unlock_bh(&mc->mca_lock);
+                       spin_lock_bh(&mc->mca_lock);
+                       for (psf=mc->mca_sources;psf;psf=psf->sf_next) {
+                             if (ipv6_addr_cmp(&psf->sf_addr,
+                                 src_addr) == 0)
+                                   break;
+                       }
+                       if (psf)
+                             rv = psf->sf_count[MCAST_INCLUDE] ||
+                                   psf->sf_count[MCAST_EXCLUDE] !=
+                                   mc->mca_sfcount[MCAST_EXCLUDE];
+                       else
+                             rv = mc->mca_sfcount[MCAST_EXCLUDE] !=0;
+                       spin_unlock_bh(&mc->mca_lock);
+                 } else
+                       rv = 1; /* don't filter unspecified source */
            }
            read_unlock_bh(&idev->lock);
            in6_dev_put(idev);

(See attached file: igmpf1.patch)
--1__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>When sending a multicast and using looping back a copy to the<br>
local machine, the interface filter checks can be done before the<br>
source address is specified. For an INCLUDE filter, this won't match<br>
the allowed sources and the packets won't be delivered locally,<br>
even when the ultimate source address chosen is in the allowed list.<br>
<br>
The patch below fixes the filter checks for both IGMPv3 and MLDv2<br>
to only apply when a source address is available.<br>
<br>
Thanks to Steven Hessing for reporting the problem and providing<br>
a test case for reproducing it.<br>
<br>
					+-DLS<br>
<br>
[not-whitespace-mangled patch attached]<br>
<br>
diff -ruN linux-2.6.2-rc1/net/ipv4/igmp.c linux-2.6.2-rc1F1/net/ipv4/igmp.c<br>
--- linux-2.6.2-rc1/net/ipv4/igmp.c	2004-01-21 14:03:35.000000000 -0800<br>
+++ linux-2.6.2-rc1F1/net/ipv4/igmp.c	2004-01-22 17:11:38.000000000 -0800<br>
@@ -2084,16 +2084,19 @@<br>
 	if (im &amp;&amp; proto == IPPROTO_IGMP) {<br>
 		rv = 1;<br>
 	} else if (im) {<br>
-		for (psf=im-&gt;sources; psf; psf=psf-&gt;sf_next) {<br>
-			if (psf-&gt;sf_inaddr == src_addr)<br>
-				break;<br>
-		}<br>
-		if (psf)<br>
-			rv = psf-&gt;sf_count[MCAST_INCLUDE] ||<br>
-				psf-&gt;sf_count[MCAST_EXCLUDE] !=<br>
-				im-&gt;sfcount[MCAST_EXCLUDE];<br>
-		else<br>
-			rv = im-&gt;sfcount[MCAST_EXCLUDE] != 0;<br>
+		if (src_addr) {<br>
+			for (psf=im-&gt;sources; psf; psf=psf-&gt;sf_next) {<br>
+				if (psf-&gt;sf_inaddr == src_addr)<br>
+					break;<br>
+			}<br>
+			if (psf)<br>
+				rv = psf-&gt;sf_count[MCAST_INCLUDE] ||<br>
+					psf-&gt;sf_count[MCAST_EXCLUDE] !=<br>
+					im-&gt;sfcount[MCAST_EXCLUDE];<br>
+			else<br>
+				rv = im-&gt;sfcount[MCAST_EXCLUDE] != 0;<br>
+		} else<br>
+			rv = 1; /* unspecified source; tentatively allow */<br>
 	}<br>
 	read_unlock(&amp;in_dev-&gt;lock);<br>
 	return rv;<br>
diff -ruN linux-2.6.2-rc1/net/ipv6/mcast.c linux-2.6.2-rc1F1/net/ipv6/mcast.c<br>
--- linux-2.6.2-rc1/net/ipv6/mcast.c	2004-01-21 14:03:35.000000000 -0800<br>
+++ linux-2.6.2-rc1F1/net/ipv6/mcast.c	2004-01-22 17:29:29.000000000 -0800<br>
@@ -918,20 +918,24 @@<br>
 				break;<br>
 		}<br>
 		if (mc) {<br>
-			struct ip6_sf_list *psf;<br>
+			if (ipv6_addr_any(src_addr)) {<br>
+				struct ip6_sf_list *psf;<br>
 <br>
-			spin_lock_bh(&amp;mc-&gt;mca_lock);<br>
-			for (psf=mc-&gt;mca_sources; psf; psf=psf-&gt;sf_next) {<br>
-				if (ipv6_addr_cmp(&amp;psf-&gt;sf_addr, src_addr) == 0)<br>
-					break;<br>
-			}<br>
-			if (psf)<br>
-				rv = psf-&gt;sf_count[MCAST_INCLUDE] ||<br>
-					psf-&gt;sf_count[MCAST_EXCLUDE] !=<br>
-					mc-&gt;mca_sfcount[MCAST_EXCLUDE];<br>
-			else<br>
-				rv = mc-&gt;mca_sfcount[MCAST_EXCLUDE] != 0;<br>
-			spin_unlock_bh(&amp;mc-&gt;mca_lock);<br>
+				spin_lock_bh(&amp;mc-&gt;mca_lock);<br>
+				for (psf=mc-&gt;mca_sources;psf;psf=psf-&gt;sf_next) {<br>
+					if (ipv6_addr_cmp(&amp;psf-&gt;sf_addr,<br>
+					    src_addr) == 0)<br>
+						break;<br>
+				}<br>
+				if (psf)<br>
+					rv = psf-&gt;sf_count[MCAST_INCLUDE] ||<br>
+						psf-&gt;sf_count[MCAST_EXCLUDE] !=<br>
+						mc-&gt;mca_sfcount[MCAST_EXCLUDE];<br>
+				else<br>
+					rv = mc-&gt;mca_sfcount[MCAST_EXCLUDE] !=0;<br>
+				spin_unlock_bh(&amp;mc-&gt;mca_lock);<br>
+			} else<br>
+				rv = 1; /* don't filter unspecified source */<br>
 		}<br>
 		read_unlock_bh(&amp;idev-&gt;lock);<br>
 		in6_dev_put(idev);<br>
<br>
<i>(See attached file: igmpf1.patch)</i><br>
</body></html>

--1__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB--


--0__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB
Content-type: application/octet-stream;
	name="igmpf1.patch"
Content-Disposition: attachment; filename="igmpf1.patch"
Content-ID: <10__=07BBE4B7DF99ABEB8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yLXJjMS9uZXQvaXB2NC9pZ21wLmMgbGludXgtMi42LjItcmMx
RjEvbmV0L2lwdjQvaWdtcC5jCi0tLSBsaW51eC0yLjYuMi1yYzEvbmV0L2lwdjQvaWdtcC5jCTIw
MDQtMDEtMjEgMTQ6MDM6MzUuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMi1yYzFGMS9u
ZXQvaXB2NC9pZ21wLmMJMjAwNC0wMS0yMiAxNzoxMTozOC4wMDAwMDAwMDAgLTA4MDAKQEAgLTIw
ODQsMTYgKzIwODQsMTkgQEAKIAlpZiAoaW0gJiYgcHJvdG8gPT0gSVBQUk9UT19JR01QKSB7CiAJ
CXJ2ID0gMTsKIAl9IGVsc2UgaWYgKGltKSB7Ci0JCWZvciAocHNmPWltLT5zb3VyY2VzOyBwc2Y7
IHBzZj1wc2YtPnNmX25leHQpIHsKLQkJCWlmIChwc2YtPnNmX2luYWRkciA9PSBzcmNfYWRkcikK
LQkJCQlicmVhazsKLQkJfQotCQlpZiAocHNmKQotCQkJcnYgPSBwc2YtPnNmX2NvdW50W01DQVNU
X0lOQ0xVREVdIHx8Ci0JCQkJcHNmLT5zZl9jb3VudFtNQ0FTVF9FWENMVURFXSAhPQotCQkJCWlt
LT5zZmNvdW50W01DQVNUX0VYQ0xVREVdOwotCQllbHNlCi0JCQlydiA9IGltLT5zZmNvdW50W01D
QVNUX0VYQ0xVREVdICE9IDA7CisJCWlmIChzcmNfYWRkcikgeworCQkJZm9yIChwc2Y9aW0tPnNv
dXJjZXM7IHBzZjsgcHNmPXBzZi0+c2ZfbmV4dCkgeworCQkJCWlmIChwc2YtPnNmX2luYWRkciA9
PSBzcmNfYWRkcikKKwkJCQkJYnJlYWs7CisJCQl9CisJCQlpZiAocHNmKQorCQkJCXJ2ID0gcHNm
LT5zZl9jb3VudFtNQ0FTVF9JTkNMVURFXSB8fAorCQkJCQlwc2YtPnNmX2NvdW50W01DQVNUX0VY
Q0xVREVdICE9CisJCQkJCWltLT5zZmNvdW50W01DQVNUX0VYQ0xVREVdOworCQkJZWxzZQorCQkJ
CXJ2ID0gaW0tPnNmY291bnRbTUNBU1RfRVhDTFVERV0gIT0gMDsKKwkJfSBlbHNlCisJCQlydiA9
IDE7IC8qIHVuc3BlY2lmaWVkIHNvdXJjZTsgdGVudGF0aXZlbHkgYWxsb3cgKi8KIAl9CiAJcmVh
ZF91bmxvY2soJmluX2Rldi0+bG9jayk7CiAJcmV0dXJuIHJ2OwpkaWZmIC1ydU4gbGludXgtMi42
LjItcmMxL25ldC9pcHY2L21jYXN0LmMgbGludXgtMi42LjItcmMxRjEvbmV0L2lwdjYvbWNhc3Qu
YwotLS0gbGludXgtMi42LjItcmMxL25ldC9pcHY2L21jYXN0LmMJMjAwNC0wMS0yMSAxNDowMzoz
NS4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4yLXJjMUYxL25ldC9pcHY2L21jYXN0LmMJ
MjAwNC0wMS0yMiAxNzoyOToyOS4wMDAwMDAwMDAgLTA4MDAKQEAgLTkxOCwyMCArOTE4LDI0IEBA
CiAJCQkJYnJlYWs7CiAJCX0KIAkJaWYgKG1jKSB7Ci0JCQlzdHJ1Y3QgaXA2X3NmX2xpc3QgKnBz
ZjsKKwkJCWlmIChpcHY2X2FkZHJfYW55KHNyY19hZGRyKSkgeworCQkJCXN0cnVjdCBpcDZfc2Zf
bGlzdCAqcHNmOwogCi0JCQlzcGluX2xvY2tfYmgoJm1jLT5tY2FfbG9jayk7Ci0JCQlmb3IgKHBz
Zj1tYy0+bWNhX3NvdXJjZXM7IHBzZjsgcHNmPXBzZi0+c2ZfbmV4dCkgewotCQkJCWlmIChpcHY2
X2FkZHJfY21wKCZwc2YtPnNmX2FkZHIsIHNyY19hZGRyKSA9PSAwKQotCQkJCQlicmVhazsKLQkJ
CX0KLQkJCWlmIChwc2YpCi0JCQkJcnYgPSBwc2YtPnNmX2NvdW50W01DQVNUX0lOQ0xVREVdIHx8
Ci0JCQkJCXBzZi0+c2ZfY291bnRbTUNBU1RfRVhDTFVERV0gIT0KLQkJCQkJbWMtPm1jYV9zZmNv
dW50W01DQVNUX0VYQ0xVREVdOwotCQkJZWxzZQotCQkJCXJ2ID0gbWMtPm1jYV9zZmNvdW50W01D
QVNUX0VYQ0xVREVdICE9IDA7Ci0JCQlzcGluX3VubG9ja19iaCgmbWMtPm1jYV9sb2NrKTsKKwkJ
CQlzcGluX2xvY2tfYmgoJm1jLT5tY2FfbG9jayk7CisJCQkJZm9yIChwc2Y9bWMtPm1jYV9zb3Vy
Y2VzO3BzZjtwc2Y9cHNmLT5zZl9uZXh0KSB7CisJCQkJCWlmIChpcHY2X2FkZHJfY21wKCZwc2Yt
PnNmX2FkZHIsCisJCQkJCSAgICBzcmNfYWRkcikgPT0gMCkKKwkJCQkJCWJyZWFrOworCQkJCX0K
KwkJCQlpZiAocHNmKQorCQkJCQlydiA9IHBzZi0+c2ZfY291bnRbTUNBU1RfSU5DTFVERV0gfHwK
KwkJCQkJCXBzZi0+c2ZfY291bnRbTUNBU1RfRVhDTFVERV0gIT0KKwkJCQkJCW1jLT5tY2Ffc2Zj
b3VudFtNQ0FTVF9FWENMVURFXTsKKwkJCQllbHNlCisJCQkJCXJ2ID0gbWMtPm1jYV9zZmNvdW50
W01DQVNUX0VYQ0xVREVdICE9MDsKKwkJCQlzcGluX3VubG9ja19iaCgmbWMtPm1jYV9sb2NrKTsK
KwkJCX0gZWxzZQorCQkJCXJ2ID0gMTsgLyogZG9uJ3QgZmlsdGVyIHVuc3BlY2lmaWVkIHNvdXJj
ZSAqLwogCQl9CiAJCXJlYWRfdW5sb2NrX2JoKCZpZGV2LT5sb2NrKTsKIAkJaW42X2Rldl9wdXQo
aWRldik7Cg==

--0__=07BBE4B7DF99ABEB8f9e8a93df938690918c07BBE4B7DF99ABEB--
