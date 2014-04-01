From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] isdnloop: NUL-terminate strings from userspace
Date: Tue, 01 Apr 2014 12:46:37 +0200
Message-ID: <533A990D.2040609@oracle.com>
References: <1396346898-8950-1-git-send-email-vegard.nossum@oracle.com> <20140401103020.GG24150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140401103020.GG24150@order.stressinduktion.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2014 12:30 PM, Hannes Frederic Sowa wrote:
> On Tue, Apr 01, 2014 at 12:08:18PM +0200, Vegard Nossum wrote:
>> Both the in-kernel and BSD strlcpy() require that the source string is
>> NUL terminated. We could use strncpy() + explicitly terminate the result,
>> but this relies on src and dest having the same size, so the safest thing
>> to do seems to explicitly terminate the source string before doing the
>> strlcpy().
>>
>> Fixes: f9a23c84486ed35 ("isdnloop: use strlcpy() instead of strcpy()")
>> Cc: Dan Carpenter <dan.carpenter@oracle.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
>> ---
>>   drivers/isdn/isdnloop/isdnloop.c |    8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
>> index 02125e6..50cd348 100644
>> --- a/drivers/isdn/isdnloop/isdnloop.c
>> +++ b/drivers/isdn/isdnloop/isdnloop.c
>> @@ -1070,6 +1070,14 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
>>   		return -EBUSY;
>>   	if (copy_from_user((char *) &sdef, (char *) sdefp, sizeof(sdef)))
>>   		return -EFAULT;
>> +
>> +	/*
>> +	 * Null terminate strings from userspace so we don't have to worry
>> +	 * about this later on.
>> +	 */
>> +	for (i = 0; i < 3; i++)
>> +		sdef.num[i][sizeof(sdef.num[0]) - 1] = '\0';
>> +
>
> Looking down the problem, it seems the problem is that the strlen in strlcpy
> could read beyond the input buffer?
>
> To prevent this problem in other parts of the kernel wouldn't it be better to
> replace the strlen with strnlen in strlcpy?

Sorry, I should have included the link to the previous thread: 
https://lkml.org/lkml/2014/3/7/712

I only resent (adding netdev to Cc) to get this into David Miller's 
patch queue.

As you can see from the previous discussion, we _could_ change the Linux 
kernel's definition of strlcpy(), but I wouldn't recommend it for the 
following reasons:

1. Both BSD man page and BSD implementation _require_ the source string 
to be 0-terminated. Changing the semantics of strlcpy() in the Linux 
kernel would probably be a bad idea and cause even more confusion that 
what we already have.

2. Even if we changed strlcpy() to use strnlen(), it would still be 
unsafe if the source string is not 0-terminated and the source buffer is 
shorter than the destination buffer. That's because the size passed to 
strlcpy() is conceptually the length of the _destination_ buffer, not 
the source string.

I'm not against changing strlcpy() per se (changing to strnlen() might 
be a performance improvement), but we shouldn't use that as an excuse to 
use the interface incorrectly.


Vegard
