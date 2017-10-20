From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Get rid of RCU callbacks in TC filters?
Date: Thu, 19 Oct 2017 20:15:41 -0700
Message-ID: <CAM_iQpW90BZaKHkFhvuYJLWDg85m6ec7secv3whc5emy7EfsMQ@mail.gmail.com>
References: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
 <20171018193548.GM3521@linux.vnet.ibm.com> <52808e54-2f59-49c8-37be-d226e79fe286@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Chris Mi <chrism@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:54844 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdJTDQC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 23:16:02 -0400
Received: by mail-pf0-f196.google.com with SMTP id n89so8976643pfk.11
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 20:16:02 -0700 (PDT)
In-Reply-To: <52808e54-2f59-49c8-37be-d226e79fe286@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 8:34 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> My take on this would be to stay with the current RCU callbacks and try
> to simplify the implementation. Falling back to sync operations seems
> like a step backwards to me. I know update/delete of filters is currently
> a pain point for some use cases so getting the RTNL out of the way may
> become a requirement to support those (alternatively maybe batching is
> good enough).

For me it looks like very hard to make tc action destroy code completely
race-free in RCU callbacks, at least looks harder than getting rid of
RCU callbacks.


>
> I guess at a high level with Cris' patches actions are now doing reference
> counting correctly. If shared filters also do reference counting similarly
> we should be OK right? (yes I know simplifying maybe too much to be
> meaningful)

I don't know what you mean by "doing reference counting correctly",
if you mean making them atomic, as I already explained to Chris, it
is not necessary at all if we remove RCU callbacks. Refcnt doesn't
have to be atomic if it is always serialized with a lock.

>
> Are we aware of any outstanding problem areas?
>

Potentially many problems, since tc action destroy code could be
called either with a RTNL lock (fine) or in a RCU callback without
RTNL lock (buggy), these two paths race with each other and RCU
callbacks race among themselves too.
