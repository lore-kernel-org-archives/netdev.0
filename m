From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [v4] Fix to avoid IS_ERR_VALUE and IS_ERR abuses on 64bit
 systems.
Date: Tue, 2 Aug 2016 19:57:48 +0000
Message-ID: <DB5PR0401MB1928DE1F195A57160DED735D91050@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1469963924-8800-1-git-send-email-arvind.yadav.cs@gmail.com>
 <1956647.cOmaJREgOE@wuerfel>
 <DB5PR0401MB19280ACA87C7F5EE2822D5FB91040@DB5PR0401MB1928.eurprd04.prod.outlook.com>
 <2484583.95xFmO7xir@wuerfel> <57A0BD8E.9050305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
	"viresh.kumar@linaro.org" <viresh.kumar@linaro.org>,
	"zajec5@gmail.com" <zajec5@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"David.Laight@aculab.com" <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"scottwood@freescale.com" <scottwood@freescale.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	Li Yang <leoli@freescale.com>
To: arvind Yadav <arvind.yadav.cs@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0086.outbound.protection.outlook.com ([104.47.2.86]:49120
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751042AbcHBU3V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 16:29:21 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2016 10:34 AM, arvind Yadav wrote:
> 
> 
> On Tuesday 02 August 2016 01:15 PM, Arnd Bergmann wrote:
>> On Monday, August 1, 2016 4:55:43 PM CEST Scott Wood wrote:
>>> On 08/01/2016 02:02 AM, Arnd Bergmann wrote:
>>>>> diff --git a/include/linux/err.h b/include/linux/err.h
>>>>> index 1e35588..c2a2789 100644
>>>>> --- a/include/linux/err.h
>>>>> +++ b/include/linux/err.h
>>>>> @@ -18,7 +18,17 @@
>>>>>  
>>>>>  #ifndef __ASSEMBLY__
>>>>>  
>>>>> -#define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
>>>>> +#define IS_ERR_VALUE(x) unlikely(is_error_check(x))
>>>>> +
>>>>> +static inline int is_error_check(unsigned long error)
>>>> Please leave the existing macro alone. I think you were looking for
>>>> something specific to the return code of qe_muram_alloc() function,
>>>> so please add a helper in that subsystem if you need it, not in
>>>> the generic header files.
>>> qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.  The
>>> problem is certain callers that store the return value in a u32.  Why
>>> not just fix those callers to store it in unsigned long (at least until
>>> error checking is done)?
>>>
>> Yes, that would also address another problem with code like
>>
>>          kfree((void *)ugeth->tx_bd_ring_offset[i]);
>>
>> which is not 64-bit safe when tx_bd_ring_offset is a 32-bit value
>> that also holds the return value of qe_muram_alloc.

Well, hopefully it doesn't hold a return of qe_muram_alloc() when it's
being passed to kfree()...

There's also the code that casts kmalloc()'s return to u32, etc.
ucc_geth is not 64-bit clean in general.

>>
>> 	Arnd
> Yes, we will fix caller. Caller api is not safe on 64bit.

The API is fine (or at least, I haven't seen a valid issue pointed out
yet).  The problem is the ucc_geth driver.

> Even qe_muram_addr(a.k.a. cpm_muram_addr )passing value unsigned int,
> but it should be unsigned long.

cpm_muram_addr takes unsigned long as a parameter, not that it matters
since you can't pass errors into it and a muram offset should never
exceed 32 bits.

-Scott
