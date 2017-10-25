From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next v3 06/10] bnxt: Add devlink support for config
 get/set
Date: Wed, 25 Oct 2017 05:55:58 +0000
Message-ID: <AM0PR0502MB3683860B5E15C71A00435499BF440@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
 <1508875962-39233-7-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0061.outbound.protection.outlook.com ([104.47.1.61]:10793
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750972AbdJYF4B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 01:56:01 -0400
In-Reply-To: <1508875962-39233-7-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int bnxt_nvm_read(struct bnxt *bp, int nvm_param, int idx,
> +			 void *buf, int size)
> +{
> +	struct hwrm_nvm_get_variable_input req =3D {0};
> +	dma_addr_t dest_data_dma_addr;
> +	void *dest_data_addr =3D NULL;
> +	int bytesize;
> +	int rc;
> +
> +	bytesize =3D (size + 7) / BITS_PER_BYTE;
roundup?

..

+static int bnxt_nvm_write(struct bnxt *bp, int nvm_param, int idx,
> +			  const void *buf, int size)
> +{
> +	struct hwrm_nvm_set_variable_input req =3D {0};
> +	dma_addr_t src_data_dma_addr;
> +	void *src_data_addr =3D NULL;
> +	int bytesize;
> +	int rc;
> +
> +	bytesize =3D (size + 7) / BITS_PER_BYTE;
Likewise

> +
> +	src_data_addr =3D dma_alloc_coherent(&bp->pdev->dev, bytesize,
> +					   &src_data_dma_addr,
> GFP_KERNEL);
> +	if (!src_data_addr) {
> +		netdev_err(bp->dev, "dma_alloc_coherent failure\n");

Won't you see an oom? Why do you need the print?

> +static int bnxt_dl_perm_config_set(struct devlink *devlink,
> +				   enum devlink_perm_config_param param,
> +				   u8 type, void *value, u8 *restart_reqd)
> +{
> +	struct bnxt *bp =3D bnxt_get_bp_from_dl(devlink);
> +	struct bnxt_drv_cfgparam *entry;
> +	int idx =3D 0;
> +	int ret =3D 0;
> +	u32 bytesize;
> +	u32 val32;
> +	u16 val16;
> +	u8 val8;
> +	int i;
> +
> +	*restart_reqd =3D 0;
> +
> +	/* Find parameter in table */
> +	for (i =3D 0; i < BNXT_NUM_DRV_CFGPARAM; i++) {
> +		if (param =3D=3D bnxt_drv_cfgparam_list[i].param) {
> +			entry =3D &bnxt_drv_cfgparam_list[i];
> +			break;
> +		}
> +	}
> +
> +	/* Not found */
> +	if (i =3D=3D BNXT_NUM_DRV_CFGPARAM)
> +		return -EINVAL;
> +
Looks cleaner to check whether entry is set instead
...

> +	bytesize =3D (entry->bitlength + 7) / BITS_PER_BYTE;

Roundup?

...

> +		if (bytesize =3D=3D 1) {
> +			val8 =3D val32;

Don't you need explicit castings for these kind of assignments
to prevent warnings?

> +			ret =3D bnxt_nvm_write(bp, entry->nvm_param, idx,
> &val8,
> +					     entry->bitlength);
> +		} else if (bytesize =3D=3D 2) {
> +			val16 =3D val32;
> +			ret =3D bnxt_nvm_write(bp, entry->nvm_param, idx,
> &val16,
> +					     entry->bitlength);
> +		} else {
> +			ret =3D bnxt_nvm_write(bp, entry->nvm_param, idx,
> &val32,
> +					     entry->bitlength);
> +		}
> +	}
> +
> +	/* Restart required for all nvm parameter writes */
> +	*restart_reqd =3D 1;
> +
> +	return ret;
> +}
> +
> +static int bnxt_dl_perm_config_get(struct devlink *devlink,
> +				   enum devlink_perm_config_param param,
> +				   u8 type, void *value)
> +{
Same comments as for the setter
...

> -	if (!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
> -		return 0;
> -
> -	if (bp->hwrm_spec_code < 0x10800) {
> +	if ((!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV)) ||
> +	    bp->hwrm_spec_code < 0x10800) {
> +		/* eswitch switchdev mode not supported */
> +		bnxt_dl_ops.eswitch_mode_set =3D NULL;
> +		bnxt_dl_ops.eswitch_mode_get =3D NULL;

Why would you need to tie this interface to the presence of SRIOV in PCIe?
Also, Assuming the ability to disable sriov in #2 would cause this capabili=
ty
not to be exposed after reboot, isn't this a one-way ticket?
