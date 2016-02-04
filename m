From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 2/3] ibmveth: Return correct error codes
Date: Thu, 4 Feb 2016 19:25:19 +0530
Message-ID: <20160204135519.GA8362@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: tlfalcon@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of kmalloc and kcalloc on failure of allocation of
memory should be -ENOMEM and not -1.

Found using Coccinelle. A simplified version of the semantic patch
used is:

//<smpl>
@@
expression *e;
position p,q;
@@

e@q = \(kmalloc\|kcalloc\)(...);
if@p (e == NULL) {
...
return
- -1
+ -ENOMEM
;
}
//</smpl>

The two call sites only check that the return value is not 0,
hence no change is required at the call sites.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 7af870a..92a9a70 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -167,13 +167,13 @@ static int ibmveth_alloc_buffer_pool(struct ibmveth_buff_pool *pool)
 	pool->free_map = kmalloc(sizeof(u16) * pool->size, GFP_KERNEL);
 
 	if (!pool->free_map)
-		return -1;
+		return -ENOMEM;
 
 	pool->dma_addr = kmalloc(sizeof(dma_addr_t) * pool->size, GFP_KERNEL);
 	if (!pool->dma_addr) {
 		kfree(pool->free_map);
 		pool->free_map = NULL;
-		return -1;
+		return -ENOMEM;
 	}
 
 	pool->skbuff = kcalloc(pool->size, sizeof(void *), GFP_KERNEL);
@@ -184,7 +184,7 @@ static int ibmveth_alloc_buffer_pool(struct ibmveth_buff_pool *pool)
 
 		kfree(pool->free_map);
 		pool->free_map = NULL;
-		return -1;
+		return -ENOMEM;
 	}
 
 	memset(pool->dma_addr, 0, sizeof(dma_addr_t) * pool->size);
-- 
1.9.1
