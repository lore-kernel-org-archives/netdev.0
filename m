From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Mon, 28 Apr 2008 03:30:22 -0700 (PDT)
Message-ID: <20080428.033022.166259760.davem@davemloft.net>
References: <48157685.1040709@openvz.org>
	<20080428093130.GA1011@flint.arm.linux.org.uk>
	<20080428101835.GA13522@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, netfilter@vger.kernel.org
To: rmk@arm.linux.org.uk
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20080428101835.GA13522@flint.arm.linux.org.uk>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King <rmk@arm.linux.org.uk>
Date: Mon, 28 Apr 2008 11:18:35 +0100

> Further to this, it's looking like there's a nf_conntrack issue.  Having
> placed similar printks in the netfilter code, I see the ipv4_confirm()
> hook normally returning 1 (NF_ACCEPT), but then decides to return 0
> (NF_DROP) and no ping replies.

There's already been a report about specific hashing problems with
conntrack on ARM.  It has something to do with how structures are
padding on ARM combined with the following patch made by Patrick:

commit 0794935e21a18e7c171b604c31219b60ad9749a9
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 31 04:40:52 2008 -0800

    [NETFILTER]: nf_conntrack: optimize hash_conntrack()
    
    Avoid calling jhash three times and hash the entire tuple in one go.
    
      __hash_conntrack | -485 # 760 -> 275, # inlines: 3 -> 1, size inlines: 717 -> 252
     1 function changed, 485 bytes removed
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ce4c4ba..4a2cce1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -73,15 +73,19 @@ static unsigned int nf_conntrack_hash_rnd;
 static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
 				  unsigned int size, unsigned int rnd)
 {
-	unsigned int a, b;
+	unsigned int n;
+	u_int32_t h;
 
-	a = jhash2(tuple->src.u3.all, ARRAY_SIZE(tuple->src.u3.all),
-		   (tuple->src.l3num << 16) | tuple->dst.protonum);
-	b = jhash2(tuple->dst.u3.all, ARRAY_SIZE(tuple->dst.u3.all),
-		   ((__force __u16)tuple->src.u.all << 16) |
-		    (__force __u16)tuple->dst.u.all);
+	/* The direction must be ignored, so we hash everything up to the
+	 * destination ports (which is a multiple of 4) and treat the last
+	 * three bytes manually.
+	 */
+	n = (sizeof(tuple->src) + sizeof(tuple->dst.u3)) / sizeof(u32);
+	h = jhash2((u32 *)tuple, n,
+		   rnd ^ (((__force __u16)tuple->dst.u.all << 16) |
+			  tuple->dst.protonum));
 
-	return ((u64)jhash_2words(a, b, rnd) * size) >> 32;
+	return ((u64)h * size) >> 32;
 }
 
 static inline u_int32_t hash_conntrack(const struct nf_conntrack_tuple *tuple)

