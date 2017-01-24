From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 20:11:27 +0100
Message-ID: <20170124191127.GG21921@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <1485279889.16328.306.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170124183446.GE21921@1wt.eu>
 <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Wang <tracywwnj@gmail.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:65061 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750735AbdAXTLh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:11:37 -0500
Content-Disposition: inline
In-Reply-To: <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 10:51:25AM -0800, Eric Dumazet wrote:
> We do not return -1 / EINPROGRESS but 0
> 
> Do not call connect() twice, it is clearly not supposed to work.

Yes it is, it normally returns -1 / EISCONN on a regular socket :

      EISCONN
              The socket is already connected.

> Fact that it happened to work is still kept for applications not using
> new features (like TCP_FASTOPEN_CONNECT), we wont break this.

Sure but as we saw, deeply burried silent bugs having no effect in
existing applications can suddenly become problematic once TFO is
enabled, and the semantics difference between the two are minimal
enough to warrant being closed.

> I would prefer you submit _if_ needed a patch on top of Wei patch, which
> was carefully tested with our ~500 packetdrill tests.

I totally understand and rest assured that I have a great respect for
this amount of test, which is also why I find the feature really exciting.
I'll probably propose something involving an extra argument then, this
will be much easier to review in the perspective of the existing tests.

> TCP_FASTOPEN_CONNECT + connect() returning 0 is already a violation of
> past behavior, in the sense that no connection really happened yet.

I agree but semantically it could be considered that it means "connect()
already called successfully, feel free to proceed with send() whenever
you want" and that's why it's appealing ;-)

> An application exploiting this return value and consider the server is
> reachable would be mistaken.

100% agree, I even had a private discussion regarding this, mentionning
that I already added a test in haproxy to only enable it if there are
data scheduled for leaving. In my case it's easy because I already have
the same test to decide whether or not to disable TCP_QUICKACK to save
one packet by sending the payload with the first ACK. So in short it will
be :

     if (data) {
          if (disable_quick_ack)
               setsockopt(fd, SOL_TCP, TCP_QUICKACK, &zero, sizeof(&zero));
          if (enable_fastopen)
               setsockopt(fd, SOL_TCP, TCP_FASTOPEN_CONNECT, &one, sizeof(&one));
     }
     connect(fd, ...);

But I certainly understand that in some implementations it's could be
trickier. That just reminds me that I haven't tested it combined with
splicing. I'll have to try this.

> We do not support connect() + TCP_FASTOPEN_CONNECT + read(), because we
> do not want to add yet another conditional test in recvmsg() fast path
> for such feature, while existing sendmsg() can already be used to send a
> SYN with FastOpen option.

Yes, I think the mechanism is complex enough internally not to try to
make it even more complex :-)

> So people are not expected to blindly add TCP_FASTOPEN_CONNECT to every
> TCP socket they allocate/use. This would add too much bloat to the
> kernel.

I really think that the true benefit of TFO is for HTTP and SSL where
the client speaks first and already has something to say when the decision
to connect is made. It should be clear in implementors' minds that it
cannot be a default setting and that it doesn't make sense.

Thanks,
Willy
