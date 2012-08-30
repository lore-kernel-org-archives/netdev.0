From: Richard Davies <richard.j.davies@gmail.com>
Subject: Re: Slow inbound traffic on macvtap interfaces
Date: Thu, 30 Aug 2012 09:20:57 +0100
Message-ID: <20120830082057.GA18072@alpha.arachsys.com>
References: <20120816092004.GA1894@arachsys.com>
 <20120829175256.GC3529@arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, qemu-devel@nongnu.org,
	Jason Wang <jasowang@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>, Michael Tsirkin <mst@redhat.com>
To: Chris Webb <chris@arachsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.arachsys.com ([91.203.57.7]:46562 "EHLO
	alpha.arachsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266Ab2H3ItU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 04:49:20 -0400
Content-Disposition: inline
In-Reply-To: <20120829175256.GC3529@arachsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Webb wrote:
> I found that on my laptop, the single change of host kernel config
>
> -CONFIG_INTEL_IDLE=y
> +# CONFIG_INTEL_IDLE is not set
>
> is sufficient to turn transfers into guests from slow to full wire speed

I am not deep enough in this code to write a patch, but I wonder if
macvtap_forward in macvtap.c is missing a call to kill_fasync, which I
understand is used to signal to interested processes when data arrives?


Here is the end of macvtap_forward:

  skb_queue_tail(&q->sk.sk_receive_queue, skb);
  wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
  return NET_RX_SUCCESS;


Compared to this end of tun_net_xmit in tun.c:

  /* Enqueue packet */
  skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);

  /* Notify and wake up reader process */
  if (tun->flags & TUN_FASYNC)
          kill_fasync(&tun->fasync, SIGIO, POLL_IN);
  wake_up_interruptible_poll(&tun->wq.wait, POLLIN |
                             POLLRDNORM | POLLRDBAND);
  return NETDEV_TX_OK;


Richard.
