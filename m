From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Thu, 24 Apr 2008 11:52:01 -0600
Message-ID: <OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0062243C88257435_="
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47386 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbYDXRwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 13:52:17 -0400
In-Reply-To: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 0062243C88257435_=
Content-Type: text/plain; charset="US-ASCII"

I was looking at this problem too, and below is what I have at the
moment. I've only tested the group_req portion, and I was looking
at putting this in net/compat.c with hooks back, since the code is
literally identical for IPv4 except the sockopt function you call at
the end, but I've moved it to ipv6_sockglue.c for this patch.

This touches a lot less code and I think comes out a lot smaller.

Method is to translate to padded version on the user stack, make
the call, and translate back (in the MSFILTER case) on return, as
is done for some other compat functions.

                                        +-DLS

inline for viewing, attached for applying, and no signed-off line
since I have completed it; just for discussion.

--- linux-2.6.18.ppc64/net/ipv6/ipv6_sockglue.c 2008-04-21 
13:51:02.000000000 -0700
+++ linux-2.6.18.ppc64DLS1/net/ipv6/ipv6_sockglue.c     2008-04-24 
02:20:23.000000000 -0700
@@ -39,6 +39,7 @@
 #include <linux/init.h>
 #include <linux/sysctl.h>
 #include <linux/netfilter.h>
+#include <linux/compat.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -754,6 +755,27 @@ int ipv6_setsockopt(struct sock *sk, int
 
 
 #ifdef CONFIG_COMPAT
