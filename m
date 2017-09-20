From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Wed, 20 Sep 2017 15:19:33 -0500
Message-ID: <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>
To: "Yang, Wenyou" <Wenyou.Yang@Microchip.com>,
        Sekhar Nori <nsekhar@ti.com>, <wg@grandegger.com>,
        <mkl@pengutronix.de>, <mario.huettel@gmx.net>,
        <socketcan@hartkopp.net>, <quentin.schulz@free-electrons.com>,
        <edumazet@google.com>, <linux-can@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wenyou,

On 09/17/2017 10:47 PM, Yang, Wenyou wrote:
> 
> 
> On 2017/9/14 13:06, Sekhar Nori wrote:
>> On Thursday 14 September 2017 03:28 AM, Franklin S Cooper Jr wrote:
>>>
>>> On 08/18/2017 02:39 PM, Franklin S Cooper Jr wrote:
>>>> During test transmitting using CAN-FD at high bitrates (4 Mbps) only
>>>> resulted in errors. Scoping the signals I noticed that only a single
>>>> bit
>>>> was being transmitted and with a bit more investigation realized the
>>>> actual
>>>> MCAN IP would go back to initialization mode automatically.
>>>>
>>>> It appears this issue is due to the MCAN needing to use the Transmitter
>>>> Delay Compensation Mode as defined in the MCAN User's Guide. When this
>>>> mode is used the User's Guide indicates that the Transmitter Delay
>>>> Compensation Offset register should be set. The document mentions
>>>> that this
>>>> register should be set to (1/dbitrate)/2*(Func Clk Freq).
>>>>
>>>> Additional CAN-CIA's "Bit Time Requirements for CAN FD" document
>>>> indicates
>>>> that this TDC mode is only needed for data bit rates above 2.5 Mbps.
>>>> Therefore, only enable this mode and only set TDCO when the data bit
>>>> rate
>>>> is above 2.5 Mbps.
>>>>
>>>> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
>>>> ---
>>>> I'm pretty surprised that this hasn't been implemented already since
>>>> the primary purpose of CAN-FD is to go beyond 1 Mbps and the MCAN IP
>>>> supports up to 10 Mbps.
>>>>
>>>> So it will be nice to get comments from users of this driver to
>>>> understand
>>>> if they have been able to use CAN-FD beyond 2.5 Mbps without this
>>>> patch.
>>>> If they haven't what did they do to get around it if they needed higher
>>>> speeds.
>>>>
>>>> Meanwhile I plan on testing this using a more "realistic" CAN bus to
>>>> insure
>>>> everything still works at 5 Mbps which is the max speed of my CAN
>>>> transceiver.
>>> ping. Anyone has any thoughts on this?
>> I added Dong who authored the m_can driver and Wenyou who added the only
>> in-kernel user of the driver for any help.
> I tested it on SAMA5D2 Xplained board both with and without this patch, 
> both work with the 4M bps data bit rate.

Thank you for testing this out. Its interesting that you have been able
to use higher speeds without this patch. What is the CAN transceiver
being used on the SAMA5D2 Xplained board? I tried looking at the
schematic but it seems the CAN signals are used on an extension board
which I can't find the schematic for. Also do you mind sharing your test
setup? Were you doing a short point to point test?

Thank You,
Franklin

> 
>>
>> Thanks,
>> Sekhar
>>
>>>>   drivers/net/can/m_can/m_can.c | 24 +++++++++++++++++++++++-
>>>>   1 file changed, 23 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/can/m_can/m_can.c
>>>> b/drivers/net/can/m_can/m_can.c
>>>> index f4947a7..720e073 100644
>>>> --- a/drivers/net/can/m_can/m_can.c
>>>> +++ b/drivers/net/can/m_can/m_can.c
>>>> @@ -126,6 +126,12 @@ enum m_can_mram_cfg {
>>>>   #define DBTP_DSJW_SHIFT        0
>>>>   #define DBTP_DSJW_MASK        (0xf << DBTP_DSJW_SHIFT)
>>>>   +/* Transmitter Delay Compensation Register (TDCR) */
>>>> +#define TDCR_TDCO_SHIFT        8
>>>> +#define TDCR_TDCO_MASK        (0x7F << TDCR_TDCO_SHIFT)
>>>> +#define TDCR_TDCF_SHIFT        0
>>>> +#define TDCR_TDCF_MASK        (0x7F << TDCR_TDCO_SHIFT)
>>>> +
>>>>   /* Test Register (TEST) */
>>>>   #define TEST_LBCK        BIT(4)
>>>>   @@ -977,6 +983,8 @@ static int m_can_set_bittiming(struct
>>>> net_device *dev)
>>>>       const struct can_bittiming *dbt = &priv->can.data_bittiming;
>>>>       u16 brp, sjw, tseg1, tseg2;
>>>>       u32 reg_btp;
>>>> +    u32 enable_tdc = 0;
>>>> +    u32 tdco;
>>>>         brp = bt->brp - 1;
>>>>       sjw = bt->sjw - 1;
>>>> @@ -991,9 +999,23 @@ static int m_can_set_bittiming(struct
>>>> net_device *dev)
>>>>           sjw = dbt->sjw - 1;
>>>>           tseg1 = dbt->prop_seg + dbt->phase_seg1 - 1;
>>>>           tseg2 = dbt->phase_seg2 - 1;
>>>> +
>>>> +        /* TDC is only needed for bitrates beyond 2.5 MBit/s
>>>> +         * Specified in the "Bit Time Requirements for CAN FD"
>>>> document
>>>> +         */
>>>> +        if (dbt->bitrate > 2500000) {
>>>> +            enable_tdc = DBTP_TDC;
>>>> +            /* Equation based on Bosch's M_CAN User Manual's
>>>> +             * Transmitter Delay Compensation Section
>>>> +             */
>>>> +            tdco = priv->can.clock.freq / (dbt->bitrate * 2);
>>>> +            m_can_write(priv, M_CAN_TDCR, tdco << TDCR_TDCO_SHIFT);
>>>> +        }
>>>> +
>>>>           reg_btp = (brp << DBTP_DBRP_SHIFT) | (sjw <<
>>>> DBTP_DSJW_SHIFT) |
>>>>               (tseg1 << DBTP_DTSEG1_SHIFT) |
>>>> -            (tseg2 << DBTP_DTSEG2_SHIFT);
>>>> +            (tseg2 << DBTP_DTSEG2_SHIFT) | enable_tdc;
>>>> +
>>>>           m_can_write(priv, M_CAN_DBTP, reg_btp);
>>>>       }
>>>>  
> 
> Regards,
> Wenyou Yang
> 
