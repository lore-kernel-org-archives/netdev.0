From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/21] e1000: force register write flushes to circumvent
 broken platforms
Date: Mon, 26 Jun 2006 21:47:31 -0400
Message-ID: <44A08E33.3020501@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052027.25497.51513.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32980 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030581AbWF0Bre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:47:34 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052027.25497.51513.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> A certain AMD64 bridge (8132) has an option to turn on write combining
> which breaks our adapter. To circumvent this we need to flush every write.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_hw.c   |   24 ++++++++++++++++++++++--
>  drivers/net/e1000/e1000_main.c |   18 +++++++++++-------
>  2 files changed, 33 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
> index 3959039..749d621 100644
> --- a/drivers/net/e1000/e1000_hw.c
> +++ b/drivers/net/e1000/e1000_hw.c
> @@ -705,8 +705,12 @@ e1000_init_hw(struct e1000_hw *hw)
>      /* Zero out the Multicast HASH table */
>      DEBUGOUT("Zeroing the MTA\n");
>      mta_size = E1000_MC_TBL_SIZE;
> -    for(i = 0; i < mta_size; i++)
> +    for(i = 0; i < mta_size; i++) {
>          E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
> +        /* use write flush to prevent Memory Write Block (MWB) from
> +         * occuring when accessing our register space */
> +        E1000_WRITE_FLUSH(hw);
> +    }

NAK.  We can't crap up every driver just for one weird piece of hardware.

If this problem falls outside the grounds of mmiowb() [see 
Documentation/memory-barriers.txt], then other solutions need to be 
looked into... ioremap_nocache() ?  Tweaking the MTRR for this region? 
Chipset quirk?  ...

	Jeff



