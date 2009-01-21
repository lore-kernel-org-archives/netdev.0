From: Jonathan Fournier <jonathan.fournier@gmail.com>
Subject: Fwd: Question regarding e1000 link status
Date: Wed, 21 Jan 2009 15:12:27 -0500
Message-ID: <b1640ef40901211212k39dbc28eq86fe5e7c2d4d575b@mail.gmail.com>
References: <b1640ef40901191409qe39f3tcd8efd041677997c@mail.gmail.com>
	 <b1640ef40901201500w5f31896k75a76ebf6b8349b1@mail.gmail.com>
	 <b1640ef40901201547v1a1c19dxc10a8eced3a50cda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:59851 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbZAUUM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 15:12:28 -0500
Received: by rv-out-0506.google.com with SMTP id k40so3761640rvb.1
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 12:12:27 -0800 (PST)
In-Reply-To: <b1640ef40901201547v1a1c19dxc10a8eced3a50cda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm forwarding to netdev, a little thread I created yesterday on
e1000-devel (3 posted messages). Trying to reach a wider audience.

Cheers,

/jonathan

---------- Forwarded message ----------
From: Jonathan Fournier <jonathan.fournier@gmail.com>
Date: Tue, Jan 20, 2009 at 6:47 PM
Subject: Re: Question regarding e1000 link status
To: e1000-devel@lists.sourceforge.net


>From e1000_hw.c: e1000_set_media_type()
...
       default:
           status = er32(STATUS);
           if (status & E1000_STATUS_TBIMODE) {
               hw->media_type = e1000_media_type_fiber;
               /* tbi_compatibility not valid on fiber */
               hw->tbi_compatibility_en = false;
           } else {
               hw->media_type = e1000_media_type_copper;
           }
           break;
       }

Could it be possible that the media_type is set to fiber by error here?

I'm trying to compare with the source of the last version 8.0.9, and
only finding assignments to "phy.media_type" in those files:

e1000_82540.c:164:              hw->phy.media_type = e1000_media_type_fiber;
e1000_82540.c:168:              hw->phy.media_type =
e1000_media_type_internal_serdes;
e1000_82540.c:171:              hw->phy.media_type = e1000_media_type_copper;
e1000_82541.c:224:      hw->phy.media_type = e1000_media_type_copper;
e1000_82542.c:100:      hw->phy.media_type = e1000_media_type_fiber;
e1000_82543.c:196:              hw->phy.media_type = e1000_media_type_fiber;
e1000_82543.c:199:              hw->phy.media_type = e1000_media_type_copper;

Cheers,

/jonathan

