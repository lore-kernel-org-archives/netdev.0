From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Don't warn if high-order hash resize fails
Date: Mon, 14 May 2007 15:48:37 +1000
Message-ID: <20070514054837.GA18879@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4896 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755621AbXENFsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 01:48:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

I just got this when rekeying my VPN (2.6.21.1):

events/0: page allocation failure. order:7, mode:0xd0
 [<c0146235>] __alloc_pages+0x1e5/0x2e0
 [<c0146356>] __get_free_pages+0x26/0x50
 [<c02a01ef>] xfrm_hash_alloc+0x2f/0x80
 [<c029a947>] xfrm_bydst_resize+0x37/0xc0
 [<c029aa70>] xfrm_hash_resize+0x0/0x80
 [<c029aae7>] xfrm_hash_resize+0x77/0x80
 [<c012a8ea>] run_workqueue+0x8a/0x190
 [<c012ab17>] worker_thread+0x127/0x160
 [<c0117490>] default_wake_function+0x0/0x10
 [<c01174d7>] __wake_up_common+0x37/0x70
 [<c0117490>] default_wake_function+0x0/0x10
 [<c012a9f0>] worker_thread+0x0/0x160
 [<c012e044>] kthread+0xb4/0xc0
 [<c012df90>] kthread+0x0/0xc0
 [<c0105287>] kernel_thread_helper+0x7/0x10
 =======================

Isn't an order-7 allocation (half a meg) a bit over-the-top for that hash,
especially since I've got a grand total of 4 SAs :)

Anyway, we shouldn't warn about these allocations since they're expected
to fail after the box has been up for a while.  Also, should we try
vmalloc when it does fail?

[IPSEC]: Don't warn if high-order hash resize fails

Multi-page allocations are always likely to fail.  Since such failures
are expected and non-critical in xfrm_hash_alloc, we shouldn't warn about
them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
index 37643bb..55ab579 100644
--- a/net/xfrm/xfrm_hash.c
+++ b/net/xfrm/xfrm_hash.c
@@ -22,7 +22,8 @@ struct hlist_head *xfrm_hash_alloc(unsigned int sz)
 		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
 	else
 		n = (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL, get_order(sz));
+			__get_free_pages(GFP_KERNEL | __GFP_NOWARN,
+					 get_order(sz));
 
 	if (n)
 		memset(n, 0, sz);
