From: realmz paranoid <realmz6@gmail.com>
Subject: Re: [PATCH] socket-can: bit-timing calculation
Date: Wed, 18 Jan 2012 12:45:23 +0800
Message-ID: <CAMk6uBkrjaXUrGD69-Wg0QLHR8AmShyxUAFQgOZcOLi1aD-7CA@mail.gmail.com>
References: <1326711025-6629-1-git-send-email-realmz6@gmail.com>
	<4F1538F1.8020508@grandegger.com>
	<CAMk6uBnoQwuo2LwcSD4hucn9bM9vqEVNEM3L9PLqmX-BgD30iA@mail.gmail.com>
	<4F153F16.8060603@grandegger.com>
	<CAMk6uBn87VjAJPPXUSG6G6_21Ov1tT6k=NkENm+9ZhRnsXNExQ@mail.gmail.com>
	<4F154A3C.3010502@grandegger.com>
	<CAMk6uBmJ5DqE3BDtZQBpfbp0s7pC=j0JuVzgbxCPh-jWA76Ofw@mail.gmail.com>
	<4F154CB1.4090307@pengutronix.de>
	<4F1586E0.1060308@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F1586E0.1060308@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Tue, Jan 17, 2012 at 10:34 PM, Marc Kleine-Budde <mkl@pengutronix.de=
> wrote:
> Hello,
>
> Realmz Paranoid, a hint from David Miller:
>> Nobody is seeing any of your postings because of "open list: NETWORK=
ING
>> DRIVERS" stuff in the email headers.
>
> On 01/17/2012 11:25 AM, Marc Kleine-Budde wrote:
>> On 01/17/2012 11:18 AM, realmz paranoid wrote:
>> [...]
>>
>>>>>> This is worse because it does not find the best match. The first
>>>>>> match might not be the best.
>>>>>>
>>>>>> I got it, because the tseg1_max and tseg2_max limit, the first f=
ound
>>>> best
>>>>> error will not get the best sample point on some hardware.
>>>>> So I'd tweak the blackfin can code.
>>>>
>>>> The algorithm does *not* work well for all configs, especially whe=
n the
>>>> clock frequency is not a multiple of 8 MHz. Instead of tweaking th=
e
>>>> algorithm just for your hardware it does make more sense to provid=
e the
>>>> parameters manually using "tq=3D ...". Also setting "sjw > 1" help=
s if the
>>>> bit-timing is not optimal.
>>
>> I've an improved version (somewhere) that minimizes sample point err=
or,
>> too. Give me some minutes to find it.
>
> Here it is. Wolfgang wrote the can-calc-bit-timing tool, which he use=
d to generate
> the table in the other mail. It's part of can-utils. I've pushed my i=
mprovement
> to my repo (better-bitrate-calculation branch):
>
> https://gitorious.org/~bet-frogger/linux-can/mkl-can-utils
>
> Here's the patch:
>
> From 4df04420f128ec326e536fe55fc819b893a5c9ef Mon Sep 17 00:00:00 200=
1
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Sat, 15 May 2010 18:26:03 +0200
> Subject: [PATCH] can-calc-bit-timing: better sample point calculation
>
> This patch tries to optimize the calculation of the sample point. To
> understand what it does have a look at the original implementation.
>
> If there is a combination of timing parameters where both the bitrate
> and sample point error are 0 the current implementation has a pretty
> good change of finding it (maybe it will always do, but I'm to lazy
> to proof this).
>
> However if the reference clock doesn't allow an optimal bitrate (this
> means =C2=A0the bitrate error is always !=3D 0) there might be severa=
l timing
> parameter combinations having the same bitrate error. The original
> implementation will allways choose the one with the highest brp. The
> actual sample point error isn't taken into account.
>
> This patch changes the algorithm to minimize the sample point error,
> too. Now a brp/tseg combination is accepted as better if one of these
> condition are fulfilled:
> 1) the bit rate error must be smaller, or
> 2) the bit rate error must be equal and
> =C2=A0 the sample point error must be equal or smaller
>
> If a smaller bit rate error is found the sample point error is reset.
> This ensures that we first optimize for small bit rate error and then
> for small sample point errors.
>
> The following diff shows the sample point error improvements.
>
> --- orig.txt =C2=A0 =C2=A02010-05-17 00:10:21.000000000 +0200
> +++ new.txt =C2=A0 =C2=A0 2010-05-17 00:10:05.000000000 +0200
> @@ -27,9 +27,9 @@
> =C2=A0Bit timing parameters for mscan with 33.000000 MHz ref clock
> =C2=A0nominal =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 real Bitrt =C2=
=A0 nom =C2=A0real SampP
> =C2=A0Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP =
Error BTR0 BTR1
> =C2=A01000000 =C2=A0 =C2=A0 90 =C2=A0 3 =C2=A0 =C2=A04 =C2=A0 =C2=A03=
 =C2=A0 1 =C2=A0 3 1000000 =C2=A00.0% 75.0% 72.7% =C2=A03.1% 0x02 0x26
