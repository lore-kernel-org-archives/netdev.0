From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 12:00:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
References: <20080717214222.GA29449@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net, johnpol@2ka.mipt.ru
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51471 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbYGRJAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:00:49 -0400
In-Reply-To: <20080717214222.GA29449@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ingo,

On Thu, 17 Jul 2008, Ingo Molnar wrote:
> A regression to v2.6.26:
> 
> I started getting this skb-head corruption message today, on a T60 
> laptop with e1000:

[snip]
 
On Thu, 17 Jul 2008, Ingo Molnar wrote:
> Perhaps SLUB debugging got smarter?

Nope.

On Thu, 17 Jul 2008, Ingo Molnar wrote:
> PM: Removing info for No Bus:vcs11
> device: 'vcs11': device_create_release
> =============================================================================
> BUG skbuff_head_cache: Poison overwritten
> -----------------------------------------------------------------------------
> 
> INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b

0x6b is POISON_FREE so 0x6a is one bit corruption.

> INFO: Allocated in __alloc_skb+0x2c/0x110 age=0 cpu=0 pid=5098
> INFO: Freed in __kfree_skb+0x31/0x80 age=0 cpu=1 pid=4440
> INFO: Slab 0xc16cc140 objects=16 used=1 fp=0xf658ae00 flags=0x400000c3
> INFO: Object 0xf658ae00 @offset=3584 fp=0xf658af00
> 
> Bytes b4 0xf658adf0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>   Object 0xf658ae00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>   Object 0xf658ae70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk

It's bit unfortunate that we don't see full dump of the corruption here 
because SLUB limits the output to 128 bytes. Ingo, you might want to try 
this patch so that we can see all of it:

diff --git a/mm/slub.c b/mm/slub.c
index 5f6e2c4..f69d181 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -492,7 +492,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	if (p > addr + 16)
 		print_section("Bytes b4", p - 16, 16);
 
-	print_section("Object", p, min(s->objsize, 128));
+	print_section("Object", p, s->objsize);
 
 	if (s->flags & SLAB_RED_ZONE)
 		print_section("Redzone", p + s->objsize,
