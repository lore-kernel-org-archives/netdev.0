From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v4 5/7] vmxnet3: add support for get_coalesce,
 set_coalesce ethtool operations
Date: Tue, 14 Jun 2016 20:38:06 +0100
Message-ID: <1465933086.3529.247.camel@decadent.org.uk>
References: <1465930348-92164-1-git-send-email-skhare@vmware.com>
	 <1465930348-92164-6-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jujr15nM3NqlqcYhYfwd"
Cc: Keyong Sun <sunk@vmware.com>, Manoj Tammali <tammalim@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52346 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751801AbcFNTiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:38:14 -0400
In-Reply-To: <1465930348-92164-6-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jujr15nM3NqlqcYhYfwd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-06-14 at 11:52 -0700, Shrikrishna Khare wrote:
> Signed-off-by: Keyong Sun <sunk@vmware.com>
> Signed-off-by: Manoj Tammali <tammalim@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> v1-v2: v1 patch used special values of rx-usecs to differentiate between
> coalescing modes. v2 uses relevant fields in struct ethtool_coalesce
> to choose modes. Also, a new command VMXNET3_CMD_GET_COALESCE is
> introduced which allows driver to query the device for default coalescing
> configuration.
>=20
> v3-v4: address Ben's review comments: remove unnecessary memset from
> vmxnet3_get_coalesce.
>=20
> ---
> =C2=A0drivers/net/vmxnet3/vmxnet3_defs.h=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A033 ++++++-
> =C2=A0drivers/net/vmxnet3/vmxnet3_drv.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A054 ++++++++++++
> =C2=A0drivers/net/vmxnet3/vmxnet3_ethtool.c | 158 +++++++++++++++++++++++=
+++++++++++
> =C2=A0drivers/net/vmxnet3/vmxnet3_int.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A09 ++
> =C2=A04 files changed, 253 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmx=
net3_defs.h
> index f3b31c2..274e145 100644
> --- a/drivers/net/vmxnet3/vmxnet3_defs.h
> +++ b/drivers/net/vmxnet3/vmxnet3_defs.h
> @@ -80,6 +80,7 @@ enum {
> =C2=A0	VMXNET3_CMD_LOAD_PLUGIN,
> =C2=A0	VMXNET3_CMD_RESERVED2,
> =C2=A0	VMXNET3_CMD_RESERVED3,
> +	VMXNET3_CMD_SET_COALESCE,
> =C2=A0
> =C2=A0	VMXNET3_CMD_FIRST_GET =3D 0xF00D0000,
> =C2=A0	VMXNET3_CMD_GET_QUEUE_STATUS =3D VMXNET3_CMD_FIRST_GET,
> @@ -92,7 +93,8 @@ enum {
> =C2=A0	VMXNET3_CMD_GET_DEV_EXTRA_INFO,
> =C2=A0	VMXNET3_CMD_GET_CONF_INTR,
> =C2=A0	VMXNET3_CMD_GET_RESERVED1,
> -	VMXNET3_CMD_GET_TXDATA_DESC_SIZE
> +	VMXNET3_CMD_GET_TXDATA_DESC_SIZE,
> +	VMXNET3_CMD_GET_COALESCE,
> =C2=A0};
> =C2=A0
> =C2=A0/*
> @@ -637,6 +639,35 @@ struct Vmxnet3_SetPolling {
> =C2=A0	u8					enablePolling;
> =C2=A0};
> =C2=A0
> +#define VMXNET3_COAL_STATIC_MAX_DEPTH		128
> +#define VMXNET3_COAL_RBC_MIN_RATE		100
> +#define VMXNET3_COAL_RBC_MAX_RATE		100000
> +
> +enum Vmxnet3_CoalesceMode {
> +	VMXNET3_COALESCE_DISABLED=C2=A0=C2=A0=C2=A0=3D 0,
> +	VMXNET3_COALESCE_ADAPT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D 1,
> +	VMXNET3_COALESCE_STATIC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D 2,
> +	VMXNET3_COALESCE_RBC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D=
 3
> +};
> +
> +struct Vmxnet3_CoalesceRbc {
> +	u32					rbc_rate;
> +};
> +
> +struct Vmxnet3_CoalesceStatic {
> +	u32					tx_depth;
> +	u32					tx_comp_depth;
> +	u32					rx_depth;
> +};
> +
> +struct Vmxnet3_CoalesceScheme {
> +	enum Vmxnet3_CoalesceMode		coalMode;
> +	union {
> +		struct Vmxnet3_CoalesceRbc	coalRbc;
> +		struct Vmxnet3_CoalesceStatic	coalStatic;
> +	} coalPara;
> +};
> +
> =C2=A0/* If the command data <=3D 16 bytes, use the shared memory directl=
y.
> =C2=A0 * otherwise, use variable length configuration descriptor.
> =C2=A0 */
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxn=
et3_drv.c
> index 6449d2e..d0bcc1d9 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -2491,6 +2491,32 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter=
 *adapter)
