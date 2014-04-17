From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v2 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Wed, 16 Apr 2014 19:06:47 -0700
Message-ID: <CAKh23FmM6L4PeL+GOz=neQac4ZDj+_LmH5=zTLtVZxfUe9HQVw@mail.gmail.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
	<1397271984-23405-5-git-send-email-isubramanian@apm.com>
	<534BEB20.3080501@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <534BEB20.3080501-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Please find my response inline.

On Mon, Apr 14, 2014 at 7:05 AM, Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org> wrote:
> On 12/04/14 04:06, Iyappan Subramanian wrote:
>>
>> This patch adds network driver for APM X-Gene SoC ethernet.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
>
>
> [snip]
>
>
>> +{
>> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> +       struct phy_device *phydev;
>> +       unsigned char phy_id[MII_BUS_ID_SIZE+3];
>> +       int ret = 0;
>> +
>> +       phydev = phy_find_first(pdata->mdio_bus);
>> +       if (!phydev) {
>> +               netdev_info(ndev, "no PHY found\n");
>> +               ret = -1;
>> +               goto out;
>> +       }
>> +
>> +       /* attach the mac to the phy */
>> +       snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, pdata->mdio_bus->id,
>> +                pdata->phy_addr);
>> +       phydev = phy_connect(ndev, phy_id,
>> +                            &xgene_enet_mdio_link_change,
>> pdata->phy_mode);
>> +       if (IS_ERR(phydev)) {
>> +               netdev_err(ndev, "Could not attach to PHY\n");
>> +               ret = PTR_ERR(phydev);
>> +               phydev = NULL;
>> +               goto out;
>> +       }
>> +
>
>
> You should be using of_phy_connect or similar so that the
> necessary PHY<>OF data is properly initialised
>

I will use of_phy_connect function to connect to PHY.

>
>> +       netdev_info(ndev, "phy_id=0x%08x phy_drv=\"%s\"",
>> +                   phydev->phy_id, phydev->drv->name);
>> +out:
>> +       pdata->phy_link = 0;
>> +       pdata->phy_speed = 0;
>> +       pdata->phy_dev = phydev;
>> +
>> +       return ret;
>> +}
>> +
>
>
>
> [snip]
>
>
>> +struct xgene_enet_desc {
>> +       u64 m0;
>> +       u64 m1;
>> +       u64 m2;
>> +       u64 m3;
>> +};
>> +
>> +struct xgene_enet_desc16 {
>> +       u64 m0;
>> +       u64 m1;
>> +};
>> +
>> +static inline void xgene_enet_cpu_to_le64(struct xgene_enet_desc *desc,
>> +                                         int count)
>> +{
>> +#ifdef CONFIG_CPU_BIG_ENDIAN
>> +       int i;
>> +
>> +       for (i = 0; i < count; i++)
>> +               ((u64 *)desc)[i] = cpu_to_le64(((u64 *)desc)[i]);
>> +#endif
>> +}
>> +
>> +static inline void xgene_enet_le64_to_cpu(struct xgene_enet_desc *desc,
>> +                                         int count)
>> +{
>> +#ifdef CONFIG_CPU_BIG_ENDIAN
>> +       int i;
>> +
>> +       for (i = 0; i < count; i++)
>> +               ((u64 *)desc)[i] = le64_to_cpu(((u64 *)desc)[i]);
>> +#endif
>> +}
>> +
>> +static inline void xgene_enet_desc16_to_le64(struct xgene_enet_desc
>> *desc)
>> +{
>> +#ifdef CONFIG_CPU_BIG_ENDIAN
>> +       ((u64 *)desc)[1] = cpu_to_le64(((u64 *)desc)[1]);
>> +#endif
>> +}
>> +
>> +static inline void xgene_enet_le64_to_desc16(struct xgene_enet_desc
>> *desc)
>> +{
>> +#ifdef CONFIG_CPU_BIG_ENDIAN
>> +       ((u64 *)desc)[1] = le64_to_cpu(((u64 *)desc)[1]);
>> +#endif
>> +}
>
>
> With this do you not risk confusing the hardware by swapping the
> format of the descriptors?
>
> Why not use xxx_to_cpu() and cpu_to_xxx() functions when reading or
> writing the descriptors? It would also remove a lot of the #ifdef in
> this code.

Our hardware expects descriptor in the little endian format.  I will remove the
#ifdef.

>
> --
> Ben Dooks                               http://www.codethink.co.uk/
> Senior Engineer                         Codethink - Providing Genius
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
