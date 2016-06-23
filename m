From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net-next 10/19] net: hns: bugfix about pfc pause frame
 statistics
Date: Thu, 23 Jun 2016 13:42:58 +0800
Message-ID: <576B76E2.9040402@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1466481399-70080-11-git-send-email-Yisen.Zhuang@huawei.com>
 <1466505178.30123.201.camel@linux.intel.com> <5769ED55.3000408@huawei.com>
 <1466588498.30123.235.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andrew@lunn.ch>, <geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<davem@davemloft.net>, <salil.mehta@huawei.com>,
	<yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466588498.30123.235.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=E5=9C=A8 2016/6/22 17:41, Andy Shevchenko =E5=86=99=E9=81=93:
> On Wed, 2016-06-22 at 09:43 +0800, Yisen Zhuang wrote:
>>
>> =E5=9C=A8 2016/6/21 18:32, Andy Shevchenko =E5=86=99=E9=81=93:
>>> On Tue, 2016-06-21 at 11:56 +0800, Yisen Zhuang wrote:
>>>> From: Daode Huang <huangdaode@hisilicon.com>
>>>>
>>>> For SoC hip06, PFC pause handled in dsaf, while hip05 in XGMAC,
>>>> so change the statistics of pfc pause in dsaf and remove the old
>>>> pfc pause frame statistics.
>>>>
>>> =20
>>>
>>>> +static char *hns_dsaf_get_node_stats_strings(char *data, int
>>>> node,
>>>> +					     struct dsaf_device
>>>> *dsaf_dev)
>>>>  {
>>>>  	char *buff =3D data;
>>>> +	int i;
>>>> +	bool is_ver1 =3D AE_IS_VER1(dsaf_dev->dsaf_ver);
>>>> =20
>>>>  	snprintf(buff, ETH_GSTRING_LEN, "innod%d_pad_drop_pkts",
>>>> node);
>>>>  	buff =3D buff + ETH_GSTRING_LEN;
>>>> @@ -2502,6 +2530,18 @@ static char
>>>> *hns_dsaf_get_node_stats_strings(char *data, int node)
>>>>  	buff =3D buff + ETH_GSTRING_LEN;
>>>>  	snprintf(buff, ETH_GSTRING_LEN, "innod%d_stp_drop_pkts",
>>>> node);
>>>>  	buff =3D buff + ETH_GSTRING_LEN;
>>>> +	if ((node < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
>>>
>>> Redundant parens.
>>>
>>>> +		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
>>>> +			snprintf(buff, ETH_GSTRING_LEN,
>>>> +				 "inod%d_pfc_prio%d_pkts", node,
>>>> i);
>>>> +			buff =3D buff + ETH_GSTRING_LEN;
>>>
>>> buff +=3D ...
>>>
>>>> +		}
>>>> +		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
>>>> +			snprintf(buff, ETH_GSTRING_LEN,
>>>> +				 "onod%d_pfc_prio%d_pkts", node,
>>>> i);
>>>> +			buff =3D buff + ETH_GSTRING_LEN;
>>>
>>> Ditto.
>>>
>>>>  {
>>>>  	u64 *p =3D data;
>>>> +	int i;
>>>>  	struct dsaf_hw_stats *hw_stats =3D &ddev-
>>>>> hw_stats[node_num];
>>>> +	bool is_ver1 =3D AE_IS_VER1(ddev->dsaf_ver);
>>>> =20
>>>>  	p[0] =3D hw_stats->pad_drop;
>>>>  	p[1] =3D hw_stats->man_pkts;
>>>> @@ -2527,8 +2569,16 @@ static u64 *hns_dsaf_get_node_stats(struct
>>>> dsaf_device *ddev, u64 *data,
>>>>  	p[10] =3D hw_stats->local_addr_false;
>>>>  	p[11] =3D hw_stats->vlan_drop;
>>>>  	p[12] =3D hw_stats->stp_drop;
>>>> -	p[13] =3D hw_stats->tx_pkts;
>>>> +	if ((node_num < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
>>>> +		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
>>>> +			p[13 + i] =3D hw_stats->rx_pfc[i];
>>>> +			p[13 + i + DSAF_PRIO_NR] =3D hw_stats-
>>>>> tx_pfc[i];
>>>> +		}
>>>
>>> Two different approaches how to assign data. Above uses 2 for-loops=
,
>>> here you put everything to one.
>>
>> Above cann't be merged to 1 for-loop, because lenght of the string i=
s
>> unknowable.
>=20
> It doesn't matter since you are incrementing start position by
> constant.=20
>=20
> snprintf(buff, ETH_GSTRING_LEN, "inod%d_pfc_prio%d_pkts", node, i);
> snprintf(buff, ETH_GSTRING_LEN, "onod%d_pfc_prio%d_pkts", node, i);
>=20
> Same approach as below can be used
>=20
> snprintf(buff + 0 * ETH_GSTRING_LEN * DSAF_PRIO_NR, ETH_GSTRING_LEN, =
=2E..
> snprintf(buff + 1 * ETH_GSTRING_LEN * DSAF_PRIO_NR, ETH_GSTRING_LEN, =
=2E..
>=20
> Of course to make it less verbose you may add new definition(s) and/ =
or
> variable(s).
>=20
>>
>> And here we put everything to one to reduce codes.
>>
>=20
> I would suggest to use following pattern for such lines
> p[13 + i + 0 * DSAF_PRIO_NR] =3D hw_stats->rx_pfc[i];
> p[13 + i + 1 * DSAF_PRIO_NR] =3D hw_stats->tx_pfc[i];
>=20
> That's allow reader to see what are you doing here.
>=20
> P.S. This is for the future patches since current is already applied.

Hi Andy,

Many thanks for you suggestions. I will fix it with a new patch.

Thanks,

Yisen

>=20
