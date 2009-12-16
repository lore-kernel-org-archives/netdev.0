From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [RFC 2/2] udp: udp_lib_get_port start at a different bucket on different
 processors
Date: Wed, 16 Dec 2009 21:24:44 +0200
Message-ID: <4B2933FC.7070306@ixiacom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080401020805040000040102"
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:17012 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935559AbZLPTYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 14:24:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080401020805040000040102
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


On SMP, when ports are not allocated randomly, using the same starting
port on all processors will lead to bad performance as all processors
will try to get the same hashbucket spinlock: only one will succeed,
the rest will spin madly.

We solve this problem by making each processor start searching from a
different port. To not skip possibly valid port ranges we renormalize
the hint value too.

Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
  net/ipv4/udp.c |   12 +++++++++---
  1 files changed, 9 insertions(+), 3 deletions(-)



--------------080401020805040000040102
Content-Type: text/x-patch;
 name="0002-udp-udp_lib_get_port-start-at-a-different-bucket-on-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-udp-udp_lib_get_port-start-at-a-different-bucket-on-.pa";
 filename*1="tch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f437d9d..5d17c71 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -219,7 +219,9 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			first = (((u64)rand * remaining) >> 32) + low;
 		} else {
 			rand = 1;
-			first = hint;
+			first = hint + smp_processor_id();
+			if (first > high)
+				first = low + (first - low) % remaining;
 		}
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
@@ -243,8 +245,12 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			do {
 				if (low <= snum && snum <= high &&
 				    !test_bit(snum >> udptable->log, bitmap)) {
-					if (unlikely(!sysctl_udp_port_randomization))
-						hint = snum;
+					if (unlikely(!sysctl_udp_port_randomization)) {
+						int cur_hint = snum - smp_processor_id();
+						if (cur_hint < low)
+							cur_hint = high - (low - cur_hint) % remaining;
+						hint = cur_hint;
+					}
 					goto found;
 				}
 				snum += rand;


--------------080401020805040000040102--
