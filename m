From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Mar 28 (broadcom/bnx2x)
Date: Thu, 28 Mar 2013 14:20:58 -0400 (EDT)
Message-ID: <20130328.142058.1418770354237033948.davem@davemloft.net>
References: <20130328162804.0676c97abb26d356ad8e50a6@canb.auug.org.au>
	<51547915.2010607@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eilong@broadcom.com
To: rdunlap@infradead.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <51547915.2010607@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 28 Mar 2013 10:08:37 -0700

> On 03/27/13 22:28, Stephen Rothwell wrote:
>> Hi all,
>> 
>> The next linux-next release will be on Tuesday April 2.
>> 
>> Changes since 20130327:
>> 
> 
> on i386:
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function 'bnx2x_init_one':
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:12525:3: error: 'struct bnx2x' has no member named 'vf2pf_mutex'
> 
> 
> Full randconfig file is attached.

This should be fixed in net-next by:

commit 8b49a4c75965ed157e21450d23dcadd6b27c1aa3
Author: Dmitry Kravkov <dmitry@broadcom.com>
Date:   Wed Mar 27 08:56:10 2013 +0000

    bnx2x: fix compilation without CONFIG_BNX2X_SRIOV
    
    Move mutex initialization by allocation of the mailbox it protects.
    
    introduced in commit 1d6f3cd89 'bnx2x: Prevent VF race'
    
    Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
    Reported-by: kbuild test robot <fengguang.wu@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 10af03e..fdfe33b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12522,7 +12522,6 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	 */
 	if (IS_VF(bp)) {
 		bp->doorbells = bnx2x_vf_doorbells(bp);
-		mutex_init(&bp->vf2pf_mutex);
 		rc = bnx2x_vf_pci_alloc(bp);
 		if (rc)
 			goto init_one_exit;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index db63d86..2ce7c74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3425,6 +3425,8 @@ void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 
 int bnx2x_vf_pci_alloc(struct bnx2x *bp)
 {
+	mutex_init(&bp->vf2pf_mutex);
+
 	/* allocate vf2pf mailbox for vf to pf channel */
 	BNX2X_PCI_ALLOC(bp->vf2pf_mbox, &bp->vf2pf_mbox_mapping,
 			sizeof(struct bnx2x_vf_mbx_msg));
