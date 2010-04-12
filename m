From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 1/3] sysctl: refactor integer handling proc code
Date: Mon, 12 Apr 2010 14:30:15 +0800
Message-ID: <4BC2BDF7.6020900@redhat.com>
References: <20100409101442.5051.99812.sendpatchset@localhost.localdomain> <20100409101452.5051.74050.sendpatchset@localhost.localdomain> <n2j412e6f7f1004090349q37cb01f0u177aaa4fc16664ec@mail.gmail.com> <201004091640.44056.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab0DLG0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 02:26:41 -0400
In-Reply-To: <201004091640.44056.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> Hi and thanks for reviewing.
> 
> On Friday 09 April 2010 13:49:12 you wrote:
>>> + *
>>> + * In case of success 0 is returned and buf and size are updated with
>>> + * the amount of bytes read. If tr is non NULL and a trailing
>>> + * character exist (size is non zero after returning from this
>>> + * function) tr is updated with the trailing character.
>>> + */
>>> +static int proc_get_ulong(char __user **buf, size_t *size,
>>> +                         unsigned long *val, bool *neg,
>>> +                         const char *perm_tr, unsigned perm_tr_len, char
>>> *tr) +{
>>> +       int len;
>>> +       char *p, tmp[TMPBUFLEN];
>>> +
>>> +       if (!*size)
>>> +               return -EINVAL;
>>> +
>>> +       len = *size;
>>> +       if (len > TMPBUFLEN-1)
>>> +               len = TMPBUFLEN-1;
>>> +
>>> +       if (copy_from_user(tmp, *buf, len))
>>> +               return -EFAULT;
>>> +
>>> +       tmp[len] = 0;
>>> +       p = tmp;
>>> +       if (*p == '-' && *size > 1) {
>>> +               *neg = 1;
>>> +               p++;
>>> +       } else
>>> +               *neg = 0;
>> the function name implies that it is used to parse unsigned long, so
>> negative value should not be supported.
>>
> 
> My intention was to signal that the argument is unsigned long and that the 
> sign come separate in neg, but I am OK with changing the function name to 
> proc_get_long() if you think that is better.
> 
>>> +       if (!isdigit(*p))
>>> +               return -EINVAL;
>> It seems that ledding white space should be allowed, so this check
>> isn't needed, and simple_strtoul can handle it.
>>
> 
> Leading white space is skipped with proc_skip_space before calling this 
> function. AFAICS simple_strtoul does not handle whitespaces.


Right, callers already skip spaces.

> 
>>> +
>>> +       *val = simple_strtoul(p, &p, 0);
>>> +
>>> +       len = p - tmp;
>>> +
>>> +       /* We don't know if the next char is whitespace thus we may
>>> accept +        * invalid integers (e.g. 1234...a) or two integers
>>> instead of one +        * (e.g. 123...1). So lets not allow such large
>>> numbers. */ +       if (len == TMPBUFLEN - 1)
>>> +               return -EINVAL;
>>> +
>>> +       if (len < *size && perm_tr_len && !isanyof(*p, perm_tr,
>>> perm_tr_len)) +               return -EINVAL;
>> is strspn() better?
>>
> 
> I don't  think it will work out, \0 is an accepted trailer for many of the 
> function which use this function.
> 

Yes, that is why 'len' is the last parameter of isanyof().


> 
>>> +
>>> +       if (tr && (len < *size))
>>> +               *tr = *p;
>>> +
>>> +       *buf += len;
>>> +       *size -= len;
>>> +
>>> +       return 0;
>>> +}
>>> +
>>> +/**
>>> + * proc_put_ulong - coverts an integer to a decimal ASCII formated
>>> string + *
>>> + * @buf - the user buffer
>>> + * @size - the size of the user buffer
>>> + * @val - the integer to be converted
>>> + * @neg - sign of the number, %TRUE for negative
>>> + * @first - if %FALSE will insert a separator character before the
>>> number + * @separator - the separator character
>>> + *
>>> + * In case of success 0 is returned and buf and size are updated with
>>> + * the amount of bytes read.
>>> + */
>>> +static int proc_put_ulong(char __user **buf, size_t *size, unsigned long
>>> val, +                         bool neg, bool first, char separator)
>>> +{
>>> +       int len;
>>> +       char tmp[TMPBUFLEN], *p = tmp;
>>> +
>>> +       if (!first)
>>> +               *p++ = separator;
>>> +       sprintf(p, "%s%lu", neg ? "-" : "", val);
>> negative should not be supported too.
>>
> 
> We need negatives in proc_dointvec, again we can change the function name if 
> it will clear things up.
> 


Yeah, I will change them to proc_{get,put}_long().


> <snip>
>>>                int val = *valp;
>>>                unsigned long lval;
>>>                if (val < 0) {
>>> -                       *negp = -1;
>>> +                       *negp = 1;
>>>                        lval = (unsigned long)-val;
>>>                } else {
>>>                        *negp = 0;
>> These functions have so much lines of code. I think you can make them
>> less. Please refer to strsep().
>>
> 
> Hmm, the input its pretty permissive and maybe this is why it looks so fat, we 
> need to account for quite a few cases. 
> 

Because the original code is messy and already has much lines.

Thanks.
