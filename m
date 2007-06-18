From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 12:47:17 +0200
Message-ID: <E1I0ElR-0007Kz-00@dorka.pomaz.szeredi.hu>
References: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu> <20070618.021813.105401188.davem@davemloft.net> <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu> <20070618.023520.102546505.davem@davemloft.net> <E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu> <20070618103241.GX521@postel.suug.ch> <20070618104059.GY521@postel.suug.ch>
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:34525 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbXFRKr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 06:47:58 -0400
In-reply-to: <20070618104059.GY521@postel.suug.ch> (message from Thomas Graf
	on Mon, 18 Jun 2007 12:40:59 +0200)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * Thomas Graf <tgraf@suug.ch> 2007-06-18 12:32
> > * Miklos Szeredi <miklos@szeredi.hu> 2007-06-18 11:44
> > > Garbage collection only ever happens, if the app is sending AF_UNIX
> > > sockets over AF_UNIX sockets.  Which is a rather rare case.  And which
> > > is basically why this bug went unnoticed for so long.
> > > 
> > > So my second patch only affects the performance of _exactly_ those
> > > apps which might well be bitten by the bug itself.
> > 
> > That's not entirely the truth. It affects all applications using
> > AF_UNIX sockets while file descriptors are being transfered. I
> > agree that the performance impact is not severe on most systems
> > but if file descriptors are being transfered continously by just
> > a single application it can become rather severe.
> 
> Also think of the scenario where an application, deliberately or not,
> begins a file descriptor tranfser using sendmsg() and the receiving
> part never invokes recvmsg() to decrement the inflight counters
> again. Every unix socket that gets closed would result in a gc call
> locking all sockets.

And if some of the sent files were unix sockets, rightly so, since the
sent sockets might need to be garbage collected.

And BTW the whole gc is done with the unix_table_lock held, so it will
stop some socket operations anyway.  The fact that it needs to stop
some more operations is a necessary thing.  But we are talking about a
_spinlocked_ region, which for zillions of sockets might run for a
long time, but it's not as if it's really going to affect performance
in real cases.

Miklos
