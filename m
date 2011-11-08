From: Li Yang-R58472 <r58472@freescale.com>
Subject: RE: [PATCH 7/7] gianfar: add support for wake-on-packet
Date: Tue, 8 Nov 2011 11:20:30 +0000
Message-ID: <3F607A5180246847A760FD34122A1E052BC9C7@039-SN1MPN1-004.039d.mgd.msft.net>
References: <1320410403-14639-1-git-send-email-chenhui.zhao@freescale.com>
 <4EB45515.6060405@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Fleming Andy-AFLEMING <afleming@freescale.com>
To: Wood Scott-B07421 <B07421@freescale.com>,
	Zhao Chenhui-B35336 <B35336@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:3026 "EHLO
	TX2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab1KHLUd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 06:20:33 -0500
In-Reply-To: <4EB45515.6060405@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org
>[mailto:linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org] On
>Behalf Of Scott Wood
>Sent: Saturday, November 05, 2011 5:12 AM
>To: Zhao Chenhui-B35336
>Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; Fleming Andy-
>AFLEMING
>Subject: Re: [PATCH 7/7] gianfar: add support for wake-on-packet
>
>On 11/04/2011 07:40 AM, Zhao Chenhui wrote:
>> diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>> index 2c6be03..543e36c 100644
>> --- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>> +++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
>> @@ -56,6 +56,9 @@ Properties:
>>      hardware.
>>    - fsl,magic-packet : If present, indicates that the hardware supports
>>      waking up via magic packet.
>> +  - fsl,wake-on-filer : If present, indicates that the hardware
>supports
>> +    waking up via arp request to local ip address or unicast packet to
>> +    local mac address.
>
>Is there any way to determine this at runtime via the device's registers?
>
>I think TSEC_ID2[TSEC_CFG] can be used.  The manual describes it
>awkwardly, but it looks like 0x20 is the bit for the filer.

That bit only defines the filer feature but not wakeup on it.  Another solution is to get the capability from the fsl_pmc driver, but will make the driver a lot more complex.

>
>> @@ -751,7 +764,6 @@ static int gfar_of_init(struct platform_device
>*ofdev, struct net_device **pdev)
>>  			FSL_GIANFAR_DEV_HAS_PADDING |
>>  			FSL_GIANFAR_DEV_HAS_CSUM |
>>  			FSL_GIANFAR_DEV_HAS_VLAN |
>> -			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
>>  			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
>>  			FSL_GIANFAR_DEV_HAS_TIMER;
>
>This is an unrelated change.  Are there any eTSECs that don't support
>magic packet?

I'm not sure.  But as we have the property for it in device tree, we use it.

>
>> +static int gfar_get_ip(struct net_device *dev)
>> +{
>> +	struct gfar_private *priv = netdev_priv(dev);
>> +	struct in_device *in_dev = (struct in_device *)dev->ip_ptr;
>> +	struct in_ifaddr *ifa;
>> +
>> +	if (in_dev != NULL) {
>> +		ifa = (struct in_ifaddr *)in_dev->ifa_list;
>> +		if (ifa != NULL) {
>> +			memcpy(priv->ip_addr, &ifa->ifa_address, 4);
>> +			return 0;
>> +		}
>> +	}
>> +	return -ENOENT;
>> +}
>
>Unnecessary cast, ifa_list is already struct in_ifaddr *.
>
>Better, use for_primary_ifa(), and document that you won't wake on ARP
>packets for secondary IP addresses.
>
>>  static int gfar_suspend(struct device *dev)
>>  {
>> @@ -1268,9 +1443,17 @@ static int gfar_suspend(struct device *dev)
>>  	struct gfar __iomem *regs = priv->gfargrp[0].regs;
>>  	unsigned long flags;
>>  	u32 tempval;
>> -
>>  	int magic_packet = priv->wol_en &&
>> -		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
>> +		(priv->wol_opts & GIANFAR_WOL_MAGIC);
>> +	int arp_packet = priv->wol_en &&
>> +		(priv->wol_opts & GIANFAR_WOL_ARP);
>> +
>> +	if (arp_packet) {
>> +		pmc_enable_wake(priv->ofdev, PM_SUSPEND_MEM, 1);
>> +		pmc_enable_lossless(1);
>> +		gfar_arp_suspend(ndev);
>> +		return 0;
>> +	}
>
>How do we know this isn't standby?

Maybe we can remove the PM state parameter from the API.

- Leo
