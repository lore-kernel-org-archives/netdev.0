From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v2 3/9] socket: initial cgroup code.
Date: Wed, 7 Sep 2011 02:59:06 -0300
Message-ID: <4E67082A.1020005@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-4-git-send-email-glommer@parallels.com> <CALdu-PCeZLnF-3zx=NU6paC41Hp+_VTN-mTt6RvXbCu7Kdk-mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<containers@lists.osdl.org>, <netdev@vger.kernel.org>,
	<xemul@parallels.com>, "David S. Miller" <davem@davemloft.net>,
	Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Paul Menage <paul@paulmenage.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:50459 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237Ab1IGF7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 01:59:54 -0400
In-Reply-To: <CALdu-PCeZLnF-3zx=NU6paC41Hp+_VTN-mTt6RvXbCu7Kdk-mQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2011 02:26 AM, Paul Menage wrote:
> On Tue, Sep 6, 2011 at 9:23 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> We aim to control the amount of kernel memory pinned at any
>> time by tcp sockets. To lay the foundations for this work,
>> this patch adds a pointer to the kmem_cgroup to the socket
>> structure.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>> ---
>>   include/linux/kmem_cgroup.h |   29 +++++++++++++++++++++++++++++
>>   include/net/sock.h          |    2 ++
>>   net/core/sock.c             |    5 ++---
>>   3 files changed, 33 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
>> index 0e4a74b..77076d8 100644
>> --- a/include/linux/kmem_cgroup.h
>> +++ b/include/linux/kmem_cgroup.h
>> @@ -49,5 +49,34 @@ static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
>>         return NULL;
>>   }
>>   #endif /* CONFIG_CGROUP_KMEM */
>> +
>> +#ifdef CONFIG_INET
>> +#include<net/sock.h>
>> +static inline void sock_update_kmem_cgrp(struct sock *sk)
>> +{
>> +#ifdef CONFIG_CGROUP_KMEM
>> +       sk->sk_cgrp = kcg_from_task(current);
>
> BUG_ON(sk->sk_cgrp) ? Or else release the old cgroup if necessary.

Since at least in this current incarnation, I am not doing migrations,
I definitely don't expect to have a pointer already present here.
BUG_ON() it is.

>> @@ -339,6 +340,7 @@ struct sock {
>>   #endif
>>         __u32                   sk_mark;
>>         u32                     sk_classid;
>> +       struct kmem_cgroup      *sk_cgrp;
>
> Should this be protected by a #ifdef?
I don't particularly like it. I think that ifdef'ing fields
in structures, while allowing for size optimization, takes away
size and alignment predictability. But... can do.
