From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Tue, 17 Jan 2017 21:07:05 +1300
Message-ID: <87wpduaz4m.fsf@xmission.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
        <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
        <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
        <20161209013208.GW1555@ZenIV.linux.org.uk>
        <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
        <20161209064144.GZ1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209064144.GZ1555@ZenIV.linux.org.uk> (Al Viro's message of
        "Fri, 9 Dec 2016 06:41:44 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:
>
>> > Why do we do autobind there, anyway, and why is it conditional on
>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
>> > to sending stuff without autobind ever done - just use socketpair()
>> > to create that sucker and we won't be going through the connect()
>> > at all.
>> 
>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
>> not SOCK_STREAM.
>
> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?

With respect to the conditionality on SOCK_PASSCRED those are the linux
semantics.  Semantically that is the way the code has behaved since
2.1.15 when support for passing credentials was added to the code.
So I presume someone thought it was a good idea to have a name for
a socket that is sending credentials to another socket.  It certainly
seems reasonable at first glance.

With socketpair the only path that doesn't enforce this with
SOCK_STREAM and SOCK_PASSCRED that is either an oversight or a don't
care because we already know who is at the other end.

I can imagine two possible fixes:
1) Declare that splice is non-sense in the presence of SOCK_PASSCRED.
2) Someone adds a preparation operation that can be called on
   af_unix sockets that will ensure the autobind happens before
   any problematic locks are taken.

Eric
