From: "lipeng (Y)" <lipeng321@huawei.com>
Subject: Re: [PATCH net-next 2/3] net: hns: support deferred probe when no
 mdio
Date: Fri, 21 Apr 2017 15:18:37 +0800
Message-ID: <22ba80ac-b83e-9017-0bd5-fe4e03edfd49@huawei.com>
References: <1492510354-11300-1-git-send-email-yankejian@huawei.com>
 <1492510354-11300-3-git-send-email-yankejian@huawei.com>
 <5c299e38-88f0-9801-5e7b-477e6fa0db18@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: Matthias Brugger <matthias.bgg@gmail.com>,
        Yankejian <yankejian@huawei.com>, <davem@davemloft.net>,
        <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <allenhuangsz10@gmail.com>, <huangdaode@hisilicon.com>,
        <hjat.hejun@huawei.com>, <zhangping5@huawei.com>,
        <qichengming@huawei.com>, <qumingguang@hisilicon.com>,
        <zhouhuiru@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:2072 "EHLO
        dggrg05-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1035937AbdDUHUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 03:20:48 -0400
In-Reply-To: <5c299e38-88f0-9801-5e7b-477e6fa0db18@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/4/20 19:13, Matthias Brugger wrote:
> On 18/04/17 12:12, Yankejian wrote:
>> From: lipeng <lipeng321@huawei.com>
>>
>> In the hip06 and hip07 SoCs, phy connect to mdio bus.The mdio
>> module is probed with module_init, and, as such,
>> is not guaranteed to probe before the HNS driver. So we need
>> to support deferred probe.
>>
>> We check for probe deferral in the mac init, so we not init DSAF
>> when there is no mdio, and free all resource, to later learn that
>> we need to defer the probe.
>>
>> Signed-off-by: lipeng <lipeng321@huawei.com>
>
> on which kernel version is this patch based?
> I checked against next-20170420 and it does not apply.
>

Will refloat this patchset on net.

thanks.
lipeng
>
>> ---
>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 34 
>> +++++++++++++++++++----
>>  1 file changed, 28 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c 
>> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
>> index bdd8cdd..284ebfe 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
>> @@ -735,6 +735,8 @@ static int hns_mac_init_ex(struct hns_mac_cb 
>> *mac_cb)
>>      rc = phy_device_register(phy);
>>      if (rc) {
>>          phy_device_free(phy);
>> +        dev_err(&mdio->dev, "registered phy fail at address %i\n",
>> +            addr);
>>          return -ENODEV;
>>      }
>>
>> @@ -745,7 +747,7 @@ static int hns_mac_init_ex(struct hns_mac_cb 
>> *mac_cb)
>>      return 0;
>>  }
>>
>> -static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
>> +static int hns_mac_register_phy(struct hns_mac_cb *mac_cb)
>>  {
>>      struct acpi_reference_args args;
>>      struct platform_device *pdev;
>> @@ -755,24 +757,39 @@ static void hns_mac_register_phy(struct 
>> hns_mac_cb *mac_cb)
>>
>>      /* Loop over the child nodes and register a phy_device for each 
>> one */
>>      if (!to_acpi_device_node(mac_cb->fw_port))
>> -        return;
>> +        return 0;
>
> Please return appropriate errno.
>
>>
>>      rc = acpi_node_get_property_reference(
>>              mac_cb->fw_port, "mdio-node", 0, &args);
>>      if (rc)
>> -        return;
>> +        return 0;
>
> Please return appropriate errno.
>
>>
>>      addr = hns_mac_phy_parse_addr(mac_cb->dev, mac_cb->fw_port);
>>      if (addr < 0)
>> -        return;
>> +        return 0;
>
> Shouldn't we just error out here by returning addr?
>
>>
>>      /* dev address in adev */
>>      pdev = 
>> hns_dsaf_find_platform_device(acpi_fwnode_handle(args.adev));
>> +    if (!pdev) {
>> +        dev_err(mac_cb->dev, "mac%d mdio pdev is NULL\n",
>> +            mac_cb->mac_id);
>> +        return 0;
>
> Please return appropriate errno.
>
> Regards,
> Matthias
>
>> +    }
>> +
>>      mii_bus = platform_get_drvdata(pdev);
>> +    if (!mii_bus) {
>> +        dev_err(mac_cb->dev,
>> +            "mac%d mdio is NULL, dsaf will probe again later\n",
>> +            mac_cb->mac_id);
>> +        return -EPROBE_DEFER;
>> +    }
>> +
>>      rc = hns_mac_register_phydev(mii_bus, mac_cb, addr);
>>      if (!rc)
>>          dev_dbg(mac_cb->dev, "mac%d register phy addr:%d\n",
>>              mac_cb->mac_id, addr);
>> +
>> +    return rc;
>>  }
>>
>>  #define MAC_MEDIA_TYPE_MAX_LEN        16
>> @@ -793,7 +810,7 @@ static void hns_mac_register_phy(struct 
>> hns_mac_cb *mac_cb)
>>   *@np:device node
>>   * return: 0 --success, negative --fail
>>   */
>> -static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
>> +static int hns_mac_get_info(struct hns_mac_cb *mac_cb)
>>  {
>>      struct device_node *np;
>>      struct regmap *syscon;
>> @@ -903,7 +920,10 @@ static int  hns_mac_get_info(struct hns_mac_cb 
>> *mac_cb)
>>              }
>>          }
>>      } else if (is_acpi_node(mac_cb->fw_port)) {
>> -        hns_mac_register_phy(mac_cb);
>> +        ret = hns_mac_register_phy(mac_cb);
>> +
>> +        if (ret)
>> +            return ret;
>>      } else {
>>          dev_err(mac_cb->dev, "mac%d cannot find phy node\n",
>>              mac_cb->mac_id);
>> @@ -1065,6 +1085,7 @@ int hns_mac_init(struct dsaf_device *dsaf_dev)
>>              dsaf_dev->mac_cb[port_id] = mac_cb;
>>          }
>>      }
>> +
>>      /* init mac_cb for all port */
>>      for (port_id = 0; port_id < max_port_num; port_id++) {
>>          mac_cb = dsaf_dev->mac_cb[port_id];
>> @@ -1074,6 +1095,7 @@ int hns_mac_init(struct dsaf_device *dsaf_dev)
>>          ret = hns_mac_get_cfg(dsaf_dev, mac_cb);
>>          if (ret)
>>              return ret;
>> +
>>          ret = hns_mac_init_ex(mac_cb);
>>          if (ret)
>>              return ret;
>>
>
> .
>
