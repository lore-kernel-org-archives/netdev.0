From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] tap: convert a mutex to a spinlock
Date: Thu, 6 Jul 2017 10:56:07 -0700
Message-ID: <CAM_iQpVbe=iSoAND1hyEmpEcxuTCguXLbPkyHHhTS0s1=9A69Q@mail.gmail.com>
References: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com> <1499329462.16045.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        borntraeger@de.ibm.com, Sainath Grandhi <sainath.grandhi@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33768 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbdGFR43 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 13:56:29 -0400
Received: by mail-lf0-f67.google.com with SMTP id t72so1410098lff.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 10:56:28 -0700 (PDT)
In-Reply-To: <1499329462.16045.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 6, 2017 at 1:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-07-05 at 13:50 -0700, Cong Wang wrote:
>> We are not allowed to block on the RCU reader side, so can't
>> just hold the mutex as before. As a quick fix, convert it to
>> a spinlock.
>>
>> Fixes: d9f1f61c0801 ("tap: Extending tap device create/destroy APIs")
>> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
>> Cc: Sainath Grandhi <sainath.grandhi@intel.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  drivers/net/tap.c | 18 +++++++++---------
>>  1 file changed, 9 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/tap.c b/drivers/net/tap.c
>> index 4d4173d..d88ae3c 100644
>> --- a/drivers/net/tap.c
>> +++ b/drivers/net/tap.c
>> @@ -106,7 +106,7 @@ struct major_info {
>>       struct rcu_head rcu;
>>       dev_t major;
>>       struct idr minor_idr;
>> -     struct mutex minor_lock;
>> +     spinlock_t minor_lock;
>>       const char *device_name;
>>       struct list_head next;
>>  };
>> @@ -416,15 +416,15 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
>>               goto unlock;
>>       }
>>
>> -     mutex_lock(&tap_major->minor_lock);
>> -     retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);
>
>         idr_preload(GFP_KERNEL);


Are you sure we can use GFP_KERNEL? RCU read lock is already taken
at this point, so I am afraid we can't do preload here.
