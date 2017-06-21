From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the pci tree
Date: Wed, 21 Jun 2017 11:54:43 +1000
Message-ID: <20170621115443.3e10f0bc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>,
        Brian Norris <briannorris@chromium.org>,
        Kalle Valo <kvalo@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/wireless/marvell/mwifiex/pcie.c

between commit:

  c336cc0ee4eb ("PCI: Split ->reset_notify() method into ->reset_prepare() and ->reset_done()")

from the pci tree and commit:

  68efd0386988 ("mwifiex: pcie: stop setting/clearing 'surprise_removed'")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/wireless/marvell/mwifiex/pcie.c
index 279adf124fc9,b53ecf1eddda..000000000000
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@@ -361,48 -359,35 +361,46 @@@ static void mwifiex_pcie_reset_prepare(
  	}
  
  	mwifiex_dbg(adapter, INFO,
 -		    "%s: vendor=0x%4.04x device=0x%4.04x rev=%d %s\n",
 -		    __func__, pdev->vendor, pdev->device,
 -		    pdev->revision,
 -		    prepare ? "Pre-FLR" : "Post-FLR");
 -
 -	if (prepare) {
 -		/* Kernel would be performing FLR after this notification.
 -		 * Cleanup all software without cleaning anything related to
 -		 * PCIe and HW.
 -		 */
 -		mwifiex_shutdown_sw(adapter);
 -		clear_bit(MWIFIEX_IFACE_WORK_DEVICE_DUMP, &card->work_flags);
 -		clear_bit(MWIFIEX_IFACE_WORK_CARD_RESET, &card->work_flags);
 -	} else {
 -		/* Kernel stores and restores PCIe function context before and
 -		 * after performing FLR respectively. Reconfigure the software
 -		 * and firmware including firmware redownload
 -		 */
 -		ret = mwifiex_reinit_sw(adapter);
 -		if (ret) {
 -			dev_err(&pdev->dev, "reinit failed: %d\n", ret);
 -			return;
 -		}
 -	}
 +		    "%s: vendor=0x%4.04x device=0x%4.04x rev=%d Pre-FLR\n",
 +		    __func__, pdev->vendor, pdev->device, pdev->revision);
 +
 +	mwifiex_shutdown_sw(adapter);
- 	adapter->surprise_removed = true;
 +	clear_bit(MWIFIEX_IFACE_WORK_DEVICE_DUMP, &card->work_flags);
 +	clear_bit(MWIFIEX_IFACE_WORK_CARD_RESET, &card->work_flags);
  	mwifiex_dbg(adapter, INFO, "%s, successful\n", __func__);
  }
  
 -static const struct pci_error_handlers mwifiex_pcie_err_handler[] = {
 -		{ .reset_notify = mwifiex_pcie_reset_notify, },
 +/*
 + * Kernel stores and restores PCIe function context before and after performing
 + * FLR respectively. Reconfigure the software and firmware including firmware
 + * redownload.
 + */
 +static void mwifiex_pcie_reset_done(struct pci_dev *pdev)
 +{
 +	struct pcie_service_card *card = pci_get_drvdata(pdev);
 +	struct mwifiex_adapter *adapter = card->adapter;
 +	int ret;
 +
 +	if (!adapter) {
 +		dev_err(&pdev->dev, "%s: adapter structure is not valid\n",
 +			__func__);
 +		return;
 +	}
 +
 +	mwifiex_dbg(adapter, INFO,
 +		    "%s: vendor=0x%4.04x device=0x%4.04x rev=%d Post-FLR\n",
 +		    __func__, pdev->vendor, pdev->device, pdev->revision);
 +
- 	adapter->surprise_removed = false;
 +	ret = mwifiex_reinit_sw(adapter);
 +	if (ret)
 +		dev_err(&pdev->dev, "reinit failed: %d\n", ret);
 +	else
 +		mwifiex_dbg(adapter, INFO, "%s, successful\n", __func__);
 +}
 +
 +static const struct pci_error_handlers mwifiex_pcie_err_handler = {
 +	.reset_prepare		= mwifiex_pcie_reset_prepare,
 +	.reset_done		= mwifiex_pcie_reset_done,
  };
  
  #ifdef CONFIG_PM_SLEEP
