From: Tom Marshall <tom@cyngn.com>
Subject: Re: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Wed, 11 Feb 2015 21:24:28 -0800
Message-ID: <20150212052428.GB10785@eden.sea.cyngn.com>
References: <20150212005844.GB3829@nwwn.com>
 <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:46992 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbBLFYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 00:24:32 -0500
Received: by mail-pa0-f53.google.com with SMTP id lf10so8872067pab.12
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 21:24:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2015 at 08:06:14PM -0800, Eric Dumazet wrote:
> On Wed, 2015-02-11 at 16:58 -0800, Tom Marshall wrote:
> > Port zero is reserved according to IANA.
> > 
> > Note UDP sendto is already disallowed if dport is zero.
> 
> I have no idea why we should prevent such thing.

* It is marked "reserved" by IANA.

* UDP packets with dport=0 are already prevented from being sent.

* Many routers will either drop the packets or, worse, send back a RST to a
  SYN destined for port 0.

> There is nothing wrong sending a TCP frame with dport=0, even if
> practically it is not possible to setup a listener on such port using
> BSD API.

Then why not allow UDP packets with dport=0?



For background, I encountered this via a test fail in Google's Android CTS. 
Their test suite tries to ensure that a Java level connect with a specified
timeout functions properly by establishing a TCPv4 connection to a verified
unreachable address on the internet.  It happens to use port 0 as a
destination port.  I observed that sometimes this test succeeds and
sometimes it fails.  When it fails, tcpdump shows a RST coming back.  And
that RST is coming from a local router on one of the networks that I am
frequently on.

After doing some research and seeing the UDP sendto behavior, I figured it
would be good to have consistency between sendto() and connect(), and also
make it obvious to userspace that dport=0 is not permitted in any form.

Note that the latest CTS code does have a "fix" for this ... which was not
to switch ports, but to handle the case where ECONNREFUSED is returned
before the connect timeout expires... :/
