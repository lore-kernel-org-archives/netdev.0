From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: remove tc class reference counting
Date: Thu, 24 Aug 2017 15:09:21 -0700
Message-ID: <CAM_iQpU=+YD7V0m5u8auy0oA+UcErd_Xq+ZQyKGkewTFfmQvWg@mail.gmail.com>
References: <20170823043810.17602-1-xiyou.wangcong@gmail.com> <20170824.123220.2250866539237700218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37862 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753492AbdHXWJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:09:42 -0400
Received: by mail-pg0-f65.google.com with SMTP id a7so1063840pgn.4
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:09:42 -0700 (PDT)
In-Reply-To: <20170824.123220.2250866539237700218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 12:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 22 Aug 2017 21:38:10 -0700
>
>> For TC classes, their ->get() and ->put() are always paired, and the
>> reference counting is completely useless, because:
>>
>> 1) For class modification and dumping paths, we already hold RTNL lock,
>>    so all of these ->get(),->change(),->put() are atomic.
>>
>> 2) For filter bindiing/unbinding, we use other reference counter than
>>    this one, and they should have RTNL lock too.
>>
>> 3) For ->qlen_notify(), it is special because it is called on ->enqueue()
>>    path, but we already hold qdisc tree lock there, and we hold this
>>    tree lock when graft or delete the class too, so it should not be gone
>>    or changed until we release the tree lock.
>>
>> Therefore, this patch removes ->get() and ->put(), but:
>>
>> 1) Adds a new ->find() to find the pointer to a class by classid, no
>>    refcnt.
>>
>> 2) Move the original class destroy upon the last refcnt into ->delete(),
>>    right after releasing tree lock. This is fine because the class is
>>    already removed from hash when holding the lock.
>>
>> For those who also use ->put() as ->unbind(), just rename them to reflect
>> this change.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> This one looks good to me.
>
> Jamal, please give it a quick look over and review.
>

Hold on, I spot a problem near ->delete(), need a fix like
I did for tc actions...

The reason why I didn't catch it in my test is actually we
don't notify delete event for classes when deleting the
whole tree.

Anyway, v2 is coming.