> - 800000 =C2=A0 =C2=A0181 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A0 6 =C2=A0785714 =C2=A01.8% 80.0% 71.4% 10.8% 0x05 0x13
> + 800000 =C2=A0 =C2=A0 90 =C2=A0 5 =C2=A0 =C2=A05 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 3 =C2=A0785714 =C2=A01.8% 80.0% 78.5% =C2=A01.9% 0x02 0x29
> =C2=A0500000 =C2=A0 =C2=A0181 =C2=A0 4 =C2=A0 =C2=A04 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A0 6 =C2=A0500000 =C2=A00.0% 87.5% 81.8% =C2=A06.5% 0x05 0=
x17
> =C2=A0250000 =C2=A0 =C2=A0333 =C2=A0 4 =C2=A0 =C2=A05 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A011 =C2=A0250000 =C2=A00.0% 87.5% 83.3% =C2=A04.8% 0x0a 0=
x18
> =C2=A0125000 =C2=A0 =C2=A0666 =C2=A0 4 =C2=A0 =C2=A05 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A022 =C2=A0125000 =C2=A00.0% 87.5% 83.3% =C2=A04.8% 0x15 0=
x18
> =C2=A0100000 =C2=A0 =C2=A0666 =C2=A0 6 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A022 =C2=A0100000 =C2=A00.0% 87.5% 86.6% =C2=A01.0% 0x15 0=
x1b
> @@ -40,12 +40,12 @@
> =C2=A0Bit timing parameters for mscan with 33.300000 MHz ref clock
> =C2=A0nominal =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 real Bitrt =C2=
=A0 nom =C2=A0real SampP
> =C2=A0Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP =
Error BTR0 BTR1
> =C2=A01000000 =C2=A0 =C2=A0 90 =C2=A0 3 =C2=A0 =C2=A04 =C2=A0 =C2=A03=
 =C2=A0 1 =C2=A0 3 1009090 =C2=A00.9% 75.0% 72.7% =C2=A03.1% 0x02 0x26
> - 800000 =C2=A0 =C2=A0180 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A0 6 =C2=A0792857 =C2=A00.9% 80.0% 71.4% 10.8% 0x05 0x13
> + 800000 =C2=A0 =C2=A0 90 =C2=A0 5 =C2=A0 =C2=A05 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 3 =C2=A0792857 =C2=A00.9% 80.0% 78.5% =C2=A01.9% 0x02 0x29
> =C2=A0500000 =C2=A0 =C2=A0180 =C2=A0 4 =C2=A0 =C2=A04 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A0 6 =C2=A0504545 =C2=A00.9% 87.5% 81.8% =C2=A06.5% 0x05 0=
x17
> - 250000 =C2=A0 =C2=A0570 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A019 =C2=A0250375 =C2=A00.1% 87.5% 71.4% 18.4% 0x12 0x13
> - 125000 =C2=A0 1141 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0 1 =
=C2=A038 =C2=A0125187 =C2=A00.1% 87.5% 71.4% 18.4% 0x25 0x13
> + 250000 =C2=A0 =C2=A0210 =C2=A0 7 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 7 =C2=A0250375 =C2=A00.1% 87.5% 84.2% =C2=A03.8% 0x06 0x2e
> + 125000 =C2=A0 =C2=A0570 =C2=A0 5 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A019 =C2=A0125187 =C2=A00.1% 87.5% 85.7% =C2=A02.1% 0x12 0x1a
> =C2=A0100000 =C2=A0 1111 =C2=A0 3 =C2=A0 =C2=A03 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A037 =C2=A0100000 =C2=A00.0% 87.5% 77.7% 11.2% 0x24 0x15
> =C2=A0 50000 =C2=A0 1111 =C2=A0 7 =C2=A0 =C2=A07 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A037 =C2=A0 50000 =C2=A00.0% 87.5% 83.3% =C2=A04.8% 0x24 0x2d
> =C2=A0 20000 ***bitrate not possible***
> =C2=A0 10000 ***bitrate not possible***
> @@ -53,12 +53,12 @@
> =C2=A0Bit timing parameters for mscan with 33.333333 MHz ref clock
> =C2=A0nominal =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 real Bitrt =C2=
=A0 nom =C2=A0real SampP
> =C2=A0Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP =
Error BTR0 BTR1
> =C2=A01000000 =C2=A0 =C2=A0 90 =C2=A0 3 =C2=A0 =C2=A04 =C2=A0 =C2=A03=
 =C2=A0 1 =C2=A0 3 1010101 =C2=A01.0% 75.0% 72.7% =C2=A03.1% 0x02 0x26
