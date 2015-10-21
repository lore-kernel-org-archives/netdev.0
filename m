From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 22:28:28 +0100
Message-ID: <20151021212827.GN22011@ZenIV.linux.org.uk>
References: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021.083008.1870598627666404990.davem@davemloft.net>
 <201510211604.t9LG4r9A005345@room101.nl.oracle.com>
 <1445462310.22974.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casper.Dik@oracle.com, David Miller <davem@davemloft.net>,
	Alan.Burlison@oracle.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57605 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbbJUV2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 17:28:32 -0400
Content-Disposition: inline
In-Reply-To: <1445462310.22974.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 02:18:30PM -0700, Eric Dumazet wrote:
> On Wed, 2015-10-21 at 18:04 +0200, Casper.Dik@oracle.com wrote:
> 
> > It is only expensive within the process itself. 
> 
> thread synchro would require additional barriers to maintain this state,
> for a very unlikely case.
> 
> The atomic_{inc|dec}() on file refcount are already a problem.

To be fair, this would avoid at least _that_ - file refcount updates would
be less frequent.  However, unlike file->f_count, *descriptor* refcounts
would be much harder to keep in different cachelines.

> We certainly do not use/take a lock to find a file pointer into file
> descriptor table.
> 
> (This lock is only used at open() or close() time)

as well as dup2() and friends, of course.  But yes, we are pretty careful
about avoiding non-local stores on the normal "get file by descriptor" path -
in case of non-shared descriptor table we don't do them at all, and in case
of shared one we only modify refcount in struct file.
