From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Thu, 8 Dec 2016 22:32:00 -0800
Message-ID: <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com> <20161209013208.GW1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209013208.GW1555@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 8, 2016 at 5:32 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Dec 08, 2016 at 04:08:27PM -0800, Cong Wang wrote:
>> On Thu, Dec 8, 2016 at 8:30 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> > Chain exists of:
>> >  Possible unsafe locking scenario:
>> >
>> >        CPU0                    CPU1
>> >        ----                    ----
>> >   lock(sb_writers#5);
>> >                                lock(&u->bindlock);
>> >                                lock(sb_writers#5);
>> >   lock(&pipe->mutex/1);
>>
>> This looks false positive, probably just needs lockdep_set_class()
>> to set keys for pipe->mutex and unix->bindlock.
>
> I'm afraid that it's not a false positive at all.

Right, I was totally misled by the scenario output of lockdep, the stack
traces actually are much more reasonable.

The deadlock scenario is easy actually, comparing with the netlink one
which has 4 locks involved, it is:

unix_bind() path:
u->bindlock ==> sb_writer

do_splice() path:
sb_writer ==> pipe->mutex ==> u->bindlock

 *** DEADLOCK ***

>
> Why do we do autobind there, anyway, and why is it conditional on
> SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
> to sending stuff without autobind ever done - just use socketpair()
> to create that sucker and we won't be going through the connect()
> at all.

In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
not SOCK_STREAM.

I guess some lock, perhaps the u->bindlock could be dropped before
acquiring the next one (sb_writer), but I need to double check.