> - 800000 =C2=A0 =C2=A0180 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A0 6 =C2=A0793650 =C2=A00.8% 80.0% 71.4% 10.8% 0x05 0x13
> + 800000 =C2=A0 =C2=A0 90 =C2=A0 5 =C2=A0 =C2=A05 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 3 =C2=A0793650 =C2=A00.8% 80.0% 78.5% =C2=A01.9% 0x02 0x29
> =C2=A0500000 =C2=A0 =C2=A0180 =C2=A0 4 =C2=A0 =C2=A04 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A0 6 =C2=A0505050 =C2=A01.0% 87.5% 81.8% =C2=A06.5% 0x05 0=
x17
> - 250000 =C2=A0 =C2=A0570 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A019 =C2=A0250626 =C2=A00.3% 87.5% 71.4% 18.4% 0x12 0x13
> - 125000 =C2=A0 1140 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0 1 =
=C2=A038 =C2=A0125313 =C2=A00.3% 87.5% 71.4% 18.4% 0x25 0x13
> + 250000 =C2=A0 =C2=A0210 =C2=A0 7 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 7 =C2=A0250626 =C2=A00.3% 87.5% 84.2% =C2=A03.8% 0x06 0x2e
> + 125000 =C2=A0 =C2=A0570 =C2=A0 5 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A019 =C2=A0125313 =C2=A00.3% 87.5% 85.7% =C2=A02.1% 0x12 0x1a
> =C2=A0100000 =C2=A0 1110 =C2=A0 3 =C2=A0 =C2=A03 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A037 =C2=A0100100 =C2=A00.1% 87.5% 77.7% 11.2% 0x24 0x15
> =C2=A0 50000 =C2=A0 =C2=A0870 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A06 =
=C2=A0 1 =C2=A029 =C2=A0 49975 =C2=A00.1% 87.5% 73.9% 15.5% 0x1c 0x5f
> =C2=A0 20000 ***bitrate not possible***
> =C2=A0 10000 ***bitrate not possible***
> @@ -78,12 +78,12 @@
>
> =C2=A0Bit timing parameters for at91 with 99.532800 MHz ref clock
> =C2=A0nominal =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 real Bitrt =C2=
=A0 nom =C2=A0real SampP
> =C2=A0Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP =
Error =C2=A0 =C2=A0 CAN_BR
> -1000000 =C2=A0 =C2=A0100 =C2=A0 3 =C2=A0 =C2=A03 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A010 =C2=A0995328 =C2=A00.5% 75.0% 70.0% =C2=A06.7% 0x00090222
> +1000000 =C2=A0 =C2=A0 50 =C2=A0 7 =C2=A0 =C2=A07 =C2=A0 =C2=A05 =C2=A0=
 1 =C2=A0 5 =C2=A0995328 =C2=A00.5% 75.0% 75.0% =C2=A00.0% 0x00040664
