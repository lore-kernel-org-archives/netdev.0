From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: setsockopt()
Date: Mon, 7 Jul 2008 17:32:27 -0400
Message-ID: <20080707213227.GD19523@fieldses.org>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, netdev@vger.kernel.org,
	Jim Rees <rees@umich.edu>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55942 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbYGGVc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 17:32:29 -0400
Content-Disposition: inline
In-Reply-To: <20080707142408.43aa2a2e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2008 at 02:24:08PM -0700, Stephen Hemminger wrote:
> On Mon, 07 Jul 2008 14:18:38 -0400
> Olga Kornievskaia <aglo@citi.umich.edu> wrote:
> 
> > Hi,
> > 
> >     I'd like to ask a question regarding socket options, more 
> > specifically send and receive buffer sizes.
> > 
> >     One simple question: (on the server-side) is it true that, to set 
> > send/receive buffer size, setsockopt() can only be called before 
> > listen()? From what I can tell, if I were to set socket options for the 
> > listening socket, they get inherited by the socket created during the 
> > accept(). However, when I try to change send/receive buffer size for the 
> > new socket, they take no affect.
> > 
> >     The server in question is the NFSD server in the kernel. NFSD's code 
> > tries to adjust the buffer size (in order to have TCP increase the 
> > window size appropriately) but it does so after the new socket is 
> > created. It leads to the fact that the TCP window doesn't open beyond 
> > the TCP's "default" sysctl value (that would be the 2nd value in the 
> > triple net.ipv4.tcp_rmem, which on our system is set to 64KB). We 
> > changed the code so that setsockopt() is called for the listening socket 
> > is created and we set the buffer sizes to something bigger, like 8MB. 
> > Then we try to increase the buffer size for each socket created by the 
> > accept() but what is seen on the network trace is that window size 
> > doesn't open beyond the values used for the listening socket.
> 
> It would be better if NFSD stayed out of doign setsockopt and just
> let the sender/receiver autotuning work?

Just googling around....  Yes, that's probably exactly what we want,
thanks!  Any pointers to a good tutorial on the autotuning behavior?

So all we should have to do is never mess with setsockopt, and the
receive buffer size can increase up to the maximum (the third integer in
the tcp_rmem sysctl) if necessary?

--b.

> 
> >     I looked around in the code. There is a variable called 
> > "window_clamp" that seems to specifies the largest possible window 
> > advertisement. window_clamp gets set during the creation of the accept 
> > socket. At that time, it's value is based on the sk_rcvbuf of the 
> > listening socket. Thus, that would explain the behavior that window 
> > doesn't grow beyond the values used in setsockopt() for the listening 
> > socket, even though the new socket has new (larger) sk_sndbuf and 
> > sk_rcvbuf  than the listening socket.
> > 
> >     I realize that send/receive buffer size and window advertisement are 
> > different but they are related in the way that by telling TCP that we 
> > have a certain amount of memory for socket operations, it should try to 
> > open big enough window (provided that there is no congestion).
> > 
> >     Can somebody advise us on how to properly set send/receive buffer 
> > sizes for the NFSD in the kernel such that (1) the window is not bound 
> > by the TCP's default sysctl value and (2) if it is possible to do so for 
> > the accept sockets and not the listening socket.
> > 
> >     I would appreciate if we could be CC-ed on the reply as we are not 
> > subscribed to the netdev mailing list.
> > 
> > Thank you.
> > 
> > -Olga
> > 
> >    
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
