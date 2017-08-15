From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the pci tree with the net tree
Date: Wed, 16 Aug 2017 09:51:28 +1000
Message-ID: <20170816095128.7205e4f1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Casey Leedom <leedom@chelsio.com>,
        Sinan Kaya <okaya@codeaurora.org>
To: Bjorn Helgaas <bhelgaas@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

Today's linux-next merge of the pci tree got a conflict in:

  drivers/pci/probe.c

between commit:

  a99b646afa8a ("PCI: Disable PCIe Relaxed Ordering if unsupported")

from the net tree and commit:

  62ce94a7a5a5 ("PCI: Mark Broadcom HT2100 Root Port Extended Tags as broken")

from the pci tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/pci/probe.c
index e6a917b4acd3,d11fede6bd53..000000000000
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@@ -1751,67 -1753,51 +1753,94 @@@ int pci_configure_extended_tags(struct 
  	int ret;
  
  	if (!pci_is_pcie(dev))
- 		return;
+ 		return 0;
  
- 	ret = pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &dev_cap);
+ 	ret = pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
  	if (ret)
- 		return;
+ 		return 0;
+ 
+ 	if (!(cap & PCI_EXP_DEVCAP_EXT_TAG))
+ 		return 0;
+ 
+ 	ret = pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &ctl);
+ 	if (ret)
+ 		return 0;
+ 
+ 	host = pci_find_host_bridge(dev->bus);
+ 	if (!host)
+ 		return 0;
+ 
+ 	/*
+ 	 * If some device in the hierarchy doesn't handle Extended Tags
+ 	 * correctly, make sure they're disabled.
+ 	 */
+ 	if (host->no_ext_tags) {
+ 		if (ctl & PCI_EXP_DEVCTL_EXT_TAG) {
+ 			dev_info(&dev->dev, "disabling Extended Tags\n");
+ 			pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
+ 						   PCI_EXP_DEVCTL_EXT_TAG);
+ 		}
+ 		return 0;
+ 	}
  
- 	if (dev_cap & PCI_EXP_DEVCAP_EXT_TAG)
+ 	if (!(ctl & PCI_EXP_DEVCTL_EXT_TAG)) {
+ 		dev_info(&dev->dev, "enabling Extended Tags\n");
  		pcie_capability_set_word(dev, PCI_EXP_DEVCTL,
  					 PCI_EXP_DEVCTL_EXT_TAG);
+ 	}
+ 	return 0;
  }
  
 +/**
 + * pcie_relaxed_ordering_enabled - Probe for PCIe relaxed ordering enable
 + * @dev: PCI device to query
 + *
 + * Returns true if the device has enabled relaxed ordering attribute.
 + */
 +bool pcie_relaxed_ordering_enabled(struct pci_dev *dev)
 +{
 +	u16 v;
 +
 +	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
 +
 +	return !!(v & PCI_EXP_DEVCTL_RELAX_EN);
 +}
 +EXPORT_SYMBOL(pcie_relaxed_ordering_enabled);
 +
 +static void pci_configure_relaxed_ordering(struct pci_dev *dev)
 +{
 +	struct pci_dev *root;
 +
 +	/* PCI_EXP_DEVICE_RELAX_EN is RsvdP in VFs */
 +	if (dev->is_virtfn)
 +		return;
 +
 +	if (!pcie_relaxed_ordering_enabled(dev))
 +		return;
 +
 +	/*
 +	 * For now, we only deal with Relaxed Ordering issues with Root
 +	 * Ports. Peer-to-Peer DMA is another can of worms.
 +	 */
 +	root = pci_find_pcie_root_port(dev);
 +	if (!root)
 +		return;
 +
 +	if (root->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING) {
 +		pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
 +					   PCI_EXP_DEVCTL_RELAX_EN);
 +		dev_info(&dev->dev, "Disable Relaxed Ordering because the Root Port didn't support it\n");
 +	}
 +}
 +
  static void pci_configure_device(struct pci_dev *dev)
  {
  	struct hotplug_params hpp;
  	int ret;
  
  	pci_configure_mps(dev);
- 	pci_configure_extended_tags(dev);
+ 	pci_configure_extended_tags(dev, NULL);
 +	pci_configure_relaxed_ordering(dev);
  
  	memset(&hpp, 0, sizeof(hpp));
  	ret = pci_get_hp_params(dev, &hpp);
