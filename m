From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Fri, 10 Nov 2006 18:20:31 +0000
Message-ID: <20061110182031.GO29920@ftp.linux.org.uk>
References: <20061108221332.GI29920@ftp.linux.org.uk> <45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net> <4554A811.5060402@hp.com> <20061110173422.GM29920@ftp.linux.org.uk> <4554BC17.8020809@hp.com> <20061110180534.GN29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33163 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1161934AbWKJSUh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 13:20:37 -0500
To: Brian Haley <brian.haley@hp.com>
Content-Disposition: inline
In-Reply-To: <20061110180534.GN29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 10, 2006 at 06:05:34PM +0000, Al Viro wrote:
> On Fri, Nov 10, 2006 at 12:51:19PM -0500, Brian Haley wrote:
> > Al Viro wrote:
> > >On Fri, Nov 10, 2006 at 11:25:53AM -0500, Brian Haley wrote:
> > >>Since the only difference between echo requests and echo replies is the 
> > >>ICMPv6 type value (which is a difference of 1), just subtracting one 
> > >>from the request checksum will result in the correct checksum for the 
> > >>reply.
> > >
> > >Um, no.  That will *not* result in correct checksum.  Please, RTFRFC 1071.
> > 
> > I verified this works for echo request/reply on my IA64 box, 
> > double-checked with ethereal/wireshark.  Is there something specific in 
> > RFC 1071 that I should be looking for?
> 
> Definition of checksum.
> 
> See also include/net/ip.h::ip_decrease_ttl() for similar situation.

Note that even on little-endian you want
	3 -> 2
	2 -> 1
	1 -> 0xffff
	0 -> 0xfffe

On big-endian you get

	0x102 -> 2
	0x101 -> 1
	0x100 -> 0xffff
	0xff  -> 0xfffe
	...
	0     -> 0xfeff

so -= 1 is broken even on ia64 and it's *always* broken on big-endian
boxen.
