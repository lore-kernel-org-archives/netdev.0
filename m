From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Wed, 19 Mar 2014 09:20:17 -0500
Message-ID: <5329A7A1.20606@gmail.com>
References: <201403191333.01095.arnd@arndb.de> <53299CA8.607@gmail.com> <4337501.shzGE38xmF@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dinh Nguyen <dinguyen@altera.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hans de Goede <hdegoede@redhat.com>, arm@kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4337501.shzGE38xmF@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/19/2014 09:05 AM, Arnd Bergmann wrote:
> On Wednesday 19 March 2014 08:33:28 Dinh Nguyen wrote:
>> On 03/19/2014 07:33 AM, Arnd Bergmann wrote:
>>>
>>> * Replaced the parent/child DT nodes with a combined node
>>> * Renamed the device node from 'ethernet0' to 'ethernet'
>>>     as the standard name.
>>> * Removed interrupt-names and clock-names properties that
>>>     are not documented in the binding and not used.
>>> * Added a new DWMAC_SOCFPGA Kconfig symbol to control
>>>     compilation of this driver
>>
>> The v1 of this patch had this had this Kconfig symbol and is
>> similar to your proposed fix.
>>
>> http://marc.info/?l=linux-netdev&m=139167062725242&w=2
>
> I don't understand. So you got parts of it right at first, but then
> changed it in a different way from what Peppe asked you to do?
>

Peppe asked me to remove DWMAC_SOCFPGA Koption and take the dwmac-sti.c
file as an example, which I did. The original patch for dwmac-sti.c had 
just a CONFIG_ARCH_STI Kconfig option and not CONFIG_DWMAC_STI.

http://marc.info/?l=linux-netdev&m=138426461307138&w=2

I'm sorry I did not follow the later versions of dwmac-sti.c.

>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> index 8fb32a8..46aef510 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> @@ -38,6 +38,9 @@ static const struct of_device_id stmmac_dt_ids[] = {
>>>    	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
>>>    	{ .compatible = "st,stid127-dwmac", .data = &sti_gmac_data},
>>>    #endif
>>> +#ifdef CONFIG_DWMAC_SOCFPGA
>>> +	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
>>> +#endif
>>>    	/* SoC specific glue layers should come before generic bindings */
>>>    	{ .compatible = "st,spear600-gmac"},
>>>    	{ .compatible = "snps,dwmac-3.610"},
>>
>>
>> If it's okay with you Arnd, can I take this patch and add on top of it
>> as it is also breaking dtb builds:
>>
>> Error: arch/arm/boot/dts/socfpga_arria5_socdk.dts:51.2-3 label or path,
>> 'ethernet1', not found
>> FATAL ERROR: Syntax error parsing input tree
>> Error: arch/arm/boot/dts/socfpga_cyclone5_socdk.dts:44.2-3 label or
>> path, 'ethernet1', not found
>> FATAL ERROR: Syntax error parsing input tree
>> make[1]: *** [arch/arm/boot/dts/socfpga_arria5_socdk.dtb] Error 1
>> make[1]: *** Waiting for unfinished jobs....
>> make[1]: *** [arch/arm/boot/dts/socfpga_cyclone5_socdk.dtb] Error 1
>> Error: arch/arm/boot/dts/socfpga_cyclone5_sockit.dts:44.2-3 label or
>> path, 'ethernet1', not found
>> FATAL ERROR: Syntax error parsing input tree
>> make[1]: *** [arch/arm/boot/dts/socfpga_cyclone5_sockit.dtb] Error 1
>> Error: arch/arm/boot/dts/socfpga_vt.dts:92.2-3 label or path,
>> 'ethernet0', not found
>
> I have found the same problems and fixed it up locally already with
> the additional change below.
>

Thanks,
Dinh

> 	Arnd
>
>
> diff --git a/arch/arm/boot/dts/socfpga_arria5_socdk.dts b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
> index 2d6b38b..a87ee1c 100644
> --- a/arch/arm/boot/dts/socfpga_arria5_socdk.dts
> +++ b/arch/arm/boot/dts/socfpga_arria5_socdk.dts
> @@ -46,11 +46,8 @@
>   	};
>   };
>
> -&ethernet1 {
> -	status = "okay";
> -};
> -
>   &gmac1 {
> +	status = "okay";
>   	phy-mode = "rgmii";
>
>   	rxd0-skew-ps = <0>;
> diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
> index 26c63a0..ae16d97 100644
> --- a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
> +++ b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
> @@ -39,11 +39,8 @@
>   	};
>   };
>
> -&ethernet1 {
> -	status = "okay";
> -};
> -
>   &gmac1 {
> +	status = "okay";
>   	phy-mode = "rgmii";
>
>   	rxd0-skew-ps = <0>;
> diff --git a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
> index 469bb5c..b79e2a2 100644
> --- a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
> +++ b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
> @@ -39,11 +39,8 @@
>   	};
>   };
>
> -&ethernet1 {
> -	status = "okay";
> -};
> -
>   &gmac1 {
> +	status = "okay";
>   	phy-mode = "rgmii";
>
>   	rxd0-skew-ps = <0>;
> diff --git a/arch/arm/boot/dts/socfpga_vt.dts b/arch/arm/boot/dts/socfpga_vt.dts
> index 91f6ccf..0f33f2f 100644
> --- a/arch/arm/boot/dts/socfpga_vt.dts
> +++ b/arch/arm/boot/dts/socfpga_vt.dts
> @@ -87,10 +87,7 @@
>   	};
>   };
>
> -&ethernet0 {
> -        status = "okay";
> -};
> -
>   &gmac0 {
> +        status = "okay";
>   	phy-mode = "gmii";
>   };
>
