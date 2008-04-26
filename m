From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Sat, 26 Apr 2008 00:00:49 -0700
Message-ID: <OF7B59958D.88AA9A1D-ON88257437.0023AEDC-88257437.00268638@us.ibm.com>
References: <20080425.223130.04936392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45634 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbYDZHAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 03:00:55 -0400
In-Reply-To: <20080425.223130.04936392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Miller wrote on 04/25/2008 10:31:30 PM:

> Regardless, using packed has several other side effects you absolutely
> do not want.  It causes words to be loaded using byte loads on RISC
> architectures, because no alignment assumptions can be made at all
> about packed objects.

        Isn't that appropriate in the general case? If the architecture
actually required 8-byte alignment to access the type and we only have
4-byte alignment because the app was compiled with different (32 bit)
alignment rules, then we'd fault if we forced the alignment and accessed
it directly. That's why we don't access it directly. In these, we're
using the (byte) copy functions to get the (totally inappropriately
aligned because it wasn't compiled in 64-bit mode) data to the well
behaved and aligned in-kernel copy of the struct and from there (only)
do we access them as structured objects. If the copy code is clever
enough to use word copies when alignment allows, and byte copies for
the ends, then all we have to care about is that the byte-offset we copy
from is correct for the app-compiled architecture.

        I don't think the point is that important here, because all of 
these
methods identically describe the 32-bit data layout (which is all we
need-- could even use a char array for the source data since we know
the offsets very well!), and we use the copy functions to get it to the
layout we need. So I may be missing your point, but I don't need to 
belabor
it all the same. :-)
        The only reason I didn't want to use aligned(4) for 
sockaddr_storage
is because it's just another single-use declaration. It seems to me plain
old packed is defined by the C language to have the proper offsets on all
architectures for these declarations, and all of these others 
modifications
are no better since they all lead to the same thing. But so would
(char *)optval + 4; as the start of the gr_group, say. We don't use the
compat struct's for anything but a handy way to describe those byte 
offsets.

        Anyway, I belabored. I'll change to aligned(4) with 
compat_sockaddr_storage
declaration...

> 
> Please use aligned(4), it should be totally sufficient.
> 
> >         In this case, we want no pad, so packed is the relevant part. 
If
> > had a char followed by a struct as in your previous example, the right
> > way to get 4-byte alignment is both aligned(4) and packed. Leaving off
> > packed would allow 8-byte or 16-byte (or 12 :-)) alignment, too.
> 
> Have you seen this in practice?

        I did see that plain old structure field __attribute((4))__
wasn't correct (still padded), and gcc docs use the same language
to define the behavior for structure field attribute "aligned" and
type attribute "aligned" (at least with my limited research). So,
it surprised me that the field attribute results in pad and the
type attribute doesn't, and I wonder if it's good to rely on that
difference given the same documentation for both as "minimum alignment".
But if the compiler changes its notion of when to pad this in a way
that breaks it, we can always revisit it later. :-)

                                                                +-DLS

 

