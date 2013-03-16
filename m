From: William Ahern <william@25thandClement.com>
Subject: connect(2) reassociation regression
Date: Fri, 15 Mar 2013 22:56:32 -0700
Message-ID: <20130316055632.GA21364@wilbur.25thandClement.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [68.68.99.238] ([68.68.99.238]:34661 "EHLO
	wilbur.25thandClement.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751349Ab3CPGMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 02:12:07 -0400
Received: from wilbur.25thandClement.com (william@localhost.25thandClement.com [127.0.0.1])
	by wilbur.25thandClement.com (8.14.5/8.14.5) with ESMTP id r2G5uW85004205
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 22:56:32 -0700 (PDT)
Received: (from william@localhost)
	by wilbur.25thandClement.com (8.14.5/8.14.3/Submit) id r2G5uW8t022530
	for netdev@vger.kernel.org; Fri, 15 Mar 2013 22:56:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've stumbled upon what may be a regression in connect(2) behavior.

My DNS library uses connect(2) to reassociate UDP sockets. That way the
kernel can filter my packets, and it makes for cleaner code overall. The
Linux manual page makes it pretty clear that this is okay, and at least one
interpretation of POSIX (certainly the one I had) does as well.

At some point in the 3.x cycle (maybe after 3.2.0) something was changed.
Whereas previously any reassociation worked, regardless of destination
network, now if the _first_ association is to the loopback, any subsequent
association to non-loopback fails with EINVAL. However, if the loopback is
the second or later association then everything continues to work. In other
words, the sequence

	connect(127.0.0.1), connect(8.8.8.8)

fails with EINVAL, but

	connect(8.8.8.8), connect(127.0.0.1), connect(1.2.3.4)

succeeds.

I admit that originally I simply presumed that on each reassociation the
kernel would handle reassociating the source address in addition to the
destination address. The technique worked everywhere I tested, including
Linux, Solaris, NetBSD, OpenBSD, FreeBSD. And I should note that it even
worked when reassociating to different external networks (and still works on
everything but Linux, AFAICT).

I realize now that arguably POSIX only requires that a second connnect call
change the destination address, and not the source address. But what would
be the point of allowing a reassociation if the source address is never
changed? Because any two addresses may route to entirely different networks
or over different devices, the capability to reassociate would be pointless.

OTOH, if you explicitly called bind before connect, most systems these days
will unbind the source address when reassociating. That may be undesirable
behavior, but it is long-standing behavior AFAICT, including on Linux. One
way to bypass the new Linux behavior is to reset the socket with
connect(AF_UNSPEC), but under the pedantic interpretation of POSIX that's
not guaranteed to work.

I first posted this issue on comp.unix.programmer, including example code.
The thread is at

https://groups.google.com/forum/?fromgroups=#!topic/comp.unix.programmer/ya0V-rr8ip0

Although it's hard to follow w/ Google's horrendous interface.