+
+struct compat_group_req {
+       __u32                                   gr_interface;
+       struct __kernel_sockaddr_storage        gr_group;
+} __attribute__ ((packed));
+
+struct compat_group_source_req {
+       __u32                                   gsr_interface;
+       struct __kernel_sockaddr_storage        gsr_group;
+       struct __kernel_sockaddr_storage        gsr_source;
+} __attribute__ ((packed));
+
+struct compat_group_filter {
+       __u32                                   gf_interface;
+       struct __kernel_sockaddr_storage        gf_group;
+       __u32                                   gf_fmode;
+       __u32                                   gf_numsrc;
+       struct __kernel_sockaddr_storage        gf_slist[1];
+} __attribute__ ((packed));
+
+
 int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
                           char __user *optval, int optlen)
 {
@@ -769,6 +791,95 @@ int compat_ipv6_setsockopt(struct sock *
        if (level != SOL_IPV6)
                return -ENOPROTOOPT;
 
+       switch (optname) {
+       case MCAST_JOIN_GROUP:
+       case MCAST_LEAVE_GROUP:
+       {
+               struct compat_group_req __user *gr32 = (void *)optval;
+               struct group_req __user *kgr =
+                       compat_alloc_user_space(sizeof(struct group_req));
+               u32 interface;
+
+               if (!access_ok(VERIFY_READ, gr32, sizeof(*gr32)) ||
+                   !access_ok(VERIFY_WRITE, kgr, sizeof(struct 
group_req)) ||
+                   __get_user(interface, &gr32->gr_interface) ||
+                   __put_user(interface, &kgr->gr_interface) ||
+                   __copy_tofrom_user(&kgr->gr_group, &gr32->gr_group,
+                               sizeof(kgr->gr_group)))
+                       return -EFAULT;
+               return do_ipv6_setsockopt(sk, level, optname,
+                       (char __user *)kgr, sizeof(struct group_req));
+       }
+       case MCAST_JOIN_SOURCE_GROUP:
+       case MCAST_LEAVE_SOURCE_GROUP:
+       case MCAST_BLOCK_SOURCE:
+       case MCAST_UNBLOCK_SOURCE:
+       {
+               struct compat_group_source_req __user *gsr32 = (void 
*)optval;
+               struct group_source_req *kgsr = compat_alloc_user_space(
+                       sizeof(struct group_source_req));
+               u32 interface;
+
+               if (!access_ok(VERIFY_READ, gsr32, sizeof(*gsr32)) ||
+                   !access_ok(VERIFY_WRITE, kgsr,
+                       sizeof(struct group_source_req)) ||
+                   __get_user(interface, &gsr32->gsr_interface) ||
+                   __put_user(interface, &kgsr->gsr_interface) ||
+                   __copy_tofrom_user(&kgsr->gsr_group, 
&gsr32->gsr_group,
+                               sizeof(kgsr->gsr_group)) ||
+                   __copy_tofrom_user(&kgsr->gsr_source, 
&gsr32->gsr_source,
+                               sizeof(kgsr->gsr_source)))
+                       return -EFAULT;
+               return do_ipv6_setsockopt(sk, level, optname,
+                       (char __user *)kgsr, sizeof(struct 
group_source_req));
+       }
+       case MCAST_MSFILTER:
+       {
+               struct compat_group_filter __user *gf32 = (void *)optval;
+               struct group_filter *kgf;
+               u32 interface, fmode, numsrc;
+               int len;
+
+               if (!access_ok(VERIFY_READ, gf32, sizeof(*gf32)) ||
+                   __get_user(interface, &gf32->gf_interface) ||
+                   __get_user(fmode, &gf32->gf_fmode) ||
+                   __get_user(numsrc, &gf32->gf_numsrc))
+                       return -EFAULT;
+               if (optlen < GROUP_FILTER_SIZE(0))
+                       return -EINVAL;
+               len = GROUP_FILTER_SIZE(numsrc);
+               len = len < optlen ? len : optlen;
+               kgf = compat_alloc_user_space(len);
+               if (!access_ok(VERIFY_WRITE, kgf, len) ||
+                   __put_user(interface, &kgf->gf_interface) ||
+                   __put_user(fmode, &kgf->gf_fmode) ||
+                   __put_user(numsrc, &kgf->gf_numsrc) ||
+                   __copy_tofrom_user(&kgf->gf_group, &gf32->gf_group,
+                               sizeof(kgf->gf_group)) ||
+                   (numsrc && __copy_tofrom_user(&kgf->gf_slist,
+                               &gf32->gf_slist, len - 
GROUP_FILTER_SIZE(0))))
+                       return -EFAULT;
+               err = do_ipv6_setsockopt(sk, level, optname,
+                       (char __user *)kgf, len);
+               if (!access_ok(VERIFY_WRITE, gf32, sizeof(*gf32)) ||
+                   __get_user(interface, &kgf->gf_interface) ||
+                   __put_user(interface, &gf32->gf_interface) ||
+                   __get_user(fmode, &kgf->gf_fmode) ||
+                   __put_user(fmode, &gf32->gf_fmode) ||
+                   __get_user(numsrc, &kgf->gf_numsrc) ||
+                   __put_user(numsrc, &gf32->gf_numsrc) ||
+                   __copy_tofrom_user(&gf32->gf_group, &kgf->gf_group,
+                               sizeof(gf32->gf_group)) ||
+                   (numsrc && __copy_tofrom_user(&gf32->gf_slist,
+                               &kgf->gf_slist, len - 
GROUP_FILTER_SIZE(0))))
+                       return -EFAULT;
+               return err;
+       }
+
+       default:
+               break;
+       }
+
        err = do_ipv6_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible ENOPROTOOPTs except default 
case */


--=_mixed 0062243C88257435_=
Content-Type: application/octet-stream; name="mc_compat1.patch"
Content-Disposition: attachment; filename="mc_compat1.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi4xOC5wcGM2NC9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMJMjAwOC0wNC0y
MSAxMzo1MTowMi4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xOC5wcGM2NERMUzEvbmV0
L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jCTIwMDgtMDQtMjQgMDI6MjA6MjMuMDAwMDAwMDAwIC0wNzAw
CkBAIC0zOSw2ICszOSw3IEBACiAjaW5jbHVkZSA8bGludXgvaW5pdC5oPgogI2luY2x1ZGUgPGxp
bnV4L3N5c2N0bC5oPgogI2luY2x1ZGUgPGxpbnV4L25ldGZpbHRlci5oPgorI2luY2x1ZGUgPGxp
bnV4L2NvbXBhdC5oPgogCiAjaW5jbHVkZSA8bmV0L3NvY2suaD4KICNpbmNsdWRlIDxuZXQvc25t
cC5oPgpAQCAtNzU0LDYgKzc1NSwyNyBAQCBpbnQgaXB2Nl9zZXRzb2Nrb3B0KHN0cnVjdCBzb2Nr
ICpzaywgaW50CiAKIAogI2lmZGVmIENPTkZJR19DT01QQVQKKworc3RydWN0IGNvbXBhdF9ncm91
cF9yZXEgeworCV9fdTMyCQkJCQlncl9pbnRlcmZhY2U7CisJc3RydWN0IF9fa2VybmVsX3NvY2th
ZGRyX3N0b3JhZ2UJZ3JfZ3JvdXA7Cit9IF9fYXR0cmlidXRlX18gKChwYWNrZWQpKTsKKworc3Ry
dWN0IGNvbXBhdF9ncm91cF9zb3VyY2VfcmVxIHsKKwlfX3UzMgkJCQkJZ3NyX2ludGVyZmFjZTsK
KwlzdHJ1Y3QgX19rZXJuZWxfc29ja2FkZHJfc3RvcmFnZQlnc3JfZ3JvdXA7CisJc3RydWN0IF9f
a2VybmVsX3NvY2thZGRyX3N0b3JhZ2UJZ3NyX3NvdXJjZTsKK30gX19hdHRyaWJ1dGVfXyAoKHBh
Y2tlZCkpOworCitzdHJ1Y3QgY29tcGF0X2dyb3VwX2ZpbHRlciB7CisJX191MzIJCQkJCWdmX2lu
dGVyZmFjZTsKKwlzdHJ1Y3QgX19rZXJuZWxfc29ja2FkZHJfc3RvcmFnZQlnZl9ncm91cDsKKwlf
X3UzMgkJCQkJZ2ZfZm1vZGU7CisJX191MzIJCQkJCWdmX251bXNyYzsKKwlzdHJ1Y3QgX19rZXJu
ZWxfc29ja2FkZHJfc3RvcmFnZQlnZl9zbGlzdFsxXTsKK30gX19hdHRyaWJ1dGVfXyAoKHBhY2tl
ZCkpOworCisKIGludCBjb21wYXRfaXB2Nl9zZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICpzaywgaW50
IGxldmVsLCBpbnQgb3B0bmFtZSwKIAkJCSAgIGNoYXIgX191c2VyICpvcHR2YWwsIGludCBvcHRs
ZW4pCiB7CkBAIC03NjksNiArNzkxLDk1IEBAIGludCBjb21wYXRfaXB2Nl9zZXRzb2Nrb3B0KHN0
cnVjdCBzb2NrICoKIAlpZiAobGV2ZWwgIT0gU09MX0lQVjYpCiAJCXJldHVybiAtRU5PUFJPVE9P
UFQ7CiAKKwlzd2l0Y2ggKG9wdG5hbWUpIHsKKwljYXNlIE1DQVNUX0pPSU5fR1JPVVA6CisJY2Fz
ZSBNQ0FTVF9MRUFWRV9HUk9VUDoKKwl7CisJCXN0cnVjdCBjb21wYXRfZ3JvdXBfcmVxIF9fdXNl
ciAqZ3IzMiA9ICh2b2lkICopb3B0dmFsOworCQlzdHJ1Y3QgZ3JvdXBfcmVxIF9fdXNlciAqa2dy
ID0KKwkJCWNvbXBhdF9hbGxvY191c2VyX3NwYWNlKHNpemVvZihzdHJ1Y3QgZ3JvdXBfcmVxKSk7
CisJCXUzMiBpbnRlcmZhY2U7CisKKwkJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1JFQUQsIGdyMzIs
IHNpemVvZigqZ3IzMikpIHx8CisJCSAgICAhYWNjZXNzX29rKFZFUklGWV9XUklURSwga2dyLCBz
aXplb2Yoc3RydWN0IGdyb3VwX3JlcSkpIHx8CisJCSAgICBfX2dldF91c2VyKGludGVyZmFjZSwg
JmdyMzItPmdyX2ludGVyZmFjZSkgfHwKKwkJICAgIF9fcHV0X3VzZXIoaW50ZXJmYWNlLCAma2dy
LT5ncl9pbnRlcmZhY2UpIHx8CisJCSAgICBfX2NvcHlfdG9mcm9tX3VzZXIoJmtnci0+Z3JfZ3Jv
dXAsICZncjMyLT5ncl9ncm91cCwKKwkJCQlzaXplb2Yoa2dyLT5ncl9ncm91cCkpKQorCQkJcmV0
dXJuIC1FRkFVTFQ7CisJCXJldHVybiBkb19pcHY2X3NldHNvY2tvcHQoc2ssIGxldmVsLCBvcHRu
YW1lLAorCQkJKGNoYXIgX191c2VyICopa2dyLCBzaXplb2Yoc3RydWN0IGdyb3VwX3JlcSkpOwor
CX0KKwljYXNlIE1DQVNUX0pPSU5fU09VUkNFX0dST1VQOgorCWNhc2UgTUNBU1RfTEVBVkVfU09V
UkNFX0dST1VQOgorCWNhc2UgTUNBU1RfQkxPQ0tfU09VUkNFOgorCWNhc2UgTUNBU1RfVU5CTE9D
S19TT1VSQ0U6CisJeworCQlzdHJ1Y3QgY29tcGF0X2dyb3VwX3NvdXJjZV9yZXEgX191c2VyICpn
c3IzMiA9ICh2b2lkICopb3B0dmFsOworCQlzdHJ1Y3QgZ3JvdXBfc291cmNlX3JlcSAqa2dzciA9
IGNvbXBhdF9hbGxvY191c2VyX3NwYWNlKAorCQkJc2l6ZW9mKHN0cnVjdCBncm91cF9zb3VyY2Vf
cmVxKSk7CisJCXUzMiBpbnRlcmZhY2U7CisKKwkJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1JFQUQs
IGdzcjMyLCBzaXplb2YoKmdzcjMyKSkgfHwKKwkJICAgICFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRF
LCBrZ3NyLAorCQkJc2l6ZW9mKHN0cnVjdCBncm91cF9zb3VyY2VfcmVxKSkgfHwKKwkJICAgIF9f
Z2V0X3VzZXIoaW50ZXJmYWNlLCAmZ3NyMzItPmdzcl9pbnRlcmZhY2UpIHx8CisJCSAgICBfX3B1
dF91c2VyKGludGVyZmFjZSwgJmtnc3ItPmdzcl9pbnRlcmZhY2UpIHx8CisJCSAgICBfX2NvcHlf
dG9mcm9tX3VzZXIoJmtnc3ItPmdzcl9ncm91cCwgJmdzcjMyLT5nc3JfZ3JvdXAsCisJCQkJc2l6
ZW9mKGtnc3ItPmdzcl9ncm91cCkpIHx8CisJCSAgICBfX2NvcHlfdG9mcm9tX3VzZXIoJmtnc3It
Pmdzcl9zb3VyY2UsICZnc3IzMi0+Z3NyX3NvdXJjZSwKKwkJCQlzaXplb2Yoa2dzci0+Z3NyX3Nv
dXJjZSkpKQorCQkJcmV0dXJuIC1FRkFVTFQ7CisJCXJldHVybiBkb19pcHY2X3NldHNvY2tvcHQo
c2ssIGxldmVsLCBvcHRuYW1lLAorCQkJKGNoYXIgX191c2VyICopa2dzciwgc2l6ZW9mKHN0cnVj
dCBncm91cF9zb3VyY2VfcmVxKSk7CisJfQorCWNhc2UgTUNBU1RfTVNGSUxURVI6CisJeworCQlz
dHJ1Y3QgY29tcGF0X2dyb3VwX2ZpbHRlciBfX3VzZXIgKmdmMzIgPSAodm9pZCAqKW9wdHZhbDsK
KwkJc3RydWN0IGdyb3VwX2ZpbHRlciAqa2dmOworCQl1MzIgaW50ZXJmYWNlLCBmbW9kZSwgbnVt
c3JjOworCQlpbnQgbGVuOworCisJCWlmICghYWNjZXNzX29rKFZFUklGWV9SRUFELCBnZjMyLCBz
aXplb2YoKmdmMzIpKSB8fAorCQkgICAgX19nZXRfdXNlcihpbnRlcmZhY2UsICZnZjMyLT5nZl9p
bnRlcmZhY2UpIHx8CisJCSAgICBfX2dldF91c2VyKGZtb2RlLCAmZ2YzMi0+Z2ZfZm1vZGUpIHx8
CisJCSAgICBfX2dldF91c2VyKG51bXNyYywgJmdmMzItPmdmX251bXNyYykpCisJCQlyZXR1cm4g
LUVGQVVMVDsKKwkJaWYgKG9wdGxlbiA8IEdST1VQX0ZJTFRFUl9TSVpFKDApKQorCQkJcmV0dXJu
IC1FSU5WQUw7CisJCWxlbiA9IEdST1VQX0ZJTFRFUl9TSVpFKG51bXNyYyk7CisJCWxlbiA9IGxl
biA8IG9wdGxlbiA/IGxlbiA6IG9wdGxlbjsKKwkJa2dmID0gY29tcGF0X2FsbG9jX3VzZXJfc3Bh
Y2UobGVuKTsKKwkJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBrZ2YsIGxlbikgfHwKKwkJ
ICAgIF9fcHV0X3VzZXIoaW50ZXJmYWNlLCAma2dmLT5nZl9pbnRlcmZhY2UpIHx8CisJCSAgICBf
X3B1dF91c2VyKGZtb2RlLCAma2dmLT5nZl9mbW9kZSkgfHwKKwkJICAgIF9fcHV0X3VzZXIobnVt
c3JjLCAma2dmLT5nZl9udW1zcmMpIHx8CisJCSAgICBfX2NvcHlfdG9mcm9tX3VzZXIoJmtnZi0+
Z2ZfZ3JvdXAsICZnZjMyLT5nZl9ncm91cCwKKwkJCQlzaXplb2Yoa2dmLT5nZl9ncm91cCkpIHx8
CisJCSAgICAobnVtc3JjICYmIF9fY29weV90b2Zyb21fdXNlcigma2dmLT5nZl9zbGlzdCwKKwkJ
CQkmZ2YzMi0+Z2Zfc2xpc3QsIGxlbiAtIEdST1VQX0ZJTFRFUl9TSVpFKDApKSkpCisJCQlyZXR1
cm4gLUVGQVVMVDsKKwkJZXJyID0gZG9faXB2Nl9zZXRzb2Nrb3B0KHNrLCBsZXZlbCwgb3B0bmFt
ZSwKKwkJCShjaGFyIF9fdXNlciAqKWtnZiwgbGVuKTsKKwkJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZ
X1dSSVRFLCBnZjMyLCBzaXplb2YoKmdmMzIpKSB8fAorCQkgICAgX19nZXRfdXNlcihpbnRlcmZh
Y2UsICZrZ2YtPmdmX2ludGVyZmFjZSkgfHwKKwkJICAgIF9fcHV0X3VzZXIoaW50ZXJmYWNlLCAm
Z2YzMi0+Z2ZfaW50ZXJmYWNlKSB8fAorCQkgICAgX19nZXRfdXNlcihmbW9kZSwgJmtnZi0+Z2Zf
Zm1vZGUpIHx8CisJCSAgICBfX3B1dF91c2VyKGZtb2RlLCAmZ2YzMi0+Z2ZfZm1vZGUpIHx8CisJ
CSAgICBfX2dldF91c2VyKG51bXNyYywgJmtnZi0+Z2ZfbnVtc3JjKSB8fAorCQkgICAgX19wdXRf
dXNlcihudW1zcmMsICZnZjMyLT5nZl9udW1zcmMpIHx8CisJCSAgICBfX2NvcHlfdG9mcm9tX3Vz
ZXIoJmdmMzItPmdmX2dyb3VwLCAma2dmLT5nZl9ncm91cCwKKwkJCQlzaXplb2YoZ2YzMi0+Z2Zf
Z3JvdXApKSB8fAorCQkgICAgKG51bXNyYyAmJiBfX2NvcHlfdG9mcm9tX3VzZXIoJmdmMzItPmdm
X3NsaXN0LAorCQkJCSZrZ2YtPmdmX3NsaXN0LCBsZW4gLSBHUk9VUF9GSUxURVJfU0laRSgwKSkp
KQorCQkJcmV0dXJuIC1FRkFVTFQ7CisJCXJldHVybiBlcnI7CisJfQorCisJZGVmYXVsdDoKKwkJ
YnJlYWs7CisJfQorCiAJZXJyID0gZG9faXB2Nl9zZXRzb2Nrb3B0KHNrLCBsZXZlbCwgb3B0bmFt
ZSwgb3B0dmFsLCBvcHRsZW4pOwogI2lmZGVmIENPTkZJR19ORVRGSUxURVIKIAkvKiB3ZSBuZWVk
IHRvIGV4Y2x1ZGUgYWxsIHBvc3NpYmxlIEVOT1BST1RPT1BUcyBleGNlcHQgZGVmYXVsdCBjYXNl
ICovCg==

--=_mixed 0062243C88257435_=--
