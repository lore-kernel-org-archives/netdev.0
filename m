From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] Re: Possible leak of multicast source filter sctructure
Date: Tue, 15 Aug 2006 17:57:58 -0600
Message-ID: <OF0DDEC0BC.F489C923-ON882571CB.0082F373-882571CB.0083A630@us.ibm.com>
References: <20060815.002139.107685177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0083A62D882571CB_="
Cc: kuznet@ms2.inr.ac.ru, michal.ruzicka@comstar.cz,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:32713 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750702AbWHOX6D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 19:58:03 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7FNw2o2025476
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 19:58:02 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7FNvx82361578
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 17:57:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7FNvxrQ022515
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 17:57:59 -0600
In-Reply-To: <20060815.002139.107685177.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 0083A62D882571CB_=
Content-Type: text/plain; charset="US-ASCII"

Here's a patch to fix source filter leakage when a device is removed
and a process leaves the group thereafter. (2nd part of prior discussion)

This patch also includes corresponding fixes for IPv6 multicast source
filters on device removal (1st & 2nd parts of prior discussion, for IPv6).

                                                +-DLS

[in-line for viewing, attached for applying]

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.17.8/net/ipv4/igmp.c 
linux-2.6.17.8-dls/net/ipv4/igmp.c
--- linux-2.6.17.8/net/ipv4/igmp.c      2006-08-06 21:18:54.000000000 
-0700
+++ linux-2.6.17.8-dls/net/ipv4/igmp.c  2006-08-15 16:30:18.000000000 
-0700
@@ -1796,29 +1796,35 @@ int ip_mc_leave_group(struct sock *sk, s
        struct in_device *in_dev;
        u32 group = imr->imr_multiaddr.s_addr;
        u32 ifindex;
+       int ret = -EADDRNOTAVAIL;
 
        rtnl_lock();
        in_dev = ip_mc_find_dev(imr);
-       if (!in_dev) {
-               rtnl_unlock();
-               return -ENODEV;
-       }
        ifindex = imr->imr_ifindex;
        for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = 
&iml->next) {
-               if (iml->multi.imr_multiaddr.s_addr == group &&
-                   iml->multi.imr_ifindex == ifindex) {
-                       (void) ip_mc_leave_src(sk, iml, in_dev);
+               if (iml->multi.imr_multiaddr.s_addr != group)
+                       continue;
+               if (ifindex) {
+                       if (iml->multi.imr_ifindex != ifindex)
+                               continue;
+               } else if (imr->imr_address.s_addr && 
imr->imr_address.s_addr !=
+                               iml->multi.imr_address.s_addr)
+                       continue;
+
+               (void) ip_mc_leave_src(sk, iml, in_dev);
 
-                       *imlp = iml->next;
+               *imlp = iml->next;
 
+               if (in_dev)
                        ip_mc_dec_group(in_dev, group);
-                       rtnl_unlock();
-                       sock_kfree_s(sk, iml, sizeof(*iml));
-                       return 0;
-               }
+               rtnl_unlock();
+               sock_kfree_s(sk, iml, sizeof(*iml));
+               return 0;
        }
+       if (!in_dev)
+               ret = -ENODEV;
        rtnl_unlock();
-       return -EADDRNOTAVAIL;
+       return ret;
 }
 
 int ip_mc_source(int add, int omode, struct sock *sk, struct
diff -ruNp linux-2.6.17.8/net/ipv6/mcast.c 
linux-2.6.17.8-dls/net/ipv6/mcast.c
--- linux-2.6.17.8/net/ipv6/mcast.c     2006-08-06 21:18:54.000000000 
-0700
+++ linux-2.6.17.8-dls/net/ipv6/mcast.c 2006-08-15 15:51:53.000000000 
-0700
@@ -269,13 +269,14 @@ int ipv6_sock_mc_drop(struct sock *sk, i
                        if ((dev = dev_get_by_index(mc_lst->ifindex)) != 
NULL) {
                                struct inet6_dev *idev = in6_dev_get(dev);
 
+                               (void) ip6_mc_leave_src(sk, mc_lst, idev);
                                if (idev) {
-                                       (void) 
ip6_mc_leave_src(sk,mc_lst,idev);
                                        __ipv6_dev_mc_dec(idev, 
&mc_lst->addr);
                                        in6_dev_put(idev);
                                }
                                dev_put(dev);
-                       }
+                       } else
+                               (void) ip6_mc_leave_src(sk, mc_lst, NULL);
                        sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
                        return 0;
                }
