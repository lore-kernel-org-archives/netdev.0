From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/8] net/mlx5: Fixed static checker warnings
Date: Wed, 01 Feb 2017 12:22:32 -0500 (EST)
Message-ID: <20170201.122232.468887635709421897.davem@davemloft.net>
References: <20170131205843.23235-1-saeedm@mellanox.com>
        <20170131205843.23235-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, matanb@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752791AbdBARWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:22:33 -0500
In-Reply-To: <20170131205843.23235-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 31 Jan 2017 22:58:36 +0200

> @@ -487,11 +487,11 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
>  			MLX5_SET(fte_match_set_lyr_2_4, headers_c, cvlan_tag, 1);
>  			MLX5_SET(fte_match_set_lyr_2_4, headers_v, cvlan_tag, 1);
>  
> -			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, mask->vlan_id);
> -			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, key->vlan_id);
> +			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, (u16)mask->vlan_id);
> +			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, (u16)key->vlan_id);
 ...
> @@ -67,10 +67,11 @@
>  
>  /* insert a value to a struct */
>  #define MLX5_SET(typ, p, fld, v) do { \
> +	typeof(v) _v = v; \
>  	BUILD_BUG_ON(__mlx5_st_sz_bits(typ) % 32);             \
>  	*((__be32 *)(p) + __mlx5_dw_off(typ, fld)) = \
>  	cpu_to_be32((be32_to_cpu(*((__be32 *)(p) + __mlx5_dw_off(typ, fld))) & \
> -		     (~__mlx5_dw_mask(typ, fld))) | (((v) & __mlx5_mask(typ, fld)) \
> +		     (~__mlx5_dw_mask(typ, fld))) | (((_v) & __mlx5_mask(typ, fld)) \
>  		     << __mlx5_dw_bit_off(typ, fld))); \
>  } while (0)

I have to agree with others that this is really crummy.

You're propagating values into a u32 field, which you are explicitly
performing 32-bit endianness conversions upon.

Just use "u32" for a local variable and get rid of all of these casts.
