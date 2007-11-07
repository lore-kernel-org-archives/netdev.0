From: David Miller <davem@davemloft.net>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Wed, 07 Nov 2007 01:22:20 -0800 (PST)
Message-ID: <20071107.012220.17723288.davem@davemloft.net>
References: <20071106142558.GC1666@ff.dom.local>
	<1194360226.4444.39.camel@localhost>
	<1194368416.2987.218.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jarkao2@o2.pl, netdev@vger.kernel.org
To: radu.rendec@ines.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755008AbXKGJWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 04:22:21 -0500
In-Reply-To: <1194368416.2987.218.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Radu Rendec <radu.rendec@ines.ro>
Date: Tue, 06 Nov 2007 19:00:16 +0200

> On Tue, 2007-11-06 at 09:43 -0500, jamal wrote:
> > On Tue, 2007-06-11 at 15:25 +0100, Jarek Poplawski wrote:
> > 
> > > Yes, it saves one htonl() on the slow path!
> > 
> > Would it feel better to say grew down exponentially from version 1 to
> > 3? ;->
> 
> Not only it saves one htonl(), but also keeps the code readable :)
> Computing offsets within the rtnetlink response skb and applying htonl()
> there is quite tricky and might get broken if RTA_PUT() is changed.
> Unfortunately I spent about an hour figuring out how to do that :))
> 
> The bad news is that today I haven't got the chance to work on the two
> patches. But the good news is that I managed to finish the (urgent) task
> that had been assigned to me at work, and tomorrow I will be able to
> work on the kernel and test it leisurely.

I've grown impatient and done the work for you :-)  I've applied
the patch below to my tree, thank you!

If someone wants to send me the ffs() thing relative to this,
I'd appreciate it.  Thanks again!

>From 8e36263f10a054479636b57943cdeaf37470acc5 Mon Sep 17 00:00:00 2001
From: Radu Rendec <radu.rendec@ines.ro>
Date: Wed, 7 Nov 2007 01:20:12 -0800
Subject: [PATCH] [PKT_SCHED] CLS_U32: Fix endianness problem with u32 classifier hash masks.

From: Radu Rendec <radu.rendec@ines.ro>

While trying to implement u32 hashes in my shaping machine I ran into
a possible bug in the u32 hash/bucket computing algorithm
(net/sched/cls_u32.c).

The problem occurs only with hash masks that extend over the octet
boundary, on little endian machines (where htonl() actually does
something).

Let's say that I would like to use 0x3fc0 as the hash mask. This means
8 contiguous "1" bits starting at b6. With such a mask, the expected
(and logical) behavior is to hash any address in, for instance,
192.168.0.0/26 in bucket 0, then any address in 192.168.0.64/26 in
bucket 1, then 192.168.0.128/26 in bucket 2 and so on.

This is exactly what would happen on a big endian machine, but on
little endian machines, what would actually happen with current
implementation is 0x3fc0 being reversed (into 0xc03f0000) by htonl()
in the userspace tool and then applied to 192.168.x.x in the u32
classifier. When shifting right by 16 bits (rank of first "1" bit in
the reversed mask) and applying the divisor mask (0xff for divisor
256), what would actually remain is 0x3f applied on the "168" octet of
the address.

One could say is this can be easily worked around by taking endianness
into account in userspace and supplying an appropriate mask (0xfc03)
that would be turned into contiguous "1" bits when reversed
(0x03fc0000). But the actual problem is the network address (inside
the packet) not being converted to host order, but used as a
host-order value when computing the bucket.

Let's say the network address is written as n31 n30 ... n0, with n0
being the least significant bit. When used directly (without any
conversion) on a little endian machine, it becomes n7 ... n0 n8 ..n15
etc in the machine's registers. Thus bits n7 and n8 would no longer be
adjacent and 192.168.64.0/26 and 192.168.128.0/26 would no longer be
consecutive.

The fix is to apply ntohl() on the hmask before computing fshift,
and in u32_hash_fold() convert the packet data to host order before
shifting down by fshift.

With helpful feedback from Jamal Hadi Salim and Jarek Poplawski.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/cls_u32.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9e98c6e..5317102 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -91,7 +91,7 @@ static struct tc_u_common *u32_list;
 
 static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fshift)
 {
-	unsigned h = (key & sel->hmask)>>fshift;
+	unsigned h = ntohl(key & sel->hmask)>>fshift;
 
 	return h;
 }
@@ -615,7 +615,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	n->handle = handle;
 {
 	u8 i = 0;
-	u32 mask = s->hmask;
+	u32 mask = ntohl(s->hmask);
 	if (mask) {
 		while (!(mask & 1)) {
 			i++;
-- 
1.5.3.5

