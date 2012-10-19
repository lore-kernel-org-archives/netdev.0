From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Fri, 19 Oct 2012 08:50:13 +0200
Message-ID: <1350629413.2293.157.camel@edumazet-glaptop>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	 <507C4401.7050500@oracle.com>
	 <CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	 <CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	 <5080279F.80008@oracle.com> <5080340F.3050207@oracle.com>
	 <CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
	 <CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:54269 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2JSGuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:50:17 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so34841eaa.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 23:50:16 -0700 (PDT)
In-Reply-To: <CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-18 at 23:02 -0700, Vijay Subramanian wrote:
> >> They all remain on ESTABLISHED state on the client side.
> >
> > yeah, that's what i see with netstat -t too.
> >
> 
> > (https://android-review.googlesource.com/#/c/44563/), but i'd love to
> > at least understand what's going on here, even if it's just that i
> > have a fundamental misunderstanding of what the listen backlog is
> > supposed to mean.
> >
> 
> The listen backlog represents the number of received SYNs that have
> not been processed i.e. for which a SYN-ACK has not been sent.
> Actually, the number of SYNs
> that can be pending for processing is actually backlog+1. With a
> backlog of 1, there can be 2 SYNs that can be pending for processing.
> 
> Once a SYN is processed by the server socket (in LISTEN state) and a
> syn-ack is sent back, a request_sock is created to represent it. Once
> the client replies with the last step of connect() i.e. with  an ack,
> a fully established socket is created. The number of queued
> request-socks for a LISTEN socket can be much more than the backlog
> limit given in listen() (which is 1 in your case). If after a short
> period (after SYNACK_RETRIES), the three way handshake is not
> completed, request_socks can be silently discarded.
> 
> When a SYN is received, it is processed by   tcp_v4_conn_request()
> where we have..
> if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
>  got drop;
> 
> So, for the SYN to be dropped, backlog limit must be exceeded _and_ we
> must have recently accepted another SYN request. So, even when backlog
> limit is exceeded, SYNs are processed and syn-acks are sent back. It
> seems that the listen backlog limit is applied definitively only in
> the third step in tcp_v4_syn_recv_sock() and not in the first step.
> In  tcp_v4_syn_recv_sock(), we have
>  if (sk_acceptq_is_full(sk))
>                 goto exit_overflow;
> 
> This prevents the socket from being created fully. On the client side
> however, since the three way handshake has finished, the socket goes
> into ESTABLISHED state which is what you see with netstat. In your
> test case, typically 2 connections are in state where SYN has to be
> processed  and rest are as request_sock where synacks have been sent.
> However,
> they may not become fully created sockets as they will fail in step 3
> as described above.
> 
> man listen() says
> " The  backlog  argument  defines  the maximum length to which the
> queue of pending connections for sockfd may grow. " In your case where
> backlog is 1, there can be a max of 2 pending connections (SYNs not
> yet processed) and this is what we see. By this interpretation,
> behavior seems correct.
> 
> Not sure if this behavior is a bug but the processing in
> tcp_v4_conn_request()  does look suspicious. Should we terminate
> earlier without doing three way hand shake?
> Perhaps someone who knows this better can clarify.
> 
> Hope this helps.
> Vijay

I came to the same analysis than you.

Current behavior is stupid, because the traffic for such 'sockets' is
insane :

As we sent a SYNACK, client sends the 3rd packet (ACK), and we ignore
it.

Then we keep retransmitting SYNACKS....

Oh well.

21:38:27.459937 IP glaptop.53627 > 172.30.42.23.9877: Flags [S], seq
1124582230, win 14600, options [mss 1460,sackOK,TS val 84038374 ecr
0,nop,wscale 7], length 0
21:38:27.460007 IP 172.30.42.23.9877 > glaptop.53627: Flags [S.], seq
1077519728, ack 1124582231, win 14480, options [mss 1460,sackOK,TS val
4230664 ecr 84038374,nop,wscale 7], length 0
21:38:27.460235 IP glaptop.53627 > 172.30.42.23.9877: Flags [.], ack 1,
win 115, options [nop,nop,TS val 84038374 ecr 4230664], length 0

21:38:28.661139 IP 172.30.42.23.9877 > glaptop.53627: Flags [S.], seq
1077519728, ack 1124582231, win 14480, options [mss 1460,sackOK,TS val
4231866 ecr 84038374,nop,wscale 7], length 0
21:38:28.661428 IP glaptop.53627 > 172.30.42.23.9877: Flags [.], ack 1,
win 115, options [nop,nop,TS val 84038494 ecr 4231866,nop,nop,sack 1
{0:1}], length 0
21:38:30.661138 IP 172.30.42.23.9877 > glaptop.53627: Flags [S.], seq
1077519728, ack 1124582231, win 14480, options [mss 1460,sackOK,TS val
4233866 ecr 84038494,nop,wscale 7], length 0
21:38:30.661412 IP glaptop.53627 > 172.30.42.23.9877: Flags [.], ack 1,
win 115, options [nop,nop,TS val 84038694 ecr 4233866,nop,nop,sack 1
{0:1}], length 0
21:38:35.061135 IP 172.30.42.23.9877 > glaptop.53627: Flags [S.], seq
1077519728, ack 1124582231, win 14480, options [mss 1460,sackOK,TS val
4238266 ecr 84038694,nop,wscale 7], length 0
21:38:35.061413 IP glaptop.53627 > 172.30.42.23.9877: Flags [.], ack 1,
win 115, options [nop,nop,TS val 84039134 ecr 4238266,nop,nop,sack 1
{0:1}], length 0
21:38:43.061118 IP 172.30.42.23.9877 > glaptop.53627: Flags [S.], seq
1077519728, ack 1124582231, win 14480, options [mss 1460,sackOK,TS val
4246266 ecr 84039134,nop,wscale 7], length 0
21:38:43.061357 IP glaptop.53627 > 172.30.42.23.9877: Flags [.], ack 1,
win 115, options [nop,nop,TS val 84039934 ecr 4246266,nop,nop,sack 1
{0:1}], length 0
21:38:59.061135 IP 172.30.42.23.9877 > glaptop.53627: Flags [S.], seq
1077519728, ack 1124582231, win 14480, options [mss 1460,sackOK,TS val
4262266 ecr 84039934,nop,wscale 7], length 0
21:38:59.061434 IP glaptop.53627 > 172.30.42.23.9877: Flags [.], ack 1,
win 115, options [nop,nop,TS val 84041534 ecr 4262266,nop,nop,sack 1
{0:1}], length 0