> =C2=A0	/* the rest are already zeroed */
> =C2=A0}
> =C2=A0
> +static void
> +vmxnet3_init_coalesce(struct vmxnet3_adapter *adapter)
> +{
> +	struct Vmxnet3_DriverShared *shared =3D adapter->shared;
> +	union Vmxnet3_CmdInfo *cmdInfo =3D &shared->cu.cmdInfo;
> +	unsigned long flags;
> +
> +	if (!VMXNET3_VERSION_GE_3(adapter))
> +		return;
> +
> +	spin_lock_irqsave(&adapter->cmd_lock, flags);
> +	cmdInfo->varConf.confVer =3D 1;
> +	cmdInfo->varConf.confLen =3D
> +		cpu_to_le32(sizeof(*adapter->coal_conf));
> +	cmdInfo->varConf.confPA=C2=A0=C2=A0=3D cpu_to_le64(adapter->coal_conf_p=
a);
> +
> +	if (adapter->default_coal_mode) {
> +		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0VMXNET3_CMD_GET_COALESCE);
> +	} else {
> +		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0VMXNET3_CMD_SET_COALESCE);
> +	}
> +
> +	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
> +}
> =C2=A0
> =C2=A0int
> =C2=A0vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
> @@ -2540,6 +2566,8 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapte=
r)
> =C2=A0		goto activate_err;
> =C2=A0	}
> =C2=A0
> +	vmxnet3_init_coalesce(adapter);
> +
> =C2=A0	for (i =3D 0; i < adapter->num_rx_queues; i++) {
> =C2=A0		VMXNET3_WRITE_BAR0_REG(adapter,
> =C2=A0				VMXNET3_REG_RXPROD + i * VMXNET3_REG_ALIGN,
> @@ -3345,6 +3373,22 @@ vmxnet3_probe_device(struct pci_dev *pdev,
> =C2=A0		goto err_ver;
> =C2=A0	}
> =C2=A0
> +	if (VMXNET3_VERSION_GE_3(adapter)) {
> +		adapter->coal_conf =3D
> +			dma_alloc_coherent(&adapter->pdev->dev,
> +					=C2=A0=C2=A0=C2=A0sizeof(struct Vmxnet3_CoalesceScheme)
> +					=C2=A0=C2=A0=C2=A0,
> +					=C2=A0=C2=A0=C2=A0&adapter->coal_conf_pa,
> +					=C2=A0=C2=A0=C2=A0GFP_KERNEL);
> +		if (!adapter->coal_conf) {
> +			err =3D -ENOMEM;
> +			goto err_ver;
> +		}
> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> +		adapter->coal_conf->coalMode =3D VMXNET3_COALESCE_DISABLED;
> +		adapter->default_coal_mode =3D true;
> +	}
> +
> =C2=A0	SET_NETDEV_DEV(netdev, &pdev->dev);
> =C2=A0	vmxnet3_declare_features(adapter, dma64);
> =C2=A0
> @@ -3407,6 +3451,11 @@ vmxnet3_probe_device(struct pci_dev *pdev,
> =C2=A0	return 0;
> =C2=A0
> =C2=A0err_register:
> +	if (VMXNET3_VERSION_GE_3(adapter)) {
> +		dma_free_coherent(&adapter->pdev->dev,
> +				=C2=A0=C2=A0sizeof(struct Vmxnet3_CoalesceScheme),
> +				=C2=A0=C2=A0adapter->coal_conf, adapter->coal_conf_pa);
> +	}
> =C2=A0	vmxnet3_free_intr_resources(adapter);
> =C2=A0err_ver:
> =C2=A0	vmxnet3_free_pci_resources(adapter);
> @@ -3457,6 +3506,11 @@ vmxnet3_remove_device(struct pci_dev *pdev)
> =C2=A0
> =C2=A0	vmxnet3_free_intr_resources(adapter);
> =C2=A0	vmxnet3_free_pci_resources(adapter);
> +	if (VMXNET3_VERSION_GE_3(adapter)) {
> +		dma_free_coherent(&adapter->pdev->dev,
> +				=C2=A0=C2=A0sizeof(struct Vmxnet3_CoalesceScheme),
> +				=C2=A0=C2=A0adapter->coal_conf, adapter->coal_conf_pa);
> +	}
> =C2=A0#ifdef VMXNET3_RSS
> =C2=A0	dma_free_coherent(&adapter->pdev->dev, sizeof(struct UPT1_RSSConf)=
,
> =C2=A0			=C2=A0=C2=A0adapter->rss_conf, adapter->rss_conf_pa);
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/=
vmxnet3_ethtool.c
> index 38f7c79..aabc6ef 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -725,6 +725,162 @@ vmxnet3_set_rss(struct net_device *netdev, const u3=
2 *p, const u8 *key,
> =C2=A0}
> =C2=A0#endif
> =C2=A0
> +static int
> +vmxnet3_get_coalesce(struct net_device *netdev, struct ethtool_coalesce =
*ec)
> +{
> +	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
> +
> +	if (!VMXNET3_VERSION_GE_3(adapter))
> +		return -EOPNOTSUPP;
> +
> +	switch (adapter->coal_conf->coalMode) {
> +	case VMXNET3_COALESCE_DISABLED:
> +		/* struct ethtool_coalesce is already initialized to 0 */
> +		break;
> +	case VMXNET3_COALESCE_ADAPT:
> +		ec->use_adaptive_rx_coalesce =3D true;
> +		break;
> +	case VMXNET3_COALESCE_STATIC:
> +		ec->tx_max_coalesced_frames =3D
> +			adapter->coal_conf->coalPara.coalStatic.tx_comp_depth;
> +		ec->rx_max_coalesced_frames =3D
> +			adapter->coal_conf->coalPara.coalStatic.rx_depth;
> +		break;
> +	case VMXNET3_COALESCE_RBC: {
> +		u32 rbc_rate;
> +
> +		rbc_rate =3D adapter->coal_conf->coalPara.coalRbc.rbc_rate;
> +		ec->rx_coalesce_usecs =3D VMXNET3_COAL_RBC_USECS(rbc_rate);
> +	}
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}
> +
> +static int
> +vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_coalesce =
*ec)
> +{
> +	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
> +	struct Vmxnet3_DriverShared *shared =3D adapter->shared;
> +	union Vmxnet3_CmdInfo *cmdInfo =3D &shared->cu.cmdInfo;
> +	unsigned long flags;
> +
> +	if (!VMXNET3_VERSION_GE_3(adapter))
> +		return -EOPNOTSUPP;
> +
> +	if (ec->rx_coalesce_usecs_irq ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_max_coalesced_frames_irq ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_coalesce_usecs ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_coalesce_usecs_irq ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_max_coalesced_frames_irq ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->stats_block_coalesce_usecs ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->use_adaptive_tx_coalesce ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->pkt_rate_low ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_coalesce_usecs_low ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_max_coalesced_frames_low ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_coalesce_usecs_low ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_max_coalesced_frames_low ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->pkt_rate_high ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_coalesce_usecs_high ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_max_coalesced_frames_high ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_coalesce_usecs_high ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_max_coalesced_frames_high ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0ec->rate_sample_interval) {
> +		return -EINVAL;
> +	}
> +
> +	if ((ec->rx_coalesce_usecs =3D=3D 0) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(ec->use_adaptive_rx_coalesce =3D=3D 0) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(ec->tx_max_coalesced_frames =3D=3D 0) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(ec->rx_max_coalesced_frames =3D=3D 0)) {
> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> +		adapter->coal_conf->coalMode =3D VMXNET3_COALESCE_DISABLED;
> +		goto done;
> +	}
> +
> +	if (ec->rx_coalesce_usecs !=3D 0) {
> +		u32 rbc_rate;
> +
> +		if ((ec->use_adaptive_rx_coalesce !=3D 0) ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0(ec->tx_max_coalesced_frames !=3D 0) ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0(ec->rx_max_coalesced_frames !=3D 0)) {
> +			return -EINVAL;
> +		}
> +
> +		rbc_rate =3D VMXNET3_COAL_RBC_RATE(ec->rx_coalesce_usecs);
> +		if (rbc_rate < VMXNET3_COAL_RBC_MIN_RATE ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0rbc_rate > VMXNET3_COAL_RBC_MAX_RATE) {
> +			return -EINVAL;
> +		}
> +
> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> +		adapter->coal_conf->coalMode =3D VMXNET3_COALESCE_RBC;
> +		adapter->coal_conf->coalPara.coalRbc.rbc_rate =3D rbc_rate;
> +		goto done;
> +	}
> +
> +	if (ec->use_adaptive_rx_coalesce !=3D 0) {
> +		if ((ec->rx_coalesce_usecs !=3D 0) ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0(ec->tx_max_coalesced_frames !=3D 0) ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0(ec->rx_max_coalesced_frames !=3D 0)) {
> +			return -EINVAL;
> +		}
> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> +		adapter->coal_conf->coalMode =3D VMXNET3_COALESCE_ADAPT;
> +		goto done;
> +	}
> +
> +	if ((ec->tx_max_coalesced_frames !=3D 0) ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0(ec->rx_max_coalesced_frames !=3D 0)) {
> +		if ((ec->rx_coalesce_usecs !=3D 0) ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0(ec->use_adaptive_rx_coalesce !=3D 0)) {
> +			return -EINVAL;
> +		}
> +
> +		if ((ec->tx_max_coalesced_frames >
> +		=C2=A0=C2=A0=C2=A0=C2=A0VMXNET3_COAL_STATIC_MAX_DEPTH) ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0(ec->rx_max_coalesced_frames >
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0VMXNET3_COAL_STATIC_MAX_DEPTH)) {
> +			return -EINVAL;
> +		}
> +
> +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> +		adapter->coal_conf->coalMode =3D VMXNET3_COALESCE_STATIC;
> +
> +		adapter->coal_conf->coalPara.coalStatic.tx_comp_depth =3D
> +			(ec->tx_max_coalesced_frames ?
> +			=C2=A0ec->tx_max_coalesced_frames :
> +			=C2=A0VMXNET3_COAL_STATIC_DEFAULT_DEPTH);
> +
> +		adapter->coal_conf->coalPara.coalStatic.rx_depth =3D
> +			(ec->rx_max_coalesced_frames ?
> +			=C2=A0ec->rx_max_coalesced_frames :
> +			=C2=A0VMXNET3_COAL_STATIC_DEFAULT_DEPTH);
> +
> +		adapter->coal_conf->coalPara.coalStatic.tx_depth =3D
> +			=C2=A0VMXNET3_COAL_STATIC_DEFAULT_DEPTH;
> +		goto done;
> +	}
> +
> +done:
> +	adapter->default_coal_mode =3D false;
> +	if (netif_running(netdev)) {
> +		spin_lock_irqsave(&adapter->cmd_lock, flags);
> +		cmdInfo->varConf.confVer =3D 1;
> +		cmdInfo->varConf.confLen =3D
> +			cpu_to_le32(sizeof(*adapter->coal_conf));
> +		cmdInfo->varConf.confPA=C2=A0=C2=A0=3D cpu_to_le64(adapter->coal_conf_=
pa);
> +		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0VMXNET3_CMD_SET_COALESCE);
> +		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
> +	}
> +
> +	return 0;
> +}
> +
> =C2=A0static const struct ethtool_ops vmxnet3_ethtool_ops =3D {
> =C2=A0	.get_settings=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D vmxnet3_get_s=
ettings,
> =C2=A0	.get_drvinfo=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D vmxnet3_=
get_drvinfo,
> @@ -733,6 +889,8 @@ static const struct ethtool_ops vmxnet3_ethtool_ops =
=3D {
> =C2=A0	.get_wol=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=3D vmxnet3_get_wol,
> =C2=A0	.set_wol=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=3D vmxnet3_set_wol,
> =C2=A0	.get_link=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=3D ethtool_op_get_link,
> +	.get_coalesce=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D vmxnet3_get_coales=
ce,
> +	.set_coalesce=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D vmxnet3_set_coales=
ce,
> =C2=A0	.get_strings=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=3D vmxnet3_=
get_strings,
> =C2=A0	.get_sset_count	=C2=A0=C2=A0=C2=A0=3D vmxnet3_get_sset_count,
> =C2=A0	.get_ethtool_stats =3D vmxnet3_get_ethtool_stats,
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxn=
et3_int.h
> index c46bf09..63df4f2 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -358,6 +358,7 @@ struct vmxnet3_adapter {
> =C2=A0	int		rx_buf_per_pkt;=C2=A0=C2=A0/* only apply to the 1st ring */
> =C2=A0	dma_addr_t			shared_pa;
> =C2=A0	dma_addr_t queue_desc_pa;
> +	dma_addr_t coal_conf_pa;
> =C2=A0
> =C2=A0	/* Wake-on-LAN */
> =C2=A0	u32=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0wol;
> @@ -384,6 +385,9 @@ struct vmxnet3_adapter {
> =C2=A0
> =C2=A0	int share_intr;
> =C2=A0
> +	struct Vmxnet3_CoalesceScheme *coal_conf;
> +	bool=C2=A0=C2=A0=C2=A0default_coal_mode;
> +
> =C2=A0	dma_addr_t adapter_pa;
> =C2=A0	dma_addr_t pm_conf_pa;
> =C2=A0	dma_addr_t rss_conf_pa;
> @@ -429,6 +433,11 @@ struct vmxnet3_adapter {
> =C2=A0	(rqID >=3D 2 * adapter->num_rx_queues &&		\
> =C2=A0	rqID < 3 * adapter->num_rx_queues)		\
> =C2=A0
> +#define VMXNET3_COAL_STATIC_DEFAULT_DEPTH	64
> +
> +#define VMXNET3_COAL_RBC_RATE(usecs) (1000000 / usecs)
> +#define VMXNET3_COAL_RBC_USECS(rbc_rate) (1000000 / rbc_rate)
> +
> =C2=A0int
> =C2=A0vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
> =C2=A0
--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- A=
lbert
Camus

--=-Jujr15nM3NqlqcYhYfwd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXYF0eAAoJEOe/yOyVhhEJMxoQALVe51LDyCgyqabIENL928R2
FwlQEF1IfqfZtScpyB0mwQdy4U70OFNAKto/+TsjdwvdRiyc7AKpzQa0if4PWRt6
B+jMs3yNX2WBZGSWnUkD8fJ0gZb6kLS+pGGZc/hPwCiEtl/GCrKdsypdOL2X62l3
TPY+iUcD2LKcDmXEB6gwWd49NXtu0MvFIXAMYmLBZMzHQPq95nBtRF5Pwcl3gLfu
z3cSpciHLZkMJYWFgwpo6LxiuPOszVXMog9dciIQAAwI6vhIV7Gp/mix1tQhtuyV
SiUZ+HyNX+3Fa8SGJGdZdrtYPLTNPAkRyOuTSk4Z8e/f51VeuWKD4ogsMyKMcnxr
/xRaIAciDvHedleAzjk6NuG6Fyrp/pTs13nnu14Appgc77QgcQJ2WHCErZ2JoPXh
93RT6M0OjdjbPuq/lRtKlBIK6395y6PPMzwATrVB0zr9F3JwOEW2c+zLIngtm+BU
YJmEQVWHx95bWUNqbzrSAFg6iTdvKPdPZAsaEuojrUP8lu0yFYNdNQaKnMANm2Jw
LjTwI7wZ9A1SDHeFS3kdDJVf2dM91vfLYtpWTo1q3s3u+wrxKdgeZBWq8Bg/UeLa
jAcIC3Moz+hIvu4j504Wbx8w87Wm2cMY0X6RydKnuG79uhhHO4lGNMEGYUhr4dan
f5DXQDK4flLJVNY3k2lA
=Ld3K
-----END PGP SIGNATURE-----

--=-Jujr15nM3NqlqcYhYfwd--
