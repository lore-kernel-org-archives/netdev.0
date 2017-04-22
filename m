From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: [RFC] change the default Kconfig value of mlx5_en
Date: Sat, 22 Apr 2017 11:28:06 +0200
Message-ID: <CAA85sZsH4JNczUzK0EfGC959y=+SK1b=T6_5zb_0e1b99xGtvA@mail.gmail.com>
References: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
 <20170421.154745.182611990085743539.davem@davemloft.net> <CAA85sZtBo5dORg4sj8X_SROBU0ySh3_CQh1WiYcVX-RVv4E+gA@mail.gmail.com>
 <CAA85sZtr3N3Y8=R5qZHDTMgquV35ddw0x45qy8Kkf_tiVdu8ag@mail.gmail.com>
 <CALzJLG9cLY8qqjFHGx6i=Gi-TH5EZ2Mq+TQOusX7=EoRDvx1tw@mail.gmail.com>
 <CAA85sZsUjOSZ9Ax6=YFVQfykexCUCRH8+qVxUHRHwt0cBtSqmQ@mail.gmail.com> <CALzJLG_+ubbpwYy+i=HixbT6C6PXB16ZA8_iySmggSsUD70bKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35694 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1043714AbdDVJ23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 05:28:29 -0400
Received: by mail-lf0-f68.google.com with SMTP id i3so11717999lfh.2
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 02:28:28 -0700 (PDT)
In-Reply-To: <CALzJLG_+ubbpwYy+i=HixbT6C6PXB16ZA8_iySmggSsUD70bKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 3:07 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Sat, Apr 22, 2017 at 3:47 AM, Ian Kumlien <ian.kumlien@gmail.com> wrote:
>> On Sat, Apr 22, 2017 at 2:34 AM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>>> On Sat, Apr 22, 2017 at 2:10 AM, Ian Kumlien <ian.kumlien@gmail.com> wrote:
>>>> Sorry,
>>>>
>>>> Back again, fighting cold, hot whiskey has been consumed...
>>>>
>>>> Something like this would perhaps be a better solution:
>>>>
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c
>>>> b/drivers/net/ethernet/mellanox/mlx5/core/main.c
>>>> index 60154a175bd3..fe192e247601 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
>>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
>>>> @@ -1139,6 +1139,10 @@ static int mlx5_load_one(struct mlx5_core_dev
>>>> *dev, struct mlx5_priv *priv,
>>>>
>>>>  #ifdef CONFIG_MLX5_CORE_EN
>>>>         mlx5_eswitch_attach(dev->priv.eswitch);
>>>> +#else
>>>> +       if (MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) {
>>>> +               dev_info(&pdev->dev, "Ethernet device discovered but
>>>> support not enabled in kernel.");
>>>> +       }
>>>>  #endif
>>>>
>>>
>>> Currently both MLX5_CORE=n and MLX5_CORE_EN=n as a default, the issue
>>> you are seeing can occur only if you explicitly  set MLX5_CORE=y and
>>> MLX5_CORE=n, Why would someone do this if he knows he wants Ethernet
>>> support as well ? IMHO this print is redundant .
>>
>> Well, I'm running a prebuilt kernel - which was configured this way,
>> and since there
>> is no mlx5_en module and it does state that the link is "Ethernet", it
>> just looks like the
>> driver is broken or in some kind of really weird state.
>>
>>> Anyway, Are you looking for RDMA support over ethernet (RoCE) ? and
>>> you are not interested to have ethernet netdev support ?
>>
>> ? RDMA is something we'll look at in the future, right now, having the
>> nics actually
>> work as nics is a priority ;)
>>
>
> I see, i just wanted to understand your situation :)
>
>>> if yes, I think this is something that can be achieved, but the
>>> question is do we really need this ?
>>
>> It's really weird to see the driver load, to see everything register
>> and have no feedback.
>>
>
> So, in your case you have mlx5 core support without MLX5_CORE_EN which
> provides the eswitch and netdev functionality in ethernet.

Yes

> But you will still have mlx5_ib register an RDMA interface and
> theoretically it should work, the only thing you won't see is a
> netdevice.
>
> The weird thing is that you don't see a link up on the RDMA interface,
> Leon/Matan can you please look into this ? do we really need a netdev
> to have a functioning RDMA logical link in ethernet ?

The switch we have does support RDMA but the manual is sparse (as in
nothing really there) wrt enabling/configuring the RDMA bit so something
might be missing.

I'll try to remember to do the same test when we setup the mellanox switches =)

>> Including no network devices, but if you run the Infiniband commands,
>> they tell you that
>> you are connected to Ethernet but that the device is down and disabled.
>>
>> To me, down and disabled is not the same as in "Ethernet support is
>> not included" =)
>>
>> Basically, i would hate for someone else to end up in the same
>> situation since you only
>> get guides on how to enable infiniband/RDMA but what you really want
>> to do at that point
>> is to disable it and see if that gives you your network devices back =)
>>
>
> Yes this is misleading, Maybe your kernel log warning is not so bad
> after all, but let me dig more into this.
> I will get back to you next week.

Thanks, I bet that there is better ways to do it, this one was just
one of the first ones i found =)

>> I have had similar issues with some connectx3 devices while playing at
>> home but i suspect
>> that it's just a limitation of OFED packages available for the dist I'm running.
