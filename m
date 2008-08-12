From: "John Gumb" <john.gumb@tandberg.com>
Subject: RE: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26,ip6_route_output, rt6_fill_node+0x175
Date: Tue, 12 Aug 2008 11:11:47 +0200
Message-ID: <9F6ACAE02B6DD040A1E259977622CFDB0335994F@oslexcp1.eu.tandberg.int>
References: <20080811110335.GA29407@kernel.sg>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C8FC5B.733BF61F"
Cc: "Alexey Dobriyan" <adobriyan@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"YOSHIFUJI Hideaki" <yoshfuji@linux-ipv6.org>
To: "Eugene Teo" <eugeneteo@kernel.sg>,
	"Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oslproxyp1.tandberg.com ([194.0.215.2]:52555 "EHLO
	oslproxyp1.tandberg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbYHLJMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 05:12:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080811110335.GA29407@kernel.sg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C8FC5B.733BF61F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Folks

I've enclosed patch from Eugene just so we all know which patch we're
talking about. It 'works' according to the following definition:

a) Fixed OOPS
b) runs overnight in our test network. This run doesn't do much specific
ipv6 testing - but clearly what's there is catching stuff :-;

cheers

John
-----Original Message-----
From: Eugene Teo [mailto:eugeneteo@kernel.sg]=20
Sent: 11 August 2008 12:04
To: Brian Haley
Cc: Alexey Dobriyan; John Gumb; linux-kernel@vger.kernel.org;
netdev@vger.kernel.org; YOSHIFUJI Hideaki
Subject: Re: OOPS, ip -f inet6 route get fec0::1,
linux-2.6.26,ip6_route_output, rt6_fill_node+0x175

Hi,

<quote sender=3D"Brian Haley">
> Alexey Dobriyan wrote:
>> On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
[...]
> The commit that changed this can't be reverted easily, but the patch =20
> below works for me.
>
> Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input =20
> device present in the dst entry.
>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

I think it's better to use a helper routine like ipv6_get_saddr to make
sure that both dst and rt6i_idev arguments are checked for NULL.

I have compiled, and tested the patch.

Thanks,
Eugene

---
Fix NULL pointer dereference in rt6_fill_node().

# ip -f inet6 route get fec0::1

BUG: unable to handle kernel NULL pointer dereference at 00000000
IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
EIP is at rt6_fill_node+0x175/0x3b0

Cc: Stable <stable@kernel.org>
Signed-off-by: Eugene Teo <eugeneteo@kernel.sg>
---
 include/net/addrconf.h  |    4 ++++
 include/net/ip6_fib.h   |    2 +-
 net/ipv6/addrconf.c     |    8 ++++++++
 net/ipv6/fib6_rules.c   |    3 +--
 net/ipv6/ip6_output.c   |    3 +--
 net/ipv6/route.c        |    3 +--
 net/ipv6/xfrm6_policy.c |    3 +--
 net/sctp/ipv6.c         |    3 +--
 8 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 06b2814..c43ad8e 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -80,6 +80,10 @@ extern struct inet6_ifaddr
*ipv6_get_ifaddr(struct net *net,
 						 struct net_device *dev,
 						 int strict);
=20
+extern int			ipv6_get_saddr(struct dst_entry *dst,
+					       const struct in6_addr
*daddr,
+					       unsigned int srcprefs,
+					       struct in6_addr *saddr);
 extern int			ipv6_dev_get_saddr(struct net_device
*dev,=20
 					       const struct in6_addr
*daddr,
 					       unsigned int srcprefs,
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 7c5c0f7..73f7f6b 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -118,7 +118,7 @@ struct rt6_info
=20
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 {
-	return ((struct rt6_info *)dst)->rt6i_idev;
+	return dst ? ((struct rt6_info *)dst)->rt6i_idev : NULL;
 }
=20
 struct fib6_walker_t
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a7842c5..55647bd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1239,6 +1239,14 @@ try_nextdev:
 	return 0;
 }
