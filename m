From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: add MSI interrupts support
Date: Mon, 24 Mar 2014 10:14:06 -0500
Message-ID: <53304BBE.6040403@lwfinger.net>
References: <1395640841-14477-1-git-send-email-adam.lee@canonical.com> <1395660884-15042-1-git-send-email-adam.lee@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Adam Lee <adam.lee@canonical.com>, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:33800 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbaCXPOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 11:14:10 -0400
In-Reply-To: <1395660884-15042-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2014 06:34 AM, Adam Lee wrote:
> Add MSI interrupts support, enable it when msi_support flag is true,
> also could fallback to pin-based interrupts mode if MSI mode fails.
>
> Signed-off-by: Adam Lee <adam.lee@canonical.com>

Your first patch turns on MSI support unconditionally. That implies that there 
are no harmful effects for attempting to use MSI on a box where it is not 
needed, and/or not implemented. If that is the case, then the msi_support bool 
should be eliminated, your first patch dropped, and this one revised 
appropriately. Driver rtl8723be added this bool, but never uses it. Once that 
driver reaches mainline, a patch can be prepared to remove the variable.

I think this patch should be applied to stable. Applying it back to 3.10+ should 
be far enough. That will pick up the initial submission of the RTL8188EE driver. 
Boxes that need MSI interrupts are not likely to use any of the older chips.

There are some additional in-line comments below.

> ---
>   drivers/net/wireless/rtlwifi/pci.c | 63 ++++++++++++++++++++++++++++++++++++--
>   1 file changed, 61 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
> index f26f4ff..dd8497a 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -1853,6 +1853,63 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
>   	return true;
>   }
>
> +static int rtl_pci_intr_mode_msi(struct ieee80211_hw *hw)
> +{
> +	struct rtl_priv *rtlpriv = rtl_priv(hw);
> +	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
> +	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
> +	int ret;

I like a blank line between the declarations and the code.

> +	ret = pci_enable_msi(rtlpci->pdev);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
> +			  IRQF_SHARED, KBUILD_MODNAME, hw);
> +	if (ret < 0) {
> +		pci_disable_msi(rtlpci->pdev);
> +		return ret;
> +	}
> +
> +	rtlpci->using_msi = true;
> +
> +	RT_TRACE(rtlpriv, COMP_INIT|COMP_INTR, DBG_DMESG,
> +			("MSI Interrupt Mode!\n"));

Doesn't checkpatch.pl complain about the alignment here?

> +	return 0;
> +}
> +
> +static int rtl_pci_intr_mode_legacy(struct ieee80211_hw *hw)
> +{
> +	struct rtl_priv *rtlpriv = rtl_priv(hw);
> +	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
> +	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
> +	int ret;
> +
> +	ret = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
> +			  IRQF_SHARED, KBUILD_MODNAME, hw);
> +	if (ret < 0)
> +		return ret;
> +
> +	rtlpci->using_msi = false;
> +	RT_TRACE(rtlpriv, COMP_INIT|COMP_INTR, DBG_DMESG,
> +		 ("Pin-based Interrupt Mode!\n"));
> +	return 0;
> +}
> +
> +static int rtl_pci_intr_mode_decide(struct ieee80211_hw *hw)
> +{
> +	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
> +	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
> +	int ret;
> +	if (rtlpci->msi_support == true) {

As discussed above, this test is not needed. If it were, the current version of 
checkpatch.pl complains about the "== true" part.

> +		ret = rtl_pci_intr_mode_msi(hw);
> +		if (ret < 0)
> +			ret = rtl_pci_intr_mode_legacy(hw);
> +	} else {
> +		ret = rtl_pci_intr_mode_legacy(hw);
> +	}
> +	return ret;
> +}
> +
>   int rtl_pci_probe(struct pci_dev *pdev,
>   			    const struct pci_device_id *id)
>   {
> @@ -1995,8 +2052,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
>   	}
>
>   	rtlpci = rtl_pcidev(pcipriv);
> -	err = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
> -			  IRQF_SHARED, KBUILD_MODNAME, hw);
> +	err = rtl_pci_intr_mode_decide(hw);
>   	if (err) {
>   		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
>   			 "%s: failed to register IRQ handler\n",
> @@ -2064,6 +2120,9 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
>   		rtlpci->irq_alloc = 0;
>   	}
>
> +	if (rtlpci->using_msi == true)

Again "if (rtlpci->using_msi)" is preferred.

> +		pci_disable_msi(rtlpci->pdev);
> +
>   	list_del(&rtlpriv->list);
>   	if (rtlpriv->io.pci_mem_start != 0) {
>   		pci_iounmap(pdev, (void __iomem *)rtlpriv->io.pci_mem_start);
>

When you resubmit, use "[PATCH V2]" in the subject, and use the proper CC stable 
with [3.10+] following the address.

Larry
