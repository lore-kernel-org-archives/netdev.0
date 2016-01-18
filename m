From: "Yankejian (Hackim Yim)" <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 next-next] net: hns: enet specifies a reference to dsaf
Date: Mon, 18 Jan 2016 19:35:38 +0800
Message-ID: <569CCE0A.5010005@huawei.com>
References: <1452654880-28980-1-git-send-email-yankejian@huawei.com>
 <56970F48.9060504@huawei.com> <1452764635.2521.28.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Yisen Zhuang <Yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
	<fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1452764635.2521.28.camel-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/1/14 17:43, Andy Shevchenko wrote:
> On Thu, 2016-01-14 at 11:00 +0800, Yisen Zhuang wrote:
>> =E5=9C=A8 2016/1/13 11:14, Kejian Yan =E5=86=99=E9=81=93:
>>> This patch replace the assoication between dsaf and enet from
>>> string
>>> matching to object reference. It requires the DTS to be updated
>>> within
>>> BIOS. Thanks god it can be done for all released boards.
>>>
>> Hi kejian,
>>
>> This patch is fine to me.
> There are few thing below.
>
>> =20
>>> --- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
>>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
>>> @@ -847,6 +847,7 @@ static struct hnae_ae_ops hns_dsaf_ops =3D {
>>>  int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
>>>  {
>>>  	struct hnae_ae_dev *ae_dev =3D &dsaf_dev->ae_dev;
>>> +	static atomic_t id =3D ATOMIC_INIT(-1);
>>> =20
>>>  	switch (dsaf_dev->dsaf_ver) {
>>>  	case AE_VERSION_1:
>>> @@ -858,6 +859,9 @@ int hns_dsaf_ae_init(struct dsaf_device
>>> *dsaf_dev)
>>>  	default:
>>>  		break;
>>>  	}
>>> +
>>> +	snprintf(ae_dev->name, AE_NAME_SIZE, "%s%d",
>>> DSAF_DEVICE_NAME,
>>> +		 (int)atomic_inc_return(&id));
> If you bind/unbind device enough times you may get an overflow and en=
d
> up with name of existing device (if you have 1+ of them in the system=
).
>
> To avoid such situation better to use IDA/IDR framework.

thanks

Best Regards
Kejian Yan

>>> =20
>>> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>>> @@ -1802,7 +1802,7 @@ static int hns_nic_try_get_ae(struct
>>> net_device *ndev)
>>>  	int ret;
>>> =20
>>>  	h =3D hnae_get_handle(&priv->netdev->dev,
>>> -			    priv->ae_name, priv->port_id, NULL);
>>> +			    priv->ae_node, priv->port_id, NULL);
>>>  	if (IS_ERR_OR_NULL(h)) {
>>>  		ret =3D PTR_ERR(h);
>>>  		dev_dbg(priv->dev, "has not handle, register
>>> notifier!\n");
>>> @@ -1880,9 +1880,12 @@ static int hns_nic_dev_probe(struct
>>> platform_device *pdev)
>>>  	else
>>>  		priv->enet_ver =3D AE_VERSION_2;
>>> =20
>>> -	ret =3D of_property_read_string(node, "ae-name", &priv-
>>>> ae_name);
>>> -	if (ret)
>>> -		goto out_read_string_fail;
> (1)
>
>>> +	priv->ae_node =3D (void *)of_parse_phandle(node, "ae-
>>> handle", 0);
>>> +	if (IS_ERR_OR_NULL(priv->ae_node)) {
>>> +		ret =3D PTR_ERR(priv->ae_node);
>>> +		dev_err(dev, "not find ae-handle\n");
>>> +		goto out_read_handle_fai;
> (2)
>
>>> +	}
>>> =20
>>>  	ret =3D of_property_read_u32(node, "port-id", &priv-
>>>> port_id);
>>>  	if (ret)
>>> @@ -1945,6 +1948,8 @@ static int hns_nic_dev_probe(struct
>>> platform_device *pdev)
>>> =20
>>>  out_notify_fail:
>>>  	(void)cancel_work_sync(&priv->service_task);
>>> +out_read_handle_fai:
>>> +
> Redundant line
>
>>>  out_read_string_fail:
> Leftover? (see (1) and (2) )

thanks.

Best Regards
Kejian Yan


--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
