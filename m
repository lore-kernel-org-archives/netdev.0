From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 12:39:07 +0200
Message-ID: <E1I0EdX-0007Ia-00@dorka.pomaz.szeredi.hu>
References: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu> <20070618.021813.105401188.davem@davemloft.net> <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu> <20070618.023520.102546505.davem@davemloft.net> <E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu> <20070618103241.GX521@postel.suug.ch>
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.sa.eol.hu ([212.108.200.67]:60042 "EHLO
	mail-gw1.sa.eol.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758251AbXFRKj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 06:39:56 -0400
In-reply-to: <20070618103241.GX521@postel.suug.ch> (message from Thomas Graf
	on Mon, 18 Jun 2007 12:32:41 +0200)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * Miklos Szeredi <miklos@szeredi.hu> 2007-06-18 11:44
> > Garbage collection only ever happens, if the app is sending AF_UNIX
> > sockets over AF_UNIX sockets.  Which is a rather rare case.  And which
> > is basically why this bug went unnoticed for so long.
> > 
> > So my second patch only affects the performance of _exactly_ those
> > apps which might well be bitten by the bug itself.
> 
> That's not entirely the truth. It affects all applications using
> AF_UNIX sockets while file descriptors are being transfered. I
> agree that the performance impact is not severe on most systems
> but if file descriptors are being transfered continously by just
> a single application it can become rather severe.

You are wrong.  Look in unix_release_sock():

	if (atomic_read(&unix_tot_inflight))
		unix_gc();		/* Garbage collect fds */


unix_tot_inflight is the number of AF_UNIX sockets currently being
transferred over some AF_UNIX sockets.

That means that just sending (non-unix socket) fds over unix sockets
will never invoke the gc.

Miklos
