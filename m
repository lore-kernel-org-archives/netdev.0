From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 18:01:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFABEBA675.68903615-ON88256E33.000504D4-88256E33.0005673C@us.ibm.com>
References: <20040115221841.7e7cc78d%hibi665@oki.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244"
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040115221841.7e7cc78d%hibi665@oki.com>
To: Takashi Hibi <hibi665@oki.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244
Content-type: multipart/alternative;
	Boundary="1__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244"

--1__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244
Content-type: text/plain; charset=US-ASCII





Takashi,
      Below is a patch that allows MLD ICMP types without
applying the interface filters to them.

                              +-DLS
[in-line & attached]

diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F1/include/net/addrconf.h
--- linux-2.6.2/include/net/addrconf.h    2004-02-03 19:44:17.000000000 -0800
+++ linux-2.6.2F1/include/net/addrconf.h  2004-02-06 16:03:34.000000000 -0800
@@ -98,6 +98,7 @@

 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
            struct in6_addr *src_addr);
+extern int is_mld(struct sk_buff *skb);

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
+                     !is_mld(skb))
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
+int is_mld(struct sk_buff *skb)
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

(See attached file: mldx.patch)
--1__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
	Below is a patch that allows MLD ICMP types without<br>
applying the interface filters to them. <br>
<br>
					+-DLS<br>
[in-line &amp; attached]<br>
<br>
diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F1/include/net/addrconf.h<br>
--- linux-2.6.2/include/net/addrconf.h	2004-02-03 19:44:17.000000000 -0800<br>
+++ linux-2.6.2F1/include/net/addrconf.h	2004-02-06 16:03:34.000000000 -0800<br>
@@ -98,6 +98,7 @@<br>
 <br>
 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,<br>
 		struct in6_addr *src_addr);<br>
+extern int is_mld(struct sk_buff *skb);<br>
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
 						     csum_partial(skb-&gt;nh.raw, skb-&gt;h.raw-skb-&gt;nh.raw, 0));<br>
 				cksum_sub++;<br>
 			}<br>
+			hdr = skb-&gt;nh.ipv6h;<br>
+			if (ipv6_addr_is_multicast(&amp;hdr-&gt;daddr) &amp;&amp;<br>
+			    !ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr,<br>
+			    &amp;hdr-&gt;saddr) &amp;&amp;<br>
+			    !is_mld(skb))<br>
+				goto discard;<br>
 		}<br>
 		if (!(ipprot-&gt;flags &amp; INET6_PROTO_NOPOLICY) &amp;&amp;<br>
 		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) <br>
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
+int is_mld(struct sk_buff *skb)<br>
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
<br>
<i>(See attached file: mldx.patch)</i><br>
</body></html>

--1__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244--


--0__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244
Content-type: application/octet-stream;
	name="mldx.patch"
