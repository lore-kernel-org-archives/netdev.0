From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: [PATCH 2/2] ixgbe: set driver_max_VFs should be done
	before enabling SRIOV
Date: Wed, 15 Jan 2014 22:15:18 +0800
Message-ID: <1389795318-384-1-git-send-email-ethan.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Ethan Zhao <ethan.kernel@gmail.com>, linux-kernel@vger.kernel.org
To: aaron.f.brown@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

commit 43dc4e01 Limit number of reported VFs to device specific value
It doesn't work and always returns -EBUSY because VFs ware already enabled.

ixgbe_enable_sriov()
        pci_enable_sriov()
                sriov_enable()
                {
                ... ..
                iov->ctrl |= PCI_SRIOV_CTRL_VFE | PCI_SRIOV_CTRL_MSE;
                pci_cfg_access_lock(dev);
                ... ...
                }

pci_sriov_set_totalvfs()
{
... ...
if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
                return -EBUSY;
...
}

So should set driver_max_VFs with pci_sriov_set_totalvfs() before
enable VFs with ixgbe_enable_sriov().

Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 47e9b44..bfc8e94 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7639,8 +7639,8 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Mailbox */
 	ixgbe_init_mbx_params_pf(hw);
 	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
-	ixgbe_enable_sriov(adapter);
 	pci_sriov_set_totalvfs(pdev, IXGBE_MAX_VFS_DRV_LIMIT);
+	ixgbe_enable_sriov(adapter);
 skip_sriov:
 
 #endif
-- 
1.8.3.4 (Apple Git-47)


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
