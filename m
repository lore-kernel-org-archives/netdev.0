From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Thu, 06 May 2010 22:02:21 -0700 (PDT)
Message-ID: <20100506.220221.90798296.davem@davemloft.net>
References: <1273037049.2304.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, therbert@google.com,
	monstr@monstr.eu, microblaze-uclinux@itee.uq.edu.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41256
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751721Ab0EGFCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:02:16 -0400
In-Reply-To: <1273037049.2304.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 May 2010 07:24:09 +0200

> eth_type_trans() & get_rps_cpus() currently need two 64bytes cache lines
> in packet to compute rxhash.
> 
> Increasing NET_SKB_PAD from 32 to 64 reduces the need to one cache line
> only, and makes RPS faster.
> 
> NET_IP_ALIGN(2) + ethernet_header(14) + IP_header(20/40) + ports(8)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

Seeing this made me go check who was overriding NET_IP_ALIGN or
NET_SKB_PAD.

The powerpc bits are legitimate, but the microblaze case is complete
bogosity.  It defines NET_IP_ALIGN to the default (2) and sets
NET_SKB_PAD to L1_CACHE_BYTES which on microblaze is 4 and
significantly smaller than the default.

So I'm going to delete them in net-next-2.6 like so:

--------------------
microblaze: Kill NET_SKB_PAD and NET_IP_ALIGN overrides.

NET_IP_ALIGN defaults to 2, no need to override.

NET_SKB_PAD is now 64, which is much larger than microblaze's
L1_CACHE_SIZE so no need to override that either.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/microblaze/include/asm/system.h |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/include/asm/system.h
index 48c4f03..b1e2f07 100644
--- a/arch/microblaze/include/asm/system.h
+++ b/arch/microblaze/include/asm/system.h
@@ -97,14 +97,4 @@ extern struct dentry *of_debugfs_root;
 
 #define arch_align_stack(x) (x)
 
-/*
- * MicroBlaze doesn't handle unaligned accesses in hardware.
- *
- * Based on this we force the IP header alignment in network drivers.
- * We also modify NET_SKB_PAD to be a cacheline in size, thus maintaining
- * cacheline alignment of buffers.
- */
-#define NET_IP_ALIGN	2
-#define NET_SKB_PAD	L1_CACHE_BYTES
-
 #endif /* _ASM_MICROBLAZE_SYSTEM_H */
-- 
1.7.0.4

