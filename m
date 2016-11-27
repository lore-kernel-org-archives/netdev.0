From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Sun, 27 Nov 2016 08:23:44 -0800
Message-ID: <1480263824.18162.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
         <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
         <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUnz2kkjOFuk3fKKEYDh54b9WHk1dvH098mGtrGTPjZFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35083 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752302AbcK0QXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 11:23:46 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so5138286pfk.2
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 08:23:46 -0800 (PST)
In-Reply-To: <CAM_iQpUnz2kkjOFuk3fKKEYDh54b9WHk1dvH098mGtrGTPjZFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-11-26 at 22:28 -0800, Cong Wang wrote:
> On Sat, Nov 26, 2016 at 6:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Are you telling me inet_release() is called when we close() the first
> > file descriptor ?
> >
> > fd1 = socket()
> > fd2 = dup(fd1);
> > close(fd2) -> release() ???
> 
> Sorry, I didn't express myself clearly, I meant your change,
> if exclude the SOCK_RCU_FREE part, basically reverts this commit:
> 
> commit 3f660d66dfbc13ea4b61d3865851b348444c24b4
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu May 3 03:17:14 2007 -0700
> 
>     [NETLINK]: Kill CB only when socket is unused
> 
> IOW, ->release() is called when the last sock fd ref is gone, but ->destructor()
> is called with the last sock ref is gone. They are very different.

Hmm...


> I am confused, what Subash reported is a kernel warning which can
> surely be fixed by removing genl lock (if it is correct, I need to double
> check), so why for net-next?

Because Subash pointed to a buggy commit.

We want to fix all issues bring by this commit, not only the immediate
problem about mutex.

I have no idea if we can safely remove the mutex from genl_lock_done() :

The genl_lock() is not only protecting the socket itself, it might
protect global data as well, or protect some kind of lock ordering among
multiple mutexes.

Have you checked all genl users, down to linux-4.0 , point where commit
21e4902aea80ef35a was added ?

Herbert, Thomas, your help would be appreciated, thanks.
