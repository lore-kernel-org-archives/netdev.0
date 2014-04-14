From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v2 4/4] drivers: net: Add APM X-Gene SoC ethernet driver
 support.
Date: Mon, 14 Apr 2014 15:05:20 +0100
Message-ID: <534BEB20.3080501@codethink.co.uk>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com> <1397271984-23405-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397271984-23405-5-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/14 04:06, Iyappan Subramanian wrote:
> This patch adds network driver for APM X-Gene SoC ethernet.
>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Ravi Patel <rapatel@apm.com>

[snip]

> +{
> +	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +	struct phy_device *phydev;
> +	unsigned char phy_id[MII_BUS_ID_SIZE+3];
> +	int ret = 0;
> +
> +	phydev = phy_find_first(pdata->mdio_bus);
> +	if (!phydev) {
> +		netdev_info(ndev, "no PHY found\n");
> +		ret = -1;
> +		goto out;
> +	}
> +
> +	/* attach the mac to the phy */
> +	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, pdata->mdio_bus->id,
> +		 pdata->phy_addr);
> +	phydev = phy_connect(ndev, phy_id,
> +			     &xgene_enet_mdio_link_change, pdata->phy_mode);
> +	if (IS_ERR(phydev)) {
> +		netdev_err(ndev, "Could not attach to PHY\n");
> +		ret = PTR_ERR(phydev);
> +		phydev = NULL;
> +		goto out;
> +	}
> +

You should be using of_phy_connect or similar so that the
necessary PHY<>OF data is properly initialised

> +	netdev_info(ndev, "phy_id=0x%08x phy_drv=\"%s\"",
> +		    phydev->phy_id, phydev->drv->name);
> +out:
> +	pdata->phy_link = 0;
> +	pdata->phy_speed = 0;
> +	pdata->phy_dev = phydev;
> +
> +	return ret;
> +}
> +


[snip]

> +struct xgene_enet_desc {
> +	u64 m0;
> +	u64 m1;
> +	u64 m2;
> +	u64 m3;
> +};
> +
> +struct xgene_enet_desc16 {
> +	u64 m0;
> +	u64 m1;
> +};
> +
> +static inline void xgene_enet_cpu_to_le64(struct xgene_enet_desc *desc,
> +					  int count)
> +{
> +#ifdef CONFIG_CPU_BIG_ENDIAN
> +	int i;
> +
> +	for (i = 0; i < count; i++)
> +		((u64 *)desc)[i] = cpu_to_le64(((u64 *)desc)[i]);
> +#endif
> +}
> +
> +static inline void xgene_enet_le64_to_cpu(struct xgene_enet_desc *desc,
> +					  int count)
> +{
> +#ifdef CONFIG_CPU_BIG_ENDIAN
> +	int i;
> +
> +	for (i = 0; i < count; i++)
> +		((u64 *)desc)[i] = le64_to_cpu(((u64 *)desc)[i]);
> +#endif
> +}
> +
> +static inline void xgene_enet_desc16_to_le64(struct xgene_enet_desc *desc)
> +{
> +#ifdef CONFIG_CPU_BIG_ENDIAN
> +	((u64 *)desc)[1] = cpu_to_le64(((u64 *)desc)[1]);
> +#endif
> +}
> +
> +static inline void xgene_enet_le64_to_desc16(struct xgene_enet_desc *desc)
> +{
> +#ifdef CONFIG_CPU_BIG_ENDIAN
> +	((u64 *)desc)[1] = le64_to_cpu(((u64 *)desc)[1]);
> +#endif
> +}

With this do you not risk confusing the hardware by swapping the
format of the descriptors?

Why not use xxx_to_cpu() and cpu_to_xxx() functions when reading or
writing the descriptors? It would also remove a lot of the #ifdef in
this code.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
