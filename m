From: Eric Nelson <eric.nelson@boundarydevices.com>
Subject: Re: [PATCH 1/1 net-next] net: fec: enable pause frame to improve
 rx prefomance for 1G network
Date: Tue, 08 Jan 2013 09:13:41 -0700
Message-ID: <50EC45B5.3000601@boundarydevices.com>
References: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com> <50EBED0E.6090608@de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>,
	"lznuaa@gmail.com" <lznuaa@gmail.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Dirk Behme <dirk.behme@de.bosch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38828 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756360Ab3AHQNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 11:13:45 -0500
Received: by mail-pa0-f52.google.com with SMTP id fb1so416210pad.39
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 08:13:45 -0800 (PST)
In-Reply-To: <50EBED0E.6090608@de.bosch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 02:55 AM, Dirk Behme wrote:
> On 08.01.2013 09:43, Frank Li wrote:
>> The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
>> There will be many packages lost because FIFO over run.
>>
>> This patch enable pause frame flow control.
>
> Many thanks for this patch!
>
> Do we want/need anything similar for U-Boot, too?
>
> Some people want to boot the system from U-Boot attached to 1G network
> and have issues there, too.
>

It's hard to see how the typical use (dhcp+tftp) would be affected
because of the small packet sizes and half-duplex operation.

That said, the statistics registers make it pretty easy to see when
there are overflows as described here:
	http://boundarydevices.com/i-mx6-ethernet/

We should be able to just poke the ENET_MIBC register and watch
to see if the IEEE_R_MACERR register shows that overruns are
occurring using the U-Boot md and mw commands.

In a quick test, it appears that this doesn't work though.
This line of code in fec_halt from fec_mxc.c seems to clear the
statistics.

	writel(readl(&fec->eth->ecntrl) & ~FEC_ECNTRL_ETHER_EN,
			&fec->eth->ecntrl);

If you comment that out, you can see all of the statistics registers
as shown below:

U-Boot > mw.l 0x02188064 0    #ENET_MIBC
U-Boot > dhcp 10800000 192.168.0.55:uImage-bluemeany
BOOTP broadcast 1
DHCP client bound to address 192.168.0.91
Using FEC device
TFTP from server 192.168.0.55; our IP address is 192.168.0.91
Filename 'uImage-bluemeany'.
Load address: 0x10800000
Loading: ...
done
Bytes transferred = 3760504 (396178 hex)
U-Boot > md.l 0x02188200 0x39
02188200: 00000000 00001cb6 00000003 00000000    ................
02188210: 00000000 00000000 00000000 00000000    ................
02188220: 00000000 00000000 00001cb2 00000002    ................
02188230: 00000000 00000002 00000000 00000000    ................
02188240: 00000000 00072fd4 00000000 00001cb6    ...../..........
02188250: 00000000 00000000 00000000 00000000    ................
02188260: 00000000 00000000 00000000 00000000    ................
02188270: 00000000 00072fd4 00000000 00000000    ...../..........
02188280: 00000000 00001dca 0000002a 000000e6    ........*.......
02188290: 00000000 00000000 00000000 00000000    ................
021882a0: 00000000 00000000 00000037 00000057    ........7...W...
021882b0: 0000004e 00000023 00001ccb 00000000    N...#...........
021882c0: 00000000 003fd011 00000000 00001dcc    ......?.........
021882d0: 00000000 00000000 00000000 00000000    ................
021882e0: 003fd011    ..?.
U-Boot >

Register 0x021882d8 is the MACERR (fifo overlow) counter.

Regards,


Eric
