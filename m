From: David Stevens <dlstevens@us.ibm.com>
Subject: MLDv1 bug [PATCH]
Date: Thu, 20 Nov 2003 15:33:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF57EBC173.5A7DDA2A-ON88256DE4.007B48CB@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE777DFE8CE5B8f9e8a93df938690918c07BBE777DFE8CE5B"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE777DFE8CE5B8f9e8a93df938690918c07BBE777DFE8CE5B
Content-type: text/plain; charset=US-ASCII





Dave,
      Someone pointed out to me this apparently old bug in MLDv1. According
to RFC 2710:

"MLD messages are never sent for multicast addresses whose scope is 0
(reserved) or 1 (node-local).

MLD messages ARE sent for multicast addresses whose scope is 2
(link-local), including Solicited-Node multicast addersses [ADDR-ARCH],
except for the link-scope, all-nodes address (FF02::1)."

      The current MLDv1 code does not send reports for link-scope addresses
and doesn't restrict scope 0. This may break switches that snoop reports for
determining which ports should receive particular addresses.  Patch below.

                        +-DLS

--- linux-2.6.0-test9-bk23/net/ipv6/mcast.c     2003-11-18 23:20:56.000000000 -0800
+++ linux-2.6.0-test9-bk23F2/net/ipv6/mcast.c   2003-11-20 14:22:51.910526392 -0800
@@ -960,8 +960,9 @@
 {
      unsigned long delay = resptime;

-     /* Do not start timer for addresses with link/host scope */
-     if (ipv6_addr_type(&ma->mca_addr)&(IPV6_ADDR_LINKLOCAL|IPV6_ADDR_LOOPBACK))
+     /* Do not start timer for these addresses */
+     if (ipv6_addr_is_ll_all_nodes(&ma->mca_addr) ||
+         IPV6_ADDR_MC_SCOPE(&ma->mca_addr) < IPV6_ADDR_SCOPE_LINKLOCAL)
            return;

      if (del_timer(&ma->mca_timer)) {

(See attached file: MLDv1LL.patch)
--0__=07BBE777DFE8CE5B8f9e8a93df938690918c07BBE777DFE8CE5B
Content-type: application/octet-stream;
	name="MLDv1LL.patch"
Content-Disposition: attachment; filename="MLDv1LL.patch"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMjMvbmV0L2lwdjYvbWNhc3QuYwkyMDAzLTExLTE4IDIz
OjIwOjU2LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjAtdGVzdDktYmsyM0YyL25ldC9p
cHY2L21jYXN0LmMJMjAwMy0xMS0yMCAxNDoyMjo1MS45MTA1MjYzOTIgLTA4MDAKQEAgLTk2MCw4
ICs5NjAsOSBAQAogewogCXVuc2lnbmVkIGxvbmcgZGVsYXkgPSByZXNwdGltZTsKIAotCS8qIERv
IG5vdCBzdGFydCB0aW1lciBmb3IgYWRkcmVzc2VzIHdpdGggbGluay9ob3N0IHNjb3BlICovCi0J
aWYgKGlwdjZfYWRkcl90eXBlKCZtYS0+bWNhX2FkZHIpJihJUFY2X0FERFJfTElOS0xPQ0FMfElQ
VjZfQUREUl9MT09QQkFDSykpCisJLyogRG8gbm90IHN0YXJ0IHRpbWVyIGZvciB0aGVzZSBhZGRy
ZXNzZXMgKi8KKwlpZiAoaXB2Nl9hZGRyX2lzX2xsX2FsbF9ub2RlcygmbWEtPm1jYV9hZGRyKSB8
fAorCSAgICBJUFY2X0FERFJfTUNfU0NPUEUoJm1hLT5tY2FfYWRkcikgPCBJUFY2X0FERFJfU0NP
UEVfTElOS0xPQ0FMKQogCQlyZXR1cm47CiAKIAlpZiAoZGVsX3RpbWVyKCZtYS0+bWNhX3RpbWVy
KSkgewo=

--0__=07BBE777DFE8CE5B8f9e8a93df938690918c07BBE777DFE8CE5B--
