From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 21:12:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
References: <20040206195325.207aa1c7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5"
Cc: hibi665@oki.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040206195325.207aa1c7.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5
Content-type: multipart/alternative;
	Boundary="1__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5"

--1__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5
Content-type: text/plain; charset=US-ASCII






> David, please don't pollute global name space so badly :-)
> ipv6_is_mld() would be fine.

Of course, sorry about that. :-)

                  +-DLS

diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F1/include/net/addrconf.h
--- linux-2.6.2/include/net/addrconf.h    2004-02-03 19:44:17.000000000 -0800
+++ linux-2.6.2F1/include/net/addrconf.h  2004-02-06 16:03:34.000000000 -0800
@@ -98,6 +98,7 @@

 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
            struct in6_addr *src_addr);
+extern int ipv6_is_mld(struct sk_buff *skb);

 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);

diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2F1/net/ipv6/ip6_input.c
--- linux-2.6.2/net/ipv6/ip6_input.c      2004-02-03 19:44:14.000000000 -0800
+++ linux-2.6.2F1/net/ipv6/ip6_input.c    2004-02-06 16:04:00.000000000 -0800
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
@@ -211,16 +219,11 @@

 int ip6_mc_input(struct sk_buff *skb)
 {
-     struct ipv6hdr *hdr;
-     int deliver = 0;
+     int deliver = 1;
      int discard = 1;

      IP6_INC_STATS_BH(Ip6InMcastPkts);

-     hdr = skb->nh.ipv6h;
-     if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
-           deliver = 1;
-
      /*
       *    IPv6 multicast router mode isnt currently supported.
       */
diff -ruN linux-2.6.2/net/ipv6/mcast.c linux-2.6.2F1/net/ipv6/mcast.c
--- linux-2.6.2/net/ipv6/mcast.c    2004-02-03 19:44:28.000000000 -0800
+++ linux-2.6.2F1/net/ipv6/mcast.c  2004-02-06 16:04:25.000000000 -0800
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

(See attached file: mldx2.patch)
--1__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&gt; David, please don't pollute global name space so badly :-)<br>
&gt; ipv6_is_mld() would be fine.</tt><br>
<br>
<tt>Of course, sorry about that. :-)</tt><br>
<br>
<tt>			+-DLS</tt><br>
<br>
<tt>diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F1/include/net/addrconf.h<br>
--- linux-2.6.2/include/net/addrconf.h	2004-02-03 19:44:17.000000000 -0800<br>
+++ linux-2.6.2F1/include/net/addrconf.h	2004-02-06 16:03:34.000000000 -0800<br>
@@ -98,6 +98,7 @@<br>
 <br>
 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,<br>
 		struct in6_addr *src_addr);<br>
+extern int ipv6_is_mld(struct sk_buff *skb);<br>
 <br>
 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);<br>
 <br>
diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2F1/net/ipv6/ip6_input.c<br>
--- linux-2.6.2/net/ipv6/ip6_input.c	2004-02-03 19:44:14.000000000 -0800<br>
+++ linux-2.6.2F1/net/ipv6/ip6_input.c	2004-02-06 16:04:00.000000000 -0800<br>
@@ -168,11 +168,19 @@<br>
 		<br>
 		smp_read_barrier_depends();<br>
 		if (ipprot-&gt;flags &amp; INET6_PROTO_FINAL) {<br>
+			struct ipv6hdr *hdr;	<br>
+<br>
 			if (!cksum_sub &amp;&amp; skb-&gt;ip_summed == CHECKSUM_HW) {<br>
 				skb-&gt;csum = csum_sub(skb-&gt;csum,<br>
 						 &nbsp; &nbsp; csum_partial(skb-&gt;nh.raw, skb-&gt;h.raw-skb-&gt;nh.raw, 0));<br>
 				cksum_sub++;<br>
 			}</tt><br>
<tt>+			hdr = skb-&gt;nh.ipv6h;<br>
+			if (ipv6_addr_is_multicast(&amp;hdr-&gt;daddr) &amp;&amp;<br>
+			 &nbsp; &nbsp;!ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr,<br>
+			 &nbsp; &nbsp;&amp;hdr-&gt;saddr) &amp;&amp;<br>
+			 &nbsp; &nbsp;!ipv6_is_mld(skb))<br>
+				goto discard;<br>
 		}<br>
 		if (!(ipprot-&gt;flags &amp; INET6_PROTO_NOPOLICY) &amp;&amp;<br>
 		 &nbsp; &nbsp;!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) <br>
