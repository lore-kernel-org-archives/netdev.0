From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Sat, 26 Nov 2016 18:26:10 -0800
Message-ID: <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
         <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34421 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752872AbcK0C0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 21:26:13 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so9266686pgc.1
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 18:26:12 -0800 (PST)
In-Reply-To: <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-11-26 at 18:08 -0800, Cong Wang wrote:
> On Fri, Nov 25, 2016 at 8:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Oh well, this wont work, since sk->sk_destruct will be called from RCU
> > callback.
> >
> > Grabbing the mutex should not be done from netlink_sock_destruct() but
> > from netlink_release()
> 
> But you also change the behavior of cb.done(), currently it is called when the
> last sock ref is gone, with your patch it is called when the first
> sock is closed.

No. It will be called when last refcount on the socket is released,
sk_refcnt transitions to final 0.


My patch changes the sock_hold() to the variant that makes sure
sk_refcnt is not 0 before increase, otherwise a race can happen and
release could be called twice.

Classic refcounting stuff coupled to rcu rules.

> No?


Are you telling me inet_release() is called when we close() the first
file descriptor ?

fd1 = socket()
fd2 = dup(fd1);
close(fd2) -> release() ???


> 
> I don't see why we need to get genl_lock in ->done() here, because we are
> already the last sock using it and module ref protects the ops from being
> removed via module, seems we are pretty safe without any lock.

Well, at least this exposes a real bug in Thomas patch.

Removing the lock might be done for net-next, not stable branches.
