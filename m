From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 7/7] nfp: allow application firmware to limit
 number of SR-IOV VFs
Date: Sun, 19 Feb 2017 16:00:59 +0000
Message-ID: <BL2PR07MB2306B36343A7E0493018AB158D5F0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170217220027.189992-1-jakub.kicinski@netronome.com>
 <20170217220027.189992-8-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>,
        "dinan.gunawardena@netronome.com" <dinan.gunawardena@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0045.outbound.protection.outlook.com ([104.47.38.45]:41282
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751888AbdBSQBC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 11:01:02 -0500
In-Reply-To: <20170217220027.189992-8-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void nfp_pcie_sriov_read_nfd_limit(struct nfp_pf *pf)
> +{
> +	int err;
> +
> +	pf->limit_vfs =3D nfp_rtsym_read_le(pf->cpp, "nfd_vf_cfg_max_vfs",
> &err);
> +	if (!err)
> +		return;
> +
> +	pf->limit_vfs =3D ~0;
> +	/* Allow any setting for backwards compatibility if symbol not found
> */
> +	if (err !=3D -ENOENT)
> +		nfp_warn(pf->cpp, "Warning: VF limit read failed: %d\n", err);
> +}
> +

If you're only going to use this under CONFIG_PCI_IOV,
perhaps put this underneath the ifdef as well?

>  static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
>  {
>  #ifdef CONFIG_PCI_IOV
>  	struct nfp_pf *pf =3D pci_get_drvdata(pdev);
>  	int err;
>=20
> +	if (num_vfs > pf->limit_vfs) {
> +		nfp_info(pf->cpp, "Firmware limits number of VFs to %u\n",
> +			 pf->limit_vfs);
> +		return -EINVAL;
> +	}
> +
>  	err =3D pci_enable_sriov(pdev, num_vfs);
>  	if (err) {
>  		dev_warn(&pdev->dev, "Failed to enable PCI sriov: %d\n",
> err);
> @@ -333,6 +354,8 @@ static int nfp_pci_probe(struct pci_dev *pdev,
>  	if (err)
>  		goto err_cpp_free;
>=20
> +	nfp_pcie_sriov_read_nfd_limit(pf);
> +
>  	err =3D nfp_net_pci_probe(pf);
>  	if (err)
>  		goto err_fw_unload;
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h
> b/drivers/net/ethernet/netronome/nfp/nfp_main.h
> index 6c40fa322da3..39105d0435e9 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
> @@ -59,6 +59,7 @@ struct nfp_eth_table;
>   * @tx_area:		Pointer to the CPP area for the TX queues
>   * @rx_area:		Pointer to the CPP area for the FL/RX queues
>   * @irq_entries:	Array of MSI-X entries for all ports
> + * @limit_vfs:		Number of VFs supported by firmware (~0 for PCI
> limit)
>   * @num_vfs:		Number of SR-IOV VFs enabled
>   * @fw_loaded:		Is the firmware loaded?
>   * @eth_tbl:		NSP ETH table
> @@ -77,6 +78,7 @@ struct nfp_pf {
>=20
>  	struct msix_entry *irq_entries;
>=20
> +	unsigned int limit_vfs;
>  	unsigned int num_vfs;
>=20
>  	bool fw_loaded;
> --
> 2.11.0
