From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Mon, 9 Feb 2004 16:20:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF40DCBAE1.2110C762-ON88256E35.007F7C77-88256E35.0080020D@us.ibm.com>
References: <20040207.154603.51160771.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7"
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040207.154603.51160771.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7
Content-type: multipart/alternative;
	Boundary="1__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7"

--1__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7
Content-type: text/plain; charset=US-ASCII





Here's a revised version with all the comments incorporated.

                  +-DLS


diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2
F2/include/net/addrconf.h
--- linux-2.6.2/include/net/addrconf.h    2004-02-03 19:44:17.000000000
-0800
+++ linux-2.6.2F2/include/net/addrconf.h  2004-02-06 16:03:34.000000000
-0800
@@ -98,6 +98,7 @@

 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr
*group,
            struct in6_addr *src_addr);
+extern int ipv6_is_mld(struct sk_buff *skb);

 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);

diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2
F2/net/ipv6/ip6_input.c
--- linux-2.6.2/net/ipv6/ip6_input.c      2004-02-03 19:44:14.000000000
-0800
+++ linux-2.6.2F2/net/ipv6/ip6_input.c    2004-02-09 14:12:34.000000000
-0800
@@ -168,11 +168,19 @@

            smp_read_barrier_depends();
            if (ipprot->flags & INET6_PROTO_FINAL) {
+                 struct ipv6hdr *hdr;
+
                  if (!cksum_sub && skb->ip_summed == CHECKSUM_HW) {
                        skb->csum = csum_sub(skb->csum,
                                         csum_partial(skb->nh.raw,
skb->h.raw-skb->nh.raw, 0));
                        cksum_sub++;
                  }
+                 hdr = skb->nh.ipv6h;
+                 if (ipv6_addr_is_multicast(&hdr->daddr) &&
+                     !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,
+                     &hdr->saddr) &&
+                     !ipv6_is_mld(skb))
+                       goto discard;
            }
            if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
                !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
@@ -211,50 +219,21 @@

 int ip6_mc_input(struct sk_buff *skb)
 {
-     struct ipv6hdr *hdr;
-     int deliver = 0;
-     int discard = 1;
+     struct ipv6hdr *hdr;
+     int deliver;

      IP6_INC_STATS_BH(Ip6InMcastPkts);

      hdr = skb->nh.ipv6h;
-     if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
-           deliver = 1;
-
-     /*
-      *    IPv6 multicast router mode isnt currently supported.
-      */
-#if 0
-     if (ipv6_config.multicast_route) {
-           int addr_type;
-
-           addr_type = ipv6_addr_type(&hdr->daddr);
-
-           if (!(addr_type & (IPV6_ADDR_LOOPBACK | IPV6_ADDR_LINKLOCAL))) {
-                 struct sk_buff *skb2;
-                 struct dst_entry *dst;
-
-                 dst = skb->dst;
-
-                 if (deliver) {
-                       skb2 = skb_clone(skb, GFP_ATOMIC);
-                 } else {
-                       discard = 0;
-                       skb2 = skb;
-                 }
-
-                 dst_output(skb2);
-           }
-     }
-#endif
+     deliver = !(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) ||
+         ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);

-     if (deliver) {
-           discard = 0;
+     if (likely(deliver)) {
            ip6_input(skb);
+           return 0;
      }
-
-     if (discard)
-           kfree_skb(skb);
+     /* discard */
+     kfree_skb(skb);

      return 0;
 }
diff -ruN linux-2.6.2/net/ipv6/mcast.c linux-2.6.2F2/net/ipv6/mcast.c
--- linux-2.6.2/net/ipv6/mcast.c    2004-02-03 19:44:28.000000000 -0800
+++ linux-2.6.2F2/net/ipv6/mcast.c  2004-02-09 13:12:07.000000000 -0800
@@ -901,6 +901,25 @@
 }

 /*
+ * identify MLD packets for MLD filter exceptions
+ */
+int ipv6_is_mld(struct sk_buff *skb)
+{
+     struct icmp6hdr *pic = (struct icmp6hdr *)skb->h.raw;
+
+     switch (pic->icmp6_type) {
+     case ICMPV6_MGM_QUERY:
+     case ICMPV6_MGM_REPORT:
+     case ICMPV6_MGM_REDUCTION:
+     case ICMPV6_MLD2_REPORT:
+           return 1;
+     default:
+           break;
+     }
+     return 0;
+}
+
+/*
  *   check if the interface/address pair is valid
  */
 int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
