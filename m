From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Mon, 20 Mar 2017 17:46:26 +0100
Message-ID: <86fb20f6-8a3a-163f-9dc6-ba7f5368b689@grandegger.com>
References: <1489785040-26477-1-git-send-email-akshay.bhat@timesys.com>
 <1489785040-26477-2-git-send-email-akshay.bhat@timesys.com>
 <78bf099d-32ad-9981-6ba9-fe56fbcabc3e@grandegger.com>
 <7f768a65-bdf0-3b43-17e8-9aaca5997663@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Akshay Bhat <nodeax@gmail.com>
To: Akshay Bhat <akshay.bhat@timesys.com>, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7f768a65-bdf0-3b43-17e8-9aaca5997663@timesys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

Am 20.03.2017 um 16:14 schrieb Akshay Bhat:
> Hi Wolfgang,
>
> On 03/19/2017 12:17 PM, Wolfgang Grandegger wrote:
>> Hello Akshay,
>>
>> I still see some improvements...
>>
>> Am 17.03.2017 um 22:10 schrieb Akshay Bhat:
>>> This patch adds support for the Holt HI-311x CAN controller. The HI311x
>>> CAN controller is capable of transmitting and receiving standard data
>>> frames, extended data frames and remote frames. The HI311x interfaces
>>> with the host over SPI.
>>>
>>> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>>>
>>> Signed-off-by: Akshay Bhat <nodeax@gmail.com>
>>> ---
>>>
>>> v3 -> v4:
>>> Address comments from Wolfgang Grandegger:
>>> - Add support for CAN warning state reporting
>>> - Add support for reporting tx/rx error counts in bus error messages
>>> - Keep bus error interrupts enabled to detect CAN state changes
>>> - Fix bug in restart code after BUSOFF state
>>> - Clean up error handling code
>>>
>>>  drivers/net/can/spi/Kconfig  |    6 +
>>>  drivers/net/can/spi/Makefile |    1 +
>>>  drivers/net/can/spi/hi311x.c | 1072
>>> ++++++++++++++++++++++++++++++++++++++++++
>>>  3 files changed, 1079 insertions(+)
>>>  create mode 100644 drivers/net/can/spi/hi311x.c
>>>
>>> diff --git a/drivers/net/can/spi/Kconfig b/drivers/net/can/spi/Kconfig
>>> index 148cae5..8f2e0dd 100644
>>> --- a/drivers/net/can/spi/Kconfig
>>> +++ b/drivers/net/can/spi/Kconfig
>>> @@ -1,6 +1,12 @@
>>>  menu "CAN SPI interfaces"
>>>      depends on SPI
>>>
>>> +config CAN_HI311X
>>> +    tristate "Holt HI311x SPI CAN controllers"
>>> +    depends on CAN_DEV && SPI && HAS_DMA
>>> +    ---help---
>>> +      Driver for the Holt HI311x SPI CAN controllers.
>>> +
>>>  config CAN_MCP251X
>>>      tristate "Microchip MCP251x SPI CAN controllers"
>>>      depends on HAS_DMA
>>> diff --git a/drivers/net/can/spi/Makefile b/drivers/net/can/spi/Makefile
>>> index 0e86040..f59fa37 100644
>>> --- a/drivers/net/can/spi/Makefile
>>> +++ b/drivers/net/can/spi/Makefile
>>> @@ -3,4 +3,5 @@
>>>  #
>>>
>>>
>>> +obj-$(CONFIG_CAN_HI311X)    += hi311x.o
>>>  obj-$(CONFIG_CAN_MCP251X)    += mcp251x.o
>>> diff --git a/drivers/net/can/spi/hi311x.c b/drivers/net/can/spi/hi311x.c
>>> new file mode 100644
>>> index 0000000..2a3d794
>>> --- /dev/null
>>> +++ b/drivers/net/can/spi/hi311x.c
>>> @@ -0,0 +1,1072 @@
>>> +/* CAN bus driver for Holt HI3110 CAN Controller with SPI Interface
>>> + *
>>> + * Copyright(C) Timesys Corporation 2016
>>> + *
>>> + * Based on Microchip 251x CAN Controller (mcp251x) Linux kernel driver
>>> + * Copyright 2009 Christian Pellegrin EVOL S.r.l.
>>> + * Copyright 2007 Raymarine UK, Ltd. All Rights Reserved.
>>> + * Copyright 2006 Arcom Control Systems Ltd.
>>> + *
>>> + * Based on CAN bus driver for the CCAN controller written by
>>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
>>> + * - Simon Kallweit, intefo AG
>>> + * Copyright 2007
>>> + *
>>> + * This program is free software; you can redistribute it and/or modify
>>> + * it under the terms of the GNU General Public License version 2 as
>>> + * published by the Free Software Foundation.
>>> + */
>>
>> ... snip...
>>
>>> +
>>> +static irqreturn_t hi3110_can_ist(int irq, void *dev_id)
>>> +{
>>> +    struct hi3110_priv *priv = dev_id;
>>> +    struct spi_device *spi = priv->spi;
>>> +    struct net_device *net = priv->net;
>>> +
>>> +    mutex_lock(&priv->hi3110_lock);
>>> +
>>> +    while (!priv->force_quit) {
>>> +        enum can_state new_state;
>>> +        u8 intf, eflag, statf;
>>> +
>>> +        while (!(HI3110_STAT_RXFMTY &
>>> +               (statf = hi3110_read(spi, HI3110_READ_STATF)))) {
>>> +            hi3110_hw_rx(spi);
>>> +        }
>>> +
>>> +        intf = hi3110_read(spi, HI3110_READ_INTF);
>>
>> I think HI3110_READ_ERR is only valid if HI3110_INT_BUSERR is set!
>> Therefore:
>>
>>                 if ((intf & HI3110_INT_BUSERR) {
>>
>> It saves reading one SPI register in the message processing path. Please
>> check if back-to-error-active still comes.
>>
>
> The top 3 bits of HI3110_READ_ERR (BUSOFF, TXERRP, RXERRP) are valid
> even if HI3110_INT_BUSERR is not set.

I'm confused! If you disable BUSERR interrupts, you do not get the 
status bits any longer, you said. But the manual says: "Bits 4:0 in the 
ERR register can be read to determine the source of the error.", which 
excludes the above bits... but obviously the controller does it that way.

Sorry for the noise,

Wolfgang.
