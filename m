From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: repost work around 82571 completion timout on
 pseries HW
Date: Tue, 24 Jul 2007 08:31:08 -0700
Message-ID: <46A61B3C.5070808@intel.com>
References: <20070724151912.GA2293@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39321 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759240AbXGXPbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 11:31:21 -0400
In-Reply-To: <20070724151912.GA2293@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> There seems to have been some discussion about a patch like this in the
> past but I still haven't noticed any platforms fixes or noticed that
> this got included, so I'd like to propose this modified version.
> 
> Thoughts?

I've written a completely new version for IBM based on the response that 
implements this as a pci quirk (to tag the chipset, not the device).

However IBM has spotted an issue due to firmware hiding the id for linux of the 
bridge involved (on pseries), and they're working on an alternative to fix that.

So, the patch will look different, and I'll post it as soon as we have a version 
for both pseries and xseries that works.

Auke


> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
> 
>  e1000_hw.c |    7 +++++++
>  e1000_hw.h |    1 +
>  2 files changed, 8 insertions(+)
> 
> diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
> index 9be4469..7c75b8b 100644
> --- a/drivers/net/e1000/e1000_hw.c
> +++ b/drivers/net/e1000/e1000_hw.c
> @@ -1030,6 +1030,13 @@ e1000_init_hw(struct e1000_hw *hw)
>          break;
>      }
>  
> +#if defined(CONFIG_PPC_PSERIES)
> +    if (hw->mac_type == e1000_82571) {
> +        uint32_t gcr = E1000_READ_REG(hw, GCR);
> +        gcr |= E1000_GCR_DISABLE_TIMEOUT_MECHANISM;
> +        E1000_WRITE_REG(hw, GCR, gcr);
> +    }
> +#endif 
>  
>      if (hw->mac_type == e1000_82573) {
>          uint32_t gcr = E1000_READ_REG(hw, GCR);
> diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
> index bd000b8..71f4e2d 100644
> --- a/drivers/net/e1000/e1000_hw.h
> +++ b/drivers/net/e1000/e1000_hw.h
> @@ -2211,6 +2211,7 @@ struct e1000_host_command_info {
>  #define PCI_EX_82566_SNOOP_ALL PCI_EX_NO_SNOOP_ALL
>  
>  #define E1000_GCR_L1_ACT_WITHOUT_L0S_RX 0x08000000
> +#define E1000_GCR_DISABLE_TIMEOUT_MECHANISM 0x80000000
>  /* Function Active and Power State to MNG */
>  #define E1000_FACTPS_FUNC0_POWER_STATE_MASK         0x00000003
>  #define E1000_FACTPS_LAN0_VALID                     0x00000004
