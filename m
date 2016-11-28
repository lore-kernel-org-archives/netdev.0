From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Sun, 27 Nov 2016 22:53:21 -0800
Message-ID: <CAM_iQpXB_LRqE83cWwU0ZDckLWPrMcZg-yD4+NKy+rBVz3YAyw@mail.gmail.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
 <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
 <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUnz2kkjOFuk3fKKEYDh54b9WHk1dvH098mGtrGTPjZFQ@mail.gmail.com> <1480263824.18162.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35001 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754053AbcK1Gxn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 01:53:43 -0500
Received: by mail-io0-f181.google.com with SMTP id a124so214496942ioe.2
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 22:53:42 -0800 (PST)
In-Reply-To: <1480263824.18162.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 8:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-11-26 at 22:28 -0800, Cong Wang wrote:
>> On Sat, Nov 26, 2016 at 6:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>> > Are you telling me inet_release() is called when we close() the first
>> > file descriptor ?
>> >
>> > fd1 = socket()
>> > fd2 = dup(fd1);
>> > close(fd2) -> release() ???
>>
>> Sorry, I didn't express myself clearly, I meant your change,
>> if exclude the SOCK_RCU_FREE part, basically reverts this commit:
>>
>> commit 3f660d66dfbc13ea4b61d3865851b348444c24b4
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Thu May 3 03:17:14 2007 -0700
>>
>>     [NETLINK]: Kill CB only when socket is unused
>>
>> IOW, ->release() is called when the last sock fd ref is gone, but ->destructor()
>> is called with the last sock ref is gone. They are very different.
>
> Hmm...
>
>
>> I am confused, what Subash reported is a kernel warning which can
>> surely be fixed by removing genl lock (if it is correct, I need to double
>> check), so why for net-next?
>
> Because Subash pointed to a buggy commit.
>
> We want to fix all issues bring by this commit, not only the immediate
> problem about mutex.
>
> I have no idea if we can safely remove the mutex from genl_lock_done() :

I meant removing it only for the destructor case, we definitely can't remove
it for the dump case.

>
> The genl_lock() is not only protecting the socket itself, it might
> protect global data as well, or protect some kind of lock ordering among
> multiple mutexes.
>
> Have you checked all genl users, down to linux-4.0 , point where commit
> 21e4902aea80ef35a was added ?
>

I just took a deeper look, some user calls rhashtable_destroy() in ->done(),
so even removing that genl lock is not enough, perhaps we should just
move it to a work struct like what Daniel does for the tcf_proto, but that is
ugly... I don't know if RCU provides any API to execute the callback in process
context.
