From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Fri, 18 May 2012 00:10:58 +0200
Message-ID: <1337292658.3403.62.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu>
	 <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu>
	 <1337290822.3403.47.camel@edumazet-glaptop>
	 <1337291410.3403.52.camel@edumazet-glaptop>
	 <1337292119.3403.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63042 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965954Ab2EQWLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 18:11:04 -0400
Received: by weyu7 with SMTP id u7so1447313wey.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 15:11:03 -0700 (PDT)
In-Reply-To: <1337292119.3403.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 00:02 +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 23:50 +0200, Eric Dumazet wrote:
> > On Thu, 2012-05-17 at 23:40 +0200, Eric Dumazet wrote:
> > 
> > > I dont understand why we should tcp_push() if we sent 0 bytes in this
> > > splice() call.
> > > 
> > > The push() should have be done already by prior splice() call, dont you
> > > think ?
> > > 
> > > out:
> > > 	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
> > > 		tcp_push(sk, flags, mss_now, tp->nonagle);
> > > 
> > 
> > I think I now understand
> > 
> > One splice() syscall actually calls do_tcp_sendpages() several times
> > (N).
> > 
> > Problem is N-1 calls are done with MSG_SENDPAGE_NOTLAST set
> > 
> > And last one with MSG_SENDPAGE_NOTLAST unset
> > 
> > So maybe we should replace this test by :
> > 
> > 	if (!(flags & MSG_SENDPAGE_NOTLAST))
> > 		tcp_push(...);
> > 
> > 
> 
> Its more tricky than that.
> 
> If we return 0 from do_tcp_sendpages(), __splice_from_pipe() wont call
> us again, but we need to flush().  (This bug is indeed very old)
> 
> So maybe use :
> 
> if ((copied && !(flags & MSG_SENDPAGE_NOTLAST)) ||
>     !copied)
> 	tcp_push(...);


But then your patch is equivalentm so I'm going to Ack it ;)
