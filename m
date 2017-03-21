From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 05/13] i40e: rework exit flow of i40e_add_fdir_ethtool
Date: Tue, 21 Mar 2017 13:11:05 +0300
Message-ID: <2871a7df-bdd7-7f74-8326-40bf381e65cd@cogentembedded.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
 <20170320234712.84157-6-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34166 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756711AbdCUKUL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 06:20:11 -0400
Received: by mail-lf0-f50.google.com with SMTP id z15so65411652lfd.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 03:19:41 -0700 (PDT)
In-Reply-To: <20170320234712.84157-6-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/21/2017 2:47 AM, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>
>
> Refactor the exit flow of the i40e_add_fdir_ethtool function. Move the
> input_label to the end of the function, removing the dependency on

    I don't see 'input_label' anywhere. Perhaps 'free_input' label was meant?

> having a non-zero return value. Add a comment explaining why it is ok
> not to free the fdir data structure, because the structure is now stored
> in the fdir_filter_list.
>
> Change-Id: I723342181d59cd0c9f3b31140c37961ba37bb242
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index 7a22b473dbdd..d16a5a6b24fc 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -2828,12 +2828,19 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
>  	}
>
>  	ret = i40e_add_del_fdir(vsi, input, true);
> -free_input:
>  	if (ret)
> -		kfree(input);
> -	else
> -		i40e_update_ethtool_fdir_entry(vsi, input, fsp->location, NULL);
> +		goto free_input;
> +
> +	/* Add the input filter to the fdir_input_list, possibly replacing
> +	 * a previous filter. Do not free the input structure after adding it
> +	 * to the list as this would cause a use-after-free bug.
> +	 */
> +	i40e_update_ethtool_fdir_entry(vsi, input, fsp->location, NULL);
>
> +	return 0;
> +
> +free_input:
> +	kfree(input);
>  	return ret;
>  }

MBR, Sergei
