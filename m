From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Thu, 5 May 2005 23:13:45 -0700
Message-ID: <20050505231345.4296d9b5.davem@davemloft.net>
References: <20050504230731.12be1bc3.davem@davemloft.net>
	<20050506043653.GD8255@krispykreme>
	<20050506054516.GE8255@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050506054516.GE8255@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 May 2005 15:45:16 +1000
Anton Blanchard <anton@samba.org> wrote:

> With a 9000 byte MTU I see page sized frags as expected. There are still
> some pages broken in two which is interesting.

I know what is causing the breaks, it's the "cache line align" crap
in tcp_sendmsg().

Comment out this alignment code in net/ipv4/tcp.c and see how it goes:

					/* If page is cached, align
					 * offset to L1 cache boundary
					 */
					off = (off + L1_CACHE_BYTES - 1) &
					      ~(L1_CACHE_BYTES - 1);

This alignment causes TSO coalescing to fail at these spots.

You should not see this effect when sendfile() is used for
the transfer.