On Tue, Jan 20, 2009 at 6:00 PM, Jonathan Fournier
<jonathan.fournier@gmail.com> wrote:
> Hi,
>
> I've found more information to share about my problem.
>
> I'm debugging on the ATCA-7101, I initially thought from the datasheet
> that it had a 82546EB, but by printing the pdev->device it has a value
> of 0x1079 = E1000_DEV_ID_82546GB_COPPER.
>
> Since in the patch I've previously provided, I was wondering why the
> PHY Reset hacks were done based on the hw.media_type ==
> e1000_media_type_fiber || e1000_media_type_internal_serdes.
>
> I also added info in the printk displayed at boot time:
>
>        /* print bus type/speed/width info */
> -       DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
> +       DPRINTK(PROBE, INFO, "(PCI%s:%s:%s:%04x:%d) ",
>                ((hw->bus_type == e1000_bus_type_pcix) ? "-X" :
>                 (hw->bus_type == e1000_bus_type_pci_express ? " Express":"")),
>                ((hw->bus_speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
> @@ -1194,7 +1198,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>                ((hw->bus_width == e1000_bus_width_64) ? "64-bit" :
>                 (hw->bus_width == e1000_bus_width_pciex_4) ? "Width x4" :
>                 (hw->bus_width == e1000_bus_width_pciex_1) ? "Width x1" :
> -                "32-bit"));
> +                "32-bit"), pdev->device, hw->media_type);
>
> --------->--------->--------->--------->--------->--------->--------->--------->--------->---------
>
> Intel(R) PRO/1000 Network Driver - version 7.3.20-k3-NAPI
> Copyright (c) 1999-2006 Intel Corporation.
> ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
> PCI: setting IRQ 10 as level-triggered
> e1000 0000:0b:01.0: PCI INT A -> Link[LNKA] -> GSI 10 (level, low) -> IRQ 10
> e1000: 0000:0b:01.0: e1000_probe: (PCI-X:133MHz:64-bit:1079:0) 00:01:af:15:82:f2
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000 0000:0b:01.1: PCI INT B -> Link[LNKA] -> GSI 10 (level, low) -> IRQ 10
> e1000: 0000:0b:01.1: e1000_probe: (PCI-X:133MHz:64-bit:1079:0) 00:01:af:15:82:f3
> Switched to high resolution mode on CPU 0
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000 0000:0a:01.0: PCI INT A -> Link[LNKA] -> GSI 10 (level, low) -> IRQ 10
> e1000: 0000:0a:01.0: e1000_probe: (PCI-X:133MHz:64-bit:1079:1) 00:01:af:15:82:f0
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000 0000:0a:01.1: PCI INT B -> Link[LNKA] -> GSI 10 (level, low) -> IRQ 10
> e1000: 0000:0a:01.1: e1000_probe: (PCI-X:133MHz:64-bit:1079:1) 00:01:af:15:82:f1
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 7
> PCI: setting IRQ 7 as level-triggered
> e1000 0000:07:01.0: PCI INT A -> Link[LNKB] -> GSI 7 (level, low) -> IRQ 7
> e1000: 0000:07:01.0: e1000_probe: (PCI-X:133MHz:64-bit:1079:0) 00:01:af:15:82:f4
> e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000 0000:07:01.1: PCI INT B -> Link[LNKB] -> GSI 7 (level, low) -> IRQ 7
> e1000: 0000:07:01.1: e1000_probe: (PCI-X:133MHz:64-bit:1079:0) 00:01:af:15:82:f5
> e1000: eth5: e1000_probe: Intel(R) PRO/1000 Network Connection
>
> --------->--------->--------->--------->--------->--------->--------->--------->--------->---------
>
> To my surprise, two of the interface had this: (PCI-X:133MHz:64-bit:1079:1)
>
> pdev->device = E1000_DEV_ID_82546GB_COPPER = 0x1079
> hw->media_type = e1000_media_type_fiber = 1
>
> Is it really possible that a 82546GB_COPPER uses fiber as it's media
> type? If not that could explain why such an hack was introduced to
> make sure the PHY reset occured?
>
> I don't know much about e1000 internals, so I'm asking if it's an
> error, and how come the media_type could be set wrong then?
>
> Cheers,
>
> /jonathan
>
> On Mon, Jan 19, 2009 at 5:09 PM, Jonathan Fournier
> <jonathan.fournier@gmail.com> wrote:
>> Hi,
>>
>> I'm currently doing some cleanup in *very* old patches I had against
>> 2.6.10. (patch inlined below)
>>
>> At that time a patch was provided to me to fix link status problems on
>> two ATCA boards (Mot ATCA-7101 and Mot ATCA-6101). If I'm correct the
>> 7101 is using a variant of the 82546EB, and the 6101 a variant of the
>> 82546GB.
>>
>> I'm trying to achieve two things with that patch:
>>
>> 1. Cleanup the #if defined (CONFIG_ ...) that are introducing
>> useless kernel CONFIG options that are probably not board specific.
>>
>>        1.a If needed move those to check based on DEVID or media_type
>>        1.b If not needed, trash them.
>>
>> 2. Asking around if playing with those PHY registers is the best
>> approach.
>>        2.a Submit patch upstream when cleaned up
>>
>> I'm currently testing with the e1000 driver as of "commit
>> c6c427835cd755115a0f86da1aa9c97b2f8ffff8" (2.6.27.11)
>>
>> When issuing ifdown on the interfaces I get some hanging, so I believe
>> those old changes might still be required in their current form, or
>> rebased for the current driver.
>>
>> I think I've identified where in the current driver where that code
>> could fit, just asking around if you think it could be needed.
>>
>> Cheers,
>>
>> /jonathan
>>
>> ----------------------------------------------------------------------
>>
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -29,6 +29,9 @@
>>  #include "e1000.h"
>>
>>  /* Change Log
>> + * 5.3.13      3/23/06
>> + * - synchronize physical link with interface (j.pietro@xxx)
>> + *
>>  * 5.3.12      6/7/04
>>  * - kcompat NETIF_MSG for older kernels (2.4.9) <sean.p.mcdermott@xxx>
>>  * - if_mii support and associated kcompat for older kernels
>> @@ -258,12 +261,35 @@
>>        /* hardware has been reset, we need to reload some things */
>>
>>        /* Reset the PHY if it was previously powered down */
>> -       if(adapter->hw.media_type == e1000_media_type_copper) {
>> +       if(adapter->hw.media_type == e1000_media_type_copper)
>> +       {
>>                uint16_t mii_reg;
>>                e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
>>                if(mii_reg & MII_CR_POWER_DOWN)
>>                        e1000_phy_reset(&adapter->hw);
>>        }
>> +#if defined(CONFIG_PPC_ATCA6101) || defined(CONFIG_INTEL_ATCA7101)
>> +       else if((adapter->hw.media_type == e1000_media_type_fiber) ||
>> +               (adapter->hw.media_type == e1000_media_type_internal_serdes))
>> +       {
>> +               int32_t  ret_val;
>> +               int32_t  ret_val2;
>> +               uint16_t default_page = 0;
>> +               uint16_t phy_data;
>> +
>> +               /* Set PHY register 30, page 31, bits 15:0 <= 0h */
>> +               ret_val2 = ret_val = e1000_read_phy_reg(&adapter->hw,
>> M88E1000_PHY_PAGE_SELECT, &default_page);
>> +               if(ret_val == E1000_SUCCESS)
>> +                       ret_val = e1000_write_phy_reg(&adapter->hw,
>> M88E1000_PHY_PAGE_SELECT, 31);
>> +               if(ret_val == E1000_SUCCESS)
>> +                       ret_val = e1000_read_phy_reg(&adapter->hw,
>> M88E1000_PHY_GEN_CONTROL, &phy_data);
>> +               phy_data &= 0xFFFF0000;
>> +               if(ret_val == E1000_SUCCESS)
>> +                       e1000_write_phy_reg(&adapter->hw,
>> M88E1000_PHY_GEN_CONTROL, phy_data);
>> +               if(ret_val2 == E1000_SUCCESS)
>> +                       e1000_write_phy_reg(&adapter->hw,
>> M88E1000_PHY_PAGE_SELECT, default_page);
>> +       }
>> +#endif
>>
>>        e1000_set_multi(netdev);
>>
>> @@ -306,12 +332,43 @@
>>
>>        /* If WoL is not enabled
>>         * Power down the PHY so no link is implied when interface is down */
>> +#if defined(CONFIG_PPC_ATCA6101) || defined(CONFIG_INTEL_ATCA7101)
>> +       if(!adapter->wol)
>> +       {
>> +               if(adapter->hw.media_type == e1000_media_type_copper)
>> +               {
>> +#else
>>        if(!adapter->wol && adapter->hw.media_type == e1000_media_type_copper) {
>> +#endif
>>                uint16_t mii_reg;
>>                e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
>>                mii_reg |= MII_CR_POWER_DOWN;
>>                e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
>>        }
>> +#if defined(CONFIG_PPC_ATCA6101) || defined(CONFIG_INTEL_ATCA7101)
>> +               else if((adapter->hw.media_type == e1000_media_type_fiber) ||
>> +                       (adapter->hw.media_type ==
>> e1000_media_type_internal_serdes))
>> +               {
>> +                       int32_t  ret_val;
>> +                       int32_t  ret_val2;
>> +                       uint16_t default_page = 0;
>> +                       uint16_t phy_data;
>> +
>> +                       /* Set PHY register 30, page 31, bits 15:0 <= 2001h */
>> +                       ret_val2 = ret_val =
>> e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_PAGE_SELECT,
>> &default_page);
>> +                       if(ret_val == E1000_SUCCESS)
>> +                               ret_val =
>> e1000_write_phy_reg(&adapter->hw, M88E1000_PHY_PAGE_SELECT, 31);
>> +                       if(ret_val == E1000_SUCCESS)
>> +                               ret_val =
>> e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_GEN_CONTROL, &phy_data);
>> +                       phy_data &= 0xFFFF0000;
>> +                       phy_data |= 0x2001;
>> +                       if(ret_val == E1000_SUCCESS)
>> +                               ret_val =
>> e1000_write_phy_reg(&adapter->hw, M88E1000_PHY_GEN_CONTROL, phy_data);
>> +                       if(ret_val2 == E1000_SUCCESS)
>> +                               e1000_write_phy_reg(&adapter->hw,
>> M88E1000_PHY_PAGE_SELECT, default_page);
>> +               }
>> +       }
>> +#endif
>>  }
>>
>>  void
>> @@ -588,6 +645,42 @@
>>        if((err = register_netdev(netdev)))
>>                goto err_register;
>>
>> +#if defined(CONFIG_PPC_ATCA6101) || defined(CONFIG_INTEL_ATCA7101)
>> +       /* If WoL is not enabled
>> +        * Power down the PHY so no link is implied when interface is down */
>> +       if(!adapter->wol)
>> +       {
>> +               if(adapter->hw.media_type == e1000_media_type_copper)
>> +               {
>> +                       uint16_t mii_reg;
>> +                       e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
>> +                       mii_reg |= MII_CR_POWER_DOWN;
>> +                       e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
>> +               }
>> +               else if((adapter->hw.media_type == e1000_media_type_fiber) ||
>> +                       (adapter->hw.media_type ==
>> e1000_media_type_internal_serdes))
>> +               {
>> +                       int32_t  ret_val;
>> +                       int32_t  ret_val2;
>> +                       uint16_t default_page = 0;
>> +                       uint16_t phy_data;
>> +
>> +                       /* Set PHY register 30, page 31, bits 15:0 <= 2001h */
>> +                       ret_val2 = ret_val =
>> e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_PAGE_SELECT,
>> &default_page);
>> +                       if(ret_val == E1000_SUCCESS)
>> +                               ret_val =
>> e1000_write_phy_reg(&adapter->hw, M88E1000_PHY_PAGE_SELECT, 31);
>> +                       if(ret_val == E1000_SUCCESS)
>> +                               ret_val =
>> e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_GEN_CONTROL, &phy_data);
>> +                       phy_data &= 0xFFFF0000;
>> +                       phy_data |= 0x2001;
>> +                       if(ret_val == E1000_SUCCESS)
>> +                               ret_val =
>> e1000_write_phy_reg(&adapter->hw, M88E1000_PHY_GEN_CONTROL, phy_data);
>> +                       if(ret_val2 == E1000_SUCCESS)
>> +                               e1000_write_phy_reg(&adapter->hw,
>> M88E1000_PHY_PAGE_SELECT, default_page);
>> +               }
>> +       }
>> +#endif
>> +
>>        DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
>>
>>        cards_found++;
>>
>
