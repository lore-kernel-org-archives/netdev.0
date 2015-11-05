From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 10:07:29 +0100
Message-ID: <4931220.z2MFa8LzkQ@wuerfel>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:62278 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030521AbbKEJHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 04:07:37 -0500
In-Reply-To: <20151105.000414.1682124328670738318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 November 2015 00:04:14 David Miller wrote:
> As part of fixing y2038 problems, Arnd is going to have to make a new
> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
> the time values to 64-bit.
> 
> So I want everyone to think about whether there are any other changes
> we might want to make given that we have to make a v4 anyways.
> 
> Particularly, I am rather certain that the buffer management could be
> improved.  Some have complained that v3 is kinda awkward to use and/or
> suboptimal is various ways.

I have taken a closer look at the actual timestamp data now, and noticed
that we use __u32 for both tp_sec and ts_sec in the user visible data.
This means that once we fix the internal implementation to use 64-bit
timestamps, we actually won't overflow until 2106 because the 2038 overflow
is only for signed 32-bit numbers as we have in 'struct timespec'.

So the good news is that we can keep the existing v1 through v3 formats
beyond 2038, but only as long as all user space that cares about the
value also interprets it as unsigned.

If we want to have a v4 format anyway, there are a few consideration
for the format of the timestamps: I generally recommend using __u64
nanoseconds rather than split second/nanosecond, as that simplifies
the code in most cases and makes it more efficient, unless you
actually need the seconds portion on a system that does not have
a 64-bit divide instruction (most 32-bit architectures).

Also, most subsystems are moving to 'monotonic' (counting seconds
from boot, and not impacted by settimeofday(), leap seconds or
ntp jumps) timestamps, but it's not clear if that is the best choice
here, because it won't work for hardware timestamps that actually
use real time. If we do this, we probably also need a field to
store the clockid.

	Arnd
