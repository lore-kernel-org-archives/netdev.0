From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast loop with include filters fix [PATCH]
Date: Fri, 23 Jan 2004 15:39:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF62EF6DA6.732A9C7E-ON88256E24.007C1F78@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8"
Cc: netdev@oss.sgi.com, stevenh@xsmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8
Content-type: multipart/alternative;
	Boundary="1__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8"

--1__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8
Content-type: text/plain; charset=US-ASCII





Dave,
      Here's the 2.4.x version of the patch.

                        +-DLS

diff -ruN linux-2.4.25-pre7/net/ipv4/igmp.c linux-2.4.25-pre7F1/net/ipv4/igmp.c
--- linux-2.4.25-pre7/net/ipv4/igmp.c     2004-01-23 13:54:35.000000000 -0800
+++ linux-2.4.25-pre7F1/net/ipv4/igmp.c   2004-01-23 13:58:43.000000000 -0800
@@ -2071,16 +2071,19 @@
       * Differs from 2.5.x here.   +-DLS 4/23/03
       */
      if (im) {
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
+                 rv = 1;
      }
      read_unlock(&in_dev->lock);
      return rv;
diff -ruN linux-2.4.25-pre7/net/ipv6/mcast.c linux-2.4.25-pre7F1/net/ipv6/mcast.c
--- linux-2.4.25-pre7/net/ipv6/mcast.c    2004-01-23 13:54:35.000000000 -0800
+++ linux-2.4.25-pre7F1/net/ipv6/mcast.c  2004-01-23 13:56:19.000000000 -0800
@@ -914,20 +914,24 @@
                        break;
            }
            if (mc) {
-                 struct ip6_sf_list *psf;
+                 if (!ipv6_addr_any(src_addr)) {
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

(See attached file: 2.4.25-pre7IGMP.patch)
--1__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Dave,<br>
	Here's the 2.4.x version of the patch.<br>
<br>
				+-DLS<br>
<br>
diff -ruN linux-2.4.25-pre7/net/ipv4/igmp.c linux-2.4.25-pre7F1/net/ipv4/igmp.c<br>
--- linux-2.4.25-pre7/net/ipv4/igmp.c	2004-01-23 13:54:35.000000000 -0800<br>
+++ linux-2.4.25-pre7F1/net/ipv4/igmp.c	2004-01-23 13:58:43.000000000 -0800<br>
@@ -2071,16 +2071,19 @@<br>
 	 * Differs from 2.5.x here.	+-DLS 4/23/03<br>
 	 */<br>
 	if (im) {<br>
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
+			rv = 1;<br>
 	}<br>
 	read_unlock(&amp;in_dev-&gt;lock);<br>
 	return rv;<br>
diff -ruN linux-2.4.25-pre7/net/ipv6/mcast.c linux-2.4.25-pre7F1/net/ipv6/mcast.c<br>
--- linux-2.4.25-pre7/net/ipv6/mcast.c	2004-01-23 13:54:35.000000000 -0800<br>
+++ linux-2.4.25-pre7F1/net/ipv6/mcast.c	2004-01-23 13:56:19.000000000 -0800<br>
@@ -914,20 +914,24 @@<br>
 				break;<br>
 		}<br>
 		if (mc) {<br>
-			struct ip6_sf_list *psf;<br>
+			if (!ipv6_addr_any(src_addr)) {<br>
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
<i>(See attached file: 2.4.25-pre7IGMP.patch)</i><br>
</body></html>

--1__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8--


--0__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8
Content-type: application/octet-stream;
	name="2.4.25-pre7IGMP.patch"
Content-Disposition: attachment; filename="2.4.25-pre7IGMP.patch"
Content-ID: <10__=07BBE4B7DFEF99E88f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNS1wcmU3L25ldC9pcHY0L2lnbXAuYyBsaW51eC0yLjQuMjUt
cHJlN0YxL25ldC9pcHY0L2lnbXAuYwotLS0gbGludXgtMi40LjI1LXByZTcvbmV0L2lwdjQvaWdt
cC5jCTIwMDQtMDEtMjMgMTM6NTQ6MzUuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjUt
cHJlN0YxL25ldC9pcHY0L2lnbXAuYwkyMDA0LTAxLTIzIDEzOjU4OjQzLjAwMDAwMDAwMCAtMDgw
MApAQCAtMjA3MSwxNiArMjA3MSwxOSBAQAogCSAqIERpZmZlcnMgZnJvbSAyLjUueCBoZXJlLgkr
LURMUyA0LzIzLzAzCiAJICovCiAJaWYgKGltKSB7Ci0JCWZvciAocHNmPWltLT5zb3VyY2VzOyBw
c2Y7IHBzZj1wc2YtPnNmX25leHQpIHsKLQkJCWlmIChwc2YtPnNmX2luYWRkciA9PSBzcmNfYWRk
cikKLQkJCQlicmVhazsKLQkJfQotCQlpZiAocHNmKQotCQkJcnYgPSBwc2YtPnNmX2NvdW50W01D
QVNUX0lOQ0xVREVdIHx8Ci0JCQkJcHNmLT5zZl9jb3VudFtNQ0FTVF9FWENMVURFXSAhPQotCQkJ
CWltLT5zZmNvdW50W01DQVNUX0VYQ0xVREVdOwotCQllbHNlCi0JCQlydiA9IGltLT5zZmNvdW50
W01DQVNUX0VYQ0xVREVdICE9IDA7CisJCWlmIChzcmNfYWRkcikgeworCQkJZm9yIChwc2Y9aW0t
PnNvdXJjZXM7IHBzZjsgcHNmPXBzZi0+c2ZfbmV4dCkgeworCQkJCWlmIChwc2YtPnNmX2luYWRk
ciA9PSBzcmNfYWRkcikKKwkJCQkJYnJlYWs7CisJCQl9CisJCQlpZiAocHNmKQorCQkJCXJ2ID0g
cHNmLT5zZl9jb3VudFtNQ0FTVF9JTkNMVURFXSB8fAorCQkJCQlwc2YtPnNmX2NvdW50W01DQVNU
X0VYQ0xVREVdICE9CisJCQkJCWltLT5zZmNvdW50W01DQVNUX0VYQ0xVREVdOworCQkJZWxzZQor
CQkJCXJ2ID0gaW0tPnNmY291bnRbTUNBU1RfRVhDTFVERV0gIT0gMDsKKwkJfSBlbHNlCisJCQly
diA9IDE7CiAJfQogCXJlYWRfdW5sb2NrKCZpbl9kZXYtPmxvY2spOwogCXJldHVybiBydjsKZGlm
ZiAtcnVOIGxpbnV4LTIuNC4yNS1wcmU3L25ldC9pcHY2L21jYXN0LmMgbGludXgtMi40LjI1LXBy
ZTdGMS9uZXQvaXB2Ni9tY2FzdC5jCi0tLSBsaW51eC0yLjQuMjUtcHJlNy9uZXQvaXB2Ni9tY2Fz
dC5jCTIwMDQtMDEtMjMgMTM6NTQ6MzUuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjUt
cHJlN0YxL25ldC9pcHY2L21jYXN0LmMJMjAwNC0wMS0yMyAxMzo1NjoxOS4wMDAwMDAwMDAgLTA4
MDAKQEAgLTkxNCwyMCArOTE0LDI0IEBACiAJCQkJYnJlYWs7CiAJCX0KIAkJaWYgKG1jKSB7Ci0J
CQlzdHJ1Y3QgaXA2X3NmX2xpc3QgKnBzZjsKKwkJCWlmICghaXB2Nl9hZGRyX2FueShzcmNfYWRk
cikpIHsKKwkJCQlzdHJ1Y3QgaXA2X3NmX2xpc3QgKnBzZjsKIAotCQkJc3Bpbl9sb2NrX2JoKCZt
Yy0+bWNhX2xvY2spOwotCQkJZm9yIChwc2Y9bWMtPm1jYV9zb3VyY2VzOyBwc2Y7IHBzZj1wc2Yt
PnNmX25leHQpIHsKLQkJCQlpZiAoaXB2Nl9hZGRyX2NtcCgmcHNmLT5zZl9hZGRyLCBzcmNfYWRk
cikgPT0gMCkKLQkJCQkJYnJlYWs7Ci0JCQl9Ci0JCQlpZiAocHNmKQotCQkJCXJ2ID0gcHNmLT5z
Zl9jb3VudFtNQ0FTVF9JTkNMVURFXSB8fAotCQkJCQlwc2YtPnNmX2NvdW50W01DQVNUX0VYQ0xV
REVdICE9Ci0JCQkJCW1jLT5tY2Ffc2Zjb3VudFtNQ0FTVF9FWENMVURFXTsKLQkJCWVsc2UKLQkJ
CQlydiA9IG1jLT5tY2Ffc2Zjb3VudFtNQ0FTVF9FWENMVURFXSAhPSAwOwotCQkJc3Bpbl91bmxv
Y2tfYmgoJm1jLT5tY2FfbG9jayk7CisJCQkJc3Bpbl9sb2NrX2JoKCZtYy0+bWNhX2xvY2spOwor
CQkJCWZvciAocHNmPW1jLT5tY2Ffc291cmNlcztwc2Y7cHNmPXBzZi0+c2ZfbmV4dCkgeworCQkJ
CQlpZiAoaXB2Nl9hZGRyX2NtcCgmcHNmLT5zZl9hZGRyLAorCQkJCQkgICAgc3JjX2FkZHIpID09
IDApCisJCQkJCQlicmVhazsKKwkJCQl9CisJCQkJaWYgKHBzZikKKwkJCQkJcnYgPSBwc2YtPnNm
X2NvdW50W01DQVNUX0lOQ0xVREVdIHx8CisJCQkJCQlwc2YtPnNmX2NvdW50W01DQVNUX0VYQ0xV
REVdICE9CisJCQkJCQltYy0+bWNhX3NmY291bnRbTUNBU1RfRVhDTFVERV07CisJCQkJZWxzZQor
CQkJCQlydiA9IG1jLT5tY2Ffc2Zjb3VudFtNQ0FTVF9FWENMVURFXSAhPTA7CisJCQkJc3Bpbl91
bmxvY2tfYmgoJm1jLT5tY2FfbG9jayk7CisJCQl9IGVsc2UKKwkJCQlydiA9IDE7IC8qIGRvbid0
IGZpbHRlciB1bnNwZWNpZmllZCBzb3VyY2UgKi8KIAkJfQogCQlyZWFkX3VubG9ja19iaCgmaWRl
di0+bG9jayk7CiAJCWluNl9kZXZfcHV0KGlkZXYpOwo=

--0__=07BBE4B7DFEF99E88f9e8a93df938690918c07BBE4B7DFEF99E8--
