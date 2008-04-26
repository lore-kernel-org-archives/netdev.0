From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Sat, 26 Apr 2008 17:55:44 -0600
Message-ID: <OF6237355B.2CBF6C7D-ON88257437.007F7B3D-88257437.00837003@us.ibm.com>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0083700188257437_="
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:37147 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbYDZXzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 19:55:48 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3QNtleW023175
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 19:55:47 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3QNtlLN186184
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 17:55:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3QNtk80004365
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 17:55:47 -0600
In-Reply-To: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 0083700188257437_=
Content-Type: text/plain; charset="ISO-2022-JP"

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/25/2008 
08:33:59 PM:

> __copy_in_user().
> Maybe we can use __copy_in_user for u32?

        __copy_in_user seems to be an alias for copy_from_user
(ie, user-to-kernel), which is totally different from
copy_in_user (user to user).
        It's terrible naming, but I think copy_in_user() is
what we want.

        On aligned(4) and packed, I think the net effect of
the discussion last night is to leave it alone.
        The only change in this version is to replace cross
references of the setsockopt routines with passing those as
an argument from the callers.

                                                +-DLS

Add support on 64-bit kernels for seting 32-bit compatible
MCAST* socket options.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.18.ppc64/include/net/compat.h 
linux-2.6.18.ppc64DLS2/include/net/compat.h
--- linux-2.6.18.ppc64/include/net/compat.h     2008-04-21 
13:50:33.000000000 -0700
+++ linux-2.6.18.ppc64DLS2/include/net/compat.h 2008-04-26 
04:34:04.000000000 -0700
@@ -39,4 +39,7 @@ extern int put_cmsg_compat(struct msghdr
 
 extern int cmsghdr_from_user_compat_to_kern(struct msghdr *, struct sock 
*, unsigned char *, int);
 
+extern int compat_mc_setsockopt(struct sock *, int, int, char __user *, 
int,
+       int (*)(struct sock *, int, int, char __user *, int));
+
 #endif /* NET_COMPAT_H */
diff -ruNp linux-2.6.18.ppc64/net/compat.c 
linux-2.6.18.ppc64DLS2/net/compat.c
--- linux-2.6.18.ppc64/net/compat.c     2008-04-21 13:51:02.000000000 
-0700
+++ linux-2.6.18.ppc64DLS2/net/compat.c 2008-04-26 04:35:22.000000000 
-0700
@@ -26,6 +26,8 @@
 
 #include <net/scm.h>
 #include <net/sock.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
 #include <asm/uaccess.h>
 #include <net/compat.h>
 
@@ -589,6 +591,121 @@ asmlinkage long compat_sys_getsockopt(in
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
+       char __user *optval, int optlen,
+       int (*setsockopt)(struct sock *,int,int,char __user *,int))
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
+       return setsockopt(sock, level, optname, koptval, koptlen);
+}
+
+EXPORT_SYMBOL(compat_mc_setsockopt);
+
+
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
 static unsigned char nas[18]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
diff -ruNp linux-2.6.18.ppc64/net/ipv4/ip_sockglue.c 
linux-2.6.18.ppc64DLS2/net/ipv4/ip_sockglue.c
--- linux-2.6.18.ppc64/net/ipv4/ip_sockglue.c   2008-04-21 
13:51:00.000000000 -0700
+++ linux-2.6.18.ppc64DLS2/net/ipv4/ip_sockglue.c       2008-04-26 
04:36:24.000000000 -0700
@@ -37,6 +37,7 @@
 #include <linux/mroute.h>
 #include <net/route.h>
 #include <net/xfrm.h>
+#include <net/compat.h>
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <net/transp_v6.h>
 #endif
