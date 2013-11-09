From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Sat, 09 Nov 2013 04:02:27 +0300
Message-ID: <527D89A3.1070403@cogentembedded.com>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com> <524BB883.2040400@grandegger.com> <526061BE.7060204@cogentembedded.com> <52657CA1.2040708@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	mkl@pengutronix.de, linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52657CA1.2040708@grandegger.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/21/2013 11:12 PM, Wolfgang Grandegger wrote:

>>     Sorry for the belated reply -- was on vacations.

    And again sorry, couldn't get to this due to other things.

>>> thanks for your contribution. The patch looks already quite good. Before
>>> I find time for a detailed review could you please check error handling
>>> and bus-off recovery by reporting the output of "$ candump -td -e
>>> any,0:0,#FFFFFFFF" while sending messages to the device ...

[...]

>> root@10.0.0.101:/opt/can-utils# ip -details link show can0
>> 2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
>> qlen 10 link/can
>> can state ERROR-PASSIVE (berr-counter tx 128 rx 0) restart-ms 0
>> bitrate 297619 sample-point 0.714

> Strange, what bitrate did you configure?

    300000.

>> tq 480 prop-seg 2 phase-seg1 2 phase-seg2 2 sjw 1
>> rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
>> clock 49999999

> Could you please try if the algorithm works better with 50000000.

    It doesn't. Look at the logs below:

Bitrate setting:
----------------
actual:
300KHz
ip -details link show can0
2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
link/can
can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
bitrate 297619 sample-point 0.714
tq 480 prop-seg 2 phase-seg1 2 phase-seg2 2 sjw 1
rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
clock 49999999

500KHz:
ip -details link show can0
2: can0: <NOARP,ECHO> mtu 16 qdisc pfifo_fast state DOWN qlen 10
link/can
can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
bitrate 499999 sample-point 0.800
tq 200 prop-seg 3 phase-seg1 4 phase-seg2 2 sjw 1
rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
clock 49999999

700KHz:
ip -details link show can0
2: can0: <NOARP,ECHO> mtu 16 qdisc pfifo_fast state DOWN qlen 10
link/can
can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
bitrate 694444 sample-point 0.750
tq 180 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
clock 49999999

--------------
Forced:
priv->can.clock.freq = 50000000;
300KHz:
ip -details link show can0
2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
link/can
can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
bitrate 297619 sample-point 0.714
tq 480 prop-seg 2 phase-seg1 2 phase-seg2 2 sjw 1
rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
clock 50000000
root@10.0.0.101:/opt#

700KHz:
root@10.0.0.101:/opt# ip -details link show can0
2: can0: <NOARP,ECHO> mtu 16 qdisc pfifo_fast state DOWN qlen 10
link/can
can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
bitrate 694444 sample-point 0.750
tq 180 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
clock 50000000

>> root@10.0.0.101:/opt/can-utils#

>> dmesg:
>> rcar_can rcar_can.0 can0: bitrate error 0.7%
>> rcar_can rcar_can.0 can0: Error warning interrupt
>> rcar_can rcar_can.0 can0: Bus error interrupt:
>> rcar_can rcar_can.0 can0: ACK Error
>> rcar_can rcar_can.0 can0: Error passive interrupt

>>> 2. ... with short-circuited CAN high and low and doing some time later
>>>          a manual recovery with "ip link set can0 type can restart"

>>     Now we have auto recovery only. Manual recovery was tested with the
>> first driver version and worked.

> What do you mean with "auto recovery"? Auto recovery by the hardware or
> via "restart-ms <ms>"? How do you choose between "manual" and "auto"
> recovery?

    This exact test was done with hardware auto-recovery only. No "restart-ms" 
was programmed.

>> Terminal 1:

>> root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
>> root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
>> root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
>> root@10.0.0.104:/opt/can-utils#

>> Terminal 2:

>> root@10.0.0.104:/opt/can-utils# ./candump -td -e any,0:0,#FFFFFFFF
>> (000.000000) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
>> controller-problem{}
>> protocol-violation{{tx-dominant-bit-error}{}}
>> bus-error
>> (000.021147) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
>> controller-problem{}
>> bus-off
>> restarted-after-bus-off

> Why does it get "restarted" directly after the bus-off?

    Because we have hardware auto-recovery enabled.

>> (011.738522) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
>> controller-problem{}

> What controller problem? data[1] is not set for some reasom.

    Not comments. Looking into it.

>> protocol-violation{{tx-dominant-bit-error}{}}
>> bus-error
>> (000.021163) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
>> controller-problem{}
>> bus-off
>> restarted-after-bus-off
>> (001.666625) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
>> controller-problem{}
>> protocol-violation{{tx-dominant-bit-error}{}}
>> bus-error
>> (000.021157) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
>> controller-problem{}
>> bus-off
>> restarted-after-bus-off

>> dmesg:
>> rcar_can rcar_can.0 can0: Error warning interrupt
>> rcar_can rcar_can.0 can0: Error passive interrupt
>> rcar_can rcar_can.0 can0: Bus error interrupt:
>> rcar_can rcar_can.0 can0: Bit Error (dominant)
>> rcar_can rcar_can.0 can0: Error warning interrupt
>> rcar_can rcar_can.0 can0: Error passive interrupt

> Why are they reported again. You are already in error passive.

    Don't know. :-/

[...]

>>> I also wonder if the messages are always sent in order. You could use
>>> the program "canfdtest" [1] from the can-utils for validation.

>>     This program is PITA. With the driver workaroung it works:

> What workaround?

    Doesn't matter already, got rid of it.

> Wolfgang.

WBR, Sergei

