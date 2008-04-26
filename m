From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Fri, 25 Apr 2008 18:24:28 -0600
Message-ID: <OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com>
References: <20080425.162417.25756786.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 00023C8288257437_="
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46915 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758131AbYDZAYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 20:24:41 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3Q0OUG3014223
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 20:24:30 -0400
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3Q0OUp3030154
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 18:24:30 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.13.1/8.13.3) with ESMTP id m3Q0OTSr002256
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 18:24:30 -0600
In-Reply-To: <20080425.162417.25756786.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 00023C8288257437_=
Content-Type: text/plain; charset="US-ASCII"

Here's what I have for setsockopt, v4 & v6 and tested with both.

I discovered that the aligned attribute is only a minimum, so
aligned by itself has no effect on padding. GNU documentation
says you need both aligned and packed to make the pad be
a certain value.  In this case, because the items that
are padded are 32 bit, they are identical with and without on all
architectures, but I stuck in the aligned all the same.

Patch is against 2.6.18, but it applies to 2.6.25 too.

I'll get to work on getsockopt for these now.

                                +-DLS

Patch blurb:

Added 32-bit compatibility support for setsockopt using
MCAST_* socket options.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.18.ppc64/include/net/compat.h 
linux-2.6.18.ppc64DLS1/include/net/compat.h
--- linux-2.6.18.ppc64/include/net/compat.h     2008-04-21 
13:50:33.000000000 -0700
+++ linux-2.6.18.ppc64DLS1/include/net/compat.h 2008-04-25 
03:13:39.000000000 -0700
@@ -39,4 +39,6 @@ extern int put_cmsg_compat(struct msghdr
 
 extern int cmsghdr_from_user_compat_to_kern(struct msghdr *, struct sock 
*, unsigned char *, int);
 
+extern int compat_mc_setsockopt(struct sock *, int, int, char __user *, 
int);
+
 #endif /* NET_COMPAT_H */
diff -ruNp linux-2.6.18.ppc64/net/compat.c 
linux-2.6.18.ppc64DLS1/net/compat.c
--- linux-2.6.18.ppc64/net/compat.c     2008-04-21 13:51:02.000000000 
-0700
+++ linux-2.6.18.ppc64DLS1/net/compat.c 2008-04-25 08:53:47.000000000 
-0700
@@ -26,6 +26,8 @@
 
 #include <net/scm.h>
 #include <net/sock.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
 #include <asm/uaccess.h>
 #include <net/compat.h>
 
@@ -589,6 +591,122 @@ asmlinkage long compat_sys_getsockopt(in
        }
        return err;
 }
