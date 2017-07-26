From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 2/2] mlxsw: spectrum: Add support for access
 cable info via ethtool
Date: Wed, 26 Jul 2017 16:18:33 +0200
Message-ID: <20170726141833.GB12049@lunn.ch>
References: <20170614072740.1243-1-jiri@resnulli.us>
 <20170614072740.1243-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        arkadis@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40831 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752037AbdGZOSh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 10:18:37 -0400
Content-Disposition: inline
In-Reply-To: <20170614072740.1243-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int mlxsw_sp_get_module_info(struct net_device *netdev,
> +				    struct ethtool_modinfo *modinfo)
> +{
> +	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(netdev);
> +	u8 module_info[MLXSW_SP_EEPROM_MODULE_INFO_SIZE];
> +	u8 module_rev_id, module_id;
> +	unsigned int read_size;
> +	int err;
> +
> +	err = mlxsw_sp_query_module_eeprom(mlxsw_sp_port, 0,
> +					   MLXSW_SP_EEPROM_MODULE_INFO_SIZE,
> +					   module_info, &read_size);
> +	if (err)
> +		return err;
> +
> +	if (read_size < MLXSW_SP_EEPROM_MODULE_INFO_SIZE)
> +		return -EIO;
> +
> +	module_rev_id = module_info[MLXSW_SP_EEPROM_MODULE_INFO_REV_ID];
> +	module_id = module_info[MLXSW_SP_EEPROM_MODULE_INFO_ID];
> +
> +	switch (module_id) {
> +	case MLXSW_SP_EEPROM_MODULE_INFO_ID_QSFP:
> +		modinfo->type       = ETH_MODULE_SFF_8436;
> +		modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
> +		break;
> +	case MLXSW_SP_EEPROM_MODULE_INFO_ID_QSFP_PLUS:
> +	case MLXSW_SP_EEPROM_MODULE_INFO_ID_QSFP28:
> +		if (module_id  == MLXSW_SP_EEPROM_MODULE_INFO_ID_QSFP28 ||
> +		    module_rev_id >= MLXSW_SP_EEPROM_MODULE_INFO_REV_ID_8636) {
> +			modinfo->type       = ETH_MODULE_SFF_8636;
> +			modinfo->eeprom_len = ETH_MODULE_SFF_8636_LEN;
> +		} else {
> +			modinfo->type       = ETH_MODULE_SFF_8436;
> +			modinfo->eeprom_len = ETH_MODULE_SFF_8436_LEN;
> +		}
> +		break;
> +	case MLXSW_SP_EEPROM_MODULE_INFO_ID_SFP:
> +		modinfo->type       = ETH_MODULE_SFF_8472;
> +		modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
> +		break;
> +	default:
> +		return -EINVAL;

Hi Jiri

I remember seeing a few different implementations of this function in
various drivers. Could you pull it out into a helper, passing in the
array of bytes and mod info? bnxt, mlx4, mlx5, igb, ixgbe and sfc
could then use the helper.

      Andrew