@@ -918,7 +937,7 @@
                        break;
            }
            if (mc) {
-                 if (!ipv6_addr_any(src_addr)) {
+                 if (src_addr && !ipv6_addr_any(src_addr)) {
                        struct ip6_sf_list *psf;

                        spin_lock_bh(&mc->mca_lock);

(See attached file: mldx3.patch)
--1__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Here's a revised version with all the comments incorporated.<br>
<br>
			+-DLS<br>
<br>
<br>
diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F2/include/net/addrconf.h<br>
--- linux-2.6.2/include/net/addrconf.h	2004-02-03 19:44:17.000000000 -0800<br>
+++ linux-2.6.2F2/include/net/addrconf.h	2004-02-06 16:03:34.000000000 -0800<br>
@@ -98,6 +98,7 @@<br>
 <br>
 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,<br>
 		struct in6_addr *src_addr);<br>
+extern int ipv6_is_mld(struct sk_buff *skb);<br>
 <br>
 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);<br>
 <br>
diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2F2/net/ipv6/ip6_input.c<br>
--- linux-2.6.2/net/ipv6/ip6_input.c	2004-02-03 19:44:14.000000000 -0800<br>
+++ linux-2.6.2F2/net/ipv6/ip6_input.c	2004-02-09 14:12:34.000000000 -0800<br>
@@ -168,11 +168,19 @@<br>
 		<br>
 		smp_read_barrier_depends();<br>
 		if (ipprot-&gt;flags &amp; INET6_PROTO_FINAL) {<br>
+			struct ipv6hdr *hdr;	<br>
+<br>
 			if (!cksum_sub &amp;&amp; skb-&gt;ip_summed == CHECKSUM_HW) {<br>
 				skb-&gt;csum = csum_sub(skb-&gt;csum,<br>
 						     csum_partial(skb-&gt;nh.raw, skb-&gt;h.raw-skb-&gt;nh.raw, 0));<br>
 				cksum_sub++;<br>
 			}<br>
+			hdr = skb-&gt;nh.ipv6h;<br>
+			if (ipv6_addr_is_multicast(&amp;hdr-&gt;daddr) &amp;&amp;<br>
+			    !ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr,<br>
+			    &amp;hdr-&gt;saddr) &amp;&amp;<br>
+			    !ipv6_is_mld(skb))<br>
+				goto discard;<br>
 		}<br>
 		if (!(ipprot-&gt;flags &amp; INET6_PROTO_NOPOLICY) &amp;&amp;<br>
 		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) <br>
@@ -211,50 +219,21 @@<br>
 <br>
 int ip6_mc_input(struct sk_buff *skb)<br>
 {<br>
-	struct ipv6hdr *hdr;	<br>
-	int deliver = 0;<br>
-	int discard = 1;<br>
+	struct ipv6hdr *hdr;<br>
+	int deliver;<br>
 <br>
 	IP6_INC_STATS_BH(Ip6InMcastPkts);<br>
 <br>
 	hdr = skb-&gt;nh.ipv6h;<br>
-	if (ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr, &amp;hdr-&gt;saddr))<br>
-		deliver = 1;<br>
-<br>
-	/*<br>
-	 *	IPv6 multicast router mode isnt currently supported.<br>
-	 */<br>
-#if 0<br>
-	if (ipv6_config.multicast_route) {<br>
-		int addr_type;<br>
-<br>
-		addr_type = ipv6_addr_type(&amp;hdr-&gt;daddr);<br>
-<br>
-		if (!(addr_type &amp; (IPV6_ADDR_LOOPBACK | IPV6_ADDR_LINKLOCAL))) {<br>
-			struct sk_buff *skb2;<br>
-			struct dst_entry *dst;<br>
-<br>
-			dst = skb-&gt;dst;<br>
-			<br>
-			if (deliver) {<br>
-				skb2 = skb_clone(skb, GFP_ATOMIC);<br>
-			} else {<br>
-				discard = 0;<br>
-				skb2 = skb;<br>
-			}<br>
-<br>
-			dst_output(skb2);<br>
-		}<br>
-	}<br>
-#endif<br>
+	deliver = !(skb-&gt;dev-&gt;flags &amp; (IFF_PROMISC|IFF_ALLMULTI)) ||<br>
+	    ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr, NULL);<br>
 <br>
