From: Radu Rendec <radu.rendec@ines.ro>
Subject: Endianness problem with u32 classifier hash masks
Date: Thu, 01 Nov 2007 19:55:01 +0200
Message-ID: <1193939701.2987.82.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:42950 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753228AbXKASKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 14:10:31 -0400
Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1])
	by blade.ines.ro (8.14.1/8.14.1) with ESMTP id lA1Ht1pC008476
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 19:55:18 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

While trying to implement u32 hashes in my shaping machine I ran into a
possible bug in the u32 hash/bucket computing algorithm
(net/sched/cls_u32.c).

The problem occurs only with hash masks that extend over the octet
boundary, on little endian machines (where htonl() actually does
something).

I'm not 100% sure this is a problem with u32 itself, but at least I'm
sure u32 with the same configuration would behave differently on little
endian and big endian machines. Detailed description of the problem and
proposed patch follow.

Let's say that I would like to use 0x3fc0 as the hash mask. This means 8
contiguous "1" bits starting at b6. With such a mask, the expected (and
logical) behavior is to hash any address in, for instance,
192.168.0.0/26 in bucket 0, then any address in 192.168.0.64/26 in
bucket 1, then 192.168.0.128/26 in bucket 2 and so on.

This is exactly what would happen on a big endian machine, but on little
endian machines, what would actually happen with current implementation
is 0x3fc0 being reversed (into 0xc03f0000) by htonl() in the userspace
tool and then applied to 192.168.x.x in the u32 classifier. When
shifting right by 16 bits (rank of first "1" bit in the reversed mask)
and applying the divisor mask (0xff for divisor 256), what would
actually remain is 0x3f applied on the "168" octet of the address.

One could say is this can be easily worked around by taking endianness
into account in userspace and supplying an appropriate mask (0xfc03)
that would be turned into contiguous "1" bits when reversed
(0x03fc0000). But the actual problem is the network address (inside the
packet) not being converted to host order, but used as a host-order
value when computing the bucket.

Let's say the network address is written as n31 n30 ... n0, with n0
being the least significant bit. When used directly (without any
conversion) on a little endian machine, it becomes
n7 ... n0 n8 ..n15 etc in the machine's registers. Thus bits n7 and n8
would no longer be adjacent and 192.168.64.0/26 and 192.168.128.0/26
would no longer be consecutive.

My approach to this issue was keeping the hash mask in host order and
converting the octets in the packet to host order before applying the
mask. This proved to work just fine on my little endian machine, but I'm
interested in finding out (from you) if this really is an issue with u32
itself.

My changes to the u32 classifier are attached below as a patch. It was
made against 2.6.22.9, but applies cleanly on Dave Miller's net-2.6
tree.

The idea behind my changes is to keep the user space tool intact and
work everything out in kernel space (because converting the packet
octets to host order must be done in kernel anyway).

Therefore, hash masks are converted back to host order when a selector
is configured - in u32_change() - and converted to network order
(because userspace tools expect to get them in network order from the
kernel) when a selector is dumped - in u32_dump().

I would like at least to know your opinion about this issue.

Thanks,

Radu Rendec

--- linux-2.6.22.9/net/sched/cls_u32.c.orig	2007-10-30 17:08:03.000000000 +0200
+++ linux-2.6.22.9/net/sched/cls_u32.c	2007-10-30 17:04:49.000000000 +0200
@@ -198,7 +198,7 @@
 		ht = n->ht_down;
 		sel = 0;
 		if (ht->divisor)
-			sel = ht->divisor&u32_hash_fold(*(u32*)(ptr+n->sel.hoff), &n->sel,n->fshift);
+			sel = ht->divisor&u32_hash_fold(ntohl(*(u32*)(ptr+n->sel.hoff)), &n->sel,n->fshift);
 
 		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT)))
 			goto next_ht;
@@ -626,6 +626,10 @@
 	}
 #endif
 
+	/* userspace tc tool sends us the hmask in network order, but we
+	 * need host order, so change it here */
+	s->hmask = ntohl(s->hmask);
+
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 	n->ht_up = ht;
 	n->handle = handle;
@@ -735,9 +739,14 @@
 		u32 divisor = ht->divisor+1;
 		RTA_PUT(skb, TCA_U32_DIVISOR, 4, &divisor);
 	} else {
+		/* get the address where the selector will be put, then
+		 * change the hmask after it is put there */
+		struct tc_u32_sel *s =
+			(struct tc_u32_sel *)RTA_DATA(skb_tail_pointer(skb));
 		RTA_PUT(skb, TCA_U32_SEL,
 			sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
 			&n->sel);
+		s->hmask = htonl(s->hmask);
 		if (n->ht_up) {
 			u32 htid = n->handle & 0xFFFFF000;
 			RTA_PUT(skb, TCA_U32_HASH, 4, &htid);