+
+struct compat_group_req {
+       __u32                            gr_interface;
+       struct __kernel_sockaddr_storage gr_group
+               __attribute__ ((aligned(4)));
+} __attribute__ ((packed));
+
+struct compat_group_source_req {
+       __u32                            gsr_interface;
+       struct __kernel_sockaddr_storage gsr_group
+               __attribute__ ((aligned(4)));
+       struct __kernel_sockaddr_storage gsr_source
+               __attribute__ ((aligned(4)));
+} __attribute__ ((packed));
+
+struct compat_group_filter {
+       __u32                            gf_interface;
+       struct __kernel_sockaddr_storage gf_group
+               __attribute__ ((aligned(4)));
+       __u32                            gf_fmode;
+       __u32                            gf_numsrc;
+       struct __kernel_sockaddr_storage gf_slist[1]
+               __attribute__ ((aligned(4)));
+} __attribute__ ((packed));
+
+
+int compat_mc_setsockopt(struct sock *sock, int level, int optname,
+       char __user *optval, int optlen)
+{
+       char __user     *koptval = optval;
+       int             koptlen = optlen;
+
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
+                   copy_in_user(&kgr->gr_group, &gr32->gr_group,
+                               sizeof(kgr->gr_group)))
+                       return -EFAULT;
+               koptval = (char __user *)kgr;
+               koptlen = sizeof(struct group_req);
+               break;
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
+                   copy_in_user(&kgsr->gsr_group, &gsr32->gsr_group,
+                               sizeof(kgsr->gsr_group)) ||
+                   copy_in_user(&kgsr->gsr_source, &gsr32->gsr_source,
+                               sizeof(kgsr->gsr_source)))
+                       return -EFAULT;
+               koptval = (char __user *)kgsr;
+               koptlen = sizeof(struct group_source_req);
+               break;
+       }
+       case MCAST_MSFILTER:
+       {
+               struct compat_group_filter __user *gf32 = (void *)optval;
+               struct group_filter *kgf;
+               u32 interface, fmode, numsrc;
+
+               if (!access_ok(VERIFY_READ, gf32, sizeof(*gf32)) ||
+                   __get_user(interface, &gf32->gf_interface) ||
+                   __get_user(fmode, &gf32->gf_fmode) ||
+                   __get_user(numsrc, &gf32->gf_numsrc))
+                       return -EFAULT;
+               koptlen = optlen + sizeof(struct group_filter) -
+                               sizeof(struct compat_group_filter);
+               if (koptlen < GROUP_FILTER_SIZE(numsrc))
+                       return -EINVAL;
+               kgf = compat_alloc_user_space(koptlen);
+               if (!access_ok(VERIFY_WRITE, kgf, koptlen) ||
+                   __put_user(interface, &kgf->gf_interface) ||
+                   __put_user(fmode, &kgf->gf_fmode) ||
+                   __put_user(numsrc, &kgf->gf_numsrc) ||
+                   copy_in_user(&kgf->gf_group, &gf32->gf_group,
+                               sizeof(kgf->gf_group)) ||
+                   (numsrc && copy_in_user(&kgf->gf_slist, 
&gf32->gf_slist,
+                               numsrc * sizeof(kgf->gf_slist[0]))))
+                       return -EFAULT;
+               koptval = (char __user *)kgf;
+               break;
+       }
+
+       default:
+               break;
+       }
+       if (level == SOL_IPV6)
+               return ipv6_setsockopt(sock, level, optname, koptval, 
koptlen);
+       return ip_setsockopt(sock, level, optname, koptval, koptlen);
+}
+
+EXPORT_SYMBOL(compat_mc_setsockopt);
+
+
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
 static unsigned char nas[18]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
diff -ruNp linux-2.6.18.ppc64/net/ipv4/ip_sockglue.c 
linux-2.6.18.ppc64DLS1/net/ipv4/ip_sockglue.c
--- linux-2.6.18.ppc64/net/ipv4/ip_sockglue.c   2008-04-21 
13:51:00.000000000 -0700
+++ linux-2.6.18.ppc64DLS1/net/ipv4/ip_sockglue.c       2008-04-25 
08:16:40.000000000 -0700
@@ -37,6 +37,7 @@
 #include <linux/mroute.h>
 #include <net/route.h>
 #include <net/xfrm.h>
+#include <net/compat.h>
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <net/transp_v6.h>
 #endif
