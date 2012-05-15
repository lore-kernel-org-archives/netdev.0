From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 15 May 2012 16:56:16 +0200
Message-ID: <1337093776.8512.1089.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60277 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932875Ab2EOO4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 10:56:21 -0400
Received: by bkcji2 with SMTP id ji2so4888772bkc.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 07:56:20 -0700 (PDT)
In-Reply-To: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 15:38 +0100, Kieran Mansley wrote:
> I've been investigating an issue with TCPBacklogDrops being reported
> (and relatively poor performance as a result).  The problem is most
> easily observed on slightly older kernels (e.g 3.0.13) but is still
> present in 3.3.6, although harder to reproduce.  I've also seen it in
> 2.6 series kernels, so it's not a recent issue.
> 
> The problem occurs at the receiver when a TCP sender with a large
> congestion window is sending at a high rate and the receiving
> application has blocked in a recv() or similar call.  During the stream
> ACKs are being returned to the sender keeping the receive window open
> and so allowing it to carry on sending.  The local socket receive buffer
> gets dynamically increased, and the advertised receive window increases
> similarly.
> 
> [As an aside, it appears as though the total bytes that the receiver
> commits to receiving - i.e. the point at which it stops advertising new
> sequence space - is around double the receive socket buffer.  I'm
> guessing it is committing to receiving the current socket buffer
> (perhaps as there is a pending recv() it knows it will be able to
> immediately empty this) and the next one, but I've not looked into this
> in detail]
> 
> As the socket buffer is approaching full the kernel decides to satisfy
> the recv() call and wake the application.  It will have to copy the data
> to application address space etc.  At this point there is a switch in
> tcp_v4_rcv():
> 
> http://lxr.linux.no/#linux+v3.3.6/net/ipv4/tcp_ipv4.c#L1726
> 
> Before this point, the "if (!sock_owned_by_user(sk)) " will evaluate to
> true, but once it has decided to wake the application I think it will
> evaluate to false and it will drop through to:
> 
> 1739        else if (unlikely(sk_add_backlog(sk, skb))) {
> 1740                bh_unlock_sock(sk);
> 1741                NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
> 1742                goto discard_and_relse;
> 1743        }
> 
> In sk_add_backlog() there is a test to see if the socket's receive
> buffer is full, and if there is the kernel drops the packets, reporting
> them through netstat as TCPBacklogDrop.  This is despite there being
> potentially megabytes of unused advertised receive window space at this
> point.
> 
> Very shortly afterwards the socket buffer will be empty again (as its
> contents will have been transferred to the user) so this is essentially
> a race and depends on a fast sender to demonstrate it.  It shows up as a
> acute period of drops that are quickly retransmitted and then
> accepted.  
> 
> There are two ways of thinking about this problem: either the receiver
> should be more conservative about the receive window it advertises
> (limiting it to the available receive socket buffer size); or the
> receiver should be more generous with what it will accept on to the
> backlog (matching it to the advertised receive window).  It is the
> discrepancy between advertised receive window and what can be put on the
> backlog that is the root of the problem.  I would be tempted by the
> latter and say that as the backlog is likely to soon make it into the
> receive buffer, it should be allowed to contain a full receive buffer of
> bytes on top of what is currently being removed from the receive buffer
> into the application.
> 
> It is harder to reproduce on recent kernels because the pending recv()
> call gets satisfied very close to the start of a burst, and at this time
> the receive buffer will be mostly empty and so it is less likely that
> any packets in flight will overflow the backlog.  On earlier kernels it
> is easier to reproduce because the pending recv() call didn't return
> until the socket's receive buffer was nearly full, and so it would only
> take a few extra packets to overflow the backlog.
> 
> I have a packet capture to illustrate the problem (taken on 3.0.13) if
> that would be of help.  As I can easily reproduce it I'm also happy to
> make changes and test to see if they improve matters.


Please try latest kernels, this is probably 'fixed'

What network driver are you using ?
