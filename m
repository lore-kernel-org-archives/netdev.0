From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] UDP select handling of bad checksums.
Date: Tue, 2 Nov 2004 16:52:53 -0800
Message-ID: <20041103005253.GA77817@gaz.sfgoth.com>
References: <20041102162454.3f153ff0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041102162454.3f153ff0@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch addresses the issue of blocking usage of select() by UDP applications.

I'm glad to see someone actually putting some code forward in this debate...
Looks pretty good, but can't you implement this a bit cleaner by just
wrapping datagram_poll?  Something like:

unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
{
   unsigned int mask = datagram_poll(file, sock, wait);

  if ((mask & POLLRDNORM) != 0 && (file->f_flags & O_NONBLOCK) == 0 && 
      (sk->sk_shutdown & RCV_SHUTDOWN) == 0) {
	struct sk_buff_head *rcvq = &sk->sk_receive_queue;
	struct sk_buff *skb;
	spin_lock_irq(&rcvq->lock);
	// the skb_peek() loop from your udp_rcv_ready() goes here...
	spin_unlock_irq(&rcvq->lock);
	if (skb == NULL)	/* nope, nothing really ready */
	  mask &= ~(POLLIN | POLLRDNORM);
  }

  return mask;
}

That way you duplicate a lot less code.  It does slightly more work but
only in the broken !O_NONBLOCK case - the fast path is just as quick.

-Mitch
