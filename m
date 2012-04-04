From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for Bosch
 D_CAN controller
Date: Wed, 04 Apr 2012 18:21:41 +0200
Message-ID: <4F7C7515.4070802@grandegger.com>
References: <1333456339-9372-1-git-send-email-anilkumar@ti.com> <4F7AF0C7.7020506@grandegger.com> <331ABD5ECB02734CA317220B2BBEABC1317D85D0@DBDE01.ent.ti.com> <4F7AFFEC.1010805@pengutronix.de> <331ABD5ECB02734CA317220B2BBEABC1317D86F7@DBDE01.ent.ti.com> <4F7B1854.90106@pengutronix.de> <331ABD5ECB02734CA317220B2BBEABC1317D88B7@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"m.kleine-budde@pengutronix.de" <m.kleine-budde@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Gole, Anant" <anantgole@ti.com>, "Nori, Sekhar" <nsekhar@ti.com>
To: "AnilKumar, Chimata" <anilkumar@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <331ABD5ECB02734CA317220B2BBEABC1317D88B7@DBDE01.ent.ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/03/2012 05:58 PM, AnilKumar, Chimata wrote:
> On Tue, Apr 03, 2012 at 21:03:40, Marc Kleine-Budde wrote:
>> On 04/03/2012 04:29 PM, AnilKumar, Chimata wrote:
>>>>>> Please explain why this CAN controller cannot be handled by the existing
>>>>>> C_CAN driver, eventually with some extensions. The register layout seems
>>>>>> almost identical, at least.
>>>>>>
>>>>>> Wolfgang.
>>>>>>
>>>>>
>>>>> These are the some of the pointers I can say, why I had gone for separate
>>>>> file instead of existing driver:
>>>>> * In case of D_CAN driver we can see all the registers are 32bit length
>>>>>   but in case of C_CAN registers are in 16bit length.
>>>>
>>>> How many bits in these 32 bit registers are used?
>>>
>>> In some cases (D_CAN_TXRQ, D_CAN_INTPND, D_CAN_MSGVAL) I have used all the
>>> bits, in some cases used few bits.
>>>
>>> Roughly I can say that its (higher 16bits) % of usages is similar as compare
>>> to 16bits 
>>>
>>> While checking the status of TXRequest registers and INT pending register,
>>> which is a hot code path, we have to put if checks for register access.
>>
>> The c_can already has a c_can_read_reg32() function. It's for example
>> used in the rx_poll function. You can make it a function pointer (i.e.
>> pric->read_reg32()) for easy abstraction.
> 
> This won't fit for D_CAN case because offsets are different in c_can compared
> to d_can. For example if I read CONTROL_REG register (0x0) in case of d_can,
> which will read only control register. In case of c_can it will read
> CONTROL_REG + STATUS register values in single read
> 
>>
>>>>> * Some of the registers, bit masks are different, so we have to add
>>>>>   checks on every API for differentiating the kind of device
>>>>
>>>> Which registers are this? Can you give us an example?
>>>
>>> I am pointing out some of the resisters
>>> * Single registers in case of D_CAN but multiple register in case of C_CAN
>>>   So masks will change MASK, ARB, INTPND
>>> * D_CAN_IFCMD is the combination of COMM request and COMM mask registers
>>
>> Maybe you can use the read_reg32 function on both c_can and d_can.
> 
> Above comment applies here as well

I did look into the manual. Unfortunately, a direct mapping of the C_CAN
to the D_CAN registers seems not possible. It's not just a different
alignment but sometimes two 16-bit C_CAN registers are folded into *one*
32-bit D_CAN register. Therefore we need something more clever, e.g.
using a separate struct or union or handling those register separately.
I still think, if feasible, we should avoid an extra driver for the
D_CAN controller, also because we sooner than later need the same
infrastructure (register_c_can_dev etc.).

Wolfgang.
