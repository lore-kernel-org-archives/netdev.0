From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 3 Jan 2007 16:13:06 -0700
Message-ID: <OF68896635.077F2C1B-ON88257258.007F0BD8-88257258.007F8A72@us.ibm.com>
References: <OFD014A990.71736F9E-ON88257258.0079E460-88257258.007A382C@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 007F8A7088257258_="
Cc: jarkao2@o2.pl, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47909 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177AbXACXNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 18:13:08 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l03ND7OE021915
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 18:13:07 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l03ND7Pt433996
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 16:13:07 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l03ND7bW017624
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 16:13:07 -0700
In-Reply-To: <OFD014A990.71736F9E-ON88257258.0079E460-88257258.007A382C@us.ibm.com>
To: Ben Greear <greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 007F8A7088257258_=
Content-Type: text/plain; charset="US-ASCII"

Ben,
        Here's a patch that I think will fix it, assuming the receive is 
on the
same device as the initialization. Can you try this out?

                                                +-DLS
[inline for viewing, attached for applying]

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.19.1/net/ipv4/devinet.c 
linux-2.6.19.1T1/net/ipv4/devinet.c
--- linux-2.6.19.1/net/ipv4/devinet.c   2006-12-11 11:32:53.000000000 
-0800
+++ linux-2.6.19.1T1/net/ipv4/devinet.c 2007-01-03 14:37:56.000000000 
-0800
@@ -165,9 +165,8 @@ struct in_device *inetdev_init(struct ne
                              NET_IPV4_NEIGH, "ipv4", NULL, NULL);
 #endif
 
-       /* Account for reference dev->ip_ptr */
+       /* Account for reference dev->ip_ptr (below) */
        in_dev_hold(in_dev);
-       rcu_assign_pointer(dev->ip_ptr, in_dev);
 
 #ifdef CONFIG_SYSCTL
        devinet_sysctl_register(in_dev, &in_dev->cnf);
