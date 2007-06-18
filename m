From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 13:01:52 +0100
Message-ID: <20070618130152.50215201@the-village.bc.nu>
References: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
	<20070618.021813.105401188.davem@davemloft.net>
	<E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
	<20070618.023520.102546505.davem@davemloft.net>
	<E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu>
	<20070618103241.GX521@postel.suug.ch>
	<E1I0EdX-0007Ia-00@dorka.pomaz.szeredi.hu>
	<20070618104340.GZ521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miklos Szeredi <miklos@szeredi.hu>, davem@davemloft.net,
	akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:53477 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761394AbXFRL4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 07:56:51 -0400
In-Reply-To: <20070618104340.GZ521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jun 2007 12:43:40 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * Miklos Szeredi <miklos@szeredi.hu> 2007-06-18 12:39
> > You are wrong.  Look in unix_release_sock():
> > 
> > 	if (atomic_read(&unix_tot_inflight))
> > 		unix_gc();		/* Garbage collect fds */
> > 
> > 
> > unix_tot_inflight is the number of AF_UNIX sockets currently being
> > transferred over some AF_UNIX sockets.
> > 
> > That means that just sending (non-unix socket) fds over unix sockets
> > will never invoke the gc.
> 
> That's what I meant, I'm sorry, I should have written unix socket
> file descriptor to not leave any room for misinterpretation.

You can bound the worst case on this and I think stay within the specs
(as the specs don't say a lot about it). One way would be to make
unix_gc() kick off a thread/tasklet and if the last unix_gc was within 5
seconds then use a timer to defer it - that prevents any user driven
"lets cause a ton of gc" cases.
