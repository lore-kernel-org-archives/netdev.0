From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 07:56:18 -0700
Message-ID: <5627A792.3020201@roeck-us.net>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
 <5587575.y3COavlu1k@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5587575.y3COavlu1k@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 10/21/2015 07:39 AM, Arnd Bergmann wrote:
> On Wednesday 21 October 2015 07:29:33 Guenter Roeck wrote:
>> The Hisilicon network driver does not build for Sparc. Enabling
>> COMPILE_TEST for it causes Sparc allmodconfig/allyesconfig builds
>> to fail with
>>
>> drivers/net/ethernet/hisilicon/hns_mdio.c: In function 'hns_mdio_bus_name':
>> drivers/net/ethernet/hisilicon/hns_mdio.c:409:3: error:
>>                  implicit declaration of function 'of_translate_address'
>
> I see.
>
>> Fixes: 876133d3161d ("net: hisilicon: add OF dependency")
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
>>   drivers/net/ethernet/hisilicon/Kconfig | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
>> index f250dec488fd..413935085591 100644
>> --- a/drivers/net/ethernet/hisilicon/Kconfig
>> +++ b/drivers/net/ethernet/hisilicon/Kconfig
>> @@ -5,7 +5,7 @@
>>   config NET_VENDOR_HISILICON
>>          bool "Hisilicon devices"
>>          default y
>> -       depends on OF && (ARM || ARM64 || COMPILE_TEST)
>> +       depends on OF && (ARM || ARM64 || COMPILE_TEST) && !SPARC
>>          ---help---
>>            If you have a network (Ethernet) card belonging to this class, say Y.
>
> This looks fragile to me. Checking the declaration of of_translate_address,
> I see now that it actually depends on CONFIG_OF_ADDRESS, which is defined using
> "depends on !SPARC && HAS_IOMEM". This means we would get the same problem on
> SCORE, Tile, and UML.
>
> How about this version?
>
> diff --git a/include/linux/of_address.h b/include/linux/of_address.h
> index d88e81be6368..f2f7986cac45 100644
> --- a/include/linux/of_address.h
> +++ b/include/linux/of_address.h
> @@ -57,6 +57,11 @@ extern int of_dma_get_range(struct device_node *np, u64 *dma_addr,
>   				u64 *paddr, u64 *size);
>   extern bool of_dma_is_coherent(struct device_node *np);
>   #else /* CONFIG_OF_ADDRESS */
> +static inline u64 of_translate_address(struct device_node *np, const __be32 *addr)
> +{
> +	return 0;

Maybe return OF_BAD_ADDR ?

> +}
> +
>   static inline struct device_node *of_find_matching_node_by_address(
>   					struct device_node *from,
>   					const struct of_device_id *matches,
>
>
> It looks like it's in line with the other wrappers here. Alternatively,
> we could decide to use CONFIG_OF_ADDRESS instead of CONFIG_OF as the dependency.
>
You are right, both of those would be better than my patch.
My preference would be to introduce the dummy function. This would solve
the problem for good (it isn't the first time this happens).

Are you going to submit that patch ?

Thanks,
Guenter
