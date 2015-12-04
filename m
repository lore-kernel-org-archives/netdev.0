From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Fri, 4 Dec 2015 22:39:56 +0800
Message-ID: <20151204143956.GA17471@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203125117.GB5505@gondor.apana.org.au>
 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 03, 2015 at 08:08:39AM -0800, Eric Dumazet wrote:
>
> Anyway, __vmalloc() can be used with GFP_ATOMIC, have you tried this ?

OK I've tried it and I no longer get any ENOMEM errors!

---8<---
When an rhashtable user pounds rhashtable hard with back-to-back
insertions we may end up growing the table in GFP_ATOMIC context.
Unfortunately when the table reaches a certain size this often
fails because we don't have enough physically contiguous pages
to hold the new table.

Eric Dumazet suggested (and in fact wrote this patch) using
__vmalloc instead which can be used in GFP_ATOMIC context.

Reported-by: Phil Sutter <phil@nwl.cc>
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a54ff89..1c624db 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -120,8 +120,9 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) ||
 	    gfp != GFP_KERNEL)
 		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
-	if (tbl == NULL && gfp == GFP_KERNEL)
-		tbl = vzalloc(size);
+	if (tbl == NULL)
+		tbl = __vmalloc(size, gfp | __GFP_HIGHMEM | __GFP_ZERO,
+				PAGE_KERNEL);
 	if (tbl == NULL)
 		return NULL;
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
