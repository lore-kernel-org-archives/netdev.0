From: "Bonitch, Joseph" <Joseph.Bonitch@xerox.com>
Subject: IPV6 stateless autoconfig: prefix route lifetime issue
Date: Fri, 9 May 2008 08:55:18 -0400
Message-ID: <BECE1C148A85274EB554378A3E0EDF4906335DEE@USA0300MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wvmler2.mail.xerox.com ([13.8.138.217]:57887 "EHLO
	wvmler2.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbYEIMzd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 08:55:33 -0400
Received: from wvmlir3.mail.xerox.com (wvmlir3.mail.xerox.com [13.147.8.223])
	by wvmler2.mail.xerox.com (8.14.2/8.13.8) with ESMTP id m49CtXwv004319
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 05:55:33 -0700
Received: from wvmlir3.mail.xerox.com (localhost.localdomain [127.0.0.1])
	by wvmlir3.mail.xerox.com (8.13.8/8.13.6) with ESMTP id m49CtP4a003857
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 05:55:25 -0700
Received: from USA0300GW002.na.xerox.net (usa0300gw002.na.xerox.net [13.135.210.15])
	by wvmlir3.mail.xerox.com (8.13.8/8.13.6) with ESMTP id m49CtIIN003711
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 05:55:24 -0700
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In one of our labs we have a router sending RA's where the prefix info
option has both valid and preferred lifetime set to infinity
(0xffffffff)
per RFC4861.

On a client configured for stateless address autoconfiguration, the
addresses and prefix routes are created as expected when the RA is
received,
but the prefix routes get expired after < 30 seconds.  After adding some
debug and further testing I found that when
    valid lifetime >= 0x7fffffff * HZ (HZ=250, USER_HZ=100 in our
config)
this condition occurs and prefix routes are prematurely expired.

We are using 2.6.20 + patches but I also tested with the latest Ubuntu
using
2.6.24-16 with the same results.  This is repeatable simply by booting
into
the liveCD option using Ubuntu 8.04 desktop.  No config changes
necessary -
just plug into an IPV6 network where you can change the RA Prefix Info
lifetimes.  Do "ip -6 route list" a bunch of times.  You will see the
routes
added with huge expiry times and they will count down as expected.  The
first
time fib garbage collection runs the routes disappear.  Using valid
lifetimes
such as 900, 3600, 86400, etc work just fine.

Looking at net/ipv6/addrconf.c the problem appears to be in
addrconf_prefix_rcv() after the "Avoid arithmetic overflow" comment.
Before
the comment the lifetimes have been read into valid_lft and
preferred_lft.
Clearly RFC4861 specifies that these are both u32 in units of seconds
and
0xffffffff = infinity.  Reading through RFC4862/ADDRCONF 5.5.3, there
are
no further limitations placed on the lifetimes other than the rules to
prevent the DoS case.

Problem #1 the infinity case is not specifically handled
Problem #2 premature expiration when valid_lft > 0x7ffffffff * HZ.

Let me know if further information is needed and if I should submit
a bug in bugzilla.

Regards,

Joe
