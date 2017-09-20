From: Wei Wang <weiwan@google.com>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 15:09:02 -0700
Message-ID: <CAEA6p_DpSr84cYu3pXqoHV=V=daSsbiOcnzsF+Kt0r4Wv_jmdg@mail.gmail.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl> <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
 <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl> <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
 <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl> <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
 <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl> <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com>
 <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl> <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
 <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
 <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl> <548a893c-8a8f-3b07-00f7-d75de1d777ad@itcare.pl>
 <7d8731ee-6c91-bbfd-6313-c95f52d7b49a@itcare.pl> <26e8b899-d8b1-caa4-436b-e23ffe384b0f@itcare.pl>
 <6c36fa00-13e6-8cd7-ff5c-df7739220736@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:47071 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdITWJE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:09:04 -0400
Received: by mail-ua0-f174.google.com with SMTP id q29so2543404uaf.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 15:09:04 -0700 (PDT)
In-Reply-To: <6c36fa00-13e6-8cd7-ff5c-df7739220736@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> bisected again and same result:
>>> b838d5e1c5b6e57b10ec8af2268824041e3ea911 is the first bad commit
>>> commit b838d5e1c5b6e57b10ec8af2268824041e3ea911
>>> Author: Wei Wang <weiwan@google.com>
>>> Date:   Sat Jun 17 10:42:32 2017 -0700
>>>
>>>     ipv4: mark DST_NOGC and remove the operation of dst_free()
>>>
>>>     With the previous preparation patches, we are ready to get rid of t=
he
>>>     dst gc operation in ipv4 code and release dst based on refcnt only.
>>>     So this patch adds DST_NOGC flag for all IPv4 dst and remove the
>>> calls
>>>     to dst_free().
>>>     At this point, all dst created in ipv4 code do not use the dst gc
>>>     anymore and will be destroyed at the point when refcnt drops to 0.
>>>
>>>     Signed-off-by: Wei Wang <weiwan@google.com>
>>>     Acked-by: Martin KaFai Lau <kafai@fb.com>
>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>> :040000 040000 9b7e7fb641de6531fc7887473ca47ef7cb6a11da
>>> 831a73b71d3df1755f3e24c0d3c86d7a93fd55e2 M      net
>>>
>>> Will add now version 2 of patch from Eric and we will see
>>>
>>>
>> after adding patch
>> perf top catch
>>    PerfTop:   77159 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz cycles]=
,
>> (all, 40 CPUs)
>>
>> ------------------------------------------------------------------------=
---------------------------------------------------------------------------=
------------------------------------------------------------
>>
>>     60.95%  [kernel]            [k] dev_put.part.6
>>      4.00%  [kernel]            [k] ixgbe_poll
>>      3.63%  [kernel]            [k] irq_entries_start
>>      1.22%  [kernel]            [k] fib_table_lookup
>>      1.15%  [kernel]            [k] do_raw_spin_lock
>>      1.05%  [kernel]            [k] ixgbe_xmit_frame_ring
>>      1.04%  [kernel]            [k] lookup
>>      0.87%  [kernel]            [k] eth_type_trans
>>
>>
>> no panic on console - rebooting to check logs
>>
>>
> Nothing logged
>

Thanks very much Pawel for the feedback.

I was looking into the code (specifically IPv4 part) and found that in
free_fib_info_rcu(), we call free_nh_exceptions() without holding the
fnhe_lock. I am wondering if that could cause some race condition on
fnhe->fnhe_rth_input/output so a double call on dst_dev_put() on the
same dst could be happening.

But as we call free_fib_info_rcu() only after the grace period, and
the lookup code which could potentially modify
fnhe->fnhe_rth_input/output all holds rcu_read_lock(), it seems
fine...


