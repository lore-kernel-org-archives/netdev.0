From: David Miller <davem@davemloft.net>
Subject: Re: arm64: next-20170428 hangs on boot
Date: Fri, 28 Apr 2017 12:05:32 -0400 (EDT)
Message-ID: <20170428.120532.2008072008826207366.davem@davemloft.net>
References: <20170428132429.c3dlxbmt7iqs2isl@yury-N73SV>
        <20170428145233.GB5292@leverpostej>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ynorov@caviumnetworks.com, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55880 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756789AbdD1QFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:05:34 -0400
In-Reply-To: <20170428145233.GB5292@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rutland <mark.rutland@arm.com>
Date: Fri, 28 Apr 2017 15:52:34 +0100

> On Fri, Apr 28, 2017 at 04:24:29PM +0300, Yury Norov wrote:
>> Hi all,
> 
> Hi,
> 
> [adding Dave Miller, netdev, lkml]
> 
>> On QEMU the next-20170428 hangs on boot for me due to kernel panic in 
>> rtnetlink_init():
>> 
>> void __init rtnetlink_init(void)
>> {
>>         if (register_pernet_subsys(&rtnetlink_net_ops))
>>                 panic("rtnetlink_init: cannot initialize rtnetlink\n");
>> 
>>         ...
>> }
> 
> I see the same thing with a next-20170428 arm64 defconfig, on a Juno R1
> system:

As stated, should be fixed by:

>From 2d2ab658d2debcb4c0e29c9e6f18e5683f3077bf Mon Sep 17 00:00:00 2001
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Apr 2017 14:10:48 +0800
Subject: [PATCH] rhashtable: Do not lower max_elems when max_size is zero

The commit 6d684e54690c ("rhashtable: Cap total number of entries
to 2^31") breaks rhashtable users that do not set max_size.  This
is because when max_size is zero max_elems is also incorrectly set
to zero instead of 2^31.

This patch fixes it by only lowering max_elems when max_size is not
zero.

Fixes: 6d684e54690c ("rhashtable: Cap total number of entries to 2^31")
Reported-by: Florian Fainelli <f.fainelli@gmail.com>
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 lib/rhashtable.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 751630b..3895486 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -958,13 +958,14 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->min_size)
 		ht->p.min_size = roundup_pow_of_two(params->min_size);
 
-	if (params->max_size)
-		ht->p.max_size = rounddown_pow_of_two(params->max_size);
-
 	/* Cap total entries at 2^31 to avoid nelems overflow. */
 	ht->max_elems = 1u << 31;
-	if (ht->p.max_size < ht->max_elems / 2)
-		ht->max_elems = ht->p.max_size * 2;
+
+	if (params->max_size) {
+		ht->p.max_size = rounddown_pow_of_two(params->max_size);
+		if (ht->p.max_size < ht->max_elems / 2)
+			ht->max_elems = ht->p.max_size * 2;
+	}
 
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
-- 
2.4.11
