From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Sat, 23 Jun 2007 10:42:05 -0600
Message-ID: <m1ir9eaahu.fsf@ebiederm.dsl.xmission.com>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
	<20070607.184731.10907840.davem@davemloft.net>
	<E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu>
	<m17ipxfi9d.fsf@ebiederm.dsl.xmission.com>
	<E1I21IL-0004LH-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43442 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757588AbXFWQsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 12:48:06 -0400
In-Reply-To: <E1I21IL-0004LH-00@dorka.pomaz.szeredi.hu> (Miklos Szeredi's
	message of "Sat, 23 Jun 2007 10:48:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Miklos Szeredi <miklos@szeredi.hu> writes:

> Right.  But the devil is in the details, and (as you correctly point
> out later) to implement this, the whole locking scheme needs to be
> overhauled.  Problems:
>
>  - Using the queue lock to make the dequeue and the fd detach atomic
>    wrt the GC is difficult, if not impossible: they are are far from
>    each other with various magic in between.  It would need thorough
>    understanding of these functions and _big_ changes to implement.
>
>  - Sleeping on u->readlock in GC is currently not possible, since that
>    could deadlock with unix_dgram_recvmsg().  That function could
>    probably be modified to release u->readlock, while waiting for
>    data, similarly to unix_stream_recvmsg() at the cost of some added
>    complexity.
>
>  - Sleeping on u->readlock is also impossible, because GC is holding
>    unix_table_lock for the whole operation.  We could release
>    unix_table_lock, but then would have to cope with sockets coming
>    and going, making the current socket iterator unworkable.
>
> So theoretically it's quite simple, but it needs big changes.  And
> this wouldn't even solve all the problems with the GC, like being a
> possible DoS vector.

Making the GC fully incremental will solve the DoS vector problem as
well.  Basically you do a fixed amount of reclaim in the new socket
allocation code.

It appears clear that since we can't stop the world and garbage
collect we need an incremental collector.

Eric
