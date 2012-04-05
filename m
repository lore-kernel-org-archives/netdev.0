From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH 2/2] ixgbe: add missing rtnl_lock in PM resume
	path
Date: Thu,  5 Apr 2012 11:11:04 -0400
Message-ID: <1333638664-17062-2-git-send-email-bpoirier@suse.de>
References: <1333638664-17062-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1333638664-17062-1-git-send-email-bpoirier@suse.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Upon resume from standby, ixgbe may trigger the ASSERT_RTNL() in
netif_set_real_num_tx_queues(). The call stack is:
	netif_set_real_num_tx_queues
	ixgbe_set_num_queues
	ixgbe_init_interrupt_scheme
	ixgbe_resume

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

---
Unlike patch 1 for igb, we cannot lock rtnl closer to the point where
netif_set_real_num_tx_queues() is called because ixgbe_init_interrupt_scheme()
is also called by the dcb code, already under rtnl.
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3e26b1f..ff6edab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4836,7 +4836,9 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	pci_wake_from_d3(pdev, false);
 
+	rtnl_lock();
 	err = ixgbe_init_interrupt_scheme(adapter);
+	rtnl_unlock();
 	if (err) {
 		e_dev_err("Cannot initialize interrupts for device\n");
 		return err;
-- 
1.7.7


------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
