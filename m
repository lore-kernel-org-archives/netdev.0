From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: About bittiming calculation result
Date: Mon, 07 Feb 2011 13:00:57 +0100
Message-ID: <4D4FDEF9.2030305@grandegger.com>
References: <cover.1296818921.git.segoon@openwall.com><a6800dc8b0daed78256f98f52844cbbb48f4a76d.1296818921.git.segoon@openwall.com><20110204124233.GB334@e-circ.dyndns.org>
	<20110204.130649.112613896.davem@davemloft.net>
	<5009516791F146C49C73FAC57C437313@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <5009516791F146C49C73FAC57C437313-c0cKtqp5df7I9507bXv2FdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tomoya,

On 02/07/2011 12:38 PM, Tomoya MORINAGA wrote:
> Hi,
> 
> I have a question for bittiming-value calculated by Can-core.
> 
> In case setting like below,
>  - ip link set can0 type can bitrate 800000
>  - clock=50MHz
>  - Use pch_can
> 
> Can-core calculates like below
> brp=21
> seg1=1
> seg2=1
> sjw=1
> prop_seg=0
> 
> Is "prop_seg=0" true ?

Well, only prop_seg+phase_seg=tseg1 is relevant and the pch_can driver
sets the allowed minimum "tseg1_min1" currently to 1:

static struct can_bittiming_const pch_can_bittiming_const = {
        .name = KBUILD_MODNAME,
        .tseg1_min = 1,
        .tseg1_max = 16,
        .tseg2_min = 1,
        .tseg2_max = 8,
        .sjw_max = 4,
        .brp_min = 1,
        .brp_max = 1024, /* 6bit + extended 4bit */
        .brp_inc = 1,
};

> seg1/seg2/sjw/prop_seg must be more than 1 ?

Then "tseg1_min" should be set to *2*.

> Also I can see the following kernel error log.
> bitrate error 0.7%

A clock frequency of 50 MHz is sub-optimal for CAN and some
bit-rates cannot be reproduced properly. Here is the output of
the can-utils program "can-calc-bit-timing" (with an entry for
the pch-can added):

$ ./can-calc-bit-timing pch-can
Bit timing parameters for pch-can with 50.000000 MHz ref clock
nominal                                 real Bitrt   nom  real SampP
Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP Error CNF1 CNF2 CNF3
1000000    100   3    3    3   1   5 1000000  0.0% 75.0% 70.0%  6.7% 0x05 0x92 0x02
 800000    420   0    1    1   1  21  793650  0.8% 80.0% 66.6% 16.8% 0x15 0xff 0x00
 500000    100   8    8    3   1   5  500000  0.0% 87.5% 85.0%  2.9% 0x05 0xbf 0x02
 250000    500   3    3    1   1  25  250000  0.0% 87.5% 87.5%  0.0% 0x19 0x92 0x00
 125000    500   6    7    2   1  25  125000  0.0% 87.5% 87.5%  0.0% 0x19 0xb5 0x01
 100000    500   8    8    3   1  25  100000  0.0% 87.5% 85.0%  2.9% 0x19 0xbf 0x02
  50000   2500   3    3    1   1 125   50000  0.0% 87.5% 87.5%  0.0% 0x7d 0x92 0x00
  20000   2500   8    8    3   1 125   20000  0.0% 87.5% 85.0%  2.9% 0x7d 0xbf 0x02
  10000  12500   3    3    1   1 625   10000  0.0% 87.5% 87.5%  0.0% 0x71 0x92 0x00

As you can see, especially 800000 gives rather bad results.

Wolfgang.