Content-Disposition: attachment; filename="mldx.patch"
Content-ID: <10__=07BBE4A0DF9682448f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbmV0L2FkZHJjb25mLmggbGludXgtMi42LjJG
MS9pbmNsdWRlL25ldC9hZGRyY29uZi5oCi0tLSBsaW51eC0yLjYuMi9pbmNsdWRlL25ldC9hZGRy
Y29uZi5oCTIwMDQtMDItMDMgMTk6NDQ6MTcuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYu
MkYxL2luY2x1ZGUvbmV0L2FkZHJjb25mLmgJMjAwNC0wMi0wNiAxNjowMzozNC4wMDAwMDAwMDAg
LTA4MDAKQEAgLTk4LDYgKzk4LDcgQEAKIAogZXh0ZXJuIGludCBpcHY2X2Noa19tY2FzdF9hZGRy
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBpbjZfYWRkciAqZ3JvdXAsCiAJCXN0cnVj
dCBpbjZfYWRkciAqc3JjX2FkZHIpOworZXh0ZXJuIGludCBpc19tbGQoc3RydWN0IHNrX2J1ZmYg
KnNrYik7CiAKIGV4dGVybiB2b2lkIGFkZHJjb25mX3ByZWZpeF9yY3Yoc3RydWN0IG5ldF9kZXZp
Y2UgKmRldiwgdTggKm9wdCwgaW50IGxlbik7CiAKZGlmZiAtcnVOIGxpbnV4LTIuNi4yL25ldC9p
cHY2L2lwNl9pbnB1dC5jIGxpbnV4LTIuNi4yRjEvbmV0L2lwdjYvaXA2X2lucHV0LmMKLS0tIGxp
bnV4LTIuNi4yL25ldC9pcHY2L2lwNl9pbnB1dC5jCTIwMDQtMDItMDMgMTk6NDQ6MTQuMDAwMDAw
MDAwIC0wODAwCisrKyBsaW51eC0yLjYuMkYxL25ldC9pcHY2L2lwNl9pbnB1dC5jCTIwMDQtMDIt
MDYgMTY6MDQ6MDAuMDAwMDAwMDAwIC0wODAwCkBAIC0xNjgsMTEgKzE2OCwxOSBAQAogCQkKIAkJ
c21wX3JlYWRfYmFycmllcl9kZXBlbmRzKCk7CiAJCWlmIChpcHByb3QtPmZsYWdzICYgSU5FVDZf
UFJPVE9fRklOQUwpIHsKKwkJCXN0cnVjdCBpcHY2aGRyICpoZHI7CQorCiAJCQlpZiAoIWNrc3Vt
X3N1YiAmJiBza2ItPmlwX3N1bW1lZCA9PSBDSEVDS1NVTV9IVykgewogCQkJCXNrYi0+Y3N1bSA9
IGNzdW1fc3ViKHNrYi0+Y3N1bSwKIAkJCQkJCSAgICAgY3N1bV9wYXJ0aWFsKHNrYi0+bmgucmF3
LCBza2ItPmgucmF3LXNrYi0+bmgucmF3LCAwKSk7CiAJCQkJY2tzdW1fc3ViKys7CiAJCQl9CisJ
CQloZHIgPSBza2ItPm5oLmlwdjZoOworCQkJaWYgKGlwdjZfYWRkcl9pc19tdWx0aWNhc3QoJmhk
ci0+ZGFkZHIpICYmCisJCQkgICAgIWlwdjZfY2hrX21jYXN0X2FkZHIoc2tiLT5kZXYsICZoZHIt
PmRhZGRyLAorCQkJICAgICZoZHItPnNhZGRyKSAmJgorCQkJICAgICFpc19tbGQoc2tiKSkKKwkJ
CQlnb3RvIGRpc2NhcmQ7CiAJCX0KIAkJaWYgKCEoaXBwcm90LT5mbGFncyAmIElORVQ2X1BST1RP
X05PUE9MSUNZKSAmJgogCQkgICAgIXhmcm02X3BvbGljeV9jaGVjayhOVUxMLCBYRlJNX1BPTElD
WV9JTiwgc2tiKSkgCkBAIC0yMTEsMTYgKzIxOSwxMSBAQAogCiBpbnQgaXA2X21jX2lucHV0KHN0
cnVjdCBza19idWZmICpza2IpCiB7Ci0Jc3RydWN0IGlwdjZoZHIgKmhkcjsJCi0JaW50IGRlbGl2
ZXIgPSAwOworCWludCBkZWxpdmVyID0gMTsKIAlpbnQgZGlzY2FyZCA9IDE7CiAKIAlJUDZfSU5D
X1NUQVRTX0JIKElwNkluTWNhc3RQa3RzKTsKIAotCWhkciA9IHNrYi0+bmguaXB2Nmg7Ci0JaWYg
KGlwdjZfY2hrX21jYXN0X2FkZHIoc2tiLT5kZXYsICZoZHItPmRhZGRyLCAmaGRyLT5zYWRkcikp
Ci0JCWRlbGl2ZXIgPSAxOwotCiAJLyoKIAkgKglJUHY2IG11bHRpY2FzdCByb3V0ZXIgbW9kZSBp
c250IGN1cnJlbnRseSBzdXBwb3J0ZWQuCiAJICovCmRpZmYgLXJ1TiBsaW51eC0yLjYuMi9uZXQv
aXB2Ni9tY2FzdC5jIGxpbnV4LTIuNi4yRjEvbmV0L2lwdjYvbWNhc3QuYwotLS0gbGludXgtMi42
LjIvbmV0L2lwdjYvbWNhc3QuYwkyMDA0LTAyLTAzIDE5OjQ0OjI4LjAwMDAwMDAwMCAtMDgwMAor
KysgbGludXgtMi42LjJGMS9uZXQvaXB2Ni9tY2FzdC5jCTIwMDQtMDItMDYgMTY6MDQ6MjUuMDAw
MDAwMDAwIC0wODAwCkBAIC05MDEsNiArOTAxLDI1IEBACiB9CiAKIC8qCisgKiBpZGVudGlmeSBN
TEQgcGFja2V0cyBmb3IgTUxEIGZpbHRlciBleGNlcHRpb25zCisgKi8KK2ludCBpc19tbGQoc3Ry
dWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlzdHJ1Y3QgaWNtcDZoZHIgKnBpYyA9IChzdHJ1Y3QgaWNt
cDZoZHIgKilza2ItPmgucmF3OworCisJc3dpdGNoIChwaWMtPmljbXA2X3R5cGUpIHsKKwljYXNl
IElDTVBWNl9NR01fUVVFUlk6CisJY2FzZSBJQ01QVjZfTUdNX1JFUE9SVDoKKwljYXNlIElDTVBW
Nl9NR01fUkVEVUNUSU9OOgorCWNhc2UgSUNNUFY2X01MRDJfUkVQT1JUOgorCQlyZXR1cm4gMTsK
KwlkZWZhdWx0OgorCQlicmVhazsKKwl9CisJcmV0dXJuIDA7Cit9CisKKy8qCiAgKgljaGVjayBp
ZiB0aGUgaW50ZXJmYWNlL2FkZHJlc3MgcGFpciBpcyB2YWxpZAogICovCiBpbnQgaXB2Nl9jaGtf
bWNhc3RfYWRkcihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2FkZHIgKmdyb3Vw
LAo=

--0__=07BBE4A0DF9682448f9e8a93df938690918c07BBE4A0DF968244--
