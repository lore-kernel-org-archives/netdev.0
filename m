From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Fri, 18 Oct 2013 02:16:30 +0400
Message-ID: <526061BE.7060204@cogentembedded.com>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com> <524BB883.2040400@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	mkl@pengutronix.de, linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <524BB883.2040400@grandegger.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/02/2013 10:09 AM, Wolfgang Grandegger wrote:

    Sorry for the belated reply -- was on vacations.

> thanks for your contribution. The patch looks already quite good. Before
> I find time for a detailed review could you please check error handling
> and bus-off recovery by reporting the output of "$ candump -td -e
> any,0:0,#FFFFFFFF" while sending messages to the device ...

> 1. ... without cable connected

Terminal 1:

root@10.0.0.101:/opt/can-utils# ./cangen -n 1 -g 1 can0
root@10.0.0.101:/opt/can-utils#

Terminal 2:

root@10.0.0.101:/opt/can-utils# ./candump -td -e any,0:0,#FFFFFFFF
(000.000000) can0 200000AC [8] 00 08 00 19 00 00 00 00 ERRORFRAME
controller-problem{tx-error-warning}
protocol-violation{{}{acknowledge-slot}}
no-acknowledgement-on-tx
bus-error
(000.004496) can0 20000004 [8] 00 20 00 00 00 00 00 00 ERRORFRAME
controller-problem{tx-error-passive}

So we get and stay in error- passive state:

root@10.0.0.101:/opt/can-utils# ip -details link show can0
2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 
10 link/can
can state ERROR-PASSIVE (berr-counter tx 128 rx 0) restart-ms 0
bitrate 297619 sample-point 0.714
tq 480 prop-seg 2 phase-seg1 2 phase-seg2 2 sjw 1
rcar_can: tseg1 4..16 tseg2 2..8 sjw 1..4 brp 1..1024 brp-inc 1
clock 49999999
root@10.0.0.101:/opt/can-utils#

dmesg:
rcar_can rcar_can.0 can0: bitrate error 0.7%
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Bus error interrupt:
rcar_can rcar_can.0 can0: ACK Error
rcar_can rcar_can.0 can0: Error passive interrupt

> 2. ... with short-circuited CAN high and low and doing some time later
>         a manual recovery with "ip link set can0 type can restart"

    Now we have auto recovery only. Manual recovery was tested with the first 
driver version and worked.

Terminal 1:

root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
root@10.0.0.104:/opt/can-utils#

Terminal 2:

root@10.0.0.104:/opt/can-utils# ./candump -td -e any,0:0,#FFFFFFFF
(000.000000) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
controller-problem{}
protocol-violation{{tx-dominant-bit-error}{}}
bus-error
(000.021147) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
controller-problem{}
bus-off
restarted-after-bus-off
(011.738522) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
controller-problem{}
protocol-violation{{tx-dominant-bit-error}{}}
bus-error
(000.021163) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
controller-problem{}
bus-off
restarted-after-bus-off
(001.666625) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
controller-problem{}
protocol-violation{{tx-dominant-bit-error}{}}
bus-error
(000.021157) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
controller-problem{}
bus-off
restarted-after-bus-off

dmesg:
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Error passive interrupt
rcar_can rcar_can.0 can0: Bus error interrupt:
rcar_can rcar_can.0 can0: Bit Error (dominant)
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Error passive interrupt
rcar_can rcar_can.0 can0: Bus-off entry interrupt
rcar_can rcar_can.0 can0: bus-off
rcar_can rcar_can.0 can0: Bus-off recovery interrupt
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Error passive interrupt
rcar_can rcar_can.0 can0: Bus error interrupt:
rcar_can rcar_can.0 can0: Bit Error (dominant)
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Error passive interrupt
rcar_can rcar_can.0 can0: Bus-off entry interrupt
rcar_can rcar_can.0 can0: bus-off
rcar_can rcar_can.0 can0: Bus-off recovery interrupt
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Error passive interrupt
rcar_can rcar_can.0 can0: Bus error interrupt:
rcar_can rcar_can.0 can0: Bit Error (dominant)
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Error passive interrupt
rcar_can rcar_can.0 can0: Bus-off entry interrupt
rcar_can rcar_can.0 can0: bus-off
rcar_can rcar_can.0 can0: Bus-off recovery interrupt

> I also wonder if the messages are always sent in order. You could use
> the program "canfdtest" [1] from the can-utils for validation.

    This program is PITA. With the driver workaroung it works:

FULL Duplex test:
on DUT:
root@10.0.0.104:/opt/can-utils# ./canfdtest -v can0
interface = can0, family = 29, type = 3, proto = 1
............................

root@am335x-evm:~# canconfig can0 bitrate 1000000
can0 bitrate: 1000000, sample-point: 0.750
root@am335x-evm:~# canconfig can0 start
[50164.566650] d_can d_can.1: can0: setting CAN BT = 0x2701
can0 state: ERROR-ACTIVE
root@am335x-evm:~# ./canfdtest -v -g can0
interface = can0, family = 29, type = 3, proto = 1
...............................................................................C
Test messages sent and received: 3826567
Exiting...

> Support for CAN_CTRLMODE_BERR_REPORTING would also be nice, especially
> if the bus errors reporting can easily be switched off (via interrupt mask).

   Done.

> There is also the RCAN-TL1 (Renesas CAN Time Trigger Level 1) module
> e.g. available on the SH7203 Group of processors. Is this CAN controller
> compatible to some extend with the R-Car CAN or a completely different
> implementation?

    No, not compatible.

> [1] https://gitorious.org/linux-can/can-utils/source/canfdtest.c

> Wolfgang.

WBR, Sergei

