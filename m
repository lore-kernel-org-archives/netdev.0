From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Thu, 9 May 2013 14:11:34 -0400
Message-ID: <CAAsGZS49POkSAumqQPkVT61i3Tz7+qqiRL5C2HrUCENTW5xw+Q@mail.gmail.com>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
	<CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com>
	<518968DF.9070008@redhat.com>
	<CAAsGZS5SrH7vJ=dd+2JkpAF7RS1UGv09kU+nCjw-qXhDV7SZTA@mail.gmail.com>
	<518AF306.8020307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:47315 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab3EISLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 14:11:38 -0400
Received: by mail-la0-f48.google.com with SMTP id eg20so3121017lab.21
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 11:11:35 -0700 (PDT)
In-Reply-To: <518AF306.8020307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 8, 2013 at 8:51 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
>
> I'm sorry Chetan, I still don't see the justification. If the user does
> crap, he'll get an -EINVAL when trying to setup an {R,T}X_RING wrongly.

No :). The open_block check is a runtime thingy and not at
ring_init/mmap time(At init time, the mmap'd block is zero'd by the
kernel and so you will not detect this). The open_block check will be
triggered by an incoming frame.

> How he access frames in his application and give them back to the kernel,
> he will get from some docs. Do you really think that such users who write
> crappy applications will care to look into the Linux kernel source code
> to locate the warning and know that this might be in relation to their

Normally people(sane code) will look for the return value from a
syscall. mmap is special because there's no syscall to run once you
mmap/setup the rings. Since there's no syscall there's no return
value. That's why we try to detect it at run-time and try to WARN the
user if we can.

> code? Rather, in best case, they might send a bug report to netdev where
> you have to tell them that it's not a kernel bug, but a bug in their user
> space application.
>

No, we wouldn't know if it's a kernel bug or a user-triggered bug. All
we can infer is that something is not right. But you are correct you
can't tell if it's a kernel/user bug. So the original WARN stmt was
printing the status_bit. We can add a text - "memory
mismatch/corruption detected. Either due to kernel or user code."

> Fact is, we currently do *not* warn him in case of TPACKET_V1 or TPACKET_V2
> either, and yet it works for users! Neither do we warn in case of an

By works, it means the corruption goes un-noticed and un-detected.

The get_frame_status function simply returns if the correct status
isn't set in the frame. In the _v3 it's a little different because we
only check for
the BLOCK_STATUS and not the frame_status.

> RX_RING nor TX_RING. So we *cannot* have double standards here, either we
> do not warn at all or we do warn in *every* case. (What would give
> justification to only WARN in TPACKET_V3 but not in TPACKET_V1 and
> TPACKET_V2 while they all are based on the same underlying technology?)

The v1/v2 behavior is still intact. i.e. - they don't get the warning.
But by removing the WARN, we have now changed the _v3 behavior from
kernel 3.3.

>
> And personally, I think the first case is more sane. Imho, the kernel is
> not responsible to do *bug reports* to the user in this scenario. It makes
> sense when you have syscalls and return an -EINVAL with possible cause
> explanations in man pages, but we don't have this here. I think it doesn't

Can't return -EINVAL after mmap goes live - explained above.



>
> If you think differently, then please go ahead and and put WARNs all over
> the place for all other TPACKET versions as well and also for netlink's

I don't think I'm asking to change the existing behavior of other
flavors and that too for shipping releases. I can send the patch just
for _v3 but wanted to first discuss it on netdev and didn't want to
step on your patch.


>
> Thanks,
>
> Daniel

Chetan