@@ -211,16 +219,11 @@<br>
 <br>
 int ip6_mc_input(struct sk_buff *skb)<br>
 {<br>
-	struct ipv6hdr *hdr;	<br>
-	int deliver = 0;<br>
+	int deliver = 1;<br>
 	int discard = 1;<br>
 <br>
 	IP6_INC_STATS_BH(Ip6InMcastPkts);<br>
 <br>
-	hdr = skb-&gt;nh.ipv6h;<br>
-	if (ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr, &amp;hdr-&gt;saddr))<br>
-		deliver = 1;<br>
-<br>
 	/*<br>
 	 *	IPv6 multicast router mode isnt currently supported.<br>
 	 */<br>
diff -ruN linux-2.6.2/net/ipv6/mcast.c linux-2.6.2F1/net/ipv6/mcast.c<br>
--- linux-2.6.2/net/ipv6/mcast.c	2004-02-03 19:44:28.000000000 -0800<br>
+++ linux-2.6.2F1/net/ipv6/mcast.c	2004-02-06 16:04:25.000000000 -0800<br>
@@ -901,6 +901,25 @@<br>
 }<br>
 <br>
 /*<br>
+ * identify MLD packets for MLD filter exceptions<br>
+ */<br>
+int ipv6_is_mld(struct sk_buff *skb)<br>
+{<br>
+	struct icmp6hdr *pic = (struct icmp6hdr *)skb-&gt;h.raw;</tt><br>
<tt>+<br>
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
 &nbsp;*	check if the interface/address pair is valid<br>
 &nbsp;*/<br>
 int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,</tt><br>
<br>
<i>(See attached file: mldx2.patch)</i><br>
</body></html>

--1__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5--


--0__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5
Content-type: application/octet-stream;
	name="mldx2.patch"
Content-Disposition: attachment; filename="mldx2.patch"
Content-ID: <10__=07BBE4A0DF8538D58f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbmV0L2FkZHJjb25mLmggbGludXgtMi42LjJG
MS9pbmNsdWRlL25ldC9hZGRyY29uZi5oCi0tLSBsaW51eC0yLjYuMi9pbmNsdWRlL25ldC9hZGRy
Y29uZi5oCTIwMDQtMDItMDMgMTk6NDQ6MTcuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYu
MkYxL2luY2x1ZGUvbmV0L2FkZHJjb25mLmgJMjAwNC0wMi0wNiAxNjowMzozNC4wMDAwMDAwMDAg
LTA4MDAKQEAgLTk4LDYgKzk4LDcgQEAKIAogZXh0ZXJuIGludCBpcHY2X2Noa19tY2FzdF9hZGRy
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBpbjZfYWRkciAqZ3JvdXAsCiAJCXN0cnVj
dCBpbjZfYWRkciAqc3JjX2FkZHIpOworZXh0ZXJuIGludCBpcHY2X2lzX21sZChzdHJ1Y3Qgc2tf
YnVmZiAqc2tiKTsKIAogZXh0ZXJuIHZvaWQgYWRkcmNvbmZfcHJlZml4X3JjdihzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2LCB1OCAqb3B0LCBpbnQgbGVuKTsKIApkaWZmIC1ydU4gbGludXgtMi42LjIv
bmV0L2lwdjYvaXA2X2lucHV0LmMgbGludXgtMi42LjJGMS9uZXQvaXB2Ni9pcDZfaW5wdXQuYwot
LS0gbGludXgtMi42LjIvbmV0L2lwdjYvaXA2X2lucHV0LmMJMjAwNC0wMi0wMyAxOTo0NDoxNC4w
MDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4yRjEvbmV0L2lwdjYvaXA2X2lucHV0LmMJMjAw
NC0wMi0wNiAxNjowNDowMC4wMDAwMDAwMDAgLTA4MDAKQEAgLTE2OCwxMSArMTY4LDE5IEBACiAJ
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
WEZSTV9QT0xJQ1lfSU4sIHNrYikpIApAQCAtMjExLDE2ICsyMTksMTEgQEAKIAogaW50IGlwNl9t
Y19pbnB1dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogewotCXN0cnVjdCBpcHY2aGRyICpoZHI7CQot
CWludCBkZWxpdmVyID0gMDsKKwlpbnQgZGVsaXZlciA9IDE7CiAJaW50IGRpc2NhcmQgPSAxOwog
CiAJSVA2X0lOQ19TVEFUU19CSChJcDZJbk1jYXN0UGt0cyk7CiAKLQloZHIgPSBza2ItPm5oLmlw
djZoOwotCWlmIChpcHY2X2Noa19tY2FzdF9hZGRyKHNrYi0+ZGV2LCAmaGRyLT5kYWRkciwgJmhk
ci0+c2FkZHIpKQotCQlkZWxpdmVyID0gMTsKLQogCS8qCiAJICoJSVB2NiBtdWx0aWNhc3Qgcm91
dGVyIG1vZGUgaXNudCBjdXJyZW50bHkgc3VwcG9ydGVkLgogCSAqLwpkaWZmIC1ydU4gbGludXgt
Mi42LjIvbmV0L2lwdjYvbWNhc3QuYyBsaW51eC0yLjYuMkYxL25ldC9pcHY2L21jYXN0LmMKLS0t
IGxpbnV4LTIuNi4yL25ldC9pcHY2L21jYXN0LmMJMjAwNC0wMi0wMyAxOTo0NDoyOC4wMDAwMDAw
MDAgLTA4MDAKKysrIGxpbnV4LTIuNi4yRjEvbmV0L2lwdjYvbWNhc3QuYwkyMDA0LTAyLTA2IDE2
OjA0OjI1LjAwMDAwMDAwMCAtMDgwMApAQCAtOTAxLDYgKzkwMSwyNSBAQAogfQogCiAvKgorICog
aWRlbnRpZnkgTUxEIHBhY2tldHMgZm9yIE1MRCBmaWx0ZXIgZXhjZXB0aW9ucworICovCitpbnQg
aXB2Nl9pc19tbGQoc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlzdHJ1Y3QgaWNtcDZoZHIgKnBp
YyA9IChzdHJ1Y3QgaWNtcDZoZHIgKilza2ItPmgucmF3OworCisJc3dpdGNoIChwaWMtPmljbXA2
X3R5cGUpIHsKKwljYXNlIElDTVBWNl9NR01fUVVFUlk6CisJY2FzZSBJQ01QVjZfTUdNX1JFUE9S
VDoKKwljYXNlIElDTVBWNl9NR01fUkVEVUNUSU9OOgorCWNhc2UgSUNNUFY2X01MRDJfUkVQT1JU
OgorCQlyZXR1cm4gMTsKKwlkZWZhdWx0OgorCQlicmVhazsKKwl9CisJcmV0dXJuIDA7Cit9CisK
Ky8qCiAgKgljaGVjayBpZiB0aGUgaW50ZXJmYWNlL2FkZHJlc3MgcGFpciBpcyB2YWxpZAogICov
CiBpbnQgaXB2Nl9jaGtfbWNhc3RfYWRkcihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3Qg
aW42X2FkZHIgKmdyb3VwLAo=

--0__=07BBE4A0DF8538D58f9e8a93df938690918c07BBE4A0DF8538D5--