@@ -921,6 +922,9 @@ int compat_ip_setsockopt(struct sock *sk
        if (level != SOL_IP)
                return -ENOPROTOOPT;
 
+       if (optname >= MCAST_JOIN_GROUP && optname <= MCAST_MSFILTER)
+               return compat_mc_setsockopt(sk, level, optname, optval, 
optlen);
+
        err = do_ip_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible ENOPROTOOPTs except default 
case */
diff -ruNp linux-2.6.18.ppc64/net/ipv6/ipv6_sockglue.c 
linux-2.6.18.ppc64DLS1/net/ipv6/ipv6_sockglue.c
--- linux-2.6.18.ppc64/net/ipv6/ipv6_sockglue.c 2008-04-21 
13:51:02.000000000 -0700
+++ linux-2.6.18.ppc64DLS1/net/ipv6/ipv6_sockglue.c     2008-04-25 
05:34:02.000000000 -0700
@@ -52,6 +52,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/xfrm.h>
+#include <net/compat.h>
 
 #include <asm/uaccess.h>
 
@@ -769,6 +770,9 @@ int compat_ipv6_setsockopt(struct sock *
        if (level != SOL_IPV6)
                return -ENOPROTOOPT;
 
+       if (optname >= MCAST_JOIN_GROUP && optname <= MCAST_MSFILTER)
+               return compat_mc_setsockopt(sk, level, optname, optval, 
optlen);
+
        err = do_ipv6_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible ENOPROTOOPTs except default 
case */


--=_mixed 00023C8288257437_=
Content-Type: application/octet-stream; name="setsockopt2.patch"
Content-Disposition: attachment; filename="setsockopt2.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTgucHBjNjQvaW5jbHVkZS9uZXQvY29tcGF0LmggbGludXgt
Mi42LjE4LnBwYzY0RExTMS9pbmNsdWRlL25ldC9jb21wYXQuaAotLS0gbGludXgtMi42LjE4LnBw
YzY0L2luY2x1ZGUvbmV0L2NvbXBhdC5oCTIwMDgtMDQtMjEgMTM6NTA6MzMuMDAwMDAwMDAwIC0w
NzAwCisrKyBsaW51eC0yLjYuMTgucHBjNjRETFMxL2luY2x1ZGUvbmV0L2NvbXBhdC5oCTIwMDgt
MDQtMjUgMDM6MTM6MzkuMDAwMDAwMDAwIC0wNzAwCkBAIC0zOSw0ICszOSw2IEBAIGV4dGVybiBp
bnQgcHV0X2Ntc2dfY29tcGF0KHN0cnVjdCBtc2doZHIKIAogZXh0ZXJuIGludCBjbXNnaGRyX2Zy
b21fdXNlcl9jb21wYXRfdG9fa2VybihzdHJ1Y3QgbXNnaGRyICosIHN0cnVjdCBzb2NrICosIHVu
c2lnbmVkIGNoYXIgKiwgaW50KTsKIAorZXh0ZXJuIGludCBjb21wYXRfbWNfc2V0c29ja29wdChz
dHJ1Y3Qgc29jayAqLCBpbnQsIGludCwgY2hhciBfX3VzZXIgKiwgaW50KTsKKwogI2VuZGlmIC8q
IE5FVF9DT01QQVRfSCAqLwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4xOC5wcGM2NC9uZXQvY29tcGF0
LmMgbGludXgtMi42LjE4LnBwYzY0RExTMS9uZXQvY29tcGF0LmMKLS0tIGxpbnV4LTIuNi4xOC5w
cGM2NC9uZXQvY29tcGF0LmMJMjAwOC0wNC0yMSAxMzo1MTowMi4wMDAwMDAwMDAgLTA3MDAKKysr
IGxpbnV4LTIuNi4xOC5wcGM2NERMUzEvbmV0L2NvbXBhdC5jCTIwMDgtMDQtMjUgMDg6NTM6NDcu
MDAwMDAwMDAwIC0wNzAwCkBAIC0yNiw2ICsyNiw4IEBACiAKICNpbmNsdWRlIDxuZXQvc2NtLmg+
CiAjaW5jbHVkZSA8bmV0L3NvY2suaD4KKyNpbmNsdWRlIDxuZXQvaXAuaD4KKyNpbmNsdWRlIDxu
ZXQvaXB2Ni5oPgogI2luY2x1ZGUgPGFzbS91YWNjZXNzLmg+CiAjaW5jbHVkZSA8bmV0L2NvbXBh
dC5oPgogCkBAIC01ODksNiArNTkxLDEyMiBAQCBhc21saW5rYWdlIGxvbmcgY29tcGF0X3N5c19n
ZXRzb2Nrb3B0KGluCiAJfQogCXJldHVybiBlcnI7CiB9CisKK3N0cnVjdCBjb21wYXRfZ3JvdXBf
cmVxIHsKKwlfX3UzMgkJCQkgZ3JfaW50ZXJmYWNlOworCXN0cnVjdCBfX2tlcm5lbF9zb2NrYWRk
cl9zdG9yYWdlIGdyX2dyb3VwCisJCV9fYXR0cmlidXRlX18gKChhbGlnbmVkKDQpKSk7Cit9IF9f
YXR0cmlidXRlX18gKChwYWNrZWQpKTsKKworc3RydWN0IGNvbXBhdF9ncm91cF9zb3VyY2VfcmVx
IHsKKwlfX3UzMgkJCQkgZ3NyX2ludGVyZmFjZTsKKwlzdHJ1Y3QgX19rZXJuZWxfc29ja2FkZHJf
c3RvcmFnZSBnc3JfZ3JvdXAKKwkJX19hdHRyaWJ1dGVfXyAoKGFsaWduZWQoNCkpKTsKKwlzdHJ1
Y3QgX19rZXJuZWxfc29ja2FkZHJfc3RvcmFnZSBnc3Jfc291cmNlCisJCV9fYXR0cmlidXRlX18g
KChhbGlnbmVkKDQpKSk7Cit9IF9fYXR0cmlidXRlX18gKChwYWNrZWQpKTsKKworc3RydWN0IGNv
bXBhdF9ncm91cF9maWx0ZXIgeworCV9fdTMyCQkJCSBnZl9pbnRlcmZhY2U7CisJc3RydWN0IF9f
a2VybmVsX3NvY2thZGRyX3N0b3JhZ2UgZ2ZfZ3JvdXAKKwkJX19hdHRyaWJ1dGVfXyAoKGFsaWdu
ZWQoNCkpKTsKKwlfX3UzMgkJCQkgZ2ZfZm1vZGU7CisJX191MzIJCQkJIGdmX251bXNyYzsKKwlz
dHJ1Y3QgX19rZXJuZWxfc29ja2FkZHJfc3RvcmFnZSBnZl9zbGlzdFsxXQorCQlfX2F0dHJpYnV0
ZV9fICgoYWxpZ25lZCg0KSkpOworfSBfX2F0dHJpYnV0ZV9fICgocGFja2VkKSk7CisKKworaW50
IGNvbXBhdF9tY19zZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICpzb2NrLCBpbnQgbGV2ZWwsIGludCBv
cHRuYW1lLAorCWNoYXIgX191c2VyICpvcHR2YWwsIGludCBvcHRsZW4pCit7CisJY2hhciBfX3Vz
ZXIJKmtvcHR2YWwgPSBvcHR2YWw7CisJaW50CQlrb3B0bGVuID0gb3B0bGVuOworCisJc3dpdGNo
IChvcHRuYW1lKSB7CisJY2FzZSBNQ0FTVF9KT0lOX0dST1VQOgorCWNhc2UgTUNBU1RfTEVBVkVf
R1JPVVA6CisJeworCQlzdHJ1Y3QgY29tcGF0X2dyb3VwX3JlcSBfX3VzZXIgKmdyMzIgPSAodm9p
ZCAqKW9wdHZhbDsKKwkJc3RydWN0IGdyb3VwX3JlcSBfX3VzZXIgKmtnciA9CisJCQljb21wYXRf
YWxsb2NfdXNlcl9zcGFjZShzaXplb2Yoc3RydWN0IGdyb3VwX3JlcSkpOworCQl1MzIgaW50ZXJm
YWNlOworCisJCWlmICghYWNjZXNzX29rKFZFUklGWV9SRUFELCBncjMyLCBzaXplb2YoKmdyMzIp
KSB8fAorCQkgICAgIWFjY2Vzc19vayhWRVJJRllfV1JJVEUsIGtnciwgc2l6ZW9mKHN0cnVjdCBn
cm91cF9yZXEpKSB8fAorCQkgICAgX19nZXRfdXNlcihpbnRlcmZhY2UsICZncjMyLT5ncl9pbnRl
cmZhY2UpIHx8CisJCSAgICBfX3B1dF91c2VyKGludGVyZmFjZSwgJmtnci0+Z3JfaW50ZXJmYWNl
KSB8fAorCQkgICAgY29weV9pbl91c2VyKCZrZ3ItPmdyX2dyb3VwLCAmZ3IzMi0+Z3JfZ3JvdXAs
CisJCQkJc2l6ZW9mKGtnci0+Z3JfZ3JvdXApKSkKKwkJCXJldHVybiAtRUZBVUxUOworCQlrb3B0
dmFsID0gKGNoYXIgX191c2VyICopa2dyOworCQlrb3B0bGVuID0gc2l6ZW9mKHN0cnVjdCBncm91
cF9yZXEpOworCQlicmVhazsKKwl9CisJY2FzZSBNQ0FTVF9KT0lOX1NPVVJDRV9HUk9VUDoKKwlj
YXNlIE1DQVNUX0xFQVZFX1NPVVJDRV9HUk9VUDoKKwljYXNlIE1DQVNUX0JMT0NLX1NPVVJDRToK
KwljYXNlIE1DQVNUX1VOQkxPQ0tfU09VUkNFOgorCXsKKwkJc3RydWN0IGNvbXBhdF9ncm91cF9z
b3VyY2VfcmVxIF9fdXNlciAqZ3NyMzIgPSAodm9pZCAqKW9wdHZhbDsKKwkJc3RydWN0IGdyb3Vw
X3NvdXJjZV9yZXEgKmtnc3IgPSBjb21wYXRfYWxsb2NfdXNlcl9zcGFjZSgKKwkJCXNpemVvZihz
dHJ1Y3QgZ3JvdXBfc291cmNlX3JlcSkpOworCQl1MzIgaW50ZXJmYWNlOworCisJCWlmICghYWNj
ZXNzX29rKFZFUklGWV9SRUFELCBnc3IzMiwgc2l6ZW9mKCpnc3IzMikpIHx8CisJCSAgICAhYWNj
ZXNzX29rKFZFUklGWV9XUklURSwga2dzciwKKwkJCXNpemVvZihzdHJ1Y3QgZ3JvdXBfc291cmNl
X3JlcSkpIHx8CisJCSAgICBfX2dldF91c2VyKGludGVyZmFjZSwgJmdzcjMyLT5nc3JfaW50ZXJm
YWNlKSB8fAorCQkgICAgX19wdXRfdXNlcihpbnRlcmZhY2UsICZrZ3NyLT5nc3JfaW50ZXJmYWNl
KSB8fAorCQkgICAgY29weV9pbl91c2VyKCZrZ3NyLT5nc3JfZ3JvdXAsICZnc3IzMi0+Z3NyX2dy
b3VwLAorCQkJCXNpemVvZihrZ3NyLT5nc3JfZ3JvdXApKSB8fAorCQkgICAgY29weV9pbl91c2Vy
KCZrZ3NyLT5nc3Jfc291cmNlLCAmZ3NyMzItPmdzcl9zb3VyY2UsCisJCQkJc2l6ZW9mKGtnc3It
Pmdzcl9zb3VyY2UpKSkKKwkJCXJldHVybiAtRUZBVUxUOworCQlrb3B0dmFsID0gKGNoYXIgX191
c2VyICopa2dzcjsKKwkJa29wdGxlbiA9IHNpemVvZihzdHJ1Y3QgZ3JvdXBfc291cmNlX3JlcSk7
CisJCWJyZWFrOworCX0KKwljYXNlIE1DQVNUX01TRklMVEVSOgorCXsKKwkJc3RydWN0IGNvbXBh
dF9ncm91cF9maWx0ZXIgX191c2VyICpnZjMyID0gKHZvaWQgKilvcHR2YWw7CisJCXN0cnVjdCBn
cm91cF9maWx0ZXIgKmtnZjsKKwkJdTMyIGludGVyZmFjZSwgZm1vZGUsIG51bXNyYzsKKworCQlp
ZiAoIWFjY2Vzc19vayhWRVJJRllfUkVBRCwgZ2YzMiwgc2l6ZW9mKCpnZjMyKSkgfHwKKwkJICAg
IF9fZ2V0X3VzZXIoaW50ZXJmYWNlLCAmZ2YzMi0+Z2ZfaW50ZXJmYWNlKSB8fAorCQkgICAgX19n
ZXRfdXNlcihmbW9kZSwgJmdmMzItPmdmX2Ztb2RlKSB8fAorCQkgICAgX19nZXRfdXNlcihudW1z
cmMsICZnZjMyLT5nZl9udW1zcmMpKQorCQkJcmV0dXJuIC1FRkFVTFQ7CisJCWtvcHRsZW4gPSBv
cHRsZW4gKyBzaXplb2Yoc3RydWN0IGdyb3VwX2ZpbHRlcikgLQorCQkJCXNpemVvZihzdHJ1Y3Qg
Y29tcGF0X2dyb3VwX2ZpbHRlcik7CisJCWlmIChrb3B0bGVuIDwgR1JPVVBfRklMVEVSX1NJWkUo
bnVtc3JjKSkKKwkJCXJldHVybiAtRUlOVkFMOworCQlrZ2YgPSBjb21wYXRfYWxsb2NfdXNlcl9z
cGFjZShrb3B0bGVuKTsKKwkJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBrZ2YsIGtvcHRs
ZW4pIHx8CisJCSAgICBfX3B1dF91c2VyKGludGVyZmFjZSwgJmtnZi0+Z2ZfaW50ZXJmYWNlKSB8
fAorCQkgICAgX19wdXRfdXNlcihmbW9kZSwgJmtnZi0+Z2ZfZm1vZGUpIHx8CisJCSAgICBfX3B1
dF91c2VyKG51bXNyYywgJmtnZi0+Z2ZfbnVtc3JjKSB8fAorCQkgICAgY29weV9pbl91c2VyKCZr
Z2YtPmdmX2dyb3VwLCAmZ2YzMi0+Z2ZfZ3JvdXAsCisJCQkJc2l6ZW9mKGtnZi0+Z2ZfZ3JvdXAp
KSB8fAorCQkgICAgKG51bXNyYyAmJiBjb3B5X2luX3VzZXIoJmtnZi0+Z2Zfc2xpc3QsICZnZjMy
LT5nZl9zbGlzdCwKKwkJCQludW1zcmMgKiBzaXplb2Yoa2dmLT5nZl9zbGlzdFswXSkpKSkKKwkJ
CXJldHVybiAtRUZBVUxUOworCQlrb3B0dmFsID0gKGNoYXIgX191c2VyICopa2dmOworCQlicmVh
azsKKwl9CisKKwlkZWZhdWx0OgorCQlicmVhazsKKwl9CisJaWYgKGxldmVsID09IFNPTF9JUFY2
KQorCQlyZXR1cm4gaXB2Nl9zZXRzb2Nrb3B0KHNvY2ssIGxldmVsLCBvcHRuYW1lLCBrb3B0dmFs
LCBrb3B0bGVuKTsKKwlyZXR1cm4gaXBfc2V0c29ja29wdChzb2NrLCBsZXZlbCwgb3B0bmFtZSwg
a29wdHZhbCwga29wdGxlbik7Cit9CisKK0VYUE9SVF9TWU1CT0woY29tcGF0X21jX3NldHNvY2tv
cHQpOworCisKIC8qIEFyZ3VtZW50IGxpc3Qgc2l6ZXMgZm9yIGNvbXBhdF9zeXNfc29ja2V0Y2Fs
bCAqLwogI2RlZmluZSBBTCh4KSAoKHgpICogc2l6ZW9mKHUzMikpCiBzdGF0aWMgdW5zaWduZWQg
Y2hhciBuYXNbMThdPXtBTCgwKSxBTCgzKSxBTCgzKSxBTCgzKSxBTCgyKSxBTCgzKSwKZGlmZiAt
cnVOcCBsaW51eC0yLjYuMTgucHBjNjQvbmV0L2lwdjQvaXBfc29ja2dsdWUuYyBsaW51eC0yLjYu
MTgucHBjNjRETFMxL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMKLS0tIGxpbnV4LTIuNi4xOC5wcGM2
NC9uZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jCTIwMDgtMDQtMjEgMTM6NTE6MDAuMDAwMDAwMDAwIC0w
NzAwCisrKyBsaW51eC0yLjYuMTgucHBjNjRETFMxL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMJMjAw
OC0wNC0yNSAwODoxNjo0MC4wMDAwMDAwMDAgLTA3MDAKQEAgLTM3LDYgKzM3LDcgQEAKICNpbmNs
dWRlIDxsaW51eC9tcm91dGUuaD4KICNpbmNsdWRlIDxuZXQvcm91dGUuaD4KICNpbmNsdWRlIDxu
ZXQveGZybS5oPgorI2luY2x1ZGUgPG5ldC9jb21wYXQuaD4KICNpZiBkZWZpbmVkKENPTkZJR19J
UFY2KSB8fCBkZWZpbmVkKENPTkZJR19JUFY2X01PRFVMRSkKICNpbmNsdWRlIDxuZXQvdHJhbnNw
X3Y2Lmg+CiAjZW5kaWYKQEAgLTkyMSw2ICs5MjIsOSBAQCBpbnQgY29tcGF0X2lwX3NldHNvY2tv
cHQoc3RydWN0IHNvY2sgKnNrCiAJaWYgKGxldmVsICE9IFNPTF9JUCkKIAkJcmV0dXJuIC1FTk9Q
Uk9UT09QVDsKIAorCWlmIChvcHRuYW1lID49IE1DQVNUX0pPSU5fR1JPVVAgJiYgb3B0bmFtZSA8
PSBNQ0FTVF9NU0ZJTFRFUikKKwkJcmV0dXJuIGNvbXBhdF9tY19zZXRzb2Nrb3B0KHNrLCBsZXZl
bCwgb3B0bmFtZSwgb3B0dmFsLCBvcHRsZW4pOworCiAJZXJyID0gZG9faXBfc2V0c29ja29wdChz
aywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZhbCwgb3B0bGVuKTsKICNpZmRlZiBDT05GSUdfTkVURklM
VEVSCiAJLyogd2UgbmVlZCB0byBleGNsdWRlIGFsbCBwb3NzaWJsZSBFTk9QUk9UT09QVHMgZXhj
ZXB0IGRlZmF1bHQgY2FzZSAqLwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4xOC5wcGM2NC9uZXQvaXB2
Ni9pcHY2X3NvY2tnbHVlLmMgbGludXgtMi42LjE4LnBwYzY0RExTMS9uZXQvaXB2Ni9pcHY2X3Nv
Y2tnbHVlLmMKLS0tIGxpbnV4LTIuNi4xOC5wcGM2NC9uZXQvaXB2Ni9pcHY2X3NvY2tnbHVlLmMJ
MjAwOC0wNC0yMSAxMzo1MTowMi4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xOC5wcGM2
NERMUzEvbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jCTIwMDgtMDQtMjUgMDU6MzQ6MDIuMDAwMDAw
MDAwIC0wNzAwCkBAIC01Miw2ICs1Miw3IEBACiAjaW5jbHVkZSA8bmV0L3RjcC5oPgogI2luY2x1
ZGUgPG5ldC91ZHAuaD4KICNpbmNsdWRlIDxuZXQveGZybS5oPgorI2luY2x1ZGUgPG5ldC9jb21w
YXQuaD4KIAogI2luY2x1ZGUgPGFzbS91YWNjZXNzLmg+CiAKQEAgLTc2OSw2ICs3NzAsOSBAQCBp
bnQgY29tcGF0X2lwdjZfc2V0c29ja29wdChzdHJ1Y3Qgc29jayAqCiAJaWYgKGxldmVsICE9IFNP
TF9JUFY2KQogCQlyZXR1cm4gLUVOT1BST1RPT1BUOwogCisJaWYgKG9wdG5hbWUgPj0gTUNBU1Rf
Sk9JTl9HUk9VUCAmJiBvcHRuYW1lIDw9IE1DQVNUX01TRklMVEVSKQorCQlyZXR1cm4gY29tcGF0
X21jX3NldHNvY2tvcHQoc2ssIGxldmVsLCBvcHRuYW1lLCBvcHR2YWwsIG9wdGxlbik7CisKIAll
cnIgPSBkb19pcHY2X3NldHNvY2tvcHQoc2ssIGxldmVsLCBvcHRuYW1lLCBvcHR2YWwsIG9wdGxl
bik7CiAjaWZkZWYgQ09ORklHX05FVEZJTFRFUgogCS8qIHdlIG5lZWQgdG8gZXhjbHVkZSBhbGwg
cG9zc2libGUgRU5PUFJPVE9PUFRzIGV4Y2VwdCBkZWZhdWx0IGNhc2UgKi8K

--=_mixed 00023C8288257437_=--
