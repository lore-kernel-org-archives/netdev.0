From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Fri, 20 Jan 2017 23:52:17 +0100
Message-ID: <CACT4Y+Yf5S1OiNdd8WH=bmge=25m3zOh48QB8iq2nsKESG6Z_Q@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
 <CACT4Y+Y_3i=PThhVzHXYnCQm_xN72VQ0eN9Ae4uXyORq_a_Z6w@mail.gmail.com> <CAM_iQpUtirzcm901Gh6918g2yROo3FFKb6Vx87Wtj7M31wE6DA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUtirzcm901Gh6918g2yROo3FFKb6Vx87Wtj7M31wE6DA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 5:57 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>>> > Why do we do autobind there, anyway, and why is it conditional on
>>>>>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
>>>>>> > to sending stuff without autobind ever done - just use socketpair()
>>>>>> > to create that sucker and we won't be going through the connect()
>>>>>> > at all.
>>>>>>
>>>>>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
>>>>>> not SOCK_STREAM.
>>>>>
>>>>> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
>>>>> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?
>>>>>
>>>>>> I guess some lock, perhaps the u->bindlock could be dropped before
>>>>>> acquiring the next one (sb_writer), but I need to double check.
>>>>>
>>>>> Bad idea, IMO - do you *want* autobind being able to come through while
>>>>> bind(2) is busy with mknod?
>>>>
>>>>
>>>> Ping. This is still happening on HEAD.
>>>>
>>>
>>> Thanks for your reminder. Mind to give the attached patch (compile only)
>>> a try? I take another approach to fix this deadlock, which moves the
>>> unix_mknod() out of unix->bindlock. Not sure if there is any unexpected
>>> impact with this way.
>>
>>
>> I instantly hit:
>>
>
> Oh, sorry about it, I forgot to initialize struct path...
>
> Attached is the updated version, I just did a boot test, no crash at least. ;)
>
> Thanks!

This works! I did not see the deadlock warning, nor any other related crashes.

Tested-by: Dmitry Vyukov <dvyukov@google.com>
