From: booster@wolke7.net
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Thu, 01 Dec 2011 21:42:19 +0100
Message-ID: <4ED7E6AB.6050308@wolke7.net>
References: <20111125222211.GA13719@electric-eye.fr.zoreil.com> <1322262357.2550.12.camel@edumazet-laptop> <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com> <4ED538EC.4010509@wolke7.net> <20111201102000.GA14013@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>,
	'Jonathan Nieder' <jrnieder@gmail.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, 'nic_swsd' <nic_swsd@realtek.com>,
	linux-kernel@vger.kernel.org,
	'Armin Kazmi' <armin.kazmi@tu-dortmund.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:55098 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753453Ab1LAUm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 15:42:27 -0500
In-Reply-To: <20111201102000.GA14013@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> booster@wolke7.net <booster@wolke7.net> :
> [...]
>   
>> Any more ideas ?
>>     
>
> Give me a brain.
>
> Fixed patch below.
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 6f06aa1..e776bf2 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4885,8 +4894,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
>  	RTL_W16(IntrMitigate, 0x5151);
>  
>  	/* Work around for RxFIFO overflow. */
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
>  		tp->intr_event |= RxFIFOOver | PCSTimeout;
>  		tp->intr_event &= ~RxOverflow;
>  	}
> @@ -5804,6 +5812,10 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  	 */
>  	status = RTL_R16(IntrStatus);
>  	while (status && status != 0xffff) {
> +		status &= tp->intr_event;
> +		if (!status)
> +			break;
> +
>  		handled = 1;
>  
>  		/* Handle all of the error cases first. These will reset
> @@ -5818,7 +5830,6 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  			switch (tp->mac_version) {
>  			/* Work around for rx fifo overflow */
>  			case RTL_GIGA_MAC_VER_11:
> -			case RTL_GIGA_MAC_VER_22:
>  			case RTL_GIGA_MAC_VER_26:
>  				netif_stop_queue(dev);
>  				rtl8169_tx_timeout(dev);
> @@ -5828,6 +5839,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  			case RTL_GIGA_MAC_VER_19:
>  			case RTL_GIGA_MAC_VER_20:
>  			case RTL_GIGA_MAC_VER_21:
> +			case RTL_GIGA_MAC_VER_22:
>  			case RTL_GIGA_MAC_VER_23:
>  			case RTL_GIGA_MAC_VER_24:
>  			case RTL_GIGA_MAC_VER_27:
>
>   
Hello Francois,

it looks OK now - no more "eth0: link up" messages and network hangs any
more.
I've send and received 60 GB to and from the system and the performance
is ~30 MB/s.
I'll keep the system up and running and do some more stability tests.

The only thing that's missing now is the transfer LED: the yellow link
LED is on,
but the green transfer LED is off and doesn't blink.

Thanks a lot for your great support.

Regards,
Gerd


Output:

[    2.334588] r8169 Gigabit Ethernet driver 2.3LK-NAPI-patch3 loaded
[    2.334639] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) ->
IRQ 16
[    2.334689] r8169 0000:02:00.0: setting latency timer to 64
[    2.334767] r8169 0000:02:00.0: irq 40 for MSI/MSI-X
[    2.387618] r8169 0000:02:00.0: eth0: RTL8168c/8111c[21] at
0xf8224000, 00:01:c0:08:aa:31, XID 1c4000c0 IRQ 40
[    2.387630] r8169 0000:02:00.0: eth0: jumbo features [frames: 6128
bytes, tx checksumming: ko]
[    2.392954] r8169 Gigabit Ethernet driver 2.3LK-NAPI-patch3 loaded
[    2.393015] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) ->
IRQ 17
[    2.393082] r8169 0000:03:00.0: setting latency timer to 64
[    2.393166] r8169 0000:03:00.0: irq 41 for MSI/MSI-X
[    2.394707] r8169 0000:03:00.0: eth1: RTL8168c/8111c[21] at
0xf8238000, 00:01:c0:08:aa:32, XID 1c4000c0 IRQ 41
[    2.394718] r8169 0000:03:00.0: eth1: jumbo features [frames: 6128
bytes, tx checksumming: ko]
[   14.324097] r8169 0000:03:00.0: eth1: link down
[   14.324555] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   14.419038] r8169 0000:02:00.0: eth0: link down
[   14.419049] r8169 0000:02:00.0: eth0: link down
[   14.419419] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   16.789915] r8169 0000:02:00.0: eth0: link up
[   16.791046] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

driver: r8169
version: 2.3LK-NAPI-patch3
firmware-version: N/A
bus-info: 0000:02:00.0

Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised pause frame use: Symmetric Receive-only
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                             100baseT/Half 100baseT/Full
                                             1000baseT/Full
        Link partner advertised pause frame use: Symmetric
        Link partner advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
        Link detected: yes
