From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 11:22:51 -0700
Message-ID: <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl> <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl> <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl> <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
 <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl> <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
 <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl> <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
 <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl> <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
 <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com> <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:44005 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdITSXM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 14:23:12 -0400
Received: by mail-pg0-f51.google.com with SMTP id u18so2146472pgo.0
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:23:12 -0700 (PDT)
In-Reply-To: <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 10:55 AM, Pawe=C5=82 Staszewski
<pstaszewski@itcare.pl> wrote:
>
>
> W dniu 2017-09-20 o 19:50, Cong Wang pisze:
>
> On Wed, Sep 20, 2017 at 6:11 AM, Eric Dumazet <eric.dumazet@gmail.com>
> wrote:
>
> Sorry for top-posting, but this is to give context to Wei, since Pawel
> used a top posting way to report his bisection.
>
> Wei, can you take a look at Pawel report ?
>
> Crash happens in dst_destroy() at following :
>
> if (dst->dev)
>      dev_put(dst->dev); <<CRASH>>
>
>
> dst->dev is not NULL, but netdev->pcpu_refcnt is NULL
>
> 65 ff 08                decl   %gs:(%rax)   // CRASH since rax =3D NULL
>
>
>
> Pawel, please share your netdevices and routing setup  ?
>
> Looks like a double dev_put() on some dev...
>
> Pawel, do you have any idea how this is triggered? Does your
> test try to remove some network device? If so which one?
> I noticed you have at least multiple vlan, bond and ixgbe
> devices.
>
> Just after i start bgp sessions
> So when host is starting i have all bgp sessions to upstreams shutdown
>
> To trigger panic i just enable all 6x bgp sessions at once to upstreams -
> and zebra is start to pull prefixes and push them to the kernel
>
> Then some traffic is generated from test hosts thru this backup router an=
d
> panic is generated - every time after 10 to 15 seconds after bgp sessions
> are connected.
>
> I'm not removing any interface at this time or do anything with interface=
s -
> just wait.
>
> And yes there are vlans attached to the bond devices
> but dmesg at this time shows nothing about interfaces or flaps.

This is very odd.

We only free netdevice in free_netdev() and it is only called when
we unregister a netdevice. Otherwise pcpu_refcnt is impossible
to be NULL.
