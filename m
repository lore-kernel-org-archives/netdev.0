From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Tue, 26 Sep 2017 18:26:41 +0300
Message-ID: <bebe7824-1cd8-11d1-a8c7-1e2affadc687@mellanox.com>
References: <20170919232709.14690-1-edumazet@google.com>
 <8edb310a-562d-bff1-0482-64314833e722@mellanox.com>
 <CANn89i+LE6He_E3VHwUTpLAVW+uUGo+FPs_zg1bs4P3CVcCL6Q@mail.gmail.com>
 <266d30e7-5164-48e8-b802-56bb93558823@mellanox.com>
 <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Yonatan Cohen <yonatanc@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20089.outbound.protection.outlook.com ([40.107.2.89]:39397
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934460AbdIZP0v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 11:26:51 -0400
In-Reply-To: <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 26/09/2017 6:13 PM, Eric Dumazet wrote:
> On Tue, Sep 26, 2017 at 8:04 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>
>> On 26/09/2017 3:51 PM, Eric Dumazet wrote:
>>> On Tue, Sep 26, 2017 at 4:21 AM, Tariq Toukan <tariqt@mellanox.com> wrote:
>>>>
>>>> Hi Eric,
>>>>
>>>> We see a regression introduced in this series, specifically in the
>>>> patches
>>>> touching lib/kobject_uevent.c.
>>>> We tried to figure out what is wrong there, but couldn't point it out.
>>>>
>>>> Bug is that mlx4 driver restart fails, because mlx4_core is still in use.
>>>> According to module dependencies, both mlx4_en and mlx4_ib should have
>>>> been
>>>> unloaded at this point
>>>> Please see log below.
>>>>
>>>> This looks to be some kind of a race, as the repro is not deterministic.
>>>> Probably the en/ib modules are now mistakenly reloaded.
>>>>
>>>> Any idea what could this be?
>>>>
>>>> Regards,
>>>> Tariq
>>>>
>>>>
>>>> [root@reg-l-vrt-41016-009 ~]# /etc/init.d/openibd stop
>>>> Unloading HCA driver:                                      [  OK  ]
>>>> [root@reg-l-vrt-41016-009 ~]# /etc/init.d/openibd start
>>>> Loading HCA driver and Access Layer:                       [  OK  ]
>>>> [root@reg-l-vrt-41016-009 ~]# /etc/init.d/openibd stop
>>>> Unloading mlx4_core                                        [FAILED]
>>>> rmmod: ERROR: Module mlx4_core is in use
>>> I have absolutely no idea. Please bisect.
>> We previously saw a similar issue, that was reported in mailing list.
>> Dmitry Torokhov suggested the following fix:
>> https://emea01.safelinks.protection.outlook.com/?url=https%3A%2F%2Flkml.org%2Flkml%2F2017%2F9%2F12%2F523&data=02%7C01%7Ctariqt%40mellanox.com%7C4a275c766aeb4224376e08d504f12193%7Ca652971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C636420356043309380&sdata=GGeDFkX277R%2BKShsUPsePoAD6p5yaO2v0CteABtCrcY%3D&reserved=0
>>
>> And indeed, it solved the issue.
>>
>> We kept the suggested patch in our internal branch, and rebased.
>> Issue appeared again once your series was accepted.
>>
>> By bisecting, we see that the issue re-appears in this patch:
>> 4a336a23d619 kobject: copy env blob in one go
>>
>>> Are you really using netns in the first place ?
>> No. But seems like it still affects the modules load/unload.
>>
>> Regards,
>> Tariq
> Ah this makes sense now.
>
> Dmitry Torokhov hack breaks the assumption I used in my patch.
>
> Since it is not upstream yet, I believe that it will need more work
> before being in a proper state.
>
> Thanks.
I see. Thanks for the clarification.
I guess we'll keep only one patch for now, until issues are resolved.

Regards.
