From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v6 04/20] can: EG20T PCH: Add Tx Flow Control
Date: Thu, 02 Dec 2010 13:12:36 -0800 (PST)
Message-ID: <20101202.131236.28815617.davem@davemloft.net>
References: <4CF47B2C.4010507@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CF47B2C.4010507-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Date: Tue, 30 Nov 2010 13:18:52 +0900

> Currently, there is no flow control processing.
> Thus, Add flow control processing as
> when there is no empty of tx buffer,
> netif_stop_queue is called.
> When there is empty buffer, netif_wake_queue is called.
> 
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

When implementing functionality like this it is better to use other
existing well tested network drivers as a guide rather then trying
to be unique and clever, as you are doing here.

First of all, your netif_wake_queue() call is racy.  Because another
thread can be queueing up packets, fill the queue, and execute a
stop queue right when you have made the decision to invoke
netif_wake_queue().

Second of all, checking the state of the device to determine if a
stop queue should be performed has two problems:

1) The test uses a magic constant mask, which is undocumented.

2) It causes the race you have on the wake queue side

Use pure software state to guide your actions, and let the hardware
interrupt trigger the wake queue.

Also, you don't implement this as a true ring buffer, you only
consider to stop the queue when you hit the last TX object entry.  But
all the previous slots could be available.

Your head and tail pointer need to be maintained by advancing the
head pointer only during pch_xmit(), and advancing the tail pointer
only in the NAPI code as you get indications from the hardware.

Then, after the NAPI TX code advances the tail pointer, you see if
1) the queue is stopped and 2) TX space is now available.  If both
are true you wake the queue.

Use a well tested and mature driver like drivers/net/tg3.c as a
guide.  Search for netif_tx_{stop,wake}_queue().
