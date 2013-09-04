From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH 5/7] ixgbe: use pcie_capability_read_word() to simplify
 code
Date: Wed, 4 Sep 2013 10:20:22 -0600
Message-ID: <20130904162022.GE24733@google.com>
References: <1378193715-25328-1-git-send-email-wangyijing@huawei.com>
 <1378193715-25328-5-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	Hanjun Guo <guohanjun@huawei.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>
To: Yijing Wang <wangyijing@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378193715-25328-5-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc Jacob, Jeff]

On Tue, Sep 03, 2013 at 03:35:13PM +0800, Yijing Wang wrote:
> use pcie_capability_read_word() to simplify code.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Cc: e1000-devel@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index bad8f14..bfa0b06 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -152,7 +152,6 @@ MODULE_VERSION(DRV_VERSION);
>  static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
>  					  u32 reg, u16 *value)
>  {
> -	int pos = 0;
>  	struct pci_dev *parent_dev;
>  	struct pci_bus *parent_bus;
>  
> @@ -164,11 +163,10 @@ static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
>  	if (!parent_dev)
>  		return -1;
>  
> -	pos = pci_find_capability(parent_dev, PCI_CAP_ID_EXP);
> -	if (!pos)
> +	if (!pci_is_pcie(parent_dev))
>  		return -1;
>  
> -	pci_read_config_word(parent_dev, pos + reg, value);
> +	pcie_capability_read_word(parent_dev, reg, value);
>  	return 0;
>  }
>  

Here's the caller of ixgbe_read_pci_cfg_word_parent():

    /* Get the negotiated link width and speed from PCI config space of the
     * parent, as this device is behind a switch
     */
    err = ixgbe_read_pci_cfg_word_parent(adapter, 18, &link_status);

This should be using PCI_EXP_LNKSTA instead of "18".

But it would be even better if we could drop ixgbe_get_parent_bus_info()
completely.  It seems redundant after merging Jacob's new
pcie_get_minimum_link() stuff [1].

ixgbe_disable_pcie_master() looks like it should be using
pcie_capability_read_word() with PCI_EXP_DEVSTA instead of using
IXGBE_PCI_DEVICE_STATUS.  If fact, it looks like it could use the
new pci_wait_for_pending_transaction() interface [2].

It looks like all the #defines in the "PCI Bus Info" block
(IXGBE_PCI_DEVICE_STATUS, IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING,
IXGBE_PCI_LINK_STATUS, etc.) [3] are really for PCIe-generic things.  If
so, the IXGBE-specific ones should be dropped in favor of the generic
ones.

[1] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c?id=e027d1aec4bb49030646d2c186a721f94372d7f2
[2] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/pci/pci.c?id=3775a209d38aa3a0c7ed89a7d0f529e0230f280e
[3] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h#n1833
