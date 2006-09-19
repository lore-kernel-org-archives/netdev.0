From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/23] e1000: Fix MANC detection for PCIE adapters
Date: Tue, 19 Sep 2006 15:31:32 -0400
Message-ID: <45104594.8030200@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172855.4605.79006.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55995 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751036AbWISTbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:31:34 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172855.4605.79006.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Several manageability capability detection parts hinted towards
> our code being incomplete for PCI-E. According to spec, we do not
> want to poke any MANC bits at all.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   15 ++++-----------
>  1 files changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index f3f3d38..e81aa03 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -662,9 +662,7 @@ e1000_reset(struct e1000_adapter *adapte
>  		                    phy_data);
>  	}
>  
> -	if (adapter->hw.mac_type < e1000_ich8lan)
> -	/* FIXME: this code is duplicate and wrong for PCI Express */
> -	if (adapter->en_mng_pt) {
> +	if ((adapter->en_mng_pt) && (adapter->hw.mac_type < e1000_82571)) {
>  		manc = E1000_READ_REG(&adapter->hw, MANC);
>  		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
>  		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> @@ -1042,8 +1040,7 @@ e1000_remove(struct pci_dev *pdev)
>  
>  	flush_scheduled_work();
>  
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	   adapter->hw.mac_type != e1000_ich8lan &&
> +	if (adapter->hw.mac_type < e1000_82571 &&
>  	   adapter->hw.media_type == e1000_media_type_copper) {
>  		manc = E1000_READ_REG(&adapter->hw, MANC);
>  		if (manc & E1000_MANC_SMBUS_EN) {
> @@ -4695,9 +4692,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
>  		pci_enable_wake(pdev, PCI_D3cold, 0);
>  	}
>  
> -	/* FIXME: this code is incorrect for PCI Express */
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	   adapter->hw.mac_type != e1000_ich8lan &&
> +	if (adapter->hw.mac_type < e1000_82571 &&
>  	   adapter->hw.media_type == e1000_media_type_copper) {
>  		manc = E1000_READ_REG(&adapter->hw, MANC);
>  		if (manc & E1000_MANC_SMBUS_EN) {
> @@ -4749,9 +4744,7 @@ e1000_resume(struct pci_dev *pdev)
>  
>  	netif_device_attach(netdev);
>  
> -	/* FIXME: this code is incorrect for PCI Express */
> -	if (adapter->hw.mac_type >= e1000_82540 &&
> -	   adapter->hw.mac_type != e1000_ich8lan &&
> +	if (adapter->hw.mac_type < e1000_82571 &&
>  	   adapter->hw.media_type == e1000_media_type_copper) {
>  		manc = E1000_READ_REG(&adapter->hw, MANC);
>  		manc &= ~(E1000_MANC_ARP_EN);

ACK patches 9-10, though this illustrates another key problem in e1000:

you should be testing feature bits, not lists of e1000 chip revisions.

set feature (and errata) bits in a flag variables at probe time, then 
simply test a single bit to determine whether to use a certain feature, 
or activate a certain errata workaround.

	Jeff



