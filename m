From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Fri, 10 Nov 2006 19:17:15 +0000
Message-ID: <20061110191715.GP29920@ftp.linux.org.uk>
References: <20061108221332.GI29920@ftp.linux.org.uk> <45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net> <4554A811.5060402@hp.com> <20061110173422.GM29920@ftp.linux.org.uk> <4554BC17.8020809@hp.com> <20061110180534.GN29920@ftp.linux.org.uk> <20061110182031.GO29920@ftp.linux.org.uk> <4554CD40.3030801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60611 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1161497AbWKJTRS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 14:17:18 -0500
To: Brian Haley <brian.haley@hp.com>
Content-Disposition: inline
In-Reply-To: <4554CD40.3030801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 10, 2006 at 02:04:32PM -0500, Brian Haley wrote:
> Al Viro wrote:
> >so -= 1 is broken even on ia64 and it's *always* broken on big-endian
> >boxen.
> 
> It's not broken in ia64, I've tested that, just don't have an x86 for 
> testing right now.  Can you please apply these changes and prove it's 
> broken?  This little trick has been done in other UNIXes for years 
> without any problems.

Could you fscking read what you've replied to?  Your -=1 will turn 0
into 0xffff instead of correct 0xfffe.  IOW, it's broken in 1:65536
cases.

On big-endian boxen (which x86 is not, BTW), it will *always* give the
wrong result. -= htons(0x100) is better, but still fscks up in 1:256.

You _can_ adjust the checksum; however it's not that trivial.  One working
variant is
	if (sum > htons(0x100)
		sum -= htons(0x100);
	else
		sum += 0xffff - htons(0x100);
In little-endian case it turns into
	if (sum > 1)
		sum--;
	else
		sum += 0xfffe;
which is why your variant breaks rarely on itanic (or x86 - they are not
different in that respect).  You still need to handle that corner case,
though.

As for the various Unices doing the same trick, I suggest you to check
what they _really_ do and report bugs for those that have pure -- and
nothing else.

Again, the checksum is sum modulo 0xffff, *not* 0x10000.  And endianness
matters, of course, since the packet type is either LSB or MSB, depending
on it.
