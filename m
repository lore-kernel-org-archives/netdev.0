From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Thu, 2 Mar 2017 20:00:15 +0100
Message-ID: <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-3-arnd@arndb.de>
 <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com>
 <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34987 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751828AbdCBX7w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 18:59:52 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v22IxKgd059828
        for <netdev@vger.kernel.org>; Thu, 2 Mar 2017 14:00:23 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0b-001b2d01.pphosted.com with ESMTP id 28xpbu8ayj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 14:00:23 -0500
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
        Thu, 2 Mar 2017 14:00:22 -0500
In-Reply-To: <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2017 06:55 PM, Arnd Bergmann wrote:
> On Thu, Mar 2, 2017 at 5:51 PM, Christian Borntraeger
> <borntraeger@de.ibm.com> wrote:
>> On 03/02/2017 05:38 PM, Arnd Bergmann wrote:
>>>
>>> This attempts a rewrite of the two macros, using a simpler implementation
>>> for the most common case of having a naturally aligned 1, 2, 4, or (on
>>> 64-bit architectures) 8  byte object that can be accessed with a single
>>> instruction.  For these, we go back to a volatile pointer dereference
>>> that we had with the ACCESS_ONCE macro.
>>
>> We had changed that back then because gcc 4.6 and 4.7 had a bug that could
>> removed the volatile statement on aggregate types like the following one
>>
>> union ipte_control {
>>         unsigned long val;
>>         struct {
>>                 unsigned long k  : 1;
>>                 unsigned long kh : 31;
>>                 unsigned long kg : 32;
>>         };
>> };
>>
>> See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145
>>
>> If I see that right, your __ALIGNED_WORD(x)
>> macro would say that for above structure  sizeof(x) == sizeof(long)) is true,
>> so it would fall back to the old volatile cast and might reintroduce the
>> old compiler bug?

Oh dear, I should double check my sentences in emails before sending...anyway
the full story is referenced in 

commit 60815cf2e05057db5b78e398d9734c493560b11e
    Merge tag 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/borntraeger/linux
which has a pointer to
http://marc.info/?i=54611D86.4040306%40de.ibm.com
which contains the full story.

> 
> Ah, right, that's the missing piece. For some reason I didn't find
> the reference in the source or the git log.
> 
>> Could you maybe you fence your simple macro for anything older than 4.9? After
>> all there was no kasan support anyway on these older gcc version.
> 
> Yes, that should work, thanks!
