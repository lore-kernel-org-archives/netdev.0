From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 4/6] Add support for __be64 and bitops to ethtool
Date: Wed, 27 Apr 2011 09:46:07 -0700
Message-ID: <4DB8484F.8030001@intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>	 <20110421204035.23054.6918.stgit@gitlad.jf.intel.com> <1303919692.2875.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20338 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab1D0QqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 12:46:18 -0400
In-Reply-To: <1303919692.2875.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/2011 8:54 AM, Ben Hutchings wrote:
> On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
>> This change is meant to add support for __be64 values and bitops to
>> ethtool.  These changes will be needed in order to support network flow
>> classifier rule configuration.
>>
>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>> ---
>>
>>   ethtool-bitops.h |   25 +++++++++++++++++++++++++
>>   ethtool-util.h   |   30 ++++++++++++++++++++++++++----
>>   ethtool.c        |    7 -------
>>   3 files changed, 51 insertions(+), 11 deletions(-)
>>   create mode 100644 ethtool-bitops.h
>>
>> diff --git a/ethtool-bitops.h b/ethtool-bitops.h
>> new file mode 100644
>> index 0000000..0ff14f1
>> --- /dev/null
>> +++ b/ethtool-bitops.h
>> @@ -0,0 +1,25 @@
>> +#ifndef ETHTOOL_BITOPS_H__
>> +#define ETHTOOL_BITOPS_H__
>> +
>> +#define BITS_PER_BYTE		8
>> +#define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
>> +#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
>> +#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
>> +
>> +static inline void set_bit(int nr, unsigned long *addr)
>> +{
>> +	addr[nr / BITS_PER_LONG] |= 1UL<<  (nr % BITS_PER_LONG);
>> +}
>> +
>> +static inline void clear_bit(int nr, unsigned long *addr)
>> +{
>> +	addr[nr / BITS_PER_LONG]&= ~(1UL<<  (nr % BITS_PER_LONG));
>> +}
>> +
>> +static __always_inline int test_bit(unsigned int nr, const unsigned long *addr)
>> +{
>> +	return !!((1UL<<  (nr % BITS_PER_LONG))&
>> +		  (((unsigned long *)addr)[nr / BITS_PER_LONG]));
>> +}
>
> Where is __always_inline supposed to be defined?

Sorry that should have just been inline.  I forgot we have to take tools 
other than gcc into account.

>> +#endif
>> diff --git a/ethtool-util.h b/ethtool-util.h
>> index f053028..3d46faf 100644
>> --- a/ethtool-util.h
>> +++ b/ethtool-util.h
>> @@ -5,15 +5,18 @@
>>
>>   #include<sys/types.h>
>>   #include<endian.h>
>> +#include<sys/ioctl.h>
>> +#include<net/if.h>
>> +#include "ethtool-config.h"
>> +#include "ethtool-copy.h"
>>
>>   /* ethtool.h expects these to be defined by<linux/types.h>  */
>>   #ifndef HAVE_BE_TYPES
>>   typedef __uint16_t __be16;
>>   typedef __uint32_t __be32;
>> +typedef unsigned long long __be64;
>>   #endif
>>
>> -#include "ethtool-copy.h"
>> -
>
> You can't move the inclusion of ethtool-copy.h; that defeats the whole
> purpose of the HAVE_BE_TYPES feature test.

You're correct. I will get that corrected so that it is located after 
the definitions of the types.  The key bit that mattered was getting 
ethtool-config.h in there before the type declarations.  I need it in 
place to address the test for HAVE_BE_TYPES.

> [...]
>> +#ifndef ARRAY_SIZE
>> +#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
>> +#endif
>> +
>> +#ifndef SIOCETHTOOL
>> +#define SIOCETHTOOL     0x8946
>>   #endif
>>
>>   /* National Semiconductor DP83815, DP83816 */
>> diff --git a/ethtool.c b/ethtool.c
>> index 9ad7000..15af86a 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
>> @@ -45,16 +45,9 @@
>>   #include<linux/sockios.h>
>>   #include "ethtool-util.h"
>>
>> -
>> -#ifndef SIOCETHTOOL
>> -#define SIOCETHTOOL     0x8946
>> -#endif
>>   #ifndef MAX_ADDR_LEN
>>   #define MAX_ADDR_LEN	32
>>   #endif
>> -#ifndef ARRAY_SIZE
>> -#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
>> -#endif
>>
>>   #ifndef HAVE_NETIF_MSG
>>   enum {
>>
>
> Presumably this is needed by the next patch, but it has nothing to do
> with what the commit message says.
>
> Ben.
>

Yes. These two moves and the addition of certain headers to the 
ethtool-util.h were to address the needs of both the rxclass.c file and 
the ethtool.c file in one central location.  I will probably break those 
off into a separate patch.

On a side note, is there a git tree somewhere I can re-base off of?  At 
this point I know you have pulled in a number of patches and I figure it 
would be helpful for me to clean up my tree so I am not guessing what is 
there and what isn't.

Thanks,

Alex



