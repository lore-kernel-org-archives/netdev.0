From: Tom Herbert <tom@herbertland.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Mon, 19 Dec 2016 18:07:41 -0800
Message-ID: <CALx6S340vCsaymbx+CcKL3Zi2p9EvDSwc0fDAxKsSqs4C2p5kg@mail.gmail.com>
References: <1481928610.17731.0@smtp.office365.com> <e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
 <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com> <20161219.205646.1955469060856026212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Josef Bacik <jbacik@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34638 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbcLTCHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 21:07:42 -0500
Received: by mail-qk0-f177.google.com with SMTP id q68so35045688qki.1
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 18:07:42 -0800 (PST)
In-Reply-To: <20161219.205646.1955469060856026212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 5:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Josef Bacik <jbacik@fb.com>
> Date: Sat, 17 Dec 2016 13:26:00 +0000
>
>> So take my current duct tape fix and augment it with more
>> information in the bind bucket?  I'm not sure how to make this work
>> without at least having a list of the binded addrs as well to make
>> sure we are really ok.  I suppose we could save the fastreuseport
>> address that last succeeded to make it work properly, but I'd have
>> to make it protocol agnostic and then have a callback to have the
>> protocol to make sure we don't have to do the bind_conflict run.  Is
>> that what you were thinking of?  Thanks,
>
> So there isn't a deadlock or lockup here, something is just running
> really slow, right?
>
Correct.

> And that "something" is a scan of the sockets on a tb list, and
> there's lots of timewait sockets hung off of that tb.
>
Yes.

> As far as I can tell, this scan is happening in
> inet_csk_bind_conflict().
>
Yes.

> Furthermore, reuseport is somehow required to make this problem
> happen.  How exactly?

When sockets created SO_REUSEPORT move to TW state they are placed
back on the the tb->owners. fastreuse port is no longer set so we have
to walk potential long list of sockets in tb->owners to open a new
listener socket. I imagine this is happens when we try to open a new
listener SO_REUSEPORT after the system has been running a while and so
we hit the long tb->owners list.

Tom
