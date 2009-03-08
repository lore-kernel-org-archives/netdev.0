From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] pci: fix kexec with power state D3
Date: Sun, 08 Mar 2009 00:09:28 -0800
Message-ID: <49B37D38.7060304@kernel.org>
References: <49B1F934.5050006@kernel.org> <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Impact: second kernel by kexec will have some pci devices working

Found one system with 82575EB, in the kernel that is kexeced, probe igb
failed with -2.

it looks like the same behavior happened on forcedeth.
try to check system_state to make sure if put it on D3

Jesse Brandeburg said that we should do that check in core code instead of
every device driver.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/pci/pci.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

Index: linux-2.6/drivers/pci/pci.c
===================================================================
--- linux-2.6.orig/drivers/pci/pci.c
+++ linux-2.6/drivers/pci/pci.c
@@ -593,6 +593,14 @@ int pci_set_power_state(struct pci_dev *
 	if (state == PCI_D3hot && (dev->dev_flags & PCI_DEV_FLAGS_NO_D3))
 		return 0;
 
+	/*
+	 * Apparently it is not possible to reinitialise from D3 hot,
+	 * only put the device into D3 if we really go for poweroff.
+	 */
+	if (system_state != SYSTEM_POWER_OFF &&
+	    (state == PCI_D3hot || state == PCI_D3cold))
+		return 0;
+
 	error = pci_raw_set_power_state(dev, state, true);
 
 	if (state > PCI_D0 && platform_pci_power_manageable(dev)) {
@@ -1124,6 +1132,15 @@ int pci_enable_wake(struct pci_dev *dev,
 	int error = 0;
 	bool pme_done = false;
 
+	/*
+	 * Apparently it is not possible to reinitialise from D3 hot,
+	 * only put the device into D3 if we really go for poweroff.
+	 * we only need to enable wake when we are going to power off
+	 */
+	if (enable && system_state != SYSTEM_POWER_OFF &&
+	    (state == PCI_D3hot || state == PCI_D3cold))
+		return 0;
+
 	if (enable && !device_may_wakeup(&dev->dev))
 		return -EINVAL;
 
