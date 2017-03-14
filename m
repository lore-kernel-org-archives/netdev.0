From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Tue, 14 Mar 2017 22:23:56 +0100
Message-ID: <a2207858-eb1f-7ae2-d5fc-805b51ceceb2@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Akshay Bhat <nodeax@gmail.com>
To: Akshay Bhat <akshay.bhat@timesys.com>, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 14.03.2017 um 19:08 schrieb Wolfgang Grandegger:
> Hello Akshay,
>
> Am 14.03.2017 um 17:20 schrieb Akshay Bhat:
>>
>> Hi Wolfgang,
>>
>> On 03/14/2017 08:11 AM, Wolfgang Grandegger wrote:
>>> ... snip ...
>>>>> A few other things to check:
>>>>>
>>>>> Run "cangen" and monitor the message with "candump -e
>>>>> any,0:0,#FFFFFFF".
>>>>> Then 1) disconnect the cable or 2) short-circuit CAN low and high
>>>>> at the
>>>>> connector. You should see error messages. After reconnection or
>>>>> removing
>>>>> the short-circuit (and bus-off recovery) the state should go back to
>>>>> "active".
>>>>>
>>>>
>>>> With the above sequence, candump reports "ERRORFRAME" with
>>>> protocol-violation{{}{acknowledge-slot}}, bus-error. On re-connecting
>>>> the cable the can state goes back to ACTIVE and I see the messages that
>>>> were in the queue being sent.
>>>
>>> Do you get the ACK error also with berr-reporting off? Would be nice if
>>> you could show a candump log here.
>>>
>>
>> Below is a log for disconnecting and re-connecting CAN cable scenario:
>> (Note this is on a 4.1.18 kernel with RT patch)
>>
>> root@imx6qrom5420b1:~# ip link set can0 up type can bitrate 1000000
>> berr-reporting on
>> root@imx6qrom5420b1:~# candump -e any,0:0,#FFFFFFF &
>
> Please add "-td" ...
>
>> [1] 768
>> root@imx6qrom5420b1:~# cangen can0
>
> and "-i" here.
>
>>   can0  21C   [8]  35 98 C0 7A 95 03 E6 2A
>>   can0  6E6   [1]  F2
>>   can0  5C7   [2]  42 50
>>   can0  57C   [8]  83 7A E4 0C 03 8B 90 45
>>   can0  55C   [8]  B9 74 87 52 D8 F4 64 04
>>   can0  014   [8]  28 CB 96 57 3B 80 67 4F
>>   can0  6AF   [1]  35
>>   can0  51E   [8]  B6 C8 6C 1D 3A 87 ED 2E
>>   can0  527   [8]  D0 8A D3 59 0E 34 40 78
>>   can0  30C   [2]  6A 12
>>   can0  145   [8]  CB 6E FF 55 C1 BE C3 22
>>   can0  5A5   [8]  C4 49 54 68 02 63 F9 35
>>   can0  0BA   [8]  DA 57 5E 3A CE 88 20 1C
>>   can0  516   [2]  09 09
>>   can0  743   [8]  7C 4D 25 47 61 4C 56 3D
>>   can0  31D   [2]  9C D3
>>   can0  71E   [8]  53 7C 97 2A 2A F2 9F 56
>>   can0  52E   [8]  FE DA 2D 51 73 96 DF 79
>> /////disconnect cable
>>   can0  20000088   [8]  00 00 00 19 00 00 28 00   ERRORFRAME
>>     protocol-violation{{}{acknowledge-slot}}
>>     bus-error
>>     error-counter-tx-rx{{40}{0}}
>>   can0  20000088   [8]  00 00 00 19 00 00 58 00   ERRORFRAME
>>     protocol-violation{{}{acknowledge-slot}}
>>     bus-error
>>     error-counter-tx-rx{{88}{0}}
>>   can0  20000088   [8]  00 00 00 19 00 00 80 00   ERRORFRAME
>>     protocol-violation{{}{acknowledge-slot}}
>>     bus-error
>>     error-counter-tx-rx{{128}{0}}
>
> TX error warning is missing.
>
>>   can0  2000008C   [8]  00 20 00 19 00 00 80 00   ERRORFRAME
>>     controller-problem{tx-error-passive}
>>     protocol-violation{{}{acknowledge-slot}}
>>     bus-error
>>     error-counter-tx-rx{{128}{0}}
>
> Here "tx-error-passiv" is packed with a bus error. What I'm looking for
> are state change messages similar to:
>
>    can0  20000204  [8] 00 08 00 00 00 00 60 00   ERRORFRAME
>         controller-problem{tx-error-warning}
>         state-change{tx-error-warning}
>         error-counter-tx-rx{{96}{0}}
>    can0  20000204  [8] 00 30 00 00 00 00 80 00   ERRORFRAME
>         controller-problem{tx-error-passive}
>         state-change{tx-error-passive}
>         error-counter-tx-rx{{128}{0}
>
> They should always come, even with "berr-reporting off".
>
>> write: No buffer space available
>> root@imx6qrom5420b1:~# ip -s -d link show can0
>> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>> mode DEFAULT group default qlen 10
>>     link/can  promiscuity 0
>>     can <BERR-REPORTING> state ERROR-PASSIVE (berr-counter tx 128 rx 0)
>> restart-ms 0
>>       bitrate 1000000 sample-point 0.750
>>       tq 62 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
>>       hi3110: tseg1 2..16 tseg2 2..8 sjw 1..4 brp 1..64 brp-inc 1
>>       clock 16000000
>>       re-started bus-errors arbit-lost error-warn error-pass bus-off
>>       0          6          0          1          1          0
>
> The error warning and passive counter increased , though. Also the bus
> error should come in at a rather hight rate. Looking to the code, maybe
> you need to test STATF to check for state changes (and not ERR).

Likely the ERR bits are only valid if the BUSERR bit in INTF is set.

>>     RX: bytes  packets  errors  dropped overrun mcast
>>     0          0        6       0       0       0
>>     TX: bytes  packets  errors  dropped carrier collsns
>>     106        18       0       0       0       0
>> root@imx6qrom5420b1:~#
>> /////re-connect cable
>>   can0  169   [8]  35 55 A3 1C 0F 47 2E 5B
>>   can0  318   [8]  11 AA 27 11 D2 1B CE 34
>>   can0  577   [8]  A0 A4 EE 50 8D A2 E1 3E
>>   can0  4ED   [8]  52 96 17 7E 31 FC 7D 7C
>>   can0  2E7   [8]  92 48 D4 39 05 1E 9F 50
>>   can0  200   [8]  4A 66 F6 02 1E 71 8E 26
>>   can0  29A   [8]  49 63 2E 7D C9 77 85 7A
>>   can0  15A   [7]  3C 0E 65 74 C3 62 80
>>   can0  011   [1]  D2
>>   can0  26B   [3]  FC D6 68
>>   can0  5CE   [8]  6F 02 B5 14 BC 7A D7 02
>>
>> root@imx6qrom5420b1:~# ip -s -d link show can0
>> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>> mode DEFAULT group default qlen 10
>>     link/can  promiscuity 0
>>     can <BERR-REPORTING> state ERROR-ACTIVE (berr-counter tx 117 rx 0)
>> restart-ms 0
>>       bitrate 1000000 sample-point 0.750
>>       tq 62 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
>>       hi3110: tseg1 2..16 tseg2 2..8 sjw 1..4 brp 1..64 brp-inc 1
>>       clock 16000000
>>       re-started bus-errors arbit-lost error-warn error-pass bus-off
>>       0          7          0          1          1          0
>>     RX: bytes  packets  errors  dropped overrun mcast
>>     0          0        7       0       0       0
>>     TX: bytes  packets  errors  dropped carrier collsns
>>     181        29       0       0       0       0
>>
>>
>> //Reboot the board and test with bus error reporting off
>>
>> root@imx6qrom5420b1:~# ip link set can0 up type can bitrate 1000000
>> berr-reporting off
>> root@imx6qrom5420b1:~# candump -e any,0:0,#FFFFFFF &
>> [1] 782
>> root@imx6qrom5420b1:~# cangen can0
>>   can0  1FA   [3]  C9 FE C2
>>   can0  3E2   [5]  85 37 03 5B 6F
>>   can0  289   [8]  A4 F6 BF 4A 3F 70 65 1B
>>   can0  12D   [8]  B2 72 10 33 AB B4 68 64
>>   can0  054   [2]  01 D7
>>   can0  4A6   [8]  29 7D 76 56 CA C1 60 00
>>   can0  768   [8]  97 3D 92 08 61 C1 D9 03
>>   can0  098   [6]  A4 A8 5A 60 92 1A
>>   can0  3C9   [8]  71 78 0D 25 AB 27 8B 51
>> /////disconnect cable
>> write: No buffer space available
>> root@imx6qrom5420b1:~# ip -s -d link show can0
>> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>> mode DEFAULT group default qlen 10
>>     link/can  promiscuity 0
>>     can state ERROR-ACTIVE (berr-counter tx 128 rx 0) restart-ms 0
>>       bitrate 1000000 sample-point 0.750
>>       tq 62 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
>>       hi3110: tseg1 2..16 tseg2 2..8 sjw 1..4 brp 1..64 brp-inc 1
>>       clock 16000000
>>       re-started bus-errors arbit-lost error-warn error-pass bus-off
>>       0          0          0          0          0          0
>>     RX: bytes  packets  errors  dropped overrun mcast
>>     0          0        0       0       0       0
>>     TX: bytes  packets  errors  dropped carrier collsns
>>     56         9        0       0       0       0
>> root@imx6qrom5420b1:~#
>> /////re-connect cable
>> can0  20000088   [8]  00 00 00 19 00 00 7F 00   ERRORFRAME
>>     protocol-violation{{}{acknowledge-slot}}
>>     bus-error
>>     error-counter-tx-rx{{127}{0}}
>>   can0  553   [6]  1A E4 60 6B DC 07
>>   can0  7E3   [8]  1C 78 95 6E 10 81 AA 40
>>   can0  20C   [8]  BB 35 13 25 60 0A 56 57
>>   can0  1D0   [8]  48 4A 39 64 76 E6 57 08
>>   can0  43A   [1]  40
>>   can0  2CF   [7]  03 45 5E 0F 67 33 4C
>>   can0  1CD   [8]  F9 4D AB 1D 96 A5 67 0E
>>   can0  515   [8]  41 CD F2 5F 68 92 43 16
>>   can0  661   [8]  45 9A 73 69 45 EE 8B 42
>>   can0  41B   [1]  55
>>   can0  52F   [1]  87
>
> After some more messages there should be also:
>
>     can0  20000200  [8] 00 40 00 00 00 00 5F 00   ERRORFRAME
>         state-change{back-to-error-active}
>         error-counter-tx-rx{{95}{0}}
>
> For each message sent, the error counter decreases by 8.
>
>
>>
>> root@imx6qrom5420b1:~# ip -s -d link show can0
>> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>> mode DEFAULT group default qlen 10
>>     link/can  promiscuity 0
>>     can state ERROR-ACTIVE (berr-counter tx 117 rx 0) restart-ms 0
>>       bitrate 1000000 sample-point 0.750
>>       tq 62 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
>>       hi3110: tseg1 2..16 tseg2 2..8 sjw 1..4 brp 1..64 brp-inc 1
>>       clock 16000000
>>       re-started bus-errors arbit-lost error-warn error-pass bus-off
>>       0          1          0          0          0          0
>
> Strange, some counters got lost.
>
>>     RX: bytes  packets  errors  dropped overrun mcast
>>     0          0        1       0       0       0
>>     TX: bytes  packets  errors  dropped carrier collsns
>>     120        20       0       0       0       0
>>
>>
>>> Also, any error message should show the bus error counts in data[7,8]:
>>>
>>> http://lxr.free-electrons.com/source/drivers/net/can/sja1000/sja1000.c#L408
>>>
>>>
>>
>> I can add this in v4 version of the patch (Above log has this patch
>> applied).
>
> Looks good.
>
>>> And please check bus-off as well (short-circuiting CAN low and high).
>>>
>>
>> I have not been able to check the bus-off condition by (short-circuiting
>> CAN low and high). The tec error count remains at 128 when I short the
>> CAN low and high pins and the status never goes BUSOFF.
>
> You also need to send a message and the short-circuit should be at the
> connector of the sending host. What tranceiver is used? Do you know?

You could try to set a different bit-rate on the other CAN controller. 
Then try to send or receive messages.

Wolfgang.
