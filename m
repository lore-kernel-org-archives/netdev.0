From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: BUG still has locks held in unix_stream_splice_read
Date: Thu, 17 Nov 2016 13:44:35 -0800
Message-ID: <CAM_iQpUEEDE+OcfX66YJDC6dA+b-URHhUtWtv+sn-t5Esk_FWw@mail.gmail.com>
References: <CACT4Y+aPybMnXjiH+DdDWDAfz+L6PF-H-J3YT2+hjcDp3aw9SQ@mail.gmail.com>
 <CACT4Y+a6yDm28VYtNPSktYKs_T2UzLGb8jadpFpsdKfNzb7-tA@mail.gmail.com>
 <20161010024607.GV19539@ZenIV.linux.org.uk> <20161010031450.GW19539@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Colin Cross <ccross@android.com>,
        Mandeep Singh Baines <msb@chromium.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010031450.GW19539@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 9, 2016 at 8:14 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> E.g what will happen if some code does a read on AF_UNIX socket with
> some local mutex held?  AFAICS, there are exactly two callers of
> freezable_schedule_timeout() - this one and one in XFS; the latter is
> in a kernel thread where we do have good warranties about the locking
> environment, but here it's in the bleeding ->recvmsg/->splice_read and
> for those assumption that caller doesn't hold any locks is pretty
> strong, especially since it's not documented anywhere.
>
> What's going on there?

Commit 2b15af6f95 ("af_unix: use freezable blocking calls in read")
converts schedule_timeout() to its freezable version, it was probably correct
at that time, but later, commit 2b514574f7e88c8498027ee366
("net: af_unix: implement splice for stream af_unix sockets") breaks its
requirement for a freezable sleep:

    commit 0f9548ca10916dec166eaf74c816bded7d8e611d

    lockdep: check that no locks held at freeze time

    We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
    deadlock if the lock is later acquired in the suspend or hibernate path
    (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
    cgroup_freezer if a lock is held inside a frozen cgroup that is later
    acquired by a process outside that group.

So probably we just need to revert commit 2b15af6f95 now.

I am going to send a revert for at least -net and -stable, since Dmitry
saw this warning again.
