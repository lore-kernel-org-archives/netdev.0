From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/4] pci-hyperv: do not sleep in compose_msi_msg
Date: Mon, 31 Jul 2017 16:37:12 -0700
Message-ID: <20170731233712.12087-5-sthemmin@microsoft.com>
References: <20170731233712.12087-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
 linux-pci@vger.kernel.org, linux-doc@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
 corbet@lwn.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170731233712.12087-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The setup of MSI with Hyper-V host was sleeping with locks held.
This error is reported when doing SR-IOV hotplug with kernel built with lockdep.

    BUG: sleeping function called from invalid context at kernel/sched/completion.c:93
    in_atomic(): 1, irqs_disabled(): 1, pid: 1405, name: ip
    3 locks held by ip/1405:
   #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff976b10bb>] rtnetlink_rcv+0x1b/0x40
   #1:  (&desc->request_mutex){+.+...}, at: [<ffffffff970ddd33>] __setup_irq+0xb3/0x720
   #2:  (&irq_desc_lock_class){-.-...}, at: [<ffffffff970ddd65>] __setup_irq+0xe5/0x720
   irq event stamp: 3476
   hardirqs last  enabled at (3475): [<ffffffff971b3005>] get_page_from_freelist+0x225/0xc90
   hardirqs last disabled at (3476): [<ffffffff978024e7>] _raw_spin_lock_irqsave+0x27/0x90
   softirqs last  enabled at (2446): [<ffffffffc05ef0b0>] ixgbevf_configure+0x380/0x7c0 [ixgbevf]
   softirqs last disabled at (2444): [<ffffffffc05ef08d>] ixgbevf_configure+0x35d/0x7c0 [ixgbevf]

The workaround is to poll for host response instead of blocking on
completion.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/pci/host/pci-hyperv.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/host/pci-hyperv.c b/drivers/pci/host/pci-hyperv.c
index 415dcc69a502..334c9a7b8991 100644
--- a/drivers/pci/host/pci-hyperv.c
+++ b/drivers/pci/host/pci-hyperv.c
@@ -50,6 +50,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/delay.h>
 #include <linux/semaphore.h>
 #include <linux/irqdomain.h>
 #include <asm/irqdomain.h>
@@ -1159,7 +1160,12 @@ static void hv_compose_msi_msg(struct irq_data *data, struct msi_msg *msg)
 		goto free_int_desc;
 	}
 
-	wait_for_completion(&comp.comp_pkt.host_event);
+	/*
+	 * Since this function is called with IRQ locks held, can't
+	 * do normal wait for completion; instead poll.
+	 */
+	while (!try_wait_for_completion(&comp.comp_pkt.host_event))
+		udelay(100);
 
 	if (comp.comp_pkt.completion_status < 0) {
 		dev_err(&hbus->hdev->device,
-- 
2.11.0
