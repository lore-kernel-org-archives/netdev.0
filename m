From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : secure sequence number functions can use nsec
 resolution instead of usec
Date: Wed, 28 Mar 2007 17:43:22 +0200
Message-ID: <20070328174322.5d806dd0.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38020 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932433AbXC1PnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 11:43:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David

We could use the nanosec resolution for various functions defined in drivers/char/random.c
(secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number())

I am not sure if it's a netdev related patch or core kernel, so I have CC Andrew.

Thank you

[PATCH] NET : random functions can use nsec resolution instead of usec

In order to get more randomness for secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number() functions, we can use the high resolution time services, providing nanosec resolution.

I've also done two kmalloc()/kzalloc() conversions.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--- linux-2.6.21-rc5/drivers/char/random.c
+++ linux-2.6.21-rc5-ed/drivers/char/random.c
@@ -881,15 +881,15 @@ EXPORT_SYMBOL(get_random_bytes);
  */
 static void init_std_data(struct entropy_store *r)
 {
-	struct timeval tv;
+	ktime_t now;
 	unsigned long flags;
 
 	spin_lock_irqsave(&r->lock, flags);
 	r->entropy_count = 0;
 	spin_unlock_irqrestore(&r->lock, flags);
 
-	do_gettimeofday(&tv);
-	add_entropy_words(r, (__u32 *)&tv, sizeof(tv)/4);
+	now = ktime_get_real();
+	add_entropy_words(r, (__u32 *)&now, sizeof(now)/4);
 	add_entropy_words(r, (__u32 *)utsname(),
 			  sizeof(*(utsname()))/4);
 }
@@ -911,14 +911,12 @@ void rand_initialize_irq(int irq)
 		return;
 
 	/*
-	 * If kmalloc returns null, we just won't use that entropy
+	 * If kzalloc returns null, we just won't use that entropy
 	 * source.
 	 */
-	state = kmalloc(sizeof(struct timer_rand_state), GFP_KERNEL);
-	if (state) {
-		memset(state, 0, sizeof(struct timer_rand_state));
+	state = kzalloc(sizeof(struct timer_rand_state), GFP_KERNEL);
+	if (state)
 		irq_timer_state[irq] = state;
-	}
 }
 
 #ifdef CONFIG_BLOCK
@@ -927,14 +925,12 @@ void rand_initialize_disk(struct gendisk
 	struct timer_rand_state *state;
 
 	/*
-	 * If kmalloc returns null, we just won't use that entropy
+	 * If kzalloc returns null, we just won't use that entropy
 	 * source.
 	 */
-	state = kmalloc(sizeof(struct timer_rand_state), GFP_KERNEL);
-	if (state) {
-		memset(state, 0, sizeof(struct timer_rand_state));
+	state = kzalloc(sizeof(struct timer_rand_state), GFP_KERNEL);
+	if (state)
 		disk->random = state;
-	}
 }
 #endif
 
@@ -1469,7 +1465,6 @@ late_initcall(seqgen_init);
 __u32 secure_tcpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 				   __be16 sport, __be16 dport)
 {
-	struct timeval tv;
 	__u32 seq;
 	__u32 hash[12];
 	struct keydata *keyptr = get_keyptr();
@@ -1485,8 +1480,7 @@ __u32 secure_tcpv6_sequence_number(__be3
 	seq = twothirdsMD4Transform((const __u32 *)daddr, hash) & HASH_MASK;
 	seq += keyptr->count;
 
-	do_gettimeofday(&tv);
-	seq += tv.tv_usec + tv.tv_sec * 1000000;
+	seq += ktime_get_real().tv64;
 
 	return seq;
 }
@@ -1521,7 +1515,6 @@ __u32 secure_ip_id(__be32 daddr)
 __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 				 __be16 sport, __be16 dport)
 {
-	struct timeval tv;
 	__u32 seq;
 	__u32 hash[4];
 	struct keydata *keyptr = get_keyptr();
@@ -1543,12 +1536,11 @@ __u32 secure_tcp_sequence_number(__be32 
 	 *	As close as possible to RFC 793, which
 	 *	suggests using a 250 kHz clock.
 	 *	Further reading shows this assumes 2 Mb/s networks.
-	 *	For 10 Mb/s Ethernet, a 1 MHz clock is appropriate.
+	 *	For 10 Gb/s Ethernet, a 1 GHz clock is appropriate.
 	 *	That's funny, Linux has one built in!  Use it!
 	 *	(Networks are faster now - should this be increased?)
 	 */
-	do_gettimeofday(&tv);
-	seq += tv.tv_usec + tv.tv_sec * 1000000;
+	seq += ktime_get_real().tv64;
 #if 0
 	printk("init_seq(%lx, %lx, %d, %d) = %d\n",
 	       saddr, daddr, sport, dport, seq);
@@ -1598,7 +1590,6 @@ u32 secure_ipv6_port_ephemeral(const __b
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport)
 {
-	struct timeval tv;
 	u64 seq;
 	__u32 hash[4];
 	struct keydata *keyptr = get_keyptr();
@@ -1611,8 +1602,7 @@ u64 secure_dccp_sequence_number(__be32 s
 	seq = half_md4_transform(hash, keyptr->secret);
 	seq |= ((u64)keyptr->count) << (32 - HASH_BITS);
 
-	do_gettimeofday(&tv);
-	seq += tv.tv_usec + tv.tv_sec * 1000000;
+	seq += ktime_get_real().tv64;
 	seq &= (1ull << 48) - 1;
 #if 0
 	printk("dccp init_seq(%lx, %lx, %d, %d) = %d\n",
