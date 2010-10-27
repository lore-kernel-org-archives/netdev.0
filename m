From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 10:37:46 -0700
Message-ID: <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
References: <1287704752.11051.79.camel@Dan> <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
 <20101027.102940.112580564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59925 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752965Ab0J0Rio convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 13:38:44 -0400
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9RHcE3C019569
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 10:38:15 -0700
Received: by vws13 with SMTP id 13so193366vws.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 10:38:09 -0700 (PDT)
In-Reply-To: <20101027.102940.112580564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 10:29 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> But for a datagram socket, we have to have a one-to-one correspondanc=
e
> between write() calls and packets on the wire. =A0So we'd either need=
 to
> accept the entire write() length or fail it with an error.

I disagree. We had that exact issue with regular file read/write: in
theory, POSIX says that you should never do a partial write to a
regular file.

And the thing is, WE SIMPLY DON'T CARE. If somebody does a 2GB+ IO,
they damn well need to accept that it's not going to be some atomic
single event. It doesn't matter _how_ much actual real memory you
have, it's just stupid to even care about that situation. It's not
something any real app actually can reasonably ever expect to work, so
rather than say "we have to do it right or error out", you should just
see it as a "it's a stupid situation, we can do whatever the hell we
want, because anybody who cares is a f*cking moron that we don't care
about".

If you _really_ care deeply, then some packet-oriented protocol can
just have its own private packet size limit (which would be way less
than 2GB), and then just look at the total size and say "oh, the total
size is bigger than my limit, so I'll just error out". Then, the fact
that verify_iovec() may have truncated the message to 2GB-1 doesn't
matter at all.

(Practically speaking, I bet all packet-oriented protocols already
have a limit that is enforced by simply allocation patterns, so I
don't think it's actually a problem even now)

                   Linus
