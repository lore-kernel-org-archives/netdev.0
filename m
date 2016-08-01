From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [v4] Fix to avoid IS_ERR_VALUE and IS_ERR abuses on 64bit
 systems.
Date: Mon, 1 Aug 2016 16:55:43 +0000
Message-ID: <DB5PR0401MB19280ACA87C7F5EE2822D5FB91040@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1469963924-8800-1-git-send-email-arvind.yadav.cs@gmail.com>
 <1956647.cOmaJREgOE@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>,
	"zajec5@gmail.com" <zajec5@gmail.com>,
	"leoli@freescale.com" <leoli@freescale.com>,
	"qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
	"viresh.kumar@linaro.org" <viresh.kumar@linaro.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"David.Laight@aculab.com" <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"scottwood@freescale.com" <scottwood@freescale.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux@roeck-us.net" <linux@roeck-us.net>
To: Arnd Bergmann <arnd@arndb.de>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0056.outbound.protection.outlook.com ([104.47.2.56]:64520
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754578AbcHASc0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 14:32:26 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2016 02:02 AM, Arnd Bergmann wrote:
> On Sunday, July 31, 2016 4:48:44 PM CEST Arvind Yadav wrote:
>> IS_ERR_VALUE() assumes that parameter is an unsigned long.
>> It can not be used to check if 'unsigned int' is passed insted.
>> Which tends to reflect an error.
>>
>> In 64bit architectures sizeof (int) == 4 && sizeof (long) == 8.
>> IS_ERR_VALUE(x) is ((x) >= (unsigned long)-4095).
>>
>> IS_ERR_VALUE() of 'unsigned int' is always false because the 32bit
>> value is zero extended to 64 bits.
>>
>> Value of (unsigned int)-4095 is always less than value of
>> (unsigned long)-4095.
>>
>> Now We are taking only first 32 bit for error checking rest of the 32 bit
>> we ignore such that we get appropriate comparison on 64bit system as well.
> 
> This is completely wrong: if you have a valid 64-bit pointer like
> 0x00001234ffffff00, this will be interpreted as an error now.
> 
>> First 32bit of Value of (unsigned int)-4095 and (unsigned long)-4095 will
>> be equal.
>>
>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>> ---
>>  include/linux/err.h | 12 +++++++++++-
>>  1 file changed, 11 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/err.h b/include/linux/err.h
>> index 1e35588..c2a2789 100644
>> --- a/include/linux/err.h
>> +++ b/include/linux/err.h
>> @@ -18,7 +18,17 @@
>>  
>>  #ifndef __ASSEMBLY__
>>  
>> -#define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
>> +#define IS_ERR_VALUE(x) unlikely(is_error_check(x))
>> +
>> +static inline int is_error_check(unsigned long error)
> 
> Please leave the existing macro alone. I think you were looking for
> something specific to the return code of qe_muram_alloc() function,
> so please add a helper in that subsystem if you need it, not in
> the generic header files.

qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.  The
problem is certain callers that store the return value in a u32.  Why
not just fix those callers to store it in unsigned long (at least until
error checking is done)?

-Scott
