From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT,
 expected EINVAL/ENOTTY
Date: Sat, 09 Dec 2006 01:05:45 -0800 (PST)
Message-ID: <20061209.010545.126590710.davem@davemloft.net>
References: <20061208140021.27e9ab2d@freekitty>
	<20061208.163349.74721527.davem@davemloft.net>
	<457A6E83.2070708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org, hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S936480AbWLIJFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 04:05:39 -0500
To: dada1@cosmosbay.com
In-Reply-To: <457A6E83.2070708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 09 Dec 2006 09:06:27 +0100

> Well, as long you/we dont break isattty() (which try an 
> ioctl(fd,TCGETS,&termios) on the fd), it should be OK.
> 
> So TCGETS *MUST* return an error on a socket (and other non tty files)

Actually, did anyone actually bother to look at what's happening
here in this case?  It's not an ioctl number aliasing issue at
all, rather dev_ioctl() blindly tries to copy a structure in
from userspace before checking the ioctl number against the
list of ioctls it actually understands.

That's the bug, anyone care to code up the fix to guard that
copy_from_user() call in dev_ioctl() with a big switch statement
verification on the ioctl number?

Something like:

	switch (cmd) {
	case SIOC*:
		break;
	default:
		if (cmd == SIOCWANDEV ||
		    (cmd >= SIOCDEVPRIVATE &&
		     cmd <= SIOCDEVPRIVATE + 15))
			break;
		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
			break;
		return -EINVAL;
	}
	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
		return -EFAULT;

Thanks.
