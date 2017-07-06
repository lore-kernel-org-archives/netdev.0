From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Thu, 6 Jul 2017 10:48:26 -0700
Message-ID: <CAF2d9jhr-G2WxxhW=D6ox-XLTHH8q7YtO8wxCaguwpqJT1YVuw@mail.gmail.com>
References: <20170704191615.6412-1-mahesh@bandewar.net> <20170705.092032.1482668095877350196.davem@davemloft.net>
 <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
 <20170705.170524.241248681076978527.davem@davemloft.net> <CAF2d9jhTujK0J53DODxCp+0yYnR2RTz7rVGaJE=xeN0-9k4C3g@mail.gmail.com>
 <871spuek9i.fsf@xmission.com> <CAF2d9jjsRXnuPz3WKSRZK5ctj_c2BMBcWfiWbe4vxesGA8fNgg@mail.gmail.com>
 <87inj57o7t.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>, mahesh@bandewar.net,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35695 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751813AbdGFRst (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 13:48:49 -0400
Received: by mail-it0-f41.google.com with SMTP id v202so9758641itb.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 10:48:48 -0700 (PDT)
In-Reply-To: <87inj57o7t.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 6, 2017 at 5:18 AM, Eric W. Biederman <ebiederm@xmission.com> w=
rote:
> "Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=
=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=B0)" <maheshb@google.com> writes=
:
>
>>> I wonder if it is too late to change this since this behavior is probab=
ly
>>> from the beginning of network namespace. A networkless netns is also
>>> useful at least for testing purpose, we do use it as a sandbox.
>>>
>> Sandbox is my use case too but i'm worried about all other things that
>> a process inside that namespace can do (tasks' capability mask) and
>> want to eliminate a need to have a capability just to bing-up the
>> loopback device (more in the commit message update)
>>
>>
>>> If you can please include the analysis that describes why no one will
>>> care. Especially applications such as vsftpd that create network
>>> namespaces as a way to sandbox themselves and not have a network stack
>>> available.
>>>
>> Well, I wasn't sure hence probed with the RFC patch.
>> I'm not familiar with the vsftpd use-case but I assume it's expecting
>> a loopback device to be in DOWN state.
>
> The expectation is that it is up to the poster of a patch to convince
> the rest of us it is worth while.
>
> The obvious pro that you don't have go through the extra step
> of setting the loopback device up.
>
> I listed vsftpd as it is widely available and was the the most obviously
> different from the normal use case.  I don't think you will break
> vsftpd.  I know all vsftpd cares about is ensuring it's process can not
> communicate with the outside world except through it's one socket. I
> know somethings are different with lo up vs lo down but I don't know
> them well enough to imagine what will break.
>
> I know on any other interface you want to delay bringing the interface
> up because things like ipv6 stateless address autoconfiguration can be
> problematic for debugging if you aren't using ipv6.  Just lots of extra
> packet noise.
>
> The only argument I can see for leaving the loopback interface down by
> default is that if bringing the interface up makes it difficult to
> disable something (such as tcp to localhost).
>
> Hmm...   The one disadvantage that I can see with bringing the loopback
> device up is that, bringing the loopback device up will create
> routing entries.  Those routing entries will persist for at least an rcu
> grace period.  That will make it more expensive to destroy a network
> namespace if you don't every use those routes.  (see vsftpd above)
>
However note that this is small use case while most use cases do bring up
loopback and add other networking too. So these small savings are not reall=
y
applicable to the most common use cases.

> I personally think it would be handy to have loopback devices always
> up.  I don't see loopback devices as that expensive to bring up so I
> don't much care.  So right now I personally am persuaded that he
> aditional expense for applications like vsftpd makes bringing up the
> loopback device undesirable.
>
> The less magic at namespace creation time also seems like a compelling
> argument when I am debugging things.
>
> Among non-container things I don't see anything except an initial
> ramdisk as being able to care.  As the initial ramdisk is very likely
> going to bring up the loopback device.
>
> Does the in kernel nfsroot support bring up the loopback device?
> I know it needs to bring up networking otherwise.
>
>> Now that you have made me aware of some use cases that do want the
>> loopback device to be DOWN, could we use a global sysctl to dictate
>> the loopback behavior during init? e.g.
>>
>> net.core.netdev_loopback_state =3D {0|1}
>>
>>     where 0: is current behavior i.e. DOWN by default.
>>                1: is the proposed new behavior i.e. UP by default.
>>
>> We can keep the default value of this sysctl to be '1' so that when a
>> host boots, the loopback is UP by default.
>>  In a running system that prefers the loopback device to come up in
>> DOWN state for the namespaces, can change the value of this sysctl to
>> '0' so every namespace creation will come-up with loopback in DOWN
>> state. Or we could reverse the behavior by changing the default value
>> of this sysctl (to '0').
>
> I don't think it is worth the complexity to have a sysctl to change the
> default behavior.  Especially as we can't make it a per network
> namespace sysctl.  That will just make the kernel more complex and less
> predictable to userspace.
>
> Anything that is useful enough to implement a sysctl would convince me
> it is worth it to change the default.
>
>
> We do need your bug fix.  Please send that one separately so David can
> merge it.  Although I suspect at this point it will need to wait until
> David reopens the net-next.
>
OK I'll decouple these two patches and send them separately.

>
> Eric
>