> =C2=A0800000 =C2=A0 =C2=A0 50 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A08 =
=C2=A0 1 =C2=A0 5 =C2=A0796262 =C2=A00.5% 80.0% 68.0% 15.0% 0x00040777
> - 500000 =C2=A0 =C2=A0251 =C2=A0 2 =C2=A0 =C2=A03 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A025 =C2=A0497664 =C2=A00.5% 87.5% 75.0% 14.3% 0x00180121
> - 250000 =C2=A0 =C2=A0572 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A057 =C2=A0249455 =C2=A00.2% 87.5% 71.4% 18.4% 0x00380111
> + 500000 =C2=A0 =C2=A0100 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A010 =C2=A0497664 =C2=A00.5% 87.5% 85.0% =C2=A02.9% 0x00090772
> + 250000 =C2=A0 =C2=A0210 =C2=A0 7 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A021 =C2=A0249455 =C2=A00.2% 87.5% 84.2% =C2=A03.8% 0x00140672
> =C2=A0125000 =C2=A0 =C2=A0532 =C2=A0 6 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A053 =C2=A0125198 =C2=A00.2% 87.5% 86.6% =C2=A01.0% 0x0034=
0551
> =C2=A0100000 =C2=A0 =C2=A0833 =C2=A0 4 =C2=A0 =C2=A05 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A083 =C2=A0 99932 =C2=A00.1% 87.5% 83.3% =C2=A04.8% 0x0052=
0341
> =C2=A0 50000 =C2=A0 =C2=A0833 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A07 =
=C2=A0 1 =C2=A083 =C2=A0 49966 =C2=A00.1% 87.5% 70.8% 19.1% 0x00520776
> =C2=A0 20000 ***bitrate not possible***
> @@ -92,22 +92,22 @@
> =C2=A0Bit timing parameters for flexcan with 49.875000 MHz ref clock
> =C2=A0nominal =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 real Bitrt =C2=
=A0 nom =C2=A0real SampP
> =C2=A0Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP =
Error =C2=A0 CAN_CTRL
> =C2=A01000000 =C2=A0 =C2=A0100 =C2=A0 3 =C2=A0 =C2=A03 =C2=A0 =C2=A03=
 =C2=A0 1 =C2=A0 5 =C2=A0997500 =C2=A00.2% 75.0% 70.0% =C2=A06.7% 0x041=
20002
> - 800000 =C2=A0 =C2=A0180 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A0 9 =C2=A0791666 =C2=A01.0% 80.0% 71.4% 10.8% 0x08090001
> - 500000 =C2=A0 =C2=A0200 =C2=A0 3 =C2=A0 =C2=A04 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A010 =C2=A0498750 =C2=A00.2% 87.5% 80.0% =C2=A08.6% 0x09190002
> - 250000 =C2=A0 =C2=A0501 =C2=A0 2 =C2=A0 =C2=A03 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A025 =C2=A0249375 =C2=A00.2% 87.5% 75.0% 14.3% 0x18110001
> + 800000 =C2=A0 =C2=A0140 =C2=A0 3 =C2=A0 =C2=A03 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A0 7 =C2=A0791666 =C2=A01.0% 80.0% 77.7% =C2=A02.9% 0x06110002
> + 500000 =C2=A0 =C2=A0100 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 5 =C2=A0498750 =C2=A00.2% 87.5% 85.0% =C2=A02.9% 0x043a0007
> + 250000 =C2=A0 =C2=A0200 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A010 =C2=A0249375 =C2=A00.2% 87.5% 85.0% =C2=A02.9% 0x093a0007
> =C2=A0125000 =C2=A0 =C2=A0421 =C2=A0 7 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =
=C2=A0 1 =C2=A021 =C2=A0125000 =C2=A00.0% 87.5% 84.2% =C2=A03.8% 0x143a=
0006
> - 100000 =C2=A0 1002 =C2=A0 3 =C2=A0 =C2=A04 =C2=A0 =C2=A02 =C2=A0 1 =
=C2=A050 =C2=A0 99750 =C2=A00.2% 87.5% 80.0% =C2=A08.6% 0x31190002
> + 100000 =C2=A0 =C2=A0501 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A025 =C2=A0 99750 =C2=A00.2% 87.5% 85.0% =C2=A02.9% 0x183a0007
> =C2=A0 50000 =C2=A0 1664 =C2=A0 4 =C2=A0 =C2=A05 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A083 =C2=A0 50075 =C2=A00.1% 87.5% 83.3% =C2=A04.8% 0x52210003
> =C2=A0 20000 =C2=A0 3568 =C2=A0 5 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =C2=A0=
 1 178 =C2=A0 20014 =C2=A00.1% 87.5% 85.7% =C2=A02.1% 0xb1290004
