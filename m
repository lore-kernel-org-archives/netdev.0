From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in tw_timer_handler
Date: Fri, 17 Feb 2017 14:30:10 -0800
Message-ID: <CAM_iQpWgUQiarfH9wkxEkCoFkwvKJt75uX4CP1-MUU6u_hkLYQ@mail.gmail.com>
References: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
 <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
 <1485268138.16328.297.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+b=-XJCwofbCRo6BnKJRU=amd7pxYpNrGdPEFT0bAtJaQ@mail.gmail.com>
 <CANn89iK=5uPEDLpM6=JAKzJ=1GuSSiXw5b_8BrkVUvhYRi_9mw@mail.gmail.com>
 <CACT4Y+bRP9ffnXDJeOD5VkqFw+-cDHh4hEVzcnv3vnHh+vdqBQ@mail.gmail.com>
 <CAM_iQpXDtOY+A2pEqGeggBONnGawt=Xv6PdcWJpUB-4dqv4hpA@mail.gmail.com> <CACT4Y+ZR8aQsrfVBxtg45YYyNZsYqHvUDkRrqAgE=+v+8O1pDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZR8aQsrfVBxtg45YYyNZsYqHvUDkRrqAgE=+v+8O1pDg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 17, 2017 at 12:36 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Feb 17, 2017 at 7:51 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>>>
>>>>>> This code was changed a long time ago :
>>>>>>
>>>>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
>>>>>>
>>>>>> So I suspect a recent patch broke the logic.
>>>>>>
>>>>>> You might start a bisection :
>>>>>>
>>>>>> I would check if 4.7 and 4.8 trigger the issue you noticed.
>>>>>
>>>>>
>>>>> It happens with too low rate for bisecting (few times per day). I
>>>>> could add some additional checks into code, but I don't know what
>>>>> checks could be useful.
>>>>
>>>> If you can not tell if 4.7 and/or 4.8 have the problem, I am not sure
>>>> we are able to help.
>>>
>>>
>>> There are also chances that the problem is older.
>>>
>>> Looking at the code, this part of inet_twsk_purge looks fishy:
>>>
>>> 285                         if (unlikely((tw->tw_family != family) ||
>>> 286                                      atomic_read(&twsk_net(tw)->count))) {
>>>
>>> It uses net->count == 0 check to find the right sockets. But what if
>>> there are several nets with count == 0 in flight, can't there be
>>> several inet_twsk_purge calls running concurrently freeing each other
>>> sockets? If so it looks like inet_twsk_purge can call
>>> inet_twsk_deschedule_put twice for a socket. Namely, two calls for
>>> different nets discover the socket, check that net->count==0 and both
>>> call inet_twsk_deschedule_put. Shouldn't we just give inet_twsk_purge
>>> net that it needs to purge?
>>
>> I don't think this could happen, because cleanup_net() is called in a
>> work struct, and this work can't be scheduled twice, so there should
>> not be any parallel cleanup_net().
>>
>> Also, inet_twsk_deschedule_put() already waits for the flying timer,
>> net->count==0 at this point and all sockets in this netns are already
>> gone, so I don't know how a timer could be still fired after this.
>
>
> One thing that I noticed is that use-after-free always happens in
> tw_timer_handler, but never in timer code. This suggests that:
> 1. Whoever frees the struct waits for the timer mutex unlock.
> 2. Free happens almost at the same time as timer fires (otherwise the
> timer would probably be cancelled).
>
> That could happen if there is a race in timer code during cancellation
> or rearming. I understand that it's heavily stressed code, but who
> knows...

Good point! I think this could happen since timer is deactivated before
unlinking the tw sock, so another CPU could find it and rearm the timer
during such window?

>
> I still wonder if twsk_net(tw)->count==0 is the right condition. This
> net may not yet have been scheduled for destruction, but another task
> could pick it up and start destroying...

Good question. net_exit_list is just a snapshot of the cleanup_list, so
it is true that inet_twsk_purge() could purge more netns'es than in
net_exit_list, but I don't see any problem with this, the work later can't
find the same twsck again since it is unlinked from hashtable.
Do you see otherwise?

>
> Cong, do you have any ideas as to what debugging checks I could add to
> help track this down?

I don't have any theory for the cause of this bug. Your point above actually
makes sense for me. Maybe you can add some code in between the following
code:

        if (del_timer_sync(&tw->tw_timer))
                inet_twsk_kill(tw);

to verify is the timer is rearmed or not.
