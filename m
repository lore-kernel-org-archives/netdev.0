From: David Stevens <dlstevens@us.ibm.com>
Subject: [IPV6] send ICMPv6 error on scope violations
Date: Wed, 9 May 2007 13:55:15 -0600
Message-ID: <OFA075DC7D.6AB1CB33-ON882572D6.006CBBA4-882572D6.006D635E@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 006D6356882572D6_="
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:45426 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbXEITzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 15:55:22 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l49JtI9d007187
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 15:55:18 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l49JtHNb170996
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 13:55:17 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l49JtHgp021563
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 13:55:17 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 006D6356882572D6_=
Content-Type: text/plain; charset="US-ASCII"

When an IPv6 router is forwarding a packet with a link-local scope source
address off-link, RFC 4007 requires it to send an ICMPv6 destination
unreachable with code 2 ("not neighbor"), but Linux doesn't. Fix below.

                                                +-DLS
[in-line for viewing, attached for applying]

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

--- linux-2.6.20.7/net/ipv6/ip6_output.c        2007-04-13 
13:48:14.000000000 -0700
+++ linux-2.6.20.7T1/net/ipv6/ip6_output.c      2007-05-09 
12:32:45.000000000 -0700
@@ -449,10 +449,17 @@ int ip6_forward(struct sk_buff *skb)
                 */
                if (xrlim_allow(dst, 1*HZ))
                        ndisc_send_redirect(skb, n, target);
-       } else if 
(ipv6_addr_type(&hdr->saddr)&(IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK
-                                               |IPV6_ADDR_LINKLOCAL)) {
+       } else {
+               int addrtype = ipv6_addr_type(&hdr->saddr);
+
                /* This check is security critical. */
-               goto error;
+               if (addrtype & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK))
+                       goto error;
+               if (addrtype & IPV6_ADDR_LINKLOCAL) {
+                       icmpv6_send(skb, ICMPV6_DEST_UNREACH,
+                               ICMPV6_NOT_NEIGHBOUR, 0, skb->dev);
+                       goto error;
+               }
        }
 
        if (skb->len > dst_mtu(dst)) {



--=_mixed 006D6356882572D6_=
Content-Type: application/octet-stream; name="icmp6fix.patch"
Content-Disposition: attachment; filename="icmp6fix.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi4yMC43L25ldC9pcHY2L2lwNl9vdXRwdXQuYwkyMDA3LTA0LTEzIDEzOjQ4
OjE0LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjIwLjdUMS9uZXQvaXB2Ni9pcDZfb3V0
cHV0LmMJMjAwNy0wNS0wOSAxMjozMjo0NS4wMDAwMDAwMDAgLTA3MDAKQEAgLTQ0OSwxMCArNDQ5
LDE3IEBAIGludCBpcDZfZm9yd2FyZChzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogCQkgKi8KIAkJaWYg
KHhybGltX2FsbG93KGRzdCwgMSpIWikpCiAJCQluZGlzY19zZW5kX3JlZGlyZWN0KHNrYiwgbiwg
dGFyZ2V0KTsKLQl9IGVsc2UgaWYgKGlwdjZfYWRkcl90eXBlKCZoZHItPnNhZGRyKSYoSVBWNl9B
RERSX01VTFRJQ0FTVHxJUFY2X0FERFJfTE9PUEJBQ0sKLQkJCQkJCXxJUFY2X0FERFJfTElOS0xP
Q0FMKSkgeworCX0gZWxzZSB7CisJCWludCBhZGRydHlwZSA9IGlwdjZfYWRkcl90eXBlKCZoZHIt
PnNhZGRyKTsKKwogCQkvKiBUaGlzIGNoZWNrIGlzIHNlY3VyaXR5IGNyaXRpY2FsLiAqLwotCQln
b3RvIGVycm9yOworCQlpZiAoYWRkcnR5cGUgJiAoSVBWNl9BRERSX01VTFRJQ0FTVHxJUFY2X0FE
RFJfTE9PUEJBQ0spKQorCQkJZ290byBlcnJvcjsKKwkJaWYgKGFkZHJ0eXBlICYgSVBWNl9BRERS
X0xJTktMT0NBTCkgeworCQkJaWNtcHY2X3NlbmQoc2tiLCBJQ01QVjZfREVTVF9VTlJFQUNILAor
CQkJCUlDTVBWNl9OT1RfTkVJR0hCT1VSLCAwLCBza2ItPmRldik7CisJCQlnb3RvIGVycm9yOwor
CQl9CiAJfQogCiAJaWYgKHNrYi0+bGVuID4gZHN0X210dShkc3QpKSB7Cg==

--=_mixed 006D6356882572D6_=--
