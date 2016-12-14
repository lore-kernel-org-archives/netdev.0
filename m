From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: [PATCH v2 net-next 1/2] phy: add phy fixup unregister functions
Date: Wed, 14 Dec 2016 16:39:21 +0800
Message-ID: <58510539.1030803@hisilicon.com>
References: <9235D6609DB808459E95D78E17F2E43D4097999C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <Woojung.Huh@microchip.com>, <davem@davemloft.net>,
        <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:42689 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753138AbcLNImu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 03:42:50 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4097999C@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On 2016/12/8 4:26, Woojung.Huh@microchip.com wrote:
>>From : Woojung Huh <woojung.huh@microchip.com>
> 
> Add functions to unregister phy fixup for modules.
> 
> int phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask)
> 	Unregister phy fixup from phy_fixup_list per bus_id, phy_uid &
> 	phy_uid_mask
> 
> int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask)
> 	Unregister phy fixup from phy_fixup_list.
> 	Use it for fixup registered by phy_register_fixup_for_uid()
> 
> int phy_unregister_fixup_for_id(const char *bus_id)
> 	Unregister phy fixup from phy_fixup_list.
> 	Use it for fixup registered by phy_register_fixup_for_id()
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  Documentation/networking/phy.txt |  9 ++++++++
>  drivers/net/phy/phy_device.c     | 47 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/phy.h              |  4 ++++
>  3 files changed, 60 insertions(+)
> 
> diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
> index e017d93..16f90d8 100644
> --- a/Documentation/networking/phy.txt
> +++ b/Documentation/networking/phy.txt
> @@ -407,6 +407,15 @@ Board Fixups
>   The stubs set one of the two matching criteria, and set the other one to
>   match anything.
>  
> + When phy_register_fixup() or *_for_uid()/*_for_id() is called at module,
> + unregister fixup and free allocate memory are required.
> +
> + Call one of following function before unloading module.
> +
> + int phy_unregister_fixup(const char *phy_id, u32 phy_uid, u32 phy_uid_mask);
> + int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask);
> + int phy_register_fixup_for_id(const char *phy_id);
> +
>  Standards
>  
>   IEEE Standard 802.3: CSMA/CD Access Method and Physical Layer Specifications, Section Two:
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index aeaf1bc..32fa7c7 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -235,6 +235,53 @@ int phy_register_fixup_for_id(const char *bus_id,
>  }
>  EXPORT_SYMBOL(phy_register_fixup_for_id);
>  
> +/**
> + * phy_unregister_fixup - remove a phy_fixup from the list
> + * @bus_id: A string matches fixup->bus_id (or PHY_ANY_ID) in phy_fixup_list
> + * @phy_uid: A phy id matches fixup->phy_id (or PHY_ANY_UID) in phy_fixup_list
> + * @phy_uid_mask: Applied to phy_uid and fixup->phy_uid before comparison
> + */
> +int phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask)
> +{
> +	struct list_head *pos, *n;
> +	struct phy_fixup *fixup;
> +	int ret;
> +
> +	ret = -ENODEV;
> +
> +	mutex_lock(&phy_fixup_lock);
> +	list_for_each_safe(pos, n, &phy_fixup_list) {
> +		fixup = list_entry(pos, struct phy_fixup, list);
> +
> +		if ((!strcmp(fixup->bus_id, bus_id)) &&
> +		    ((fixup->phy_uid & phy_uid_mask) ==
> +		     (phy_uid & phy_uid_mask))) {
> +			list_del(&fixup->list);
> +			kfree(fixup);
> +			ret = 0;
> +			break;
> +		}
> +	}
> +	mutex_unlock(&phy_fixup_lock);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(phy_unregister_fixup);
> +
I just want to commit the unregister patch and found this patch. Good job!
But I consider this patch may miss something.
If one SoC has 2 MAC ports and each port uses the different network driver,
the 2 drivers may register fixup for the same PHY chip with different
"run" function because the PHY chip works in different mode.
In such a case, this patch doesn't consider "run" function and may cause problem.
When removing the driver which register fixup at last, it will remove another
driver's fixup.
Should this condition be considered and fixed?

> +/* Unregisters a fixup of any PHY with the UID in phy_uid */
> +int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask)
> +{
> +	return phy_unregister_fixup(PHY_ANY_ID, phy_uid, phy_uid_mask);
> +}
> +EXPORT_SYMBOL(phy_unregister_fixup_for_uid);
> +
> +/* Unregisters a fixup of the PHY with id string bus_id */
> +int phy_unregister_fixup_for_id(const char *bus_id)
> +{
> +	return phy_unregister_fixup(bus_id, PHY_ANY_UID, 0xffffffff);
> +}
> +EXPORT_SYMBOL(phy_unregister_fixup_for_id);
> +
>  /* Returns 1 if fixup matches phydev in bus_id and phy_uid.
>   * Fixups can be set to match any in one or more fields.
>   */
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index feb8a98..f7d95f6 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -860,6 +860,10 @@ int phy_register_fixup_for_id(const char *bus_id,
>  int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
>  			       int (*run)(struct phy_device *));
>  
> +int phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask);
> +int phy_unregister_fixup_for_id(const char *bus_id);
> +int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask);
> +
>  int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
>  int phy_get_eee_err(struct phy_device *phydev);
>  int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data);
> 


    Regards,
    Dongpo

.
