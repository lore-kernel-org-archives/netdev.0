From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: fix DT port device name
Date: Sun, 07 Jul 2013 23:58:49 +0200
Message-ID: <51D9E499.5000801@gmail.com>
References: <1373229231-8838-1-git-send-email-sebastian.hesselbarth@gmail.com> <20130707234341.0000721b@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Jonas Gorski <jogo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130707234341.0000721b@unknown>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/07/2013 11:43 PM, Jonas Gorski wrote:
> On Sun,  7 Jul 2013 22:33:51 +0200
> Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>  wrote:
>
>> Device tree support added to Marvell MV643xx ethernet driver registers
>> port devices from port device nodes found on the corresponding controller
>> node. The current port device name will cause the second controller to
>> fail on registration because of two identical device names. This fixes
>> the issue by taking the device node's name also as port device name.
>>
>> Signed-off-by: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
>> Reported-by: Jonas Gorski<jogo@openwrt.org>
>> ---
>> Cc: Lennert Buytenhek<buytenh@wantstofly.org>
>> Cc: Jonas Gorski<jogo@openwrt.org>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>   drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
>> index 6495bea..1f3a03d 100644
>> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
>> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
>> @@ -2521,7 +2521,7 @@ static int mv643xx_eth_shared_of_add_port(struct platform_device *pdev,
>>   		of_property_read_u32(pnp, "duplex",&ppd.duplex);
>>   	}
>>
>> -	ppdev = platform_device_alloc(MV643XX_ETH_NAME, ppd.port_number);
>> +	ppdev = platform_device_alloc(pnp->name, ppd.port_number);
>>   	if (!ppdev)
>>   		return -ENOMEM;
>>   	ppdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
>
> This breaks ethernet completely, as there is no platform driver
> registered for pnp->name ("ethernetX-port"), only for MV643XX_ETH_NAME.

Jonas,

I asked you to test the above earlier today. You said this would fix
the issue. I have no Kirkwood board with two ethernet's available, so
I really needed on your help here.

Please prepare a patch yourself, that fixes the issue.

Sebastian

> Also since I didn't see a patch for it and no mentioning of it:
>
> There's still one further issue from having two ethernet-ports with
> port_number 0, it causes a device leak:
>
> static struct platform_device *port_platdev[3];
>
> mv643xx_eth_shared_of_add_port()
> {
> 	...
> 	port_platdev[ppd.port_number] = ppdev;
> 	...
> }
>
> The second port at 0 will overwrite the first and thus will never be
> deleted in
>
> mv643xx_eth_shared_of_remove()
> {
> 	...
> 	for (n = 0; n<  3; n++) {
> 		platform_device_del(port_platdev[n]);
> 		port_platdev[n] = NULL;
> 	}
> }
>
> I doubt a insmod-rmmod-insmod will go well in that case ;-)
>
>
> Regards
> Jonas
