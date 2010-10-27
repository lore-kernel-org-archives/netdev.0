From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 11:51:19 -0700
Message-ID: <AANLkTikKZdq9u0+Nkd4wtEcAZMT3YCPaXMv6FZaafetc@mail.gmail.com>
References: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
 <20101027.102940.112580564.davem@davemloft.net> <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
 <20101027.105047.183059900.davem@davemloft.net> <1288203979.1836.2.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51598 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752046Ab0J0SwP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 14:52:15 -0400
Received: from mail-gx0-f174.google.com (mail-gx0-f174.google.com [209.85.161.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9RIpiQU031669
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 11:51:45 -0700
Received: by gxk23 with SMTP id 23so667019gxk.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 11:51:39 -0700 (PDT)
In-Reply-To: <1288203979.1836.2.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 11:26 AM, Dan Rosenberg
<drosenberg@vsecurity.com> wrote:
> The proposed fix is a start, but it's not sufficient to completely fi=
x
> the problem. =A0What if the total of the iovecs wraps around back to =
0?
> The total size will be returned as a small number, but large amounts =
of
> data will be copied into the allocated buffer since the individual
> iovecs can have arbitrary sizes.

That's why I suggested just fixing iovec_verify() to do this all. It
already walks the thing, and while it allows the overflow right now
(and only wants to make sure the end result is positive to separate it
out from error numbers), that was always a ugly thing to do.

And the thing is, once you disallow overflow, you really MUST NOT
return an error - you need to instead cap the max, the way I also did
in my patch.

Why? Because for a streaming thing, it's entirely possible that
somebody tries to write out a whole mmap'ed file in one go, for
example. Returning an error because somebody tries to write 8GB in one
single system call is wrong as it would result in the application
reporting an IO error - but saying "I will write out part of it" is
fine, and then it's up to the user to loop over it (it already needs
to do that for other reasons for partial IO).

So doing this in verify_iovec() (and verify_compat_iovec - which I
didn't do in my RFC patch) really does fix everything, and means that
the individual socket types never have to worry about the subtle cases
of overflow in any type.

                        Linus
