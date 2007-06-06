From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 05 Jun 2007 22:41:28 -0700 (PDT)
Message-ID: <20070605.224128.104032917.davem@davemloft.net>
References: <20070605.000247.18308209.davem@davemloft.net>
	<20070605.173120.59467114.davem@davemloft.net>
	<E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754833AbXFFFlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 01:41:13 -0400
In-Reply-To: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 06 Jun 2007 07:26:52 +0200

> > Holding a global mutex over recvmsg() calls under AF_UNIX is pretty
> > much a non-starter, this will kill performance for multi-threaded
> > apps.
> 
> That's an rwsem held for read.  It's held for write in unix_gc() only
> for a short duration, and unix_gc() should only rarely be called.  So
> I don't think there's any performance problem here.

It pulls a non-local cacheline into the local thread, that's extremely
expensive on SMP.

If everyone starts grabbing this thing during recvmsg() it's going to
become a really hot lock and kill performance, even if it's a read
side lock being taken.

That's why I said we need to investigate solutions involving
u->readlock, that already has to be taken and is local to the socket.
