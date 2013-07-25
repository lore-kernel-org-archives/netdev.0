From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused
 function
Date: Thu, 25 Jul 2013 21:05:06 +0200
Message-ID: <20130725190506.GA32375@nautica>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
 <20130724.154646.2283898956674234778.davem@davemloft.net>
 <1374707387.29835.23.camel@x61.thuisdomein>
 <20130724.164514.393667021861625699.davem@davemloft.net>
 <20130725061411.GA8579@nautica>
 <20130725064802.GA12569@nautica>
 <CAFkjPTm1FH24EfWMDrXTh7DmU8WAb0ji-jkUgkayqMzfWj9O0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dominique Martinet <dominique.martinet@cea.fr>,
	Latchesar Ionkov <lucho@ionkov.net>, pebolle@tiscali.nl,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>, andi@etezian.org,
	rminnich@sandia.gov,
	V9FS Developers <v9fs-developer@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:44512 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756160Ab3GYTFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 15:05:23 -0400
Content-Disposition: inline
In-Reply-To: <CAFkjPTm1FH24EfWMDrXTh7DmU8WAb0ji-jkUgkayqMzfWj9O0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Van Hensbergen wrote on Thu, Jul 25, 2013 :
> So, the cancel function should be used to flush any pending requests that
> haven't actually been sent yet.  Looking at the 9p RDMA code, it looks like
> the thought was that this wasn't going to be possible.  Regardless of
> removing unsent requests, the flush will still be sent and if the server
> processes it before the original request and sends a flush response back
> then we need to clear the posted buffer.  This is what rdma_cancelled is
> supposed to be doing.  So, the fix is to hook it into the structure -- but
> looking at the code it seems like we probably need to do something more to
> reclaim the buffer rather than just incrementing a counter.
> 
> To be clear this has less to do with recovery and more to do with the
> proper implementation of 9p flush semantics.  By and large, those semantics
> won't impact static file system users -- but if anyone is using the
> transport to access synthetic filesystems or files then they'll definitely
> want to have a properly implemented flush setup.  The way to test this is
> to get a blocking read on a remote named pipe or fifo and then ^C it.

Ok, I knew about the concept of flush but didn't think a ^C would cause
a -ESYSRESTART, so didn't think of that.
That said, reading from, say, a fifo is an entierly local operation: the
client does a walk, getattr, doesn't do anything 9p-wise, and clunks
when it's done with it.



As for the function needing a bit more work, there's a race, but on
"normal" requests I think it is about right - the answer lays in a
comment in rdma_request:

  /* When an error occurs between posting the recv and the send,
   * there will be a receive context posted without a pending request.
   * Since there is no way to "un-post" it, we remember it and skip
   * post_recv() for the next request.
   * So here,
   * see if we are this `next request' and need to absorb an excess rc.
   * If yes, then drop and free our own, and do not recv_post().
   **/

Basically, receive buffers are sent in a queue, and we can't "retrieve"
it back, so we just don't sent next one.

There is one problem though - if the server handles the original request
before getting the flush, the receive buffer will be consumed and we
won't send a new one, so we'll starve the reception queue.
I'm afraid I don't have any bright idea there...


While we are on reception buffer issues, there is another problem with
the queue of receive buffers, even without flush, in the following
scenario:
 - post a buffer for tag 0, on a hanging request
 - post a buffer for tag 1
 - reply for tag 1 will come on buffer from tag 0
 - post another request with tag 1.. the buffer already is in the queue,
and we don't know we can post the buffer associated with tag 0 back.

I haven't found how to reproduce this perfectly yet, but a dd with
blocksize 1MB and one with blocksize 10B in parallel brought the
mountpoint down (and the whole server was completely unavailable for the
duration of the dd - TCP sessions timed out, I even got IO errors on the
local disk :D)


Regards,
-- 
Dominique Martinet
