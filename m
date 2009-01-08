From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 8 Jan 2009 23:03:45 +0100
Message-ID: <20090108220345.GB24243@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <20090108194424.GE32491@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Ben Mansell <ben@zeus.com>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761751AbZAHWEU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090108194424.GE32491@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 08, 2009 at 08:44:24PM +0100, Jens Axboe wrote:
> On Thu, Jan 08 2009, Willy Tarreau wrote:
> > Jens,
> > 
> > here's the other patch I was talking about, for better behaviour of
> > non-blocking splice(). Ben Mansell also confirms similar improvements
> > in his tests, where non-blocking splice() initially showed half of
> > read()/write() performance. Ben, would you mind adding a Tested-By
> > line ?
> 
> Looks very good to me, I don't see any valid reason to have that !timeo
> break. So feel free to add my acked-by to that patch and send it to
> Dave.

Done, thanks.

Also, I tried to follow the code path from the userspace splice() call and
the kernel code. While splicing from socket to a pipe seems obvious till
tcp_splice_read(), I have a hard time finding the correct way from the pipe
to the socket.

It *seems* to me that we proceed like this, I'd like someone to confirm :

sys_splice()
  do_splice()
    do_splice_from()
      generic_splice_sendpage()      [ I assumed this from socket_file_ops ]
        splice_from_pipe(,,pipe_to_sendpage)
          __splice_from_pipe(,,pipe_to_sendpage)
            pipe_to_sendpage()
              tcp_sendpage()         [ I assumed this from inet_stream_ops ]
                do_tcp_sendpages()   (if NETIF_F_SG) or sock_no_sendpage()

I hope that I guessed it right because it does not appear obvious to me. It
will help me try to understand better the corruption problem.

Now for the read part, am I wrong tcp_splice_read() will return -EAGAIN
if the pipe is full ? It seems to me that this will be brought up by
splice_to_pipe(), via __tcp_splice_read, tcp_read_sock, tcp_splice_data_recv
and skb_splice_bits.

If so, this can cause serious trouble because if there is data available in
a socket, poll() will return POLLIN. Then we call splice(sock, pipe) but the
pipe is full, so we get -EAGAIN, which in turn makes the application think
that we need to poll again, and since no data has moved, we'll immediately
call splice() again. In my early experiments, I'm pretty sure I already came
across such a situation. Shouldn't we return -EBUSY or -ENOSPC in this case ?
I can work on patches if there is a consensus around those issues, and this
will also help me understand better the splice internals. I just don't want
to work in the wrong direction for nothing.

Thanks,
Willy
