From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Thu, 18 Oct 2012 23:02:53 -0700
Message-ID: <CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	<507C4401.7050500@oracle.com>
	<CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	<CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	<5080279F.80008@oracle.com>
	<5080340F.3050207@oracle.com>
	<CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: enh <enh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40263 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab2JSGCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:02:53 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so105755obb.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 23:02:53 -0700 (PDT)
In-Reply-To: <CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> They all remain on ESTABLISHED state on the client side.
>
> yeah, that's what i see with netstat -t too.
>

> (https://android-review.googlesource.com/#/c/44563/), but i'd love to
> at least understand what's going on here, even if it's just that i
> have a fundamental misunderstanding of what the listen backlog is
> supposed to mean.
>

The listen backlog represents the number of received SYNs that have
not been processed i.e. for which a SYN-ACK has not been sent.
Actually, the number of SYNs
that can be pending for processing is actually backlog+1. With a
backlog of 1, there can be 2 SYNs that can be pending for processing.

Once a SYN is processed by the server socket (in LISTEN state) and a
syn-ack is sent back, a request_sock is created to represent it. Once
the client replies with the last step of connect() i.e. with  an ack,
a fully established socket is created. The number of queued
request-socks for a LISTEN socket can be much more than the backlog
limit given in listen() (which is 1 in your case). If after a short
period (after SYNACK_RETRIES), the three way handshake is not
completed, request_socks can be silently discarded.

When a SYN is received, it is processed by   tcp_v4_conn_request()
where we have..
if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 got drop;

So, for the SYN to be dropped, backlog limit must be exceeded _and_ we
must have recently accepted another SYN request. So, even when backlog
limit is exceeded, SYNs are processed and syn-acks are sent back. It
seems that the listen backlog limit is applied definitively only in
the third step in tcp_v4_syn_recv_sock() and not in the first step.
In  tcp_v4_syn_recv_sock(), we have
 if (sk_acceptq_is_full(sk))
                goto exit_overflow;

This prevents the socket from being created fully. On the client side
however, since the three way handshake has finished, the socket goes
into ESTABLISHED state which is what you see with netstat. In your
test case, typically 2 connections are in state where SYN has to be
processed  and rest are as request_sock where synacks have been sent.
However,
they may not become fully created sockets as they will fail in step 3
as described above.

man listen() says
" The  backlog  argument  defines  the maximum length to which the
queue of pending connections for sockfd may grow. " In your case where
backlog is 1, there can be a max of 2 pending connections (SYNs not
yet processed) and this is what we see. By this interpretation,
behavior seems correct.

Not sure if this behavior is a bug but the processing in
tcp_v4_conn_request()  does look suspicious. Should we terminate
earlier without doing three way hand shake?
Perhaps someone who knows this better can clarify.

Hope this helps.
Vijay
