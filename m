From: David Miller <davem@davemloft.net>
Subject: Re: zd1211rw (2.6.22 sparc64): unaligned access (do_rx)
Date: Tue, 20 Nov 2007 04:34:23 -0800 (PST)
Message-ID: <20071120.043423.42170421.davem@davemloft.net>
References: <4740DF47.4040206@hotmail.com>
	<20071119.002755.77617097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: shaddy_baddah@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760025AbXKTMeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 07:34:23 -0500
In-Reply-To: <20071119.002755.77617097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Nov 2007 00:27:55 -0800 (PST)

> From: Shaddy Baddah <shaddy_baddah@hotmail.com>
> Date: Mon, 19 Nov 2007 11:56:39 +1100
> 
> > If I try to scan for APs using iwlist, I get one AP listed, before a bus 
> > error occurs. This of course, does not suggest that the problem is with 
> > the driver, but I mention it for the record.
> 
> This is an unaligned data access in the userland tools.
> Try to catch it with GDB and give us ths backtrace.

I think I've figured out what's happening here.

The kernel makes no effort whatsoever to translate iwe streams in
compat environments.  And userspace then tries to "correct" this and
does so miserably.  Likely this is what causes the bus error.

The fix is that we need to add some handling code
fs/compat_ioctl.c:do_wireless_ioctl() for the case where we are
returning an iwe stream (SIOCGIWSCAN).

It should not be very difficult to do this, since the compat format
will be the same size or smaller, it should be easy to recode the
thing in-place in the user buffer.

So you make a pass over the user buffer fixing things up and then you
adjust the iw_data length for the new size.

Alternatively, you can allocate a kernel buffer for this, use a 'fs =
get_fs(); set_fs(KERNEL_DS); ioctl(); set_fs(fs);' sequence, fixup the
iwe stream, then copy the everything back out to userspace.

Then we can delete all of this incredibly stupid code in the wireless
tools that attempts to fix this up in userspace.

Can someone implement this and test it or send Shaddy a patch to test?

Thanks.