On Wed, Sep 20, 2017 at 2:25 PM, Pawe=C5=82 Staszewski <pstaszewski@itcare.=
pl> wrote:
>
>
> W dniu 2017-09-20 o 23:24, Pawe=C5=82 Staszewski pisze:
>
>>
>>
>> W dniu 2017-09-20 o 23:10, Pawe=C5=82 Staszewski pisze:
>>>
>>>
>>>
>>> W dniu 2017-09-20 o 21:23, Pawe=C5=82 Staszewski pisze:
>>>>
>>>>
>>>>
>>>> W dniu 2017-09-20 o 21:13, Pawe=C5=82 Staszewski pisze:
>>>>>
>>>>>
>>>>>
>>>>> W dniu 2017-09-20 o 20:36, Cong Wang pisze:
>>>>>>
>>>>>> On Wed, Sep 20, 2017 at 11:30 AM, Eric Dumazet
>>>>>> <eric.dumazet@gmail.com> wrote:
>>>>>>>
>>>>>>> On Wed, 2017-09-20 at 11:22 -0700, Cong Wang wrote:
>>>>>>>>
>>>>>>>> but dmesg at this time shows nothing about interfaces or flaps.
>>>>>>>>
>>>>>>>> This is very odd.
>>>>>>>>
>>>>>>>> We only free netdevice in free_netdev() and it is only called when
>>>>>>>> we unregister a netdevice. Otherwise pcpu_refcnt is impossible
>>>>>>>> to be NULL.
>>>>>>>
>>>>>>> If there is a missing dev_hold() or one dev_put() in excess,
>>>>>>> this would allow the netdev to be freed too soon.
>>>>>>>
>>>>>>> -> Use after free.
>>>>>>> memory holding netdev could be reallocated-cleared by some other
>>>>>>> kernel
>>>>>>> user.
>>>>>>>
>>>>>> Sure, but only unregister could trigger a free. If there is no
>>>>>> unregister,
>>>>>> like what Pawel claims, then there is no free, the refcnt just goes =
to
>>>>>> 0 but the memory is still there.
>>>>>>
>>>>> About possible mistake from my side with bisect - i can judge too ear=
ly
>>>>> that some bisect was good
>>>>> the road was:
>>>>> git bisect start
>>>>> # bad: [ac7b75966c9c86426b55fe1c50ae148aa4571075] Merge tag
>>>>> 'pinctrl-v4.13-1' of
>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl
>>>>> git bisect bad ac7b75966c9c86426b55fe1c50ae148aa4571075
>>>>> # good: [e24dd9ee5399747b71c1d982a484fc7601795f31] Merge branch 'next=
'
>>>>> of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-securi=
ty
>>>>> git bisect good e24dd9ee5399747b71c1d982a484fc7601795f31
>>>>> # bad: [9cc9a5cb176ccb4f2cda5ac34da5a659926f125f] datapath: Avoid usi=
ng
>>>>> stack larger than 1024.
>>>>> git bisect bad 9cc9a5cb176ccb4f2cda5ac34da5a659926f125f
>>>>> # good: [073cf9e20c333ab29744717a23f9e43ec7512a20] Merge branch
>>>>> 'udp-reduce-cache-pressure'
>>>>> git bisect good 073cf9e20c333ab29744717a23f9e43ec7512a20
>>>>> # bad: [8abd5599a520e9f188a750f1bde9dde5fb856230] Merge branch
>>>>> 's390-net-updates-part-2'
>>>>> git bisect bad 8abd5599a520e9f188a750f1bde9dde5fb856230
>>>>> # good: [2fae5d0e647c6470d206e72b5fc24972bb900f70] Merge branch
>>>>> 'bpf-ctx-narrow'
>>>>> git bisect good 2fae5d0e647c6470d206e72b5fc24972bb900f70
>>>>> # good: [41500c3e2a19ffcf40a7158fce1774de08e26ba2] rds: tcp: remove
>>>>> cp_outgoing
>>>>> git bisect good 41500c3e2a19ffcf40a7158fce1774de08e26ba2
>>>>> # bad: [8917a777be3ba566377be05117f71b93a5fd909d] tcp: md5: add
>>>>> TCP_MD5SIG_EXT socket option to set a key address prefix
>>>>> git bisect bad 8917a777be3ba566377be05117f71b93a5fd909d
>>>>> # good: [4a6ce2b6f2ecabbddcfe47e7cf61dd0f00b10e36] net: introduce a n=
ew
>>>>> function dst_dev_put()
>>>>>
>>>>> And currently have this running for about 4 hours without problems.
>>>>>
>>>>>
>>>>>
>>>>> git bisect good 4a6ce2b6f2ecabbddcfe47e7cf61dd0f00b10e36
>>>>> # bad: [a4c2fd7f78915a0d7c5275e7612e7793157a01f2] net: remove
>>>>> DST_NOCACHE flag
>>>>>
>>>>> Here for sure - panic
>>>>>
>>>>> git bisect bad a4c2fd7f78915a0d7c5275e7612e7793157a01f2
>>>>> # bad: [ad65a2f05695aced349e308193c6e2a6b1d87112] ipv6: call
>>>>> dst_hold_safe() properly
>>>>> git bisect bad ad65a2f05695aced349e308193c6e2a6b1d87112
>>>>> # good: [9df16efadd2a8a82731dc76ff656c771e261827f] ipv4: call
>>>>> dst_hold_safe() properly
>>>>> git bisect good 9df16efadd2a8a82731dc76ff656c771e261827f
>>>>> # bad: [1cfb71eeb12047bcdbd3e6730ffed66e810a0855] ipv6: take
>>>>> dst->__refcnt for insertion into fib6 tree
>>>>>
>>>>> im not 100% sure tor last two
>>>>> Will test them again starting from
>>>>> [95c47f9cf5e028d1ae77dc6c767c1edc8a18025b] ipv4: call dst_dev_put()
>>>>> properly
>>>>>
>>>>>
>>>>> git bisect bad 1cfb71eeb12047bcdbd3e6730ffed66e810a0855
>>>>> # bad: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC
>>>>> and remove the operation of dst_free()
>>>>>
>>>>>
>>>>>
>>>>> git bisect bad b838d5e1c5b6e57b10ec8af2268824041e3ea911
>>>>> # first bad commit: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4:
>>>>> mark DST_NOGC and remove the operation of dst_free()
>>>>>
>>>>>
>>>>>
>>>> What i can say more
>>>> I can reproduce this on any server with similar configuration
>>>> the difference can be teamd instead of bonding
>>>> ixgbe or i40e and mlx5
>>>> Same problems
>>>>
>>>> vlans - more or less prefixes learned from bgp -> zebra -> netlink ->
>>>> kernel
>>>> But normally in lab when using only plain routing no bgpd and about 12=
8
>>>> vlans - with 128 routes - cant reproduce this - this apperas only with=
 bgp -
