From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Slow inbound traffic on macvtap interfaces
Date: Thu, 30 Aug 2012 11:44:33 +0300
Message-ID: <20120830084433.GC10269@redhat.com>
References: <20120816092004.GA1894@arachsys.com>
	<20120829175256.GC3529@arachsys.com>
	<20120830082057.GA18072@alpha.arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	Chris Webb <chris@arachsys.com>, qemu-devel@nongnu.org,
	Arnd Bergmann <arnd@arndb.de>
To: Richard Davies <richard.j.davies@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <20120830082057.GA18072@alpha.arachsys.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2012 at 09:20:57AM +0100, Richard Davies wrote:
> Chris Webb wrote:
> > I found that on my laptop, the single change of host kernel config
> >
> > -CONFIG_INTEL_IDLE=y
> > +# CONFIG_INTEL_IDLE is not set
> >
> > is sufficient to turn transfers into guests from slow to full wire speed
> 
> I am not deep enough in this code to write a patch, but I wonder if
> macvtap_forward in macvtap.c is missing a call to kill_fasync, which I
> understand is used to signal to interested processes when data arrives?
> 

No, only if TUN_FASYNC is set. qemu does not seem to set it.

> Here is the end of macvtap_forward:
> 
>   skb_queue_tail(&q->sk.sk_receive_queue, skb);
>   wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
>   return NET_RX_SUCCESS;
> 
> 
> Compared to this end of tun_net_xmit in tun.c:
> 
>   /* Enqueue packet */
>   skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
> 
>   /* Notify and wake up reader process */
>   if (tun->flags & TUN_FASYNC)
>           kill_fasync(&tun->fasync, SIGIO, POLL_IN);
>   wake_up_interruptible_poll(&tun->wq.wait, POLLIN |
>                              POLLRDNORM | POLLRDBAND);
>   return NETDEV_TX_OK;
> 
> 
> Richard.