@@ -176,6 +175,8 @@ struct in_device *inetdev_init(struct ne
        if (dev->flags & IFF_UP)
                ip_mc_up(in_dev);
 out:
+       /* we can receive as soon as ip_ptr is set -- do this last */
+       rcu_assign_pointer(dev->ip_ptr, in_dev);
        return in_dev;
 out_kfree:
        kfree(in_dev);
diff -ruNp linux-2.6.19.1/net/ipv6/addrconf.c 
linux-2.6.19.1T1/net/ipv6/addrconf.c
--- linux-2.6.19.1/net/ipv6/addrconf.c  2006-12-11 11:32:53.000000000 
-0800
+++ linux-2.6.19.1T1/net/ipv6/addrconf.c        2007-01-03 
14:47:07.000000000 -0800
@@ -413,8 +413,6 @@ static struct inet6_dev * ipv6_add_dev(s
        if (netif_carrier_ok(dev))
                ndev->if_flags |= IF_READY;
 
-       /* protected by rtnl_lock */
-       rcu_assign_pointer(dev->ip6_ptr, ndev);
 
        ipv6_mc_init_dev(ndev);
        ndev->tstamp = jiffies;
@@ -425,6 +423,8 @@ static struct inet6_dev * ipv6_add_dev(s
                              NULL);
        addrconf_sysctl_register(ndev, &ndev->cnf);
 #endif
+       /* protected by rtnl_lock */
+       rcu_assign_pointer(dev->ip6_ptr, ndev);
        return ndev;
 }
 

--=_mixed 007F8A7088257258_=
Content-Type: application/octet-stream; name="initfix.patch"
Content-Disposition: attachment; filename="initfix.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTkuMS9uZXQvaXB2NC9kZXZpbmV0LmMgbGludXgtMi42LjE5
LjFUMS9uZXQvaXB2NC9kZXZpbmV0LmMKLS0tIGxpbnV4LTIuNi4xOS4xL25ldC9pcHY0L2Rldmlu
ZXQuYwkyMDA2LTEyLTExIDExOjMyOjUzLjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjE5
LjFUMS9uZXQvaXB2NC9kZXZpbmV0LmMJMjAwNy0wMS0wMyAxNDozNzo1Ni4wMDAwMDAwMDAgLTA4
MDAKQEAgLTE2NSw5ICsxNjUsOCBAQCBzdHJ1Y3QgaW5fZGV2aWNlICppbmV0ZGV2X2luaXQoc3Ry
dWN0IG5lCiAJCQkgICAgICBORVRfSVBWNF9ORUlHSCwgImlwdjQiLCBOVUxMLCBOVUxMKTsKICNl
bmRpZgogCi0JLyogQWNjb3VudCBmb3IgcmVmZXJlbmNlIGRldi0+aXBfcHRyICovCisJLyogQWNj
b3VudCBmb3IgcmVmZXJlbmNlIGRldi0+aXBfcHRyIChiZWxvdykgKi8KIAlpbl9kZXZfaG9sZChp
bl9kZXYpOwotCXJjdV9hc3NpZ25fcG9pbnRlcihkZXYtPmlwX3B0ciwgaW5fZGV2KTsKIAogI2lm
ZGVmIENPTkZJR19TWVNDVEwKIAlkZXZpbmV0X3N5c2N0bF9yZWdpc3Rlcihpbl9kZXYsICZpbl9k
ZXYtPmNuZik7CkBAIC0xNzYsNiArMTc1LDggQEAgc3RydWN0IGluX2RldmljZSAqaW5ldGRldl9p
bml0KHN0cnVjdCBuZQogCWlmIChkZXYtPmZsYWdzICYgSUZGX1VQKQogCQlpcF9tY191cChpbl9k
ZXYpOwogb3V0OgorCS8qIHdlIGNhbiByZWNlaXZlIGFzIHNvb24gYXMgaXBfcHRyIGlzIHNldCAt
LSBkbyB0aGlzIGxhc3QgKi8KKwlyY3VfYXNzaWduX3BvaW50ZXIoZGV2LT5pcF9wdHIsIGluX2Rl
dik7CiAJcmV0dXJuIGluX2RldjsKIG91dF9rZnJlZToKIAlrZnJlZShpbl9kZXYpOwpkaWZmIC1y
dU5wIGxpbnV4LTIuNi4xOS4xL25ldC9pcHY2L2FkZHJjb25mLmMgbGludXgtMi42LjE5LjFUMS9u
ZXQvaXB2Ni9hZGRyY29uZi5jCi0tLSBsaW51eC0yLjYuMTkuMS9uZXQvaXB2Ni9hZGRyY29uZi5j
CTIwMDYtMTItMTEgMTE6MzI6NTMuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMTkuMVQx
L25ldC9pcHY2L2FkZHJjb25mLmMJMjAwNy0wMS0wMyAxNDo0NzowNy4wMDAwMDAwMDAgLTA4MDAK
QEAgLTQxMyw4ICs0MTMsNiBAQCBzdGF0aWMgc3RydWN0IGluZXQ2X2RldiAqIGlwdjZfYWRkX2Rl
dihzCiAJaWYgKG5ldGlmX2NhcnJpZXJfb2soZGV2KSkKIAkJbmRldi0+aWZfZmxhZ3MgfD0gSUZf
UkVBRFk7CiAKLQkvKiBwcm90ZWN0ZWQgYnkgcnRubF9sb2NrICovCi0JcmN1X2Fzc2lnbl9wb2lu
dGVyKGRldi0+aXA2X3B0ciwgbmRldik7CiAKIAlpcHY2X21jX2luaXRfZGV2KG5kZXYpOwogCW5k
ZXYtPnRzdGFtcCA9IGppZmZpZXM7CkBAIC00MjUsNiArNDIzLDggQEAgc3RhdGljIHN0cnVjdCBp
bmV0Nl9kZXYgKiBpcHY2X2FkZF9kZXYocwogCQkJICAgICAgTlVMTCk7CiAJYWRkcmNvbmZfc3lz
Y3RsX3JlZ2lzdGVyKG5kZXYsICZuZGV2LT5jbmYpOwogI2VuZGlmCisJLyogcHJvdGVjdGVkIGJ5
IHJ0bmxfbG9jayAqLworCXJjdV9hc3NpZ25fcG9pbnRlcihkZXYtPmlwNl9wdHIsIG5kZXYpOwog
CXJldHVybiBuZGV2OwogfQogCg==

--=_mixed 007F8A7088257258_=--
