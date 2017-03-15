From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Wed, 15 Mar 2017 10:42:03 +0100
Message-ID: <3dba0948-ffcb-8e80-fb32-62bb0aca6627@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
 <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Akshay Bhat <akshay.bhat@timesys.com>, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Akshay Bhat <nodeax@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

Am 15.03.2017 um 05:44 schrieb Akshay Bhat:
> Hi Wolfgang,
>
> On Tue, Mar 14, 2017 at 2:08 PM, Wolfgang Grandegger <wg@grandegger.com> wrote:
> ...snip....
>>> /////disconnect cable
>>>   can0  20000088   [8]  00 00 00 19 00 00 28 00   ERRORFRAME
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{40}{0}}
>>>   can0  20000088   [8]  00 00 00 19 00 00 58 00   ERRORFRAME
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{88}{0}}
>>>   can0  20000088   [8]  00 00 00 19 00 00 80 00   ERRORFRAME
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{128}{0}}
>>
>>
>> TX error warning is missing.
>>
>
> This support was missing in the driver, added in V4 patch.
>
>>>   can0  2000008C   [8]  00 20 00 19 00 00 80 00   ERRORFRAME
>>>         controller-problem{tx-error-passive}
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{128}{0}}
>>
>>
>> Here "tx-error-passiv" is packed with a bus error. What I'm looking for are
>> state change messages similar to:
>>
>>    can0  20000204  [8] 00 08 00 00 00 00 60 00   ERRORFRAME
>>         controller-problem{tx-error-warning}
>>         state-change{tx-error-warning}
>>         error-counter-tx-rx{{96}{0}}
>>    can0  20000204  [8] 00 30 00 00 00 00 80 00   ERRORFRAME
>>         controller-problem{tx-error-passive}
>>         state-change{tx-error-passive}
>>         error-counter-tx-rx{{128}{0}
>>
>> They should always come, even with "berr-reporting off".
>>
>
> HI-3110 has only 1 bus error interrupt. There is no dedicated state
> change interrupts like other controllers.

I have little hope! Some revision of the flexcan controller have the 
same problem

>
> So here is my plan:
> - Have the bus error interrupt always enabled
> - If berr-reporting off, then have the isr checks/reports state changes

Error state change messages should always be there. These are the 
important one.

> - if berr-reporting on, then have the isr checks/reports bus errors
> and state changes (Does it make sense packing the error message, if
> the ISR finds both bus and state changes?)

If berr-reporting is off, simply do not create an error message for bus 
errors, and only if the state changed. If it's "on" create an additional 
bus error message.

http://lxr.free-electrons.com/source/drivers/net/can/flexcan.c#L334


>>> write: No buffer space available
>>> root@imx6qrom5420b1:~# ip -s -d link show can0
>>> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>>> mode DEFAULT group default qlen 10
>>>     link/can  promiscuity 0
>>>     can <BERR-REPORTING> state ERROR-PASSIVE (berr-counter tx 128 rx 0)
>>> restart-ms 0
>>>           bitrate 1000000 sample-point 0.750
>>>           tq 62 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
>>>           hi3110: tseg1 2..16 tseg2 2..8 sjw 1..4 brp 1..64 brp-inc 1
>>>           clock 16000000
>>>           re-started bus-errors arbit-lost error-warn error-pass bus-off
>>>           0          6          0          1          1          0
>>
>>
>> The error warning and passive counter increased , though. Also the bus error
>> should come in at a rather hight rate. Looking to the code, maybe
>> you need to test STATF to check for state changes (and not ERR).
>>
>
> Apologize, just realized In the above case some error packets were
> lost, because I forgot to set the CPU frequency to max. Will resend
> the log.
>
> ..snip...
>>
>> After some more messages there should be also:
>>
>>     can0  20000200  [8] 00 40 00 00 00 00 5F 00   ERRORFRAME
>>         state-change{back-to-error-active}
>>         error-counter-tx-rx{{95}{0}}
>>
>> For each message sent, the error counter decreases by 8.
>>
>
> The HI-3110 controller decrements the error counter by 1 for every message sent.
> The error count increments by 8 when there is an error.

Seems OK according to:

http://electronics.stackexchange.com/questions/220596/can-error-counters-behaviour

>>
>>>
>>> root@imx6qrom5420b1:~# ip -s -d link show can0
>>> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>>> mode DEFAULT group default qlen 10
>>>     link/can  promiscuity 0
>>>     can state ERROR-ACTIVE (berr-counter tx 117 rx 0) restart-ms 0
>>>           bitrate 1000000 sample-point 0.750
>>>           tq 62 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
>>>           hi3110: tseg1 2..16 tseg2 2..8 sjw 1..4 brp 1..64 brp-inc 1
>>>           clock 16000000
>>>           re-started bus-errors arbit-lost error-warn error-pass bus-off
>>>           0          1          0          0          0          0
>>
>>
>> Strange, some counters got lost.
>>
>
> This was a bug introduced when adding berr-reporting, have fixed in v4 patch.
>
>>>
>>> I have not been able to check the bus-off condition by (short-circuiting
>>> CAN low and high). The tec error count remains at 128 when I short the
>>> CAN low and high pins and the status never goes BUSOFF.
>>
>>
>> You also need to send a message and the short-circuit should be at the
>> connector of the sending host. What tranceiver is used? Do you know?
>>
>
> ADM3054 transceiver is used with HI-3111. I connected the
> HI-3111/ADM3054 board to kvaser leaf and ran "cangen -i can0" and
> "candump -e any,0:0,#FFFFFFF" on the board. Removed the cable and
> shorted the CAN_H/L pins coming out of ADM3054. I will try your
> suggestion of using a different bit-rate on the Kvaser leaf instead.
>
> I appreciate your continued feedback, it has helped significantly
> improve the error handling of the driver. Looking back I should have
> based it on sja1000 or flexcan driver.

Well, the SJA1000 is the reference concerning error reporting. It's very 
detailed. Most of the error cases from

http://lxr.free-electrons.com/source/include/uapi/linux/can/error.h

are SJA1000 related. Most other CAN controllers report much less. And 
the Flexcan driver handles a lot of different chip revisions and uses 
mail boxes. It's not a good base for the Hi-311x.

Wolfgang.

Wolfgang.
