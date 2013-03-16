From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: connect(2) reassociation regression
Date: Sat, 16 Mar 2013 07:51:07 -0700
Message-ID: <1363445467.29475.63.camel@edumazet-glaptop>
References: <20130316055632.GA21364@wilbur.25thandClement.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Ahern <william@25thandClement.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:48521 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737Ab3CPOvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 10:51:11 -0400
Received: by mail-pb0-f45.google.com with SMTP id ro8so5044752pbb.18
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 07:51:10 -0700 (PDT)
In-Reply-To: <20130316055632.GA21364@wilbur.25thandClement.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-15 at 22:56 -0700, William Ahern wrote:
> I've stumbled upon what may be a regression in connect(2) behavior.
> 
> My DNS library uses connect(2) to reassociate UDP sockets. That way the
> kernel can filter my packets, and it makes for cleaner code overall. The
> Linux manual page makes it pretty clear that this is okay, and at least one
> interpretation of POSIX (certainly the one I had) does as well.
> 
> At some point in the 3.x cycle (maybe after 3.2.0) something was changed.
> Whereas previously any reassociation worked, regardless of destination
> network, now if the _first_ association is to the loopback, any subsequent
> association to non-loopback fails with EINVAL. However, if the loopback is
> the second or later association then everything continues to work. In other
> words, the sequence
> 
> 	connect(127.0.0.1), connect(8.8.8.8)
> 
> fails with EINVAL, but
> 
> 	connect(8.8.8.8), connect(127.0.0.1), connect(1.2.3.4)
> 
> succeeds.
> 
> I admit that originally I simply presumed that on each reassociation the
> kernel would handle reassociating the source address in addition to the
> destination address. The technique worked everywhere I tested, including
> Linux, Solaris, NetBSD, OpenBSD, FreeBSD. And I should note that it even
> worked when reassociating to different external networks (and still works on
> everything but Linux, AFAICT).
> 
> I realize now that arguably POSIX only requires that a second connnect call
> change the destination address, and not the source address. But what would
> be the point of allowing a reassociation if the source address is never
> changed? Because any two addresses may route to entirely different networks
> or over different devices, the capability to reassociate would be pointless.
> 
> OTOH, if you explicitly called bind before connect, most systems these days
> will unbind the source address when reassociating. That may be undesirable
> behavior, but it is long-standing behavior AFAICT, including on Linux. One
> way to bypass the new Linux behavior is to reset the socket with
> connect(AF_UNSPEC), but under the pedantic interpretation of POSIX that's
> not guaranteed to work.

There is an issue as the connect() call sets both local address:port and
remote address, in the case the local address was not already set by a
prior bind().

And once bound to a local address, its not really clear if we are
allowed to bind to a different one, and fall in the possible traps of
SO_REUSEADDR and find another socket bound to the same local addr:port.

So if the second connect() also change the source port, I am pretty sure
some applications will badly break.

I would just avoid the problem of handling this mess, and let the
application close the socket and allocate a new one.

Changing the kernel behavior on these kind of unspecified stuff might
break some other applications.

Clearly the BSD API was bad, as the connect() is a 'super operation',
not only setting the remote address:port, but also the local
address:port given the current routing table.