> =C2=A0 10000 =C2=A0 4350 =C2=A0 8 =C2=A0 =C2=A08 =C2=A0 =C2=A06 =C2=A0=
 1 217 =C2=A0 =C2=A09992 =C2=A00.1% 87.5% 73.9% 15.5% 0xd83d0007
>
> =C2=A0Bit timing parameters for flexcan with 66.500000 MHz ref clock
> =C2=A0nominal =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 real Bitrt =C2=
=A0 nom =C2=A0real SampP
> =C2=A0Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP =
Error =C2=A0 CAN_CTRL
> =C2=A01000000 =C2=A0 =C2=A0 90 =C2=A0 3 =C2=A0 =C2=A04 =C2=A0 =C2=A03=
 =C2=A0 1 =C2=A0 6 1007575 =C2=A00.8% 75.0% 72.7% =C2=A03.1% 0x051a0002
> - 800000 =C2=A0 =C2=A0180 =C2=A0 2 =C2=A0 =C2=A02 =C2=A0 =C2=A02 =C2=A0=
 1 =C2=A012 =C2=A0791666 =C2=A01.0% 80.0% 71.4% 10.8% 0x0b090001
> + 800000 =C2=A0 =C2=A0 90 =C2=A0 5 =C2=A0 =C2=A05 =C2=A0 =C2=A03 =C2=A0=
 1 =C2=A0 6 =C2=A0791666 =C2=A01.0% 80.0% 78.5% =C2=A01.9% 0x05220004
> =C2=A0500000 =C2=A0 =C2=A0105 =C2=A0 7 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =
=C2=A0 1 =C2=A0 7 =C2=A0500000 =C2=A00.0% 87.5% 84.2% =C2=A03.8% 0x063a=
0006
> =C2=A0250000 =C2=A0 =C2=A0285 =C2=A0 5 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A019 =C2=A0250000 =C2=A00.0% 87.5% 85.7% =C2=A02.1% 0x1229=
0004
> =C2=A0125000 =C2=A0 =C2=A0571 =C2=A0 5 =C2=A0 =C2=A06 =C2=A0 =C2=A02 =
=C2=A0 1 =C2=A038 =C2=A0125000 =C2=A00.0% 87.5% 85.7% =C2=A02.1% 0x2529=
0004
> =C2=A0100000 =C2=A0 =C2=A0526 =C2=A0 7 =C2=A0 =C2=A08 =C2=A0 =C2=A03 =
=C2=A0 1 =C2=A035 =C2=A0100000 =C2=A00.0% 87.5% 84.2% =C2=A03.8% 0x223a=
0006
>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
> =C2=A0can-calc-bit-timing.c | =C2=A0 71 +++++++++++++++++++++++++++--=
--------------------
> =C2=A01 files changed, 39 insertions(+), 32 deletions(-)
>
> diff --git a/can-calc-bit-timing.c b/can-calc-bit-timing.c
> index f8c04ba..27bf41d 100644
> --- a/can-calc-bit-timing.c
> +++ b/can-calc-bit-timing.c
> @@ -1,6 +1,7 @@
> =C2=A0/* can-calc-bit-timing.c: Calculate CAN bit timing parameters
> =C2=A0*
> =C2=A0* Copyright (C) 2008 Wolfgang Grandegger <wg@grandegger.com>
> + * Copyright (C) 2010 Marc Kleine-Budde <mkl@pengutronix.de>
> =C2=A0*
> =C2=A0* Derived from:
> =C2=A0* =C2=A0 can_baud.c - CAN baudrate calculation
> @@ -372,18 +373,17 @@ static long common_bitrates[] =3D {
> =C2=A0#define CAN_CALC_MAX_ERROR 50 /* in one-tenth of a percent */
> =C2=A0static int can_update_spt(const struct can_bittiming_const *btc=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 int sampl_pt, int tseg, int *tseg1, int *tseg2)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int sampl=
_pt, unsigned int tseg,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int *tseg=
1, unsigned int *tseg2)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*tseg2 =3D tseg + 1 - (sampl_pt * (tseg + =
1)) / 1000;
> - =C2=A0 =C2=A0 =C2=A0 if (*tseg2 < btc->tseg2_min)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *tseg2 =3D btc->ts=
eg2_min;
> - =C2=A0 =C2=A0 =C2=A0 if (*tseg2 > btc->tseg2_max)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *tseg2 =3D btc->ts=
eg2_max;
> + =C2=A0 =C2=A0 =C2=A0 *tseg2 =3D clamp(*tseg2, btc->tseg2_min, btc->=
tseg2_max);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*tseg1 =3D tseg - *tseg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (*tseg1 > btc->tseg1_max) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*tseg1 =3D btc=
->tseg1_max;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*tseg2 =3D tse=
g - *tseg1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1000 * (tseg + 1 - *tseg2) / (tseg =
+ 1);
> =C2=A0}
> =C2=A0@@ -391,11 +391,15 @@ static int can_calc_bittiming(struct net_=
device *dev, struct can_bittiming *bt)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct can_priv *priv =3D netdev_priv(dev)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct can_bittiming_const *btc =3D =
priv->bittiming_const;
> - =C2=A0 =C2=A0 =C2=A0 long rate, best_rate =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 long best_error =3D 1000000000, error =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 int best_tseg =3D 0, best_brp =3D 0, brp =3D 0=
;
> - =C2=A0 =C2=A0 =C2=A0 int tsegall, tseg =3D 0, tseg1 =3D 0, tseg2 =3D=
 0;
