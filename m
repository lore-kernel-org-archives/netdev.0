From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Sat, 11 Nov 2006 01:45:48 +0000
Message-ID: <20061111014548.GQ29920@ftp.linux.org.uk>
References: <45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net> <4554A811.5060402@hp.com> <20061110173422.GM29920@ftp.linux.org.uk> <4554BC17.8020809@hp.com> <20061110180534.GN29920@ftp.linux.org.uk> <20061110182031.GO29920@ftp.linux.org.uk> <4554CD40.3030801@hp.com> <20061110191715.GP29920@ftp.linux.org.uk> <4554E9EC.1070803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37318 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1946872AbWKKBpv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 20:45:51 -0500
To: Brian Haley <brian.haley@hp.com>
Content-Disposition: inline
In-Reply-To: <4554E9EC.1070803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 10, 2006 at 04:06:52PM -0500, Brian Haley wrote:
> Al Viro wrote:
> >On Fri, Nov 10, 2006 at 02:04:32PM -0500, Brian Haley wrote:
> >>Al Viro wrote:
> >>>so -= 1 is broken even on ia64 and it's *always* broken on big-endian
> >>>boxen.
> >>It's not broken in ia64, I've tested that, just don't have an x86 for 
> >>testing right now.  Can you please apply these changes and prove it's 
> >>broken?  This little trick has been done in other UNIXes for years 
> >>without any problems.
> >
> >Could you fscking read what you've replied to?  Your -=1 will turn 0
> >into 0xffff instead of correct 0xfffe.  IOW, it's broken in 1:65536
> >cases.
> 
> I looked again at your previous email:
> 
> >Note that even on little-endian you want
> >	3 -> 2
> >	2 -> 1
> >	1 -> 0xffff
> >	0 -> 0xfffe
> 
> That doesn't look right to me, but I'll take your word that there's one 
> edge case out there I don't see (even though this worked on Alpha). 

Sigh...  Here's how the checksum is defined:
	take array of bytes
	pad it to even length with 0
	split it into 16bit words
define x # y as (x + y) < 0x10000 ? x + y: x + y - 0xffff
	calculate sum = w0 # w1 # w2 # ..... # wn
	take 0xffff - sum (aka ~sum)
	store the resulting value in pair of bytes (with whatever
endianness you used all along).

Note that resulting pair of bytes does *not* depend on endianness.  See
aforementioned RFC for proof and for more fun properties of that sucker.
