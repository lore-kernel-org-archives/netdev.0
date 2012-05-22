From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 22 May 2012 18:45:35 +0200
Message-ID: <1337705135.3361.226.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
	 <1337678759.3361.147.camel@edumazet-glaptop>
	 <1337679045.3361.154.camel@edumazet-glaptop>
	 <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
	 <1337703170.3361.217.camel@edumazet-glaptop>
	 <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45853 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab2EVQpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 12:45:41 -0400
Received: by eeit10 with SMTP id t10so1783900eei.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 09:45:40 -0700 (PDT)
In-Reply-To: <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 17:32 +0100, Kieran Mansley wrote:
> On Tue, 2012-05-22 at 18:12 +0200, Eric Dumazet wrote:
> > 
> > __tcp_select_window() ( more precisely tcp_space() takes into account
> > memory used in receive/ofo queue, but not frames in backlog queue)
> > 
> > So if you send bursts, it might explain TCP stack continues to
> > advertise
> > a too big window, instead of anticipate the problem.
> > 
> > Please try the following patch :
> > 
> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > index e79aa48..82382cb 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -1042,8 +1042,9 @@ static inline int tcp_win_from_space(int space)
> >  /* Note: caller must be prepared to deal with negative returns */ 
> >  static inline int tcp_space(const struct sock *sk)
> >  {
> > -       return tcp_win_from_space(sk->sk_rcvbuf -
> > -                                 atomic_read(&sk->sk_rmem_alloc));
> > +       int used = atomic_read(&sk->sk_rmem_alloc) +
> > sk->sk_backlog.len;
> > +
> > +       return tcp_win_from_space(sk->sk_rcvbuf - used);
> >  } 
> >  
> >  static inline int tcp_full_space(const struct sock *sk)
> 
> 
> I can give this a try (not sure when - probably later this week) but I
> think this it is back to front.  The patch above will reduce the
> advertised window by sk_backlog.len, but at the time that the window was
> advertised that allowed the dropped packets to be sent the backlog was
> empty.  It is later, when the kernel is waking the application and takes
> the socket lock that the backlog starts to be used and the drop happens.
> But reducing the window advertised at this point is futile - the packets
> that will be dropped are already in flight.
> 

Not really. If we receive these packets while backlog is empty, then the
sender violates TCP rules.

We advertise tcp window directly from memory we are allowed to consume.

(On the premise sender behaves correctly, not sending bytes in small
packets)


> The problem exists because the backlog has a tighter limit on it than
> the receive window does; I think the backlog should be able to accept
> sk_rcvbuf bytes in addition to what is already in the receive buffer (or
> up to the advertised receive window if that's smaller).  At the moment
> it will only accept sk_rcvbuf bytes including what is already in the
> receive buffer.  The logic being that in this case we're using the
> backlog because it's in the process of emptying the receive buffer into
> the application, and so the receive buffer will very soon be empty, and
> so we will very soon be able to accept sk_rcvbuf bytes.  This is evident
> from the packet capture as the kernel stack is quite happy to accept the
> significant quantity of data that arrives as part of the same burst
> immediately after it has dropped a couple of packets.
> 

This is not evident from the capture, you are mistaken.

tcpdump captures packets before tcp stack, it doesnt say if they are :

1) queued in receive of ofo queue
2) queued in socket backlog
3) dropped because we hit socket rcvbuf limit

If socket lock is hold by the user, packets are queued to backlog, or
dropped.

Then, when socket lock is about to be released, we process the backlog.
