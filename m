From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] sparc: clarify __GFP_NOFAIL allocation
Date: Mon, 2 Mar 2015 22:36:10 +0100
Message-ID: <20150302213610.GA31974@dhcp22.suse.cz>
References: <1425304483-7987-4-git-send-email-mhocko@suse.cz>
 <20150302.150405.2072800922470200977.davem@davemloft.net>
 <20150302203304.GA20513@dhcp22.suse.cz>
 <20150302.154424.30182050492471222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org,
	rientjes@google.com, david@fromorbit.com, tytso@mit.edu,
	mgorman@suse.de, penguin-kernel@I-love.SAKURA.ne.jp,
	sparclinux@vger.kernel.org, vipul@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150302.154424.30182050492471222.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 02-03-15 15:44:24, David S. Miller wrote:
[...]
> > OK, thanks for the clarification. This wasn't clear from the commit
> > which has introduced this code. I will drop this patch. Would you
> > accept something like the following instead?
> 
> Sure.

Thanks!

---
>From dac5829e3a1d44ba7759b4188de01f15ddb77b8b Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.cz>
Date: Mon, 2 Mar 2015 22:27:02 +0100
Subject: [PATCH] sparc: clarify __GFP_NOFAIL allocation

920c3ed74134 ([SPARC64]: Add basic infrastructure for MD add/remove
notification.) has added __GFP_NOFAIL for the allocation request but
it hasn't mentioned why is this strict requirement really needed.
The code was handling an allocation failure and propagated it properly
up the callchain so it is not clear why it is needed.

Dave has clarified the intention when I tried to remove the flag as not
being necessary:
"
It is a serious failure.

If we miss an MDESC update due to this allocation failure, the update
is not an event which gets retransmitted so we will lose the updated
machine description forever.

We really need this allocation to succeed.
"

So add a comment to clarify the nofail flag and get rid of the failure
check because __GFP_NOFAIL allocation doesn't fail.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 arch/sparc/kernel/mdesc.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index 99632a87e697..26c80e18d7b1 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -130,26 +130,26 @@ static struct mdesc_mem_ops memblock_mdesc_ops = {
 static struct mdesc_handle *mdesc_kmalloc(unsigned int mdesc_size)
 {
 	unsigned int handle_size;
+	struct mdesc_handle *hp;
+	unsigned long addr;
 	void *base;
 
 	handle_size = (sizeof(struct mdesc_handle) -
 		       sizeof(struct mdesc_hdr) +
 		       mdesc_size);
 
+	/*
+	 * Allocation has to succeed because mdesc update would be missed
+	 * and such events are not retransmitted.
+	 */
 	base = kmalloc(handle_size + 15, GFP_KERNEL | __GFP_NOFAIL);
-	if (base) {
-		struct mdesc_handle *hp;
-		unsigned long addr;
-
-		addr = (unsigned long)base;
-		addr = (addr + 15UL) & ~15UL;
-		hp = (struct mdesc_handle *) addr;
+	addr = (unsigned long)base;
+	addr = (addr + 15UL) & ~15UL;
+	hp = (struct mdesc_handle *) addr;
 
-		mdesc_handle_init(hp, handle_size, base);
-		return hp;
-	}
+	mdesc_handle_init(hp, handle_size, base);
 
-	return NULL;
+	return hp;
 }
 
 static void mdesc_kfree(struct mdesc_handle *hp)
-- 
2.1.4


-- 
Michal Hocko
SUSE Labs