@@ -921,6 +922,10 @@ int compat_ip_setsockopt(struct sock *sk
        if (level != SOL_IP)
                return -ENOPROTOOPT;
 
+       if (optname >= MCAST_JOIN_GROUP && optname <= MCAST_MSFILTER)
+               return compat_mc_setsockopt(sk, level, optname, optval, 
optlen,
+                       ip_setsockopt);
+
        err = do_ip_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible ENOPROTOOPTs except default 
case */
diff -ruNp linux-2.6.18.ppc64/net/ipv6/ipv6_sockglue.c 
linux-2.6.18.ppc64DLS2/net/ipv6/ipv6_sockglue.c
--- linux-2.6.18.ppc64/net/ipv6/ipv6_sockglue.c 2008-04-21 
13:51:02.000000000 -0700
+++ linux-2.6.18.ppc64DLS2/net/ipv6/ipv6_sockglue.c     2008-04-26 
04:35:19.000000000 -0700
@@ -52,6 +52,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/xfrm.h>
+#include <net/compat.h>
 
 #include <asm/uaccess.h>
 
@@ -769,6 +770,10 @@ int compat_ipv6_setsockopt(struct sock *
        if (level != SOL_IPV6)
                return -ENOPROTOOPT;
 
+       if (optname >= MCAST_JOIN_GROUP && optname <= MCAST_MSFILTER)
+               return compat_mc_setsockopt(sk, level, optname, optval, 
optlen,
+                       ipv6_setsockopt);
+
        err = do_ipv6_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible ENOPROTOOPTs except default 
case */


--=_mixed 0083700188257437_=
Content-Type: application/octet-stream; name="setsockopt3.patch"
Content-Disposition: attachment; filename="setsockopt3.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTgucHBjNjQvaW5jbHVkZS9uZXQvY29tcGF0LmggbGludXgt
Mi42LjE4LnBwYzY0RExTMi9pbmNsdWRlL25ldC9jb21wYXQuaAotLS0gbGludXgtMi42LjE4LnBw
YzY0L2luY2x1ZGUvbmV0L2NvbXBhdC5oCTIwMDgtMDQtMjEgMTM6NTA6MzMuMDAwMDAwMDAwIC0w
NzAwCisrKyBsaW51eC0yLjYuMTgucHBjNjRETFMyL2luY2x1ZGUvbmV0L2NvbXBhdC5oCTIwMDgt
MDQtMjYgMDQ6MzQ6MDQuMDAwMDAwMDAwIC0wNzAwCkBAIC0zOSw0ICszOSw3IEBAIGV4dGVybiBp
bnQgcHV0X2Ntc2dfY29tcGF0KHN0cnVjdCBtc2doZHIKIAogZXh0ZXJuIGludCBjbXNnaGRyX2Zy
b21fdXNlcl9jb21wYXRfdG9fa2VybihzdHJ1Y3QgbXNnaGRyICosIHN0cnVjdCBzb2NrICosIHVu
c2lnbmVkIGNoYXIgKiwgaW50KTsKIAorZXh0ZXJuIGludCBjb21wYXRfbWNfc2V0c29ja29wdChz
dHJ1Y3Qgc29jayAqLCBpbnQsIGludCwgY2hhciBfX3VzZXIgKiwgaW50LAorCWludCAoKikoc3Ry
dWN0IHNvY2sgKiwgaW50LCBpbnQsIGNoYXIgX191c2VyICosIGludCkpOworCiAjZW5kaWYgLyog
TkVUX0NPTVBBVF9IICovCmRpZmYgLXJ1TnAgbGludXgtMi42LjE4LnBwYzY0L25ldC9jb21wYXQu
YyBsaW51eC0yLjYuMTgucHBjNjRETFMyL25ldC9jb21wYXQuYwotLS0gbGludXgtMi42LjE4LnBw
YzY0L25ldC9jb21wYXQuYwkyMDA4LTA0LTIxIDEzOjUxOjAyLjAwMDAwMDAwMCAtMDcwMAorKysg
bGludXgtMi42LjE4LnBwYzY0RExTMi9uZXQvY29tcGF0LmMJMjAwOC0wNC0yNiAwNDozNToyMi4w
MDAwMDAwMDAgLTA3MDAKQEAgLTI2LDYgKzI2LDggQEAKIAogI2luY2x1ZGUgPG5ldC9zY20uaD4K
ICNpbmNsdWRlIDxuZXQvc29jay5oPgorI2luY2x1ZGUgPG5ldC9pcC5oPgorI2luY2x1ZGUgPG5l
dC9pcHY2Lmg+CiAjaW5jbHVkZSA8YXNtL3VhY2Nlc3MuaD4KICNpbmNsdWRlIDxuZXQvY29tcGF0
Lmg+CiAKQEAgLTU4OSw2ICs1OTEsMTIxIEBAIGFzbWxpbmthZ2UgbG9uZyBjb21wYXRfc3lzX2dl
dHNvY2tvcHQoaW4KIAl9CiAJcmV0dXJuIGVycjsKIH0KKworc3RydWN0IGNvbXBhdF9ncm91cF9y
ZXEgeworCV9fdTMyCQkJCSBncl9pbnRlcmZhY2U7CisJc3RydWN0IF9fa2VybmVsX3NvY2thZGRy
X3N0b3JhZ2UgZ3JfZ3JvdXAKKwkJX19hdHRyaWJ1dGVfXyAoKGFsaWduZWQoNCkpKTsKK30gX19h
dHRyaWJ1dGVfXyAoKHBhY2tlZCkpOworCitzdHJ1Y3QgY29tcGF0X2dyb3VwX3NvdXJjZV9yZXEg
eworCV9fdTMyCQkJCSBnc3JfaW50ZXJmYWNlOworCXN0cnVjdCBfX2tlcm5lbF9zb2NrYWRkcl9z
dG9yYWdlIGdzcl9ncm91cAorCQlfX2F0dHJpYnV0ZV9fICgoYWxpZ25lZCg0KSkpOworCXN0cnVj
dCBfX2tlcm5lbF9zb2NrYWRkcl9zdG9yYWdlIGdzcl9zb3VyY2UKKwkJX19hdHRyaWJ1dGVfXyAo
KGFsaWduZWQoNCkpKTsKK30gX19hdHRyaWJ1dGVfXyAoKHBhY2tlZCkpOworCitzdHJ1Y3QgY29t
cGF0X2dyb3VwX2ZpbHRlciB7CisJX191MzIJCQkJIGdmX2ludGVyZmFjZTsKKwlzdHJ1Y3QgX19r
ZXJuZWxfc29ja2FkZHJfc3RvcmFnZSBnZl9ncm91cAorCQlfX2F0dHJpYnV0ZV9fICgoYWxpZ25l
ZCg0KSkpOworCV9fdTMyCQkJCSBnZl9mbW9kZTsKKwlfX3UzMgkJCQkgZ2ZfbnVtc3JjOworCXN0
cnVjdCBfX2tlcm5lbF9zb2NrYWRkcl9zdG9yYWdlIGdmX3NsaXN0WzFdCisJCV9fYXR0cmlidXRl
X18gKChhbGlnbmVkKDQpKSk7Cit9IF9fYXR0cmlidXRlX18gKChwYWNrZWQpKTsKKworCitpbnQg
Y29tcGF0X21jX3NldHNvY2tvcHQoc3RydWN0IHNvY2sgKnNvY2ssIGludCBsZXZlbCwgaW50IG9w
dG5hbWUsCisJY2hhciBfX3VzZXIgKm9wdHZhbCwgaW50IG9wdGxlbiwKKwlpbnQgKCpzZXRzb2Nr
b3B0KShzdHJ1Y3Qgc29jayAqLGludCxpbnQsY2hhciBfX3VzZXIgKixpbnQpKQoreworCWNoYXIg
X191c2VyCSprb3B0dmFsID0gb3B0dmFsOworCWludAkJa29wdGxlbiA9IG9wdGxlbjsKKworCXN3
aXRjaCAob3B0bmFtZSkgeworCWNhc2UgTUNBU1RfSk9JTl9HUk9VUDoKKwljYXNlIE1DQVNUX0xF
QVZFX0dST1VQOgorCXsKKwkJc3RydWN0IGNvbXBhdF9ncm91cF9yZXEgX191c2VyICpncjMyID0g
KHZvaWQgKilvcHR2YWw7CisJCXN0cnVjdCBncm91cF9yZXEgX191c2VyICprZ3IgPQorCQkJY29t
cGF0X2FsbG9jX3VzZXJfc3BhY2Uoc2l6ZW9mKHN0cnVjdCBncm91cF9yZXEpKTsKKwkJdTMyIGlu
dGVyZmFjZTsKKworCQlpZiAoIWFjY2Vzc19vayhWRVJJRllfUkVBRCwgZ3IzMiwgc2l6ZW9mKCpn
cjMyKSkgfHwKKwkJICAgICFhY2Nlc3Nfb2soVkVSSUZZX1dSSVRFLCBrZ3IsIHNpemVvZihzdHJ1
Y3QgZ3JvdXBfcmVxKSkgfHwKKwkJICAgIF9fZ2V0X3VzZXIoaW50ZXJmYWNlLCAmZ3IzMi0+Z3Jf
aW50ZXJmYWNlKSB8fAorCQkgICAgX19wdXRfdXNlcihpbnRlcmZhY2UsICZrZ3ItPmdyX2ludGVy
ZmFjZSkgfHwKKwkJICAgIGNvcHlfaW5fdXNlcigma2dyLT5ncl9ncm91cCwgJmdyMzItPmdyX2dy
b3VwLAorCQkJCXNpemVvZihrZ3ItPmdyX2dyb3VwKSkpCisJCQlyZXR1cm4gLUVGQVVMVDsKKwkJ
a29wdHZhbCA9IChjaGFyIF9fdXNlciAqKWtncjsKKwkJa29wdGxlbiA9IHNpemVvZihzdHJ1Y3Qg
Z3JvdXBfcmVxKTsKKwkJYnJlYWs7CisJfQorCWNhc2UgTUNBU1RfSk9JTl9TT1VSQ0VfR1JPVVA6
CisJY2FzZSBNQ0FTVF9MRUFWRV9TT1VSQ0VfR1JPVVA6CisJY2FzZSBNQ0FTVF9CTE9DS19TT1VS
Q0U6CisJY2FzZSBNQ0FTVF9VTkJMT0NLX1NPVVJDRToKKwl7CisJCXN0cnVjdCBjb21wYXRfZ3Jv
dXBfc291cmNlX3JlcSBfX3VzZXIgKmdzcjMyID0gKHZvaWQgKilvcHR2YWw7CisJCXN0cnVjdCBn
cm91cF9zb3VyY2VfcmVxICprZ3NyID0gY29tcGF0X2FsbG9jX3VzZXJfc3BhY2UoCisJCQlzaXpl
b2Yoc3RydWN0IGdyb3VwX3NvdXJjZV9yZXEpKTsKKwkJdTMyIGludGVyZmFjZTsKKworCQlpZiAo
IWFjY2Vzc19vayhWRVJJRllfUkVBRCwgZ3NyMzIsIHNpemVvZigqZ3NyMzIpKSB8fAorCQkgICAg
IWFjY2Vzc19vayhWRVJJRllfV1JJVEUsIGtnc3IsCisJCQlzaXplb2Yoc3RydWN0IGdyb3VwX3Nv
dXJjZV9yZXEpKSB8fAorCQkgICAgX19nZXRfdXNlcihpbnRlcmZhY2UsICZnc3IzMi0+Z3NyX2lu
dGVyZmFjZSkgfHwKKwkJICAgIF9fcHV0X3VzZXIoaW50ZXJmYWNlLCAma2dzci0+Z3NyX2ludGVy
ZmFjZSkgfHwKKwkJICAgIGNvcHlfaW5fdXNlcigma2dzci0+Z3NyX2dyb3VwLCAmZ3NyMzItPmdz
cl9ncm91cCwKKwkJCQlzaXplb2Yoa2dzci0+Z3NyX2dyb3VwKSkgfHwKKwkJICAgIGNvcHlfaW5f
dXNlcigma2dzci0+Z3NyX3NvdXJjZSwgJmdzcjMyLT5nc3Jfc291cmNlLAorCQkJCXNpemVvZihr
Z3NyLT5nc3Jfc291cmNlKSkpCisJCQlyZXR1cm4gLUVGQVVMVDsKKwkJa29wdHZhbCA9IChjaGFy
IF9fdXNlciAqKWtnc3I7CisJCWtvcHRsZW4gPSBzaXplb2Yoc3RydWN0IGdyb3VwX3NvdXJjZV9y
ZXEpOworCQlicmVhazsKKwl9CisJY2FzZSBNQ0FTVF9NU0ZJTFRFUjoKKwl7CisJCXN0cnVjdCBj
b21wYXRfZ3JvdXBfZmlsdGVyIF9fdXNlciAqZ2YzMiA9ICh2b2lkICopb3B0dmFsOworCQlzdHJ1
Y3QgZ3JvdXBfZmlsdGVyICprZ2Y7CisJCXUzMiBpbnRlcmZhY2UsIGZtb2RlLCBudW1zcmM7CisK
KwkJaWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1JFQUQsIGdmMzIsIHNpemVvZigqZ2YzMikpIHx8CisJ
CSAgICBfX2dldF91c2VyKGludGVyZmFjZSwgJmdmMzItPmdmX2ludGVyZmFjZSkgfHwKKwkJICAg
IF9fZ2V0X3VzZXIoZm1vZGUsICZnZjMyLT5nZl9mbW9kZSkgfHwKKwkJICAgIF9fZ2V0X3VzZXIo
bnVtc3JjLCAmZ2YzMi0+Z2ZfbnVtc3JjKSkKKwkJCXJldHVybiAtRUZBVUxUOworCQlrb3B0bGVu
ID0gb3B0bGVuICsgc2l6ZW9mKHN0cnVjdCBncm91cF9maWx0ZXIpIC0KKwkJCQlzaXplb2Yoc3Ry
dWN0IGNvbXBhdF9ncm91cF9maWx0ZXIpOworCQlpZiAoa29wdGxlbiA8IEdST1VQX0ZJTFRFUl9T
SVpFKG51bXNyYykpCisJCQlyZXR1cm4gLUVJTlZBTDsKKwkJa2dmID0gY29tcGF0X2FsbG9jX3Vz
ZXJfc3BhY2Uoa29wdGxlbik7CisJCWlmICghYWNjZXNzX29rKFZFUklGWV9XUklURSwga2dmLCBr
b3B0bGVuKSB8fAorCQkgICAgX19wdXRfdXNlcihpbnRlcmZhY2UsICZrZ2YtPmdmX2ludGVyZmFj
ZSkgfHwKKwkJICAgIF9fcHV0X3VzZXIoZm1vZGUsICZrZ2YtPmdmX2Ztb2RlKSB8fAorCQkgICAg
X19wdXRfdXNlcihudW1zcmMsICZrZ2YtPmdmX251bXNyYykgfHwKKwkJICAgIGNvcHlfaW5fdXNl
cigma2dmLT5nZl9ncm91cCwgJmdmMzItPmdmX2dyb3VwLAorCQkJCXNpemVvZihrZ2YtPmdmX2dy
b3VwKSkgfHwKKwkJICAgIChudW1zcmMgJiYgY29weV9pbl91c2VyKCZrZ2YtPmdmX3NsaXN0LCAm
Z2YzMi0+Z2Zfc2xpc3QsCisJCQkJbnVtc3JjICogc2l6ZW9mKGtnZi0+Z2Zfc2xpc3RbMF0pKSkp
CisJCQlyZXR1cm4gLUVGQVVMVDsKKwkJa29wdHZhbCA9IChjaGFyIF9fdXNlciAqKWtnZjsKKwkJ
YnJlYWs7CisJfQorCisJZGVmYXVsdDoKKwkJYnJlYWs7CisJfQorCXJldHVybiBzZXRzb2Nrb3B0
KHNvY2ssIGxldmVsLCBvcHRuYW1lLCBrb3B0dmFsLCBrb3B0bGVuKTsKK30KKworRVhQT1JUX1NZ
TUJPTChjb21wYXRfbWNfc2V0c29ja29wdCk7CisKKwogLyogQXJndW1lbnQgbGlzdCBzaXplcyBm
b3IgY29tcGF0X3N5c19zb2NrZXRjYWxsICovCiAjZGVmaW5lIEFMKHgpICgoeCkgKiBzaXplb2Yo
dTMyKSkKIHN0YXRpYyB1bnNpZ25lZCBjaGFyIG5hc1sxOF09e0FMKDApLEFMKDMpLEFMKDMpLEFM
KDMpLEFMKDIpLEFMKDMpLApkaWZmIC1ydU5wIGxpbnV4LTIuNi4xOC5wcGM2NC9uZXQvaXB2NC9p
cF9zb2NrZ2x1ZS5jIGxpbnV4LTIuNi4xOC5wcGM2NERMUzIvbmV0L2lwdjQvaXBfc29ja2dsdWUu
YwotLS0gbGludXgtMi42LjE4LnBwYzY0L25ldC9pcHY0L2lwX3NvY2tnbHVlLmMJMjAwOC0wNC0y
MSAxMzo1MTowMC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xOC5wcGM2NERMUzIvbmV0
L2lwdjQvaXBfc29ja2dsdWUuYwkyMDA4LTA0LTI2IDA0OjM2OjI0LjAwMDAwMDAwMCAtMDcwMApA
QCAtMzcsNiArMzcsNyBAQAogI2luY2x1ZGUgPGxpbnV4L21yb3V0ZS5oPgogI2luY2x1ZGUgPG5l
dC9yb3V0ZS5oPgogI2luY2x1ZGUgPG5ldC94ZnJtLmg+CisjaW5jbHVkZSA8bmV0L2NvbXBhdC5o
PgogI2lmIGRlZmluZWQoQ09ORklHX0lQVjYpIHx8IGRlZmluZWQoQ09ORklHX0lQVjZfTU9EVUxF
KQogI2luY2x1ZGUgPG5ldC90cmFuc3BfdjYuaD4KICNlbmRpZgpAQCAtOTIxLDYgKzkyMiwxMCBA
QCBpbnQgY29tcGF0X2lwX3NldHNvY2tvcHQoc3RydWN0IHNvY2sgKnNrCiAJaWYgKGxldmVsICE9
IFNPTF9JUCkKIAkJcmV0dXJuIC1FTk9QUk9UT09QVDsKIAorCWlmIChvcHRuYW1lID49IE1DQVNU
X0pPSU5fR1JPVVAgJiYgb3B0bmFtZSA8PSBNQ0FTVF9NU0ZJTFRFUikKKwkJcmV0dXJuIGNvbXBh
dF9tY19zZXRzb2Nrb3B0KHNrLCBsZXZlbCwgb3B0bmFtZSwgb3B0dmFsLCBvcHRsZW4sCisJCQlp
cF9zZXRzb2Nrb3B0KTsKKwogCWVyciA9IGRvX2lwX3NldHNvY2tvcHQoc2ssIGxldmVsLCBvcHRu
YW1lLCBvcHR2YWwsIG9wdGxlbik7CiAjaWZkZWYgQ09ORklHX05FVEZJTFRFUgogCS8qIHdlIG5l
ZWQgdG8gZXhjbHVkZSBhbGwgcG9zc2libGUgRU5PUFJPVE9PUFRzIGV4Y2VwdCBkZWZhdWx0IGNh
c2UgKi8KZGlmZiAtcnVOcCBsaW51eC0yLjYuMTgucHBjNjQvbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1
ZS5jIGxpbnV4LTIuNi4xOC5wcGM2NERMUzIvbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jCi0tLSBs
aW51eC0yLjYuMTgucHBjNjQvbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jCTIwMDgtMDQtMjEgMTM6
NTE6MDIuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTgucHBjNjRETFMyL25ldC9pcHY2
L2lwdjZfc29ja2dsdWUuYwkyMDA4LTA0LTI2IDA0OjM1OjE5LjAwMDAwMDAwMCAtMDcwMApAQCAt
NTIsNiArNTIsNyBAQAogI2luY2x1ZGUgPG5ldC90Y3AuaD4KICNpbmNsdWRlIDxuZXQvdWRwLmg+
CiAjaW5jbHVkZSA8bmV0L3hmcm0uaD4KKyNpbmNsdWRlIDxuZXQvY29tcGF0Lmg+CiAKICNpbmNs
dWRlIDxhc20vdWFjY2Vzcy5oPgogCkBAIC03NjksNiArNzcwLDEwIEBAIGludCBjb21wYXRfaXB2
Nl9zZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICoKIAlpZiAobGV2ZWwgIT0gU09MX0lQVjYpCiAJCXJl
dHVybiAtRU5PUFJPVE9PUFQ7CiAKKwlpZiAob3B0bmFtZSA+PSBNQ0FTVF9KT0lOX0dST1VQICYm
IG9wdG5hbWUgPD0gTUNBU1RfTVNGSUxURVIpCisJCXJldHVybiBjb21wYXRfbWNfc2V0c29ja29w
dChzaywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZhbCwgb3B0bGVuLAorCQkJaXB2Nl9zZXRzb2Nrb3B0
KTsKKwogCWVyciA9IGRvX2lwdjZfc2V0c29ja29wdChzaywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZh
bCwgb3B0bGVuKTsKICNpZmRlZiBDT05GSUdfTkVURklMVEVSCiAJLyogd2UgbmVlZCB0byBleGNs
dWRlIGFsbCBwb3NzaWJsZSBFTk9QUk9UT09QVHMgZXhjZXB0IGRlZmF1bHQgY2FzZSAqLwo=

--=_mixed 0083700188257437_=--
