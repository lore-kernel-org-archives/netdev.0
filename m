From: Mohamad Haj Yahia <mohamadhajyahia.mellanox@gmail.com>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Tue, 31 Jan 2017 16:44:14 +0200
Message-ID: <CANDJFw7funFkqzvLyZuZP8V8tXeXXvvKvc8gB1=NyStnVCdPzw@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
 <CALzJLG_v2HxsdPdX5H=T51RGmaMMnXVxzihuPN66a9RxDadEcw@mail.gmail.com>
 <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
 <CALzJLG9YXBzXAOrtth7SX8n3S5cN3ZSmKax4FOGiTr7SY8gobg@mail.gmail.com>
 <CALx6S375OVvSi5QLLCpsGc84iE3cJ3VH5Rm6sg8OJgDR=nqXfA@mail.gmail.com>
 <CALzJLG_WCiTei7CDoUCzM241gt0bSKqjGJ61ke2XbbQTOjZBkQ@mail.gmail.com>
 <CALx6S35-ecvO0k6-yqdLpO6mXA4Y6mycMD3HqHPCaUtMZd8GYA@mail.gmail.com>
 <CALzJLG-U2uLB2uqeVT1viP87oxDEp1XUymu-zVRhe9yGrBEc+w@mail.gmail.com>
 <588BD66E.2050201@fb.com> <CALzJLG_abLhT7wcrtB97KzurJ2-=OZv11cELjoRW79cOeyjxgw@mail.gmail.com>
 <588CDA55.7030900@fb.com> <CALzJLG9OksXW5JAZiPoSfKtTF_z8Te9UDP9bm_XhXAp-FwmwEw@mail.gmail.com>
 <588F6DC7.70904@fb.com> <CALzJLG9Ltw7UdptVj0DbcUf4xCvooC1CkFXhSXXdt-d5-pL4ug@mail.gmail.com>
 <58900535.2050709@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34454 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdAaOoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 09:44:21 -0500
Received: by mail-oi0-f66.google.com with SMTP id w144so28535634oiw.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 06:44:20 -0800 (PST)
In-Reply-To: <58900535.2050709@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Is it multi host configuration or bare metal ?
>
>
> multihost
>
>> Do you have internal loopback traffic between different hosts ?
>
>
> in a multihost? how can I check that?
> Is there an ethtool command?
>

You can check that by sending traffic from one PF to another on the same port.

>>> broken firmware or expected behavior?
>>
>>
>> which driver did you test ? backported or net-next ?
>
>
> both backported and net-next with Tom's patches.
>
>> if it is backported driver please verify that on driver load the
>> following occurs :
>>
>> 1. VPORTS change events are globally enabled:
>> in mlx5_start_eqs@eq.c:
>> async_event_mask |= (1ull << MLX5_EVENT_TYPE_NIC_VPORT_CHANGE);
>
>
> this one is done.
>
>> 2. UC address change events are enabled for vport 0 (PF):
>> In eswitch_attach or on eswitch_init (depends on the kernel version)
>> @eswitch.c
>> esw_enable_vport(esw, 0, UC_ADDR_CHANGE); is called.
>
>
> this one is not. Tom's proposal to compile out eswitch.c
> removes invocation of mlx5_eswitch_attach() and
> corresponding esw_enable_vport() call as well.
> The question is why is it necessary?
> What will break if it's not done?
> so far we don't see any adverse effects in both multihost
> and baremetal setups.
>
Please pay attention that if you compile out the eswitch.c we will not
program the l2 table.
However, the FW populate the L2 table with default entries after
init_hca command (at the driver load stage).
For each PF, By default its permanent mac pointing to it in the l2 table.
This can explain why its working for you without setting the l2 entries.

Now, if you try to set another mac for that PF or try to reach mac
addresses that are not the permantent address (virtual mac addresses
over the PF) it will fail.
So for this reason its crucial that the PF program the l2 table (which
needs the UC_ADDR_CHANGE set in the PF vport context).

>> BTW folks, i am going to be on vacation for the rest of the week, so
>> please expect slow responses.
>
>
> have a great time off. I hope other mlx folks can answer.
>
