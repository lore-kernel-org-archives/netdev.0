From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netdev ioctl & dev_base_lock : bad idea ?
Date: Wed, 8 Dec 2004 23:13:31 -0800
Message-ID: <20041208231331.40cd98ad.davem@davemloft.net>
References: <1101458929.28048.9.camel@gaston>
	<20041208220642.6984519f.davem@davemloft.net>
	<1102573333.16495.2.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1102573333.16495.2.camel@gaston>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 09 Dec 2004 17:22:13 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> Right, and I missed the fact that we did indeed take the semaphore and
> not the lock in the _set_ functions which is just fine, we can actually
> schedule.... except in set_multicast...
> 
> Is there any reason we actually _need_ to get the xmit lock in this one
> specifically ?

Since we implement NETIF_F_LLTX, the core packet transmit routines do
no locking, the driver does it all.

So if we don't hold the tx lock in the set multicast routine, any other
cpu can come into our hard_start_xmit function and poke at the hardware.

Upon further consideration, it seems that it may be OK to drop that tx
lock right after we do the netif_stop_queue().  But we should regrab
the tx lock when we do the subsequent netif_wake_queue().
