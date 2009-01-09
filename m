From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 19:54:48 +0100
Message-ID: <20090109185448.GA1999@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1321 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbZAISzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 13:55:17 -0500
Content-Disposition: inline
In-Reply-To: <49677074.5090802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Jan 09, 2009 at 04:42:44PM +0100, Eric Dumazet wrote:
(...)
> Willy patch makes splice() behaving like tcp_recvmsg(), but we might call
> tcp_cleanup_rbuf() several times, with copied=1460 (for each frame processed)
> 
> I wonder if the right fix should be done in tcp_read_sock() : this is the
> one who should eat several skbs IMHO, if we want optimal ACK generation.
> 
> We break out of its loop at line 1246
> 
> if (!desc->count) /* this test is always true */
> 	break;
> 
> (__tcp_splice_read() set count to 0, right before calling tcp_read_sock())
> 
> So code at line 1246 (tcp_read_sock()) seems wrong, or pessimistic at least.

That's a very interesting discovery that you made here. I have made
mesurements with this line commented out just to get an idea. The
hardest part was to find a CPU-bound machine. Finally I slowed my
laptop down to 300 MHz (in fact, 600 with throttle 50%, but let's
call that 300). That way, I cannot saturate the PCI-based tg3 and
I can observe the effects of various changes on the data rate.

- original tcp_splice_read(), with "!timeo"    : 24.1 MB/s
- modified tcp_splice_read(), without "!timeo" : 32.5 MB/s (+34%)
- original with line #1246 commented out       : 34.5 MB/s (+43%)

So you're right, avoiding calling tcp_read_sock() all the time
gives a nice performance boost.

Also, I found that tcp_splice_read() behaves like this when breaking
out of the loop :

    lock_sock();
    while () {
         ...
         __tcp_splice_read();
         ...
         release_sock();
         lock_sock();
         if (break condition)
              break;
    }
    release_sock();

Which means that when breaking out of the loop on (!timeo)
with ret > 0, we do release_sock/lock_sock/release_sock.

So I tried a minor modification, consisting in moving the
test before release_sock(), and leaving !timeo there with
line #1246 commented out. That's a noticeable winner, as
the data rate went up to 35.7 MB/s (+48%).

Also, in your second mail, you're saying that your change
might return more data than requested by the user. I can't
find why, could you please explain to me, as I'm still quite
ignorant in this area ?

Thanks,
Willy

