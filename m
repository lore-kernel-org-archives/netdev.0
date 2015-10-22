From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 07:03:04 +0100
Message-ID: <20151022060304.GQ22011@ZenIV.linux.org.uk>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <20151021.182955.1434243485706993231.davem@davemloft.net>
 <5628636E.1020107@oracle.com>
 <20151022044458.GP22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org, casper.dik@oracle.com
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60354 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbJVGDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 02:03:09 -0400
Content-Disposition: inline
In-Reply-To: <20151022044458.GP22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 05:44:58AM +0100, Al Viro wrote:

> Except that in this case "correctness" is the matter of rather obscure and
> ill-documented areas in POSIX.  Don't get me wrong - this semantics isn't
> inherently bad, but it's nowhere near being an absolute requirement.

PS: in principle, a fairly ugly trick might suffice for accept(2), but
I'm less than happy with going there.  Namely, we could
	* have ->accept() get descriptor number
	* have ->flush() get descriptor number in addition to current->files
and have it DTRT for sockets in the middle of accept(2).

However, in addition to being ugly as hell, it has the problem with the points
where we call ->flush(), specifically do_dup2() and __close_fd().
It's done *after* the replacement/removal from descriptor table, so another
socket might have already gotten the same descriptor and we'd get spurious
termination of accept(2).

And I'm really curious about the things Solaris would do with dup2() there.
Does it take into account the possibility of new accept() coming just as
dup2() is trying to terminate the ongoing ones?  Is there a window when
descriptor-to-file lookups would fail?  Looks like a race/deadlock country...
