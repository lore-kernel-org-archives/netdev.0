From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] pci,
	e1000e: Add and use __pci_disable_link_state
Date: Sun, 08 May 2011 11:54:32 -0700
Message-ID: <4DC6E6E8.9040306@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Ski
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


Need to use it in _e1000e_disable_aspm.

Found lock up:

[ 2374.654557] kworker/32:1    D ffff881027f6b0f0     0  6075      2 0x00000000
[ 2374.654816]  ffff88503f099a68 0000000000000046 ffff88503f098000 0000000000004000
[ 2374.654837]  00000000001d1ec0 ffff88503f099fd8 00000000001d1ec0 ffff88503f099fd8
[ 2374.654860]  0000000000004000 00000000001d1ec0 ffff88503dcc8000 ffff88503f090000
[ 2374.654880] Call Trace:
[ 2374.654898]  [<ffffffff810b1302>] ? __lock_acquired+0x3a/0x224
[ 2374.654914]  [<ffffffff81c2b59c>] ? _raw_spin_unlock_irq+0x30/0x36
[ 2374.654925]  [<ffffffff810b069d>] ? trace_hardirqs_on_caller+0x1f/0x178
[ 2374.654936]  [<ffffffff81c2ab24>] rwsem_down_failed_common+0xd3/0x103
[ 2374.654945]  [<ffffffff810b158f>] ? __lock_contended+0x3a/0x2a2
[ 2374.654955]  [<ffffffff81c2ab7b>] rwsem_down_read_failed+0x12/0x14
[ 2374.654967]  [<ffffffff813371e4>] call_rwsem_down_read_failed+0x14/0x30
[ 2374.654981]  [<ffffffff8135df20>] ? pci_disable_link_state+0x5f/0xf5
[ 2374.654990]  [<ffffffff81c2a0e6>] ? down_read+0x7e/0x91
[ 2374.654999]  [<ffffffff8135df20>] ? pci_disable_link_state+0x5f/0xf5
[ 2374.655008]  [<ffffffff8135df20>] pci_disable_link_state+0x5f/0xf5
[ 2374.655024]  [<ffffffff81661796>] e1000e_disable_aspm+0x55/0x5a
[ 2374.655037]  [<ffffffff816677eb>] e1000_io_slot_reset+0x59/0xea
[ 2374.655048]  [<ffffffff8135fe0d>] ? report_mmio_enabled+0x5d/0x5d
[ 2374.655057]  [<ffffffff8135fe3b>] report_slot_reset+0x2e/0x5d
[ 2374.655072]  [<ffffffff8135369e>] pci_walk_bus+0x8a/0xb7
[ 2374.655081]  [<ffffffff8135fe0d>] ? report_mmio_enabled+0x5d/0x5d
[ 2374.655091]  [<ffffffff813603be>] broadcast_error_message+0xa4/0xb2
[ 2374.655101]  [<ffffffff81352c71>] ? pci_bus_read_config_dword+0x72/0x80
[ 2374.655110]  [<ffffffff813606df>] do_recovery+0x9e/0xf9
[ 2374.655120]  [<ffffffff81360786>] handle_error_source+0x4c/0x51
[ 2374.655129]  [<ffffffff81360974>] aer_isr_one_error+0x1e9/0x21a
[ 2374.655138]  [<ffffffff81360a6c>] aer_isr+0xc7/0xcc
[ 2374.655147]  [<ffffffff813609a5>] ? aer_isr_one_error+0x21a/0x21a
[ 2374.655159]  [<ffffffff81096d9f>] process_one_work+0x237/0x3ec
[ 2374.655168]  [<ffffffff81096d10>] ? process_one_work+0x1a8/0x3ec
[ 2374.655178]  [<ffffffff8109728d>] worker_thread+0x17c/0x240
[ 2374.655186]  [<ffffffff810b0803>] ? trace_hardirqs_on+0xd/0xf
[ 2374.655196]  [<ffffffff81097111>] ? manage_workers+0xab/0xab
[ 2374.655209]  [<ffffffff8109c8ed>] kthread+0xa0/0xa8
[ 2374.655223]  [<ffffffff81c332d4>] kernel_thread_helper+0x4/0x10
[ 2374.655232]  [<ffffffff81c2b880>] ? retint_restore_args+0xe/0xe
[ 2374.655243]  [<ffffffff8109c84d>] ? __init_kthread_worker+0x5b/0x5b
[ 2374.655252]  [<ffffffff81c332d0>] ? gs_change+0xb/0xb