>>>> minimum where i can reproduce this was about 130k prefixes with about =
286
>>>> nexthops
>>>>
>>>>
>>>>
>>>>
>>> bisected again and same result:
>>> b838d5e1c5b6e57b10ec8af2268824041e3ea911 is the first bad commit
>>> commit b838d5e1c5b6e57b10ec8af2268824041e3ea911
>>> Author: Wei Wang <weiwan@google.com>
>>> Date:   Sat Jun 17 10:42:32 2017 -0700
>>>
>>>     ipv4: mark DST_NOGC and remove the operation of dst_free()
>>>
>>>     With the previous preparation patches, we are ready to get rid of t=
he
>>>     dst gc operation in ipv4 code and release dst based on refcnt only.
>>>     So this patch adds DST_NOGC flag for all IPv4 dst and remove the
>>> calls
>>>     to dst_free().
>>>     At this point, all dst created in ipv4 code do not use the dst gc
>>>     anymore and will be destroyed at the point when refcnt drops to 0.
>>>
>>>     Signed-off-by: Wei Wang <weiwan@google.com>
>>>     Acked-by: Martin KaFai Lau <kafai@fb.com>
>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>> :040000 040000 9b7e7fb641de6531fc7887473ca47ef7cb6a11da
>>> 831a73b71d3df1755f3e24c0d3c86d7a93fd55e2 M      net
>>>
>>> Will add now version 2 of patch from Eric and we will see
>>>
>>>
>> after adding patch
>> perf top catch
>>    PerfTop:   77159 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz cycles]=
,
>> (all, 40 CPUs)
>>
>> ------------------------------------------------------------------------=
---------------------------------------------------------------------------=
------------------------------------------------------------
>>
>>     60.95%  [kernel]            [k] dev_put.part.6
>>      4.00%  [kernel]            [k] ixgbe_poll
>>      3.63%  [kernel]            [k] irq_entries_start
>>      1.22%  [kernel]            [k] fib_table_lookup
>>      1.15%  [kernel]            [k] do_raw_spin_lock
>>      1.05%  [kernel]            [k] ixgbe_xmit_frame_ring
>>      1.04%  [kernel]            [k] lookup
>>      0.87%  [kernel]            [k] eth_type_trans
>>
>>
>> no panic on console - rebooting to check logs
>>
>>
> Nothing logged
>
