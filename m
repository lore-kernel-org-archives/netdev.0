From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Mon, 10 Oct 2016 17:02:44 +0300
Message-ID: <1476108164.5210.11.camel@coelho.fi>
References: <20161010071943.4717-1-chris@rorvick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Chris Rorvick <chris@rorvick.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010071943.4717-1-chris@rorvick.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
On Mon, 2016-10-10 at 02:19 -0500, Chris Rorvick wrote:
> Commit bcb079a14d75 ("iwlwifi: pcie: retrieve and parse ACPI power
> limitations") looks for a specific structure in the ACPI tables for
> setting the default power limit.  The data returned for at least some
> dual band chipsets is not recognized, though.  For example, the AC 8260
> reports the following:

This is not coming from the NIC itself, but from the platform's ACPI
tables.  Can you tell us which platform you are using?


>         Name (SPLX, Package (0x04)
>         {
>             Zero,
>             Package (0x03)
>             {
>                 0,
>                 1200,
>                 1000
>             },
>             Package (0x03)
>             {
>                 0,
>                 1200,
>                 1000
>             },
>             Package (0x03)
>             {
>                 0,
>                 1200,
>                 1000
>             }
>         })

This is not the structure that we are expecting.  We expect this:

               Name (SPLX, Package (0x02)
               {
                   Zero,
                   Package (0x03)
                   {
                       0x07,
                       <value>,
                       <value>
                   }
               })

...as you correctly pointed out.  The data in the structure you have is
not for WiFi (actually I don't think 0 is a valid value, but I'll
double-check).


> The current logic expects exactly two elements in the outer package,
> causing the above to be ignored and the power limit unset.
> 
> Despite the interface being fully functional after initialization, the
> above condition is reported as an error.  Knock the message down to a
> warning and provide better context for understanding its consequence.

Reducing this to a warning is an easy way to reduce the verbosity of
the problem, but I think the correct thing to do would be to accept
multiple entries and ignore the ones that don't have the WIFI marker.
 And only type-check the WIFI ones.

There are other things that look a bit inconsistent in this code...
I'll try to find the official ACPI table definitions for this entries
to make sure it's correct.


> Signed-off-by: Chris Rorvick <chris@rorvick.com>
> ---
>  drivers/net/wireless/intel/iwlwifi/pcie/drv.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> index 78cf9a7..19b531f 100644
> --- a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> +++ b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> @@ -540,7 +540,7 @@ static u64 splx_get_pwr_limit(struct iwl_trans *trans, union acpi_object *splx)
>  	    splx->package.count != 2 ||
>  	    splx->package.elements[0].type != ACPI_TYPE_INTEGER ||
>  	    splx->package.elements[0].integer.value != 0) {
> -		IWL_ERR(trans, "Unsupported splx structure\n");
> +		IWL_WARN(trans, "Unsupported splx structure, not limiting WiFi power\n");
>  		return 0;
>  	}

If this is really bothering you, I guess I could apply this patch for
now.  But as I said, this is not solving the actual problem.

--
Cheers,
Luca.
