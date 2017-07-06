From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Thu, 06 Jul 2017 07:18:46 -0500
Message-ID: <87inj57o7t.fsf@xmission.com>
References: <20170704191615.6412-1-mahesh@bandewar.net>
        <20170705.092032.1482668095877350196.davem@davemloft.net>
        <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
        <20170705.170524.241248681076978527.davem@davemloft.net>
        <CAF2d9jhTujK0J53DODxCp+0yYnR2RTz7rVGaJE=xeN0-9k4C3g@mail.gmail.com>
        <871spuek9i.fsf@xmission.com>
        <CAF2d9jjsRXnuPz3WKSRZK5ctj_c2BMBcWfiWbe4vxesGA8fNgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>, mahesh@bandewar.net,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: =?utf-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?utf-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55406 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752708AbdGFM0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 08:26:45 -0400
In-Reply-To: <CAF2d9jjsRXnuPz3WKSRZK5ctj_c2BMBcWfiWbe4vxesGA8fNgg@mail.gmail.com>
        (Mahesh Bandewar's message of "Wed, 5 Jul 2017 16:01:55 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Mahesh Bandewar (महेश बंडेवार)" <maheshb@google.com> writes:

>> I wonder if it is too late to change this since this behavior is probably
>> from the beginning of network namespace. A networkless netns is also
>> useful at least for testing purpose, we do use it as a sandbox.
>>
> Sandbox is my use case too but i'm worried about all other things that
> a process inside that namespace can do (tasks' capability mask) and
> want to eliminate a need to have a capability just to bing-up the
> loopback device (more in the commit message update)
>
>
>> If you can please include the analysis that describes why no one will
>> care. Especially applications such as vsftpd that create network
>> namespaces as a way to sandbox themselves and not have a network stack
>> available.
>>
> Well, I wasn't sure hence probed with the RFC patch.
> I'm not familiar with the vsftpd use-case but I assume it's expecting
> a loopback device to be in DOWN state.

The expectation is that it is up to the poster of a patch to convince
the rest of us it is worth while.

The obvious pro that you don't have go through the extra step
of setting the loopback device up.

I listed vsftpd as it is widely available and was the the most obviously
different from the normal use case.  I don't think you will break
vsftpd.  I know all vsftpd cares about is ensuring it's process can not
communicate with the outside world except through it's one socket. I
know somethings are different with lo up vs lo down but I don't know
them well enough to imagine what will break.

I know on any other interface you want to delay bringing the interface
up because things like ipv6 stateless address autoconfiguration can be
problematic for debugging if you aren't using ipv6.  Just lots of extra
packet noise.

The only argument I can see for leaving the loopback interface down by
default is that if bringing the interface up makes it difficult to
disable something (such as tcp to localhost).

Hmm...   The one disadvantage that I can see with bringing the loopback
device up is that, bringing the loopback device up will create
routing entries.  Those routing entries will persist for at least an rcu
grace period.  That will make it more expensive to destroy a network
namespace if you don't every use those routes.  (see vsftpd above)

I personally think it would be handy to have loopback devices always
up.  I don't see loopback devices as that expensive to bring up so I
don't much care.  So right now I personally am persuaded that he
aditional expense for applications like vsftpd makes bringing up the
loopback device undesirable.

The less magic at namespace creation time also seems like a compelling
argument when I am debugging things.

Among non-container things I don't see anything except an initial
ramdisk as being able to care.  As the initial ramdisk is very likely
going to bring up the loopback device.

Does the in kernel nfsroot support bring up the loopback device?
I know it needs to bring up networking otherwise.

> Now that you have made me aware of some use cases that do want the
> loopback device to be DOWN, could we use a global sysctl to dictate
> the loopback behavior during init? e.g.
>
> net.core.netdev_loopback_state = {0|1}
>
>     where 0: is current behavior i.e. DOWN by default.
>                1: is the proposed new behavior i.e. UP by default.
>
> We can keep the default value of this sysctl to be '1' so that when a
> host boots, the loopback is UP by default.
>  In a running system that prefers the loopback device to come up in
> DOWN state for the namespaces, can change the value of this sysctl to
> '0' so every namespace creation will come-up with loopback in DOWN
> state. Or we could reverse the behavior by changing the default value
> of this sysctl (to '0').

I don't think it is worth the complexity to have a sysctl to change the
default behavior.  Especially as we can't make it a per network
namespace sysctl.  That will just make the kernel more complex and less
predictable to userspace.

Anything that is useful enough to implement a sysctl would convince me
it is worth it to change the default.


We do need your bug fix.  Please send that one separately so David can
merge it.  Although I suspect at this point it will need to wait until
David reopens the net-next.


Eric
