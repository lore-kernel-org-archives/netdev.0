From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH 10/19] [repost] powerpc: move get_longbusy_msecs out of
 ehca/ehea
Date: Fri, 13 Jun 2008 13:24:03 -0500
Message-ID: <4852BB43.9080305@linux.vnet.ibm.com>
References: <20080612221848.GR30916@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Santiago Leon <santil@us.ibm.com>,
	Nathan Fontenot <nfont@austin.ibm.com>,
	David Darrington <ddarring@linux.vnet.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:39534 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037AbYFMSYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 14:24:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5DIOUvD001389
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 14:24:30 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5DIOUjJ089920
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 14:24:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5DIOTo4000629
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 14:24:30 -0400
In-Reply-To: <20080612221848.GR30916@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Regarding the patches Rob just posted here, we'd like to just take them
through the powerpc tree with your sign off since they are part of a
Power platform feature we are enabling.

Thanks,

Brian

Robert Jennings wrote:
> From: Robert Jennings <rcj@linux.vnet.ibm.com>
> 
> In support of Cooperative Memory Overcommitment (CMO) this moves
> get_longbusy_msecs() out of the ehca and ehea drivers and into the 
> architecture's hvcall header as plpar_get_longbusy_msecs.  Some firmware
> calls made in pSeries platform iommu code will need to share this
> functionality.
> 
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
> 
> ---
> 
> I missed copying netdev on this patch the first time.
> 
>  drivers/infiniband/hw/ehca/hcp_if.c |   24 ++----------------------
>  drivers/net/ehea/ehea_phyp.c        |    4 ++--
>  drivers/net/ehea/ehea_phyp.h        |   20 --------------------
>  include/asm-powerpc/hvcall.h        |   27 +++++++++++++++++++++++++++
>  4 files changed, 31 insertions(+), 44 deletions(-)
> 
> Index: b/drivers/infiniband/hw/ehca/hcp_if.c
> ===================================================================
> --- a/drivers/infiniband/hw/ehca/hcp_if.c
> +++ b/drivers/infiniband/hw/ehca/hcp_if.c
> @@ -90,26 +90,6 @@
>  
>  static DEFINE_SPINLOCK(hcall_lock);
>  
> -static u32 get_longbusy_msecs(int longbusy_rc)
> -{
> -	switch (longbusy_rc) {
> -	case H_LONG_BUSY_ORDER_1_MSEC:
> -		return 1;
> -	case H_LONG_BUSY_ORDER_10_MSEC:
> -		return 10;
> -	case H_LONG_BUSY_ORDER_100_MSEC:
> -		return 100;
> -	case H_LONG_BUSY_ORDER_1_SEC:
> -		return 1000;
> -	case H_LONG_BUSY_ORDER_10_SEC:
> -		return 10000;
> -	case H_LONG_BUSY_ORDER_100_SEC:
> -		return 100000;
> -	default:
> -		return 1;
> -	}
> -}
> -
>  static long ehca_plpar_hcall_norets(unsigned long opcode,
>  				    unsigned long arg1,
>  				    unsigned long arg2,
> @@ -139,7 +119,7 @@ static long ehca_plpar_hcall_norets(unsi
>  			spin_unlock_irqrestore(&hcall_lock, flags);
>  
>  		if (H_IS_LONG_BUSY(ret)) {
> -			sleep_msecs = get_longbusy_msecs(ret);
> +			sleep_msecs = plpar_get_longbusy_msecs(ret);
>  			msleep_interruptible(sleep_msecs);
>  			continue;
>  		}
> @@ -192,7 +172,7 @@ static long ehca_plpar_hcall9(unsigned l
>  			spin_unlock_irqrestore(&hcall_lock, flags);
>  
>  		if (H_IS_LONG_BUSY(ret)) {
> -			sleep_msecs = get_longbusy_msecs(ret);
> +			sleep_msecs = plpar_get_longbusy_msecs(ret);
>  			msleep_interruptible(sleep_msecs);
>  			continue;
>  		}
> Index: b/drivers/net/ehea/ehea_phyp.c
> ===================================================================
> --- a/drivers/net/ehea/ehea_phyp.c
> +++ b/drivers/net/ehea/ehea_phyp.c
> @@ -61,7 +61,7 @@ static long ehea_plpar_hcall_norets(unsi
>  					 arg5, arg6, arg7);
>  
>  		if (H_IS_LONG_BUSY(ret)) {
> -			sleep_msecs = get_longbusy_msecs(ret);
> +			sleep_msecs = plpar_get_longbusy_msecs(ret);
>  			msleep_interruptible(sleep_msecs);
>  			continue;
>  		}
> @@ -102,7 +102,7 @@ static long ehea_plpar_hcall9(unsigned l
>  				   arg6, arg7, arg8, arg9);
>  
>  		if (H_IS_LONG_BUSY(ret)) {
> -			sleep_msecs = get_longbusy_msecs(ret);
> +			sleep_msecs = plpar_get_longbusy_msecs(ret);
>  			msleep_interruptible(sleep_msecs);
>  			continue;
>  		}
> Index: b/drivers/net/ehea/ehea_phyp.h
> ===================================================================
> --- a/drivers/net/ehea/ehea_phyp.h
> +++ b/drivers/net/ehea/ehea_phyp.h
> @@ -40,26 +40,6 @@
>   * hcp_*  - structures, variables and functions releated to Hypervisor Calls
>   */
>  
> -static inline u32 get_longbusy_msecs(int long_busy_ret_code)
> -{
> -	switch (long_busy_ret_code) {
> -	case H_LONG_BUSY_ORDER_1_MSEC:
> -		return 1;
> -	case H_LONG_BUSY_ORDER_10_MSEC:
> -		return 10;
> -	case H_LONG_BUSY_ORDER_100_MSEC:
> -		return 100;
> -	case H_LONG_BUSY_ORDER_1_SEC:
> -		return 1000;
> -	case H_LONG_BUSY_ORDER_10_SEC:
> -		return 10000;
> -	case H_LONG_BUSY_ORDER_100_SEC:
> -		return 100000;
> -	default:
> -		return 1;
> -	}
> -}
> -
>  /* Number of pages which can be registered at once by H_REGISTER_HEA_RPAGES */
>  #define EHEA_MAX_RPAGE 512
>  
> Index: b/include/asm-powerpc/hvcall.h
> ===================================================================
> --- a/include/asm-powerpc/hvcall.h
> +++ b/include/asm-powerpc/hvcall.h
> @@ -222,6 +222,33 @@
>  #ifndef __ASSEMBLY__
>  
>  /**
> + * plpar_get_longbusy_msecs: - Return number of msecs for H_LONG_BUSY* response
> + * @long_busy_ret_code: The H_LONG_BUSY_* constant to process
> + *
> + * This returns the number of msecs that corresponds to an H_LONG_BUSY_*
> + * response from a plpar_hcall.  If there is no match 1 is returned.
> + */
> +static inline u32 plpar_get_longbusy_msecs(int long_busy_ret_code)
> +{
> +	switch (long_busy_ret_code) {
> +	case H_LONG_BUSY_ORDER_1_MSEC:
> +		return 1;
> +	case H_LONG_BUSY_ORDER_10_MSEC:
> +		return 10;
> +	case H_LONG_BUSY_ORDER_100_MSEC:
> +		return 100;
> +	case H_LONG_BUSY_ORDER_1_SEC:
> +		return 1000;
> +	case H_LONG_BUSY_ORDER_10_SEC:
> +		return 10000;
> +	case H_LONG_BUSY_ORDER_100_SEC:
> +		return 100000;
> +	default:
> +		return 1;
> +	}
> +}
> +
> +/**
>   * plpar_hcall_norets: - Make a pseries hypervisor call with no return arguments
>   * @opcode: The hypervisor call to make.
>   *


-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


