From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Sun, 23 Jan 2005 20:27:15 -0800
Message-ID: <20050123202715.281ac87c.davem@davemloft.net>
References: <20050124005348.GL23931@postel.suug.ch>
	<E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, kaber@trash.net, david@davidcoulson.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Jan 2005 12:31:34 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Something is screwed up here.  If the packet really went
> through forwarding, then skb->ip_summed should be CHECKSUM_NONE.
> This is done as the first thing in ip_forward().
> 
> So if you're seeing CHECKSUM_HW at the end of the pipe,
> then somebody must've changed it.  CHECKSUM_HW should
> only be seen in dev_queue_xmit for locally generated
> traffic.

Yes.  This backtrace is very strange.  Let me take this
chance to get on my podium and re-express my distaste
for x86's inaccurate backtraces.  They make debugging so
difficult.  It's time for some dwarf2 unwind table support
the kernel x86 backtracer and a way to enable it during the
build.

My current guess is that this is some successful exploit
of some as-yet-unknown issue in netfilter's fragmentation
handling.  But that's just a guess.  If some code underruns
skb->data somehow while unfragging/refragging, that's a sure
fire way to corrupt things such as the skb->ip_summed field.

All the theoretical attack has to do is find some way to
copy a "1" into the byte at skb->ip_summed, as that's the
value of CHECKSUM_HW.

It would be nice to just log a full tcpdump trace for that
UDP port on the incoming interface on that machine.  This
will allow us to see the exact traffic pattern.