=20
+int ipv6_get_saddr(struct dst_entry *dst, const struct in6_addr *daddr,
+		    unsigned int srcprefs, struct in6_addr *saddr)
+{
+	struct inet6_dev *idev =3D ip6_dst_idev(dst);
+	return ipv6_dev_get_saddr(idev ? idev->dev : NULL, daddr,
srcprefs, saddr);
+
+}
+EXPORT_SYMBOL(ipv6_get_saddr);
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
=20
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 8d05527..27c859c 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -93,8 +93,7 @@ static int fib6_rule_action(struct fib_rule *rule,
struct flowi *flp,
 			if (flags & RT6_LOOKUP_F_SRCPREF_COA)
 				srcprefs |=3D IPV6_PREFER_SRC_COA;
=20
-			if
(ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
-					       &flp->fl6_dst, srcprefs,
+			if (ipv6_get_saddr(&rt->u.dst, &flp->fl6_dst,
srcprefs,
 					       &saddr))
 				goto again;
 			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a4402de..fc5f4f4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -934,8 +934,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
=20
 	if (ipv6_addr_any(&fl->fl6_src)) {
-		err =3D ipv6_dev_get_saddr(ip6_dst_idev(*dst)->dev,
-					 &fl->fl6_dst,
+		err =3D ipv6_get_saddr(*dst, &fl->fl6_dst,
 					 sk ? inet6_sk(sk)->srcprefs :
0,
 					 &fl->fl6_src);
 		if (err)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5a3e87e..950d709 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2188,8 +2188,7 @@ static int rt6_fill_node(struct sk_buff *skb,
struct rt6_info *rt,
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
-				       dst, 0, &saddr_buf) =3D=3D 0)
+		if (ipv6_get_saddr(&rt->u.dst, dst, 0, &saddr_buf) =3D=3D 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
=20
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8f1e054..ad582bd 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -57,8 +57,7 @@ static int xfrm6_get_saddr(xfrm_address_t *saddr,
xfrm_address_t *daddr)
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
=20
-	ipv6_dev_get_saddr(ip6_dst_idev(dst)->dev,
-			   (struct in6_addr *)&daddr->a6, 0,
+	ipv6_get_saddr(dst, (struct in6_addr *)&daddr->a6, 0,
 			   (struct in6_addr *)&saddr->a6);
 	dst_release(dst);
 	return 0;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 483a01d..0fa9411 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -319,8 +319,7 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			  __func__, asoc, dst,
NIP6(daddr->v6.sin6_addr));
=20
 	if (!asoc) {
-		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
-				   &daddr->v6.sin6_addr,
+		ipv6_get_saddr(dst, &daddr->v6.sin6_addr,
 				   inet6_sk(&sk->inet.sk)->srcprefs,
 				   &saddr->v6.sin6_addr);
 		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: " NIP6_FMT
"\n",

------_=_NextPart_001_01C8FC5B.733BF61F
Content-Type: application/octet-stream;
	name="bug#52312-idev.patch"
Content-Transfer-Encoding: base64
Content-Description: bug#52312-idev.patch
Content-Disposition: attachment;
	filename="bug#52312-idev.patch"

Rml4IE5VTEwgcG9pbnRlciBkZXJlZmVyZW5jZSBpbiBydDZfZmlsbF9ub2RlKCkuCgojIGlwIC1m
IGluZXQ2IHJvdXRlIGdldCBmZWMwOjoxCgpCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIE5V
TEwgcG9pbnRlciBkZXJlZmVyZW5jZSBhdCAwMDAwMDAwMApJUDogWzxjMDM2OWI4NT5dIHJ0Nl9m
aWxsX25vZGUrMHgxNzUvMHgzYjAKRUlQIGlzIGF0IHJ0Nl9maWxsX25vZGUrMHgxNzUvMHgzYjAK
CkNjOiBTdGFibGUgPHN0YWJsZUBrZXJuZWwub3JnPgpTaWduZWQtb2ZmLWJ5OiBFdWdlbmUgVGVv
IDxldWdlbmV0ZW9Aa2VybmVsLnNnPgotLS0KIGluY2x1ZGUvbmV0L2FkZHJjb25mLmggIHwgICAg
NCArKysrCiBpbmNsdWRlL25ldC9pcDZfZmliLmggICB8ICAgIDIgKy0KIG5ldC9pcHY2L2FkZHJj
b25mLmMgICAgIHwgICAgOCArKysrKysrKwogbmV0L2lwdjYvZmliNl9ydWxlcy5jICAgfCAgICAz
ICstLQogbmV0L2lwdjYvaXA2X291dHB1dC5jICAgfCAgICAzICstLQogbmV0L2lwdjYvcm91dGUu
YyAgICAgICAgfCAgICAzICstLQogbmV0L2lwdjYveGZybTZfcG9saWN5LmMgfCAgICAzICstLQog
bmV0L3NjdHAvaXB2Ni5jICAgICAgICAgfCAgICAzICstLQogOCBmaWxlcyBjaGFuZ2VkLCAxOCBp
bnNlcnRpb25zKCspLCAxMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9pbmNsdWRlL25ldC9h
ZGRyY29uZi5oIGIvaW5jbHVkZS9uZXQvYWRkcmNvbmYuaAppbmRleCAwNmIyODE0Li5jNDNhZDhl
IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9hZGRyY29uZi5oCisrKyBiL2luY2x1ZGUvbmV0L2Fk
ZHJjb25mLmgKQEAgLTgwLDYgKzgwLDEwIEBAIGV4dGVybiBzdHJ1Y3QgaW5ldDZfaWZhZGRyICAg
ICAgKmlwdjZfZ2V0X2lmYWRkcihzdHJ1Y3QgbmV0ICpuZXQsCiAJCQkJCQkgc3RydWN0IG5ldF9k
ZXZpY2UgKmRldiwKIAkJCQkJCSBpbnQgc3RyaWN0KTsKIAorZXh0ZXJuIGludAkJCWlwdjZfZ2V0
X3NhZGRyKHN0cnVjdCBkc3RfZW50cnkgKmRzdCwKKwkJCQkJICAgICAgIGNvbnN0IHN0cnVjdCBp
bjZfYWRkciAqZGFkZHIsCisJCQkJCSAgICAgICB1bnNpZ25lZCBpbnQgc3JjcHJlZnMsCisJCQkJ
CSAgICAgICBzdHJ1Y3QgaW42X2FkZHIgKnNhZGRyKTsKIGV4dGVybiBpbnQJCQlpcHY2X2Rldl9n
ZXRfc2FkZHIoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgCiAJCQkJCSAgICAgICBjb25zdCBzdHJ1
Y3QgaW42X2FkZHIgKmRhZGRyLAogCQkJCQkgICAgICAgdW5zaWduZWQgaW50IHNyY3ByZWZzLApk
aWZmIC0tZ2l0IGEvaW5jbHVkZS9uZXQvaXA2X2ZpYi5oIGIvaW5jbHVkZS9uZXQvaXA2X2ZpYi5o
CmluZGV4IDdjNWMwZjcuLjczZjdmNmIgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lwNl9maWIu
aAorKysgYi9pbmNsdWRlL25ldC9pcDZfZmliLmgKQEAgLTExOCw3ICsxMTgsNyBAQCBzdHJ1Y3Qg
cnQ2X2luZm8KIAogc3RhdGljIGlubGluZSBzdHJ1Y3QgaW5ldDZfZGV2ICppcDZfZHN0X2lkZXYo
c3RydWN0IGRzdF9lbnRyeSAqZHN0KQogewotCXJldHVybiAoKHN0cnVjdCBydDZfaW5mbyAqKWRz
dCktPnJ0NmlfaWRldjsKKwlyZXR1cm4gZHN0ID8gKChzdHJ1Y3QgcnQ2X2luZm8gKilkc3QpLT5y
dDZpX2lkZXYgOiBOVUxMOwogfQogCiBzdHJ1Y3QgZmliNl93YWxrZXJfdApkaWZmIC0tZ2l0IGEv
bmV0L2lwdjYvYWRkcmNvbmYuYyBiL25ldC9pcHY2L2FkZHJjb25mLmMKaW5kZXggYTc4NDJjNS4u
NTU2NDdiZCAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvYWRkcmNvbmYuYworKysgYi9uZXQvaXB2Ni9h
ZGRyY29uZi5jCkBAIC0xMjM5LDYgKzEyMzksMTQgQEAgdHJ5X25leHRkZXY6CiAJcmV0dXJuIDA7
CiB9CiAKK2ludCBpcHY2X2dldF9zYWRkcihzdHJ1Y3QgZHN0X2VudHJ5ICpkc3QsIGNvbnN0IHN0
cnVjdCBpbjZfYWRkciAqZGFkZHIsCisJCSAgICB1bnNpZ25lZCBpbnQgc3JjcHJlZnMsIHN0cnVj
dCBpbjZfYWRkciAqc2FkZHIpCit7CisJc3RydWN0IGluZXQ2X2RldiAqaWRldiA9IGlwNl9kc3Rf
aWRldihkc3QpOworCXJldHVybiBpcHY2X2Rldl9nZXRfc2FkZHIoaWRldiA/IGlkZXYtPmRldiA6
IE5VTEwsIGRhZGRyLCBzcmNwcmVmcywgc2FkZHIpOworCit9CitFWFBPUlRfU1lNQk9MKGlwdjZf
Z2V0X3NhZGRyKTsKIEVYUE9SVF9TWU1CT0woaXB2Nl9kZXZfZ2V0X3NhZGRyKTsKIAogaW50IGlw
djZfZ2V0X2xsYWRkcihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2FkZHIgKmFk
ZHIsCmRpZmYgLS1naXQgYS9uZXQvaXB2Ni9maWI2X3J1bGVzLmMgYi9uZXQvaXB2Ni9maWI2X3J1
bGVzLmMKaW5kZXggOGQwNTUyNy4uMjdjODU5YyAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvZmliNl9y
dWxlcy5jCisrKyBiL25ldC9pcHY2L2ZpYjZfcnVsZXMuYwpAQCAtOTMsOCArOTMsNyBAQCBzdGF0
aWMgaW50IGZpYjZfcnVsZV9hY3Rpb24oc3RydWN0IGZpYl9ydWxlICpydWxlLCBzdHJ1Y3QgZmxv
d2kgKmZscCwKIAkJCWlmIChmbGFncyAmIFJUNl9MT09LVVBfRl9TUkNQUkVGX0NPQSkKIAkJCQlz
cmNwcmVmcyB8PSBJUFY2X1BSRUZFUl9TUkNfQ09BOwogCi0JCQlpZiAoaXB2Nl9kZXZfZ2V0X3Nh
ZGRyKGlwNl9kc3RfaWRldigmcnQtPnUuZHN0KS0+ZGV2LAotCQkJCQkgICAgICAgJmZscC0+Zmw2
X2RzdCwgc3JjcHJlZnMsCisJCQlpZiAoaXB2Nl9nZXRfc2FkZHIoJnJ0LT51LmRzdCwgJmZscC0+
Zmw2X2RzdCwgc3JjcHJlZnMsCiAJCQkJCSAgICAgICAmc2FkZHIpKQogCQkJCWdvdG8gYWdhaW47
CiAJCQlpZiAoIWlwdjZfcHJlZml4X2VxdWFsKCZzYWRkciwgJnItPnNyYy5hZGRyLApkaWZmIC0t
Z2l0IGEvbmV0L2lwdjYvaXA2X291dHB1dC5jIGIvbmV0L2lwdjYvaXA2X291dHB1dC5jCmluZGV4
IGE0NDAyZGUuLmZjNWY0ZjQgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2lwNl9vdXRwdXQuYworKysg
Yi9uZXQvaXB2Ni9pcDZfb3V0cHV0LmMKQEAgLTkzNCw4ICs5MzQsNyBAQCBzdGF0aWMgaW50IGlw
Nl9kc3RfbG9va3VwX3RhaWwoc3RydWN0IHNvY2sgKnNrLAogCQlnb3RvIG91dF9lcnJfcmVsZWFz
ZTsKIAogCWlmIChpcHY2X2FkZHJfYW55KCZmbC0+Zmw2X3NyYykpIHsKLQkJZXJyID0gaXB2Nl9k
ZXZfZ2V0X3NhZGRyKGlwNl9kc3RfaWRldigqZHN0KS0+ZGV2LAotCQkJCQkgJmZsLT5mbDZfZHN0
LAorCQllcnIgPSBpcHY2X2dldF9zYWRkcigqZHN0LCAmZmwtPmZsNl9kc3QsCiAJCQkJCSBzayA/
IGluZXQ2X3NrKHNrKS0+c3JjcHJlZnMgOiAwLAogCQkJCQkgJmZsLT5mbDZfc3JjKTsKIAkJaWYg
KGVycikKZGlmZiAtLWdpdCBhL25ldC9pcHY2L3JvdXRlLmMgYi9uZXQvaXB2Ni9yb3V0ZS5jCmlu
ZGV4IDVhM2U4N2UuLjk1MGQ3MDkgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3JvdXRlLmMKKysrIGIv
bmV0L2lwdjYvcm91dGUuYwpAQCAtMjE4OCw4ICsyMTg4LDcgQEAgc3RhdGljIGludCBydDZfZmls
bF9ub2RlKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBydDZfaW5mbyAqcnQsCiAJCQlOTEFf
UFVUX1UzMihza2IsIFJUQV9JSUYsIGlpZik7CiAJfSBlbHNlIGlmIChkc3QpIHsKIAkJc3RydWN0
IGluNl9hZGRyIHNhZGRyX2J1ZjsKLQkJaWYgKGlwdjZfZGV2X2dldF9zYWRkcihpcDZfZHN0X2lk
ZXYoJnJ0LT51LmRzdCktPmRldiwKLQkJCQkgICAgICAgZHN0LCAwLCAmc2FkZHJfYnVmKSA9PSAw
KQorCQlpZiAoaXB2Nl9nZXRfc2FkZHIoJnJ0LT51LmRzdCwgZHN0LCAwLCAmc2FkZHJfYnVmKSA9
PSAwKQogCQkJTkxBX1BVVChza2IsIFJUQV9QUkVGU1JDLCAxNiwgJnNhZGRyX2J1Zik7CiAJfQog
CmRpZmYgLS1naXQgYS9uZXQvaXB2Ni94ZnJtNl9wb2xpY3kuYyBiL25ldC9pcHY2L3hmcm02X3Bv
bGljeS5jCmluZGV4IDhmMWUwNTQuLmFkNTgyYmQgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3hmcm02
X3BvbGljeS5jCisrKyBiL25ldC9pcHY2L3hmcm02X3BvbGljeS5jCkBAIC01Nyw4ICs1Nyw3IEBA
IHN0YXRpYyBpbnQgeGZybTZfZ2V0X3NhZGRyKHhmcm1fYWRkcmVzc190ICpzYWRkciwgeGZybV9h
ZGRyZXNzX3QgKmRhZGRyKQogCWlmIChJU19FUlIoZHN0KSkKIAkJcmV0dXJuIC1FSE9TVFVOUkVB
Q0g7CiAKLQlpcHY2X2Rldl9nZXRfc2FkZHIoaXA2X2RzdF9pZGV2KGRzdCktPmRldiwKLQkJCSAg
IChzdHJ1Y3QgaW42X2FkZHIgKikmZGFkZHItPmE2LCAwLAorCWlwdjZfZ2V0X3NhZGRyKGRzdCwg
KHN0cnVjdCBpbjZfYWRkciAqKSZkYWRkci0+YTYsIDAsCiAJCQkgICAoc3RydWN0IGluNl9hZGRy
ICopJnNhZGRyLT5hNik7CiAJZHN0X3JlbGVhc2UoZHN0KTsKIAlyZXR1cm4gMDsKZGlmZiAtLWdp
dCBhL25ldC9zY3RwL2lwdjYuYyBiL25ldC9zY3RwL2lwdjYuYwppbmRleCA0ODNhMDFkLi4wZmE5
NDExIDEwMDY0NAotLS0gYS9uZXQvc2N0cC9pcHY2LmMKKysrIGIvbmV0L3NjdHAvaXB2Ni5jCkBA
IC0zMTksOCArMzE5LDcgQEAgc3RhdGljIHZvaWQgc2N0cF92Nl9nZXRfc2FkZHIoc3RydWN0IHNj
dHBfc29jayAqc2ssCiAJCQkgIF9fZnVuY19fLCBhc29jLCBkc3QsIE5JUDYoZGFkZHItPnY2LnNp
bjZfYWRkcikpOwogCiAJaWYgKCFhc29jKSB7Ci0JCWlwdjZfZGV2X2dldF9zYWRkcihkc3QgPyBp
cDZfZHN0X2lkZXYoZHN0KS0+ZGV2IDogTlVMTCwKLQkJCQkgICAmZGFkZHItPnY2LnNpbjZfYWRk
ciwKKwkJaXB2Nl9nZXRfc2FkZHIoZHN0LCAmZGFkZHItPnY2LnNpbjZfYWRkciwKIAkJCQkgICBp
bmV0Nl9zaygmc2stPmluZXQuc2spLT5zcmNwcmVmcywKIAkJCQkgICAmc2FkZHItPnY2LnNpbjZf
YWRkcik7CiAJCVNDVFBfREVCVUdfUFJJTlRLKCJzYWRkciBmcm9tIGlwdjZfZ2V0X3NhZGRyOiAi
IE5JUDZfRk1UICJcbiIsCg==

------_=_NextPart_001_01C8FC5B.733BF61F--
