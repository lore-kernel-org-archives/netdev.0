From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Fri, 27 Jan 2017 00:29:12 +0100
Message-ID: <20170126232912.rgh6undqxd4tofqj@dhcp-1-212.brq.redhat.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk>
 <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk>
 <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752332AbdAZXb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 18:31:56 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 01:21:48PM -0800, Cong Wang wrote:
> On Mon, Jan 16, 2017 at 1:32 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > On Fri, Dec 9, 2016 at 7:41 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >> On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:
> >>
> >>> > Why do we do autobind there, anyway, and why is it conditional on
> >>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
> >>> > to sending stuff without autobind ever done - just use socketpair()
> >>> > to create that sucker and we won't be going through the connect()
> >>> > at all.
> >>>
> >>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
> >>> not SOCK_STREAM.
> >>
> >> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
> >> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?
> >>
> >>> I guess some lock, perhaps the u->bindlock could be dropped before
> >>> acquiring the next one (sb_writer), but I need to double check.
> >>
> >> Bad idea, IMO - do you *want* autobind being able to come through while
> >> bind(2) is busy with mknod?
> >
> >
> > Ping. This is still happening on HEAD.
> >
> 
> Thanks for your reminder. Mind to give the attached patch (compile only)
> a try? I take another approach to fix this deadlock, which moves the
> unix_mknod() out of unix->bindlock. Not sure if there is any unexpected
> impact with this way.
> 

I don't think this is the right approach.

Currently the file creation is potponed until unix_bind can no longer
fail otherwise. With it reordered, it may be someone races you with a
different path and now you are left with a file to clean up. Except it
is quite unclear for me if you can unlink it.

I don't have a good idea how to fix it. A somewhat typical approach
would introduce an intermediate state ("under construction") and drop
the lock between calling into unix_mknod.

In this particular case, perhaps you could repurpose gc_flags as a
general flags carrier and add a 'binding in process' flag to test.
