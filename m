From: Mark Huth <mhuth@mvista.com>
Subject: tcp_ipv6_check_established
Date: Tue, 11 May 2004 16:37:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A163A4.8050905@mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090806020709090101070306"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090806020709090101070306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

There appears to be a long-standing bug in tcp_ipv6_check_established 
that results in the return of EADDRNOTAVAILABLE from connect().  It can 
be demonstrated in the following scenario:

The following scenario fails in most known ipv6 linuxes

All within a single node.

Host has two IPv6 addresses:
    dead:dead:dead:dead::1/128
    dead:dead:dead:dead::2/128

Application A creates two listening sockets:
    dead:dead:dead:dead::1 49997
    dead:dead:dead:dead::2 49997

Application B creates a TCP-connection:
    from dead:dead:dead:dead::1 49998 to dead:dead:dead:dead::2 49997

Application C creates a TCP-connection:
    from dead:dead:dead:dead::2 49998 to dead:dead:dead:dead::1 49997

However, the latter operation fails, and connect() returns
EADDRNOTAVAILABLE.  Meaning that the host already has such a connection and
the new one cannot be created.	Clearly there is no identical connection
used (different ports), thus connect() misbehaves.

All sockets use SO_REUSEADDR-option, and all sockets bind() their source
address and source ports before the attempted connect().

While the above may be somewhat contrived, the code is wrong by inspection.
The check for the established connections interates on sk2, while the macro
argument for TCP_IPV6_MATCH is sk.  Thus the check result is invarient over the loop.

A proposed patch for 2.6.6 is attached.  A similar patch is required for 2.4 kernels, and is
also attached.

Mark Huth




--------------090806020709090101070306
Content-Type: application/octet-stream;
 name="tcp_ipv6_check_est-2.6.6.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tcp_ipv6_check_est-2.6.6.patch"

ZGlmZiAtdXIgbGludXgtMi42LjYvbmV0L2lwdjYvdGNwX2lwdjYuYyBsaW51eC0yLjYuNi1w
YXRjaC9uZXQvaXB2Ni90Y3BfaXB2Ni5jCi0tLSBsaW51eC0yLjYuNi9uZXQvaXB2Ni90Y3Bf
aXB2Ni5jCTIwMDQtMDUtMDkgMTk6MzI6MzguMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0y
LjYuNi1wYXRjaC9uZXQvaXB2Ni90Y3BfaXB2Ni5jCTIwMDQtMDUtMTEgMTE6MTk6MjQuMDAw
MDAwMDAwIC0wNzAwCkBAIC00NzksNyArNDc5LDcgQEAKIAogCS8qIEFuZCBlc3RhYmxpc2hl
ZCBwYXJ0Li4uICovCiAJc2tfZm9yX2VhY2goc2syLCBub2RlLCAmaGVhZC0+Y2hhaW4pIHsK
LQkJaWYoVENQX0lQVjZfTUFUQ0goc2ssIHNhZGRyLCBkYWRkciwgcG9ydHMsIGRpZikpCisJ
CWlmKFRDUF9JUFY2X01BVENIKHNrMiwgc2FkZHIsIGRhZGRyLCBwb3J0cywgZGlmKSkKIAkJ
CWdvdG8gbm90X3VuaXF1ZTsKIAl9CiAK
--------------090806020709090101070306
Content-Type: application/octet-stream;
 name="tcp_ipv6_check_est-2.4.20.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tcp_ipv6_check_est-2.4.20.patch"

ZGlmZiAtdXIgLS1leGNsdWRlIENWUyBsaW51eC9uZXQvaXB2Ni90Y3BfaXB2Ni5jIGxpbnV4
X3BhdGNoL25ldC9pcHY2L3RjcF9pcHY2LmMKLS0tIGxpbnV4L25ldC9pcHY2L3RjcF9pcHY2
LmMJMjAwMy0xMC0wMiAxMjowMzo1My4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4X3BhdGNo
L25ldC9pcHY2L3RjcF9pcHY2LmMJMjAwNC0wNS0xMCAxODowMDoxNC4wMDAwMDAwMDAgLTA3
MDAKQEAgLTQ1NCw3ICs0NTQsNyBAQAogCXR3ID0gTlVMTDsKIAogCWZvcihza3AgPSAmaGVh
ZC0+Y2hhaW47IChzazI9KnNrcCkhPU5VTEw7IHNrcCA9ICZzazItPm5leHQpIHsKLQkJaWYo
VENQX0lQVjZfTUFUQ0goc2ssIHNhZGRyLCBkYWRkciwgcG9ydHMsIGRpZikpCisJCWlmKFRD
UF9JUFY2X01BVENIKHNrMiwgc2FkZHIsIGRhZGRyLCBwb3J0cywgZGlmKSkKIAkJCWdvdG8g
bm90X3VuaXF1ZTsKIAl9CiAK
--------------090806020709090101070306--