-	if (deliver) {<br>
-		discard = 0;<br>
+	if (likely(deliver)) {<br>
 		ip6_input(skb);<br>
+		return 0;<br>
 	}<br>
-<br>
-	if (discard)<br>
-		kfree_skb(skb);<br>
+	/* discard */<br>
+	kfree_skb(skb);<br>
 <br>
 	return 0;<br>
 }<br>
diff -ruN linux-2.6.2/net/ipv6/mcast.c linux-2.6.2F2/net/ipv6/mcast.c<br>
--- linux-2.6.2/net/ipv6/mcast.c	2004-02-03 19:44:28.000000000 -0800<br>
+++ linux-2.6.2F2/net/ipv6/mcast.c	2004-02-09 13:12:07.000000000 -0800<br>
@@ -901,6 +901,25 @@<br>
 }<br>
 <br>
 /*<br>
+ * identify MLD packets for MLD filter exceptions<br>
+ */<br>
+int ipv6_is_mld(struct sk_buff *skb)<br>
+{<br>
+	struct icmp6hdr *pic = (struct icmp6hdr *)skb-&gt;h.raw;<br>
+<br>
+	switch (pic-&gt;icmp6_type) {<br>
+	case ICMPV6_MGM_QUERY:<br>
+	case ICMPV6_MGM_REPORT:<br>
+	case ICMPV6_MGM_REDUCTION:<br>
+	case ICMPV6_MLD2_REPORT:<br>
+		return 1;<br>
+	default:<br>
+		break;<br>
+	}<br>
+	return 0;<br>
+}<br>
+<br>
+/*<br>
  *	check if the interface/address pair is valid<br>
  */<br>
 int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,<br>
