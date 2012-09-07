From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Increased multicast packet drops in 3.4
Date: Fri, 7 Sep 2012 17:38:43 -0500
Message-ID: <20120907223843.GA2767@BohrerMBP.rgmadvisors.com>
References: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
 <1346912560.13121.175.camel@edumazet-glaptop>
 <20120906130316.GA2310@BohrerMBP.gateway.2wire.net>
 <1346937667.2484.33.camel@edumazet-glaptop>
 <20120907040043.GA2714@BohrerMBP.rgmadvisors.com>
 <1346998125.2484.220.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:34598 "EHLO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758352Ab2IGWiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 18:38:51 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so169077obb.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 15:38:50 -0700 (PDT)
In-Reply-To: <1346998125.2484.220.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 07, 2012 at 08:08:45AM +0200, Eric Dumazet wrote:
> On Thu, 2012-09-06 at 23:00 -0500, Shawn Bohrer wrote:
> > On Thu, Sep 06, 2012 at 03:21:07PM +0200, Eric Dumazet wrote:
> > > kfree_skb() can free a list of skb, and we use a generic function to do
> > > so, without forwarding the drop/notdrop status. So its unfortunate, but
> > > adding extra parameters just for the sake of drop_monitor is not worth
> > > it.  skb_drop_fraglist() doesnt know if the parent skb is dropped or
> > > only freed, so it calls kfree_skb(), not consume_skb() or kfree_skb()
> > 
> > I understand that this means that dropwatch or the skb:kfree_skb
> > tracepoint won't know if the packet was really dropped, but do we
> > know in this case from the context of the stack trace?  I'm assuming
> > since we didn't receive an error that the packet was delivered and
> > these aren't real drops.
> 
> I am starting to believe this is an application error.
> 
> This application uses recvmmsg() to fetch a lot of messages in one
> syscall, and it might well be it throws out a batch of 50+ messages
> because of an application bug. Yes, this starts with 3.4, but it can b
> triggered by a timing difference or something that is not a proper
> kernel bug...

Eric, you are absolutely correct.  There is at least one bug in the
application.  The code that re-orders out of order packets would give
up around the 50+ point and assume the packets in between were
dropped.  I did prove that if we keep reading from the socket we do
receive those packets.  So no packets are being dropped in the kernel.
I also proved I this is happening on 3.1 as well but 3.4 does trigger
it more often.

I'm still debugging the application because it appears I'm getting
very large batches of packets out of order.  It isn't clear to me if
this is another application bug, the kernel, the switch or something
else.

Thanks for all of your help looking into this (non)-issue.  If I have
further questions about the kernel side I'll let you know.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
