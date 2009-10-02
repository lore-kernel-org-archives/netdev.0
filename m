From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Fri, 2 Oct 2009 11:10:29 -0600
Message-ID: <20091002171029.GG5191@obsidianresearch.com>
References: <20090930004820.GC19540@obsidianresearch.com> <E1Mssmb-004RJz-Hf@intern.SerNet.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Volker Lendecke <vl@samba.org>
To: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 139-142-54-143.atc.vaillant.ca ([139.142.54.143]:40798 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752889AbZJBRKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 13:10:30 -0400
Content-Disposition: inline
In-Reply-To: <E1Mssmb-004RJz-Hf@intern.SerNet.DE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2009 at 08:37:13AM +0200, Volker Lendecke wrote:
> On Tue, Sep 29, 2009 at 06:48:20PM -0600, Jason Gunthorpe wrote:
> > FWIW, it looks like samba has a splice code now, but doesn't enable it
> > due to this issue?
> 
> Right. What I've learned from the comments is that splice is
> only usable in multi-threaded programs. One thread is
> reading, one is writing from the other end. I deferred using
> splice until we have the proper architecture to do sync
> syscalls in helper threads to make them virtually async.  We
> have some code for that now, but it's not a high priority
> for me at this moment.

So, it looks like thanks to Eric and davem that splice will be changed
so it can be blocking on the TCP and non-blocking on the PIPE.

I'd suggest a construct like the following as a compatability
solution:

struct pollfd pfd = {.fd = tcpfd, events = POLLIN | POLLRDHUP};
while (..) {
   rc = splice(tcpfd,0,pfd[1],0,count,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
   if (rc == -1)
     //...
   if (rc == 0) {
       if (pfd.revents & POLLRDHUP)
          // oops, EOF on TCP

       /* Might be an old kernel that nonblocks on TCP, have to check
          if this is EOF or do blocking. */
       rc = poll(&pfd,1,-1);
       if (rc == -1)
          //...
   }

   rc = splice(pfd[0],0,ofd,0,..., SPLICE_F_MOVE)
}

Which should add no overhead in the new splice blocks case, and falls
back gracefully on older kernels..

Thanks,
Jason
