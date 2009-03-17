From: Brian Haley <brian.haley@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Mon, 16 Mar 2009 22:26:34 -0400
Message-ID: <49BF0A5A.2040501@hp.com>
References: <20090316233934.GD32111@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:36513 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbZCQC0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 22:26:38 -0400
In-Reply-To: <20090316233934.GD32111@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix von Leitner wrote:
> Here's an strace:
> 
> socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
> fcntl(3, F_GETFL)                       = 0x2 (flags O_RDWR)
> fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> bind(3, {sa_family=AF_INET6, sin6_port=htons(6969), inet_pton(AF_INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot assign requested address)
> 
> This is supposed to work, and it works on other operating systems, even
> on Mac OS X.
> 
> I think it used to work on Linux, too.
> 
> I'm using 2.6.29-rc7 right now, but others have reported this not
> working on distro kernels, too.

I don't think this ever worked on Linux, from the very beginning of inet6_bind():

        /* Check if the address belongs to the host. */
        if (addr_type == IPV6_ADDR_MAPPED) {
                v4addr = addr->sin6_addr.s6_addr32[3];
                if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
                        err = -EADDRNOTAVAIL;
                        goto out;
                }
        } else {

So if it's a mapped address, the lower 32-bits must contain a local address.
RFC 3493 doesn't specifically mention what to do with ::ffff:0.0.0.0, so this
looks like a gray area to me.

So are you trying to get IPv4-only behavior out of this socket?  Seems like the
wrong way to go about it.

-Brian
