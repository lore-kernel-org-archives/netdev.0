From: Ceriel Jacobs <linux-ide@crashplan.pro>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware
Date: Tue, 07 Oct 2014 12:40:59 +0200
Message-ID: <5433C33B.2060700@crashplan.pro>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:38792 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbaJGKlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 06:41:36 -0400
In-Reply-To: <20141006221307.GB10936@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Francois Romieu schreef op 07-10-14 om 00:13:
> Hayes Wang <hayeswang@realtek.com> :
>>   Francois Romieu [mailto:romieu@fr.zoreil.com]
> [...]
>> I don't sure if the following information is helpful. Besides, I remember
>> the rtl_init_one() would disable it.
>>
>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=d64ec841517a25f6d468bde9f67e5b4cffdc67c7
>>
>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4521e1a94279ce610d3f9b7945c17d581f804242
>
> Yes, I did not expect this stuff to stay in geostationary orbit for long :o/
>
> Realtek's r8168 driver defaults to CONFIG_ASPM=1

# modinfo r8168 suggests the opposite (ASPM is disabled by default):
version:        8.039.00-NAPI
parm:           aspm:Enable ASPM. (int)

When ASPM would be enabled by default, one would need a boot parameter like:
parm:		aspm:Disable ASPM. (int)

  but I guess some users
> need to disable it and there's no known pattern / blacklist, right ?

I don't want to disable ASPM. In fact the r8168 module I am even running 
with poot params like:
# cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-3.17.0-999-generic root=/dev/sda1 ro 
biosdevname=0 intel_pstate=enable ipv6.disabled=1 debug ignore_loglevel 
panic=10 pcie_aspm.policy=powersave pcie_aspm=force r8168.aspm=1 
r8168.eee_enable=1 oops=panic

>
> Ceriel, does the patch below against current kernel make a difference ?

Francois, what do you mean with "current kernel", the latest Ubuntu 
mainline kernel or something different?

>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 0921302..b4a3881 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -468,6 +468,7 @@ enum rtl8168_registers {
>   #define PWM_EN				(1 << 22)
>   #define RXDV_GATED_EN			(1 << 19)
>   #define EARLY_TALLY_EN			(1 << 16)
> +#define FORCE_CLK			(1 << 15) /* force clock request */
>   };
>
>   enum rtl_register_content {
> @@ -5279,8 +5280,10 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
>   	rtl_eri_write(tp, 0x2f8, ERIAR_MASK_0011, 0x1d8f, ERIAR_EXGMAC);
>
>   	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> -	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
> +	RTL_W32(MISC, (RTL_R32(MISC) | FORCE_CLK) & ~RXDV_GATED_EN);
>   	RTL_W8(MaxTxPacketSize, EarlySize);
> +	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
> +	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
>
>   	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
>   	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
>
