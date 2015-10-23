From: David Holland <dholland-tech@netbsd.org>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Fri, 23 Oct 2015 18:30:25 +0000
Message-ID: <20151023183025.GA941@netbsd.org>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org,
	Casper Dik <casper.dik@oracle.com>
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netbsd.org ([149.20.53.66]:53499 "EHLO mail.netbsd.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbbJWSkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 14:40:07 -0400
Content-Disposition: inline
In-Reply-To: <5627A37B.4090208@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 03:38:51PM +0100, Alan Burlison wrote:
 > On 21/10/2015 04:49, Al Viro wrote:
 > >BTW, for real fun, consider this:
 > >7)
 > >// fd is a socket
 > >fd2 = dup(fd);
 > >in thread A: accept(fd);
 > >in thread B: accept(fd);
 > >in thread C: accept(fd2);
 > >in thread D: close(fd);
 > >
 > >Which threads (if any), should get hit where it hurts?
 > 
 > A & B should return from the accept with an error. C should continue. Which
 > is what happens on Solaris.

So, I'm coming late to this discussion and I don't have the original
context; however, to me this cited behavior seems undesirable and if I
ran across it in the wild I would probably describe it as a bug.

System call processing for operations on files involves translating a
file descriptor (a number) into an open-file object (or "file
description"), struct file in BSD and I think also in Linux. The
actual system call logic operates on the open-file object, so once the
translation happens application monkeyshines involving file descriptor
numbers should have no effect on calls in progress. Other behavior
would violate the principle of least surprise, as this basic
architecture predates POSIX.

The behavior Al Viro found in NetBSD's dup2 is a bug. System calls are
supposed to be atomic, regardless of what POSIX might or might not
say.

I did not write that code but I'll pass the report on to those who
did.

-- 
David A. Holland
dholland@netbsd.org
