From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 14/17] i40e: implement ethtool RSS config
Date: Sat, 22 Nov 2014 10:22:27 -0800
Message-ID: <1416680547.20938.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416635708-4765-16-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:57899 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaKVSW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 13:22:29 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so6837310ier.32
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 10:22:29 -0800 (PST)
In-Reply-To: <1416635708-4765-16-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-21 at 21:55 -0800, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> Support ethtool methods for getting and setting the RSS look-up table.
> 
> Change-ID: I52707fb371fc11fe9fd4c287e08542cde38f79d4
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 104 +++++++++++++++++++++++++
>  1 file changed, 104 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index fcd815d..f9f68ea 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -2237,6 +2237,106 @@ static int i40e_set_channels(struct net_device *dev,
>  		return -EINVAL;
>  }
>  
> +#define I40E_HLUT_ARRAY_SIZE ((I40E_PFQF_HLUT_MAX_INDEX + 1) * 4)
> +#define I40E_HKEY_ARRAY_SIZE ((I40E_PFQF_HKEY_MAX_INDEX * 1) * 4)
> +/**
> + * i40e_get_rxfh_key_size - get the RSS hash key size
> + * @netdev: network interface device structure
> + *
> + * Returns the table size.
> + **/
> +static u32 i40e_get_rxfh_key_size(struct net_device *netdev)
> +{
> +	return I40E_HKEY_ARRAY_SIZE;
> +}
> +
> +/**
> + * i40e_get_rxfh_indir_size - get the rx flow hash indirection table size
> + * @netdev: network interface device structure
> + *
> + * Returns the table size.
> + **/
> +static u32 i40e_get_rxfh_indir_size(struct net_device *netdev)
> +{
> +	return I40E_HLUT_ARRAY_SIZE;
> +}
> +
> +/**
> + * i40e_get_rxfh - get the rx flow hash indirection table
> + * @netdev: network interface device structure
> + * @indir: indirection table
> + * @key: hash key
> + *
> + * Reads the indirection table directly from the hardware. Always returns 0.
> + **/
> +static int i40e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_pf *pf = vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	u32 reg_val;
> +	int i, j;
> +
> +	for (i = 0, j = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++) {
> +		reg_val = rd32(hw, I40E_PFQF_HLUT(i));
> +		indir[j++] = reg_val & 0xff;
> +		indir[j++] = (reg_val >> 8) & 0xff;
> +		indir[j++] = (reg_val >> 16) & 0xff;
> +		indir[j++] = (reg_val >> 24) & 0xff;
> +	}
> +	if (key) {
> +		for (i = 0, j = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++) {
> +			reg_val = rd32(hw, I40E_PFQF_HKEY(i));
> +			key[j++] = (u8)(reg_val & 0xff);
> +			key[j++] = (u8)((reg_val >> 8) & 0xff);
> +			key[j++] = (u8)((reg_val >> 16) & 0xff);
> +			key[j++] = (u8)((reg_val >> 24) & 0xff);

Nit:

	put_unaligned_le32(reg_val, key + i * 4);

> +		}
> +	}
> +	return 0;
> +}
> +
> +/**
> + * i40e_set_rxfh - set the rx flow hash indirection table
> + * @netdev: network interface device structure
> + * @indir: indirection table
> + * @key: hash key
> + *
> + * Returns -EINVAL if the table specifies an inavlid queue id, otherwise
> + * returns 0 after programming the table.
> + **/
> +static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
> +			 const u8 *key)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_pf *pf = vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	u32 reg_val;
> +	int i, j;
> +
> +	if (indir) {
> +		for (i = 0, j = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++) {
> +			reg_val = indir[j++];

Shouldn't you check the indir[X] values are in correct range ?

( seems to be between 0 and [pf->rss_size_max - 1] )

> +			reg_val |= indir[j++] << 8;
> +			reg_val |= indir[j++] << 16;
> +			reg_val |= indir[j++] << 24;
> +			wr32(hw, I40E_PFQF_HLUT(i), reg_val);
> +		}
> +	}
> +	if (key) {
> +		for (i = 0, j = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++) {
> +			reg_val = key[j++];
> +			reg_val |= key[j++] << 8;
> +			reg_val |= key[j++] << 16;
> +			reg_val |= key[j++] << 24;

Nit:
		reg_val = get_unaligned_le32(key + i * 4);

> +			wr32(hw, I40E_PFQF_HKEY(i), reg_val);
> +		}
> +	}