> - =C2=A0 =C2=A0 =C2=A0 int spt_error =3D 1000, spt =3D 0, sampl_pt;
> + =C2=A0 =C2=A0 =C2=A0 long rate; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/* current bitrate */
> + =C2=A0 =C2=A0 =C2=A0 long rate_error; =C2=A0 =C2=A0 =C2=A0 =C2=A0/*=
 difference between current and target value */
> + =C2=A0 =C2=A0 =C2=A0 long best_rate_error =3D 1000000000;
> + =C2=A0 =C2=A0 =C2=A0 int spt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0/* current sample point in thousandth */
> + =C2=A0 =C2=A0 =C2=A0 int spt_error; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* difference between current and target value */
> + =C2=A0 =C2=A0 =C2=A0 int best_spt_error =3D 1000;
> + =C2=A0 =C2=A0 =C2=A0 int sampl_pt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 /* target sample point */
> + =C2=A0 =C2=A0 =C2=A0 int best_tseg =3D 0, best_brp =3D 0; =C2=A0 =C2=
=A0 =C2=A0 =C2=A0/* current best values for tseg and brp */
> + =C2=A0 =C2=A0 =C2=A0 unsigned int brp, tsegall, tseg, tseg1, tseg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64 v64;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!priv->bittiming_const)
> @@ -417,48 +421,51 @@ static int can_calc_bittiming(struct net_device=
 *dev, struct can_bittiming *bt)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (tseg =3D (btc->tseg1_max + btc->tseg2=
_max) * 2 + 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tseg >=3D (btc->tseg1_min +=
 btc->tseg2_min) * 2; tseg--) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tsegall =3D 1 =
+ tseg / 2;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Compute all=
 possible tseg choices (tseg=3Dtseg1+tseg2) */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0brp =3D priv->=
