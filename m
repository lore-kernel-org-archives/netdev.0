From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Wed, 18 Oct 2017 18:54:27 +0530
Message-ID: <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, <wg@grandegger.com>,
        <socketcan@hartkopp.net>, <quentin.schulz@free-electrons.com>,
        <edumazet@google.com>, <linux-can@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Wednesday 18 October 2017 06:14 PM, Marc Kleine-Budde wrote:
> On 09/21/2017 02:48 AM, Franklin S Cooper Jr wrote:
>>
>>
>> On 09/20/2017 04:37 PM, Mario Hüttel wrote:
>>>
>>>
>>> On 09/20/2017 10:19 PM, Franklin S Cooper Jr wrote:
>>>> Hi Wenyou,
>>>>
>>>> On 09/17/2017 10:47 PM, Yang, Wenyou wrote:
>>>>>
>>>>> On 2017/9/14 13:06, Sekhar Nori wrote:
>>>>>> On Thursday 14 September 2017 03:28 AM, Franklin S Cooper Jr wrote:
>>>>>>> On 08/18/2017 02:39 PM, Franklin S Cooper Jr wrote:
>>>>>>>> During test transmitting using CAN-FD at high bitrates (4 Mbps) only
>>>>>>>> resulted in errors. Scoping the signals I noticed that only a single
>>>>>>>> bit
>>>>>>>> was being transmitted and with a bit more investigation realized the
>>>>>>>> actual
>>>>>>>> MCAN IP would go back to initialization mode automatically.
>>>>>>>>
>>>>>>>> It appears this issue is due to the MCAN needing to use the Transmitter
>>>>>>>> Delay Compensation Mode as defined in the MCAN User's Guide. When this
>>>>>>>> mode is used the User's Guide indicates that the Transmitter Delay
>>>>>>>> Compensation Offset register should be set. The document mentions
>>>>>>>> that this
>>>>>>>> register should be set to (1/dbitrate)/2*(Func Clk Freq).
>>>>>>>>
>>>>>>>> Additional CAN-CIA's "Bit Time Requirements for CAN FD" document
>>>>>>>> indicates
>>>>>>>> that this TDC mode is only needed for data bit rates above 2.5 Mbps.
>>>>>>>> Therefore, only enable this mode and only set TDCO when the data bit
>>>>>>>> rate
>>>>>>>> is above 2.5 Mbps.
>>>>>>>>
>>>>>>>> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
>>>>>>>> ---
>>>>>>>> I'm pretty surprised that this hasn't been implemented already since
>>>>>>>> the primary purpose of CAN-FD is to go beyond 1 Mbps and the MCAN IP
>>>>>>>> supports up to 10 Mbps.
>>>>>>>>
>>>>>>>> So it will be nice to get comments from users of this driver to
>>>>>>>> understand
>>>>>>>> if they have been able to use CAN-FD beyond 2.5 Mbps without this
>>>>>>>> patch.
>>>>>>>> If they haven't what did they do to get around it if they needed higher
>>>>>>>> speeds.
>>>>>>>>
>>>>>>>> Meanwhile I plan on testing this using a more "realistic" CAN bus to
>>>>>>>> insure
>>>>>>>> everything still works at 5 Mbps which is the max speed of my CAN
>>>>>>>> transceiver.
>>>>>>> ping. Anyone has any thoughts on this?
>>>>>> I added Dong who authored the m_can driver and Wenyou who added the only
>>>>>> in-kernel user of the driver for any help.
>>>>> I tested it on SAMA5D2 Xplained board both with and without this patch, 
>>>>> both work with the 4M bps data bit rate.
>>>> Thank you for testing this out. Its interesting that you have been able
>>>> to use higher speeds without this patch. What is the CAN transceiver
>>>> being used on the SAMA5D2 Xplained board? I tried looking at the
>>>> schematic but it seems the CAN signals are used on an extension board
>>>> which I can't find the schematic for. Also do you mind sharing your test
>>>> setup? Were you doing a short point to point test?
>>>>
>>>> Thank You,
>>>> Franklin
>>> Hello Franklin,
>>>
>>> your patch definitely makes sense.
>>>
>>> I forgot the TDC in my patches because it was not present in the
>>> previous driver versions and because I didn't encounter any
>>> problems when testing it myself.
>>>
>>> The error is highly dependent on the hardware (transceiver) setup.
>>> So it is definitely possible that some people don't encounter errors
>>> without your patch.
>>
>> So the Transmission Delay Compensation feature Value register is suppose
>> to take into consideration the transceiver delay automatically and add
>> the value of TDCO on top of that. So why would TDCO be dependent on the
>> transceiver? I've heard conflicting things regarding TDC so any
>> clarification on what actually impacts it would be appreciated.
>>
>> Also part of the issue I'm having is how can we properly configure TDCO?
>> Configuring TDCO is essentially figuring out what Secondary Sample Point
>> to use. However, it is unclear what value to set SSP to and which use
>> cases a given SSP will work or doesn't work. I've seen various
>> recommendations from Bosch on choosing SSP but ultimately it seems they
>> suggestion "real world testing" to come up with a proper value. Not
>> setting TDCO causes problems for my device and improperly setting TDCO
>> causes problems for my device. So its likely any value I use could end
>> up breaking something for someone else.
>>
>> Currently I leaning to a DT property that can be used for setting SSP.
>> Perhaps use a generic default value and allow individuals to override it
>> via DT?
> 
> Sounds reasonable. What's the status of this series?

I have had some offline discussions with Franklin on this, and I am not
fully convinced that DT is the way to go here (although I don't have the
agreement with Franklin there).

There are two components in configuring the secondary sample point. It
is the transceiver loopback delay and an offset (example half of the bit
time in data phase).

While the transceiver loopback delay is pretty board dependent (and thus
amenable to DT encoding), I am not quite sure the offset can be
configured in DT because its not really board dependent.

Unfortunately, offset calculation does not seem to be an exact science.
There are recommendations ranging from using 50% of bit time to making
it same as the sample point configured. This means users who need to
change the SSP due to offset variations need to change  their DT even
without anything changing on their board.

Since we have a netlink socket interface to configure sample point, I
wonder if that should be extended to configure SSP too (or at least the
offset part of SSP)?

Thanks,
Sekhar
