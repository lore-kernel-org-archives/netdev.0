From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 connect() from site-local to global IPv6 address.
Date: Sat, 06 May 2006 15:47:13 +0100
Message-ID: <1146926830.2503.67.camel@shinybook.infradead.org>
References: <1146862832.2766.54.camel@pmac.infradead.org>
	 <20060506.091920.122414672.yoshfuji@linux-ipv6.org>
	 <1146876802.2503.32.camel@shinybook.infradead.org>
	 <20060506.113904.63157190.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35531 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750774AbWEGAkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 20:40:11 -0400
Received: from shinybook-bcm.infradead.org ([2001:8b0:10b:1:20a:95ff:fef3:9992] helo=shinybook.infradead.org)
	by pentafluge.infradead.org with esmtpsa (Exim 4.62 #1 (Red Hat Linux))
	id 1FcXJh-0002XT-Rr
	for netdev@vger.kernel.org; Sun, 07 May 2006 01:40:10 +0100
Received: from dwmw2 by shinybook.infradead.org with local (Exim 4.62 #1 (Red Hat Linux))
	id 1FcXJZ-0008Fv-Dr
	for netdev@vger.kernel.org; Sun, 07 May 2006 01:40:01 +0100
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060506.113904.63157190.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-05-06 at 11:39 +0900, YOSHIFUJI Hideaki wrote:
> In article <1146876802.2503.32.camel@shinybook.infradead.org> (at Sat, 06 May 2006 01:53:21 +0100), David Woodhouse <dwmw2@infradead.org> says:
> 
> > There is a default route, because I believe that's the only thing that
> > radvd can do. I cannot advertise a route to _only_ fec0::/16, can I?
> 
> Yes, you can, via Route Information option.
> (>= 2.6.17-rc1 support this.)

Hm. Has radvd also been updated to send it, or did I miss it when I
looked for such an option?

Either way, this isn't particularly useful to me yet, since no deployed
systems support it.

> Anyway, it is valid to use (obsolete) site-local source address
> for global destination address.
> The problem seems that router does NOT send ICMPv6 destination
> unreachable to the sender. I don't know why, but it SHOULD. 

I'll pursue that question later. It wouldn't be _sufficient_ since there
are (buggy) programs, including Evolution, which will not fall back to
the second and subsequent addresses from getaddrinfo() -- they'll just
give up when the first attempt to connect fails. So we really do need
the IPv4 address to be listed _first_ in the results, as it used to be.

Glibc _used_ to do what we want -- I always attributed it to Rule 2 of
the destination address selection, without looking hard at the
implementation details.

Let's forget about any details of my current implementation and I'll ask
a _simple_ question...

I have machines on an internal company network, which is all RFC1918
IPv4 addresses and has connectivity by NAT to the outside world. These
machines are mostly Linux, of various versions. 

I wish to deploy IPv6 internally so that we can develop and test IPv6
support. There is _no_ chance of getting proper IPv6 connectivity to the
outside world through the corporate firewall. I'd like IPv6 to be usable
_internally_ though, without breaking connectivity to the outside world
over IPv4.

How should I do this?


In the past, I've done it with site-local addresses. A machine on each
Ethernet subnet runs radvd, and machines pick up a site-local address
(and default route) automatically. The machines running radvd also have
IPv6-over-IPv4 tunnels for routing between subnets. 

Glibc's getaddrinfo() has in the past given me optimal behaviour. If
connecting to a remote machine which has a site-local IPv6 address, it's
favoured that site-local address. If connecting to a remote machine
which has a _Global_ IPv6 address, it's given the IPv4 address first
instead.

On new kernels, however, glibc has started to return IPv6 addresses even
for external machines which can't be reached. Hence my mail about
$SUBJECT. If I'm doing this the wrong way, what _should_ I be doing?

Uli's response has been to switch glibc so that it _always_ favours IPv4
over IPv6, which AIUI basically means that IPv6 will never get _any_
usage on Linux machines unless in an IPv6-only environment rather than
dual-stack. I.e. Unless I publish _only_ an AAAA record for my server
instead of both A and AAAA records, I won't get any IPv6 traffic. I
think it would be best to avoid that situation.

-- 
dwmw2
