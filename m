From: Dean Nelson <dnelson@redhat.com>
Subject: [PATCH 2/3] pci: fix access of PCI_X_CMD by pcix get and set mmrbc functions
Date: Tue, 9 Mar 2010 22:26:48 -0500
Message-ID: <20100310032647.6331.70590.send-patch@aqua>
References: <20100310032632.6331.15414.send-patch@aqua>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: jbarnes@virtuousgeek.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100310032632.6331.15414.send-patch@aqua>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An e1000 driver on a system with a PCI-X bus was always being returned
a value of 135 from both pcix_get_mmrbc() and pcix_set_mmrbc(). This
value reflects an error return of PCIBIOS_BAD_REGISTER_NUMBER from
pci_bus_read_config_dword(,, cap + PCI_X_CMD,).

This is because for a dword, the following portion of the PCI_OP_READ()
macro:

	if (PCI_##size##_BAD) return PCIBIOS_BAD_REGISTER_NUMBER;

expands to:

	if (pos & 3) return PCIBIOS_BAD_REGISTER_NUMBER;

And is always true for 'cap + PCI_X_CMD', which is 0xe4 + 2 = 0xe6. ('cap' is
the result of calling pci_find_capability(, PCI_CAP_ID_PCIX).)

The same problem exists for pci_bus_write_config_dword(,, cap + PCI_X_CMD,).
In both cases, instead of calling _dword(), _word() should be called.

Signed-off-by: Dean Nelson <dnelson@redhat.com>

---

 drivers/pci/pci.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 1decd4f..cdf201e 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -2585,13 +2585,13 @@ EXPORT_SYMBOL(pcix_get_max_mmrbc);
 int pcix_get_mmrbc(struct pci_dev *dev)
 {
 	int ret, cap;
-	u32 cmd;
+	u16 cmd;
 
 	cap = pci_find_capability(dev, PCI_CAP_ID_PCIX);
 	if (!cap)
 		return -EINVAL;
 
-	ret = pci_read_config_dword(dev, cap + PCI_X_CMD, &cmd);
+	ret = pci_read_config_word(dev, cap + PCI_X_CMD, &cmd);
 	if (!ret)
 		ret = 512 << ((cmd & PCI_X_CMD_MAX_READ) >> 2);
 
@@ -2611,7 +2611,8 @@ EXPORT_SYMBOL(pcix_get_mmrbc);
 int pcix_set_mmrbc(struct pci_dev *dev, int mmrbc)
 {
 	int cap, err = -EINVAL;
-	u32 stat, cmd, v, o;
+	u32 stat, v, o;
+	u16 cmd;
 
 	if (mmrbc < 512 || mmrbc > 4096 || !is_power_of_2(mmrbc))
 		goto out;
@@ -2629,7 +2630,7 @@ int pcix_set_mmrbc(struct pci_dev *dev, int mmrbc)
 	if (v > (stat & PCI_X_STATUS_MAX_READ) >> 21)
 		return -E2BIG;
 
-	err = pci_read_config_dword(dev, cap + PCI_X_CMD, &cmd);
+	err = pci_read_config_word(dev, cap + PCI_X_CMD, &cmd);
 	if (err)
 		goto out;
 
@@ -2641,7 +2642,7 @@ int pcix_set_mmrbc(struct pci_dev *dev, int mmrbc)
 
 		cmd &= ~PCI_X_CMD_MAX_READ;
 		cmd |= v << 2;
-		err = pci_write_config_dword(dev, cap + PCI_X_CMD, cmd);
+		err = pci_write_config_word(dev, cap + PCI_X_CMD, cmd);
 	}
 out:
 	return err;
