From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 3/3] net: mvpp2: Return correct error codes
Date: Thu, 4 Feb 2016 19:25:26 +0530
Message-ID: <20160204135526.GA8400@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of kzalloc on failure of allocation of memory should
be -ENOMEM and not -1.

Found using Coccinelle. A simplified version of the semantic patch
used is:

//<smpl>
@@
expression *e;
position p,q;
@@

e@q = kzalloc(...);
if@p (e == NULL) {
...
return
- -1
+ -ENOMEM
;
}
//</smpl>

This function may also return -1 after calling mpp2_prs_tcam_port_map_get.
So that the function consistently returns meaningful error values on 
failure, the -1 is changed to -EINVAL.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index d9884fd..3208787 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3061,7 +3061,7 @@ static int mvpp2_prs_mac_da_accept(struct mvpp2 *priv, int port,
 
 		pe = kzalloc(sizeof(*pe), GFP_KERNEL);
 		if (!pe)
-			return -1;
+			return -ENOMEM;
 		mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_MAC);
 		pe->index = tid;
 
@@ -3077,7 +3077,7 @@ static int mvpp2_prs_mac_da_accept(struct mvpp2 *priv, int port,
 	if (pmap == 0) {
 		if (add) {
 			kfree(pe);
-			return -1;
+			return -EINVAL;
 		}
 		mvpp2_prs_hw_inv(priv, pe->index);
 		priv->prs_shadow[pe->index].valid = false;
-- 
1.9.1
