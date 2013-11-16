From: mpb <mpb.mail@gmail.com>
Subject: Re: [PATCH v3] net: don't return uninitialized addresses on
 concurrent socket shutdown
Date: Sat, 16 Nov 2013 13:57:12 -0800
Message-ID: <CAApbN=K4gMqsk1SEPfdR1+J0CgoxYDONSi83TPNMxxHisXmA9A@mail.gmail.com>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com>
	<CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
	<20131116054344.GG26901@order.stressinduktion.org>
	<20131116054814.GH26901@order.stressinduktion.org>
	<20131116191916.GC16541@order.stressinduktion.org>
	<1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35412 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab3KPV5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 16:57:12 -0500
Received: by mail-ob0-f176.google.com with SMTP id wp4so5378244obc.21
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 13:57:12 -0800 (PST)
In-Reply-To: <1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> @@ -1847,6 +1848,8 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
>>       err = sock_recvmsg(sock, &msg, size, flags);
>>
>>       if (err >= 0 && addr != NULL) {
>> +             if (unlikely(address.ss_family == AF_INVALID))
>> +                     memset(&address, 0, sizeof(address));

Or perhaps only when err == 0?

      if (err >= 0 && addr != NULL) {
+             if ( (err == 0)  &&  unlikely(address.ss_family == AF_INVALID) )
+                     memset(&address, 0, sizeof(address));

In other words, in pseudo code:

When err == 0, the kernel checks to make sure the socket has not been
shutdown before calling move_addr_to_user.
If err == 0 and a shutdown has happened, then set addr to a value that
signifies that a shutdown was detected (or at least that a message was
not received).  After a shutdown, I believe err will only be one of 0
or -1.  If err > 0, then a shutdown has not happened.

Another approach would be to return -1 to userland and set errno to
something like EWOULDBLOCK.

Another thought: addr_len is probably smaller than sizeof(address), so
only memset whichever is smaller.

If I had a *BSD box or VM sitting around, I would look to see what
*BSD does (and perhaps copy the *BSD behavior if it were acceptable).

Eric Dumazet wrote:
> I really don't think userland should expect to read 128 null bytes if it
> asked 128 bytes.
>
> We can certainly return 2 null bytes (AF_UNSPEC)

AF_UNSPEC is good (and sufficient, IMO).

Do we need to add AF_INVALID at all?  Why not just use AF_UNSPEC?

> and comply with the documentation.

What documentation?  The interesting thing about this situation is I
have not seen any manpage that describes what should happen after a
concurrent shutdown.

-mpb
