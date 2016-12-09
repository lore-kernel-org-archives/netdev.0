From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Fri, 9 Dec 2016 01:32:08 +0000
Message-ID: <20161209013208.GW1555@ZenIV.linux.org.uk>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
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
Received: from zeniv.linux.org.uk ([195.92.253.2]:33104 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbcLIBcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 20:32:14 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 04:08:27PM -0800, Cong Wang wrote:
> On Thu, Dec 8, 2016 at 8:30 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > Chain exists of:
> >  Possible unsafe locking scenario:
> >
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(sb_writers#5);
> >                                lock(&u->bindlock);
> >                                lock(sb_writers#5);
> >   lock(&pipe->mutex/1);
> 
> This looks false positive, probably just needs lockdep_set_class()
> to set keys for pipe->mutex and unix->bindlock.

I'm afraid that it's not a false positive at all.

Preparations:
	* create an AF_UNIX socket.
	* set SOCK_PASSCRED on it.
	* create a pipe.

Child 1: splice from pipe to socket; locks pipe and proceeds down towards
unix_dgram_sendmsg().

Child 2: splice from pipe to /mnt/foo/bar; requests write access to /mnt
and blocks on attempt to lock the pipe already locked by (1).

Child 3: freeze /mnt; blocks until (2) is done

Child 4: bind() the socket to /mnt/barf; grabs ->bindlock on the socket and
proceeds to create /mnt/barf, which blocks due to fairness of freezer (no
extra write accesses to something that is in process of being frozen).

_Now_ (1) gets around to unix_dgram_sendmsg().  We still have NULL u->addr,
since bind() has not gotten through yet.  We also have SOCK_PASSCRED set,
so we attempt autobind; it blocks on the ->bindlock, which won't be
released until bind() is done (at which point we'll see non-NULL u->addr
and bugger off from autobind), but bind() won't succeed until /mnt
goes through the freeze-thaw cycle, which won't happen until (2) finishes,
which won't happen until (1) unlocks the pipe.  Deadlock.

Granted, ->bindlock is taken interruptibly, so it's not that much of
a problem (you can kill the damn thing), but you would need to intervene
and kill it.

Why do we do autobind there, anyway, and why is it conditional on
SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
to sending stuff without autobind ever done - just use socketpair()
to create that sucker and we won't be going through the connect()
at all.
