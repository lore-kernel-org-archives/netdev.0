From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net 2/5] e1000e: fix compiler warnings
Date: Wed, 18 Dec 2013 19:51:49 -0800
Message-ID: <CAL3LdT4bjaOABM_SVZsZJeH4Jr7a01Zn5M+bNAt8djAo0bioFQ@mail.gmail.com>
References: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1387351186-23389-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ertman <davidx.m.ertman@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387351186-23389-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 17, 2013 at 11:19 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: David Ertman <davidx.m.ertman@intel.com>
>
> This patch is to fix a compiler warning of __bad_udelay due to a value
> of >999 being passed as a parameter to udelay() in the function
> e1000e_phy_has_link_generic().  This affects the gcc compiler when
> it is given a flag of -O3 and the icc compiler.
>
> This patch is also making the change from mdelay() to msleep() in the
> same function, since it was determined though code inspection that this
> function is never called in atomic context.
>

CC: stable <stable@vger.kernel.org> # 3.9+

> Signed-off-by: David Ertman <davidx.m.ertman@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/phy.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
> index da2be59..20e71f4 100644
> --- a/drivers/net/ethernet/intel/e1000e/phy.c
> +++ b/drivers/net/ethernet/intel/e1000e/phy.c
> @@ -1757,19 +1757,23 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
>                  * it across the board.
>                  */
>                 ret_val = e1e_rphy(hw, MII_BMSR, &phy_status);
> -               if (ret_val)
> +               if (ret_val) {
>                         /* If the first read fails, another entity may have
>                          * ownership of the resources, wait and try again to
>                          * see if they have relinquished the resources yet.
>                          */
> -                       udelay(usec_interval);
> +                       if (usec_interval >= 1000)
> +                               msleep(usec_interval / 1000);
> +                       else
> +                               udelay(usec_interval);
> +               }
>                 ret_val = e1e_rphy(hw, MII_BMSR, &phy_status);
>                 if (ret_val)
>                         break;
>                 if (phy_status & BMSR_LSTATUS)
>                         break;
>                 if (usec_interval >= 1000)
> -                       mdelay(usec_interval / 1000);
> +                       msleep(usec_interval / 1000);
>                 else
>                         udelay(usec_interval);
>         }
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cheers,
Jeff