when aer happens,
pci_walk_bus already have down_read(&pci_bus_sem)...
then report_slot_reset
        ==> e1000_io_slot_reset
                ==> e1000e_disable_aspm
                        ==> pci_disable_link_state...

We can not use pci_disable_link_state, and it will try to hold pci_bus_sem again.

Try to have __pci_disable_link_state that will not need to hold pci_bus_sem.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/net/e1000e/netdev.c |    2 +-
 drivers/pci/pcie/aspm.c     |   16 +++++++++++++---
 include/linux/pci-aspm.h    |    1 +
 3 files changed, 15 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6/drivers/net/e1000e/netdev.c
@@ -5360,7 +5360,7 @@ static void e1000_complete_shutdown(stru
 #ifdef CONFIG_PCIEASPM
 static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 {
-	pci_disable_link_state(pdev, state);
+	__pci_disable_link_state(pdev, state);
 }
 #else
 static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
Index: linux-2.6/drivers/pci/pcie/aspm.c
===================================================================
--- linux-2.6.orig/drivers/pci/pcie/aspm.c
+++ linux-2.6/drivers/pci/pcie/aspm.c
@@ -734,7 +734,7 @@ void pcie_aspm_powersave_config_link(str
  * pci_disable_link_state - disable pci device's link state, so the link will
  * never enter specific states
  */
-void pci_disable_link_state(struct pci_dev *pdev, int state)
+static void ___pci_disable_link_state(struct pci_dev *pdev, int state, bool sem)
 {
 	struct pci_dev *parent = pdev->bus->self;
 	struct pcie_link_state *link;
@@ -747,7 +747,8 @@ void pci_disable_link_state(struct pci_d
 	if (!parent || !parent->link_state)
 		return;
 
-	down_read(&pci_bus_sem);
+	if (sem)
+		down_read(&pci_bus_sem);
 	mutex_lock(&aspm_lock);
 	link = parent->link_state;
 	if (state & PCIE_LINK_STATE_L0S)
@@ -761,7 +762,16 @@ void pci_disable_link_state(struct pci_d
 		pcie_set_clkpm(link, 0);
 	}
 	mutex_unlock(&aspm_lock);
-	up_read(&pci_bus_sem);
+	if (sem)
+		up_read(&pci_bus_sem);
+}
+void __pci_disable_link_state(struct pci_dev *pdev, int state)
+{
+	___pci_disable_link_state(pdev, state, false);
+}
+void pci_disable_link_state(struct pci_dev *pdev, int state)
+{
+	___pci_disable_link_state(pdev, state, true);
 }
 EXPORT_SYMBOL(pci_disable_link_state);
 
Index: linux-2.6/include/linux/pci-aspm.h
===================================================================
--- linux-2.6.orig/include/linux/pci-aspm.h
+++ linux-2.6/include/linux/pci-aspm.h
@@ -28,6 +28,7 @@ extern void pcie_aspm_exit_link_state(st
 extern void pcie_aspm_pm_state_change(struct pci_dev *pdev);
 extern void pcie_aspm_powersave_config_link(struct pci_dev *pdev);
 extern void pci_disable_link_state(struct pci_dev *pdev, int state);
+extern void __pci_disable_link_state(struct pci_dev *pdev, int state);
 extern void pcie_clear_aspm(void);
 extern void pcie_no_aspm(void);
 #else

------------------------------------------------------------------------------
WhatsUp Gold - Download Free Network Management Software
The most intuitive, comprehensive, and cost-effective network 
management toolset available today.  Delivers lowest initial 
acquisition cost and overall TCO of any competing solution.
http://p.sf.net/sfu/whatsupgold-sd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
