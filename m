From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 20/20] i40e: don't allow i40e_vsi_(add|kill)_vlan to
 operate when VID<1
Date: Wed, 7 Dec 2016 13:10:44 +0300
Message-ID: <8f82cd1d-0118-7b37-1a05-fa7b77d4e75c@cogentembedded.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
 <20161207073354.88568-21-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38333 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752242AbcLGKKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 05:10:45 -0500
Received: by mail-wm0-f47.google.com with SMTP id f82so158645811wmf.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 02:10:44 -0800 (PST)
In-Reply-To: <20161207073354.88568-21-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 12/7/2016 10:33 AM, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>
>
> Now that we have the separate i40e_(add|rm)_vlan_all_mac functions, we
> should not be using the i40e_vsi_kill_vlan or i40e_vsi_add_vlan
> functions when PVID is set or when VID is less than 1. This allows us to
> remove some checks in i40e_vsi_add_vlan and ensures that callers which
> need to handle VID=0 or VID=-1 don't accidentally invoke the VLAN mode
> handling used to convert filters when entering VLAN mode. We also update
> the functions to take u16 instead of s16 as well since they no longer
> expect to be called with VID=I40E_VLAN_ANY.
>
> Change-ID: Ibddf44a8bb840dde8ceef2a4fdb92fd953b05a57
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index da4cbe3..148a678 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -2575,12 +2575,15 @@ int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
>  /**
>   * i40e_vsi_add_vlan - Add VSI membership for given VLAN
>   * @vsi: the VSI being configured
> - * @vid: VLAN id to be added (0 = untagged only , -1 = any)
> + * @vid: VLAN id to be added
>   **/
> -int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
> +int i40e_vsi_add_vlan(struct i40e_vsi *vsi, u16 vid)
>  {
>  	int err;
>
> +	if (!(vid > 0) || vsi->info.pvid)

    Why not just '!vid'?

> +		return -EINVAL;
> +
>  	/* Locked once because all functions invoked below iterates list*/
>  	spin_lock_bh(&vsi->mac_filter_hash_lock);
>  	err = i40e_add_vlan_all_mac(vsi, vid);
> @@ -2623,10 +2626,13 @@ void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
>  /**
>   * i40e_vsi_kill_vlan - Remove VSI membership for given VLAN
>   * @vsi: the VSI being configured
> - * @vid: VLAN id to be removed (0 = untagged only , -1 = any)
> + * @vid: VLAN id to be removed
>   **/
> -void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
> +void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, u16 vid)
>  {
> +	if (!(vid > 0) || vsi->info.pvid)

    Likewise.

> +		return;
> +
>  	spin_lock_bh(&vsi->mac_filter_hash_lock);
>  	i40e_rm_vlan_all_mac(vsi, vid);
>  	spin_unlock_bh(&vsi->mac_filter_hash_lock);

MBR, Sergei