clock.freq / (tsegall * bt->bitrate) + tseg % 2;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* chose brp s=
tep which is possible in system */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0brp =3D (brp /=
 btc->brp_inc) * btc->brp_inc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((brp < btc=
->brp_min) || (brp > btc->brp_max))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rate =3D priv-=
>clock.freq / (brp * tsegall);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D bt->bitr=
ate - rate;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rate_error =3D abs=
((long)(bt->bitrate - rate));
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* tseg brp bi=
terror */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 error =3D -error;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error > best_e=
rror)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rate_error > b=
est_rate_error)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0continue;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 best_error =3D err=
or;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error =3D=3D 0=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 spt =3D can_update_spt(btc, sampl_pt, tseg / 2,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0&tseg1, &tseg2);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 error =3D sampl_pt - spt;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (error < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D -error;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (error > spt_error)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 spt_error =3D error;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* reset sample po=
int error if we have a better bitrate */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rate_error < b=
est_rate_error)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 best_spt_error =3D 1000;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spt =3D can_update=
_spt(btc, sampl_pt, tseg / 2, &tseg1, &tseg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spt_error =3D abs(=
(long)(sampl_pt - spt));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (spt_error > be=
st_spt_error)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 continue;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 best_spt_error =3D=
 spt_error;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 best_rate_error =3D=
 rate_error;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0best_tseg =3D =
tseg / 2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0best_brp =3D b=
rp;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 best_rate =3D rate=
;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error =3D=3D 0=
)
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rate_error =3D=
=3D 0 && spt_error =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0- =C2=A0 =C2=A0 =C2=A0if (best_error) {
> + =C2=A0 =C2=A0 =C2=A0 if (best_rate_error) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Error in on=
e-tenth of a percent */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D (best_er=
ror * 1000) / bt->bitrate;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error > CAN_CA=
LC_MAX_ERROR) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rate_error =3D (be=
st_rate_error * 1000) / bt->bitrate;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rate_error > C=
AN_CALC_MAX_ERROR) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0dev_err(dev->dev.parent,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"bitrate error %ld.%ld%% too =
high\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error / 10, error % 10);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rate_error / 10, rate_error % 10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return -EDOM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0dev_warn(dev->dev.parent, "bitrate error %ld.%ld%%\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error / 10, error % 10);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rate_error / 10, rate_error %=
 10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0-- 1.7.4.1
>

I added bfin-can to can-calc-bit-timing.c and tried with your
better-bitrate-calculation branch, it did improve the sample error.
Thank you.

Here's the result:

Bit timing parameters for bfin-can with 131.250000 MHz ref clock
nominal                                 real Bitrt   nom  real SampP
 Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP Error  =
 CAN_CTRL
 1000000    251   1    1    1   1  33  994318  0.6% 75.0% 75.0%  0.0%
clock 0x00000020 timing 0x00000001
  800000    312   1    1    1   1  41  800304  0.0% 80.0% 75.0%  6.2%
clock 0x00000028 timing 0x00000001
- 500000    502   1    1    1   1  66  497159  0.6% 87.5% 75.0% 14.3%
clock 0x00000041 timing 0x00000001
+ 500000    251   3    3    1   1  33  497159  0.6% 87.5% 87.5%  0.0%
clock 0x00000020 timing 0x00000005
  250000    266   6    6    2   1  35  250000  0.0% 87.5% 86.6%  1.0%
clock 0x00000022 timing 0x0000001b
  125000    533   6    6    2   1  70  125000  0.0% 87.5% 86.6%  1.0%
clock 0x00000045 timing 0x0000001b
- 100000   2499   1    1    1   1 328  100038  0.0% 87.5% 75.0% 14.3%
clock 0x00000147 timing 0x00000001
+ 100000   1249   3    3    1   1 164  100038  0.0% 87.5% 87.5%  0.0%
clock 0x000000a3 timing 0x00000005
   50000   1333   6    6    2   1 175   50000  0.0% 87.5% 86.6%  1.0%
clock 0x000000ae timing 0x0000001b
   20000   2940   6    7    3   1 386   20001  0.0% 87.5% 82.3%  5.9%
clock 0x00000181 timing 0x0000002c
   10000   6666   6    6    2   1 875   10000  0.0% 87.5% 86.6%  1.0%
clock 0x0000036a timing 0x0000001b
@@ -15,7 +15,7 @@
Bit timing parameters for bfin-can with 125.000000 MHz ref clock
 nominal                                 real Bitrt   nom  real SampP
 Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP Error  =
 CAN_CTRL
 1000000     40   8    8    8   1   5 1000000  0.0% 75.0% 68.0%  9.3%
clock 0x00000004 timing 0x0000007f
- 800000    312   1    1    1   1  39  801282  0.2% 80.0% 75.0%  6.2%
clock 0x00000026 timing 0x00000001
+ 800000     96   4    5    3   1  12  801282  0.2% 80.0% 76.9%  3.9%
clock 0x0000000b timing 0x00000028
  500000    400   1    2    1   1  50  500000  0.0% 87.5% 80.0%  8.6%
clock 0x00000031 timing 0x00000002
  250000    200   8    8    3   1  25  250000  0.0% 87.5% 85.0%  2.9%
clock 0x00000018 timing 0x0000002f
  125000   1000   3    3    1   1 125  125000  0.0% 87.5% 87.5%  0.0%
clock 0x0000007c timing 0x00000005

-steven

> --
> Pengutronix e.K. =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| Marc Kleine-Budde =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |
> Industrial Linux Solutions =C2=A0 =C2=A0 =C2=A0 =C2=A0| Phone: +49-23=
1-2826-924 =C2=A0 =C2=A0 |
> Vertretung West/Dortmund =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| Fax: =C2=
=A0 +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686 =C2=A0| http://www.pengutronix.de =C2=
=A0 |
>
>
>
