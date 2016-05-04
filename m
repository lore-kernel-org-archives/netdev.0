From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH] tcp: ensure non-empty connection request queue
Date: Wed, 4 May 2016 11:40:15 +0200
Message-ID: <20160504094015.GA1346@al>
References: <1462312458-2077-1-git-send-email-peter@lekensteyn.nl>
 <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Kui Zhang <kuizhang@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lekensteyn.nl ([178.21.112.251]:33913 "EHLO lekensteyn.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbcEDJlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 05:41:00 -0400
Content-Disposition: inline
In-Reply-To: <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 05:25:44PM -0700, Eric Dumazet wrote:
> On Tue, 2016-05-03 at 23:54 +0200, Peter Wu wrote:
> > When applications use listen() with a backlog of 0, the kernel would
> > set the maximum connection request queue to zero. This causes false
> > reports of SYN flooding (if tcp_syncookies is enabled) or packet drops
> > otherwise.
> > 
> > Prior kernels enforce a minimum size of 8, so do that now as well.
> > 
> > Fixes: ef547f2ac16b ("tcp: remove max_qlen_log")
> > Signed-off-by: Peter Wu <peter@lekensteyn.nl>
> > ---
> > Hi,
> > 
> > This patch fixes a regression from Linux 4.4. Use of "qemu-arm -g 1234"
> > would trigger the following warning in dmesg:
> > 
> >     TCP: request_sock_TCP: Possible SYN flooding on port 1234. Sending cookies.  Check SNMP counters.
> > 
> > For some users the "tcp: remove max_qlen_log" change already broke
> > applications[1]. While listen(3p) says that a backlog argument of 0 sets
> > the length to an "implementation-defined minimum value", I doubt that
> > "0" should be considered a valid value (as demonstrated in the above two
> > real-world applications that worked fine before). It is a hint anyway.
> > 
> > This patch was tested on top of Linux v4.5 and removes the warning which
> > would otherwise be present (due to the inet_csk_reqsk_queue_is_full()
> > check in tcp_conn_request).
> > 
> > I also looked at modifying the backlog value in inet_listen, but that
> > might have other unintended effects:
> > 
> >  - If TFO is enabled and tcp_fastopen==0x400, listen(fd, 0) currently
> >    disables TFO (also possible via setsockopt). Forcing a minimum breaks
> >    this path (unlikely to be a problem though since TFO users likely set
> >    a much higher backlog).
> >  - sk->sk_max_ack_backlog is also reported via tcp statistics and seems
> >    really to be the hint rather than the actual interpreted value.
> > 
> > Kind regards,
> > Peter
> > 
> >  [1]: https://lkml.kernel.org/r/CANn89i+OKfw896-N5KsNDEikzUidR8yX1JC089hJnGGfDQ0mzw@mail.gmail.com
> > ---
> >  include/net/inet_connection_sock.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> > index 49dcad4..ca0fdbc 100644
> > --- a/include/net/inet_connection_sock.h
> > +++ b/include/net/inet_connection_sock.h
> > @@ -296,7 +296,7 @@ static inline int inet_csk_reqsk_queue_young(const struct sock *sk)
> >  
> >  static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
> >  {
> > -	return inet_csk_reqsk_queue_len(sk) >= sk->sk_max_ack_backlog;
> > +	return inet_csk_reqsk_queue_len(sk) >= max(8U, sk->sk_max_ack_backlog);
> >  }
> >  
> >  void inet_csk_reqsk_queue_drop(struct sock *sk, struct request_sock *req);
> 
> Well, I believe I already gave my opinion on this.
> 
> listen backlog is not a hint. This is a limit.
> 
> It is the limit of outstanding children in accept queue.
> 
> If backlog is 0, no child can be put in the accept queue.
> 
> It is therefore Working As Intented.

Alright, this is actually described in the Linux manual (listen(2)):

    Now it specifies the queue length for completely established sockets
    waiting to be accepted, instead of the number of incomplete
    connection requests.

The POSIX manual (listen(3p)) says:

    A backlog argument of 0 may allow the socket to accept connections,
    in which case the length of the listen queue may be set to an
    implementation-defined minimum value.

Not accepting a connection is apparently valid due to the wording ("may
allow"). Fair enough, please drop this patch. Applications will have to
be fixed then.

Kind regards,
Peter
