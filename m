From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Tue, 6 Jan 2009 19:15:59 +0100
Message-ID: <20090106181559.GA29426@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <49639807.1040803@zeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ben Mansell <ben@zeus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1134 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845AbZAFSQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 13:16:07 -0500
Content-Disposition: inline
In-Reply-To: <49639807.1040803@zeus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Tue, Jan 06, 2009 at 05:42:31PM +0000, Ben Mansell wrote:
> Hi,
> 
> >I'm facing a data corruption problem with splice() between two
> >non-blocking TCP sockets on 2.6.27.10. I could finally write a
> >simpler proof of concept, and capture a snapshot of the issue
> >with the associated strace result.
> >
> >My program does the following :
> >  - accept an incoming connection
> >  - connect to a remote server
> >  - forward all data from the server to the client using splice()
> >
> >The data count is always correct, but some parts are corrupted and
> >contain data which seem to come from random memory locations (this
> >raises a security concern BTW). It *sometimes* happens that a few
> >megabytes can be transferred without any problem, but most of the
> >time, corruption happens for a few hundreds of bytes every few
> >hundreds of kilobytes.
> 
> FWIW, I can easily reproduce this on a Linux 2.6.27-9 (Ubuntu kernel), 
> using both forcedeth and tg3 network drivers. It's reassuring to hear of 
> this network corruption as I have been puzzling over non-blocking 
> splice() code recently!

Ah, so you might also have discovered a few annoyances with the API, eg
the fact that splice() returns after the first read in non-blocking mode,
as well as the fact that it never returns zero on close, but -EAGAIN,
which requires an additional recv(MSG_PEEK) to distinguish between a
close and a lack of data. But I leave that for a later discussion, let's
address the corruption issue first.

> The corruption does seem to be confined to the user data on the 
> connections, as I have been able to run some benchmarks using my own 
> splice()-enabled HTTP proxy to transfer lots of data. All the TCP 
> connections 'work' fine (as in no broken TCP), the initial HTTP request 
> & response headers get through OK, but the body data of the responses 
> sometimes gets corrupted. The benchmark seems to work flawlessly until 
> you look at the web page data!

I confirm your observations. Benchmarks were OK, it's the first user of
my experimental code who reported wrong md5sums on their ISO images :-/
For this reason, I think that it's completely related to the way pages
are passed between sockets, but I'm too much a loser in this area. I
understood tcp_splice_read(), but can't manage to find what is called
on the other side nor what the data become :-(

> I'm happy to run any test code on systems here or provide any debug 
> information if it would help to track this down.

That's nice, because I'd like to ensure that whatever fix is proposed
is properly validated, not only on my platforms!

Regards,
Willy

