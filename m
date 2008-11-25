From: Olivier Fourdan <ofourdan@redhat.com>
Subject: [PATCH] ip maddr =?windows-1252?Q?show=94_on_an_infiniband?=
 =?windows-1252?Q?_address_causes_a_stack_corruption?=
Date: Tue, 25 Nov 2008 12:36:22 +0000
Message-ID: <492BF146.5010808@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010100080606090206060303"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52750 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068AbYKYMg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 07:36:26 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mAPCaON4019015
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 07:36:24 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mAPCaOih031655
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 07:36:24 -0500
Received: from ofourdan.csb (dhcp-1-85.fab.redhat.com [10.33.1.85])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mAPCaNZe018287
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 07:36:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010100080606090206060303
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

ìip maddr showî on an infiniband address causes a stack corruption 
because the length of the address for Infiniband (20 bytes, as 
described in kernel doc Documentation/infiniband/ipoib.txt) does not 
fit on the 16 bytes of the field in which it gets stored.

The proposed patch increases the size of the hardware address from 4 
__u32 to 8 and also adds a check to avoid overriding the available 
size while parsing the hardware address.

This bug affects current upstream code AFAICT.

Hope this helps,
Cheers,
Olivier.


--------------010100080606090206060303
Content-Type: text/x-patch;
 name="iproute2-2.6.26-check-hwaddr-size.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
 filename="iproute2-2.6.26-check-hwaddr-size.patch"

‚Äúip maddr show ib0‚Äù causes a stack corruption because the length of the address
for Infiniband (20 see kernel doc Documentation/infiniband/ipoib.txt) does not 
fit on the 16 bytes of the field in which it gets stored.

The proposed patch increases the size of the hardware address from 4 u32 to 8 
and adds a check to avoid overriding the available size while parsing the 
hardware address.

This bug affects current upstream code and should be reported upstream.

 include/utils.h |    2 +-
 ip/ipmaddr.c    |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

--- iproute2-2.6.26/include/utils.h.hwaddrsize	2008-11-25 11:02:30.000000000 +0000
+++ iproute2-2.6.26/include/utils.h	2008-11-25 11:08:28.000000000 +0000
@@ -46,7 +46,7 @@
 	__u8 bytelen;
 	__s16 bitlen;
 	__u32 flags;
-	__u32 data[4];
+	__u32 data[8];
 } inet_prefix;
 
 #define PREFIXLEN_SPECIFIED 1
--- iproute2-2.6.26/ip/ipmaddr.c.hwaddrsize	2008-11-25 11:02:51.000000000 +0000
+++ iproute2-2.6.26/ip/ipmaddr.c	2008-11-25 11:08:26.000000000 +0000
@@ -43,11 +43,11 @@
 	exit(-1);
 }
 
-static int parse_hex(char *str, unsigned char *addr)
+static int parse_hex(char *str, unsigned char *addr, size_t size)
 {
 	int len=0;
 
-	while (*str) {
+	while (*str && (len < 2 * size)) {
 		int tmp;
 		if (str[1] == 0)
 			return -1;
@@ -104,7 +104,7 @@
 
 		m.addr.family = AF_PACKET;
 
-		len = parse_hex(hexa, (unsigned char*)&m.addr.data);
+		len = parse_hex(hexa, (unsigned char*)&m.addr.data, sizeof (m.addr.data));
 		if (len >= 0) {
 			struct ma_info *ma = malloc(sizeof(m));
 
@@ -176,7 +176,7 @@
 
 		m.addr.family = AF_INET6;
 
-		len = parse_hex(hexa, (unsigned char*)&m.addr.data);
+		len = parse_hex(hexa, (unsigned char*)&m.addr.data, sizeof (m.addr.data));
 		if (len >= 0) {
 			struct ma_info *ma = malloc(sizeof(m));
 


--------------010100080606090206060303--
