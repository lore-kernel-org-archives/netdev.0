From: Phil Oester <kernel@linuxace.com>
Subject: Regression in 3.6+: fib_validate_source breakage
Date: Sat, 12 Jan 2013 20:45:13 -0800
Message-ID: <20130113044513.GA26457@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35360 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab3AMEpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 23:45:17 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so1672218pad.33
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 20:45:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 7a9bc9b81a (Elide fib_validate_source() completely when possible) it
was stated:

    If rpfilter is off (or the SKB has an IPSEC path) and there are not
    tclassid users, we don't have to do anything at all when
    fib_validate_source() is invoked besides setting the itag to zero.

However, this change was later proven to break redirects, fixed in commit
e81da0e113 (ipv4: fix sending of redirects).  

In addition to this breakage, it also bypassed another necessary check, as
clearly stated in the preamble comment to fib_validate_source:

    * - (main) check, that source is valid i.e. not broadcast or our local
    *   address.

Without this check (and if rp_filter is NOT enabled), packets with local source
addresses are accepted by the stack.  This only came to light due to a buggy
switch which is occasionally reflecting packets back at a box running a VRRP 
daemon, causing the local box to believe it has seen a higher priority
advertisement, when in reality it is only seeing a copy of its own advertisement.
Prior to 3.6, these packets would be silently dropped.

Also, not that I use it, but accept_local handling appears to now be broken.

I realize the original change likely made the route cache removal more palatable,
but given the number of issues it has caused, perhaps a revert is in order?
I can't find any easy alternative fix.

Phil Oester
