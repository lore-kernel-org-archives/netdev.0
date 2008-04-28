From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] add compat support for getsockopt (MCAST_MSFILTER)
Date: Sun, 27 Apr 2008 23:41:51 -0600
Message-ID: <OFCC2BF571.D815BBAC-ON88257439.001DC6D6-88257439.001F49AD@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 001F49AA88257439_="
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:35369 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbYD1Fl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 01:41:57 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3S5fuSO017230
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 01:41:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3S5fuwk125622
	for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 23:41:56 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3S5fsaI029497
	for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 23:41:54 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_mixed 001F49AA88257439_=
Content-Type: text/plain; charset="US-ASCII"

This patch adds support for getsockopt for MCAST_MSFILTER for
both IPv4 and IPv6. It depends on the previous setsockopt patch,
and uses the same method. In addition, there are these cleanups
included for the setsockopt patch:

1) added missing "__user" for kgsr and kgf pointers
2) verify read for only GROUP_FILTER_SIZE(0). The group_filter
        structure definition (via RFC) includes space for one source
        in the source list array, but that source need not be present.
        So, sizeof(group_filter) > GROUP_FILTER_SIZE(0). Fixed
        the user read-check for minimum length to use the smaller size.
3) remove unneeded "&" for gf_slist addresses

[in-line for viewing, attached for applying]

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.18.ppc64DLS2/include/net/compat.h 
linux-2.6.18.ppc64GSO/include/net/compat.h
--- linux-2.6.18.ppc64DLS2/include/net/compat.h 2008-04-26 
04:34:04.000000000 -0700
+++ linux-2.6.18.ppc64GSO/include/net/compat.h  2008-04-27 
08:08:53.000000000 -0700
@@ -41,5 +41,8 @@ extern int cmsghdr_from_user_compat_to_k
 
 extern int compat_mc_setsockopt(struct sock *, int, int, char __user *, 
int,
        int (*)(struct sock *, int, int, char __user *, int));
+extern int compat_mc_getsockopt(struct sock *, int, int, char __user *, 
+       int __user *, int (*)(struct sock *, int, int, char __user *,
+                               int __user *));
 
 #endif /* NET_COMPAT_H */
diff -ruNp linux-2.6.18.ppc64DLS2/net/compat.c 
linux-2.6.18.ppc64GSO/net/compat.c
--- linux-2.6.18.ppc64DLS2/net/compat.c 2008-04-26 04:35:22.000000000 
-0700
+++ linux-2.6.18.ppc64GSO/net/compat.c  2008-04-27 13:55:40.000000000 
-0700
@@ -616,6 +616,9 @@ struct compat_group_filter {
                __attribute__ ((aligned(4)));
 } __attribute__ ((packed));
 
