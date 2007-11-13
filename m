From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET] random : secure_tcp_sequence_number should not assume CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 14:41:19 +0100
Message-ID: <4739A97F.60206@cosmosbay.com>
References: <47398ADD.2030509@cosmosbay.com> <20071113.035019.268404275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090607030807040600020403"
Cc: netdev@vger.kernel.org, kaber@trash.net, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.111]:17452 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240AbXKMNlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 08:41:24 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2e03.orange.fr (SMTP Server) with ESMTP id E6086700008F
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 14:41:22 +0100 (CET)
In-Reply-To: <20071113.035019.268404275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090607030807040600020403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I discovered one other incorrect use of .tv64 (coming from me, I must 
confess)

I guess this patch is  needed for 2.6.24 and stable (2.6.22 & 2.6.23)

Thank you

[NET] random : secure_tcp_sequence_number should not assume 
CONFIG_KTIME_SCALAR

All 32 bits machines but i386 dont have CONFIG_KTIME_SCALAR. On these 
machines, ktime.tv64
is more than 4 times the (correct) result given by ktime_to_ns()

Again on these machines, using ktime_get_real().tv64 >> 6 give a 32bits 
rollover every 64 seconds,
which is not wanted (less than the 120 s MSL)

Using ktime_to_ns() is the portable way to get nsecs from a ktime, and 
have correct code.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------090607030807040600020403
Content-Type: text/plain;
 name="random.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="random.patch"

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 1756b1f..5fee056 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1494,7 +1494,7 @@ __u32 secure_tcpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 	seq = twothirdsMD4Transform((const __u32 *)daddr, hash) & HASH_MASK;
 	seq += keyptr->count;
 
-	seq += ktime_get_real().tv64;
+	seq += ktime_to_ns(ktime_get_real());
 
 	return seq;
 }
@@ -1556,7 +1556,7 @@ __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 	 *	overlaps less than one time per MSL (2 minutes).
 	 *	Choosing a clock of 64 ns period is OK. (period of 274 s)
 	 */
-	seq += ktime_get_real().tv64 >> 6;
+	seq += ktime_to_ns(ktime_get_real()) >> 6;
 #if 0
 	printk("init_seq(%lx, %lx, %d, %d) = %d\n",
 	       saddr, daddr, sport, dport, seq);
@@ -1616,7 +1616,7 @@ u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 	seq = half_md4_transform(hash, keyptr->secret);
 	seq |= ((u64)keyptr->count) << (32 - HASH_BITS);
 
-	seq += ktime_get_real().tv64;
+	seq += ktime_to_ns(ktime_get_real());
 	seq &= (1ull << 48) - 1;
 #if 0
 	printk("dccp init_seq(%lx, %lx, %d, %d) = %d\n",

--------------090607030807040600020403--