@@ -335,13 +336,14 @@ void ipv6_sock_mc_close(struct sock *sk)
                if (dev) {
                        struct inet6_dev *idev = in6_dev_get(dev);
 
+                       (void) ip6_mc_leave_src(sk, mc_lst, idev);
                        if (idev) {
-                               (void) ip6_mc_leave_src(sk, mc_lst, idev);
                                __ipv6_dev_mc_dec(idev, &mc_lst->addr);
                                in6_dev_put(idev);
                        }
                        dev_put(dev);
-               }
+               } else
+                       (void) ip6_mc_leave_src(sk, mc_lst, NULL);
 
                sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 


--=_mixed 0083A62D882571CB_=
Content-Type: application/octet-stream; name="mcd.patch"
Content-Disposition: attachment; filename="mcd.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTcuOC9uZXQvaXB2NC9pZ21wLmMgbGludXgtMi42LjE3Ljgt
ZGxzL25ldC9pcHY0L2lnbXAuYwotLS0gbGludXgtMi42LjE3LjgvbmV0L2lwdjQvaWdtcC5jCTIw
MDYtMDgtMDYgMjE6MTg6NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTcuOC1kbHMv
bmV0L2lwdjQvaWdtcC5jCTIwMDYtMDgtMTUgMTY6MzA6MTguMDAwMDAwMDAwIC0wNzAwCkBAIC0x
Nzk2LDI5ICsxNzk2LDM1IEBAIGludCBpcF9tY19sZWF2ZV9ncm91cChzdHJ1Y3Qgc29jayAqc2ss
IHMKIAlzdHJ1Y3QgaW5fZGV2aWNlICppbl9kZXY7CiAJdTMyIGdyb3VwID0gaW1yLT5pbXJfbXVs
dGlhZGRyLnNfYWRkcjsKIAl1MzIgaWZpbmRleDsKKwlpbnQgcmV0ID0gLUVBRERSTk9UQVZBSUw7
CiAKIAlydG5sX2xvY2soKTsKIAlpbl9kZXYgPSBpcF9tY19maW5kX2RldihpbXIpOwotCWlmICgh
aW5fZGV2KSB7Ci0JCXJ0bmxfdW5sb2NrKCk7Ci0JCXJldHVybiAtRU5PREVWOwotCX0KIAlpZmlu
ZGV4ID0gaW1yLT5pbXJfaWZpbmRleDsKIAlmb3IgKGltbHAgPSAmaW5ldC0+bWNfbGlzdDsgKGlt
bCA9ICppbWxwKSAhPSBOVUxMOyBpbWxwID0gJmltbC0+bmV4dCkgewotCQlpZiAoaW1sLT5tdWx0
aS5pbXJfbXVsdGlhZGRyLnNfYWRkciA9PSBncm91cCAmJgotCQkgICAgaW1sLT5tdWx0aS5pbXJf
aWZpbmRleCA9PSBpZmluZGV4KSB7Ci0JCQkodm9pZCkgaXBfbWNfbGVhdmVfc3JjKHNrLCBpbWws
IGluX2Rldik7CisJCWlmIChpbWwtPm11bHRpLmltcl9tdWx0aWFkZHIuc19hZGRyICE9IGdyb3Vw
KQorCQkJY29udGludWU7CisJCWlmIChpZmluZGV4KSB7CisJCQlpZiAoaW1sLT5tdWx0aS5pbXJf
aWZpbmRleCAhPSBpZmluZGV4KQorCQkJCWNvbnRpbnVlOworCQl9IGVsc2UgaWYgKGltci0+aW1y
X2FkZHJlc3Muc19hZGRyICYmIGltci0+aW1yX2FkZHJlc3Muc19hZGRyICE9CisJCQkJaW1sLT5t
dWx0aS5pbXJfYWRkcmVzcy5zX2FkZHIpCisJCQljb250aW51ZTsKKworCQkodm9pZCkgaXBfbWNf
bGVhdmVfc3JjKHNrLCBpbWwsIGluX2Rldik7CiAKLQkJCSppbWxwID0gaW1sLT5uZXh0OworCQkq
aW1scCA9IGltbC0+bmV4dDsKIAorCQlpZiAoaW5fZGV2KQogCQkJaXBfbWNfZGVjX2dyb3VwKGlu
X2RldiwgZ3JvdXApOwotCQkJcnRubF91bmxvY2soKTsKLQkJCXNvY2tfa2ZyZWVfcyhzaywgaW1s
LCBzaXplb2YoKmltbCkpOwotCQkJcmV0dXJuIDA7Ci0JCX0KKwkJcnRubF91bmxvY2soKTsKKwkJ
c29ja19rZnJlZV9zKHNrLCBpbWwsIHNpemVvZigqaW1sKSk7CisJCXJldHVybiAwOwogCX0KKwlp
ZiAoIWluX2RldikKKwkJcmV0ID0gLUVOT0RFVjsKIAlydG5sX3VubG9jaygpOwotCXJldHVybiAt
RUFERFJOT1RBVkFJTDsKKwlyZXR1cm4gcmV0OwogfQogCiBpbnQgaXBfbWNfc291cmNlKGludCBh
ZGQsIGludCBvbW9kZSwgc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3QKZGlmZiAtcnVOcCBsaW51eC0y
LjYuMTcuOC9uZXQvaXB2Ni9tY2FzdC5jIGxpbnV4LTIuNi4xNy44LWRscy9uZXQvaXB2Ni9tY2Fz
dC5jCi0tLSBsaW51eC0yLjYuMTcuOC9uZXQvaXB2Ni9tY2FzdC5jCTIwMDYtMDgtMDYgMjE6MTg6
NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTcuOC1kbHMvbmV0L2lwdjYvbWNhc3Qu
YwkyMDA2LTA4LTE1IDE1OjUxOjUzLjAwMDAwMDAwMCAtMDcwMApAQCAtMjY5LDEzICsyNjksMTQg
QEAgaW50IGlwdjZfc29ja19tY19kcm9wKHN0cnVjdCBzb2NrICpzaywgaQogCQkJaWYgKChkZXYg
PSBkZXZfZ2V0X2J5X2luZGV4KG1jX2xzdC0+aWZpbmRleCkpICE9IE5VTEwpIHsKIAkJCQlzdHJ1
Y3QgaW5ldDZfZGV2ICppZGV2ID0gaW42X2Rldl9nZXQoZGV2KTsKIAorCQkJCSh2b2lkKSBpcDZf
bWNfbGVhdmVfc3JjKHNrLCBtY19sc3QsIGlkZXYpOwogCQkJCWlmIChpZGV2KSB7Ci0JCQkJCSh2
b2lkKSBpcDZfbWNfbGVhdmVfc3JjKHNrLG1jX2xzdCxpZGV2KTsKIAkJCQkJX19pcHY2X2Rldl9t
Y19kZWMoaWRldiwgJm1jX2xzdC0+YWRkcik7CiAJCQkJCWluNl9kZXZfcHV0KGlkZXYpOwogCQkJ
CX0KIAkJCQlkZXZfcHV0KGRldik7Ci0JCQl9CisJCQl9IGVsc2UKKwkJCQkodm9pZCkgaXA2X21j
X2xlYXZlX3NyYyhzaywgbWNfbHN0LCBOVUxMKTsKIAkJCXNvY2tfa2ZyZWVfcyhzaywgbWNfbHN0
LCBzaXplb2YoKm1jX2xzdCkpOwogCQkJcmV0dXJuIDA7CiAJCX0KQEAgLTMzNSwxMyArMzM2LDE0
IEBAIHZvaWQgaXB2Nl9zb2NrX21jX2Nsb3NlKHN0cnVjdCBzb2NrICpzaykKIAkJaWYgKGRldikg
ewogCQkJc3RydWN0IGluZXQ2X2RldiAqaWRldiA9IGluNl9kZXZfZ2V0KGRldik7CiAKKwkJCSh2
b2lkKSBpcDZfbWNfbGVhdmVfc3JjKHNrLCBtY19sc3QsIGlkZXYpOwogCQkJaWYgKGlkZXYpIHsK
LQkJCQkodm9pZCkgaXA2X21jX2xlYXZlX3NyYyhzaywgbWNfbHN0LCBpZGV2KTsKIAkJCQlfX2lw
djZfZGV2X21jX2RlYyhpZGV2LCAmbWNfbHN0LT5hZGRyKTsKIAkJCQlpbjZfZGV2X3B1dChpZGV2
KTsKIAkJCX0KIAkJCWRldl9wdXQoZGV2KTsKLQkJfQorCQl9IGVsc2UKKwkJCSh2b2lkKSBpcDZf
bWNfbGVhdmVfc3JjKHNrLCBtY19sc3QsIE5VTEwpOwogCiAJCXNvY2tfa2ZyZWVfcyhzaywgbWNf
bHN0LCBzaXplb2YoKm1jX2xzdCkpOwogCg==

--=_mixed 0083A62D882571CB_=--
