From: Tomi Orava <tomimo@ncircle.nullnet.fi>
Subject: Re: Fw: [Bug 54231] r8169 driver regression caused by the commit
 aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
Date: Tue, 26 Feb 2013 20:41:07 +0200
Message-ID: <512D01C3.3080604@ncircle.nullnet.fi>
References: <20130222095546.396e63a8@nehalam.linuxnetplumber.net> <20130222230908.GB4248@electric-eye.fr.zoreil.com> <512A2BB0.9050803@ncircle.nullnet.fi> <20130224220413.GA22870@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:59550 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab3BZSlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 13:41:12 -0500
In-Reply-To: <20130224220413.GA22870@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2013 12:04 AM, Francois Romieu wrote:
> Tomi Orava <tomimo@ncircle.nullnet.fi> :
>> On 02/23/2013 01:09 AM, Francois Romieu wrote:
> [...]
>> I started re-testing after your comment and figured out that the
>> real problem seems to lie somehow with jumbo frames. Ie. the DMA burst
>> changes do not actually prevent the hangs at all in my case. The
>> catch here, that I missed previously, was that for some interesting
>> reason the NIC will fail in a couple of minutes with a suitable traffic
>> if the jumbo frames (mtu 4000) have been enabled from the start.
>> However, if I enable the jumbo frames manually after the system
>> has already started up, there are no stability issues related to network.
> 
> If you mean that 'ip link set dev ... mtu 4000; ip link set dev ... up'
> fails whereas 'ip link set dev ... up; ip link set dev ... mtu 4000'
> works, the patch below is a candidate:

Yes, this fits exactly my problem. I tested this change on 3.7.9 and
on 3.4.33 and I had no network hangs anymore.

Thanks!

Tomi

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 8900398..af99498 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4766,7 +4766,7 @@ static void rtl_hw_start_8168bb(struct rtl8169_private *tp)
>  	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
>  
>  	rtl_tx_performance_tweak(pdev,
> -		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
> +		(0x2 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
>  }
>  
>  static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
> ---
> 
> [...]
>>> Tomi, what does lspci say about your 8168b device ?
>>
>> The NIC information is:
>>
>> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
>> Express Gigabit Ethernet controller (rev 01)
>>
>> 03:00.0 0200: 10ec:8168 (rev 01)
> 
> Ok, so the first hunk of the patch that Stephen forwarded would not make
> any difference for your chipset.
> 