@@ -918,7 +937,7 @@<br>
 				break;<br>
 		}<br>
 		if (mc) {<br>
-			if (!ipv6_addr_any(src_addr)) {<br>
+			if (src_addr &amp;&amp; !ipv6_addr_any(src_addr)) {<br>
 				struct ip6_sf_list *psf;<br>
 <br>
 				spin_lock_bh(&amp;mc-&gt;mca_lock);<br>
<br>
<i>(See attached file: mldx3.patch)</i><br>
</body></html>

--1__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7--


--0__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7
Content-type: application/octet-stream;
	name="mldx3.patch"
Content-Disposition: attachment; filename="mldx3.patch"
Content-ID: <10__=07BBE4A6DFECFAE78f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbmV0L2FkZHJjb25mLmggbGludXgtMi42LjJG
Mi9pbmNsdWRlL25ldC9hZGRyY29uZi5oCi0tLSBsaW51eC0yLjYuMi9pbmNsdWRlL25ldC9hZGRy
Y29uZi5oCTIwMDQtMDItMDMgMTk6NDQ6MTcuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYu
MkYyL2luY2x1ZGUvbmV0L2FkZHJjb25mLmgJMjAwNC0wMi0wNiAxNjowMzozNC4wMDAwMDAwMDAg
LTA4MDAKQEAgLTk4LDYgKzk4LDcgQEAKIAogZXh0ZXJuIGludCBpcHY2X2Noa19tY2FzdF9hZGRy
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBpbjZfYWRkciAqZ3JvdXAsCiAJCXN0cnVj
dCBpbjZfYWRkciAqc3JjX2FkZHIpOworZXh0ZXJuIGludCBpcHY2X2lzX21sZChzdHJ1Y3Qgc2tf
YnVmZiAqc2tiKTsKIAogZXh0ZXJuIHZvaWQgYWRkcmNvbmZfcHJlZml4X3JjdihzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2LCB1OCAqb3B0LCBpbnQgbGVuKTsKIApkaWZmIC1ydU4gbGludXgtMi42LjIv
bmV0L2lwdjYvaXA2X2lucHV0LmMgbGludXgtMi42LjJGMi9uZXQvaXB2Ni9pcDZfaW5wdXQuYwot
LS0gbGludXgtMi42LjIvbmV0L2lwdjYvaXA2X2lucHV0LmMJMjAwNC0wMi0wMyAxOTo0NDoxNC4w
MDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4yRjIvbmV0L2lwdjYvaXA2X2lucHV0LmMJMjAw
NC0wMi0wOSAxNDoxMjozNC4wMDAwMDAwMDAgLTA4MDAKQEAgLTE2OCwxMSArMTY4LDE5IEBACiAJ
CQogCQlzbXBfcmVhZF9iYXJyaWVyX2RlcGVuZHMoKTsKIAkJaWYgKGlwcHJvdC0+ZmxhZ3MgJiBJ
TkVUNl9QUk9UT19GSU5BTCkgeworCQkJc3RydWN0IGlwdjZoZHIgKmhkcjsJCisKIAkJCWlmICgh
Y2tzdW1fc3ViICYmIHNrYi0+aXBfc3VtbWVkID09IENIRUNLU1VNX0hXKSB7CiAJCQkJc2tiLT5j
c3VtID0gY3N1bV9zdWIoc2tiLT5jc3VtLAogCQkJCQkJICAgICBjc3VtX3BhcnRpYWwoc2tiLT5u
aC5yYXcsIHNrYi0+aC5yYXctc2tiLT5uaC5yYXcsIDApKTsKIAkJCQlja3N1bV9zdWIrKzsKIAkJ
CX0KKwkJCWhkciA9IHNrYi0+bmguaXB2Nmg7CisJCQlpZiAoaXB2Nl9hZGRyX2lzX211bHRpY2Fz
dCgmaGRyLT5kYWRkcikgJiYKKwkJCSAgICAhaXB2Nl9jaGtfbWNhc3RfYWRkcihza2ItPmRldiwg
Jmhkci0+ZGFkZHIsCisJCQkgICAgJmhkci0+c2FkZHIpICYmCisJCQkgICAgIWlwdjZfaXNfbWxk
KHNrYikpCisJCQkJZ290byBkaXNjYXJkOwogCQl9CiAJCWlmICghKGlwcHJvdC0+ZmxhZ3MgJiBJ
TkVUNl9QUk9UT19OT1BPTElDWSkgJiYKIAkJICAgICF4ZnJtNl9wb2xpY3lfY2hlY2soTlVMTCwg
WEZSTV9QT0xJQ1lfSU4sIHNrYikpIApAQCAtMjExLDUwICsyMTksMjEgQEAKIAogaW50IGlwNl9t
Y19pbnB1dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogewotCXN0cnVjdCBpcHY2aGRyICpoZHI7CQot
CWludCBkZWxpdmVyID0gMDsKLQlpbnQgZGlzY2FyZCA9IDE7CisJc3RydWN0IGlwdjZoZHIgKmhk
cjsKKwlpbnQgZGVsaXZlcjsKIAogCUlQNl9JTkNfU1RBVFNfQkgoSXA2SW5NY2FzdFBrdHMpOwog
CiAJaGRyID0gc2tiLT5uaC5pcHY2aDsKLQlpZiAoaXB2Nl9jaGtfbWNhc3RfYWRkcihza2ItPmRl
diwgJmhkci0+ZGFkZHIsICZoZHItPnNhZGRyKSkKLQkJZGVsaXZlciA9IDE7Ci0KLQkvKgotCSAq
CUlQdjYgbXVsdGljYXN0IHJvdXRlciBtb2RlIGlzbnQgY3VycmVudGx5IHN1cHBvcnRlZC4KLQkg
Ki8KLSNpZiAwCi0JaWYgKGlwdjZfY29uZmlnLm11bHRpY2FzdF9yb3V0ZSkgewotCQlpbnQgYWRk
cl90eXBlOwotCi0JCWFkZHJfdHlwZSA9IGlwdjZfYWRkcl90eXBlKCZoZHItPmRhZGRyKTsKLQot
CQlpZiAoIShhZGRyX3R5cGUgJiAoSVBWNl9BRERSX0xPT1BCQUNLIHwgSVBWNl9BRERSX0xJTktM
T0NBTCkpKSB7Ci0JCQlzdHJ1Y3Qgc2tfYnVmZiAqc2tiMjsKLQkJCXN0cnVjdCBkc3RfZW50cnkg
KmRzdDsKLQotCQkJZHN0ID0gc2tiLT5kc3Q7Ci0JCQkKLQkJCWlmIChkZWxpdmVyKSB7Ci0JCQkJ
c2tiMiA9IHNrYl9jbG9uZShza2IsIEdGUF9BVE9NSUMpOwotCQkJfSBlbHNlIHsKLQkJCQlkaXNj
YXJkID0gMDsKLQkJCQlza2IyID0gc2tiOwotCQkJfQotCi0JCQlkc3Rfb3V0cHV0KHNrYjIpOwot
CQl9Ci0JfQotI2VuZGlmCisJZGVsaXZlciA9ICEoc2tiLT5kZXYtPmZsYWdzICYgKElGRl9QUk9N
SVNDfElGRl9BTExNVUxUSSkpIHx8CisJICAgIGlwdjZfY2hrX21jYXN0X2FkZHIoc2tiLT5kZXYs
ICZoZHItPmRhZGRyLCBOVUxMKTsKIAotCWlmIChkZWxpdmVyKSB7Ci0JCWRpc2NhcmQgPSAwOwor
CWlmIChsaWtlbHkoZGVsaXZlcikpIHsKIAkJaXA2X2lucHV0KHNrYik7CisJCXJldHVybiAwOwog
CX0KLQotCWlmIChkaXNjYXJkKQotCQlrZnJlZV9za2Ioc2tiKTsKKwkvKiBkaXNjYXJkICovCisJ
a2ZyZWVfc2tiKHNrYik7CiAKIAlyZXR1cm4gMDsKIH0KZGlmZiAtcnVOIGxpbnV4LTIuNi4yL25l
dC9pcHY2L21jYXN0LmMgbGludXgtMi42LjJGMi9uZXQvaXB2Ni9tY2FzdC5jCi0tLSBsaW51eC0y
LjYuMi9uZXQvaXB2Ni9tY2FzdC5jCTIwMDQtMDItMDMgMTk6NDQ6MjguMDAwMDAwMDAwIC0wODAw
CisrKyBsaW51eC0yLjYuMkYyL25ldC9pcHY2L21jYXN0LmMJMjAwNC0wMi0wOSAxMzoxMjowNy4w
MDAwMDAwMDAgLTA4MDAKQEAgLTkwMSw2ICs5MDEsMjUgQEAKIH0KIAogLyoKKyAqIGlkZW50aWZ5
IE1MRCBwYWNrZXRzIGZvciBNTEQgZmlsdGVyIGV4Y2VwdGlvbnMKKyAqLworaW50IGlwdjZfaXNf
bWxkKHN0cnVjdCBza19idWZmICpza2IpCit7CisJc3RydWN0IGljbXA2aGRyICpwaWMgPSAoc3Ry
dWN0IGljbXA2aGRyICopc2tiLT5oLnJhdzsKKworCXN3aXRjaCAocGljLT5pY21wNl90eXBlKSB7
CisJY2FzZSBJQ01QVjZfTUdNX1FVRVJZOgorCWNhc2UgSUNNUFY2X01HTV9SRVBPUlQ6CisJY2Fz
ZSBJQ01QVjZfTUdNX1JFRFVDVElPTjoKKwljYXNlIElDTVBWNl9NTEQyX1JFUE9SVDoKKwkJcmV0
dXJuIDE7CisJZGVmYXVsdDoKKwkJYnJlYWs7CisJfQorCXJldHVybiAwOworfQorCisvKgogICoJ
Y2hlY2sgaWYgdGhlIGludGVyZmFjZS9hZGRyZXNzIHBhaXIgaXMgdmFsaWQKICAqLwogaW50IGlw
djZfY2hrX21jYXN0X2FkZHIoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IGluNl9hZGRy
ICpncm91cCwKQEAgLTkxOCw3ICs5MzcsNyBAQAogCQkJCWJyZWFrOwogCQl9CiAJCWlmIChtYykg
ewotCQkJaWYgKCFpcHY2X2FkZHJfYW55KHNyY19hZGRyKSkgeworCQkJaWYgKHNyY19hZGRyICYm
ICFpcHY2X2FkZHJfYW55KHNyY19hZGRyKSkgewogCQkJCXN0cnVjdCBpcDZfc2ZfbGlzdCAqcHNm
OwogCiAJCQkJc3Bpbl9sb2NrX2JoKCZtYy0+bWNhX2xvY2spOwo=

--0__=07BBE4A6DFECFAE78f9e8a93df938690918c07BBE4A6DFECFAE7--
