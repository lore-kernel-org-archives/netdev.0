From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Sat, 26 Nov 2016 22:28:21 -0800
Message-ID: <CAM_iQpUnz2kkjOFuk3fKKEYDh54b9WHk1dvH098mGtrGTPjZFQ@mail.gmail.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
 <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com> <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34841 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbcK0G2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 01:28:43 -0500
Received: by mail-io0-f174.google.com with SMTP id a124so182565648ioe.2
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 22:28:42 -0800 (PST)
In-Reply-To: <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2016 at 6:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Are you telling me inet_release() is called when we close() the first
> file descriptor ?
>
> fd1 = socket()
> fd2 = dup(fd1);
> close(fd2) -> release() ???

Sorry, I didn't express myself clearly, I meant your change,
if exclude the SOCK_RCU_FREE part, basically reverts this commit:

commit 3f660d66dfbc13ea4b61d3865851b348444c24b4
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu May 3 03:17:14 2007 -0700

    [NETLINK]: Kill CB only when socket is unused

IOW, ->release() is called when the last sock fd ref is gone, but ->destructor()
is called with the last sock ref is gone. They are very different.


>> I don't see why we need to get genl_lock in ->done() here, because we are
>> already the last sock using it and module ref protects the ops from being
>> removed via module, seems we are pretty safe without any lock.
>
> Well, at least this exposes a real bug in Thomas patch.
>
> Removing the lock might be done for net-next, not stable branches.

I am confused, what Subash reported is a kernel warning which can
surely be fixed by removing genl lock (if it is correct, I need to double
check), so why for net-next?