+#define __COMPAT_GF0_SIZE (sizeof(struct compat_group_filter) - \
+                       sizeof(struct __kernel_sockaddr_storage))
+
 
 int compat_mc_setsockopt(struct sock *sock, int level, int optname,
        char __user *optval, int optlen,
@@ -650,7 +653,7 @@ int compat_mc_setsockopt(struct sock *so
        case MCAST_UNBLOCK_SOURCE:
        {
                struct compat_group_source_req __user *gsr32 = (void 
*)optval;
-               struct group_source_req *kgsr = compat_alloc_user_space(
+               struct group_source_req __user *kgsr = 
compat_alloc_user_space(
                        sizeof(struct group_source_req));
                u32 interface;
 
@@ -671,10 +674,10 @@ int compat_mc_setsockopt(struct sock *so
        case MCAST_MSFILTER:
        {
                struct compat_group_filter __user *gf32 = (void *)optval;
-               struct group_filter *kgf;
+               struct group_filter __user *kgf;
                u32 interface, fmode, numsrc;
 
-               if (!access_ok(VERIFY_READ, gf32, sizeof(*gf32)) ||
+               if (!access_ok(VERIFY_READ, gf32, __COMPAT_GF0_SIZE) ||
                    __get_user(interface, &gf32->gf_interface) ||
                    __get_user(fmode, &gf32->gf_fmode) ||
                    __get_user(numsrc, &gf32->gf_numsrc))
@@ -690,7 +693,7 @@ int compat_mc_setsockopt(struct sock *so
                    __put_user(numsrc, &kgf->gf_numsrc) ||
                    copy_in_user(&kgf->gf_group, &gf32->gf_group,
                                sizeof(kgf->gf_group)) ||
-                   (numsrc && copy_in_user(&kgf->gf_slist, 
&gf32->gf_slist,
+                   (numsrc && copy_in_user(kgf->gf_slist, gf32->gf_slist,
                                numsrc * sizeof(kgf->gf_slist[0]))))
                        return -EFAULT;
                koptval = (char __user *)kgf;
@@ -705,6 +708,85 @@ int compat_mc_setsockopt(struct sock *so
 
 EXPORT_SYMBOL(compat_mc_setsockopt);
 
+int compat_mc_getsockopt(struct sock *sock, int level, int optname,
+       char __user *optval, int __user *optlen,
+       int (*getsockopt)(struct sock *,int,int,char __user *,int __user 
*))
+{
+       struct compat_group_filter __user *gf32 = (void *)optval;
+       struct group_filter __user *kgf;
+       int __user      *koptlen;
+       u32 interface, fmode, numsrc;
+       int klen, ulen, err;
+
+       if (optname != MCAST_MSFILTER)
+               return getsockopt(sock, level, optname, optval, optlen);
+
+       koptlen = compat_alloc_user_space(sizeof(*koptlen));
+       if (!access_ok(VERIFY_READ, optlen, sizeof(*optlen)) ||
+           __get_user(ulen, optlen))
+               return -EFAULT;
+
+       /* adjust len for pad */
+       klen = ulen + sizeof(*kgf) - sizeof(*gf32);
+
+       if (klen < GROUP_FILTER_SIZE(0))
+               return -EINVAL;
+
+       if (!access_ok(VERIFY_WRITE, koptlen, sizeof(*koptlen)) ||
+           __put_user(klen, koptlen))
+               return -EFAULT;
+
+       /* have to allow space for previous compat_alloc_user_space, too 
*/
+       kgf = compat_alloc_user_space(klen+sizeof(*optlen));
+
+       if (!access_ok(VERIFY_READ, gf32, __COMPAT_GF0_SIZE) ||
+           __get_user(interface, &gf32->gf_interface) ||
+           __get_user(fmode, &gf32->gf_fmode) ||
+           __get_user(numsrc, &gf32->gf_numsrc) ||
+           __put_user(interface, &kgf->gf_interface) ||
+           __put_user(fmode, &kgf->gf_fmode) ||
+           __put_user(numsrc, &kgf->gf_numsrc) ||
+ copy_in_user(&kgf->gf_group,&gf32->gf_group,sizeof(kgf->gf_group)))
+               return -EFAULT;
+
+       err = getsockopt(sock, level, optname, (char __user *)kgf, 
koptlen);
+       if (err)
+               return err;
+
+       if (!access_ok(VERIFY_READ, koptlen, sizeof(*koptlen)) ||
+           __get_user(klen, koptlen))
+               return -EFAULT;
+
+       ulen = klen - (sizeof(*kgf)-sizeof(*gf32));
+
+       if (!access_ok(VERIFY_WRITE, optlen, sizeof(*optlen)) ||
+           __put_user(ulen, optlen))
+               return -EFAULT;
+
+       if (!access_ok(VERIFY_READ, kgf, klen) ||
+           !access_ok(VERIFY_WRITE, gf32, ulen) ||
+           __get_user(interface, &kgf->gf_interface) ||
+           __get_user(fmode, &kgf->gf_fmode) ||
+           __get_user(numsrc, &kgf->gf_numsrc) ||
+           __put_user(interface, &gf32->gf_interface) ||
+           __put_user(fmode, &gf32->gf_fmode) ||
+           __put_user(numsrc, &gf32->gf_numsrc))
+               return -EFAULT;
+       if (numsrc) {
+               int copylen;
+
+               klen -= GROUP_FILTER_SIZE(0);
+               copylen = numsrc * sizeof(gf32->gf_slist[0]);
+               if (copylen > klen)
+                       copylen = klen;
+               if (copy_in_user(gf32->gf_slist, kgf->gf_slist, copylen))
+                       return -EFAULT;
+       }
+       return err;
+}
+
+EXPORT_SYMBOL(compat_mc_getsockopt);
+
 
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
diff -ruNp linux-2.6.18.ppc64DLS2/net/ipv4/ip_sockglue.c 
linux-2.6.18.ppc64GSO/net/ipv4/ip_sockglue.c
--- linux-2.6.18.ppc64DLS2/net/ipv4/ip_sockglue.c       2008-04-26 
04:36:24.000000000 -0700
+++ linux-2.6.18.ppc64GSO/net/ipv4/ip_sockglue.c        2008-04-27 
11:24:48.000000000 -0700
@@ -1193,7 +1193,14 @@ int ip_getsockopt(struct sock *sk, int l
 int compat_ip_getsockopt(struct sock *sk, int level, int optname,
                         char __user *optval, int __user *optlen)
 {
-       int err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+       int err;
+
+       if (optname == MCAST_MSFILTER)
+               return compat_mc_getsockopt(sk, level, optname, optval, 
optlen,
+                       ip_getsockopt);
+
+       err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible ENOPROTOOPTs except default 
case */
        if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS
diff -ruNp linux-2.6.18.ppc64DLS2/net/ipv6/ipv6_sockglue.c 
linux-2.6.18.ppc64GSO/net/ipv6/ipv6_sockglue.c
--- linux-2.6.18.ppc64DLS2/net/ipv6/ipv6_sockglue.c     2008-04-26 
04:35:19.000000000 -0700
+++ linux-2.6.18.ppc64GSO/net/ipv6/ipv6_sockglue.c      2008-04-27 
13:56:27.000000000 -0700
@@ -1062,6 +1062,10 @@ int compat_ipv6_getsockopt(struct sock *
        if (level != SOL_IPV6)
                return -ENOPROTOOPT;
 
+       if (optname == MCAST_MSFILTER)
+               return compat_mc_getsockopt(sk, level, optname, optval, 
optlen,
+                       ipv6_getsockopt);
+
        err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
        /* we need to exclude all possible EINVALs except default case */



--=_mixed 001F49AA88257439_=
Content-Type: application/octet-stream; name="getsockopt.patch"
Content-Disposition: attachment; filename="getsockopt.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMTgucHBjNjRETFMyL2luY2x1ZGUvbmV0L2NvbXBhdC5oIGxp
bnV4LTIuNi4xOC5wcGM2NEdTTy9pbmNsdWRlL25ldC9jb21wYXQuaAotLS0gbGludXgtMi42LjE4
LnBwYzY0RExTMi9pbmNsdWRlL25ldC9jb21wYXQuaAkyMDA4LTA0LTI2IDA0OjM0OjA0LjAwMDAw
MDAwMCAtMDcwMAorKysgbGludXgtMi42LjE4LnBwYzY0R1NPL2luY2x1ZGUvbmV0L2NvbXBhdC5o
CTIwMDgtMDQtMjcgMDg6MDg6NTMuMDAwMDAwMDAwIC0wNzAwCkBAIC00MSw1ICs0MSw4IEBAIGV4
dGVybiBpbnQgY21zZ2hkcl9mcm9tX3VzZXJfY29tcGF0X3RvX2sKIAogZXh0ZXJuIGludCBjb21w
YXRfbWNfc2V0c29ja29wdChzdHJ1Y3Qgc29jayAqLCBpbnQsIGludCwgY2hhciBfX3VzZXIgKiwg
aW50LAogCWludCAoKikoc3RydWN0IHNvY2sgKiwgaW50LCBpbnQsIGNoYXIgX191c2VyICosIGlu
dCkpOworZXh0ZXJuIGludCBjb21wYXRfbWNfZ2V0c29ja29wdChzdHJ1Y3Qgc29jayAqLCBpbnQs
IGludCwgY2hhciBfX3VzZXIgKiwgCisJaW50IF9fdXNlciAqLCBpbnQgKCopKHN0cnVjdCBzb2Nr
ICosIGludCwgaW50LCBjaGFyIF9fdXNlciAqLAorCQkJCWludCBfX3VzZXIgKikpOwogCiAjZW5k
aWYgLyogTkVUX0NPTVBBVF9IICovCmRpZmYgLXJ1TnAgbGludXgtMi42LjE4LnBwYzY0RExTMi9u
ZXQvY29tcGF0LmMgbGludXgtMi42LjE4LnBwYzY0R1NPL25ldC9jb21wYXQuYwotLS0gbGludXgt
Mi42LjE4LnBwYzY0RExTMi9uZXQvY29tcGF0LmMJMjAwOC0wNC0yNiAwNDozNToyMi4wMDAwMDAw
MDAgLTA3MDAKKysrIGxpbnV4LTIuNi4xOC5wcGM2NEdTTy9uZXQvY29tcGF0LmMJMjAwOC0wNC0y
NyAxMzo1NTo0MC4wMDAwMDAwMDAgLTA3MDAKQEAgLTYxNiw2ICs2MTYsOSBAQCBzdHJ1Y3QgY29t
cGF0X2dyb3VwX2ZpbHRlciB7CiAJCV9fYXR0cmlidXRlX18gKChhbGlnbmVkKDQpKSk7CiB9IF9f
YXR0cmlidXRlX18gKChwYWNrZWQpKTsKIAorI2RlZmluZSBfX0NPTVBBVF9HRjBfU0laRSAoc2l6
ZW9mKHN0cnVjdCBjb21wYXRfZ3JvdXBfZmlsdGVyKSAtIFwKKwkJCXNpemVvZihzdHJ1Y3QgX19r
ZXJuZWxfc29ja2FkZHJfc3RvcmFnZSkpCisKIAogaW50IGNvbXBhdF9tY19zZXRzb2Nrb3B0KHN0
cnVjdCBzb2NrICpzb2NrLCBpbnQgbGV2ZWwsIGludCBvcHRuYW1lLAogCWNoYXIgX191c2VyICpv
cHR2YWwsIGludCBvcHRsZW4sCkBAIC02NTAsNyArNjUzLDcgQEAgaW50IGNvbXBhdF9tY19zZXRz
b2Nrb3B0KHN0cnVjdCBzb2NrICpzbwogCWNhc2UgTUNBU1RfVU5CTE9DS19TT1VSQ0U6CiAJewog
CQlzdHJ1Y3QgY29tcGF0X2dyb3VwX3NvdXJjZV9yZXEgX191c2VyICpnc3IzMiA9ICh2b2lkICop
b3B0dmFsOwotCQlzdHJ1Y3QgZ3JvdXBfc291cmNlX3JlcSAqa2dzciA9IGNvbXBhdF9hbGxvY191
c2VyX3NwYWNlKAorCQlzdHJ1Y3QgZ3JvdXBfc291cmNlX3JlcSBfX3VzZXIgKmtnc3IgPSBjb21w
YXRfYWxsb2NfdXNlcl9zcGFjZSgKIAkJCXNpemVvZihzdHJ1Y3QgZ3JvdXBfc291cmNlX3JlcSkp
OwogCQl1MzIgaW50ZXJmYWNlOwogCkBAIC02NzEsMTAgKzY3NCwxMCBAQCBpbnQgY29tcGF0X21j
X3NldHNvY2tvcHQoc3RydWN0IHNvY2sgKnNvCiAJY2FzZSBNQ0FTVF9NU0ZJTFRFUjoKIAl7CiAJ
CXN0cnVjdCBjb21wYXRfZ3JvdXBfZmlsdGVyIF9fdXNlciAqZ2YzMiA9ICh2b2lkICopb3B0dmFs
OwotCQlzdHJ1Y3QgZ3JvdXBfZmlsdGVyICprZ2Y7CisJCXN0cnVjdCBncm91cF9maWx0ZXIgX191
c2VyICprZ2Y7CiAJCXUzMiBpbnRlcmZhY2UsIGZtb2RlLCBudW1zcmM7CiAKLQkJaWYgKCFhY2Nl
c3Nfb2soVkVSSUZZX1JFQUQsIGdmMzIsIHNpemVvZigqZ2YzMikpIHx8CisJCWlmICghYWNjZXNz
X29rKFZFUklGWV9SRUFELCBnZjMyLCBfX0NPTVBBVF9HRjBfU0laRSkgfHwKIAkJICAgIF9fZ2V0
X3VzZXIoaW50ZXJmYWNlLCAmZ2YzMi0+Z2ZfaW50ZXJmYWNlKSB8fAogCQkgICAgX19nZXRfdXNl
cihmbW9kZSwgJmdmMzItPmdmX2Ztb2RlKSB8fAogCQkgICAgX19nZXRfdXNlcihudW1zcmMsICZn
ZjMyLT5nZl9udW1zcmMpKQpAQCAtNjkwLDcgKzY5Myw3IEBAIGludCBjb21wYXRfbWNfc2V0c29j
a29wdChzdHJ1Y3Qgc29jayAqc28KIAkJICAgIF9fcHV0X3VzZXIobnVtc3JjLCAma2dmLT5nZl9u
dW1zcmMpIHx8CiAJCSAgICBjb3B5X2luX3VzZXIoJmtnZi0+Z2ZfZ3JvdXAsICZnZjMyLT5nZl9n
cm91cCwKIAkJCQlzaXplb2Yoa2dmLT5nZl9ncm91cCkpIHx8Ci0JCSAgICAobnVtc3JjICYmIGNv
cHlfaW5fdXNlcigma2dmLT5nZl9zbGlzdCwgJmdmMzItPmdmX3NsaXN0LAorCQkgICAgKG51bXNy
YyAmJiBjb3B5X2luX3VzZXIoa2dmLT5nZl9zbGlzdCwgZ2YzMi0+Z2Zfc2xpc3QsCiAJCQkJbnVt
c3JjICogc2l6ZW9mKGtnZi0+Z2Zfc2xpc3RbMF0pKSkpCiAJCQlyZXR1cm4gLUVGQVVMVDsKIAkJ
a29wdHZhbCA9IChjaGFyIF9fdXNlciAqKWtnZjsKQEAgLTcwNSw2ICs3MDgsODUgQEAgaW50IGNv
bXBhdF9tY19zZXRzb2Nrb3B0KHN0cnVjdCBzb2NrICpzbwogCiBFWFBPUlRfU1lNQk9MKGNvbXBh
dF9tY19zZXRzb2Nrb3B0KTsKIAoraW50IGNvbXBhdF9tY19nZXRzb2Nrb3B0KHN0cnVjdCBzb2Nr
ICpzb2NrLCBpbnQgbGV2ZWwsIGludCBvcHRuYW1lLAorCWNoYXIgX191c2VyICpvcHR2YWwsIGlu
dCBfX3VzZXIgKm9wdGxlbiwKKwlpbnQgKCpnZXRzb2Nrb3B0KShzdHJ1Y3Qgc29jayAqLGludCxp
bnQsY2hhciBfX3VzZXIgKixpbnQgX191c2VyICopKQoreworCXN0cnVjdCBjb21wYXRfZ3JvdXBf
ZmlsdGVyIF9fdXNlciAqZ2YzMiA9ICh2b2lkICopb3B0dmFsOworCXN0cnVjdCBncm91cF9maWx0
ZXIgX191c2VyICprZ2Y7CisJaW50IF9fdXNlcgkqa29wdGxlbjsKKwl1MzIgaW50ZXJmYWNlLCBm
bW9kZSwgbnVtc3JjOworCWludCBrbGVuLCB1bGVuLCBlcnI7CisKKwlpZiAob3B0bmFtZSAhPSBN
Q0FTVF9NU0ZJTFRFUikKKwkJcmV0dXJuIGdldHNvY2tvcHQoc29jaywgbGV2ZWwsIG9wdG5hbWUs
IG9wdHZhbCwgb3B0bGVuKTsKKworCWtvcHRsZW4gPSBjb21wYXRfYWxsb2NfdXNlcl9zcGFjZShz
aXplb2YoKmtvcHRsZW4pKTsKKwlpZiAoIWFjY2Vzc19vayhWRVJJRllfUkVBRCwgb3B0bGVuLCBz
aXplb2YoKm9wdGxlbikpIHx8CisJICAgIF9fZ2V0X3VzZXIodWxlbiwgb3B0bGVuKSkKKwkJcmV0
dXJuIC1FRkFVTFQ7CisKKwkvKiBhZGp1c3QgbGVuIGZvciBwYWQgKi8KKwlrbGVuID0gdWxlbiAr
IHNpemVvZigqa2dmKSAtIHNpemVvZigqZ2YzMik7CisKKwlpZiAoa2xlbiA8IEdST1VQX0ZJTFRF
Ul9TSVpFKDApKQorCQlyZXR1cm4gLUVJTlZBTDsKKworCWlmICghYWNjZXNzX29rKFZFUklGWV9X
UklURSwga29wdGxlbiwgc2l6ZW9mKCprb3B0bGVuKSkgfHwKKwkgICAgX19wdXRfdXNlcihrbGVu
LCBrb3B0bGVuKSkKKwkJcmV0dXJuIC1FRkFVTFQ7CisKKwkvKiBoYXZlIHRvIGFsbG93IHNwYWNl
IGZvciBwcmV2aW91cyBjb21wYXRfYWxsb2NfdXNlcl9zcGFjZSwgdG9vICovCisJa2dmID0gY29t
cGF0X2FsbG9jX3VzZXJfc3BhY2Uoa2xlbitzaXplb2YoKm9wdGxlbikpOworCisJaWYgKCFhY2Nl
c3Nfb2soVkVSSUZZX1JFQUQsIGdmMzIsIF9fQ09NUEFUX0dGMF9TSVpFKSB8fAorCSAgICBfX2dl
dF91c2VyKGludGVyZmFjZSwgJmdmMzItPmdmX2ludGVyZmFjZSkgfHwKKwkgICAgX19nZXRfdXNl
cihmbW9kZSwgJmdmMzItPmdmX2Ztb2RlKSB8fAorCSAgICBfX2dldF91c2VyKG51bXNyYywgJmdm
MzItPmdmX251bXNyYykgfHwKKwkgICAgX19wdXRfdXNlcihpbnRlcmZhY2UsICZrZ2YtPmdmX2lu
dGVyZmFjZSkgfHwKKwkgICAgX19wdXRfdXNlcihmbW9kZSwgJmtnZi0+Z2ZfZm1vZGUpIHx8CisJ
ICAgIF9fcHV0X3VzZXIobnVtc3JjLCAma2dmLT5nZl9udW1zcmMpIHx8CisJICAgIGNvcHlfaW5f
dXNlcigma2dmLT5nZl9ncm91cCwmZ2YzMi0+Z2ZfZ3JvdXAsc2l6ZW9mKGtnZi0+Z2ZfZ3JvdXAp
KSkKKwkJcmV0dXJuIC1FRkFVTFQ7CisKKwllcnIgPSBnZXRzb2Nrb3B0KHNvY2ssIGxldmVsLCBv
cHRuYW1lLCAoY2hhciBfX3VzZXIgKilrZ2YsIGtvcHRsZW4pOworCWlmIChlcnIpCisJCXJldHVy
biBlcnI7CisKKwlpZiAoIWFjY2Vzc19vayhWRVJJRllfUkVBRCwga29wdGxlbiwgc2l6ZW9mKCpr
b3B0bGVuKSkgfHwKKwkgICAgX19nZXRfdXNlcihrbGVuLCBrb3B0bGVuKSkKKwkJcmV0dXJuIC1F
RkFVTFQ7CisKKwl1bGVuID0ga2xlbiAtIChzaXplb2YoKmtnZiktc2l6ZW9mKCpnZjMyKSk7CisK
KwlpZiAoIWFjY2Vzc19vayhWRVJJRllfV1JJVEUsIG9wdGxlbiwgc2l6ZW9mKCpvcHRsZW4pKSB8
fAorCSAgICBfX3B1dF91c2VyKHVsZW4sIG9wdGxlbikpCisJCXJldHVybiAtRUZBVUxUOworCisJ
aWYgKCFhY2Nlc3Nfb2soVkVSSUZZX1JFQUQsIGtnZiwga2xlbikgfHwKKwkgICAgIWFjY2Vzc19v
ayhWRVJJRllfV1JJVEUsIGdmMzIsIHVsZW4pIHx8CisJICAgIF9fZ2V0X3VzZXIoaW50ZXJmYWNl
LCAma2dmLT5nZl9pbnRlcmZhY2UpIHx8CisJICAgIF9fZ2V0X3VzZXIoZm1vZGUsICZrZ2YtPmdm
X2Ztb2RlKSB8fAorCSAgICBfX2dldF91c2VyKG51bXNyYywgJmtnZi0+Z2ZfbnVtc3JjKSB8fAor
CSAgICBfX3B1dF91c2VyKGludGVyZmFjZSwgJmdmMzItPmdmX2ludGVyZmFjZSkgfHwKKwkgICAg
X19wdXRfdXNlcihmbW9kZSwgJmdmMzItPmdmX2Ztb2RlKSB8fAorCSAgICBfX3B1dF91c2VyKG51
bXNyYywgJmdmMzItPmdmX251bXNyYykpCisJCXJldHVybiAtRUZBVUxUOworCWlmIChudW1zcmMp
IHsKKwkJaW50IGNvcHlsZW47CisKKwkJa2xlbiAtPSBHUk9VUF9GSUxURVJfU0laRSgwKTsKKwkJ
Y29weWxlbiA9IG51bXNyYyAqIHNpemVvZihnZjMyLT5nZl9zbGlzdFswXSk7CisJCWlmIChjb3B5
bGVuID4ga2xlbikKKwkJCWNvcHlsZW4gPSBrbGVuOworCSAgICAgICAgaWYgKGNvcHlfaW5fdXNl
cihnZjMyLT5nZl9zbGlzdCwga2dmLT5nZl9zbGlzdCwgY29weWxlbikpCisJCQlyZXR1cm4gLUVG
QVVMVDsKKwl9CisJcmV0dXJuIGVycjsKK30KKworRVhQT1JUX1NZTUJPTChjb21wYXRfbWNfZ2V0
c29ja29wdCk7CisKIAogLyogQXJndW1lbnQgbGlzdCBzaXplcyBmb3IgY29tcGF0X3N5c19zb2Nr
ZXRjYWxsICovCiAjZGVmaW5lIEFMKHgpICgoeCkgKiBzaXplb2YodTMyKSkKZGlmZiAtcnVOcCBs
aW51eC0yLjYuMTgucHBjNjRETFMyL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMgbGludXgtMi42LjE4
LnBwYzY0R1NPL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMKLS0tIGxpbnV4LTIuNi4xOC5wcGM2NERM
UzIvbmV0L2lwdjQvaXBfc29ja2dsdWUuYwkyMDA4LTA0LTI2IDA0OjM2OjI0LjAwMDAwMDAwMCAt
MDcwMAorKysgbGludXgtMi42LjE4LnBwYzY0R1NPL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMJMjAw
OC0wNC0yNyAxMToyNDo0OC4wMDAwMDAwMDAgLTA3MDAKQEAgLTExOTMsNyArMTE5MywxNCBAQCBp
bnQgaXBfZ2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludCBsCiBpbnQgY29tcGF0X2lwX2dl
dHNvY2tvcHQoc3RydWN0IHNvY2sgKnNrLCBpbnQgbGV2ZWwsIGludCBvcHRuYW1lLAogCQkJIGNo
YXIgX191c2VyICpvcHR2YWwsIGludCBfX3VzZXIgKm9wdGxlbikKIHsKLQlpbnQgZXJyID0gZG9f
aXBfZ2V0c29ja29wdChzaywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZhbCwgb3B0bGVuKTsKKwlpbnQg
ZXJyOworCisJaWYgKG9wdG5hbWUgPT0gTUNBU1RfTVNGSUxURVIpCisJCXJldHVybiBjb21wYXRf
bWNfZ2V0c29ja29wdChzaywgbGV2ZWwsIG9wdG5hbWUsIG9wdHZhbCwgb3B0bGVuLAorCQkJaXBf
Z2V0c29ja29wdCk7CisKKwllcnIgPSBkb19pcF9nZXRzb2Nrb3B0KHNrLCBsZXZlbCwgb3B0bmFt
ZSwgb3B0dmFsLCBvcHRsZW4pOworCiAjaWZkZWYgQ09ORklHX05FVEZJTFRFUgogCS8qIHdlIG5l
ZWQgdG8gZXhjbHVkZSBhbGwgcG9zc2libGUgRU5PUFJPVE9PUFRzIGV4Y2VwdCBkZWZhdWx0IGNh
c2UgKi8KIAlpZiAoZXJyID09IC1FTk9QUk9UT09QVCAmJiBvcHRuYW1lICE9IElQX1BLVE9QVElP
TlMKZGlmZiAtcnVOcCBsaW51eC0yLjYuMTgucHBjNjRETFMyL25ldC9pcHY2L2lwdjZfc29ja2ds
dWUuYyBsaW51eC0yLjYuMTgucHBjNjRHU08vbmV0L2lwdjYvaXB2Nl9zb2NrZ2x1ZS5jCi0tLSBs
aW51eC0yLjYuMTgucHBjNjRETFMyL25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYwkyMDA4LTA0LTI2
IDA0OjM1OjE5LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjE4LnBwYzY0R1NPL25ldC9p
cHY2L2lwdjZfc29ja2dsdWUuYwkyMDA4LTA0LTI3IDEzOjU2OjI3LjAwMDAwMDAwMCAtMDcwMApA
QCAtMTA2Miw2ICsxMDYyLDEwIEBAIGludCBjb21wYXRfaXB2Nl9nZXRzb2Nrb3B0KHN0cnVjdCBz
b2NrICoKIAlpZiAobGV2ZWwgIT0gU09MX0lQVjYpCiAJCXJldHVybiAtRU5PUFJPVE9PUFQ7CiAK
KwlpZiAob3B0bmFtZSA9PSBNQ0FTVF9NU0ZJTFRFUikKKwkJcmV0dXJuIGNvbXBhdF9tY19nZXRz
b2Nrb3B0KHNrLCBsZXZlbCwgb3B0bmFtZSwgb3B0dmFsLCBvcHRsZW4sCisJCQlpcHY2X2dldHNv
Y2tvcHQpOworCiAJZXJyID0gZG9faXB2Nl9nZXRzb2Nrb3B0KHNrLCBsZXZlbCwgb3B0bmFtZSwg
b3B0dmFsLCBvcHRsZW4pOwogI2lmZGVmIENPTkZJR19ORVRGSUxURVIKIAkvKiB3ZSBuZWVkIHRv
IGV4Y2x1ZGUgYWxsIHBvc3NpYmxlIEVJTlZBTHMgZXhjZXB0IGRlZmF1bHQgY2FzZSAqLwo=

--=_mixed 001F49AA88257439_=--
