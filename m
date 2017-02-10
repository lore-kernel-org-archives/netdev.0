From: Jason Wang <jasowang@redhat.com>
Subject: Re: net: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in
 skb_array_produce
Date: Fri, 10 Feb 2017 13:17:36 +0800
Message-ID: <ce1d4f53-d664-0ee1-cf79-aca66d2d0d00@redhat.com>
References: <CACT4Y+bs15VR7xjeYhece+0_X5Ss+5FM0w6jpJH0Dbbdu-+qCQ@mail.gmail.com>
 <50038580.20299907.1486634551103.JavaMail.zimbra@redhat.com>
 <20170209200936-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38138 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750940AbdBJFSC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 00:18:02 -0500
In-Reply-To: <20170209200936-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月10日 02:10, Michael S. Tsirkin wrote:
> On Thu, Feb 09, 2017 at 05:02:31AM -0500, Jason Wang wrote:
>> ----- Original Message -----
>>> Hello,
>>>
>>> I've got the following report while running syzkaller fuzzer on mmotm
>>> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
>>> remotes/mmotm/auto-latest ee4ba7533626ba7bf2f8b992266467ac9fdc045e:
>>>
>> [...]
>>
>>> other info that might help us debug this:
>>>
>>>   Possible interrupt unsafe locking scenario:
>>>
>>>         CPU0                    CPU1
>>>         ----                    ----
>>>    lock(&(&r->consumer_lock)->rlock);
>>>                                 local_irq_disable();
>>>                                 lock(&(&r->producer_lock)->rlock);
>>>                                 lock(&(&r->consumer_lock)->rlock);
>>>    <Interrupt>
>>>      lock(&(&r->producer_lock)->rlock);
>>>
>> Thanks a lot for the testing.
>>
>> Looks like we could address this by using skb_array_consume_bh() instead.
>>
>> Could you pls verify if the following patch works?
> I think we should use _bh for the produce call as well,
> since resizing takes the producer lock.

Looks not since irq was disabled during resizing?

Thanks
