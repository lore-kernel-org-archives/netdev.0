From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: m_can: enable transmission of FD frame on latest
 version
Date: Mon, 6 Mar 2017 20:33:15 +0100
Message-ID: <b24f3252-6bd9-db48-b224-5bf3683cb75d@hartkopp.net>
References: <20170306022143.7695-1-wenyou.yang@atmel.com>
 <e4360c52-d62d-6c35-f691-7fcd0f74f954@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        Wenyou Yang <wenyou.yang@microchip.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wenyou Yang <wenyou.yang@atmel.com>,
        Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <e4360c52-d62d-6c35-f691-7fcd0f74f954@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On 03/06/2017 11:53 AM, Marc Kleine-Budde wrote:
> On 03/06/2017 03:21 AM, Wenyou Yang wrote:
>> Enables the transmission of CAN FD frames on M_CAN IP core >= v3.1.x
>> and with the bit rate switching.
>>
>> Tested on M_CAN IP 3.1.0 (CREL = 0x31040730) of SAMA5D2 SoC.
>
> Does this patch work still with the old version of the silicon?

The bits that were added in the TX FIFO element are 'reserved' in the 
old silicon - so it should not harm.

This code enables

  if (priv->can.ctrlmode & CAN_CTRLMODE_FD)
-	cccr |= CCCR_CME_CANFD_BRS << CCCR_CME_SHIFT;
+	cccr |= (CCCR_CME_CANFD_BRS | CCCR_CME_CANFD) << CCCR_CME_SHIFT;

the CAN FD support in the new silicon.

This register is set for the old silicon EVERY time a CAN frame is sent.
So this change should not harm the old silicon either.

In fact I was told that the v3.0.x IP core is rather seldom in the wild.
Although I don't have a v3.0.x to test it should work from the 
documentation side of view.

Reviewed-by: Oliver Hartkopp <socketcan@hartkopp.net>

If we would like to make it really better, the code in 
m_can_start_xmit() should only fiddle with the M_CAN_CCCR register when 
working with the v3.0.x silicon.

In fact I would suggest to use the

	if (m_can_read_core_rev(priv) < M_CAN_COREREL_3_1_0)

method from

	http://marc.info/?l=linux-can&m=148716783119090&w=2

to split the code in m_can_start_xmit() accordingly.

@Wenyou Yang: Can you please send a v3 which splits the tx function?

Regards,
Oliver
