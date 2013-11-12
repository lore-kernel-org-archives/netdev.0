From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Wed, 13 Nov 2013 00:45:32 +0300
Message-ID: <5282A17C.1030309@cogentembedded.com>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com> <524BB883.2040400@grandegger.com> <526061BE.7060204@cogentembedded.com> <52657CA1.2040708@grandegger.com> <527D89A3.1070403@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	mkl@pengutronix.de, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <527D89A3.1070403@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/09/2013 04:02 AM, Sergei Shtylyov wrote:

>>>> 2. ... with short-circuited CAN high and low and doing some time later
>>>>          a manual recovery with "ip link set can0 type can restart"

>>>     Now we have auto recovery only. Manual recovery was tested with the
>>> first driver version and worked.

>> What do you mean with "auto recovery"? Auto recovery by the hardware or
>> via "restart-ms <ms>"? How do you choose between "manual" and "auto"
>> recovery?

>     This exact test was done with hardware auto-recovery only. No "restart-ms"
> was programmed.

>>> Terminal 1:

>>> root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
>>> root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
>>> root@10.0.0.104:/opt/can-utils# ./cangen -n 1 -g 1 can0
>>> root@10.0.0.104:/opt/can-utils#

>>> Terminal 2:

>>> root@10.0.0.104:/opt/can-utils# ./candump -td -e any,0:0,#FFFFFFFF
>>> (000.000000) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
>>> controller-problem{}
>>> protocol-violation{{tx-dominant-bit-error}{}}
>>> bus-error
>>> (000.021147) can0 20000144 [8] 00 00 00 00 00 00 00 00 ERRORFRAME
>>> controller-problem{}
>>> bus-off
>>> restarted-after-bus-off

>> Why does it get "restarted" directly after the bus-off?

>     Because we have hardware auto-recovery enabled.

>>> (011.738522) can0 2000008C [8] 00 00 08 00 00 00 00 00 ERRORFRAME
>>> controller-problem{}

>> What controller problem? data[1] is not set for some reasom.

>     Not comments. Looking into it.

    Sorry, this has been fixed a while ago. Now the log looks like:

root@10.0.0.104:/opt/can-utils#  ./candump -td -e any,0:0,#FFFFFFFF
  (000.000000)  can0  2000008C   [8]  00 28 08 00 00 00 88 00 ERRORFRAME
         controller-problem{tx-error-warning,tx-error-passive}
         protocol-violation{{tx-dominant-bit-error}{}}
         bus-error
         error-counter-tx-rx{{136}{0}}
  (000.007578)  can0  20000040   [8]  00 00 00 00 00 00 00 00 ERRORFRAME
         bus-off
  (000.091847)  can0  20000100   [8]  00 00 00 00 00 00 00 00 ERRORFRAME
         restarted-after-bus-off
  (056.136722)  can0  2000008C   [8]  00 28 08 00 00 00 88 00 ERRORFRAME
         controller-problem{tx-error-warning,tx-error-passive}
         protocol-violation{{tx-dominant-bit-error}{}}
         bus-error
         error-counter-tx-rx{{136}{0}}

>>> dmesg:
>>> rcar_can rcar_can.0 can0: Error warning interrupt
>>> rcar_can rcar_can.0 can0: Error passive interrupt
>>> rcar_can rcar_can.0 can0: Bus error interrupt:
>>> rcar_can rcar_can.0 can0: Bit Error (dominant)
>>> rcar_can rcar_can.0 can0: Error warning interrupt
>>> rcar_can rcar_can.0 can0: Error passive interrupt

>> Why are they reported again. You are already in error passive.

>     Don't know. :-/

    This also has been dealt with. Here's an example:

rcar_can rcar_can.0 can0: Bus error interrupt:
rcar_can rcar_can.0 can0: ACK Error
rcar_can rcar_can.0 can0: Error warning interrupt
rcar_can rcar_can.0 can0: Bus error interrupt:
rcar_can rcar_can.0 can0: ACK Error
rcar_can rcar_can.0 can0: Error passive interrupt

WBR, Sergei

