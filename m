From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Wed, 11 Feb 2004 14:00:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFA4C00EE0.FAE8C2B9-ON88256E37.0072FEDF-88256E37.00732B00@us.ibm.com>
References: <20040211.160152.48476158.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F"
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040211.160152.48476158.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F
Content-type: multipart/alternative;
	Boundary="1__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F"

--1__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F
Content-type: text/plain; charset=US-ASCII





Ok, here's what I hope is the final version of the patch, so we can
finally put this to bed. :-)

                        +-DLS

diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F2/include/net/addrconf.h
--- linux-2.6.2/include/net/addrconf.h    2004-02-03 19:44:17.000000000 -0800
+++ linux-2.6.2F2/include/net/addrconf.h  2004-02-10 15:17:00.000000000 -0800
@@ -98,6 +98,7 @@

 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
            struct in6_addr *src_addr);
+extern int ipv6_is_mld(struct sk_buff *skb);

 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);

diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2F2/net/ipv6/ip6_input.c
--- linux-2.6.2/net/ipv6/ip6_input.c      2004-02-03 19:44:14.000000000 -0800
+++ linux-2.6.2F2/net/ipv6/ip6_input.c    2004-02-11 12:34:27.000000000 -0800
@@ -168,11 +168,19 @@

            smp_read_barrier_depends();
            if (ipprot->flags & INET6_PROTO_FINAL) {
+                 struct ipv6hdr *hdr;
+
                  if (!cksum_sub && skb->ip_summed == CHECKSUM_HW) {
                        skb->csum = csum_sub(skb->csum,
                                         csum_partial(skb->nh.raw, skb->h.raw-skb->nh.raw, 0));
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
@@ -211,15 +219,14 @@

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
+     deliver = likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))) ||
+         ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);

      /*
       *    IPv6 multicast router mode isnt currently supported.
@@ -238,23 +245,21 @@

                  if (deliver) {
                        skb2 = skb_clone(skb, GFP_ATOMIC);
+                       dst_output(skb2);
                  } else {
-                       discard = 0;
-                       skb2 = skb;
+                       dst_output(skb);
+                       return 0;
                  }
-
-                 dst_output(skb2);
            }
      }
 #endif

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
+++ linux-2.6.2F2/net/ipv6/mcast.c  2004-02-11 12:34:34.000000000 -0800
@@ -901,6 +901,30 @@
 }

 /*
+ * identify MLD packets for MLD filter exceptions
+ */
+int ipv6_is_mld(struct sk_buff *skb)
+{
+     struct icmp6hdr *pic;
+
+     if (!pskb_may_pull(skb, sizeof(struct icmp6hdr)))
+           return 0;
+
+     pic = (struct icmp6hdr *)skb->h.raw;
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
@@ -918,7 +942,7 @@
                        break;
            }
            if (mc) {
-                 if (!ipv6_addr_any(src_addr)) {
+                 if (src_addr && !ipv6_addr_any(src_addr)) {
                        struct ip6_sf_list *psf;

                        spin_lock_bh(&mc->mca_lock);
(See attached file: mldx5.patch)
--1__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Ok, here's what I hope is the final version of the patch, so we can<br>
finally put this to bed. :-)<br>
<br>
				+-DLS<br>
<br>
diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F2/include/net/addrconf.h<br>
--- linux-2.6.2/include/net/addrconf.h	2004-02-03 19:44:17.000000000 -0800<br>
+++ linux-2.6.2F2/include/net/addrconf.h	2004-02-10 15:17:00.000000000 -0800<br>
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
+++ linux-2.6.2F2/net/ipv6/ip6_input.c	2004-02-11 12:34:27.000000000 -0800<br>
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
@@ -211,15 +219,14 @@<br>
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
+	deliver = likely(!(skb-&gt;dev-&gt;flags &amp; (IFF_PROMISC|IFF_ALLMULTI))) ||<br>
+	    ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr, NULL);<br>
 <br>
 	/*<br>
 	 *	IPv6 multicast router mode isnt currently supported.<br>
@@ -238,23 +245,21 @@<br>
 			<br>
 			if (deliver) {<br>
 				skb2 = skb_clone(skb, GFP_ATOMIC);<br>
+				dst_output(skb2);<br>
 			} else {<br>
-				discard = 0;<br>
-				skb2 = skb;<br>
+				dst_output(skb);<br>
+				return 0;<br>
 			}<br>
-<br>
-			dst_output(skb2);<br>
 		}<br>
 	}<br>
 #endif<br>
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
+++ linux-2.6.2F2/net/ipv6/mcast.c	2004-02-11 12:34:34.000000000 -0800<br>
@@ -901,6 +901,30 @@<br>
 }<br>
 <br>
 /*<br>
+ * identify MLD packets for MLD filter exceptions<br>
+ */<br>
+int ipv6_is_mld(struct sk_buff *skb)<br>
+{<br>
+	struct icmp6hdr *pic;<br>
+<br>
+	if (!pskb_may_pull(skb, sizeof(struct icmp6hdr)))<br>
+		return 0;<br>
+<br>
+	pic = (struct icmp6hdr *)skb-&gt;h.raw;<br>
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
@@ -918,7 +942,7 @@<br>
 				break;<br>
 		}<br>
 		if (mc) {<br>
-			if (!ipv6_addr_any(src_addr)) {<br>
+			if (src_addr &amp;&amp; !ipv6_addr_any(src_addr)) {<br>
 				struct ip6_sf_list *psf;<br>
 <br>
 				spin_lock_bh(&amp;mc-&gt;mca_lock);<br>
<i>(See attached file: mldx5.patch)</i><br>
</body></html>

--1__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F--


--0__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F
Content-type: application/octet-stream;
	name="mldx5.patch"
Content-Disposition: attachment; filename="mldx5.patch"
Content-ID: <10__=07BBE4A4DFE1784F8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbmV0L2FkZHJjb25mLmggbGludXgtMi42LjJG
Mi9pbmNsdWRlL25ldC9hZGRyY29uZi5oCi0tLSBsaW51eC0yLjYuMi9pbmNsdWRlL25ldC9hZGRy
Y29uZi5oCTIwMDQtMDItMDMgMTk6NDQ6MTcuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYu
MkYyL2luY2x1ZGUvbmV0L2FkZHJjb25mLmgJMjAwNC0wMi0xMCAxNToxNzowMC4wMDAwMDAwMDAg
LTA4MDAKQEAgLTk4LDYgKzk4LDcgQEAKIAogZXh0ZXJuIGludCBpcHY2X2Noa19tY2FzdF9hZGRy
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBpbjZfYWRkciAqZ3JvdXAsCiAJCXN0cnVj
dCBpbjZfYWRkciAqc3JjX2FkZHIpOworZXh0ZXJuIGludCBpcHY2X2lzX21sZChzdHJ1Y3Qgc2tf
YnVmZiAqc2tiKTsKIAogZXh0ZXJuIHZvaWQgYWRkcmNvbmZfcHJlZml4X3JjdihzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2LCB1OCAqb3B0LCBpbnQgbGVuKTsKIApkaWZmIC1ydU4gbGludXgtMi42LjIv
bmV0L2lwdjYvaXA2X2lucHV0LmMgbGludXgtMi42LjJGMi9uZXQvaXB2Ni9pcDZfaW5wdXQuYwot
LS0gbGludXgtMi42LjIvbmV0L2lwdjYvaXA2X2lucHV0LmMJMjAwNC0wMi0wMyAxOTo0NDoxNC4w
MDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4yRjIvbmV0L2lwdjYvaXA2X2lucHV0LmMJMjAw
NC0wMi0xMSAxMjozNDoyNy4wMDAwMDAwMDAgLTA4MDAKQEAgLTE2OCwxMSArMTY4LDE5IEBACiAJ
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
WEZSTV9QT0xJQ1lfSU4sIHNrYikpIApAQCAtMjExLDE1ICsyMTksMTQgQEAKIAogaW50IGlwNl9t
Y19pbnB1dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogewotCXN0cnVjdCBpcHY2aGRyICpoZHI7CQot
CWludCBkZWxpdmVyID0gMDsKLQlpbnQgZGlzY2FyZCA9IDE7CisJc3RydWN0IGlwdjZoZHIgKmhk
cjsKKwlpbnQgZGVsaXZlcjsKIAogCUlQNl9JTkNfU1RBVFNfQkgoSXA2SW5NY2FzdFBrdHMpOwog
CiAJaGRyID0gc2tiLT5uaC5pcHY2aDsKLQlpZiAoaXB2Nl9jaGtfbWNhc3RfYWRkcihza2ItPmRl
diwgJmhkci0+ZGFkZHIsICZoZHItPnNhZGRyKSkKLQkJZGVsaXZlciA9IDE7CisJZGVsaXZlciA9
IGxpa2VseSghKHNrYi0+ZGV2LT5mbGFncyAmIChJRkZfUFJPTUlTQ3xJRkZfQUxMTVVMVEkpKSkg
fHwKKwkgICAgaXB2Nl9jaGtfbWNhc3RfYWRkcihza2ItPmRldiwgJmhkci0+ZGFkZHIsIE5VTEwp
OwogCiAJLyoKIAkgKglJUHY2IG11bHRpY2FzdCByb3V0ZXIgbW9kZSBpc250IGN1cnJlbnRseSBz
dXBwb3J0ZWQuCkBAIC0yMzgsMjMgKzI0NSwyMSBAQAogCQkJCiAJCQlpZiAoZGVsaXZlcikgewog
CQkJCXNrYjIgPSBza2JfY2xvbmUoc2tiLCBHRlBfQVRPTUlDKTsKKwkJCQlkc3Rfb3V0cHV0KHNr
YjIpOwogCQkJfSBlbHNlIHsKLQkJCQlkaXNjYXJkID0gMDsKLQkJCQlza2IyID0gc2tiOworCQkJ
CWRzdF9vdXRwdXQoc2tiKTsKKwkJCQlyZXR1cm4gMDsKIAkJCX0KLQotCQkJZHN0X291dHB1dChz
a2IyKTsKIAkJfQogCX0KICNlbmRpZgogCi0JaWYgKGRlbGl2ZXIpIHsKLQkJZGlzY2FyZCA9IDA7
CisJaWYgKGxpa2VseShkZWxpdmVyKSkgewogCQlpcDZfaW5wdXQoc2tiKTsKKwkJcmV0dXJuIDA7
CiAJfQotCi0JaWYgKGRpc2NhcmQpCi0JCWtmcmVlX3NrYihza2IpOworCS8qIGRpc2NhcmQgKi8K
KwlrZnJlZV9za2Ioc2tiKTsKIAogCXJldHVybiAwOwogfQpkaWZmIC1ydU4gbGludXgtMi42LjIv
bmV0L2lwdjYvbWNhc3QuYyBsaW51eC0yLjYuMkYyL25ldC9pcHY2L21jYXN0LmMKLS0tIGxpbnV4
LTIuNi4yL25ldC9pcHY2L21jYXN0LmMJMjAwNC0wMi0wMyAxOTo0NDoyOC4wMDAwMDAwMDAgLTA4
MDAKKysrIGxpbnV4LTIuNi4yRjIvbmV0L2lwdjYvbWNhc3QuYwkyMDA0LTAyLTExIDEyOjM0OjM0
LjAwMDAwMDAwMCAtMDgwMApAQCAtOTAxLDYgKzkwMSwzMCBAQAogfQogCiAvKgorICogaWRlbnRp
ZnkgTUxEIHBhY2tldHMgZm9yIE1MRCBmaWx0ZXIgZXhjZXB0aW9ucworICovCitpbnQgaXB2Nl9p
c19tbGQoc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlzdHJ1Y3QgaWNtcDZoZHIgKnBpYzsKKwor
CWlmICghcHNrYl9tYXlfcHVsbChza2IsIHNpemVvZihzdHJ1Y3QgaWNtcDZoZHIpKSkKKwkJcmV0
dXJuIDA7CisKKwlwaWMgPSAoc3RydWN0IGljbXA2aGRyICopc2tiLT5oLnJhdzsKKworCXN3aXRj
aCAocGljLT5pY21wNl90eXBlKSB7CisJY2FzZSBJQ01QVjZfTUdNX1FVRVJZOgorCWNhc2UgSUNN
UFY2X01HTV9SRVBPUlQ6CisJY2FzZSBJQ01QVjZfTUdNX1JFRFVDVElPTjoKKwljYXNlIElDTVBW
Nl9NTEQyX1JFUE9SVDoKKwkJcmV0dXJuIDE7CisJZGVmYXVsdDoKKwkJYnJlYWs7CisJfQorCXJl
dHVybiAwOworfQorCisvKgogICoJY2hlY2sgaWYgdGhlIGludGVyZmFjZS9hZGRyZXNzIHBhaXIg
aXMgdmFsaWQKICAqLwogaW50IGlwdjZfY2hrX21jYXN0X2FkZHIoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldiwgc3RydWN0IGluNl9hZGRyICpncm91cCwKQEAgLTkxOCw3ICs5NDIsNyBAQAogCQkJCWJy
ZWFrOwogCQl9CiAJCWlmIChtYykgewotCQkJaWYgKCFpcHY2X2FkZHJfYW55KHNyY19hZGRyKSkg
eworCQkJaWYgKHNyY19hZGRyICYmICFpcHY2X2FkZHJfYW55KHNyY19hZGRyKSkgewogCQkJCXN0
cnVjdCBpcDZfc2ZfbGlzdCAqcHNmOwogCiAJCQkJc3Bpbl9sb2NrX2JoKCZtYy0+bWNhX2xvY2sp
Owo=

--0__=07BBE4A4DFE1784F8f9e8a93df938690918c07BBE4A4DFE1784F--
