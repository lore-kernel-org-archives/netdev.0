From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Wed, 11 Feb 2004 23:34:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF3D503D9D.B62072AD-ON88256E38.001BCCBD-88256E38.0023E0FA@us.ibm.com>
References: <20040212.110328.103131455.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D"
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040212.110328.103131455.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D
Content-type: multipart/alternative;
	Boundary="1__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D"

--1__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D
Content-type: text/plain; charset=US-ASCII







"Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp> wrote on
02/11/2004 06:03:28 PM:

> You forgot to check if proto is IPPROTO_ICMPV6.
> (This is one reason why I want to check the icmpv6 code
> in icmpv6_rcv().)

      Arg! You're right! I had no idea what you were talking
about with that comment about icmpv6_rcv() (the test can't be
done there, because it'll be discarded without it; I thought
you were looking for an optimization of some kind). Of course,
my tests are using ICMP (MLD and ECHO) and UDP packets that
didn't have MLD types where the ICMPv6 type code would be--
so the filter and exceptions all worked. :-(

      What I intended is for ipv6_is_mld() to check this (not
assume that "skb" is ICMPv6 only). Fixed patch below [blush].
      Thanks for the reviews,

                        +-DLS

diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F2/include/net/addrconf.h
--- linux-2.6.2/include/net/addrconf.h    2004-02-03 19:44:17.000000000 -0800
+++ linux-2.6.2F2/include/net/addrconf.h  2004-02-11 21:03:10.000000000 -0800
@@ -98,6 +98,7 @@

 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,
            struct in6_addr *src_addr);
+extern int ipv6_is_mld(struct sk_buff *skb, int nexthdr);

 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);

diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2F2/net/ipv6/ip6_input.c
--- linux-2.6.2/net/ipv6/ip6_input.c      2004-02-03 19:44:14.000000000 -0800
+++ linux-2.6.2F2/net/ipv6/ip6_input.c    2004-02-11 21:00:03.000000000 -0800
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
+                     !ipv6_is_mld(skb, nexthdr))
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
+++ linux-2.6.2F2/net/ipv6/mcast.c  2004-02-11 21:01:52.000000000 -0800
@@ -901,6 +901,33 @@
 }

 /*
+ * identify MLD packets for MLD filter exceptions
+ */
+int ipv6_is_mld(struct sk_buff *skb, int nexthdr)
+{
+     struct icmp6hdr *pic;
+
+     if (nexthdr != IPPROTO_ICMPV6)
+           return 0;
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
@@ -918,7 +945,7 @@
                        break;
            }
            if (mc) {
-                 if (!ipv6_addr_any(src_addr)) {
+                 if (src_addr && !ipv6_addr_any(src_addr)) {
                        struct ip6_sf_list *psf;

                        spin_lock_bh(&mc->mca_lock);
(See attached file: mldx6.patch)
--1__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&quot;Hideaki YOSHIFUJI&quot; &lt;yoshfuji@cerberus.hongo.wide.ad.jp&gt; wrote on 02/11/2004 06:03:28 PM:<br>
</tt><br>
<tt>&gt; You forgot to check if proto is IPPROTO_ICMPV6.<br>
&gt; (This is one reason why I want to check the icmpv6 code</tt><br>
<tt>&gt; in icmpv6_rcv().)</tt><br>
<br>
<tt>	Arg! You're right! I had no idea what you were talking</tt><br>
<tt>about with that comment about icmpv6_rcv() (the test can't be</tt><br>
<tt>done there, because it'll be discarded without it; I thought</tt><br>
<tt>you were looking for an optimization of some kind). Of course,</tt><br>
<tt>my tests are using ICMP (MLD and ECHO) and UDP packets that</tt><br>
<tt>didn't have MLD types where the ICMPv6 type code would be--</tt><br>
<tt>so the filter and exceptions all worked. :-(</tt><br>
<br>
<tt>	What I intended is for ipv6_is_mld() to check this (not</tt><br>
<tt>assume that &quot;skb&quot; is ICMPv6 only). Fixed patch below [blush].</tt><br>
<tt>	Thanks for the reviews,</tt><br>
<br>
<tt>				+-DLS<br>
</tt><br>
<tt>diff -ruN linux-2.6.2/include/net/addrconf.h linux-2.6.2F2/include/net/addrconf.h<br>
--- linux-2.6.2/include/net/addrconf.h	2004-02-03 19:44:17.000000000 -0800<br>
+++ linux-2.6.2F2/include/net/addrconf.h	2004-02-11 21:03:10.000000000 -0800<br>
@@ -98,6 +98,7 @@<br>
 <br>
 extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,<br>
 		struct in6_addr *src_addr);<br>
+extern int ipv6_is_mld(struct sk_buff *skb, int nexthdr);<br>
 <br>
 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);<br>
 <br>
diff -ruN linux-2.6.2/net/ipv6/ip6_input.c linux-2.6.2F2/net/ipv6/ip6_input.c<br>
--- linux-2.6.2/net/ipv6/ip6_input.c	2004-02-03 19:44:14.000000000 -0800<br>
+++ linux-2.6.2F2/net/ipv6/ip6_input.c	2004-02-11 21:00:03.000000000 -0800<br>
@@ -168,11 +168,19 @@<br>
 		<br>
 		smp_read_barrier_depends();<br>
 		if (ipprot-&gt;flags &amp; INET6_PROTO_FINAL) {<br>
+			struct ipv6hdr *hdr;	<br>
+<br>
 			if (!cksum_sub &amp;&amp; skb-&gt;ip_summed == CHECKSUM_HW) {<br>
 				skb-&gt;csum = csum_sub(skb-&gt;csum,<br>
 						 &nbsp; &nbsp; csum_partial(skb-&gt;nh.raw, skb-&gt;h.raw-skb-&gt;nh.raw, 0));<br>
 				cksum_sub++;</tt><br>
<tt> 			}<br>
+			hdr = skb-&gt;nh.ipv6h;<br>
+			if (ipv6_addr_is_multicast(&amp;hdr-&gt;daddr) &amp;&amp;<br>
+			 &nbsp; &nbsp;!ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr,<br>
+			 &nbsp; &nbsp;&amp;hdr-&gt;saddr) &amp;&amp;<br>
+			 &nbsp; &nbsp;!ipv6_is_mld(skb, nexthdr))<br>
+				goto discard;<br>
 		}<br>
 		if (!(ipprot-&gt;flags &amp; INET6_PROTO_NOPOLICY) &amp;&amp;<br>
 		 &nbsp; &nbsp;!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) <br>
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
+	 &nbsp; &nbsp;ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr, NULL);<br>
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
-			dst_output(skb2);</tt><br>
<tt> 		}<br>
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
+++ linux-2.6.2F2/net/ipv6/mcast.c	2004-02-11 21:01:52.000000000 -0800<br>
@@ -901,6 +901,33 @@<br>
 }<br>
 <br>
 /*<br>
+ * identify MLD packets for MLD filter exceptions<br>
+ */<br>
+int ipv6_is_mld(struct sk_buff *skb, int nexthdr)<br>
+{<br>
+	struct icmp6hdr *pic;<br>
+<br>
+	if (nexthdr != IPPROTO_ICMPV6)<br>
+		return 0;<br>
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
 &nbsp;*	check if the interface/address pair is valid<br>
 &nbsp;*/<br>
 int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr *group,</tt><br>
<tt>@@ -918,7 +945,7 @@<br>
 				break;<br>
 		}<br>
 		if (mc) {<br>
-			if (!ipv6_addr_any(src_addr)) {<br>
+			if (src_addr &amp;&amp; !ipv6_addr_any(src_addr)) {<br>
 				struct ip6_sf_list *psf;<br>
 <br>
 				spin_lock_bh(&amp;mc-&gt;mca_lock);</tt><br>
<i>(See attached file: mldx6.patch)</i></body></html>

--1__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D--


--0__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D
Content-type: application/octet-stream;
	name="mldx6.patch"
Content-Disposition: attachment; filename="mldx6.patch"
Content-ID: <10__=07BBE4ABDF884A2D8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL2luY2x1ZGUvbmV0L2FkZHJjb25mLmggbGludXgtMi42LjJG
Mi9pbmNsdWRlL25ldC9hZGRyY29uZi5oCi0tLSBsaW51eC0yLjYuMi9pbmNsdWRlL25ldC9hZGRy
Y29uZi5oCTIwMDQtMDItMDMgMTk6NDQ6MTcuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYu
MkYyL2luY2x1ZGUvbmV0L2FkZHJjb25mLmgJMjAwNC0wMi0xMSAyMTowMzoxMC4wMDAwMDAwMDAg
LTA4MDAKQEAgLTk4LDYgKzk4LDcgQEAKIAogZXh0ZXJuIGludCBpcHY2X2Noa19tY2FzdF9hZGRy
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBpbjZfYWRkciAqZ3JvdXAsCiAJCXN0cnVj
dCBpbjZfYWRkciAqc3JjX2FkZHIpOworZXh0ZXJuIGludCBpcHY2X2lzX21sZChzdHJ1Y3Qgc2tf
YnVmZiAqc2tiLCBpbnQgbmV4dGhkcik7CiAKIGV4dGVybiB2b2lkIGFkZHJjb25mX3ByZWZpeF9y
Y3Yoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgdTggKm9wdCwgaW50IGxlbik7CiAKZGlmZiAtcnVO
IGxpbnV4LTIuNi4yL25ldC9pcHY2L2lwNl9pbnB1dC5jIGxpbnV4LTIuNi4yRjIvbmV0L2lwdjYv
aXA2X2lucHV0LmMKLS0tIGxpbnV4LTIuNi4yL25ldC9pcHY2L2lwNl9pbnB1dC5jCTIwMDQtMDIt
MDMgMTk6NDQ6MTQuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMkYyL25ldC9pcHY2L2lw
Nl9pbnB1dC5jCTIwMDQtMDItMTEgMjE6MDA6MDMuMDAwMDAwMDAwIC0wODAwCkBAIC0xNjgsMTEg
KzE2OCwxOSBAQAogCQkKIAkJc21wX3JlYWRfYmFycmllcl9kZXBlbmRzKCk7CiAJCWlmIChpcHBy
b3QtPmZsYWdzICYgSU5FVDZfUFJPVE9fRklOQUwpIHsKKwkJCXN0cnVjdCBpcHY2aGRyICpoZHI7
CQorCiAJCQlpZiAoIWNrc3VtX3N1YiAmJiBza2ItPmlwX3N1bW1lZCA9PSBDSEVDS1NVTV9IVykg
ewogCQkJCXNrYi0+Y3N1bSA9IGNzdW1fc3ViKHNrYi0+Y3N1bSwKIAkJCQkJCSAgICAgY3N1bV9w
YXJ0aWFsKHNrYi0+bmgucmF3LCBza2ItPmgucmF3LXNrYi0+bmgucmF3LCAwKSk7CiAJCQkJY2tz
dW1fc3ViKys7CiAJCQl9CisJCQloZHIgPSBza2ItPm5oLmlwdjZoOworCQkJaWYgKGlwdjZfYWRk
cl9pc19tdWx0aWNhc3QoJmhkci0+ZGFkZHIpICYmCisJCQkgICAgIWlwdjZfY2hrX21jYXN0X2Fk
ZHIoc2tiLT5kZXYsICZoZHItPmRhZGRyLAorCQkJICAgICZoZHItPnNhZGRyKSAmJgorCQkJICAg
ICFpcHY2X2lzX21sZChza2IsIG5leHRoZHIpKQorCQkJCWdvdG8gZGlzY2FyZDsKIAkJfQogCQlp
ZiAoIShpcHByb3QtPmZsYWdzICYgSU5FVDZfUFJPVE9fTk9QT0xJQ1kpICYmCiAJCSAgICAheGZy
bTZfcG9saWN5X2NoZWNrKE5VTEwsIFhGUk1fUE9MSUNZX0lOLCBza2IpKSAKQEAgLTIxMSwxNSAr
MjE5LDE0IEBACiAKIGludCBpcDZfbWNfaW5wdXQoc3RydWN0IHNrX2J1ZmYgKnNrYikKIHsKLQlz
dHJ1Y3QgaXB2NmhkciAqaGRyOwkKLQlpbnQgZGVsaXZlciA9IDA7Ci0JaW50IGRpc2NhcmQgPSAx
OworCXN0cnVjdCBpcHY2aGRyICpoZHI7CisJaW50IGRlbGl2ZXI7CiAKIAlJUDZfSU5DX1NUQVRT
X0JIKElwNkluTWNhc3RQa3RzKTsKIAogCWhkciA9IHNrYi0+bmguaXB2Nmg7Ci0JaWYgKGlwdjZf
Y2hrX21jYXN0X2FkZHIoc2tiLT5kZXYsICZoZHItPmRhZGRyLCAmaGRyLT5zYWRkcikpCi0JCWRl
bGl2ZXIgPSAxOworCWRlbGl2ZXIgPSBsaWtlbHkoIShza2ItPmRldi0+ZmxhZ3MgJiAoSUZGX1BS
T01JU0N8SUZGX0FMTE1VTFRJKSkpIHx8CisJICAgIGlwdjZfY2hrX21jYXN0X2FkZHIoc2tiLT5k
ZXYsICZoZHItPmRhZGRyLCBOVUxMKTsKIAogCS8qCiAJICoJSVB2NiBtdWx0aWNhc3Qgcm91dGVy
IG1vZGUgaXNudCBjdXJyZW50bHkgc3VwcG9ydGVkLgpAQCAtMjM4LDIzICsyNDUsMjEgQEAKIAkJ
CQogCQkJaWYgKGRlbGl2ZXIpIHsKIAkJCQlza2IyID0gc2tiX2Nsb25lKHNrYiwgR0ZQX0FUT01J
Qyk7CisJCQkJZHN0X291dHB1dChza2IyKTsKIAkJCX0gZWxzZSB7Ci0JCQkJZGlzY2FyZCA9IDA7
Ci0JCQkJc2tiMiA9IHNrYjsKKwkJCQlkc3Rfb3V0cHV0KHNrYik7CisJCQkJcmV0dXJuIDA7CiAJ
CQl9Ci0KLQkJCWRzdF9vdXRwdXQoc2tiMik7CiAJCX0KIAl9CiAjZW5kaWYKIAotCWlmIChkZWxp
dmVyKSB7Ci0JCWRpc2NhcmQgPSAwOworCWlmIChsaWtlbHkoZGVsaXZlcikpIHsKIAkJaXA2X2lu
cHV0KHNrYik7CisJCXJldHVybiAwOwogCX0KLQotCWlmIChkaXNjYXJkKQotCQlrZnJlZV9za2Io
c2tiKTsKKwkvKiBkaXNjYXJkICovCisJa2ZyZWVfc2tiKHNrYik7CiAKIAlyZXR1cm4gMDsKIH0K
ZGlmZiAtcnVOIGxpbnV4LTIuNi4yL25ldC9pcHY2L21jYXN0LmMgbGludXgtMi42LjJGMi9uZXQv
aXB2Ni9tY2FzdC5jCi0tLSBsaW51eC0yLjYuMi9uZXQvaXB2Ni9tY2FzdC5jCTIwMDQtMDItMDMg
MTk6NDQ6MjguMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuMkYyL25ldC9pcHY2L21jYXN0
LmMJMjAwNC0wMi0xMSAyMTowMTo1Mi4wMDAwMDAwMDAgLTA4MDAKQEAgLTkwMSw2ICs5MDEsMzMg
QEAKIH0KIAogLyoKKyAqIGlkZW50aWZ5IE1MRCBwYWNrZXRzIGZvciBNTEQgZmlsdGVyIGV4Y2Vw
dGlvbnMKKyAqLworaW50IGlwdjZfaXNfbWxkKHN0cnVjdCBza19idWZmICpza2IsIGludCBuZXh0
aGRyKQoreworCXN0cnVjdCBpY21wNmhkciAqcGljOworCisJaWYgKG5leHRoZHIgIT0gSVBQUk9U
T19JQ01QVjYpCisJCXJldHVybiAwOworCisJaWYgKCFwc2tiX21heV9wdWxsKHNrYiwgc2l6ZW9m
KHN0cnVjdCBpY21wNmhkcikpKQorCQlyZXR1cm4gMDsKKworCXBpYyA9IChzdHJ1Y3QgaWNtcDZo
ZHIgKilza2ItPmgucmF3OworCisJc3dpdGNoIChwaWMtPmljbXA2X3R5cGUpIHsKKwljYXNlIElD
TVBWNl9NR01fUVVFUlk6CisJY2FzZSBJQ01QVjZfTUdNX1JFUE9SVDoKKwljYXNlIElDTVBWNl9N
R01fUkVEVUNUSU9OOgorCWNhc2UgSUNNUFY2X01MRDJfUkVQT1JUOgorCQlyZXR1cm4gMTsKKwlk
ZWZhdWx0OgorCQlicmVhazsKKwl9CisJcmV0dXJuIDA7Cit9CisKKy8qCiAgKgljaGVjayBpZiB0
aGUgaW50ZXJmYWNlL2FkZHJlc3MgcGFpciBpcyB2YWxpZAogICovCiBpbnQgaXB2Nl9jaGtfbWNh
c3RfYWRkcihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2FkZHIgKmdyb3VwLApA
QCAtOTE4LDcgKzk0NSw3IEBACiAJCQkJYnJlYWs7CiAJCX0KIAkJaWYgKG1jKSB7Ci0JCQlpZiAo
IWlwdjZfYWRkcl9hbnkoc3JjX2FkZHIpKSB7CisJCQlpZiAoc3JjX2FkZHIgJiYgIWlwdjZfYWRk
cl9hbnkoc3JjX2FkZHIpKSB7CiAJCQkJc3RydWN0IGlwNl9zZl9saXN0ICpwc2Y7CiAKIAkJCQlz
cGluX2xvY2tfYmgoJm1jLT5tY2FfbG9jayk7Cg==

--0__=07BBE4ABDF884A2D8f9e8a93df938690918c07BBE4ABDF884A2D--
