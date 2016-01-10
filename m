From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 7/8] mlxsw: Adding layer 2 multicast support
Date: Sun, 10 Jan 2016 15:23:11 +0100
Message-ID: <5692694F.8040902@cumulusnetworks.com>
References: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
 <1452431248-5411-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35548 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861AbcAJOXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 09:23:14 -0500
Received: by mail-wm0-f47.google.com with SMTP id f206so183874844wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 06:23:14 -0800 (PST)
In-Reply-To: <1452431248-5411-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2016 02:07 PM, Jiri Pirko wrote:
> From: Elad Raz <eladr@mellanox.com>
> 
> Add SWITCHDEV_OBJ_ID_PORT_MDB switchdev ops support. On first MDB insertion
> creates a new multicast group (MID) and add members port to the MID. Also
> add new MDB entry for the flooding-domain (fid-vid) and link the MDB entry
> to the newly constructed MC group.
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   1 +
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  13 ++
>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 176 +++++++++++++++++++++
>  3 files changed, 190 insertions(+)
> 
[snip]
> +static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
> +						const unsigned char *addr,
> +						u16 vid)
> +{
> +	struct mlxsw_sp_mid *mid;
> +	u16 mid_idx;
> +
> +	mid_idx = find_first_zero_bit(mlxsw_sp->br_mids.mapped,
> +				      MLXSW_SP_MID_MAX);
> +	if (mid_idx == MLXSW_SP_MID_MAX)
> +		return NULL;
> +
> +	mid = kzalloc(sizeof(*mid), GFP_ATOMIC);

Is GFP_ATOMIC allocation really required here ?
mlxsw_sp_port_smid_set() which is called after this uses GFP_KERNEL.

Cheers,
 Nik

> +	if (!mid)
> +		return NULL;
> +
> +	set_bit(mid_idx, mlxsw_sp->br_mids.mapped);
> +	ether_addr_copy(mid->addr, addr);
> +	mid->vid = vid;
> +	mid->mid = mid_idx;
> +	mid->ref_count = 0;
> +	list_add_tail(&mid->list, &mlxsw_sp->br_mids.list);
> +
> +	return mid;
> +}
> +
> +static int __mlxsw_sp_mc_dec_ref(struct mlxsw_sp *mlxsw_sp,
> +				 struct mlxsw_sp_mid *mid)
> +{
> +	if (--mid->ref_count == 0) {
> +		list_del(&mid->list);
> +		clear_bit(mid->mid, mlxsw_sp->br_mids.mapped);
> +		kfree(mid);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
> +				 const struct switchdev_obj_port_mdb *mdb,
> +				 struct switchdev_trans *trans)
> +{
> +	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
> +	struct net_device *dev = mlxsw_sp_port->dev;
> +	struct mlxsw_sp_mid *mid;
> +	u16 fid = mlxsw_sp_port_vid_to_fid_get(mlxsw_sp_port, mdb->vid);
> +	int err = 0;
> +
> +	if (switchdev_trans_ph_prepare(trans))
> +		return 0;
> +
> +	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, mdb->vid);
> +	if (!mid) {
> +		mid = __mlxsw_sp_mc_alloc(mlxsw_sp, mdb->addr, mdb->vid);
> +		if (!mid) {
> +			netdev_err(dev, "Unable to allocate MC group\n");
> +			return -ENOMEM;
> +		}
> +	}
> +	mid->ref_count++;
> +
> +	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true,
> +				     mid->ref_count == 1);
> +	if (err) {
> +		netdev_err(dev, "Unable to set SMID\n");
> +		goto err_out;
> +	}
> +
> +	if (mid->ref_count == 1) {
> +		err = mlxsw_sp_port_mdb_op(mlxsw_sp, mdb->addr, fid, mid->mid,
> +					   true);
> +		if (err) {
> +			netdev_err(dev, "Unable to set MC SFD\n");
> +			goto err_out;
> +		}
> +	}
> +
> +	return 0;
> +
> +err_out:
> +	__mlxsw_sp_mc_dec_ref(mlxsw_sp, mid);
> +	return err;
> +}
> +
>  static int mlxsw_sp_port_obj_add(struct net_device *dev,
>  				 const struct switchdev_obj *obj,
>  				 struct switchdev_trans *trans)
> @@ -704,6 +841,11 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
>  						   SWITCHDEV_OBJ_PORT_FDB(obj),
>  						   trans);
>  		break;
> +	case SWITCHDEV_OBJ_ID_PORT_MDB:
> +		err = mlxsw_sp_port_mdb_add(mlxsw_sp_port,
> +					    SWITCHDEV_OBJ_PORT_MDB(obj),
> +					    trans);
> +		break;
>  	default:
>  		err = -EOPNOTSUPP;
>  		break;
> @@ -817,6 +959,37 @@ mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
>  						   false, false);
>  }
>  
[snip]
