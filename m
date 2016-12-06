From: Colin Cross <ccross@android.com>
Subject: Re: "af_unix: conditionally use freezable blocking calls in read" is wrong
Date: Tue, 6 Dec 2016 10:37:52 -0800
Message-ID: <CAMbhsRSJq2WsOiT=Cw+OoO4EFX7ipr9pejECvVfec2k3HGmkdQ@mail.gmail.com>
References: <20161204210455.GI1555@ZenIV.linux.org.uk> <20161204.214214.1868750446620130834.davem@davemloft.net>
 <20161205035241.GJ1555@ZenIV.linux.org.uk> <CAM_iQpXn7ssNpxviX+sLf0k-88GoWubcBeoMW=JkZTh_q8iKdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:35479 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753115AbcLFSh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 13:37:59 -0500
Received: by mail-wj0-f181.google.com with SMTP id v7so332698338wjy.2
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 10:37:58 -0800 (PST)
In-Reply-To: <CAM_iQpXn7ssNpxviX+sLf0k-88GoWubcBeoMW=JkZTh_q8iKdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 5, 2016 at 8:24 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Dec 4, 2016 at 7:52 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Sun, Dec 04, 2016 at 09:42:14PM -0500, David Miller wrote:
>>> >     I've run into that converting AF_UNIX to generic_file_splice_read();
>>> > I can kludge around that ("freezable unless ->msg_iter is ITER_PIPE"), but
>>> > that only delays trouble.
>>> >
>>> >     Note that the only other user of freezable_schedule_timeout() is
>>> > a very different story - it's a kernel thread, which *does* have a guaranteed
>>> > locking environment.  Making such assumptions in unix_stream_recvmsg(),
>>> > OTOH, is insane...
>>>
>>> We have to otherwise Android phones drain their batteries in 10
>>> minutes.
>>>
>>> I'm not going to revert this and be responsible for that.

This is an optimization for going in and out of suspend without
context switching through blocked processes, reverting it will not
cause batteries to drain in 10 minutes.  On my phone, it would cause
~83 context switches on each transition in and out of suspend, which
sometimes happens every 1-5 seconds on noisy networks, but more
normally happens on the order of minutes.

>>>
>>> So you have to find a way to make the freezable calls legitimate.
>>
>> Oh, well...  As I said, I can kludge around that - call from
>> generic_file_splice_read() can be distinguished by looking at the
>> ->msg_iter->type; it still means unpleasantness for kernel_recvmsg()
>> users - in effect, it can only be called with locks held if you know that
>> the socket is not an AF_UNIX one.
>>
>> BTW, how do they deal with plain pipes?
>
> I suppose this question is for Colin. ;)

The original patch set is at https://lkml.org/lkml/2013/4/29/495.  It
was targeted to the sites on which many threads were blocked on an
Android device, pipe_wait didn't show up high on the list (there is
only 1 thread blocked on pipe_wait on my phone right now), so I didn't
look at it.
