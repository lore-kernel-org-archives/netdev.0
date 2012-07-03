From: Willy Tarreau <w@1wt.eu>
Subject: Re: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Tue, 3 Jul 2012 02:02:02 +0200
Message-ID: <20120703000202.GC11039@1wt.eu>
References: <1341237299.22621.88.camel@edumazet-glaptop> <1341245191.2177.40.camel@schurl.lan> <CAAsGZS6ahzUo+QRcLOyPcj5=mp53O+M9kqByOwPb0zZcr-cgwQ@mail.gmail.com> <1341265024.22621.464.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chetan loke <loke.chetan@gmail.com>,
	Andreas Gruenbacher <agruen@linbit.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341265024.22621.464.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Mon, Jul 02, 2012 at 11:37:04PM +0200, Eric Dumazet wrote:
> On Mon, 2012-07-02 at 15:41 -0400, chetan loke wrote:
> > On Mon, Jul 2, 2012 at 12:06 PM, Andreas Gruenbacher <agruen@linbit.com> wrote:
> > > On Mon, 2012-07-02 at 15:54 +0200, Eric Dumazet wrote:
> > >> So I will just say no to your patches, unless you demonstrate the
> > >> splice() problems, and how you can fix the alignment problem in a new
> > >> layer instead of in the existing zero copy standard one.
> > >
> > > Again, splice or not is not the issue here. It does not, by itself, allow zero
> > > copy from the network directly to disk but it could likely be made to support
> > > that if we can get the alignment right first.  The proposed MSG_NEW_PACKET flag
> > > helps with that, but maybe someone has a better idea.
> > >
> > 
> > Eric - by using splice do you mean something like:
> > 
> > int filedes[2];
> > PIPE_SIZE (64*1024)
> > pipe(filedes);
> > ret = splice (sock_fd_from, &from_offset, filedes [1], NULL, PIPE_SIZE,
> >                      SPLICE_F_MORE | SPLICE_F_MOVE);
> > 
> > 
> > ret = splice (filedes [0], NULL, file_fd_to,
> >                          &to_offset, ret,
> >                          SPLICE_F_MORE | SPLICE_F_MOVE);
> > 
> 
> Yes, thats more or less the plan. You also can play with bigger
> PIPE_SIZE if needed.

I confirm, this is recommended at high bit rates if you're working with
large windows.

> > i.e. splice-in from socket to pipe, and splice-out from pipe to destination?
> > 
> > Andreas - if the above assumption is true then can you apply the
> > 'MSG_NEW_PACKET' on the sender and see if the above pseudo-splice code
> > achieves something similar to what you expect on the receive side(you
> > can also play w/ F_SETPIPE_SZ -  although I found very little
> > reduction in CPU usage)? Note: My personal experience - using splice
> > from an input-file-A to output-file-B bought very minimal cpu
> > reduction(yes, both the files used O_DIRECT). Instead, a simple
> > read/write w/ O_DIRECT from file-A to file-B was much much faster.
> 
> splice() performance from socket to pipe have improved a lot in
> linux-3.5
> 
> It was not true zero copy, until very recent patches.

In fact it has been true zero copy in 2.6.25 until we faced a large
amount of data corruption and the zero copy was disabled in 2.6.25.X.
Since then it remained that way until you brought your patches to
re-instantiate it.

> (It was zero copy only on certain class of NIC, not on the ones found
> on appliances or cheap platforms)
> 
> Willy Tarreau mentioned a nice boost of performance with haproxy.

Yes definitely. The savings are more noticeable on small systems where
memory bandwidth is limited. On a small ARM system bound by RAM bandwidth,
the performance was basically doubled. But I also observed nice savings
on a core2duo equipped with 2 myricom 10Gig NICs forwarding at line rate.

> Willy wanted to work on a direct splice from socket to socket, but
> I am not sure it'll bring major speed improvement.

I'm not sure at all either, I'm betting a few percent saved from the
reduction of syscalls, not much more. This is why I'll probably check
this when I have enough time to kill.

Regards,
Willy
