From: Paul Moore <paul@paul-moore.com>
Subject: Re: SELinux/IP_PASSSEC regression in 4.13-rcX
Date: Mon, 24 Jul 2017 10:42:47 -0400
Message-ID: <CAHC9VhRjju-_3V21x+BogdRg-brDho1g_HzW+0CvU0PbhEtQqw@mail.gmail.com>
References: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
 <1500899117.2458.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:37234 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755931AbdGXOmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 10:42:50 -0400
Received: by mail-lf0-f54.google.com with SMTP id m86so38083127lfi.4
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 07:42:49 -0700 (PDT)
In-Reply-To: <1500899117.2458.2.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 8:25 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> Hi,
>
> On Fri, 2017-07-21 at 18:19 -0400, Paul Moore wrote:
>> I've been seeing a SELinux regression with IP_PASSSEC on the v4.13-rcX
>> kernels and finally tracked the problem down to the
>> skb_release_head_state() call in __udp_queue_rcv_skb().  Looking at
>> the code and the git log it would appear that the likely culprit is
>> 0a463c78d25b ("udp: avoid a cache miss on dequeue
>> "); it looks similar to IP option problem fixed in 0ddf3fb2c43d2.
>
> Thank you for the report!
> My bad, I completely missed that code path.

Hi Paolo,

No problem, things get missed from time to time, especially when we
deal with things that cross subsystems.

>> From a SELinux/IP_PASSSEC point of view we need access to the skb->sp
>> pointer to examine the SAs.  I'm posting this here without a patch
>> because it isn't clear to me how you would like to fix the problem; my
>> initial thought would be to simply make the skb_release_head_state()
>> conditional on the skb->sp pointer, much like the IP options fix, but
>> I'm not sure if you have a more clever idea.
>
> Unfortunately explicitly checking skb->sp at skb free time will defeat
> completely the intended optimization.
>
> To preserve it, something like the following patch is required, could
> you please test it in your environment?
>
> Such patch is still prone to a kind of race, as only UDP packets
> enqueued to the UDP socket after the setsockopt() will carry the
> relevant cmsg info.
>
> e.g. with the following event sequence:
>
> <an UDP packet is enqueued to the revevant socket>
> setsockopt(...,IP_CMSG_PASSSEC)
> recvmsg(...);
>
> the ancillary message data will not include the IP_CMSG_PASSSEC, while
> kernel pre 0a463c78d25b will provide it. Do you think such behavior
> will be acceptable?
>
> If not, I fear a revert will be needed.

The change in behavior for userspace makes me a little nervous as
there is no way of knowing how any random application may be coded.
Even if we are confident that the majority of applications set
IP_PASSSEC before calling bind(), we are likely still stuck with a few
that will break, and that means a lot of hard to debug problem
reports.

I would feel much more comfortable if we could preserve the existing behavior.

-- 
paul moore
www.paul-moore.com
